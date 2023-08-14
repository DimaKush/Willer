import { Text } from "@chakra-ui/react"
import { ERC20Balances } from "components/balances/ERC20Balances"
import { NFTBalances } from "components/balances/NFTBalances"
import { IERC721, willerContract } from "components/Interfaces"
import { Default } from "components/layouts/Default"
import { Will } from "components/modules"
import { BigNumber, ethers } from "ethers"
import Moralis from "moralis"
import type { GetServerSideProps, NextPage } from "next"


const TestatorPage: NextPage = (props: any) => {
    return (
        <Default pageName="Will">
            {(props.error) ? (<Text>{(props.error)}</Text>) : (
                <>
                <Will {...props} />
                <ERC20Balances {...props} />
                <NFTBalances {...props} />
                </>
            )}
        </Default>
    )
}

export const getServerSideProps: GetServerSideProps = async (context) => {
    const provider = new ethers.providers.InfuraProvider(Number(process.env.APP_CHAIN_ID), { infura: process.env.INFURA_API_KEY })    
    if (!context.params?.testatorAddress) {
        return { props: { error: 'Connect wallet' } }
    }
    
    const tokenBalances = await Moralis.EvmApi.token.getWalletTokenBalances(
        {
            address: context.params?.testatorAddress as string,
            chain: Number(process.env.APP_CHAIN_ID),
        }
    )

    const filteredTokenBalances = tokenBalances.toJSON().filter((token) => {
        return token.name !== null && token.symbol !== null && token.decimals !== null
    })
    const nftBalances = await Moralis.EvmApi.nft.getWalletNFTs({
        address: context.params?.testatorAddress as string,
        chain: Number(process.env.APP_CHAIN_ID),
    });
    
    const tokensWithAllowance = await Promise.all(filteredTokenBalances.map(async (balance: any) => {
        const allowance = await Moralis.EvmApi.token.getTokenAllowance({
            chain: Number(process.env.APP_CHAIN_ID),
            address: balance.token_address as string,
            ownerAddress: context.params?.testatorAddress as string,
            spenderAddress: willerContract.address,
        })
        return ({
            ...balance,
            isApprovedForAll: BigNumber.from(allowance.toJSON().allowance).gt(BigNumber.from(balance.balance)),
            })
        }))

    const nftWithAllowance = await Promise.all(nftBalances.result.map(async (balance: any) => {
        const contract = new ethers.Contract(balance._data.tokenAddress._value, IERC721, provider)
        const allowance = await contract.isApprovedForAll(context.params?.testatorAddress, willerContract.address)
        return ({
            ...balance._data,
            tokenAddress: balance._data.tokenAddress._value,
            ownerOf: balance._data.ownerOf._value,
            isApprovedForAll: allowance,
        })
    }
    ))
    
    return {
        props: {
            tokenBalances: tokensWithAllowance,
            nftBalances: JSON.parse(JSON.stringify(nftWithAllowance)),
            testatorAddress: context.params?.testatorAddress,
        },
    };

};

export default TestatorPage
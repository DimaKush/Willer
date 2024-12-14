import { Text } from "@chakra-ui/react"
import { readContract } from "@wagmi/core"
import { ERC20Balances } from "components/balances/ERC20Balances"
import { NFTBalances } from "components/balances/NFTBalances"
import { IERC20, IERC721, willerContract } from "components/Interfaces"
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
    if (!context.params?.testatorAddress) {
        return { props: { error: 'Connect wallet' } }
    }

    const tokenBalances = await Moralis.EvmApi.token.getWalletTokenBalances(
        {
            address: context.params?.testatorAddress as string,
            chain: Number(11155111),
        }
    )

    const filteredTokenBalances = tokenBalances.toJSON().filter((token) => {
        return token.name !== null && token.symbol !== null && token.decimals !== null
    })
    const nftBalances = await Moralis.EvmApi.nft.getWalletNFTs({
        address: context.params?.testatorAddress as string,
        chain: Number(11155111),
    });

    const tokensWithAllowance = await Promise.all(filteredTokenBalances.map(async (balance: any) => {
        if (balance) {
            const allowance = await readContract({
                address: balance.token_address,
                abi: IERC20,
                functionName: 'allowance',
                args: [context.params?.testatorAddress, willerContract.address],
                
            })
            return ({
                ...balance,
                isApprovedForAll: BigNumber.from(allowance).gt(BigNumber.from(balance.balance)),
            })
        }
        return ({
            ...balance,
            isApprovedForAll: false,
        })
    }))

    const nftWithAllowance = await Promise.all(nftBalances.result.map(async (balance: any) => {
        if (balance) {
            const allowance = await readContract({
                address: balance._data.tokenAddress._value,
                abi: IERC721,
                functionName: 'isApprovedForAll',
                args: [context.params?.testatorAddress, willerContract.address]
            })
            return ({
                ...balance._data,
                tokenAddress: balance._data.tokenAddress._value,
                ownerOf: balance._data.ownerOf._value,
                isApprovedForAll: allowance,
            })
        }
        return ({
            ...balance,
            isApprovedForAll: false,
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
import { Button, Tooltip } from '@chakra-ui/react'
import { willerContract } from 'components/Interfaces'
import { ethers } from 'ethers'
import { useRouter } from 'next/router'
import type { FC } from 'react'
import { useContractWrite, usePrepareContractWrite } from 'wagmi'

interface Balances {
    tokenBalances?: Erc20Value[];
    nftBalances?: TNFTBalance[];
    testatorAddress: string;
    error?: string;
  }
  
interface IMetadata {
    name: string;
    description: string;
    image: string;
  }
  
type TNFTBalance = {
    tokenAddress: string;
    chain: string | number;
    ownerOf: string;
    blockNumberMinted: string | undefined;
    blockNumber: string | undefined;
    tokenId: string | number;
    contractType: string | number;
    tokenUri?: string | undefined;
    tokenHash?: string | undefined;
    metadata: IMetadata | undefined;
    name?: string | undefined;
    symbol?: string | undefined;
    lastMetadataSync?: Date | undefined;
    lastTokenUriSync?: Date | undefined;
    amount?: number | undefined;
    isApprovedForAll?: boolean | undefined;
  };

type Erc20Value =
  {
      balance: string;
      token_address: string;
      chain: string | number;
      decimals: number;
      name: string;
      symbol: string;
      logo?: string | null | undefined;
      logoHash?: string | null | undefined;
      thumbnail?: string | null | undefined;
      isApprovedForAll?: boolean | undefined;
    }

const ExecuteButton: FC<Balances> = ({tokenBalances, nftBalances, testatorAddress}) => {
    const getListsForBatchRelease = (approvedTokenList: TNFTBalance[]) => {
        const tokenList = new Array()
        const tokenIdLists = new Array()
        if (approvedTokenList) {
            for (const i of approvedTokenList) {
                if (!tokenList.includes(i.tokenAddress)) {
                    tokenList.push(i.tokenAddress)
                    tokenIdLists.push([i.tokenId])
                } else {
                    const index = tokenList.indexOf(i.tokenAddress)
                    tokenIdLists[index].push(i.tokenId)
                }
            }
        }
        return { tokenList, tokenIdLists }
    }
    const approvedERC20Addresses = tokenBalances ? tokenBalances.map((i: Erc20Value) => {
        if (i.isApprovedForAll) {return i.token_address} return undefined
    }).filter((n: any) => n) : []
    const approvedERC721 = nftBalances && nftBalances.filter((i: any) => (i.isApprovedForAll && i.contractType === 'ERC721'))
    const approvedERC1155 = nftBalances && nftBalances.filter((i: any) => (i.isApprovedForAll && i.contractType === 'ERC1155'))

    const { tokenList: ERC721List, tokenIdLists: ERC721tokenIdLists } = getListsForBatchRelease(approvedERC721!)
    const { tokenList: ERC1155List, tokenIdLists: ERC1155tokenIdLists } = getListsForBatchRelease(approvedERC1155!)

    const args = [testatorAddress, approvedERC20Addresses, ERC721List, ERC1155List, ERC721tokenIdLists, ERC1155tokenIdLists]
    const { config } = usePrepareContractWrite({
        address: willerContract.address,
        abi: willerContract.abi,
        functionName: 'batchRelease',
        args,
        chainId: Number(11155111),
        onError(err) {
            console.log(err)
        },
    })
    const { write } = useContractWrite(config)
    const nothingToRelease = approvedERC20Addresses.length === 0 && ERC721List.length === 0 && ERC1155List.length === 0
    return (
        <Tooltip label={`Nothing to release`} placement='bottom' openDelay={500}
         isDisabled={!nothingToRelease}
          >
        <Button
            onClick={() => {
                write?.()
            }}
            disabled={!ethers.utils.isAddress(testatorAddress) || nothingToRelease}>
            Execute Will
        </Button>
        </Tooltip>
    )
}

export default ExecuteButton
import { Button, Tooltip, Checkbox, VStack, Text } from '@chakra-ui/react'
import { willerContract } from 'components/Interfaces'
import { ethers } from 'ethers'
import { useRouter } from 'next/router'
import type { FC } from 'react'
import { useContractWrite, usePrepareContractWrite } from 'wagmi'
import { useState } from 'react'

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
    const [selectedTokens, setSelectedTokens] = useState<{
        erc20: string[],
        erc721: TNFTBalance[],
        erc1155: TNFTBalance[]
    }>({
        erc20: [],
        erc721: [],
        erc1155: []
    })

    const handleERC20Select = (address: string) => {
        setSelectedTokens((prev) => ({
            ...prev,
            erc20: prev.erc20.includes(address) 
                ? prev.erc20.filter((a) => a !== address)
                : [...prev.erc20, address]
        }))
    }

    const handleNFTSelect = (nft: TNFTBalance, type: 'erc721' | 'erc1155') => {
        setSelectedTokens((prev) => ({
            ...prev,
            [type]: prev[type].includes(nft)
                ? prev[type].filter((n) => n !== nft)
                : [...prev[type], nft]
        }))
    }

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

    const approvedERC20Addresses = selectedTokens.erc20
    const approvedERC721 = selectedTokens.erc721
    const approvedERC1155 = selectedTokens.erc1155

    const { tokenList: ERC721List, tokenIdLists: ERC721tokenIdLists } = getListsForBatchRelease(approvedERC721)
    const { tokenList: ERC1155List, tokenIdLists: ERC1155tokenIdLists } = getListsForBatchRelease(approvedERC1155)

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
        <VStack spacing={4} align="stretch">
            {/* ERC20 Tokens */}
            {tokenBalances?.map((token: Erc20Value) => (
                token.isApprovedForAll && (
                    <Checkbox 
                        key={token.token_address}
                        isChecked={selectedTokens.erc20.includes(token.token_address)}
                        onChange={() => handleERC20Select(token.token_address)}
                    >
                        {token.symbol} ({token.balance})
                    </Checkbox>
                )
            ))}

            {/* ERC721 Tokens */}
            {nftBalances?.map((nft: TNFTBalance) => (
                nft.isApprovedForAll && nft.contractType === 'ERC721' && (
                    <Checkbox 
                        key={`${nft.tokenAddress}-${nft.tokenId}`}
                        isChecked={selectedTokens.erc721.includes(nft)}
                        onChange={() => handleNFTSelect(nft, 'erc721')}
                    >
                        {nft.name} #{nft.tokenId}
                    </Checkbox>
                )
            ))}

            {/* ERC1155 Tokens */}
            {nftBalances?.map((nft: TNFTBalance) => (
                nft.isApprovedForAll && nft.contractType === 'ERC1155' && (
                    <Checkbox 
                        key={`${nft.tokenAddress}-${nft.tokenId}`}
                        isChecked={selectedTokens.erc1155.includes(nft)}
                        onChange={() => handleNFTSelect(nft, 'erc1155')}
                    >
                        {nft.name} #{nft.tokenId} (x{nft.amount})
                    </Checkbox>
                )
            ))}

            <Tooltip 
                label={`Nothing selected to release`} 
                placement='bottom' 
                openDelay={500}
                isDisabled={!nothingToRelease}
            >
                <Button
                    onClick={() => write?.()}
                    disabled={!ethers.utils.isAddress(testatorAddress) || nothingToRelease}
                >
                    Execute Selected
                </Button>
            </Tooltip>
        </VStack>
    )
}

export default ExecuteButton
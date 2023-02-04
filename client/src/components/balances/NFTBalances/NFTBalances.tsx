import { Box, Center, Flex, Grid, Heading, Text, VStack } from '@chakra-ui/react';
import type { FC } from "react";
import { useEffect, useState } from 'react';
import { useAccount } from 'wagmi';
import DripButton from '../../buttons/DripButton/DripButton';
import { NFTCard } from '../../modules';

interface Balances {
  tokenBalances?: Erc20Value[];
  nftBalances?: TNFTBalance[];
  testatorAddress: string;
  error?: string;
}

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
}

const NFTBalances: FC<Balances> = ({ nftBalances, testatorAddress }) => {
  const account = useAccount()
  const [address, setAddress] = useState<string | undefined>(undefined)
  useEffect(() => setAddress(testatorAddress), [testatorAddress]);
  if (nftBalances?.length) {
    return (
      <Box>
        <Center>
        <Heading size="lg" marginBottom={6} pt={'69px'}>
          ERC721 & ERC1155 Balances
        </Heading>
        </Center>
        <Grid templateColumns="repeat(auto-fit, minmax(280px, 1fr))" gap={6}>
          {nftBalances.map((balance, key) => (
            <NFTCard {...balance} testatorAddress={address} key={key} />
          ))}
        </Grid>
      </Box>
    )
  }
  return (<Flex align={'center'} justify={'space-around'} pt={'23px'} >
    {
      (account.address && (address === account?.address)) ? (<VStack><Text>Looks like you do not have any ERC721 tonkens</Text><DripButton /></VStack>) : (<Text>{testatorAddress} don't have ERC721 tokens</Text>)
    }</Flex>)
}

export default NFTBalances;
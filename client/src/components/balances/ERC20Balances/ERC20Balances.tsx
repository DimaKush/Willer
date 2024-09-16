import { ExternalLinkIcon } from '@chakra-ui/icons';
import {
  Avatar, Box, Center, Flex, Heading, HStack, Link, Table, TableContainer, Tbody,
  Td, Text, Tr, VStack
} from '@chakra-ui/react';
import ERC20ApproveButton from 'components/buttons/ERC20ApproveButton/ERC20ApproveButton';
import { WrapEthField } from 'components/forms/WrapEthField';
import { formatUnits } from 'ethers/lib/utils.js';
import { FC, useEffect, useState } from 'react';
import { useAccount } from 'wagmi';
import DripButton from '../../buttons/DripButton/DripButton';

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

const ERC20Balances: FC<Balances> = ({ tokenBalances, testatorAddress }) => {
  const account = useAccount()
  useEffect(() => console.log('tokenBalances: ', tokenBalances), [tokenBalances]);
  const [address, setAddress] = useState<string | undefined>(undefined)
  useEffect(() => setAddress(testatorAddress), [testatorAddress]);
  if (tokenBalances?.length) {
    return (
      <Box>
        <Center>
          <Heading size="lg" marginBottom={6} pt={'69px'}>
            ERC20 Balances
          </Heading>
        </Center>
        <Center>
          <Box border="2px"
            borderColor={"chakra-border-color"}
            borderRadius="xl"
            padding="24px 12px"
            boxShadow='dark-lg'
            maxW={'fit-content'}
            bg={"chakra-body-bg"}>

            <TableContainer w={'full'}>
              <Table size={['xs', 'sm', 'md']}>
                <Tbody>
                  {tokenBalances?.map(({ balance, name, symbol, logo, token_address, decimals }, key) => (
                    <Tr key={`${symbol}-${key}-tr`}>
                      <Td>
                        <HStack>

                          <VStack alignItems={'flex-start'}>
                            <HStack>
                              <Avatar size="xs" src={logo || ''} name={name} />
                              <Text fontSize={['xs', 'sm', 'md']}>{name}</Text>
                              <Link isExternal href={`https://sepolia.etherscan.io/token/${token_address}`} pr={'7px'}>
                                <ExternalLinkIcon fontSize={'xs'} />
                              </Link>
                            </HStack>
                            <HStack>
                              <Text fontSize={['xs', 'sm', 'md']}>{formatUnits(balance, decimals)}</Text>
                              <Text fontSize={['xs', 'sm', 'md']}>
                                {symbol}
                              </Text>
                            </HStack>
                          </VStack>
                        </HStack>
                      </Td>
                      <Td><ERC20ApproveButton contractAddress={token_address || ''} testatorAddress={testatorAddress}/></Td>
                    </Tr>))}
                
                </Tbody>
              </Table>
              {account.address && (address === account?.address) &&
                <Center mt={4} >
                  <WrapEthField />
                </Center>}
            </TableContainer>
          </Box>
        </Center>
      </Box>
    )
  }
  return (<Flex align={'center'} justify={'space-around'} pt={'23px'}>
    {(account.address && (address === account?.address)) ? (<VStack><Text>Looks Like you do not have any ERC20 tokens</Text><DripButton /></VStack>) : (<Text>{testatorAddress} don't have ERC20 tokens</Text>)}
  </Flex>)

}

export default ERC20Balances;

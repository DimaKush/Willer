import { ExternalLinkIcon } from '@chakra-ui/icons';
import { Box, Button, Center, Flex, HStack, Link, Spinner, Table, Tbody, Td, Text, Tr, useColorModeValue, useDisclosure, VStack } from '@chakra-ui/react';
import { ExecuteButton } from 'components/buttons/ExecuteButton';
import { SetNewReleaseTimeButton } from 'components/buttons/SetNewReleaseTimeButton';
import { useWiller } from 'components/hooks';
import { WillForm } from 'components/willForm/WillForm';
import { useRouter } from 'next/router';
import { FC, useEffect, useState } from 'react';
import { getEllipsisTxt } from 'utils/format';
import { useAccount } from 'wagmi';
import { ReleaseTimeCountdown } from '../ReleaseTimeCountdown';

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


const Will: FC<Balances> = (props) => {
  const account = useAccount()
  const router = useRouter()
  const [userIsTestator, setUserIsTestator] = useState<boolean | undefined>(undefined)
  const [userIsBeneficiary, setUserIsBeneficiary] = useState<boolean | undefined>(undefined)
  useEffect(() => setUserIsTestator(account.address && props.testatorAddress === account.address), [account.address, router.asPath])
  const { isOpen, onOpen, onClose } = useDisclosure()
  const hoverTrColor = useColorModeValue('gray.100', 'gray.700');
  const will = useWiller(props.testatorAddress)
  useEffect(() => setUserIsBeneficiary((account.address && will.beneficiaries && will.beneficiaries.includes(account.address)) || (account.address === will.beneficiaryOfERC721)), [account.address, router.asPath])
  if (userIsTestator === undefined) { return <Spinner /> }
  if (!will.beneficiaries?.length || !will.releaseTime || !will.beneficiaryOfERC721) {
    return (
      <Box padding="24px 18px">
        <WillForm isOpen={isOpen} onOpen={onOpen} onClose={onClose} />
        <Flex align={'center'} justify={'space-around'}>
          {userIsTestator ? <VStack>
            <Text>
              You don't have active Will
            </Text>
            <Button onClick={onOpen}>Create Will</Button>
          </VStack> : (
            <HStack><Link isExternal href={`https://goerli.etherscan.io/address/${props.testatorAddress}`}><ExternalLinkIcon /></Link>
              <Text>
                {props.testatorAddress} don't have active Will
              </Text></HStack>)}
        </Flex>
      </Box>
    )
  }

  return (
    <Center>
      <Box border="2px" borderColor={hoverTrColor} borderRadius="xl" p="24px 18px" boxShadow='dark-lg' maxW={'fit-content'} bg={"chakra-body-bg"}>
        <WillForm isOpen={isOpen} onOpen={onOpen} onClose={onClose} />
        <VStack mb={'25px'}>
          <Text fontSize={['xs', 'sm', 'md']}>
            Testator
          </Text>
          <HStack>
            <Text fontSize={['xs', 'sm', 'md']}>
              <Link isExternal href={`https://goerli.etherscan.io/address/${props.testatorAddress}`}>
                {props.testatorAddress}
              </Link>
            </Text>
          </HStack>
        </VStack>

        <Text align={'center'} fontSize={['xs', 'sm', 'md']} mt={"50px"}>
          Beneficiaries of ERC20 & ERC1155 tokens:
        </Text>
        <Table mb={4} size={['xs', 'sm', 'md']} maxW={'full'} align='center'>
          <Tbody>
            {will.beneficiaries.map((value, key) => (
              <Tr>
                <Td>
                  <HStack>
                  <Text key={key} fontSize={['xs', 'sm', 'md']}>
                  {getEllipsisTxt(value, 10)} 
                  </Text>
                  <Link isExternal href={`https://goerli.etherscan.io/address/${value}`}><ExternalLinkIcon/></Link>
                  </HStack>
                </Td>
                <Td>
                  <Text fontSize={['xs', 'sm', 'md']}>{Number((Number(will.shares?.[key]?._hex) / (Number(will.sumShares?._hex) / 100)).toFixed(2))}%</Text>
                </Td>
              </Tr>
            ))}
          </Tbody>
        </Table>
        <VStack mb={"50px"}>
          <Text fontSize={['xs', 'sm', 'md']} mt={"50px"}>Beneficiary of all ERC721 tokens:</Text>
          <Text align={'center'} fontSize={['xs', 'sm', 'md']} >

            <Link isExternal href={`https://goerli.etherscan.io/address/${will.beneficiaryOfERC721}`}>
              {will.beneficiaryOfERC721}
            </Link>
          </Text>
        </VStack>
        <ReleaseTimeCountdown releaseTimestamp={parseInt(will.releaseTime?._hex)} />
        <VStack align={'center'} justify={'space-around'}>
          {userIsTestator ? <VStack gap={'10'}>
            <SetNewReleaseTimeButton />

            <Button onClick={onOpen}>Create new Will</Button>
            <Text color={'red.600'}>👇 Add tokens to your Will 👇</Text> 
            
          </VStack> : (userIsBeneficiary ? <ExecuteButton {...props}/> : <Text>Connected address is not beneficiary</Text>)}
        </VStack>
      </Box>
    </Center>
  )

}

export default Will
import { ExternalLinkIcon } from '@chakra-ui/icons';
import { Box, HStack, Image, Link, SimpleGrid, Spinner, Text, useColorModeValue } from '@chakra-ui/react';
import { ERC721ApproveButton } from 'components/buttons';
import { useSession } from 'next-auth/react';
import type { FC } from "react";
import { getEllipsisTxt } from 'utils/format';
import { resolveIPFS } from 'utils/resolveIPFS';
import { INFTCard } from '../NFTCard/types';

const NFTCard: FC<INFTCard> = ({ amount, contractType, name, metadata, tokenAddress, tokenId, testatorAddress, isApprovedForAll }) => {
  const descBgColor = useColorModeValue('gray.200', 'gray.600')
  const session = useSession()
  if (session.status === "loading") {return <Spinner/>}


  return (
    <Box maxWidth="315px" bgColor={"chakra-body-bg"} padding={3} borderRadius="xl" borderWidth="1px" borderColor={"chakra-border-color"} boxShadow='dark-lg'>
      <Box maxHeight="260px" overflow={'hidden'} borderRadius="xl">
        <Image
          src={resolveIPFS((metadata as { image?: string })?.image)}
          alt={'nft'}
          minH="260px"
          minW="260px"
          boxSize="100%"
          objectFit="fill"
        />
      </Box>
      <Box mt="1" fontWeight="semibold" as="h4" noOfLines={1} marginTop={2}>
        {name || 'noname'}
      </Box>
      <HStack>
        <Text fontSize={'xs'}>{contractType}</Text>
        {contractType === "ERC1155" && <Text fontSize={'xs'}>| amount: {amount}</Text>}
      </HStack>
      <SimpleGrid columns={2} spacing={4} bgColor={descBgColor} padding={2.5} borderRadius="xl" marginTop={2}>

        <Box>
          <HStack>
            <Text fontSize={'sm'}>{getEllipsisTxt(tokenAddress)}</Text>
            <Link isExternal href={`https://sepolia.etherscan.io/token/${tokenAddress}`}>
              <ExternalLinkIcon fontSize={'sm'}/>
            </Link>
          </HStack>
          <Text fontSize={'sm'}>Token ID: {tokenId}</Text>
        </Box>
        <Box>
          <Box as="h4" noOfLines={1} fontSize="sm">
            Allowance
          </Box>
          <Box>
            {(testatorAddress) && <ERC721ApproveButton isApprovedForAll={isApprovedForAll!} tokenAddress={tokenAddress} testatorAddress={testatorAddress} />}
          </Box>
        </Box>
      </SimpleGrid>
    </Box >
  )
}

export default NFTCard;

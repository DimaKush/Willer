import { Box, Center, Heading, Link, List, ListItem, Text, VStack } from '@chakra-ui/react'
import type { FC } from 'react'

const About: FC = () => {
  return (
    <Box>
      <Center>
        <Heading fontSize={['2xl', "3xl", "4xl"]} my={2}>
          Delayed token recovery tool
        </Heading>
      </Center>
      <VStack>
        <Text my={2} color={'chakra-body-text'} w={['70%', '65%', '57%']} align={'justify'} fontSize={['sm', "sm", "md"]}>

          Willer is a smart contract designed to facilitate the secure distribution of ERC20, ERC721, and ERC1155 tokens according to the terms of a digital will. Testators can define beneficiaries, specify their shares, set a release time, and extend the release period if necessary. Beneficiaries, in turn, can claim their allocated tokens once the release time expires.
        </Text>
        <Text my={2} color={'chakra-body-text'} w={['70%', '65%', '57%']} align={'justify'} fontSize={['sm', "sm", "md"]}>
        <br />
        - Private Key Protection: Extend the release period as proof of ongoing private key access.
        <br />
        - No protocol fee, no DAO or token
        <br />
        - 100 % Donations go to project contributors
        </Text>
      </VStack>
    </Box>
  )
}

export default About
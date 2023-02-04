import { Box, Center, Heading, Link, List, ListItem, Text, VStack } from '@chakra-ui/react'
import { useRouter } from 'next/router'
import type { FC } from 'react'
import { useAccount } from 'wagmi'

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
          Willer is used as a testamentary notary: entrust your ERC20, ERC721 or ERC1155 tokens to Willer smart contract,
          make the Will setting up beneficiaries addresses, shares and release time,
          then try not to lose your private key. The testator must extend release time to prove his/her access to private key.
          When the release time expires, beneficiaries are able to execute Will to perform the bequest of the tokens.          
        </Text>
        <Text my={2} color={'chakra-body-text'} w={['70%', '65%', '57%']} align={'justify'} fontSize={['sm', "sm", "md"]}>
            Example: Alice bequeaths her tokens to Bob, Tim and Jane. Alice set share of ERC20 & ERC1155 tokens for Bob equal
            to 7 (7/(7+9) = 43.75%), Tim's share is 9 (9/(7+9) = 56.25%). Jane does not have a share of fungible tokens,
            but Alice bequeath all ERC721 (NFT) tokens to Jane. Alice sets the delay of the execution of the Will equal to 365 days.
            This means that exactly one year later, all of her tokens added to Will are able to be transferred to the beneficiaries.
            To execute Will any of beneficiaries needs to claim the inheritance - go to willer-ui.vercel.app/'testator's address',
            connect wallet, click "Execute" button and sign a transaction. After 360 days, Alice will receive a notification to extend
            the will by clicking the Update button (will add notifications feature soon). Alice is alive and well, she has not
            lost her private key and access to her wallet, so she extends her will for another 365 days.
          </Text>
      </VStack>
      <Center my={2}>
        <Box>
          <Heading size={"l"} mt={'14px'}>
            TODO aka Roadmap
          </Heading>
          <List>
            <ListItem>
              Compartiable with Uniswap, Sushiswap, Curve, ENS, 1inch... need test all
            </ListItem>
            <ListItem>
            <Link isExternal href={`https://app.push.org`}>PUSH (EPNS)</Link> notifications
            </ListItem>
            <ListItem>
              ENS names/avatars
            </ListItem>   
            <ListItem>
              Docs
            </ListItem>           
            <ListItem>
              Custom release time
            </ListItem>
            <ListItem>
              Tests with different wallets, browsers
            </ListItem>
            <ListItem>
              Testator's message to beneficiaries
            </ListItem>
            <ListItem>
              Smart contract audit
            </ListItem>
            <ListItem>
              Contingent Bequests
            </ListItem>
            <ListItem>...</ListItem>
          </List>
        </Box>
      </Center>
    </Box>
  )
}

export default About
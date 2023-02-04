import { Box, Button, Container, Flex, HStack, Link } from '@chakra-ui/react';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { ColorModeButton } from 'components/buttons/ColorModeButton';
import { ExecuteForm } from 'components/forms/ExecuteForm';
import { WillerIcon } from 'components/icons';
import { useSession } from 'next-auth/react';
import { useRouter } from 'next/router';
import { useEffect, useState } from 'react';
import { useAccount } from 'wagmi';

const Header = () => {
  const router = useRouter()
  const account = useAccount()
  const session = useSession()
  const [mounted, setMounted] = useState<boolean | undefined>(false)
  useEffect(() => setMounted(account.isConnected && session.status === 'authenticated'), [account.address, router.asPath, session.status])
  return (
    <>
      <Box borderBottom="1px" borderBottomColor="chakra-border-color" boxShadow='dark-lg' bg={'chakra-body-bg'}>
        <Container maxW="container.xl" p={'10px'}>
          <Flex align="center" justify="space-between">
            <Link onClick={() => router.push("/")}><WillerIcon /></Link>
            <HStack gap={'10px'}>
              <ConnectButton />
              <ColorModeButton />
            </HStack>
          </Flex>
        </Container>
      </Box>
      {mounted && 
      <Flex align={'center'} justify="center" mt={5}>
      <Button size={["sm", "md", "md"]}
        onClick={() => router.push(`/${account.address}`)}>My will</Button>
      <ExecuteForm />
      </Flex>}
    </>
  );
};

export default Header;

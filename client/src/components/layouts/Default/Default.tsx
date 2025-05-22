import { Box, Container, useColorModeValue } from '@chakra-ui/react';
import { Footer, Header } from 'components/modules';
import Head from 'next/head';
import type { FC, ReactNode } from 'react';

const Default: FC<{ children: ReactNode; pageName: string }> = ({ children, pageName }) => {
  const bgColor = useColorModeValue("https://i.ibb.co/wB9Dd4j/whiteDot.png",
  'https://i.ibb.co/tCLbZkM/blackDot.png')
  return (   
  <Box  w='100%' minH='100vh' bgImage={bgColor}
  bgSize='cover' bgAttachment='fixed' bgPos='50% 0%' pos='relative' bgRepeat='no-repeat'> 
      <Head>
        <title>{`${pageName} | Willer`}</title>
        <meta name="viewport" content="initial-scale=1.0, width=device-width" />
      </Head>

      <Header />
      <Container maxW="container.lg" p={3} marginTop={50} as="main" minH="60vh">
        {children}
      </Container>
      <Footer />
    </Box>
  )
}
export default Default;
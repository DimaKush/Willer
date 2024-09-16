import { ChakraProvider } from '@chakra-ui/react';
import { createClient, configureChains, WagmiConfig} from 'wagmi';
import { extendTheme } from '@chakra-ui/react';

import { jsonRpcProvider } from 'wagmi/providers/jsonRpc';
import { mainnet, sepolia } from '@wagmi/core/chains'
import type { AppProps } from 'next/app';
import { Session } from 'next-auth';
import '@rainbow-me/rainbowkit/styles.css';
import {
  RainbowKitProvider,
  getDefaultWallets,
  connectorsForWallets,
} from '@rainbow-me/rainbowkit';
import {
  argentWallet,
  trustWallet,
  ledgerWallet,
  metaMaskWallet,
} from '@rainbow-me/rainbowkit/wallets';
import { SessionProvider } from 'next-auth/react';
import {
  RainbowKitSiweNextAuthProvider,
} from '@rainbow-me/rainbowkit-siwe-next-auth';
import { useRouter } from 'next/router';
import { useEffect } from 'react';
import NProgress from 'nprogress'
import 'nprogress/nprogress.css'
import Moralis from 'moralis';

const { chains, provider, webSocketProvider} = configureChains([sepolia], [jsonRpcProvider({
  rpc: (chain) => ({
    http: 'https://sepolia.infura.io/v3/7f2edfe64499473c99a158ee0f43a4c0',
  }),
})]);
console.log(chains)

Moralis.start({ apiKey: process.env.MORALIS_API_KEY })

const { wallets } = getDefaultWallets({
  appName: 'Willer',
  chains,
})
const demoAppInfo = {
  appName: 'Willer',
}
const connectors = connectorsForWallets([
  ...wallets,
  {
    groupName: 'Other',
    wallets: [
      argentWallet({ chains }),
      metaMaskWallet({ chains }),
      trustWallet({ chains }),
      ledgerWallet({ chains }),
    ],
  },
]);
const config = {
  initialColorMode: 'dark',
  useSystemColorMode: false  
};
const client = createClient({ connectors, provider, webSocketProvider, autoConnect: true })
const theme = extendTheme({ config });

const MyApp = ({ Component, pageProps: { session, ...pageProps } }: AppProps<{ session: Session }>) => {
  const router = useRouter()
  useEffect(() => {
    const handleStart = (url: string) => {
      console.log(`Loading: ${url}`)
      NProgress.start()
    }

    const handleStop = () => {
      NProgress.done()
    }

    router.events.on('routeChangeStart', handleStart)
    router.events.on('routeChangeComplete', handleStop)
    router.events.on('routeChangeError', handleStop)

    return () => {
      router.events.off('routeChangeStart', handleStart)
      router.events.off('routeChangeComplete', handleStop)
      router.events.off('routeChangeError', handleStop)
    }
  }, [router])

  return (
    <ChakraProvider resetCSS theme={theme}>
      <SessionProvider session={session} refetchInterval={0}>
        <WagmiConfig client={client}>
          <RainbowKitSiweNextAuthProvider>
            <RainbowKitProvider appInfo={demoAppInfo} chains={chains} showRecentTransactions modalSize='compact'>
              <Component {...pageProps} />
            </RainbowKitProvider>
          </RainbowKitSiweNextAuthProvider>
        </WagmiConfig>
      </SessionProvider>
    </ChakraProvider>
  );
};

export default MyApp;

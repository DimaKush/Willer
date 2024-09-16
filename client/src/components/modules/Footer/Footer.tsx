import { Flex, HStack, Link, useTheme, VStack } from '@chakra-ui/react';
import { EtherscanIcon, GitcoinIcon } from 'components/icons';
import { DiscordIcon } from 'components/icons/DiscordIcon';
import { GithubIcon } from 'components/icons/GithubIcon';
import TwitterIcon from 'components/icons/TwitterIcon/TwitterIcon';
import { willerContract } from 'components/Interfaces';

const links = {
  github: 'https://github.com/DimaKush/Willer',
  polygonscan: `https://goerli.etherscan.io/address/${willerContract.address}`,
  etherscan: `https://sepolia.etherscan.io/address/${willerContract.address}`,
  ethFaucet: 'https://goerlifaucet.com/',
  gitcoin: `https://gitcoin.co/grants/7363/willer-delayed-token-recovery-tool`,
  twitter: "https://twitter.com/Willer_eth",
  discord: "https://discord.gg/5XZtRhqdzF",
};

const Footer = () => {
  useTheme()
  return (
    <Flex align="center" justify="space-between" w="full" p={6} >
      <VStack w="full">
        <HStack spacing={2}>
          <Link isExternal href={links.etherscan}><EtherscanIcon /></Link>
          <Link isExternal href={links.gitcoin}><GitcoinIcon /></Link>
          <Link isExternal href={links.github}><GithubIcon /></Link>
          <Link isExternal href={links.twitter}><TwitterIcon /></Link>
          <Link isExternal href={links.discord}><DiscordIcon /></Link>
        </HStack>
      </VStack>
    </Flex>
  );
};

export default Footer;

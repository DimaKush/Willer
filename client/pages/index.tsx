import { Default } from "components/layouts/Default";
import type { NextPage } from "next";
import React from 'react'
import { Text } from "@chakra-ui/react";
import { About } from "components/modules/About";
import { useSession } from "next-auth/react";

interface Balances {
    tokenBalances?: Erc20Value[];
    nftBalances?: TNFTBalance[];
    testatorAddress: string;
    error?: string;
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
  };

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

const HomePage: NextPage<Balances> = (props: any) => {
    if (props.error) {return (
        <Default pageName="Home">
        <Text>{props.error}</Text></Default>
    )}

    return (
        <Default pageName="Home">
            <About/>
        </Default>
    )
}

export default HomePage

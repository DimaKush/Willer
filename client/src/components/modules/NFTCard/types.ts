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
  testatorAddress?: string| undefined;
}

interface IMetadata {
  name: string;
  description: string;
  image: string;
}

export interface INFTCard
  extends Pick<TNFTBalance, 'amount' | 'contractType' | 'name' | 'symbol' | 'tokenAddress' | 'tokenId' | 'metadata' | 'isApprovedForAll' | 'tokenUri' | 'ownerOf' | 'testatorAddress'> {}

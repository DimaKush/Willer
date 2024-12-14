import { useContractRead } from 'wagmi'
import type { BigNumber } from 'ethers';
import { willerContract } from 'components/Interfaces';

interface IWill {
    beneficiaries: string[];
    shares: BigNumber[];
    releaseTime: BigNumber;
    beneficiaryOfERC721: string;
    sumShares: BigNumber;
  }

export const useWiller = (testatorAddress: string) : IWill => {
    const beneficiaries = useContractRead({
        address: willerContract.address,
        abi: willerContract.abi,
        functionName: "getBeneficiaries",
        args: [testatorAddress],
    }).data as string[]

    const shares = useContractRead({
        address: willerContract.address,
        abi: willerContract.abi,
        functionName: "getShares",
        args: [testatorAddress],
    }).data as BigNumber[]

    const releaseTime = useContractRead({
        address: willerContract.address,
        abi: willerContract.abi,
        functionName: "getReleaseTime",
        args: [testatorAddress],
    }).data as BigNumber

    const beneficiaryOfERC721 = useContractRead({
        address: willerContract.address,
        abi: willerContract.abi,
        functionName: "getBeneficiaryOfERC721",
        args: [testatorAddress],
    }).data as string

    const sumShares = useContractRead({
        address: willerContract.address,
        abi: willerContract.abi,
        functionName: "getSumShares",
        args: [testatorAddress],
    }).data as BigNumber
    
    return { beneficiaries, shares, releaseTime, beneficiaryOfERC721, sumShares }
}

export default useWiller

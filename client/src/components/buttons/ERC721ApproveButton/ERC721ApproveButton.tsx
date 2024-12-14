import { AddIcon, CheckCircleIcon, NotAllowedIcon } from '@chakra-ui/icons'
import { Icon, IconButton, Spinner } from '@chakra-ui/react'
import { IERC721, willerContract } from 'components/Interfaces'
import { useAccount, useContractRead, useContractWrite, usePrepareContractWrite, useWaitForTransaction } from 'wagmi'
import { INFTCard } from 'components/modules/NFTCard/types';


const ERC721ApproveButton = ({ tokenAddress, testatorAddress, isApprovedForAll }: INFTCard) => {
  const account = useAccount()
  const { config } = usePrepareContractWrite({
    address: tokenAddress,
    abi: IERC721,
    functionName: 'setApprovalForAll',
    overrides: {
      gasLimit: 70_000,
    },
    args: [willerContract.address, true],
    onError(err) {
      console.log(err)
    },
  })

  const { data, isLoading, write } = useContractWrite(config)
  const txData = useWaitForTransaction({ hash: data?.hash })

  if (isLoading) { return <Spinner /> }
  if (txData.isSuccess || isApprovedForAll) { return <Icon as={CheckCircleIcon} color="green.500" /> }
  if (account.address !== testatorAddress) { return <Icon as={NotAllowedIcon} color="yellow.500" />}
  return <IconButton background={'red.600'} aria-label='approval' size={'sm'} icon={<AddIcon />}
    onClick={() => {
      write?.()
    }}>
  </IconButton>

}

export default ERC721ApproveButton
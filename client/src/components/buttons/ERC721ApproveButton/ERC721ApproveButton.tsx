import { AddIcon, CheckCircleIcon, NotAllowedIcon } from '@chakra-ui/icons'
import { Icon, IconButton, Spinner } from '@chakra-ui/react'
import { IERC721, willerContract } from 'components/Interfaces'
import { useEffect, useState } from 'react'
import { useAccount, useContractRead, useContractWrite, usePrepareContractWrite, useWaitForTransaction } from 'wagmi'

interface Props {
  contractAddress: string,
  testatorAddress: string,
}

const ERC721ApproveButton = ({ contractAddress, testatorAddress }: Props) => {
  const account = useAccount()
  const [address, setAddress] = useState<string | undefined>(undefined)
  useEffect(() => setAddress(testatorAddress), [testatorAddress])
  const ERC721allowance = useContractRead({
    address: contractAddress,
    abi: IERC721,
    functionName: "isApprovedForAll",
    args: [address, willerContract.address],
    watch: true
  })
  const { config } = usePrepareContractWrite({
    address: contractAddress,
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
  const { isSuccess } = useWaitForTransaction({ hash: data?.hash })

  if (isLoading) { return <Spinner /> }
  if (ERC721allowance.data) { return <Icon as={CheckCircleIcon} color="green.500" /> }
  if (account.address !== testatorAddress) { return <Icon as={NotAllowedIcon} color="yellow.500" />}
  return <IconButton background={'red.600'} aria-label='approval' size={'sm'} icon={<AddIcon />}
    onClick={() => {
      write?.()
    }}>
  </IconButton>

}

export default ERC721ApproveButton
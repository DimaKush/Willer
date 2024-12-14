import { AddIcon, CheckCircleIcon, NotAllowedIcon } from '@chakra-ui/icons'
import { Icon, IconButton, Spinner, Tooltip } from '@chakra-ui/react'
import { approveAmount, IERC20, willerContract } from 'components/Interfaces'
import { ethers } from "ethers"
import { useEffect, useState } from 'react'
import { useAccount, useContractWrite, usePrepareContractWrite, useWaitForTransaction } from 'wagmi'

interface Props {
  contractAddress: string,
  testatorAddress: string,
  isApprovedForAll: boolean
}

const ERC20ApproveButton = ({ contractAddress, testatorAddress, isApprovedForAll }: Props) => {
  const account = useAccount()
  const [addressT, setAddressT] = useState<string | undefined>(undefined)
  useEffect(() => setAddressT(testatorAddress), [testatorAddress])
  const [notAllowedIcon, setNotAllowedIcon] = useState<boolean | undefined>(undefined)
  useEffect(() => setNotAllowedIcon(account.address !== addressT), [account.address, addressT])
  const { config } = usePrepareContractWrite({
    address: contractAddress,
    abi: IERC20,
    functionName: 'approve',
    overrides: {
      gasLimit: 50_000,
    },
    args: [willerContract.address, ethers.utils.parseEther(approveAmount.toString())],
    onError(err) {
      console.log(err)
    },
  })

  

  const { data, isLoading, write } = useContractWrite(config)
  const txData = useWaitForTransaction({
    hash: data?.hash
  })

  const [isAllowed, setIsAllowed] = useState<boolean | undefined>(undefined)
  useEffect(() => setIsAllowed(isApprovedForAll || txData.isSuccess), [isApprovedForAll, txData])
  if (isLoading) { return <Spinner size={['sm', 'md', 'md']} /> }
  if (isAllowed) {
    return <Tooltip label={`allowance ${contractAddress.toString()}`} placement='bottom' openDelay={500}
    ><Icon as={CheckCircleIcon} color="green.500" /></Tooltip>
  }
  if (notAllowedIcon) {
    return <Tooltip label={`allowance ${contractAddress.toString()}`} placement='bottom' openDelay={500}
    ><Icon as={NotAllowedIcon} color="yellow.500" /></Tooltip>
  }
  return <Tooltip label={`allowance ${contractAddress.toString()}`} placement='bottom' openDelay={500}>
    <IconButton background={'red.600'} aria-label='approval' size={['sm', 'md', 'md']} icon={<AddIcon />}
      onClick={() => {
        write?.()
      }}>
    </IconButton>
  </Tooltip>
}

export default ERC20ApproveButton
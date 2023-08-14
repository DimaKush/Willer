import { AddIcon, CheckCircleIcon, NotAllowedIcon } from '@chakra-ui/icons'
import { Icon, IconButton, Spinner, Tooltip } from '@chakra-ui/react'
import { approveAmount, IERC20, willerContract } from 'components/Interfaces'
import { BigNumber, ethers } from "ethers"
import { useEffect, useState } from 'react'
import { useAccount, useContractRead, useContractWrite, usePrepareContractWrite } from 'wagmi'

interface Props {
  contractAddress: string,
  testatorAddress: string,
}

const ERC20ApproveButton = ({ contractAddress, testatorAddress }: Props) => {
  const account = useAccount()
  const [address, setAddress] = useState<string | undefined>(undefined)
  useEffect(() => setAddress(testatorAddress), [testatorAddress])
  const balance = useContractRead({
    address: contractAddress,
    abi: IERC20,
    functionName: "balanceOf",
    args: [address],
    watch: true
  }).data as BigNumber
  const ERC20allowance = useContractRead({
    address: contractAddress,
    abi: IERC20,
    functionName: "allowance",
    args: [address, willerContract.address],
    watch: true
  }).data as BigNumber
  const [isAllowed, setIsAllowed] = useState<boolean | undefined>(undefined)
  useEffect(() => setIsAllowed((ERC20allowance !== undefined) && (balance !== undefined) && ERC20allowance.gt(balance)), [ERC20allowance, balance])
  const [notAllowedIcon, setNotAllowedIcon] = useState<boolean | undefined>(undefined)
  useEffect(() => setNotAllowedIcon(account.address !== address), [account.address, address])
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
  if (isLoading) { return <Spinner size={['sm', 'md', 'md']} /> }
  if (isAllowed) {
    return <Tooltip label={`allowance ${ERC20allowance && ERC20allowance.toString()}`} placement='bottom' openDelay={500}
    ><Icon as={CheckCircleIcon} color="green.500" /></Tooltip>
  }
  if (notAllowedIcon) {
    return <Tooltip label={`allowance ${ERC20allowance && ERC20allowance.toString()}`} placement='bottom' openDelay={500}
    ><Icon as={NotAllowedIcon} color="yellow.500" /></Tooltip>
  }
  return <Tooltip label={`allowance ${ERC20allowance && ERC20allowance.toString()}`} placement='bottom' openDelay={500}>
    <IconButton background={'red.600'} aria-label='approval' size={['sm', 'md', 'md']} icon={<AddIcon />}
      onClick={() => {
        write?.()
      }}>
    </IconButton>
  </Tooltip>
}

export default ERC20ApproveButton
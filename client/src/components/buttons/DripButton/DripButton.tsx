import { Button, Spinner, Text } from '@chakra-ui/react'
import { multiFaucet } from 'components/Interfaces'
import { useContractWrite, usePrepareContractWrite } from 'wagmi'

export const DripButton = () => {
  const { config } = usePrepareContractWrite({
    address: multiFaucet.address,
    abi: multiFaucet.abi,
    functionName: 'drip',
    onError(err) {
      console.log("Error:", err)
    },
  })
  const { isLoading, write } = useContractWrite(config)
  // TODO refresh
  return (
    <Button
      disabled={!write}
      onClick={() => write?.()}>
      {isLoading ? <Spinner/> : <Text>Drip test tokens</Text>}      
    </Button>
  )
}

export default DripButton
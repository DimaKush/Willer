import { Button, Spinner, Text } from '@chakra-ui/react'
import { IWETH, WETHAddress } from 'components/Interfaces'
import type { BigNumber } from 'ethers'
import { useContractWrite, usePrepareContractWrite } from 'wagmi'

interface Props {
    amount: BigNumber
}

const WrapButton = ({amount}: Props) => {
    const { config } = usePrepareContractWrite({
        address: WETHAddress,
        abi: IWETH,
        functionName: 'deposit',
        onError(err) {
            console.log(err)
        },
        overrides: {
            value: amount,
          },
    })

    const { isLoading, write } = useContractWrite(config)
    return (
        <Button
            disabled={!write}
            onClick={() => write?.()}>
            {isLoading ? <Spinner/> : <Text>WrapEth</Text>}
        </Button>    
    )
}

export default WrapButton
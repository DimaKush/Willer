import { AccordionButton, Button, Radio, RadioGroup, VStack } from '@chakra-ui/react'
import { useState } from 'react'
import { useAccount, useContractWrite, usePrepareContractWrite } from 'wagmi'
import { willerContract } from '../../Interfaces/Interfaces'


const SetNewReleaseTimeButton = () => {
    const [delay, setDelay] = useState<string>("300")
    const account = useAccount()

    const releaseTime = Math.floor(Date.now() / 1000) + Number(delay)

    const { config } = usePrepareContractWrite({
        address: willerContract.address,
        abi: willerContract.abi,
        functionName: 'setNewReleaseTime',
        args: [releaseTime],
        onError(err) {
            console.log(err)
          },
        overrides: {
            from: account.address
        }
    })

    const { data, write , status} = useContractWrite(config)
    return (
        <VStack alignItems={'center'}>
            <Button disabled={!write} onClick={() => write?.()}>
                Update
            </Button>
            <RadioGroup onChange={setDelay} defaultValue={"300"} value={delay}>
                <VStack>
                <Radio value={"300"}>5 Minutes</Radio> 
                <Radio value={"86400"}>1 day</Radio>               
                <Radio value={"2592000"}>30 days</Radio>
                <Radio value={"31536000"}>365 days</Radio>
                <Radio value={"86400000"}>1000 days</Radio>
                </VStack>
            </RadioGroup>
        </VStack>)
}

export default SetNewReleaseTimeButton
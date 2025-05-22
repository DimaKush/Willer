import { SearchIcon } from "@chakra-ui/icons";
import { Button, Flex, Input } from "@chakra-ui/react";
import { ethers } from 'ethers'

import { useRouter } from "next/router";
import { useState } from "react";

const ExecuteForm = () => {
    const [testatorAddress, setTestatorAddress] = useState('')
    const router = useRouter()
    const handleClick = () => {
        if (ethers.utils.isAddress(testatorAddress)) {
            router.push(`/${testatorAddress}`)
            setTestatorAddress("")
        }
    }
    return (
        <Flex alignItems={'flex-start'}>
            <Input
            
                size={["sm", "md", "md"]}
                placeholder="Testator's address"
                onChange={(e) => { setTestatorAddress(e.target.value) }}
                isInvalid={!ethers.utils.isAddress(testatorAddress) && testatorAddress !== ''}
                errorBorderColor='red.500'
                value={testatorAddress}
                w={['150px', '320px', '420px']}
            />
            <Button size={["sm", "md", "md"]}
                marginLeft={'10px'}
                onClick={handleClick} ><SearchIcon /></Button>
        </Flex>
    )
}

export default ExecuteForm
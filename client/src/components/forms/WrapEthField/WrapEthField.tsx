import { HStack, NumberDecrementStepper, NumberIncrementStepper, NumberInput, NumberInputField, NumberInputStepper } from '@chakra-ui/react'
import { ethers } from 'ethers'
import { useState } from 'react'
import WrapButton from '../../buttons/WrapButton/WrapButton'

const WrapEthField = () => {
  const [amount, setAmount] = useState('0.01')
  return (<HStack>
    <NumberInput step={0.01} precision={2} onChange={setAmount} value={amount} w={100}>
      <NumberInputField />
      <NumberInputStepper>
        <NumberIncrementStepper />
        <NumberDecrementStepper />
      </NumberInputStepper>
    </NumberInput>
    <WrapButton amount={ethers.utils.parseEther(amount)} />
  </HStack>
  )
}

export default WrapEthField
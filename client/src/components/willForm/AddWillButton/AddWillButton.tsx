import { Button } from '@chakra-ui/react'
import { willerContract } from 'components/Interfaces'
import React from 'react'
import { useContractWrite, usePrepareContractWrite } from 'wagmi'

export interface IBeneficiary {
    address: string
    share: number
}

interface Props {
    beneficiaryList: Array<IBeneficiary>,
    beneficiary721: string,
    delay: string,
    closeWillForm(): void,
}

const AddWillButton = ({ beneficiaryList, beneficiary721, delay, closeWillForm }: Props) => {
    const benArray = beneficiaryList.map((beneficiary: IBeneficiary) => {
        return (beneficiary.address)
    })
    const sharesArray = beneficiaryList.map((beneficiary: IBeneficiary) => {
        return (beneficiary.share)
    })
    const releaseTime = Math.floor(Date.now() / 1000) + parseInt(delay)
    const { config } = usePrepareContractWrite({
        address: willerContract.address,
        abi: willerContract.abi,
        functionName: 'addWill',
        args: [benArray, sharesArray, beneficiary721, releaseTime]
    })

    const { isSuccess, write } = useContractWrite(config)
    if (isSuccess) { closeWillForm() }
    return (
        <Button disabled={!write || benArray.length === 0} onClick={() => write?.()}>
            Create
        </Button>
    )
}


export default AddWillButton
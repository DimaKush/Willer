import { ChangeEvent, useState } from 'react'
import { useAccount } from 'wagmi'
import { Box, Button, HStack, IconButton, Input, Modal, ModalBody, ModalCloseButton, ModalContent, ModalFooter, ModalHeader, ModalOverlay, Radio, RadioGroup, Select, Table, TableContainer, Tbody, Text, Th, Thead, Tooltip, Tr, useColorModeValue, VStack } from '@chakra-ui/react'
import { AddIcon, DeleteIcon } from '@chakra-ui/icons'
import { AddWillButton } from '../AddWillButton'
import { ethers } from "ethers"
import { getEllipsisTxt } from 'utils/format'

interface IBeneficiary {
    address: string
    share: number
}

interface Props {
    isOpen: boolean,
    onOpen(): void,
    onClose(): void,
}

const WillForm = ({ isOpen, onClose }: Props) => {
    const hoverTrColor = useColorModeValue('gray.700', 'gray.100');
    const [beneficiaryAddress, setBeneficiaryAddress] = useState<string>("")
    const [beneficiaryShare, setBeneficiaryShare] = useState<number>(1)
    const [beneficiaryList, setBeneficiaryList] = useState<IBeneficiary[]>([])
    const [beneficiaryOfERC721InputField, setBeneficiaryOfERC721InputField] = useState<string>('')
    const [beneficiary721, setBeneficiary721] = useState("")
    const [delay, setDelay] = useState<string>("300")
    const account = useAccount()


    const handleChangeOfBeneficiaryInputField = (event: ChangeEvent<HTMLInputElement>) => {
        setBeneficiaryAddress(event.target.value)
    }

    const addBeneficiary = (address: string, share: number) => {
        if (ethers.utils.isAddress(address) && address !== account.address) {
            const newBenefisiaryListItem = { address, share }
            setBeneficiaryList([...beneficiaryList, newBenefisiaryListItem])
            setBeneficiaryAddress('')
        }
    }

    const deleteBeneficiaryListItem = (beneficiaryAddressToDelete: string) => {
        setBeneficiaryList(beneficiaryList.filter((beneficiary) => {
            return beneficiary.address !== beneficiaryAddressToDelete
        }))
    }

    return (
        <Box>
            <Modal isOpen={isOpen} onClose={onClose} size="xl">
                <ModalOverlay />
                <ModalContent>
                    <ModalHeader>
                        New Will
                    </ModalHeader>
                    <ModalCloseButton />
                    <ModalBody>
                        <Box border="2px" borderColor={hoverTrColor} borderRadius="xl" padding="24px 18px">
                            {(beneficiaryList.length !== 0) && (
                                <TableContainer>
                                    <Table>
                                        <Thead>
                                            <Tr>
                                                <Th>Beneficiaries</Th>
                                                <Th>Shares</Th>
                                            </Tr>
                                        </Thead>
                                        <Tbody>
                                            {beneficiaryList.map((beneficiary: IBeneficiary, key: number) => {
                                                return (
                                                    <Tr>
                                                        <Th>
                                                            <Text>{getEllipsisTxt(beneficiary.address)}</Text>
                                                        </Th>
                                                        <Th>
                                                            <Text>{beneficiary.share}</Text>
                                                        </Th>
                                                        <Th>
                                                            <Button onClick={() => { deleteBeneficiaryListItem(beneficiary.address) }}><DeleteIcon />
                                                            </Button>
                                                        </Th>
                                                    </Tr >)
                                            })}
                                        </Tbody>
                                    </Table>
                                </TableContainer>)}
                            {(ethers.utils.isAddress(beneficiary721)) && <Text>{beneficiary721} - beneficiary of all ERC721 tokens</Text>}
                            <Text pt={"24px"}>
                                Choose delay
                            </Text>
                            <RadioGroup onChange={setDelay} name='delayRadioGroup' value={delay}>
                                <Radio value={"300"}>5 Minutes</Radio>
                                <Radio value={"86400"}>1 day</Radio>
                                <Radio value={"2592000"}>30 days</Radio>
                                <Radio value={"31536000"}>365 days</Radio>
                                <Radio value={"86400000"}>1000 days</Radio>
                            </RadioGroup>
                        </Box>
                        <VStack paddingTop={8}>
                            <HStack width={'full'}>
                                <Input
                                    placeholder='Beneficiary of ERC20 & ERC1155'
                                    onChange={handleChangeOfBeneficiaryInputField}
                                    value={beneficiaryAddress}/>
                                <Select
                                    onChange={(e) => setBeneficiaryShare(parseInt(e.target.value))}
                                    value={beneficiaryShare}
                                    width={'100px'}>
                                    {Array.from({ length: 10 }, (_, i) => i + 1).map((value, key) => {
                                        return (
                                            <option key={key} value={value}>{value}</option>
                                        )
                                    })}

                                </Select>
                                <Tooltip label='Non-testator valid Ethereum address only'>
                                    <IconButton
                                        aria-label='add beneficiary'

                                        disabled={!ethers.utils.isAddress(beneficiaryAddress) || beneficiaryAddress === account.address}
                                        onClick={() => { addBeneficiary(beneficiaryAddress, beneficiaryShare) }}>
                                        <AddIcon />
                                    </IconButton>
                                </Tooltip>
                            </HStack>
                            <HStack width={'full'}>
                                <Input
                                    placeholder='Beneficiary of ERC721'
                                    onChange={(e) => setBeneficiaryOfERC721InputField(e.target.value)}
                                    value={beneficiaryOfERC721InputField} />
                                <Tooltip label='Non-testator valid Ethereum address only'>
                                    <IconButton
                                        aria-label='add beneficiary of ERC721'
                                        disabled={!ethers.utils.isAddress(beneficiaryOfERC721InputField) || beneficiaryOfERC721InputField === account.address}
                                        onClick={() => {
                                            setBeneficiary721(beneficiaryOfERC721InputField)
                                            setBeneficiaryOfERC721InputField('')
                                        }}>
                                        <AddIcon />
                                    </IconButton>
                                </Tooltip>
                            </HStack>
                        </VStack>
                    </ModalBody>
                    <ModalFooter>
                        <AddWillButton
                            beneficiaryList={beneficiaryList}
                            beneficiary721={beneficiary721}
                            delay={delay}
                            closeWillForm={onClose} />
                    </ModalFooter>
                </ModalContent>
            </Modal>
        </Box >

    )
}

export default WillForm
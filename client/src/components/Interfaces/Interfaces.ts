export const IDsLenght = 3
export const approveAmount = 10e18

// Import deployment addresses from broadcast
export const WETHAddress = "0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9"

// Import contract ABIs
export const willerContract = {
  address: "0xF3C1101BD52297f707E9E0742dADeeBF92dA5eB2",
  abi: require('../../abi/Willer.json')
}

export const multiFaucet = {
  address: "0x74a5D56c33e78a6472220bF88AD3FC7EC5dEDCB4",
  abi: require('../../abi/MultiFaucet.json')
}


export const IWETH = require('../../abi/WETH.json')
export const IERC20 = require('../../abi/ERC20.json')
export const IERC721 = require('../../abi/ERC721.json')
export const IERC1155 = require('../../abi/ERC1155.json')
export const IMultiFaucet = require('../../abi/MultiFaucet.json')
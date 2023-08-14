# Willer. Delayed token recovery tool

Willer is a smart contract designed to facilitate the secure distribution of ERC20, ERC721, and ERC1155 tokens according to the terms of a digital will. Testators can define beneficiaries, specify their shares, set a release time, and extend the release period if necessary. Beneficiaries, in turn, can claim their allocated tokens once the release time expires.

[Live on Goerli Testnet](https://willer-ui.vercel.app)

## Example

Example: Alice bequeaths her tokens to Bob, Tim and Jane. Alice set share of ERC20 & ERC1155 tokens for Bob equal to 7 (7/(7+9) = 43.75%), Tim's share is 9 (9/(7+9) = 56.25%). Jane does not have a share of fungible tokens, but Alice bequeath all ERC721 (NFT) tokens to Jane. Alice sets the delay of the execution of the Will equal to 365 days. This means that exactly one year later, all of her tokens added to Will are able to be transferred to the beneficiaries. To execute Will any of beneficiaries needs to claim the inheritance - go to willer-ui.vercel.app/'testator's address', connect wallet, click "Execute" button and sign a transaction. After 360 days, Alice will receive a notification to extend the will by clicking the Update button (will add notifications feature soon). Alice is alive and well, she has not lost her private key and access to her wallet, so she extends her will for another 365 days.

## Installation

1. [Install Brownie](https://eth-brownie.readthedocs.io/en/stable/install.html).

2. Clone this repo 
   ```
   git clone https://github.com/DimaKush/Willer
   cd Willer
   ```
3. If you want to deploy on testnets, do the following.

   Set our environment variables to a .env file. You can use the .env_example in this repo
   as a template, just fill in the values and rename it to '.env'.

## Usage

1. Open the Brownie console. Starting the console launches a fresh [Ganache](https://www.trufflesuite.com/ganache) instance in the background.

   ```bash
   brownie console
   ```

   Alternatively, to run on Goeri, set the network flag to goerli

   ```
   brownie console --network goerli
   ```

2. Run the [deployment script](scripts/deploy_willer.py) to deploy the project's smart contracts using Brownie console:

   ```python
   run("deploy_willer")
   ```
   Or in terminal:

   ```bash
   brownie run deploy_willer --network goerli
   ```

   Replace `goerli` with the name of the network you wish you use. You may also wish to adjust Brownie's [network settings](https://eth-brownie.readthedocs.io/en/stable/network-management.html).

3. Interact with the smart contract using Brownie console:

   ```python
   # setup script
   run('setup_will')
   # add will
   Willer[-1].addWill([accounts[1], accounts[2]], [80, 20], accounts[3], 1691455347, {'from': accounts[0]})
   # set new release time
   Willer[-1].setNewReleaseTime(1791455347, {'from': accounts[0]})   
   ```
   
### Configuring

Configure settings at 'brownie-config.yaml'

### Testing

To run the test suite:

```bash
brownie test
```
## License

Distributed under the [MIT License](https://github.com/DimaKush/Willer/blob/master/LICENSE)

## Resources
[Faucet] (https://faucet.paradigm.xyz/)

[Brownie documentation](https://eth-brownie.readthedocs.io/en/stable/)

["Getting Started with Brownie"](https://medium.com/@iamdefinitelyahuman/getting-started-with-brownie-part-1-9b2181f4cb99)

[Patrick Collins](https://twitter.com/PatrickAlphaC) tutorial on [youtube](https://www.youtube.com/watch?v=M576WGiDBdQ&t=43350s)

[Brownie Mixes](https://github.com/brownie-mix)

[OpenZeppelin docs](https://docs.openzeppelin.com/)

[RainbowKit](https://www.rainbowkit.com/)

[Ethereum boilerplate](https://github.com/ethereum-boilerplate/ethereum-boilerplate) 

[Chakra-ui](https://chakra-ui.com)

[Wagmi](https://wagmi.sh/)
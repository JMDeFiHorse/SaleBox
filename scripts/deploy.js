
async function main() {
    // We get the contract to deploy
    const contract = await ethers.getContractFactory('EventBuyBox');
    console.log('Deploying EventBuyBox...');
    /**
     * These variables below for testnet
     * @type {string}
     */

    const dfhToken = '0x945d9AF572a89627B29aafa0E3B66e4f867E32a7' // HTK token
    const erc721 = '0x9E157B549f38d5cB1dCA0d1be771fE316756eAbA' // Heroic token
    const start = Math.round(new Date().getTime()/1e3)
    /**
     * These variables below for mainnet
     */
    // const dfhToken = '0x945d9AF572a89627B29aafa0E3B66e4f867E32a7' // HTK token
    // const erc721 = '0x9E157B549f38d5cB1dCA0d1be771fE316756eAbA' // Heroic token
    // const start = Math.round(new Date().getTime()/1e3)

    const token = await contract.deploy(dfhToken, erc721, start);
    await token.deployed();

    console.log('StakingToken deployed to:', token.address);
    console.log(`Please enter this command below to verify your contract:`)
    console.log(`npx hardhat verify --network ${token.deployTransaction.chainId === 56 ? 'mainnet' : 'testnet'} ${token.address} ${dfhToken}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

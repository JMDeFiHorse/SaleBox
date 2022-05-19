
async function main() {
    // We get the contract to deploy
    const contract = await ethers.getContractFactory('EventBuyBox');
    console.log('Deploying...');
    const dfhToken = '0x5fdAb5BDbad5277B383B3482D085f4bFef68828C' // DFH
    const erc721 = '0x93b4a9c141aF9D3137DD9Fb4B5FD10df8e9D2B78' // Box test
    const start = Math.floor(new Date('2022-05-18T13:00:00.000Z').getTime() / 1e3)
    const duration = 31536000 // 365 days

    const token = await contract.deploy(
      dfhToken,
      erc721,
      start,
      duration
    );
    await token.deployed();
    console.log('StakingToken deployed to:', token.address);
    console.log(`Please enter this command below to verify your contract:`)
    console.log(`npx hardhat verify --network ${token.deployTransaction.chainId === 56 ? 'mainnet' : 'testnet'} ${token.address} ${dfhToken} ${erc721} ${start} ${duration}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

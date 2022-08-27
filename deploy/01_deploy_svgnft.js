const fs = require('fs')
let { networkConfig } = require('../helper-hardhat-config')

module.exports = async ({
    getNamedAccounts, 
    deployments,
    getChainId
}) => {
    const {deploy, log} = deployments
    const {deployer} = await getNamedAccounts()
    const chainId = await getChainId()

    //deployment
    log('Starting deployment.....')
    const SVGNFT = await deploy("SVGNFT", {
        from: deployer,
        log: true
    })
    log(`SVGNFT contract deployed to address: ${SVGNFT.address}`)

    
    const svgNFTContract = await ethers.getContractFactory("SVGNFT")
    const accounts = await hre.ethers.getSigners()
    const signer = accounts[0]
    const svgNFT = new ethers.Contract(SVGNFT.address, svgNFTContract.interface, signer)
    const networkName = networkConfig[chainId]['name']
    log(`Verify on etherscan with: \n npx hardhat verify --network ${networkName} ${svgNFT.address}`)
    
    let filepath = './img/triangle.svg'
    let svg = fs.readFileSync(filepath, {encoding: 'utf8'})
    let transactionResponse = await svgNFT.create(svg)
    let receipt = await transactionResponse.wait(1)
    log(`NFT minitng successful. Token URI: ${await svgNFT.tokenURI(0)}`)
}
module.exports.tags = ['all', 'svg']
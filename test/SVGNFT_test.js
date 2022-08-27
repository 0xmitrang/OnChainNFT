const { expect } = require('chai')
const chai = require('chai')
const BN = require('bn.js')
chai.use(require('chai-bn')(BN))
const skipIf = require('mocha-skip-if')
const fs = require('fs')
const { deployments, getChainId, ethers } = require('hardhat')
const { networkConfig, developmentChains } = require('../helper-hardhat-config')
const { assert } = require('console')

skip.if(!developmentChains.includes(network.name)).
    describe('SVGNFT Unit Tests', async function () {
        let svgNFT;

        beforeEach(async () => {
            await deployments.fixture(['mocks', 'svg'])
            const SVGNFT = await deployments.get("SVGNFT")
            svgNFT = await ethers.getContractAt("SVGNFT", SVGNFT.address)
        })

        it('should return the correct URI', async function () {
            let expectedURI = fs.readFileSync('./test/data/metadata.txt', 'utf8')
            let uri = await svgNFT.tokenURI(0)
            console.log('ecpectedURI -->', expectedURI);
            console.log('Output URI -->', uri);
            expect(uri == expectedURI).to.be.true
        })
    })
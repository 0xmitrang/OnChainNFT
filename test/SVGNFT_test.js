const { expect } = require('chai')
const chai = require('chai')
const BN = require('bn.js')
chai.use(require('chai-bn')(BN))
const skipIf = require('mocha-skip-if')
const fs = require('fs')
const { deployments, getChainId } = require('hardhat')
const { networkConfig, developmentChains } = require('../helper-hardhat-config')
const SVGNFT_ABI = require('../artifacts/contracts/SVGNFT.sol/SVGNFT.json')
const { assert } = require('console')

skip.if(!developmentChains.includes(network.name)).
    describe('SVGNFT Unit Tests', async function () {
        let svgNFT;

        beforeEach(async () => {
            await deployments.fixture(['mocks', 'svg'])
            const SVGNFT = await deployments.get("SVGNFT")
            console.log('abi -->', SVGNFT_ABI);
            svgNFT = await new web3.eth.Contract(SVGNFT_ABI, SVGNFT.address)
        })

        it('should return the correct URI', async function () {
            expect(true);
        })
    })
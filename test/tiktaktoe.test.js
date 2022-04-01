const { expect } = require("chai");
const { ethers } = require("hardhat");
const { createModuleResolutionCache } = require("typescript");

describe("TikTakToe", function() {
    let acc1
    let acc2
    let tikTakToe

    beforeEach(async function() {
       [acc1, acc2] = await ethers.getSigners()
       const TikTakToe = await ethers.getContractFactory("TikTakToe", acc1)
       tikTakToe = await TikTakToe.deploy()
       await tikTakToe.deployed()
       console.log(tikTakToe.address)
   }) 

   it("shoud be deployed", async function() {
       expect(tikTakToe.address).to.be.properAddress
   })

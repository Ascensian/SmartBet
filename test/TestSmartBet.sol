// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { ethers } from "hardhat/console";
import { expect } from "chai";
import { Contract } from "ethers";
import { waffle } from "hardhat";

describe("SmartBet", function () {
  let smartBet: Contract;
  let owner: any;
  let addr1: any;
  let addr2: any;
  let addrs: any;

  beforeEach(async function () {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    const SmartBet = await ethers.getContractFactory("SmartBet");
    smartBet = await SmartBet.deploy();
    await smartBet.deployed();
  });

  it("Should add a match", async function () {
    await smartBet.connect(owner).addMatch("Team A", "Team B", Math.floor(Date.now() / 1000) + 3600);
    expect(await smartBet.nextMatchId()).to.equal(1);
  });

  it("Should place a bet", async function () {
    await smartBet.connect(addr1).registerUser("User1");
    await smartBet.connect(addr2).registerUser("User2");

    await smartBet.connect(addr1).placeBet(0, 2, 1, { value: ethers.utils.parseEther("1") });
    await smartBet.connect(addr2).placeBet(0, 3, 2, { value: ethers.utils.parseEther("2") });

    expect(await smartBet.betsByMatchId(0)).to.have.lengthOf(2);
  });

  it("Should determine winners", async function () {
    await smartBet.connect(owner).addMatch("Team A", "Team B", Math.floor(Date.now() / 1000) + 3600);
    await smartBet.connect(addr1).registerUser("User1");
    await smartBet.connect(addr2).registerUser("User2");

    await smartBet.connect(addr1).placeBet(0, 2, 1, { value: ethers.utils.parseEther("1") });
    await smartBet.connect(addr2).placeBet(0, 3, 2, { value: ethers.utils.parseEther("2") });

    await smartBet.connect(owner).setMatchResult(0, 2, 1);

    await smartBet.connect(owner).determineWinners(0);

    // Check balance of winners
    expect(await ethers.provider.getBalance(addr1.address)).to.equal(ethers.utils.parseEther("2"));
    expect(await ethers.provider.getBalance(addr2.address)).to.equal(ethers.utils.parseEther("4"));
  });
});

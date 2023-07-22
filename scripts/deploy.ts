import { ethers } from "hardhat";

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);


  const erc20Token = await ethers.deployContract("RealWorldDAI");

  await erc20Token.waitForDeployment();

  console.log(
    `contracts were deployed to ${erc20Token.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
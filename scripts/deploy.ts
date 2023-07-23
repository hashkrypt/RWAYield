import { ethers } from "hardhat";

// async function main() {

//   const erc20Token = await ethers.deployContract("TreasuryBond");

//   await erc20Token.waitForDeployment();

//   console.log(
//     `contracts were deployed to ${erc20Token.target}`
//   );
// }

async function main(){
  const rolesAddress = "0xc099C28321ACAd70beb173f22B5bF40050bB3999";
  const registryAddress = "0x2eF31aB1efe3f520f3396B9F05E0fD10DA5dC5d2";
  const managerAddress = "0x58435c4A1Ce4aF4f8Cce7374ACe5Cd59626fCe02"; // vault address
  if( rolesAddress == "" || registryAddress == "" || managerAddress == "" ){
    console.log("Please fill the rolesAddress, registryAddress and managerAddress in this file");
    return;
  }
  const allocatorConduit = await ethers.deployContract("AllocatorConduitExample", [rolesAddress, registryAddress, managerAddress]);

  await allocatorConduit.waitForDeployment();

  console.log(
    `contracts were deployed to ${allocatorConduit.target}`
  );
}

// async function main(){
  
//   const TreasuryVault = await ethers.deployContract("TreasuryVault", ["0xAB1d82A82f113ed7b7b04B671f3401B09661b5Dd", "0x0D916B30a46390fe3baf4eFC618EA05935Dfc0aD", 1]);

//   await TreasuryVault.waitForDeployment();

//   console.log(
//     `contracts were deployed to ${TreasuryVault.target}`
//   );
// }

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
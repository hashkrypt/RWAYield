import { Web3Button, Web3NetworkSwitch } from "@web3modal/react";
import { useAccount, useNetwork, usePrepareContractWrite, useContractWrite } from "wagmi";
import Image from "next/image";
import { useState, useEffect } from "react";
import {BigNumber, ethers} from "ethers";
import { client, provider as wagmiProvider } from "../wagmi";
import { abi as ConduitABI}  from "../../../artifacts/contracts/AllocatorConduitExample.sol/AllocatorConduitExample.json";
import { abi as DaiABI}  from "../../../artifacts/contracts/Dai.sol/Dai.json";
import { abi as TreasuryVaultABI } from "../../../artifacts/contracts/TreasuryVault.sol/TreasuryVault.json";
import { abi as TreasuryBondABI } from "../../../artifacts/contracts/TreasuryBond.sol/TreasuryBond.json";


import { Account, DepositModule, RewardsModule } from "../components";

function Page() {
  const { isConnected, } = useAccount();
  // const [depositComp, setDepositcomp] = useState(true);
  const [debtAmount, setDebtAmount] = useState(0);
  const { chain, chains } = useNetwork()
  const [provider, setProvider] = useState(ethers.getDefaultProvider());
  const [txLink, setTxLink] = useState("");
  const [loading, setLoading] = useState(false);
  // const []

  const setBorrow = async (amount) => {
    setLoading(true);
    console.log("setBorrow");
    const valut = await connectVault();
    const dai = await connectDai();
    const tx = await valut.borrow(dai.address, ethers.utils.parseUnits(amount).toString());
    console.log("tx");
    console.log(tx);
    // eventを取得する
    valut.on("Borrow", async (account, address, amount, event) => {
      setTxLink(`https://goerli.etherscan.io/tx/${event.transactionHash}`)
      const signer = (provider as ethers.providers.Web3Provider).getSigner();
      const balance = await dai.balanceOf((await signer.getAddress()));
      setDebtAmount(Number(ethers.utils.parseEther(balance.toString())));
      setLoading(false);
    });
    setLoading(true);
  }

  const setRepay = async (amount) => {
    console.log("setRepay");
    setLoading(true);
    const valut = await connectVault();
    const dai = await connectDai();
    await dai.approve(valut.address, BigNumber.from(ethers.utils.parseUnits(amount)));
    dai.on("Approval", async (owner, spender, amount, event) => {
      await valut.repay(dai.address, BigNumber.from(ethers.utils.parseUnits(amount)));
    });

    valut.on("Repay", async (account, address, amount, event) => {
      setTxLink(`https://goerli.etherscan.io/tx/${event.transactionHash}`)

      const signer = (provider as ethers.providers.Web3Provider).getSigner();
      console.log("(await signer.getAddress())");
      console.log((await signer.getAddress()));
      const balance = await dai.balanceOf((await signer.getAddress()));
      setRepay(Number(ethers.utils.parseEther(balance.toString())));
      setLoading(false);
    });
  }

  const changeProvider = async () => {
    console.log("process.env.NEXT_PUBLIC_RPC_URL_GOERLI")
    console.log(process.env.NEXT_PUBLIC_RPC_URL_GOERLI)
    // const url = chain?.id == 5 ? process.env.NEXT_PUBLIC_RPC_URL_GOERLI : "";
    const provider = new ethers.providers.Web3Provider((window.ethereum as any));
    setProvider(provider);
  }

  const connectConduit = async () => {
    await changeProvider();
    const signer = (provider as ethers.providers.Web3Provider).getSigner();
    const conduit = new ethers.Contract("0xC81a7D8868f13D65552d1b5F13D2B61767E22451", ConduitABI, signer);
    return conduit
  }

  const connectDai = async () => {
    await changeProvider();
    const signer = (provider as ethers.providers.Web3Provider).getSigner();
    const dai = new ethers.Contract("0x0D916B30a46390fe3baf4eFC618EA05935Dfc0aD", DaiABI, signer);
    return dai
  }

  const connectVault = async () => {
    await changeProvider();
    const signer = (provider as ethers.providers.Web3Provider).getSigner();
    const vault = new ethers.Contract("0x58435c4A1Ce4aF4f8Cce7374ACe5Cd59626fCe02", TreasuryVaultABI, signer);
    return vault
  }

  useEffect(() => {
    setTimeout(() => {
      console.log("Hello, World!");
    }, 3000);
    changeProvider();
    setLoading(false);
    setTxLink("");
  }, [debtAmount]);

  const Header = () => {
    return (
      <div className="flex justify-between pt-4 h-30">
        <Image src="/RWAYieldLogo.png" width="100" height="100" alt={""} />
        <div className="flex">
          <Web3Button icon="show" label="Connect Wallet" balance="show" />
          <br />
          <Web3NetworkSwitch />
          <br />
        </div>
      </div>
    );
  };

  return (
    <div className="flex-auto px-8 min-h-screen bg-[#1C1E30]">
      {Header()}
      <div className="flex justify-center items-center min-h-[700px] flex-col">
        <DepositModule setBorrow={setBorrow} setRepay={setRepay} loading={loading} />
        <RewardsModule debtAmount={debtAmount} txLink={txLink} />
        <div className="flex justify-center items-center text-white">
          <a href={txLink} target="_blank" rel="noopener noreferrer">
            {txLink}
          </a>
        </div>
      </div>

      {/* {isConnected && <Account />} */}
    </div>
  );
}

export default Page;

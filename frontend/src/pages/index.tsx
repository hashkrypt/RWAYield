import { Web3Button } from "@web3modal/react";
import { useAccount } from "wagmi";
import Image from "next/image";
import { useState, useEffect } from "react";

import { Account } from "../components";
import DepositModule from "../components/DepositModule";
import RewardsModule from "../components/RewardsModule";

function Page() {
  const { isConnected } = useAccount();
  // const [depositComp, setDepositcomp] = useState(true);

  useEffect(() => {
    setTimeout(() => {
      console.log("Hello, World!");
    }, 3000);
  }, []);

  const Header = () => {
    return (
      <div className="flex justify-between pt-4 h-30">
        <Image src="/RWAYieldLogo.png" width="100" height="100" alt={""} />
        <Web3Button />
      </div>
    );
  };

  return (
    <div className="flex-auto px-8 min-h-screen bg-[#1C1E30]">
      {Header()}
      <div className="flex justify-center items-center min-h-[700px] flex-col   ">
        <DepositModule />
        <RewardsModule />
      </div>

      {/* {isConnected && <Account />} */}
    </div>
  );
}

export default Page;

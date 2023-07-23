import Image from "next/image";
import { useState, useEffect } from "react";

const tabs = [
  { name: "Borrow", href: "#", current: false },
  { name: "Repay", href: "#", current: false },
];

function classNames(...classes) {
  return classes.filter(Boolean).join(" ");
}


const someRendering = (
  <div className="sm:hidden">
    <label htmlFor="tabs" className="sr-only">
      Select a tab
    </label>
    {/* Use an "onChange" listener to redirect the user to the selected tab URL. */}
    <select
      id="tabs"
      name="tabs"
      className="block w-full rounded-md border-gray-300 py-2 pl-3 pr-10 text-base focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm"
      // defaultValue={tabs.find((tab) => tab.current).name}
    >
      {tabs.map((tab) => (
        <option className="w-1/2" key={tab.name}>
          {tab.name}
        </option>
      ))}
    </select>
  </div>
);



export const DepositModule = (props) => {
  const [depositComp, setDepositcomp] = useState(true);

  const [amount, setAmount] = useState(0);

  const handleInputValueChange = (e) => {
    setAmount(e.target.value);
  }

  useEffect(() => {
    console.log("useEffect");
  }, [depositComp]);

  const triggerVault = async () => {
    if(depositComp){
      await borrow()
    } else {
        await repay()
    }
  }

  const borrow = async () => {
    console.log("borrowing")
    console.log(amount)
    await props.setBorrow(amount)
  }

  const repay = async() => {
    console.log("repaying")
    console.log(amount)
    await props.setRepay(amount)
  }

  return (
    <div className=" w-4/12 bg-[#242741] rounded-lg	">
      {someRendering}

      {/* // Nav Component / useState for Deposit and Withdraw */}
      <div className="hidden sm:block">
        <div className="">
          <nav
            className="-mb-px flex space-x-8 bg-[#111320] px-2 rounded-t-lg                        "
            aria-label="Tabs"
            onClick={() => setDepositcomp(!depositComp)}
          >
            {tabs.map((tab) => (
              <a
                key={tab.name}
                href={tab.href}
                className={classNames(
                  !depositComp
                    ? "border-transparent text-[#9A9CB1] w-1/2 text-center hover:border-gray-300 hover:text-gray-700"
                    : "border-transparent text-[#9A9CB1] w-1/2 text-center hover:border-gray-300 hover:text-gray-700",
                  "whitespace-nowrap border-b-2 py-4 px-1 text-sm font-medium",
                )}
                aria-current={tab.current ? "page" : undefined}
              >
                {tab.name}
              </a>
            ))}
          </nav>
        </div>
      </div>

      {/* // Main Other Components */}
      <div
        style={{
          height: "100%",
          width: "100%",
          display: "flex",
          justifyContent: "center",
          alignItems: "center",
          flexDirection: "column",
          padding: 16,
        }}
      >
        <div className="flex justify-between w-full my-2">
          <p className="text-[#9A9CB1]"> Select Token</p>
          {/* <p className="text-[#9A9CB1]">Available: XXX</p> */}
        </div>

        <div className="flex flex-stretch w-full">
          <div className="h-12 w-1/6 rounded-lg bg-[#111320] flex justify-center items-center">
            <Image src="/RWAPair.png" width="50" height="50" alt={""} />
          </div>
          <div className="h-12 ml-4 py-2  rounded-lg flex justify-between items-center ">
            <input className="text-lg h-12 w-full py-2 ml-4 pl-4 text-[#9A9CB1] rounded-lg bg-[#111320]" type={"number"} onChange={handleInputValueChange} value={amount} ></input>
            <button className="bg-pink-500 m-2 hover:bg-pink-700 text-white font-bold py-2 px-4 rounded">MAX</button>
          </div>
        </div>

        <button className="mt-4 bg-pink-500 w-full hover:bg-pink-700 text-white font-bold py-2 mpx-4 rounded-lg text-center" onClick={triggerVault}>
          {props.loading ? 
          (<div className="flex justify-center">
            <svg aria-hidden="true" className="w-8 h-8 text-gray-200 animate-spin dark:text-gray-600 fill-blue-600" viewBox="0 0 100 101" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z" fill="currentColor"/>
                <path d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z" fill="currentFill"/>
            </svg>
            </div>)
                : (depositComp ? "Borrow" : "Repay")}
        </button>
      </div>
    </div>
  );
}

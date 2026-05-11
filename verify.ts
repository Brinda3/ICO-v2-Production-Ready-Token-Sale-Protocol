import { run } from "hardhat";

async function main() {
  try {

const NAME = "KooDoo";
const SYMBOL = "KDO";
const TOTAL_SUPPLY = 48000000n;
const ADMIN = "0x5FcC2fA3a76599f6e672da59CBDC0a37859CD732";
const SIGNER = "0x5FcC2fA3a76599f6e672da59CBDC0a37859CD732";
    const Token = "0x598B71b0C3e35fc60cee1aE1dB9eEF16669B3747";

    // NavkarToken
    await run("verify:verify", {
      address: "0x598B71b0C3e35fc60cee1aE1dB9eEF16669B3747",
      constructorArguments: [NAME, SYMBOL, TOTAL_SUPPLY],
    });

    // NavkarICO
    await run("verify:verify", {
      address: "0xb5807cB17CDbcAd19f06381d362Ac02C481F041A",
      constructorArguments: [ADMIN, SIGNER, Token, 0],
    });


    console.log("✅ Contract successfully verified on Etherscan!");
  } catch (error) {
    console.error("❌ Verification failed:", error);
    process.exit(1);
  }
}

main();

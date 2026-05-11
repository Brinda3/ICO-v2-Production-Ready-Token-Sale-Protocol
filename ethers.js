const { ethers } = require("ethers");

const privateKey = "YOUR_PRIVATE_KEY_HERE";

async function signMessage() {
                var getprovider = 'https://bnb-testnet.g.alchemy.com/v2/yJt6kW6vJsF2h2S-CYMC9'
                var provider = new ethers.JsonRpcProvider(getprovider);
                let wallet = new ethers.Wallet("c2d1cc710f561b9c0540b756dfd4779838fd6d38abea2a00277cfa432cc4207d", provider);
                var nonce = Math.floor(new Date().getTime() / 1000);
                var amount = 100000000000; // 0.001 BNB in wei
                hash = ethers.solidityPackedKeccak256(["uint256", "address", "address", "uint256", 'uint256'], [0, "0x5FcC2fA3a76599f6e672da59CBDC0a37859CD732","0x5FcC2fA3a76599f6e672da59CBDC0a37859CD732", amount.toString(), nonce])
                hash = ethers.getBytes(hash);
                hash = await wallet.signMessage(hash);
                hash = ethers.Signature.from(hash);
                var sign = ethers.Signature.from(hash).serialized
                console.log("Signature:", hash);
                console.log("Split Signature:", sign);
                console.log("nonce:", nonce);
            }

signMessage().catch(console.error);
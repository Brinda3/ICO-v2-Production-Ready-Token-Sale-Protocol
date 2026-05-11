import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
    etherscan: {
      apiKey: {
        polygonAmoy: "GAZQWXTARSMNCW1M9JTPQEBTXGXS7HNNJ1",
        bscTestnet: "1R7195NCZQ1ZCZHQZPUDQJUSZWZNJ27MPV",
        sepolia: "AZY45KT8HEDKIDFUD2SDTYVF4XI1TSUVVY"
      },
    },
    networks: {
      AmoyTestnet: {
        url: "https://polygon-amoy.g.alchemy.com/v2/3BH10F7T5x3xp5eOUF9vhTnu7MIv7yz_",
        accounts: ['c1930a1a532e1847605a2580eb2d0f00ff4ffa1fdeca46b8ea2acbc15d3a411b'],
      },
      BscTestnet: {
        url: "https://data-seed-prebsc-2-s1.binance.org:8545/",
        accounts: ['c2d1cc710f561b9c0540b756dfd4779838fd6d38abea2a00277cfa432cc4207d']
      },
      SepoliaTestnet: {
        url:"https://sepolia.infura.io/v3/645e75ac77564d179ed43f6a536cf97b",
        accounts: ['c526c4dee53a6d771a170635c9f6583f77783378b5cd9ee0971492d25d2149a8']
      }
    },
    solidity: {
      compilers: [
        {
          version: "0.8.29",
          settings: {
            optimizer: {
                      enabled: true,
                      runs: 200
          }
          }
        },
        {
          version: "0.8.9",
          settings: {
            optimizer: {
                      enabled: true,
                      runs: 200
          }
          }
        }
      ],
    },
  };
  
export default config;

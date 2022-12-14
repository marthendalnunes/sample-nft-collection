import { HardhatUserConfig } from 'hardhat/config'
import '@nomicfoundation/hardhat-toolbox'
require('dotenv').config({ path: '.env' })

const ALCHEMY_HTTP_URL = process.env.ALCHEMY_HTTP_URL as string
const PRIVATE_KEY = process.env.PRIVATE_KEY as string

const config: HardhatUserConfig = {
  solidity: '0.8.17',
  networks: {
    goerli: {
      url: ALCHEMY_HTTP_URL,
      accounts: [PRIVATE_KEY]
    }
  }
}

export default config

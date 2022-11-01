import { ethers } from 'hardhat'
require('dotenv').config({ path: '.env' })
import { ALLOWLIST_CONTRACT_ADDRESS, METADATA_URL } from '../constants'

async function main() {
  const allowlistContract = ALLOWLIST_CONTRACT_ADDRESS as string
  const metadataURL = METADATA_URL as string
  const cryptoDevsContract = await ethers.getContractFactory('CryptoDevs')

  const deployedCryptoDevsContract = await cryptoDevsContract.deploy(
    metadataURL,
    allowlistContract
  )
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})

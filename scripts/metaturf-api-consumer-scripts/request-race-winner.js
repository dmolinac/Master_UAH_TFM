const MetaturfAPIConsumer = artifacts.require('MetaturfAPIConsumer')

/*
  This script allows for a Chainlink request to be created from
  the requesting contract. Defaults to the Chainlink oracle address
  on this page: https://docs.chain.link/docs/decentralized-oracles-ethereum-mainnet/#testnets
*/

const raceid = 7122

module.exports = async callback => {
  const mc = await MetaturfAPIConsumer.deployed()
  console.log('Creating request on contract:', mc.address)
  const tx = await mc.requestRaceWinner(raceid)
  callback(tx.tx)
}

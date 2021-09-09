const MetaturfAPIConsumer = artifacts.require('MetaturfAPIConsumer')

/*
  This script makes it easy to read the data on
  the price feed deployed contract
*/

/*module.exports = async callback => {
  const metaturfAPIConsumer = await MetaturfAPIConsumer.deployed()
  const winnerRawText = await metaturfAPIConsumer.winnerRawText()
  callback(winnerRawText)
  console.log(winnerRawText)
}*/

module.exports = async callback => {
    const mc = await MetaturfAPIConsumer.deployed()
    const data = await mc.winnerRawText.call()
    callback(data)
  }
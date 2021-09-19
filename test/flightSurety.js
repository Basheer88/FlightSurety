
var Test = require('../config/testConfig.js');
var BigNumber = require('bignumber.js');

contract('Flight Surety Tests', async (accounts) => {

  var config;
  before('setup contract', async () => {
    config = await Test.Config(accounts);
    await config.flightSuretyData.authorizeContract(config.flightSuretyApp.address, {from: config.owner});
    //await config.flightSuretyData.authorizeCaller(config.flightSuretyApp.address);
    //await config.flightSuretyData.authorizeContract(config.flightSuretyApp.address);
  });

  /****************************************************************************************/
  /* Operations and Settings                                                              */
  /****************************************************************************************/

  it(`(multiparty) has correct initial isOperational() value`, async function () {

    // Get operating status
    let status = await config.flightSuretyData.isOperational.call();
    assert.equal(status, true, "Incorrect initial operating status value");

  });

  it(`(multiparty) can block access to setOperatingStatus() for non-Contract Owner account`, async function () {

      // Ensure that access is denied for non-Contract Owner account
      let accessDenied = false;
      try 
      {
          await config.flightSuretyData.setOperatingStatus(false, { from: config.testAddresses[2] });
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, true, "Access not restricted to Contract Owner");
            
  });

  it(`(multiparty) can allow access to setOperatingStatus() for Contract Owner account`, async function () {

      // Ensure that access is allowed for Contract Owner account
      let accessDenied = false;
      try 
      {
          await config.flightSuretyData.setOperatingStatus(false);
      }
      catch(e) {
          accessDenied = true;
      }
      assert.equal(accessDenied, false, "Access not restricted to Contract Owner");
      
  });

  it(`(multiparty) can block access to functions using requireIsOperational when operating status is false`, async function () {

      await config.flightSuretyData.setOperatingStatus(false);

      let reverted = false;
      try 
      {
          await config.flightSurety.setTestingMode(true);
      }
      catch(e) {
          reverted = true;
      }
      assert.equal(reverted, true, "Access not blocked for requireIsOperational");      

      // Set it back for other tests to work
      await config.flightSuretyData.setOperatingStatus(true);

  });

  it('(airline) cannot register an Airline using registerAirline() if it is not funded', async () => {
    
    // ARRANGE
    let newAirline = accounts[2];

    // ACT
    try {
        let x = await config.flightSuretyApp.registerAirline(newAirline, "SecAirLine", {from: config.firstAirline});
    }
    catch(e) {

    }
    let result = await config.flightSuretyData.isAirline.call(newAirline); 

    // ASSERT
    assert.equal(result, false, "Airline should not be able to register another airline if it hasn't provided funding");

  });

  it(`(First Airline) is registered when contract is deployed`, async function () {
    // Determine if Airline is registered
    let result = await config.flightSuretyData.isRegisteredAirline.call(config.owner);
    assert.equal(result, true, "First airline was not registed upon contract creation");
  });

  
  it('First Four Accounts no Vote Only Last one', async () => {
    
    // ARRANGE
    let newAirlineOne = accounts[2];
    let newAirlineTwo = accounts[3];
    let newAirlineThree = accounts[4];
    let newAirlineFour = accounts[5];
    let newAirlineFive = accounts[6];   
    
    //ACT
    await config.flightSuretyApp.registerAirline.sendTransaction(newAirlineOne, "ThirdAirLine", {from: config.owner});
    await config.flightSuretyApp.registerAirline.sendTransaction(newAirlineTwo, "ThirdAirLine", {from: config.owner});
    await config.flightSuretyApp.registerAirline.sendTransaction(newAirlineThree, "ThirdAirLine", {from: config.owner});
    await config.flightSuretyApp.registerAirline.sendTransaction(newAirlineFour, "ThirdAirLine", {from: config.owner});
    await config.flightSuretyApp.registerAirline.sendTransaction(newAirlineFive, "ThirdAirLine", {from: config.owner});


    let One   = await config.flightSuretyApp.getvoteCount.call(newAirlineOne);
    let Two   = await config.flightSuretyApp.getvoteCount.call(newAirlineTwo);
    let Three = await config.flightSuretyApp.getvoteCount.call(newAirlineThree);
    let Four  = await config.flightSuretyApp.getvoteCount.call(newAirlineFour);
    let Five  = await config.flightSuretyApp.getvoteCount.call(newAirlineFive);
    
    // ASSERT Second Account
    //assert.equal(One[0], true, "One Returned False");
    assert.equal(One.toNumber(), 1, "One Number of Votes should be 0");

    // ASSERT Second Account
    //assert.equal(Two[0], true, "Two Returned False");
    assert.equal(Two.toNumber(), 2, "Two Number of Votes should be 0");
    // Third Account
    //assert.equal(Three[0], true, "Three Returned False");
    assert.equal(Three.toNumber(), 3, "Three Number of Votes should be 0");
    // Fourth Account
    //assert.equal(Four[0], true, "Four Returned False");
    assert.equal(Four.toNumber(), 4, "Four Number of Votes should be 0");
    // Fifth account
    //assert.equal(Five[0], true, "Five Returned False");
    assert.equal(Five.toNumber() , 4, "Five Number of Votes should not be 0");
    // Yes Account Five uses a vote and while counter = 4 then only four can votes and while my vote
    // Function return only true so we have 4 true votes so that 4 = 4 So my function works correctly

  });

});

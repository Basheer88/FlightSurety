import FlightSuretyApp from '../../build/contracts/FlightSuretyApp.json';
import Config from './config.json';
import Web3 from 'web3';

export default class Contract {
    constructor(network, callback) {

        let config = Config[network];
        this.web3 = new Web3(new Web3.providers.HttpProvider(config.url));
        this.flightSuretyApp = new this.web3.eth.Contract(FlightSuretyApp.abi, config.appAddress);
        this.initialize(callback);
        this.owner = null;
        this.airlines = [];
        this.passengers = [];
        this.flights = [];
    }

    getMetaskAccountID() {
        // Retrieving metamask accounts
        this.web3.eth.getAccounts(function (err, res) {
            if (err) {
                console.log('Error:', err)
                return
            }
            this.metamaskAccountID = res[0]
        })
      }

    initialize(callback) {
        this.getMetaskAccountID()

        this.web3.eth.getAccounts((error, accts) => {
           
            this.owner = accts[0];

            let counter = 1;
            
            while(this.airlines.length < 5) {
                this.airlines.push(accts[counter++]);
            }

            while(this.passengers.length < 5) {
                this.passengers.push(accts[counter++]);
            }

            callback();
        });
    }

    getAirlines() {
        return this.airlines;
    }
    
    getPassengers() {
        return this.passengers;
    }

    isOperational(callback) {
       let self = this;
       self.flightSuretyApp.methods
            .isOperational()
            .call({ from: self.owner}, callback);
    }

    isAirlineRegistered(airline) {
        let self = this
    
        return new Promise((res, rej) => {
          self.flightSuretyApp.methods
            .isAirline(airline)
            .call({ from: self.owner }, (error, result) => {
              if (error) {
                console.log(error)
                rej(error)
              } else {
                res(result)
              }
            })
        })
    }
    
    getAirlineFunds(airline) {
        const self = this
    
        return new Promise((res, rej) => {
          self.flightSuretyApp.methods
            .getFunds()
            .call({ from: airline }, (error, result) => {
              if (error) {
                console.log(error)
                rej(error)
              } else {
                const value = Web3.utils.fromWei(result, 'ether')
                res(value)
              }
            })
        })
    }
    
    // Airline Regestration
    registerAirline(airline, airlineName) {
        const self = this
        return new Promise((res, rej) => {
          self.flightSuretyApp.methods.registerAirline(airline,airlineName).send({ from: self.owner, gasPrice: 100000000000, gas: 4712388 }, (error, result) => {
              if (error) {
                console.log(error)
                rej(error)
              } else {
                res(result)
              }
            })
        })
    }
    
    // Airline Funding 
    fundAirline(airline) {
        const self = this
        const value = Web3.utils.toWei('10', 'ether')
    
        return new Promise((res, rej) => {
          self.flightSuretyApp.methods.fund().send({ from: airline, gasPrice: 100000000000, gas: 4712388, value: value }, (error, result) => {
              if (error) {
                console.log(error)
                rej(error)
              } else {
                res(result)
              }
            })
        })
    }

    // Fligth Registration
    registerFlight(flightID, flightTime) {
        const self = this
        return new Promise((res, rej) => {
          self.flightSuretyApp.methods.registerFlight(flightID,flightTime).send({ from: self.owner, gasPrice: 100000000000, gas: 4712388 }, (error, result) => {
              if (error) {
                console.log(error)
                rej(error)
              } else {
                res(result)
              }
            })
        })
    }

    getFlights() {
      let self = this;
  
      return new Promise((res, rej) => {
        self.flightSuretyApp.methods.getFlights().call({ from: self.owner }, (error, result) => {
            if (error) {
              console.log(error)
              rej(error)
            } else {
              res(result)
            }
          })
      })
    }

    // Buy Flight Insurance
    buy(flight, amount) {
      let flightInfo = JSON.parse(flight);
      const self = this
      return new Promise((res, rej) => {
        self.flightSuretyApp.methods.buy(flightInfo.flight).send({ from: self.owner, gasPrice: 100000000000, gas: 4712388,  value: amount }, (error, result) => {
          if (error) {
            rej(error)
          } else {
            res(result)
          }
        })
      })
    }
    
    payInsurance(flight) {
        const self = this
        return new Promise((res, rej) => {
          self.flightSuretyApp.methods.payInsurance(flight).send({ from: self.owner, gasPrice: 100000000000, gas: 4712388 }, (error, result) => {
              if (error) {
                console.log(error)
                rej(error)
              } else {
                res(result)
              }
            })
        })
    }


    fetchFlightStatus(flight, callback) {
        let self = this;
        let payload = {
            airline: self.airlines[0],
            flight: flight,
            timestamp: Math.floor(Date.now() / 1000)
        } 
        self.flightSuretyApp.methods
            .fetchFlightStatus(payload.airline, payload.flight, payload.timestamp)
            .send({ from: self.owner}, (error, result) => {
                callback(error, payload);
            });
    }
}
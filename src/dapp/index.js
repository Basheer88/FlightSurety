
import DOM from './dom';
import Contract from './contract';
import './flightsurety.css';


(async() => {

    let result = null;

    let contract = new Contract('localhost', () => {

        // Read transaction
        contract.isOperational((error, result) => {
            console.log(error,result);
            display('Operational Status', 'Check if contract is operational', [ { label: 'Operational Status', error: error, value: result} ]);
        });
    
        // Get current registered flight if any
        flightFormSelect(contract);

        // User-submitted transaction
        DOM.elid('submit-oracle').addEventListener('click', () => {
            let flight = DOM.elid('flight-number').value;
            // Write transaction
            contract.fetchFlightStatus(flight, (error, result) => {
                display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp} ]);
            });
        })

        // Registering Airline
        DOM.elid('registerAirBTN').addEventListener('click', async() => {
            let airlineAddress = DOM.elid('AirLine-Address').value;
            let airlineName = DOM.elid('AirLine-Name').value;

            // Write transaction
            await contract.registerAirline(airlineAddress, airlineName ,(error, result) => {
                display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp}]);
            });
            DOM.elid('RegisterNewAirline').innerText = "Airline Registered Successfully";
        })

        // Funding Airline
        DOM.elid('fundAirBTN').addEventListener('click', async() => {
            let airlineAddress = DOM.elid('AirLine-Address').value;
            //let airlineFund = DOM.elid('AirLine-Fund').value;

            // Write transaction
            await contract.fundAirline(airlineAddress ,(error, result) => {
                display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp}]);
            //updateData(contract)
            });
            DOM.elid('FundNewAirline').innerText = "Funded Successfully";
        })

        // Registering Flight
        DOM.elid('registerFlight').addEventListener('click', async() => {
            let flightID = DOM.elid('FlightID').value;
            //let flightTime = DOM.elid('FlightTime').value;
            let flightTime = Date.now();
            //console.log("Timeeee");
            //console,log(flightTime);
            // Write transaction
            await contract.registerFlight(flightID, flightTime ,(error, result) => {
                display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp}]);
            });

            flightFormSelect(contract);
            DOM.elid('RegisterNewFlight').innerText = "Registered Successfully";  
        })

        // Buy Flight Insurance
        DOM.elid('Buy').addEventListener('click', async() => {
            let flightID = DOM.elid('buyFlight').value;
            //let flightTime = DOM.elid('FlightTime').value;
            let amount = parseInt(DOM.elid('buyAmount').value);

            // Write transaction
            //await contract.buy(flightID, flightTime ,amount ,(error, result) => {
            await contract.buy(flightID ,amount ,(error, result) => {
                display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp}]);
            });
            DOM.elid('BuyFlightStatus').innerText = "Bought";
        })

        // Fetch Flight Status
        DOM.elid('fetch').addEventListener('click', async() => {
            let fetchFlight = DOM.elid('fetchFlight').value;
            // Write transaction
            await contract.fetchFlightStatus(fetchFlight,(error, result) => {
                display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp}]);
            });
        })

        // Withdraw Flight Insurance
        DOM.elid('Refund').addEventListener('click', async() => {
            let flightID = DOM.elid('withdrawFlight').value;

            // Write transaction
            await contract.payInsurance(flightID ,(error, result) => {
                display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp}]);
            });
            DOM.elid('RefundFligh').innerText = "Refunded";
        })

    });
    

})();

// Fill Flight Select with regitered flight
async function flightFormSelect(contract) {
    const selectBuyFlight = DOM.elid('buyFlight');
    const selectFlightStatus = DOM.elid('fetchFlight');
    //const timestampInput = DOM.elid('FlightTime').value;
    //timestampInput.value = new Date().toISOString().slice(0, 10)
    while (selectBuyFlight.childElementCount > 1) {
      const lastChild = selectBuyFlight.lastChild;
      selectBuyFlight.removeChild(lastChild);
    }
    while (selectFlightStatus.childElementCount > 1) {
        const lastChild = selectFlightStatus.lastChild;
        selectFlightStatus.removeChild(lastChild);
      }
    const flights = await getRegisteredFlights(contract);
    const options = [];
    flights.forEach((address) => {
        console.log(address)
        displayList({
            flight: address
        }, selectBuyFlight)
        displayList({
            flight: address
        }, selectFlightStatus)
    })
    DOM.appendArray(selectBuyFlight, options);
    DOM.appendArray(selectFlightStatus, options);
}

async function getRegisteredFlights(contract) {
    console.log("before")
    console.log(contract.getFlights())
    console.log("after")
    const flights = contract.getFlights();
  /*  const registeredFlights = [];
  
    for (const flight of flights) {
        registeredFlights.push(flight)
    }  
    
    return registeredFlights    */
    console.log("Here1");
    console.log(flights);
    console.log("Here2");
    return flights;
  }


function display(title, description, results) {
    let displayDiv = DOM.elid("display-wrapper");
    let section = DOM.section();
    section.appendChild(DOM.h2(title));
    section.appendChild(DOM.h5(description));
    results.map((result) => {
        let row = section.appendChild(DOM.div({className:'row'}));
        row.appendChild(DOM.div({className: 'col-sm-4 field'}, result.label));
        row.appendChild(DOM.div({className: 'col-sm-8 field-value'}, result.error ? String(result.error) : String(result.value)));
        section.appendChild(row);
    })
    displayDiv.append(section);
} 

function displayList(flight, parentEl) {
    console.log(flight);
    console.log(parentEl);
    let el = document.createElement("option");
    el.text = `${flight.flight}`;
    el.value = JSON.stringify(flight);
    parentEl.add(el);
}







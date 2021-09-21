
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
        })

        // Registering Flight
        DOM.elid('registerFlight').addEventListener('click', async() => {
            let flightID = DOM.elid('FlightID').value;
            let flightTime = DOM.elid('FlightTime').value;

            // Write transaction
            await contract.registerFlight(flightID, flightTime ,(error, result) => {
                display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp}]);
            });
        })

        // Buy Flight Insurance
        DOM.elid('Buy').addEventListener('click', async() => {
            let flightID = DOM.elid('buyFlight').value;
            let flightTime = DOM.elid('FlightTime').value;
            let amount = parseInt(DOM.elid('buyAmount').value);

            // Write transaction
            await contract.buy(flightID, flightTime ,(error, result) => {
                display('Oracles', 'Trigger oracles', [ { label: 'Fetch Flight Status', error: error, value: result.flight + ' ' + result.timestamp}]);
            });
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
        })

    });
    

})();


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








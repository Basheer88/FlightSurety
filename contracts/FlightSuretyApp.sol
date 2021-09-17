pragma solidity ^0.4.25;

// It's important to avoid vulnerabilities due to numeric overflow bugs
// OpenZeppelin's SafeMath library, when used correctly, protects agains such bugs
// More info: https://www.nccgroup.trust/us/about-us/newsroom-and-events/blog/2018/november/smart-contract-insecurity-bad-arithmetic/

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

/************************************************** */
/* FlightSurety Smart Contract                      */
/************************************************** */
contract FlightSuretyApp {
    using SafeMath for uint256; // Allow SafeMath functions to be called for all uint256 types (similar to "prototype" in Javascript)

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    // Flight status codees
    uint8 private constant STATUS_CODE_UNKNOWN = 0;
    uint8 private constant STATUS_CODE_ON_TIME = 10;
    uint8 private constant STATUS_CODE_LATE_AIRLINE = 20;
    uint8 private constant STATUS_CODE_LATE_WEATHER = 30;
    uint8 private constant STATUS_CODE_LATE_TECHNICAL = 40;
    uint8 private constant STATUS_CODE_LATE_OTHER = 50;

    uint256 private counter = 1;            // Registered Airlines Counter 

    address private contractOwner;          // Account used to deploy contract

    address[] private airlineAddress = new address[](0);

    FlightSuretyData flightSuretyData;      // Pointing to FlightSuretyData contract

/*    struct Flight {
        bool isRegistered;
        uint8 statusCode;
        uint256 updatedTimestamp;        
        address airline;
    }
    mapping(bytes32 => Flight) private flights;
*/
 
    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational() 
    {
         // Modify to call data contract's status
        require(flightSuretyData.isOperational(), "Contract is currently not operational");  
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    /********************************************************************************************/
    /*                                       CONSTRUCTOR                                        */
    /********************************************************************************************/

    /**
    * @dev Contract constructor
    *
    */
    constructor
                                (
                                    address datacontract
                                ) 
                                public 
    {
        contractOwner = msg.sender;
        flightSuretyData = FlightSuretyData(datacontract);    // Set FlightSuretyData Contract address
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/
/*
    function isOperational() 
                            public 
                            pure 
                            returns(bool) 
    {
        return true;  // Modify to call data contract's status
    }*/

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/


    // Add new authorized contract
    function registerNewAuthorizedContract 
                                        (
                                            address newContract
                                        )
                                        internal
                                        requireContractOwner
                                        requireIsOperational
    {
        flightSuretyData.authorizeContract(newContract);
    }

    // Delete old Authorized Contract
    function deleteAuthorizedContract 
                                    (
                                        address delContract
                                    )
                                    internal
                                    requireContractOwner
                                    requireIsOperational
    {
        flightSuretyData.deauthorizeContract(delContract);
    }

  
   /**
    * @dev Add an airline to the registration queue
    *
    */   
    function registerAirline
                            (
                                address airAddress,
                                uint256 airName   
                            )
                            external
                            returns(bool success, uint256 votes)
    {
        votes = 0;
        if(counter >= 4)
        {
            flightSuretyData.registerAirline(airAddress, airName);
            counter.add(1);
            airlineAddress.push(airAddress);
            //return (success, 0);
            return (true, 0);
        }
        else
        {
            bool vo;
            // ask for voting
            for(uint i=1; i<= counter; i++){
                vo = randVote(airlineAddress[i]);
                if(vo){
                    votes.add(1);
                }
            }
            //  require(votes>=(counter/2),"airlines voted to reject you");
            if(votes>=(counter/2)) {
                flightSuretyData.registerAirline(airAddress, airName);
                counter.add(1);
                airlineAddress.push(airAddress);
                //return (success, votes);
                return (true, votes);
            }
            else {
                return (false, votes);
            }          
        }
    }


   /**
    * @dev Register a future flight for insuring.
    *
    */  
    function registerFlight
                            (
                                bytes32 flightID,
                                uint256 timeStamp
                            )
                            external
    {
        flightSuretyData.registerFlight(msg.sender, flightID, timeStamp);
    }
    
   /**
    * @dev Called after oracle has updated flight status
    *
    */  
    function processFlightStatus
                                (
                                    address airline,
                                    bytes32 flight,
                                    uint256 timestamp,
                                    uint8 statusCode
                                )
                                internal
    {
        flightSuretyData.processFlightStatus(flight, statusCode);
        
        // if status is 20 then the flight are delayeds
        if (statusCode == STATUS_CODE_LATE_AIRLINE)
            creditInsurees(flight, 150);
        emit flightProcessed(airline, flight, timestamp, statusCode);
    }


    // Generate a request for oracles to fetch flight information
    function fetchFlightStatus
                        (
                            address airline,
                            string flight,
                            uint256 timestamp                            
                        )
                        external
    {
        uint8 index = getRandomIndex(msg.sender);

        // Generate a unique key for storing the request
        bytes32 key = keccak256(abi.encodePacked(index, airline, flight, timestamp));
        oracleResponses[key] = ResponseInfo({
                                                requester: msg.sender,
                                                isOpen: true
                                            });

        emit OracleRequest(index, airline, flight, timestamp);
    }

    // Airlines Voting system and it always return true 
    function randVote
                    (
                        address air
                    )
                    internal
                    view
                    returns(bool)
    {
        uint x = uint(keccak256(abi.encodePacked(now, block.difficulty, air))) % 2;
        if(x==0){
            return true;    // // Can be false but We want it to be true always
        }
        else{
            return true;    // Can be false but We want it to be true always 
        }
    }

    // to call airlines fund function
    function fund()
        public
        payable
    {
        require(msg.value >= 10 ether, "Inadaquate funds, require more than or equal 10 ether.");
        flightSuretyData.fund.value(msg.value)(msg.sender);
    }

    // Buy Flight Insurance functions
    function buy
                            (
                                bytes32 _flightID,
                                uint256 _timestamp
                            )
                            external
                            payable
                            returns(bool)
    {
        require(flightSuretyData.isRegisteredFlight(_flightID),"Flight is not registered.");
        require(msg.value <= 1 ether," more than one ether.");
        bool success = flightSuretyData.buy(_flightID, msg.sender, msg.value, _timestamp);
        return success;
    }

    // Calculate Credit Insurees
    function creditInsurees
                                (
                                    bytes32 _flightID,
                                    uint256 amount
                                )
                                internal
    {
        flightSuretyData.creditInsurees(_flightID, amount);
    }

    // Pay Function
    function payInsurance
                            (
                                bytes32 _flightID
                            )
                            external
                            payable
    {
        flightSuretyData.payInsurance(_flightID, msg.sender);
    }

// region ORACLE MANAGEMENT

    // Incremented to add pseudo-randomness at various points
    uint8 private nonce = 0;    

    // Fee to be paid when registering oracle
    uint256 public constant REGISTRATION_FEE = 1 ether;

    // Number of oracles that must respond for valid status
    uint256 private constant MIN_RESPONSES = 3;


    struct Oracle {
        bool isRegistered;
        uint8[3] indexes;        
    }

    // Track all registered oracles
    mapping(address => Oracle) private oracles;

    // Model for responses from oracles
    struct ResponseInfo {
        address requester;                              // Account that requested status
        bool isOpen;                                    // If open, oracle responses are accepted
        mapping(uint8 => address[]) responses;          // Mapping key is the status code reported
                                                        // This lets us group responses and identify
                                                        // the response that majority of the oracles
    }

    // Track all oracle responses
    // Key = hash(index, flight, timestamp)
    mapping(bytes32 => ResponseInfo) private oracleResponses;

    // Event fired each time an oracle submits a response
    event FlightStatusInfo(address airline, bytes32 flight, uint256 timestamp, uint8 status);

    event flightProcessed(address airline, bytes32 flight, uint256 timestamp, uint8 statusCode);

    event OracleReport(address airline, bytes32 flight, uint256 timestamp, uint8 status);

    // Event fired when flight status request is submitted
    // Oracles track this and if they have a matching index
    // they fetch data and submit a response
    event OracleRequest(uint8 index, address airline, string flight, uint256 timestamp);


    // Register an oracle with the contract
    function registerOracle
                            (
                            )
                            external
                            payable
    {
        // Require registration fee
        require(msg.value >= REGISTRATION_FEE, "Registration fee is required");

        uint8[3] memory indexes = generateIndexes(msg.sender);

        oracles[msg.sender] = Oracle({
                                        isRegistered: true,
                                        indexes: indexes
                                    });
    }

    function getMyIndexes
                            (
                            )
                            view
                            external
                            returns(uint8[3])
    {
        require(oracles[msg.sender].isRegistered, "Not registered as an oracle");

        return oracles[msg.sender].indexes;
    }




    // Called by oracle when a response is available to an outstanding request
    // For the response to be accepted, there must be a pending request that is open
    // and matches one of the three Indexes randomly assigned to the oracle at the
    // time of registration (i.e. uninvited oracles are not welcome)
    function submitOracleResponse
                        (
                            uint8 index,
                            address airline,
                            bytes32 flight,
                            uint256 timestamp,
                            uint8 statusCode
                        )
                        external
    {
        require((oracles[msg.sender].indexes[0] == index) || (oracles[msg.sender].indexes[1] == index) || (oracles[msg.sender].indexes[2] == index), "Index does not match oracle request");


        bytes32 key = keccak256(abi.encodePacked(index, airline, flight, timestamp)); 
        require(oracleResponses[key].isOpen, "Flight or timestamp do not match oracle request");

        oracleResponses[key].responses[statusCode].push(msg.sender);

        // Information isn't considered verified until at least MIN_RESPONSES
        // oracles respond with the *** same *** information
        emit OracleReport(airline, flight, timestamp, statusCode);
        if (oracleResponses[key].responses[statusCode].length >= MIN_RESPONSES) {

            emit FlightStatusInfo(airline, flight, timestamp, statusCode);

            // Handle flight status as appropriate
            processFlightStatus(airline, flight, timestamp, statusCode);
        }
    }

/*
    function getFlightKey
                        (
                            address airline,
                            string flight,
                            uint256 timestamp
                        )
                        pure
                        internal
                        returns(bytes32) 
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }*/

    // Returns array of three non-duplicating integers from 0-9
    function generateIndexes
                            (                       
                                address account         
                            )
                            internal
                            returns(uint8[3])
    {
        uint8[3] memory indexes;
        indexes[0] = getRandomIndex(account);
        
        indexes[1] = indexes[0];
        while(indexes[1] == indexes[0]) {
            indexes[1] = getRandomIndex(account);
        }

        indexes[2] = indexes[1];
        while((indexes[2] == indexes[0]) || (indexes[2] == indexes[1])) {
            indexes[2] = getRandomIndex(account);
        }

        return indexes;
    }

    // Returns array of three non-duplicating integers from 0-9
    function getRandomIndex
                            (
                                address account
                            )
                            internal
                            returns (uint8)
    {
        uint8 maxValue = 10;

        // Pseudo random number...the incrementing nonce adds variation
        uint8 random = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - nonce++), account))) % maxValue);

        if (nonce > 250) {
            nonce = 0;  // Can only fetch blockhashes for last 256 blocks so we adapt
        }

        return random;
    }

// endregion

}   

contract FlightSuretyData {
    function isOperational() 
                            public 
                            pure
                            returns(bool);

    function isRegisteredFlight(
                                    bytes32 flightID
                                ) 
                                public 
                                view 
                                returns(bool);

    function authorizeContract
                            (
                                address newContract
                            )
                            external;

    function deauthorizeContract
                            (
                                address delContract
                            )
                            external;

    function registerAirline
                            (
                                address airAddress,
                                uint256 airName    
                            )
                            external;

    function registerFlight
                            (
                                address airline,
                                bytes32 flightID,
                                uint256 timeStamp
                            )
                            external;

    function fund           (
                                address _airline
                            )
                            public
                            payable;

    function buy            (
                                bytes32 flightID,
                                address passengerID,
                                uint256 recievedinsurence,
                                uint256 timestamp
                            )
                            external
                            payable
                            returns(bool);
    
    function creditInsurees (
                                bytes32 flightID,
                                uint256 creditAmount
                            )
                            external;
    function payInsurance   (
                                bytes32 flighID,
                                address passenger
                            )
                            external
                            payable;
    function processFlightStatus(
                                bytes32 flightID,
                                uint8 statusCode
                                )
                                external;
}
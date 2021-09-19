pragma solidity ^0.4.25;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false
    mapping(address => uint256) authorizedContracts;                    // Only Authorized Contracts can call this contract
    mapping(address => uint256) funds;
    struct Flight {
        bool isRegistered;
        uint8 statusCode;
        uint256 updatedTimestamp;       
        address airline;
        address[] passAddress;
    }
    mapping(bytes32 => Flight) private flights;

    //mapping(uint256 => address) private passNum;

    struct AirLine {
        bool isRegistered;
        bool isFunded;
        address airlineAddress;
        string airlineName;
    }
    mapping(address => AirLine) private airlines;

/*    struct Insurance{
        uint256 insuranceAmount;
        address passenger;
        bool    isTaken;
    }
    mapping (bytes32 => Insurance) private insurenceList;
    mapping (bytes32 => address[]) private passengerList;  */

    struct Insurance {
        bytes32 flightID;
        uint256 insuranceAmount;
        address passengerAddress;
        bool insuranceStatus;
        bool isTaken;
    }
    mapping (address => Insurance) private passenger;

    uint256 public constant insuranceFee = 1 ether;


    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/



    event AuthorizedCaller(address caller);
    event DeAuthorizedCaller(address caller);

    event RegisterAirline(address indexed account);
    event RegisterFlight(bytes32 flightKey);

    event Bought(address buyer, bytes32 flightKey, uint256 amount);
    event Creditted(bytes32 flightKey);
    event Paid(address insuree, uint256 amount);

    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor
                                (
                                ) 
                                public 
    {
        contractOwner = msg.sender;
        authorizedContracts[msg.sender]=1;

        airlines[msg.sender].isRegistered = true;
        airlines[msg.sender].isFunded = true;
        airlines[msg.sender].airlineAddress = contractOwner;
        airlines[msg.sender].airlineName = "Bash";

        emit RegisterAirline(contractOwner);
    }

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
        require(operational, "Contract is currently not operational");
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

    /**
    * @dev Modifier that requires the caller is listed in authorizedContracts with value 1
    */
    modifier isCallerAuthorized()
    {
        require(authorizedContracts[msg.sender] == 1 , "Caller is not authorized");
        _;
    }

    function authorizeContract(address dataContract) external requireContractOwner returns(bool){
        authorizedContracts[dataContract] = 1;
        emit AuthorizedCaller(dataContract);
        return true;
    }

    function deauthorizeContract(address dataContract) external requireContractOwner returns(bool){
        delete authorizedContracts[dataContract];
        emit DeAuthorizedCaller(dataContract);
        return true;
    }
    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */      
    function isOperational() 
                            public 
                            view 
                            returns(bool) 
    {
        return operational;
    }

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */      
    function isAirline      (
                                address _airline
                            ) 
                            public 
                            view 
                            returns(bool) 
    {
        //require(airlines[air].isRegistered, "AirLines is not registered");
        //return airlines[air].isRegistered;
        return airlines[_airline].isFunded;
    }

    /**
    * @dev Get Airline registration status
    *
    * @return A bool that indicate Airline registration status
    */      
    function isRegisteredAirline(
                                    address _airline
                                ) 
                            public 
                            view 
                            returns(bool) 
    {
        return airlines[_airline].isRegistered;
    }

    /**
    * @dev Get Flight registration status
    *
    * @return A bool that indicate flight registration status
    */      
    function isRegisteredFlight(
                                    bytes32 flightID
                                ) 
                            public 
                            view 
                            returns(bool) 
    {
        return flights[flightID].isRegistered;
    }

    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */    
    function setOperatingStatus
                            (
                                bool mode
                            ) 
                            external
                            requireContractOwner 
    {
        operational = mode;
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

   /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *
    */   
    function registerAirline
                            (
                                address airAddress,
                                string airName    
                            )
                            isCallerAuthorized
                            requireIsOperational
                            external
                            returns (bool)
    {
        require(!airlines[airAddress].isRegistered, "Airline is already registered.");
        //require(airlines[msg.sender].isRegistered, "Only registered airlines can register new one");
        airlines[airAddress].airlineAddress = airAddress;
        airlines[airAddress].airlineName = airName;
        airlines[airAddress].isRegistered = true;
        airlines[airAddress].isFunded = false;
        emit RegisterAirline(airAddress);
        return true;
    }

   /**
    * @dev Add a flight to the flights queue
    *      Can only be called from FlightSuretyApp contract
    *
    */   
    function registerFlight
                            (
                                address airline,
                                bytes32 flightID,
                                uint256 timeStamp
                            )
                            isCallerAuthorized
                            requireIsOperational
                            external
    {
        require(airlines[airline].isFunded, "Not Funded yet");
        require(!flights[flightID].isRegistered, "Flight is already registered.");
        flights[flightID].airline = airline;
        flights[flightID].updatedTimestamp = timeStamp;
        flights[flightID].statusCode = 0;
        flights[flightID].isRegistered = true;
        emit RegisterFlight(flightID);
    }

   /**
    * @dev Buy insurance for a flight
    *
    */   
    function buy
                            (
                                bytes32 flightID,
                                address passengerID,
                                uint256 recievedinsurence,
                                uint256 timestamp                             
                            )
                            isCallerAuthorized
                            requireIsOperational                            
                            external
                            payable
                            returns(bool)
    {
        require(passenger[passengerID].flightID == flightID, "is not a passenger in this flight");
        require(passenger[passengerID].insuranceStatus == false, "You already bought an insurence for current flight.");
        require(flights[flightID].updatedTimestamp == timestamp, "Different Time Stamp");
        passenger[passengerID].insuranceAmount = recievedinsurence;
        passenger[passengerID].passengerAddress = passengerID;
        passenger[passengerID].insuranceStatus = true;
        passenger[passengerID].isTaken == false;                 // is taken yet or not
        
        // transfer insurance to airline 
        flights[flightID].airline.transfer(recievedinsurence);
        flights[flightID].passAddress.push(passengerID);
        emit Bought(passengerID, flightID, recievedinsurence);
        return true;
    }

    /**
     *  @dev Credits payouts to insurees
    */
    function creditInsurees
                                (
                                    bytes32 flightID,
                                    uint256 amount
                                )
                                external
    {
        //require(contractData.isAirline(_airline), "Airline is not funded");
        //bytes32 fltKey = contractData.getFlightKey(_airline, _flt, _timestamp);
        //require(contractData.isRegisteredFlight(fltKey), "Flight is not registered.");
        //require(msg.value <= 1 ether," more than one ether.");
        //bool success = contractData.buyInsurance.value(msg.value)(fltKey, _passenger, msg.value);

        for (uint i=0; i < flights[flightID].passAddress.length; i++)
        {
            address add =  flights[flightID].passAddress[i];
            uint256 insu = passenger[add].insuranceAmount;
            insu = insu.mul(amount).div(100);
            passenger[add].insuranceAmount = insu;
            //flights[flightID].
        }
        emit Creditted(flightID);

        //return success;


    }
    

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
    function pay
                            (
                                bytes32 flightID,
                                address passengerAddress
                            )
                            external
                            payable
    {
        require(passenger[passengerAddress].flightID == flightID, "is not a passenger in this flight.");
        require(passenger[passengerAddress].insuranceStatus == true, "You didnt bought an insurence for current flight.");
        require(passenger[passengerAddress].isTaken == false, "You already Claimed your insurence.");
        uint amount = passenger[passengerAddress].insuranceAmount;
        
        passenger[passengerAddress].insuranceStatus == true;       // reset insurance status
        passenger[passengerAddress].insuranceAmount = 0;           // reset insurance amount
        passenger[passengerAddress].isTaken == true;               // claimed the insuance
        
        address passengerToTransfer = passenger[passengerAddress].passengerAddress;
        passengerToTransfer.transfer(amount);                      // transfer insurance to passenger

        emit Paid(passengerAddress, amount);
    }

   /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance payouts, the contract should be self-sustaining
    *
    */   
    function fund
                            (
                                address airAddress  
                            )
                            requireIsOperational
                            public
                            payable
    {
        //require(msg.value >= 10 ether, "Inadaquate funds, require more than or equal 10 ether");
        require(airlines[airAddress].isRegistered, "AirLine should be registered before getting funded");
        
        // Get the current fund then add more funds
        //uint256 currentFund = funds[airAddress];
        //currentFund.add(msg.value);
        airAddress.transfer(msg.value);
        funds[airAddress] = funds[airAddress].add(msg.value);
        airlines[airAddress].isFunded = true;
    }

    // A function to change flight status code
    function processFlightStatus
                                (
                                    bytes32 flightID,
                                    uint8 _statusCode
                                )
                                requireIsOperational
                                external
    {
        flights[flightID].statusCode = _statusCode;
    }
    

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    function() 
                            external 
                            payable 
    {
        fund(msg.sender);
    }


}


pragma solidity ^0.4.2;

import "./TokenBTU.sol";

/* Availabilities implementation */
contract ResContract {
    
    address                                 owner;
    TokenBTU                                BTU;
    uint public                             availabilityCount;
    mapping (uint => Availability) public   availabilities;

    enum BookingStatus { AVAILABLE, REQUESTED, REJECTED, CONFIRMED, CANCELLED }
    struct Availability {
        address                 _provider;  // address of the provider
        address                 _booker;    // address of the booker
        uint                    _resourceId ;   // resource id OR bundle id
        uint                    _type;   // Type of Availability
        uint                    _minDeposit ; // minimum BTU deposit for booking this resource
        uint                    _commission ; // commission amount paid to booker in BTU
        uint                    _freeCancelDateTs; // Limit date for a reservation cancellation
        uint                    _startDateTs;   //availability start date timestamps
        uint                    _endDateTs;   //availability end date timestamps
        BookingStatus           _bookingStatus ; // reservation status
        bytes32                 _metaDataLink; //metadatas
    }

    function ResContract() public {
        BTU = new TokenBTU(12000000000000000000, "TokenBTU", "BTU");
    }

    //Submit one availability
    function publishAvailability (uint _type, uint _minDeposit, uint _commission, 
                                  uint _freeCancelDateTs, uint _startDateTs, 
                                  uint _endDateTs, BookingStatus _bookingStatus, bytes32 _metaDataLink)
    public returns (BookingStatus status) 
    {
        availabilities[availabilityCount] = Availability( msg.sender, 0x0, availabilityCount, _type, _minDeposit,
                                                          _commission, _freeCancelDateTs, _startDateTs, _endDateTs,
                                                          _bookingStatus, _metaDataLink);
        availabilityCount++;
        return _bookingStatus;
    }

    //An overview of all availabilities
    function listAvailabilitiesOverview ()
    public constant returns (uint[], address[], address[], 
                             uint[], uint[], BookingStatus[])
    {
        uint[] memory           keys = new uint[](availabilityCount);
        address[] memory        providers = new address[](availabilityCount);
        address[] memory        bookers = new address[](availabilityCount);
        uint[] memory           resourceIds = new uint[](availabilityCount);
        uint[] memory           types = new uint[](availabilityCount);
        uint[] memory           startDateTs = new uint[](availabilityCount);
        uint[] memory           endDateTs = new uint[](availabilityCount);
        BookingStatus[] memory  bookingStatuses = new BookingStatus[](availabilityCount);

        for (uint i = 0 ; i < availabilityCount ; i++) {
            keys[i] = i;
            providers[i] = availabilities[i]._provider;
            bookers[i] = availabilities[i]._booker;
            resourceIds[i] = availabilities[i]._resourceId;
            types[i] = availabilities[i]._type;
            startDateTs[i] = availabilities[i]._startDateTs;
            endDateTs[i] = availabilities[i]._endDateTs;
            bookingStatuses[i] = availabilities[i]._bookingStatus;
        }
        return (keys, providers, bookers,
                resourceIds, types, bookingStatuses);
    }

    //All details from one availability
    function listAvailabilityDetails (uint availabilityNumber)
    public constant returns (uint, uint, uint,
                             uint, BookingStatus, bytes32)
    {
        uint                    minDeposit;
        uint                    commission;
        uint                    freeCancelDateTs;
        BookingStatus           bookingStatus;
        bytes32                 metaDataLink;

        minDeposit = availabilities[availabilityNumber]._minDeposit;
        commission = availabilities[availabilityNumber]._commission;
        freeCancelDateTs = availabilities[availabilityNumber]._freeCancelDateTs;
        bookingStatus = availabilities[availabilityNumber]._bookingStatus;
        metaDataLink = availabilities[availabilityNumber]._metaDataLink;
        return (availabilityNumber, minDeposit, commission, 
                freeCancelDateTs, bookingStatus, metaDataLink);
    }

    //Request reservation
    /* TO-ADD
     * BTU Logic :
     * BTU escrows deposit amount
     */
    function requestAvailability (uint availabilityNumber)
    public returns (BookingStatus)
    {
        if (availabilities[availabilityNumber]._bookingStatus == BookingStatus.AVAILABLE) {
            availabilities[availabilityNumber]._bookingStatus = BookingStatus.REQUESTED;
            availabilities[availabilityNumber]._booker = msg.sender;
        }
        return (availabilities[availabilityNumber]._bookingStatus);
    }

    //reject reservation
    /* TO-ADD
     * BTU Logic :
     * BTU gives deposit amount back to booker
     */
    function rejectAvailability (uint availabilityNumber)
    public returns (BookingStatus)
    {
        if (availabilities[availabilityNumber]._provider == msg.sender) {
            availabilities[availabilityNumber]._bookingStatus = BookingStatus.REJECTED;
        }
        return (availabilities[availabilityNumber]._bookingStatus);
    }

    //confirm reservation
    /* TO-ADD
     * BTU Logic :
     * BTU escrows deposit amount 
     */
    function confirmAvailability (uint availabilityNumber)
    public returns (BookingStatus)
    {
        if (availabilities[availabilityNumber]._provider == msg.sender) {
            availabilities[availabilityNumber]._bookingStatus = BookingStatus.CONFIRMED;
        }
        return (availabilities[availabilityNumber]._bookingStatus);
    }

    //cancel reservation
    /* TO-ADD
     * BTU Logic :
     * IF BEFORE CANCEL DATE : BTU gives back deposit amount to booker
     * IF AFTER CANCEL DATE : BTU gives back deposit amount to provider
     */
    function cancelAvailability (uint availabilityNumber)
    public returns (BookingStatus)
    {
        if (availabilities[availabilityNumber]._provider == msg.sender) {
            availabilities[availabilityNumber]._bookingStatus = BookingStatus.CANCELLED;
        }
        return (availabilities[availabilityNumber]._bookingStatus);
    }

    //Update reservation
    function updateAvailability (uint availabilityNumber, uint _type, uint _minDeposit, uint _commission, 
                                 uint _freeCancelDateTs, uint _startDateTs, 
                                 uint _endDateTs, BookingStatus _bookingStatus, bytes32 _metaDataLink)
    public returns (bool status) 
    {
        if (availabilities[availabilityNumber]._provider == msg.sender) {
            availabilities[availabilityNumber]._type = _type;
            availabilities[availabilityNumber]._minDeposit = _minDeposit;
            availabilities[availabilityNumber]._commission = _commission;
            availabilities[availabilityNumber]._freeCancelDateTs = _freeCancelDateTs;
            availabilities[availabilityNumber]._startDateTs = _startDateTs;
            availabilities[availabilityNumber]._endDateTs = _endDateTs;
            availabilities[availabilityNumber]._bookingStatus = _bookingStatus;
            availabilities[availabilityNumber]._metaDataLink = _metaDataLink;
            return true;
        }
        return false;
    }
}
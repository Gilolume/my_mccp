pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ResContract.sol";
import "../contracts/TokenBTU.sol";

contract ResContractTest {
    ResContract resContract;

  function ResContractTest() public {
     resContract = new ResContract(DeployedAddresses.TokenBTU());
  }

  function testPublishAvailability() public {

    resContract.publishAvailability(0, 15, 5, 0, 0, 0, ResContract.BookingStatus.REQUESTED, "metadata");
    Assert.equal(resContract.getAvailabilityCount(), 1, "Error");
  }

  function testListAvailabilityDetails() public {

      uint                      availabilityNumber;
      uint                      minDeposit;
      uint                      commission;
      uint                      freeCancelDateTs;
      ResContract.BookingStatus bookingStatus;
      bytes32                   metaDataLink;

      (availabilityNumber, minDeposit, commission, freeCancelDateTs, bookingStatus, metaDataLink) = resContract.listAvailabilityDetails(0);

      Assert.equal(availabilityNumber, 0, "Wrong deposit amount");
      Assert.equal(minDeposit, 15, "Wrong deposit amount");
      Assert.equal(commission, 5, "Wrong commission");
      Assert.equal(freeCancelDateTs, 0, "Wrong free cancel date");
      Assert.equal(metaDataLink, "metadata", "Wrong deposit amount");
  }

  function testConfirmedAvailability() public {

      if ( resContract.confirmAvailability(0) ==  ResContract.BookingStatus.CONFIRMED )
        Assert.equal(uint(1), uint(1), "Availability");
      else
        Assert.equal(uint(1), uint(2), "Availability not confirmed");
    }

    function TestRejectAvailability() public {
        if (resContract.rejectAvailability(0) == ResContract.BookingStatus.REJECTED)
        Assert.equal(uint(1), uint(1), "Availability");
      else
        Assert.equal(uint(1), uint(2), "Availability not rejected");
    }

    function TestCancelAvailability() public {
        if (resContract.cancelAvailability(0) == ResContract.BookingStatus.CANCELLED)
        Assert.equal(uint(1), uint(1), "Availability");
      else
        Assert.equal(uint(1), uint(2), "Availability not cancelled");
    }

}
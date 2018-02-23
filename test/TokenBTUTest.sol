pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TokenBTU.sol";
import "../contracts/ResContract.sol";

contract TokenBTUTest {
 address adr;


 function testInitialBalanceUsingDeployedContract() public {

    adr = 0x5f14440a33f7216aafec7a271781ca6f6fc31341;
    TokenBTU tokenBTU = TokenBTU(DeployedAddresses.TokenBTU());
    Assert.equal(tokenBTU.totalSupply(), 12000000000000000000000000000000000000, "Owner should have TokenBTU initially");

  }

  function testInitialBalanceWithNewTokenBTU() public {

    TokenBTU tokenBTU = new TokenBTU(12000000000000000000, "TokenBTU", "BTU");
    Assert.equal(tokenBTU.totalSupply(), 12000000000000000000000000000000000000, "Owner should have TokenBTU initially");

  }

  function testTransferBTU() public {

    uint256 test = 250;
    TokenBTU tokenBTU = new TokenBTU(12000000000000000000, "TokenBTU", "BTU");

    tokenBTU.transfer(adr, test);
    Assert.equal(tokenBTU.getMyAddressBalance(), 12000000000000000000000000000000000000 - test, "Owner should have TokenBTU initially");

  }

  function testEscrowAmount() public {

      uint256 test = 250;
      TokenBTU tokenBTU = new TokenBTU(12000000000000000000, "TokenBTU", "BTU");
      tokenBTU.transfer(adr, test);

      uint commission = 5;
      uint minDeposit = 15;

      ResContract resContract = new ResContract(DeployedAddresses.TokenBTU());
      resContract.publishAvailability(0, minDeposit, commission, 0, 0, 0, ResContract.BookingStatus.REQUESTED, "metadata");

      bool escr = tokenBTU.escrowAmount(0, adr, msg.sender, minDeposit, commission);

      Assert.equal(escr, true, "Ecrow fail, the booker di not have enough TokenBTU");
  }

}
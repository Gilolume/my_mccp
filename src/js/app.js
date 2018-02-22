App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    // TODO: refactor conditional
    if (typeof web3 !== 'undefined') {
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
      web3 = new Web3(App.web3Provider);
    }
    return App.initContract();
  },

  initContract: function() {
    $.getJSON("ResContract.json", function(rescontract) {
      // Instantiate a new truffle contract from the artifact
      App.contracts.ResContract = TruffleContract(rescontract);
      // Connect provider to interact with contract
      App.contracts.ResContract.setProvider(App.web3Provider);

      $.getJSON("TokenBTU.json", function(tokenbtui) {
        // Instantiate a new truffle contract from the artifact
        App.contracts.TokenBTU = TruffleContract(tokenbtui);
        // Connect provider to interact with contract
        App.contracts.TokenBTU.setProvider(App.web3Provider);
  
        //App.listenForEvents();
  
        return App.render();
      });
      
    });
  },

  render: function() {
    var resContractInstance;


    // Load account data
    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        $("#accountAddress").html("Your Account: " + account);
      }
    });

    // Load account balance
    App.contracts.TokenBTU.deployed().then(function(instance) {
      return instance.getMyAddressBalance();
    }).then(function(addressBalance) {
      $("#accountAddress").html("Your balance: " + addressBalance);
    })


    // Load contract data
    App.contracts.ResContract.deployed().then(function(instance) {
      resContractInstance = instance;
      return resContractInstance.availabilityCount();
    }).then(function(availabilityCount) {
      var availabilities = $("#availabilities");
      availabilities.empty();

      var availabilitiesRequest = $('#availabilitiesRequest');
      availabilitiesRequest.empty();


      for (var i = 0; i < availabilityCount; i++) {
        resContractInstance.availabilities(i).then(function(availabilitie) {
          var resourceId = availabilitie[2];
          var type = availabilitie[3];
          var minDeposit = availabilitie[4];
          var commission = availabilitie[5];
          var freeCancelDateTs = availabilitie[6];
          var startDateTs = availabilitie[7];
          var endDateTs = availabilitie[8];
          var bookingStatus = availabilitie[9];
          var metaDataLink = availabilitie[10];

          // Render availabiliies Result
          var availabilitieTemplate = "<tr>"+
            "<th>" + resourceId + "</th>"+
            "<th>" + web3.toAscii(metaDataLink) + "</th>"+
            "<th>" + App.getStringType(type) + "</th>"+
            "<td>" + App.getDateFromTimestamp(parseInt(startDateTs)) + "</td>"+
            "<td>" + App.getDateFromTimestamp(parseInt(endDateTs)) + "</td>"+
            "<th>" + minDeposit + "</th>"+
            "<th>" + commission + "</th>"+
            "<th>" + App.getDateFromTimestamp(parseInt(freeCancelDateTs)) + "</th>"+
            "<th>" + App.getStringBookingStatus(bookingStatus) + "</th>"+
          "</tr>"
          availabilities.append(availabilitieTemplate);

          // Render availabilities ballot option
          var availabilitieOption = "<option value='" + resourceId + "' >" + resourceId + " : " + web3.toAscii(metaDataLink) + "</ option>"
          availabilitiesRequest.append(availabilitieOption);
        });
      }
    })
  },

  getStringType: function(type) {
    var stringType = "Other";
    if (type == 0) { stringType = "Hotel"; }
    if (type == 1) { stringType = "Appartement"; }
    if (type == 2) { stringType = "Maison"; }
    if (type == 3) { stringType = "Cabane"; }
    if (type == 4) { stringType = "Bateau"; }
    if (type == 5) { stringType = "Voiture"; }
    return stringType;
  },

  getStringBookingStatus: function(bookingStatus) {
    var stringBookingStatus = "Other";
    if (bookingStatus.c[0] == 0) { stringBookingStatus = "AVAILABLE"; }
    if (bookingStatus.c[0] == 1) { stringBookingStatus = "REQUESTED"; }
    if (bookingStatus.c[0] == 2) { stringBookingStatus = "REJECTED"; }
    if (bookingStatus.c[0] == 3) { stringBookingStatus = "CONFIRMED"; }
    if (bookingStatus.c[0] == 4) { stringBookingStatus = "CANCELLED"; }
    return stringBookingStatus;
  },

  getDateFromTimestamp: function(timestamp) {
    var date = new Date(timestamp)
    var day = String(date.getDate());
    var month = String((date.getMonth() + 1));
    var year = String(date.getFullYear());

    if (day.length < 2) day = '0' + day;
    if (month.length < 2) month = '0' + month;

    var d = [day, month, year].join('-');

    return d;
  },

  getTimestampFromDate: function(date) {
    var myDate = new Date(date).getTime()
    return myDate
  },

  addAvailability: function() {

    //  resContractInstance.publishAvailability(type, minDeposit, commission, freeCancelDate, startDate, endDate, bookingStatus, name);

    console.log(App.contracts.ResContract);
    
    var name = $('#name').val();
    var type = $('#type').val();
    var minDeposit = $('#minDeposit').val();
    var commission = $('#commission').val();
    var freeCancelDate = App.getTimestampFromDate($('#freeCancelDate').val());
    var startDate =App.getTimestampFromDate($('#startDate').val());
    var endDate = App.getTimestampFromDate($('#endDate').val());
    var bookingStatus = 0;

    App.contracts.ResContract.deployed().then(function(instance) {
      resContractInstance = instance;
      return resContractInstance;
    }).then(function(resContractInstance) {
      resContractInstance.publishAvailability(type, minDeposit, commission, freeCancelDate, startDate, endDate, bookingStatus, name);
    })

  },

  castBuyBTU: function() {
    var btuAmount = $('#btuAmount').val();
    App.contracts.TokenBTU.deployed().then(function(instance) {
      return instance.buyBTU(btuAmount, { from: App.account });
    })
  },
  castRequestReservation: function() {
    var resquestId = $('#availabilitiesRequest').val();
    App.contracts.ResContract.deployed().then(function(instance) {
      return instance.requestAvailability(resquestId, { from: App.account });
    })
  },
  castConfirmReservation: function() {
    var resquestId = $('#availabilitiesRequest').val();
    App.contracts.ResContract.deployed().then(function(instance) {
      return instance.confirmAvailability(resquestId, { from: App.account });
    })
  },
  castCancelReservation: function() {
    var resquestId = $('#availabilitiesRequest').val();
    App.contracts.ResContract.deployed().then(function(instance) {
      return instance.cancelAvailability(resquestId, { from: App.account });
    })
  },
  castRejectReservation: function() {
    var resquestId = $('#availabilitiesRequest').val();
    App.contracts.ResContract.deployed().then(function(instance) {
      return instance.rejectAvailability(resquestId, { from: App.account });
    })
  },

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});

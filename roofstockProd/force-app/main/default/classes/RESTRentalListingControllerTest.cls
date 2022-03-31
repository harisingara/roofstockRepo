@isTest
public class RESTRentalListingControllerTest {
    private static Id leasingAccountRecordTypeId;
    private static Id leasingContactRecordTypeId;
  
    private static final string userAlias = 'SLUSER1';
    private static final string RB_LEASING = 'Leasing';
  
    //static initialization code (load test data)
    static {
      //create test users
      TestDataFactory.insertHierarchyCustomSettingData();
      TestDataFactory.createTestLeasingUserRecords(1);
      TestDataFactory.createTestPropertyUnitRecords(5);
  
      //load record type info
      leasingAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(RB_LEASING)
        .getRecordTypeId();
      leasingContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get(RB_LEASING)
        .getRecordTypeId();
    }
    static testMethod void createRentalListing() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        System.debug('user' + u1);
    
        Property_Unit__c unit1 = [SELECT Id FROM Property_Unit__c LIMIT 1];
    
    
        List<RESTRentalListingHelper.RentalListingWrapper> rentalListingList = new List<RESTRentalListingHelper.RentalListingWrapper>();
        RESTRentalListingHelper.RentalListingWrapper listing = new RESTRentalListingHelper.RentalListingWrapper();
        listing.unitId = unit1.Id;
        listing.currentRent = 1200;
        listing.rentalListingId = '10264';

        listing.accessEndDate = date.today();
        listing.accessStartDate = date.today();
        listing.agentInactiveDate = date.today();
        listing.agentShowingDate = date.today();
        listing.autoShowingDate = date.today();
        listing.availableDate = date.today();
        listing.depositAmount = 600;
        listing.description = '';
        listing.headline = 'Beautiful newly renovated 4 Bedroom in Florida!';
        listing.holdUntilDate = date.today();
        listing.inactiveDate = date.today();
        listing.isAllowCat = true;
        listing.isAllowDog = true;
        listing.lbAssignedDate = date.today();
        listing.lbUnassignDate = date.today();
        listing.lockboxSerialNumber = 12345;
        listing.marketDate = date.today();
        listing.moveInMoveOutType = '';
        listing.name = '5106 Ensign Ave, Jacksonville, FL 32244';
        listing.preleaseDate = date.today();
        listing.preshowDate = date.today();
        listing.previousRent = 1195;
        listing.rentCafeUrl = '';
        listing.rentReadyDate = date.today();
        listing.rentUpdatedAt = date.today();
        listing.rentlyRawHash = '';
        listing.squareFeet = 1344;
        listing.status = 'Auto Showing';
        listing.summary = '3BD | 2BA | $1,195 /mo | Cats OK | Dogs OK | 1344.00 sq ft';
        listing.vacantDate = date.today();
        listing.yardiRawHash = '';
        //RC-11384
        listing.previousLeasePrice = 100;
        listing.initialListPrice = 100;
        listing.incentiveAmount = 100;
        listing.incentiveDuration = '1';
        listing.readyDate = Date.today();
        listing.listDate = Date.today();
        listing.moveInDate = Date.today();
        listing.leasedDate = Date.today();
        listing.rentlyWaitlist = 100;

        rentalListingList.add(listing);
    
        RESTRentalListingHelper.PostResponse createResponse = RESTRentalListingHelper.AddRentalListing(
            rentalListingList
        );
        string res = createResponse.responseBody.rentalListingResponse[0].rsId;
        system.assertEquals(res, '10264');
    
    }

    static testMethod void createRentalListingRestAPITest() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        System.debug('user' + u1);
        
        Property_Unit__c unit1 = [SELECT Id FROM Property_Unit__c LIMIT 1];
        
        // String sReq = '{ "leasingActivityList": [ { "email": "dupe200@gmail.com", "firstName": "Dupe1", "lastName": "Dupe1", "phone": "2002002000", "activityType": "email", "activityId": "17047", "timeStamp": "2020-02-06T21:53:16.403Z", "timeZone": "Central Time (US & Canada)", "source": "RENTCafe.com ILS", "feedback":"Anamika is awesome developer!", "listingId": "13922" } ] }';
        List<RESTRentalListingHelper.RentalListingWrapper> requestList = new List<RESTRentalListingHelper.RentalListingWrapper>();
        RESTRentalListingHelper.RentalListingWrapper listing = new RESTRentalListingHelper.RentalListingWrapper();

        listing.unitId = unit1.Id;
        listing.currentRent = 1200;
        listing.rentalListingId = '10264';

        listing.accessEndDate = date.today();
        listing.accessStartDate = date.today();
        listing.agentInactiveDate = date.today();
        listing.agentShowingDate = date.today();
        listing.autoShowingDate = date.today();
        listing.availableDate = date.today();
        listing.depositAmount = 600;
        listing.description = '';
        listing.headline = 'Beautiful newly renovated 4 Bedroom in Florida!';
        listing.holdUntilDate = date.today();
        listing.inactiveDate = date.today();
        listing.isAllowCat = true;
        listing.isAllowDog = true;
        listing.lbAssignedDate = date.today();
        listing.lbUnassignDate = date.today();
        listing.lockboxSerialNumber = 12345;
        listing.marketDate = date.today();
        listing.moveInMoveOutType = '';
        listing.name = '5106 Ensign Ave, Jacksonville, FL 32244';
        listing.preleaseDate = date.today();
        listing.preshowDate = date.today();
        listing.previousRent = 1195;
        listing.rentCafeUrl = '';
        listing.rentReadyDate = date.today();
        listing.rentUpdatedAt = date.today();
        listing.rentlyRawHash = '';
        listing.squareFeet = 1344;
        listing.status = 'Auto Showing';
        listing.summary = '3BD | 2BA | $1,195 /mo | Cats OK | Dogs OK | 1344.00 sq ft';
        listing.vacantDate = date.today();
        listing.yardiRawHash = '';
        
        //RC-11384
        listing.previousLeasePrice = 100;
        listing.initialListPrice = 100;
        listing.incentiveAmount = 100;
        listing.incentiveDuration = '1';
        listing.readyDate = Date.today();
        listing.listDate = Date.today();
        listing.moveInDate = Date.today();
        listing.leasedDate = Date.today();
        listing.rentlyWaitlist = 100;
        
		RESTRentalListingHelper.RentalListingData oWrap = new RESTRentalListingHelper.RentalListingData();
        
        requestList.add(listing);
        oWrap.rentalListingList = requestList;
    
        String sReq = JSON.serialize(oWrap);
    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/AddRentalListing';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
    
        System.runAs(u1) {
          Test.startTest();
    
          RESTRentalListingController.addRentalListing();
          Test.stopTest();
          List<Rental_Listing__c> oListings = [
            SELECT id, Rental_Listing_Id__c
            FROM Rental_Listing__c
            LIMIT 10
          ];
          //System.debug('listings' + oListings[0]);
         // system.assertEquals(oListings.size(), 1);
        //  system.assertEquals(oListings[0].Rental_Listing_Id__c, '10264');
    
          //system.assertEquals(res.responseBody.toString(), 'Success');
 
          System.debug('statusCode ' + res.statusCode);   
          system.assertEquals(res.statusCode, 200);
        }
    }
    static testMethod void testErrorRestAPITest() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        System.debug('user' + u1);
        
        Property_Unit__c unit1 = [SELECT Id FROM Property_Unit__c LIMIT 1];
        
        // String sReq = '{ "leasingActivityList": [ { "email": "dupe200@gmail.com", "firstName": "Dupe1", "lastName": "Dupe1", "phone": "2002002000", "activityType": "email", "activityId": "17047", "timeStamp": "2020-02-06T21:53:16.403Z", "timeZone": "Central Time (US & Canada)", "source": "RENTCafe.com ILS", "feedback":"Anamika is awesome developer!", "listingId": "13922" } ] }';
        List<RESTRentalListingHelper.RentalListingWrapper> requestList = new List<RESTRentalListingHelper.RentalListingWrapper>();
        RESTRentalListingHelper.RentalListingWrapper listing = new RESTRentalListingHelper.RentalListingWrapper();

        listing.unitId = unit1.Id;
        listing.currentRent = 1200;
        listing.rentalListingId = '10264';

        listing.accessEndDate = date.today();
        listing.accessStartDate = date.today();
        listing.agentInactiveDate = date.today();
        listing.agentShowingDate = date.today();
        listing.autoShowingDate = date.today();
        listing.availableDate = date.today();
        listing.depositAmount = 600;
        listing.description = '';
        listing.headline = 'Beautiful newly renovated 4 Bedroom in Florida!';
        listing.holdUntilDate = date.today();
        listing.inactiveDate = date.today();
        listing.isAllowCat = true;
        listing.isAllowDog = true;
        listing.lbAssignedDate = date.today();
        listing.lbUnassignDate = date.today();
        listing.lockboxSerialNumber = 12345;
        listing.marketDate = date.today();
        listing.moveInMoveOutType = '';
        listing.name = '5106 Ensign Ave, Jacksonville, FL 32244';
        listing.preleaseDate = date.today();
        listing.preshowDate = date.today();
        listing.previousRent = 1195;
        listing.rentCafeUrl = '';
        listing.rentReadyDate = date.today();
        listing.rentUpdatedAt = date.today();
        listing.rentlyRawHash = '';
        listing.squareFeet = 1344;
        listing.status = 'Auto Showing';
        listing.summary = '3BD | 2BA | $1,195 /mo | Cats OK | Dogs OK | 1344.00 sq ft';
        listing.vacantDate = date.today();
        listing.yardiRawHash = '';
        //RC-11384
        listing.previousLeasePrice = 100;
        listing.initialListPrice = 100;
        listing.incentiveAmount = 100;
        listing.incentiveDuration = '1';
        listing.readyDate = Date.today();
        listing.listDate = Date.today();
        listing.moveInDate = Date.today();
        listing.leasedDate = Date.today();
        listing.rentlyWaitlist = 100;
		RESTRentalListingHelper.RentalListingData oWrap = new RESTRentalListingHelper.RentalListingData();
        
        requestList.add(listing);
        oWrap.rentalListingList = requestList;
    
        String sReq = JSON.serialize(oWrap);
    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/AddRentalListing';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        RestContext.response = res;
    
        System.runAs(u1) {
          Test.startTest();
    
          RESTRentalListingController.addRentalListing();
          Test.stopTest();
          
          system.assertEquals(res.statusCode, 500);
        }
    }
}
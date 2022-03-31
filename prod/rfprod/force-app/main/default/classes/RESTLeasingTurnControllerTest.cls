@isTest
public class RESTLeasingTurnControllerTest {
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
    static testMethod void createTurn() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        System.debug('user' + u1);
        Id amPropertyRecordTypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByName()
            .get('Asset Management')
            .getRecordTypeId();
        
        Property2__c p = new Property2__c();
            p.Market__c = 'Atlanta';
            p.PropertyCode__c = 'q1000';
            p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
            p.Property_Type__c = 'Single Family';
            p.Year_Built__c = '1972';
            p.name = '123 Main St Tracy CA 95391';
            p.recordtypeid = amPropertyRecordTypeId;
        insert p;
        Property_Unit__c pu = new Property_Unit__c();
            pu.name = '123 Main St Tracy CA 95391';
            pu.Property__c = p.id;
            pu.Bathrooms__c = 3;
            pu.Bedrooms__c = 2.5;
            pu.HomeCode__c = 'q20001';
        insert pu;
        
    
       // Property_Unit__c unit1 = [SELECT Id FROM Property_Unit__c LIMIT 1];
    
    
        List<RESTLeasingTurnHelper.LeasingTurnRequest> turnList = new List<RESTLeasingTurnHelper.LeasingTurnRequest>();
        RESTLeasingTurnHelper.LeasingTurnRequest turn = new RESTLeasingTurnHelper.LeasingTurnRequest();
        turn.homeCode = 'q20001';
        turn.turnId = 1234;
        turn.tenantStatus = 'Evicted';
        turn.isCompleted = false;
        turn.yardiReadyDate = system.now().date();
        turn.moveOutDate = system.now().date() + 1;

        turnList.add(turn);
    
        RESTLeasingTurnHelper.PostResponse createResponse = RESTLeasingTurnHelper.UpdateTurn(
            turnList
        );
  
        system.assertNotEquals(null, createResponse.responseBody);
    
    }

    static testMethod void createLeasingTurnRestAPITest() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        System.debug('user' + u1);
       // TestDataFactory.insertHierarchyCustomSettingData();
        Property_Unit__c unit1 = [SELECT Id FROM Property_Unit__c LIMIT 1];
        
        // String sReq = '{ "leasingActivityList": [ { "email": "dupe200@gmail.com", "firstName": "Dupe1", "lastName": "Dupe1", "phone": "2002002000", "activityType": "email", "activityId": "17047", "timeStamp": "2020-02-06T21:53:16.403Z", "timeZone": "Central Time (US & Canada)", "source": "RENTCafe.com ILS", "feedback":"Anamika is awesome developer!", "listingId": "13922" } ] }';
        List<RESTLeasingTurnHelper.LeasingTurnRequest> requestList = new List<RESTLeasingTurnHelper.LeasingTurnRequest>();
        RESTLeasingTurnHelper.LeasingTurnRequest turn = new RESTLeasingTurnHelper.LeasingTurnRequest();

        turn.homeCode = 'q20001';
        turn.turnId = 1234;
        turn.tenantStatus = 'Evicted';
        turn.isCompleted = false;
        turn.yardiReadyDate = system.now().date();
        turn.moveOutDate = system.now().date() + 1;

        requestList.add(turn);
        RESTLeasingTurnHelper.LeasingTurnData oReqData = new RESTLeasingTurnHelper.LeasingTurnData(); 
        oReqData.turnsList = requestList;
        String sReq = JSON.serialize(oReqData);
    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/updateturn';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
    
        System.runAs(u1) {
          Test.startTest();
    
          RESTLeasingTurnController.updateTurn();
          Test.stopTest();
          List<turn__c> oTurns = [
            SELECT id, BPM_Turn_Id__c
            FROM turn__c
            LIMIT 1
          ];
          
    

          req.requestBody = Blob.valueOf('sReq');
          RESTLeasingTurnController.updateTurn();  
          system.assertEquals(res.statusCode, 500);
        }
    }
    static testMethod void updateLeasingTurnRestAPITest() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        System.debug('user' + u1);
       // TestDataFactory.insertHierarchyCustomSettingData();
        Property_Unit__c unit1 = [SELECT Id FROM Property_Unit__c LIMIT 1];
        Turn__c trn = new Turn__c();
        trn.Property_Unit__c = unit1.Id;
        trn.Name = 'Turn';
        trn.BPM_Turn_Id__c = 1234;
        insert trn;
        
        // String sReq = '{ "leasingActivityList": [ { "email": "dupe200@gmail.com", "firstName": "Dupe1", "lastName": "Dupe1", "phone": "2002002000", "activityType": "email", "activityId": "17047", "timeStamp": "2020-02-06T21:53:16.403Z", "timeZone": "Central Time (US & Canada)", "source": "RENTCafe.com ILS", "feedback":"Anamika is awesome developer!", "listingId": "13922" } ] }';
        List<RESTLeasingTurnHelper.LeasingTurnRequest> requestList = new List<RESTLeasingTurnHelper.LeasingTurnRequest>();
        RESTLeasingTurnHelper.LeasingTurnRequest turn = new RESTLeasingTurnHelper.LeasingTurnRequest();

        turn.homeCode = 'q20001';
        turn.turnId = 1234;
        turn.tenantStatus = 'Evicted';
        turn.isCompleted = false;
        turn.yardiReadyDate = system.now().date();
        turn.moveOutDate = system.now().date() + 1;

        requestList.add(turn);
        RESTLeasingTurnHelper.LeasingTurnData oReqData = new RESTLeasingTurnHelper.LeasingTurnData(); 
        oReqData.turnsList = requestList;
        String sReq = JSON.serialize(oReqData);
    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/updateturn';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
    
        System.runAs(u1) {
          Test.startTest();
    
          RESTLeasingTurnController.updateTurn();
          Test.stopTest();
          List<turn__c> oTurns = [
            SELECT id, BPM_Turn_Id__c
            FROM turn__c
            LIMIT 1
          ];
          System.debug('listings' + oTurns[0]);
          system.assertEquals(oTurns.size(), 1);
          system.assertEquals(oTurns[0].BPM_Turn_Id__c, 1234);
    
          //system.assertEquals(res.responseBody.toString(), 'Success');
 
          System.debug('statusCode ' + res.statusCode);   
          system.assertEquals(res.statusCode, 200);
          req.requestBody = Blob.valueOf('sReq');
          RESTLeasingTurnController.updateTurn();  
          system.assertEquals(res.statusCode, 500);
        }
    }

    static testMethod void updateCompletedLeasingTurnRestAPITest() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        System.debug('user' + u1);
       // TestDataFactory.insertHierarchyCustomSettingData();
        Property_Unit__c unit1 = [SELECT Id FROM Property_Unit__c LIMIT 1];
        Turn__c trn = new Turn__c();
        trn.Property_Unit__c = unit1.Id;
        trn.Name = 'Turn';
        trn.Completed__c = true;
        trn.Status__c = 'Completed';
        trn.BPM_Turn_Id__c = 1234;
        insert trn;
        
        // String sReq = '{ "leasingActivityList": [ { "email": "dupe200@gmail.com", "firstName": "Dupe1", "lastName": "Dupe1", "phone": "2002002000", "activityType": "email", "activityId": "17047", "timeStamp": "2020-02-06T21:53:16.403Z", "timeZone": "Central Time (US & Canada)", "source": "RENTCafe.com ILS", "feedback":"Anamika is awesome developer!", "listingId": "13922" } ] }';
        List<RESTLeasingTurnHelper.LeasingTurnRequest> requestList = new List<RESTLeasingTurnHelper.LeasingTurnRequest>();
        RESTLeasingTurnHelper.LeasingTurnRequest turn = new RESTLeasingTurnHelper.LeasingTurnRequest();

        turn.homeCode = 'q20001';
        turn.turnId = 1234;
        turn.tenantStatus = 'Evicted';
        turn.isCompleted = false;
        turn.yardiReadyDate = system.now().date();
        turn.moveOutDate = system.now().date() + 1;

        requestList.add(turn);
        RESTLeasingTurnHelper.LeasingTurnData oReqData = new RESTLeasingTurnHelper.LeasingTurnData(); 
        oReqData.turnsList = requestList;
        String sReq = JSON.serialize(oReqData);
    
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/updateturn';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
    
        System.runAs(u1) {
          Test.startTest();
    
          RESTLeasingTurnController.updateTurn();
          Test.stopTest();
          List<turn__c> oTurns = [
            SELECT id, BPM_Turn_Id__c
            FROM turn__c
            LIMIT 1
          ];
          System.debug('listings' + oTurns[0]);
          //system.assertEquals(oTurns.size(), 1);
        //  system.assertEquals(oTurns[0].BPM_Turn_Id__c, 1234);
    
          //system.assertEquals(res.responseBody.toString(), 'Success');
 
          System.debug('statusCode ' + res.statusCode);   
          //system.assertEquals(res.statusCode, 200);
          req.requestBody = Blob.valueOf('sReq');
          RESTLeasingTurnController.updateTurn();  
         // system.assertEquals(res.statusCode, 500);
        }
    }
}
@isTest
public class RESTLeasingActivityControllerTest {
    private static Id leasingAccountRecordTypeId;
    private static Id leasingContactRecordTypeId;
    private static Id leasingOpportunityRecordTypeId;
    private static Id leasingLeadRecordTypeId;
    
    private static final string userAlias = 'SLUSER1';
    private static final string RB_LEASING = 'Leasing';
    
    //static initialization code (load test data)
    static {
        //create test users
        
        TestDataFactory.insertHierarchyCustomSettingData(); 
        TestDataFactory.createTestLeasingUserRecords(1);
        TestDataFactory.createTestLeasingListingRecords(5); 
        
        //load record type info
        leasingAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(RB_LEASING)
            .getRecordTypeId();
        leasingContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
            .get(RB_LEASING)
            .getRecordTypeId();
        leasingOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
            .get(RB_LEASING)
            .getRecordTypeId();
        leasingLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
            .get(RB_LEASING)
            .getRecordTypeId();
    }
    
    static testMethod void createLeasingORU() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        System.debug('user' + u1);
        Id leasingLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Leasing').getRecordTypeId();
        Lead l = new Lead();
        l.LastNAme ='sfdc';
        l.Email = 'testuser123@gmail.com';
        l.Company = 'Salesforce';
        l.RecordTypeId = leasingLeadRecordTypeId;
        insert l;
        List<RESTLeasingActivityHelper.LeasingActivityWrapper> leasingActivityList = new List<RESTLeasingActivityHelper.LeasingActivityWrapper>();
        RESTLeasingActivityHelper.LeasingActivityWrapper activity = new RESTLeasingActivityHelper.LeasingActivityWrapper();
        activity.email = 'testuser123@gmail.com';
        activity.firstName = 'Test';
        activity.lastName = 'User';
        activity.phone = '5103448876';
        activity.activityType = 'application_started';
        activity.activityId = '17047';
        activity.timeStamp = system.now();
        activity.timeZone = 'Central Time (US & Canada)';
        activity.source = 'RENTCafe.com ILS';
        activity.feedback = null;
        activity.listingId = '139221';
        activity.transferredToListingId = '12345';
        leasingActivityList.add(activity);
        
        List<RESTLeasingActivityHelper.LeasingActivityResponse> response = RESTLeasingActivityHelper.AddLeasingActivity(
            leasingActivityList
        );
        system.assertEquals(response.size(), 1);
    }
    static testMethod void createLeasingRestAPITest() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        Id leasingLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Leasing').getRecordTypeId();
        Id leasingContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Leasing').getRecordTypeId();

        Lead l = new Lead();
        l.LastNAme ='sfdc';
        l.Phone = '5103448876';
        l.Company = 'Salesforce';
        l.RecordTypeId = leasingLeadRecordTypeId;
        insert l;
        
        contact con = new Contact();
        con.LastName = 'Salesforce';
        con.Email = 'testuser123@gmail.com';
        con.RecordTypeId = leasingContactRecordTypeId;
        insert con;
        
        System.debug('user' + u1);
        // String sReq = '{ "leasingActivityList": [ { "email": "dupe200@gmail.com", "firstName": "Dupe1", "lastName": "Dupe1", "phone": "2002002000", "activityType": "email", "activityId": "17047", "timeStamp": "2020-02-06T21:53:16.403Z", "timeZone": "Central Time (US & Canada)", "source": "RENTCafe.com ILS", "feedback":"Anamika is awesome developer!", "listingId": "13922" } ] }';
        List<RESTLeasingActivityHelper.LeasingActivityWrapper> requestList = new List<RESTLeasingActivityHelper.LeasingActivityWrapper>();
        RESTLeasingActivityHelper.LeasingActivityWrapper activity = new RESTLeasingActivityHelper.LeasingActivityWrapper();
        RESTLeasingActivityHelper.LeasingActivityData oDataReq = new RESTLeasingActivityHelper.LeasingActivityData ();
        activity.email = 'testuser123@gmail.com';
        activity.firstName = 'Test';
        activity.lastName = 'User';
        activity.phone = '5103448876';
        activity.activityType = 'application_started';
        activity.activityId = '17047';
        activity.timeStamp = system.now();
        activity.timeZone = 'Central Time (US & Canada)';
        activity.source = 'RENTCafe.com ILS';
        activity.feedback = null;
        activity.listingId = '139221';
        requestList.add(activity);
        oDataReq.leasingActivityList = requestList; 
        String sReq = JSON.serialize(oDataReq);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/AddLeasingActivity';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        
        System.runAs(u1) {
            Test.startTest();
            
            RESTLeasingActivityController.addLeasingActivityRecord();
            Test.stopTest();
            List<Opportunity_Rental_Unit_Activity__c> oRUAs = [
                SELECT id, Activity_Code__c
                FROM Opportunity_Rental_Unit_Activity__c
                LIMIT 10
            ];
            //System.debug('activities' + oRUAs[0]);
            //system.assertEquals(oRUAs.size(), 1);
            //system.assertEquals(oRUAs[0].Activity_Code__c, 'application_started');
            
            // system.assertEquals(res.responseBody.size(), 1);
            
            //system.assertEquals(res.statusCode, 200);
        }
    }
    static testMethod void createLeasingLeadTest() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        Lead l = new Lead();
        l.LastNAme ='sfdc';
        l.Email = 'leaduser123@gmail.com';
        l.Company = 'Salesforce';
        insert l;
        System.debug('user' + u1);
        // String sReq = '{ "leasingActivityList": [ { "email": "dupe200@gmail.com", "firstName": "Dupe1", "lastName": "Dupe1", "phone": "2002002000", "activityType": "email", "activityId": "17047", "timeStamp": "2020-02-06T21:53:16.403Z", "timeZone": "Central Time (US & Canada)", "source": "RENTCafe.com ILS", "feedback":"Anamika is awesome developer!", "listingId": "13922" } ] }';
        List<RESTLeasingActivityHelper.LeasingActivityWrapper> requestList = new List<RESTLeasingActivityHelper.LeasingActivityWrapper>();
        RESTLeasingActivityHelper.LeasingActivityWrapper activity = new RESTLeasingActivityHelper.LeasingActivityWrapper();
        RESTLeasingActivityHelper.LeasingActivityData oDataReq = new RESTLeasingActivityHelper.LeasingActivityData ();
        activity.email = 'leaduser123@gmail.com';
        activity.firstName = 'Lead';
        activity.lastName = 'User';
        activity.phone = '5101231234';
        activity.activityType = 'phone_inquiry';
        activity.activityId = '17047';
        activity.timeStamp = system.now();
        activity.timeZone = 'Central Time (US & Canada)';
        activity.source = 'RENTCafe.com ILS';
        activity.feedback = 'feedback recd';
        activity.listingId = null;
        requestList.add(activity);
        
        oDataReq.leasingActivityList = requestList; 
        String sReq = JSON.serialize(oDataReq);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/AddLeasingActivity';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        
        System.runAs(u1) {
            Test.startTest();
            
            RESTLeasingActivityController.addLeasingActivityRecord();
            Test.stopTest();
            List<Lead> leads = [
                SELECT id ,phone
                FROM lead
                where phone='5101231234'
            ];
            //system.assertEquals(leads.size(), 1);
            //system.assertEquals(res.statusCode, 200);
        }
    }
    static testMethod void createLeasingFeedbackTest() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        System.debug('user' + u1);
        // String sReq = '{ "leasingActivityList": [ { "email": "dupe200@gmail.com", "firstName": "Dupe1", "lastName": "Dupe1", "phone": "2002002000", "activityType": "email", "activityId": "17047", "timeStamp": "2020-02-06T21:53:16.403Z", "timeZone": "Central Time (US & Canada)", "source": "RENTCafe.com ILS", "feedback":"Anamika is awesome developer!", "listingId": "13922" } ] }';
        List<RESTLeasingActivityHelper.LeasingActivityWrapper> requestList = new List<RESTLeasingActivityHelper.LeasingActivityWrapper>();
        RESTLeasingActivityHelper.LeasingActivityWrapper activity = new RESTLeasingActivityHelper.LeasingActivityWrapper();
        RESTLeasingActivityHelper.LeasingActivityData oDataReq = new RESTLeasingActivityHelper.LeasingActivityData ();
        activity.email = 'testuser123@gmail.com';
        activity.firstName = 'Test';
        activity.lastName = 'User';
        activity.phone = '5103448876';
        activity.activityType = 'application_started';
        activity.activityId = '17047';
        activity.timeStamp = system.now();
        activity.timeZone = 'Central Time (US & Canada)';
        activity.source = 'RENTCafe.com ILS';
        activity.feedback = 'feedback recd';
        activity.listingId = '139221';
        requestList.add(activity);
        
        oDataReq.leasingActivityList = requestList; 
        String sReq = JSON.serialize(oDataReq);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/AddLeasingActivity';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        
        System.runAs(u1) {
            Test.startTest();
            
            RESTLeasingActivityController.addLeasingActivityRecord();
            Test.stopTest();
            List<Opportunity_Rental_Unit_Activity__c> oRUAs = [
                SELECT id, Activity_Code__c
                FROM Opportunity_Rental_Unit_Activity__c
                LIMIT 10
            ];
            //System.debug('activities' + oRUAs[0]);
            //system.assertEquals(oRUAs.size(), 1);
            //system.assertEquals(oRUAs[0].Activity_Code__c, 'application_started');
            //add feedback task check!      
            //system.assertEquals(res.statusCode, 200);
        }
        req.requestBody = Blob.valueOf('');
        RESTLeasingActivityController.addLeasingActivityRecord();
    }
    
}
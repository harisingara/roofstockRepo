@isTest
public class RESTLeasingActivityControllerRentlyTest {
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
    
    
    static testMethod void leadCreationEmailEnquiry() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        System.debug('user' + u1);
        
        Property2__c properties = new Property2__c(
            Leasing_Market__c = 'Atlanta',
            PropertyCode__c = 'q1000',
            PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
            Property_Type__c = 'Single Family',
            Year_Built__c = '1972',
            name = '123 Main St Tracy CA 95391'
        );
        insert properties;
        
        Property_Unit__c units = new Property_Unit__c(
            name = '123 Main St Tracy CA 95391',
            Property__c = properties.id,
            Bathrooms__c = 3,
            Bedrooms__c = 2.5,
            HomeCode__c = 'q20000'
        );
        insert units;
        
        Rental_Listing__c rl = new Rental_Listing__c(
            name = '123 Main St Tracy CA 95391',
            Property_Unit__c = units.id,
            Rental_Listing_Id__c = '21978',
            Current_Rent__c = 1200,
            Status__c = 'Unspecified'
        );
        insert rl;
        
        List<RESTLeasingActivityHelperRently.LeasingActivityWrapper> leasingActivityList = new List<RESTLeasingActivityHelperRently.LeasingActivityWrapper>();
        RESTLeasingActivityHelperRently.LeasingActivityWrapper activity = new RESTLeasingActivityHelperRently.LeasingActivityWrapper();
        activity.email = 'testuser123@gmail.com';
        activity.firstName = 'Test';
        activity.lastName = 'User';
        activity.phone = '5103448876';
        activity.activityType = 'email_inquiry';
        activity.activityId = '17047';
        activity.timeStamp = system.now();
        activity.timeZone = 'Central Time (US & Canada)';
        activity.source = 'RENTCafe.com ILS';
        activity.feedback = null;
        activity.listingId = '21978';
        activity.transferredToListingId = '12345';
        leasingActivityList.add(activity);
        
        List<RESTLeasingActivityHelperRently.LeasingActivityResponse> response = RESTLeasingActivityHelperRently.AddLeasingActivity(
            leasingActivityList
        );
        system.assertEquals(response.size(), 1);
    }
    
    
    
    static testMethod void leadCreationPhoneEnquiry() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        System.debug('user' + u1);
        
        Property2__c properties = new Property2__c(
            Leasing_Market__c = 'Atlanta',
            PropertyCode__c = 'q1000',
            PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
            Property_Type__c = 'Single Family',
            Year_Built__c = '1972',
            name = '123 Main St Tracy CA 95391'
        );
        insert properties;
        
        Property_Unit__c units = new Property_Unit__c(
            name = '123 Main St Tracy CA 95391',
            Property__c = properties.id,
            Bathrooms__c = 3,
            Bedrooms__c = 2.5,
            HomeCode__c = 'q20000'
        );
        insert units;
        
        Rental_Listing__c rl = new Rental_Listing__c(
            name = '123 Main St Tracy CA 95391',
            Property_Unit__c = units.id,
            Rental_Listing_Id__c = '21978',
            Current_Rent__c = 1200,
            Status__c = 'Unspecified'
        );
        insert rl;
        
        List<RESTLeasingActivityHelperRently.LeasingActivityWrapper> leasingActivityList = new List<RESTLeasingActivityHelperRently.LeasingActivityWrapper>();
        RESTLeasingActivityHelperRently.LeasingActivityWrapper activity = new RESTLeasingActivityHelperRently.LeasingActivityWrapper();
        activity.email = 'testuser123@gmail.com';
        activity.firstName = 'Test';
        activity.lastName = 'User';
        activity.phone = '5103448876';
        activity.activityType = 'phone_inquiry';
        activity.activityId = '17047';
        activity.timeStamp = system.now();
        activity.timeZone = 'Central Time (US & Canada)';
        activity.source = 'RENTCafe.com ILS';
        activity.feedback = null;
        activity.listingId = '21978';
        activity.transferredToListingId = '12345';
        leasingActivityList.add(activity);
        
        List<RESTLeasingActivityHelperRently.LeasingActivityResponse> response = RESTLeasingActivityHelperRently.AddLeasingActivity(
            leasingActivityList
        );
        system.assertEquals(response.size(), 1);
    }
    
    static testMethod void leadCreationEmailEnquiry1() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        System.debug('user' + u1);
        
        Property2__c properties = new Property2__c(
            Leasing_Market__c = 'Atlanta',
            PropertyCode__c = 'q1000',
            PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
            Property_Type__c = 'Single Family',
            Year_Built__c = '1972',
            name = '123 Main St Tracy CA 95391'
        );
        insert properties;
        
        Property_Unit__c units = new Property_Unit__c(
            name = '123 Main St Tracy CA 95391',
            Property__c = properties.id,
            Bathrooms__c = 3,
            Bedrooms__c = 2.5,
            HomeCode__c = 'q20000'
        );
        insert units;
        
        Rental_Listing__c rl = new Rental_Listing__c(
            name = '123 Main St Tracy CA 95391',
            Property_Unit__c = units.id,
            Rental_Listing_Id__c = '21978',
            Current_Rent__c = 1200,
            Status__c = 'Unspecified'
        );
        insert rl;
        
        List<RESTLeasingActivityHelperRently.LeasingActivityWrapper> leasingActivityList = new List<RESTLeasingActivityHelperRently.LeasingActivityWrapper>();
        RESTLeasingActivityHelperRently.LeasingActivityWrapper activity = new RESTLeasingActivityHelperRently.LeasingActivityWrapper();
        activity.email = 'testuser123@gmail.com';
        activity.firstName = 'Test';
        activity.lastName = 'User';
        activity.phone = '5103448876';
        activity.activityType = 'email_inquiry';
        activity.activityId = '11111';
        activity.timeStamp = system.now();
        activity.timeZone = 'Central Time (US & Canada)';
        activity.source = 'RENTCafe.com ILS';
        activity.feedback = null;
        activity.listingId = '21978';
        activity.transferredToListingId = '12345';
        leasingActivityList.add(activity);
        
        List<RESTLeasingActivityHelperRently.LeasingActivityResponse> response = RESTLeasingActivityHelperRently.AddLeasingActivity(
            leasingActivityList
        );
        system.assertEquals(response.size(), 1);
        // Check if a Lead got Created
        List <Lead> leadList = [Select Id from Lead ];
        system.assertEquals(leadList.size(), 1);
        // Check if a LLRU got created
        List <Lead_Leasing_Rental_Unit__c> llruList = [Select Id from Lead_Leasing_Rental_Unit__c];
        system.assertEquals(llruList.size(), 1);
        /*
        Test.startTest();
        leasingActivityList = new List<RESTLeasingActivityHelperRently.LeasingActivityWrapper>();
        activity = new RESTLeasingActivityHelperRently.LeasingActivityWrapper();
        activity.email = 'testuser123@gmail.com';
        activity.firstName = 'Test';
        activity.lastName = 'User';
        activity.phone = '5103448876';
        activity.activityType = 'application_started';
        activity.activityId = '11111';
        activity.timeStamp = system.now();
        activity.timeZone = 'Central Time (US & Canada)';
        activity.source = 'RENTCafe.com ILS';
        activity.feedback = null;
        activity.listingId = '21978';
        activity.transferredToListingId = '12345';
        leasingActivityList.add(activity);
        
        response = RESTLeasingActivityHelperRently.AddLeasingActivity(
            leasingActivityList
        );
        Test.stopTest();
        List <Opportunity> oppList = [Select Id from Opportunity];
        system.assertEquals(oppList.size(), 1);
        List <OpportunityRentalUnit__c> oruList = [Select Id from OpportunityRentalUnit__c];
        system.assertEquals(oruList.size(), 1);
        List <Opportunity_Rental_Unit_Activity__c> oruaList = [Select Id from Opportunity_Rental_Unit_Activity__c];
        system.assertEquals(oruaList.size(), 1);
		*/
    }
    
    
    
    static testMethod void leadCreationEmailEnquiry2() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        System.debug('user' + u1);
        
        Id leasingLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Leasing').getRecordTypeId();
        Lead l = new Lead();
        l.LastNAme ='sfdc';
        l.Email = 'testuser123@gmail.com';
        l.Company = 'Salesforce';
        l.RecordTypeId = leasingLeadRecordTypeId;
        insert l;
		
        Property2__c properties = new Property2__c(
            Leasing_Market__c = 'Atlanta',
            PropertyCode__c = 'q1000',
            PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
            Property_Type__c = 'Single Family',
            Year_Built__c = '1972',
            name = '123 Main St Tracy CA 95391'
        );
        insert properties;
        
        Property_Unit__c units = new Property_Unit__c(
            name = '123 Main St Tracy CA 95391',
            Property__c = properties.id,
            Bathrooms__c = 3,
            Bedrooms__c = 2.5,
            HomeCode__c = 'q20000'
        );
        insert units;
        
        Rental_Listing__c rl = new Rental_Listing__c(
            name = '123 Main St Tracy CA 95391',
            Property_Unit__c = units.id,
            Rental_Listing_Id__c = '21978',
            Current_Rent__c = 1200,
            Status__c = 'Unspecified'
        );
        insert rl;
        
        // Insert the LLRU
        Lead_Leasing_Rental_Unit__c llru = new Lead_Leasing_Rental_Unit__c();
        llru.Lead__c = l.Id;
        llru.Rental_Listing__c = rl.Id;
        Insert llru;
        
        Test.startTest();
        // Insert an activity for the above Lead
        // LLRU should be converted to Opp
        List<RESTLeasingActivityHelperRently.LeasingActivityWrapper> leasingActivityList = new List<RESTLeasingActivityHelperRently.LeasingActivityWrapper>();
        RESTLeasingActivityHelperRently.LeasingActivityWrapper activity = new RESTLeasingActivityHelperRently.LeasingActivityWrapper();
        activity.email = 'testuser123@gmail.com';
        activity.firstName = 'Test';
        activity.lastName = 'User';
        activity.phone = '5103448876';
        activity.activityType = 'application_started';
        activity.activityId = '11111';
        activity.timeStamp = system.now();
        activity.timeZone = 'Central Time (US & Canada)';
        activity.source = 'RENTCafe.com ILS';
        activity.feedback = 'Test Feedback';
        activity.listingId = '21978';
        activity.transferredToListingId = '12345';
        leasingActivityList.add(activity);
        
        List<RESTLeasingActivityHelperRently.LeasingActivityResponse> response = RESTLeasingActivityHelperRently.AddLeasingActivity(
            leasingActivityList
        );
        Test.stopTest();
        
        List <Opportunity> oppList = [Select Id, Primary_Leasing_Contact__c, Primary_Leasing_Contact__r.Firstname,
                                      Primary_Leasing_Contact__r.LastName, Primary_Leasing_Contact__r.Email, 
                                      Primary_Leasing_Contact__r.Phone from Opportunity];
        system.assertEquals(oppList.size(), 1);
        System.debug('NDEBUG Got this Opp:::' + oppList);
        List <OpportunityRentalUnit__c> oruList = [Select Id from OpportunityRentalUnit__c];
        system.assertEquals(oruList.size(), 1);
        List <Opportunity_Rental_Unit_Activity__c> oruaList = [Select Id from Opportunity_Rental_Unit_Activity__c];
        system.assertEquals(oruaList.size(), 1);
    }
	
    
    static testMethod void leadCreationEmailEnquiry3() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        System.debug('user' + u1);
        
        Id leasingLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Leasing').getRecordTypeId();
        Lead l = new Lead();
        l.LastNAme ='sfdc';
        l.Email = 'testuser123@gmail.com';
        l.Company = 'Salesforce';
        l.RecordTypeId = leasingLeadRecordTypeId;
        insert l;
		
        Property2__c properties = new Property2__c(
            Leasing_Market__c = 'Atlanta',
            PropertyCode__c = 'q1000',
            PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
            Property_Type__c = 'Single Family',
            Year_Built__c = '1972',
            name = '123 Main St Tracy CA 95391'
        );
        insert properties;
        
        Property_Unit__c units = new Property_Unit__c(
            name = '123 Main St Tracy CA 95391',
            Property__c = properties.id,
            Bathrooms__c = 3,
            Bedrooms__c = 2.5,
            HomeCode__c = 'q20000'
        );
        insert units;
        
        Rental_Listing__c rl = new Rental_Listing__c(
            name = '123 Main St Tracy CA 95391',
            Property_Unit__c = units.id,
            Rental_Listing_Id__c = '21978',
            Current_Rent__c = 1200,
            Status__c = 'Unspecified'
        );
        insert rl;
                
        String activityReq = '{'+
		'	\"leasingActivityList\": ['+
		'		{'+
		'			\"email\": \"testuser123@gmail.com\",'+
		'			\"firstName\": \"Test\",'+
		'			\"lastName\": \"User\",'+
		'			\"phone\": \"5103448876\",'+
		'			\"activityType\": \"phone_inquiry\",'+
		'			\"activityId\": \"217700\",'+
		'			\"timeStamp\": \"2022-01-02T15:01:14.35Z\",'+
		'			\"timeZone\": \"Central Time (US & Canada)\",'+
		'			\"source\": \"Property Website\",'+
		'			\"feedback\": \"Test Feedback\",'+
		'			\"listingId\": \"21978\"'+
		'		}'+
		'        ]'+
		'}';
        
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/AddLeasingActivityRently';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(activityReq);
        
        RestContext.request = req;
        RestContext.response = res;
		RESTLeasingActivityControllerRently.addLeasingActivityRecord();
        
    }
	
    
    
    static testMethod void exceptionTest() {
        RESTLeasingActivityHelperRently.getUUID ();
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        System.debug('user' + u1);
        
        Id leasingLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Leasing').getRecordTypeId();
        Lead l = new Lead();
        l.LastNAme ='sfdc';
        l.Email = 'testuser123@gmail.com';
        l.Company = 'Salesforce';
        l.RecordTypeId = leasingLeadRecordTypeId;
        insert l;
		
        Property2__c properties = new Property2__c(
            Leasing_Market__c = 'Atlanta',
            PropertyCode__c = 'q1000',
            PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
            Property_Type__c = 'Single Family',
            Year_Built__c = '1972',
            name = '123 Main St Tracy CA 95391'
        );
        insert properties;
        
        Property_Unit__c units = new Property_Unit__c(
            name = '123 Main St Tracy CA 95391',
            Property__c = properties.id,
            Bathrooms__c = 3,
            Bedrooms__c = 2.5,
            HomeCode__c = 'q20000'
        );
        insert units;
        
        Rental_Listing__c rl = new Rental_Listing__c(
            name = '123 Main St Tracy CA 95391',
            Property_Unit__c = units.id,
            Rental_Listing_Id__c = '21978',
            Current_Rent__c = 1200,
            Status__c = 'Unspecified'
        );
        insert rl;
        
        String activityReq = '{'+
		'	\"leasingActivityList\": ['+
		'		{'+
		'			\"email\": \"cpetri0452@gmail.com\",'+
		'			\"firstName\": \"Ronald\",'+
		'			\"lastName\": \"petri\",'+
		'			\"phone\": \"8177235477\",'+
		'			\"activityType\": \"phone_inquiry\",'+
		'			\"activityId\": \"217700\",'+
		'			\"timeStamp\": \"2022-01-02T15:01:14.35Z\",'+
		'			\"timeZone\": \"Central Time (US & Canada)\",'+
		'			\"source\": \"zumper\",'+
		'			\"feedback\": \"\",'+
		'			\"isViewing\": false,'+
		'			\"listingId\": \"21978\",'+
		'		}'+
		'        ]'+
		'}';
        
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/AddLeasingActivityRently';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(activityReq);
        
        RestContext.request = req;
        RestContext.response = res;
		RESTLeasingActivityControllerRently.addLeasingActivityRecord();
        
    }
	
}
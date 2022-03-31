@isTest
public class RESTLeasingFinancialInfoControllerTest {
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
        
        Account testAccount = new Account();
 		testAccount.Name='Test Account' ;
 		insert testAccount;
        
        contact con = new Contact();
        con.LastName = 'Salesforce';
        con.Email = 'testuser123@gmail.com';
        con.RecordTypeId = leasingContactRecordTypeId;
        con.AccountId = testAccount.Id;
        insert con;
        
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
        
        Opportunity o = new Opportunity();
       	o.AccountID = testAccount.ID;       
        o.Name= testAccount.Name;
        o.CloseDate=System.Today().addDays(3);       
        o.StageName='Prospecting';
        o.RecordTypeId = leasingOpportunityRecordTypeId;
        o.Yardi_Prospect_Id__c = '1111';  
        o.Rental_Listing__c = rl.Id;
        Insert o;
        
        System.debug('user' + u1);
        // String sReq = '{ "leasingActivityList": [ { "email": "dupe200@gmail.com", "firstName": "Dupe1", "lastName": "Dupe1", "phone": "2002002000", "activityType": "email", "activityId": "17047", "timeStamp": "2020-02-06T21:53:16.403Z", "timeZone": "Central Time (US & Canada)", "source": "RENTCafe.com ILS", "feedback":"Anamika is awesome developer!", "listingId": "13922" } ] }';
        List<RESTLeasingFinancialInfoHelper.LeasingFinInfoWrapper> requestList = new List<RESTLeasingFinancialInfoHelper.LeasingFinInfoWrapper>();
        RESTLeasingFinancialInfoHelper.LeasingFinInfoWrapper financialInfo = new RESTLeasingFinancialInfoHelper.LeasingFinInfoWrapper();
        RESTLeasingFinancialInfoHelper.FinancialInformation oDataReq = new RESTLeasingFinancialInfoHelper.FinancialInformation ();
        
        financialInfo.prospectId ='1111';  
          financialInfo.appFeePaid = 'Yes-Paid';
          financialInfo.holdingFeeAmount = 10.00;
          financialInfo.holdingFeePaid = true;
          financialInfo.leaseRent = 1000.00;
          financialInfo.rentlyRent = 1000.00;
          financialInfo.securityDeposit = 500.00;
          financialInfo.monthlyPetFee = 50.00;
          financialInfo.upfrontPetDeposit = 50.00;
          financialInfo.tax = 100.00;
          financialInfo.adminFee = 50.00;
          financialInfo.smartHomeFee = 10.00;
          financialInfo.secondNatureFee = 10.00;
          financialInfo.latchelFee = 5.00;
          financialInfo.poolFee = 5.00;
          financialInfo.utilitiesFee = 55.00;
          financialInfo.balancePaid = 34.00;
          financialInfo.concessionAmount = 100.00;
          financialInfo.concessionTerm = 'Monthly';
          financialInfo.listingId = '21978';
          requestList.add(financialInfo);  
        
        
        oDataReq.leasingFinInfoList = requestList; 
        String sReq = JSON.serialize(oDataReq);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/AddLeasingFinancialInfo';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        
        System.runAs(u1) {
            Test.startTest();
            
            RESTLeasingFinancialInfoController.updateFinancialInfo();
            Test.stopTest();
        }
        req.requestBody = Blob.valueOf('');
        RESTLeasingFinancialInfoController.updateFinancialInfo();
    }
    
    
}
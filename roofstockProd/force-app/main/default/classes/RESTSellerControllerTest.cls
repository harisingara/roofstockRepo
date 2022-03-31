@isTest public class RESTSellerControllerTest {
    private static final string RB_RT ='Retail Buyer';
    private statIC final string RS_RT='Retail Seller';  
    private static final string userAlias = 'RSUSER1';  
    
    private static Id retailBuyerLeadRTId ;
    private static Id retailSellerLeadRTId;
    //static initialization code (load test data) 
    static {
        //create custom settings
        insert new API_Endpoints__c (name= 'Roofstock_api', Url__c= 'https://qa.roofstock.com');
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //create test users
        TestDataFactory.createTestUserRecords(2);
        //load record type info
        retailBuyerLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RB_RT).getRecordTypeId();
        retailSellerLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RS_RT).getRecordTypeId();
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    
   
    static testMethod void TestBrokerLeadConversion() {
        
        User u1 = [SELECT Id FROM User WHERE Alias= :userAlias];
        System.RunAs(u1) {   
            
            //create lead (broker)
            CreateBrokerLead();    
            
            RESTSellerHelper.AddListing('brokerfirstName','brokerlastName', '12345', 120000,  'broker@email.com',  'retail_seller',  'San Francisco',
                                        'California','123 Main street','94105', false, '<1 month','5103662254',100.20,100,1000,10000, 'Stessa',1000,'No Offer','collectiveDeclineReason');
            
        }
    }
    static void CreateBrokerLead(){
        
        // Insert Test Data (Lead record)
        Lead ld = new Lead();
        ld.LastName = 'Test';
        ld.Status = 'No Appointment';
        ld.X1_Ideally_when_would_you_buy_your_first__c = system.today()+30;
        ld.Company = 'Test Company';
        ld.Lead_Interest__c = 'Selling Properties';
        ld.LeadSource = 'Roofstock Registered';
        ld.Property_Street__c = 'fake address';
        ld.Listing_Price__c = 120000;
        ld.Email='broker@email.com';
        ld.Broker_Account_ID__c='1234';
        ld.Broker_Name__c='Test Broker';
        ld.How_did_you_hear_about_Roofstock__c = 'Podcast'; 
        

        insert ld;
        
        
    }
    
    static testMethod void CreateLeadWithoutMatchingEmail(){
        
        // Insert Test Data (Lead record)
        Lead ld = new Lead();
        ld.LastName = 'Test';
        ld.Status = 'No Appointment';
        ld.X1_Ideally_when_would_you_buy_your_first__c = system.today()+30;
        ld.Company = 'Test Company';
        ld.Lead_Interest__c = 'Selling Properties';
        ld.LeadSource = 'Roofstock Registered';
        ld.Property_Street__c = 'fake address';
        ld.Listing_Price__c = 120000;
        ld.Email='broker1@email.com';
        ld.Broker_Account_ID__c='1234';
        ld.Broker_Name__c='Test Broker';
        ld.How_did_you_hear_about_Roofstock__c = 'Podcast'; 
        insert ld;
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(ld.id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Qualified');

       // Database.LeadConvertResult lcr = Database.convertLead(lc);
        //System.assert(lcr.isSuccess());
        RESTSellerHelper.AddListing('brokerfirstName','brokerlastName', '12345', 120000,  'broker9@email.com',  'retail_seller',  'San Francisco',
                                        'California','123 Main street','94105', false, '+6 months','5103662254',100.20,100,1000,10000, 'Roofstock Self-Serve',1000,'No Offer','collectiveDeclineReason');
        
    }
    static testMethod void CreateContactWithMatchingEmail(){
        Account acc = new Account();
        acc.Name='Test Rest Leasing';
        insert acc;
        Contact c  = new Contact();
        c.LastName='RestLeasing';
        c.AccountId = acc.Id;
        c.Email = 'broker@gmail.com';
        insert c;
        
        RESTSellerHelper.AddListing('brokerfirstName','brokerlastName', '12345', 120000,  'broker@gmail.com',  'retail_seller',  'San Francisco',
                                        'California','123 Main street','94105', false, '1-3 months','5103662254',100.20,100,1000,10000, 'Stessa',1000,'No Offer','collectiveDeclineReason');
       
        
    }
    static testMethod void BlankEmail(){
        Account acc = new Account();
        acc.Name='Test Rest Leasing';
        insert acc;
        Contact c  = new Contact();
        c.LastName='RestLeasing';
        c.AccountId = acc.Id;
        c.Email = 'broker@gmail.com';
        insert c;
        
        RESTSellerHelper.AddListing('brokerfirstName','brokerlastName', '12345', 120000,  '',  'retail_seller',  'San Francisco',
                                        'California','123 Main street','94105', false, '1-3 months','5103662254',100.20,100,1000,10000, '',1000,'No Offer','collectiveDeclineReason');
        
    }
    static testMethod void createTaskTest() {
        Task t = new Task();
        t.Subject = 'test task';
        insert t;
    }
    
   /* 
    static testMethod void runTest() {
        TaskHelper.inflateTest();
    }
    */
    
    static testMethod void getLeadRecordTypeidTest(){
        List<RecordType> reTypeList =[Select id,Name,DeveloperName,SObjectType from RecordType where sObjectType='Lead' AND DeveloperName='Retail_Seller'];
        RestSellerHelper.rtsList = reTypeList;
        RestSellerHelper.getLeadRecordTypeid('Retail_Seller');
        
    }


    static testMethod void RestSellerController() {
        User u1 = [SELECT Id FROM User WHERE Alias= :userAlias];
        Account acc = new Account();
        acc.Name='Test Rest Leasing';
        insert acc;
         System.debug('=acc owner='+acc.OwnerId);
        Contact c  = new Contact();
        c.LastName='RestLeasing';
        c.AccountId = acc.Id;
        c.Email = 'broker@gmail.com';
        insert c;
        System.debug('=con owner='+c.OwnerId);
        RESTSellerHelper.sellerRequest sellerReq = new RESTSellerHelper.sellerRequest();
        sellerReq.avmHigh = 100;
        sellerReq.avmLow = 100;
        sellerReq.avmRent =100;
        sellerReq.brokerFirstName = 'SFDC';
        sellerReq.brokerId = '121';
        sellerReq.brokerLastName = 'SAP';
        sellerReq.currentlyLeased = false;
        sellerReq.email = 'a@gmail.com';
        sellerReq.expectedTimeForTransaction = '10 days';
        sellerReq.listingPrice = 100;
        sellerReq.listingType = 'retail_seller';
        sellerReq.phone ='4434344345';
        sellerReq.propertyCity ='DC';
        sellerReq.propertyMonthlyRent = 100;
        sellerReq.propertyState = 'MA';
        sellerReq.propertyStreet = 'CA';
        sellerReq.propertyZip = '591309';
        
        String sReq = JSON.serialize(sellerReq);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/createSingleSellerOpportunity';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTSellerController.addPropertyToContact();
        Test.stopTest();
        
    }
    static testMethod void RestSellerControllerException() {
        try{
        User u1 = [SELECT Id FROM User WHERE Alias= :userAlias];
        Account acc = new Account();
        acc.Name='Test Rest Leasing';
        insert acc;
         System.debug('=acc owner='+acc.OwnerId);
        Contact c  = new Contact();
        c.LastName='RestLeasing';
        c.AccountId = acc.Id;
        c.Email = 'broker@gmail.com';
        insert c;
        System.debug('=con owner='+c.OwnerId);
        List<RESTSellerHelper.sellerRequest> sellerReqList = new List<RESTSellerHelper.sellerRequest>();
        RESTSellerHelper.sellerRequest sellerReq = new RESTSellerHelper.sellerRequest();
        sellerReq.avmHigh = 100;
        sellerReq.avmLow = 100;
        sellerReq.avmRent =100;
        sellerReq.brokerFirstName = 'SFDC';
        sellerReq.brokerId = '121';
        sellerReq.brokerLastName = 'SAP';
        sellerReq.currentlyLeased = false;
        sellerReq.email = 'a@gmail.com';
        sellerReq.expectedTimeForTransaction = '10 days';
        sellerReq.listingPrice = 100;
        sellerReq.listingType = 'retail_seller';
        sellerReq.phone ='4434344345';
        sellerReq.propertyCity ='DC';
        sellerReq.propertyMonthlyRent = 100;
        sellerReq.propertyState = 'MA';
        sellerReq.propertyStreet = 'CA';
        sellerReq.propertyZip = '591309';
        sellerReqList.add(sellerReq);
        String sReq = JSON.serialize(sellerReqList);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/createSingleSellerOpportunity';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTSellerController.addPropertyToContact();
        RESTSellerHelper.defaultAccountOwner();
        Test.stopTest();
        }
        Catch(Exception ex){
            
        }
        
    }
}
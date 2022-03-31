@isTest
public class LeadTests {
    
    
    private static Id retailBuyerLeadRTId ;
    private static Id retailSellerLeadRTId;
    
    private static final string userAlias = 'RSUSER1';  
    private static final string RB_RT ='Retail Buyer';
    private statIC final string RS_RT='Retail Seller';    
    
    //static initialization code (load test data) 
    static {
        //create test users
        TestDataFactory.createTestUserRecords(2);
        //load record type info
        retailBuyerLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RB_RT).getRecordTypeId();
        retailSellerLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RS_RT).getRecordTypeId();
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    
    static Lead InitLead(){
        
        string fname = 'Rooftsock';
        string lname = 'Customer'; 
        string email = 'customer@roofstock.com';
        string phone = '415-248-4240'; 
        string company = 'D-Company';
        
        
        Lead lead = new Lead();
        lead.FirstName = fname;
        lead.LastName = lname;
        lead.Email = email;
        lead.phone = phone;
        lead.Company = company;
        
        return lead;
        
    }
    
    //lead record type related tests
    static testMethod void RecordTypeRetailBuyerForBuyerInterest() {
        
        
        User u1 = [SELECT Id FROM User WHERE Alias= :userAlias];
        
        System.RunAs(u1){
            
            Lead lead = InitLead();
            lead.Lead_Interest__c = 'Buying Properties';
            lead.How_did_you_hear_about_Roofstock__c = 'Podcast'; 
            lead.Hubspot_Score__c = 50;
            
            test.startTest();	
            Insert lead;
            test.stopTest();
            
            //query the newly inserted lead and check Record type    
            Lead newLead = [select recordtypeid from lead where id= :lead.Id];     
            System.debug(newLead.recordtypeid);
            System.assertEquals(newLead.recordtypeid, retailBuyerLeadRTId);  
            
        }
        
        
        
    }
    static testMethod void RecordTypeRetailSellerForSellerInterest() {
        
        
        User u1 = [SELECT Id FROM User WHERE Alias=:userAlias];
        System.RunAs(u1){
            
            Lead lead = InitLead();
            lead.Lead_Interest__c = 'Selling Properties';
            lead.How_did_you_hear_about_Roofstock__c = 'Podcast'; 
            
            test.startTest();
            Insert lead;
            test.stopTest(); 
            
            //query the newly inserted lead and check Record type    
            Lead newLead = [select recordtypeid from lead where id= :lead.Id];     
            System.debug(newLead.recordtypeid);
            System.assertEquals(newLead.recordtypeid, retailSellerLeadRTId);  
            
        }
        
        
    }
    static testMethod void RecordTypeRetailBuyerForBrokerInterest() {
        
        
        User u1 = [SELECT Id FROM User WHERE Alias=:userAlias];
        
        System.RunAs(u1){
            
            Lead lead = InitLead();
            lead.Lead_Interest__c = 'Referring Clients as a Broker/Agent';
            lead.How_did_you_hear_about_Roofstock__c = 'Podcast'; 
            
            test.startTest();
            Insert lead;
            test.stopTest();  
            
            //query the newly inserted lead and check Record type    
            Lead newLead = [select recordtypeid from lead where id= :lead.Id];  
            
            System.debug(newLead.recordtypeid);
            System.assertEquals(newLead.recordtypeid, retailBuyerLeadRTId);  
            
        }
        
        
    }
    
    
    
    //lead auto populate values (market value and lead value) related tests
    static testMethod void MarketValueIsAutoPopulatedByMarket() {
        
        User u1 = [SELECT Id FROM User WHERE Alias=:userAlias];
        
        List<sObject> mys = Test.loadData(marketyield__c.sObjectType, 'testMarketyields');
        System.assert(mys.size() == 4);
        
        // Get first test myield record
        // test data for (in static resource) Atlanta,1599,10
        marketyield__c my = [select id, name, market_rent__c, minimum_gross_yield__c from marketyield__c where name='Atlanta'];
        
        
        System.RunAs(u1){
            
            
            string market = my.name; //market name
            Lead lead = InitLead();
            lead.Lead_Interest__c = 'Selling Properties';
            lead.How_did_you_hear_about_Roofstock__c = 'Podcast'; 
            lead.Listing_Markets__c = market;  //set the zip code 
            lead.Current_Rent__c = 120000;
            
            Test.startTest();
            Insert lead;
            Test.stopTest();
            
            //query the newly inserted lead and check Record type    
            Lead newLead = [select Listing_Markets__c,Yield_Value__c ,Market_Rent__c from lead where id= :lead.Id];     
            System.debug(newLead.Listing_Markets__c);
            
            //expected result  yield = current rent /min yield = 120000/.10 = 1200000
            
            System.assertEquals(newLead.Yield_Value__c, 1200000);
            System.assertEquals(newLead.Market_Rent__c, my.Market_Rent__c);
            
        }
        
    }
    
    static testMethod void YieldValueisEmptyForEmptyMarkets() {
        
        User u1 = [SELECT Id FROM User WHERE Alias=:userAlias];
        
        List<sObject> mys = Test.loadData(marketyield__c.sObjectType, 'testMarketyields');
        System.assert(mys.size() == 4);
        
        // Get first test myield record
        // test data for (in static resource) Atlanta,1599,10
        marketyield__c my = [select id, name, market_rent__c, minimum_gross_yield__c from marketyield__c where name='Atlanta'];
        
        
        System.RunAs(u1){
            string market = my.name; //market name
            Lead lead = InitLead();
            lead.Lead_Interest__c = 'Selling Properties';
            lead.How_did_you_hear_about_Roofstock__c = 'Podcast'; 
            lead.Listing_Markets__c = '';  //if no market info
            lead.Current_Rent__c = 120000;
            Test.startTest();
            Insert lead;
            Test.stopTest();
            //query the newly inserted lead and check Record type    
            Lead newLead = [select Listing_Markets__c,Yield_Value__c ,Market_Rent__c from lead where id= :lead.Id];     
            System.debug(newLead.Listing_Markets__c);
            
            System.assertEquals(newLead.Yield_Value__c, null);
            System.assertEquals(newLead.Market_Rent__c, null);
        }
    }
    
    
    
    static testMethod void MarketValuesAreAutoPopulatedByPropertyZip() {
        
        User u1 = [SELECT Id FROM User WHERE Alias=:userAlias];
        
        List<sObject> mys = Test.loadData(marketyield__c.sObjectType, 'testMarketyields');
        System.assert(mys.size() == 4);
        
        // Get first test myield record
        // test data for (in static resource) Atlanta,1599,10
        marketyield__c my = [select id, name, market_rent__c, minimum_gross_yield__c from marketyield__c where name='Atlanta'];
        
        System.RunAs(u1){
            //custom settings are not readable from test class,so insert here..	
            insert new API_Endpoints__c(Name='Roofstock_api', Url__c = 'https://qa.roofstock.com');
            
            
            string market = my.name; //market name
            Lead lead = InitLead();
            lead.Lead_Interest__c = 'Selling Properties';
            lead.How_did_you_hear_about_Roofstock__c = 'Podcast'; 
            lead.Property_Zip_Code__c = '30301';
            
            lead.Current_Rent__c = 120000;
            
            //mock http callout to roofstock api
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
            Test.startTest();
            Insert lead;
            Test.stopTest();
            
            //query async call result after stoptest to see the result!
            //query the newly inserted lead and check Record type    
            Lead newLead = [select Listing_Markets__c,Yield_Value__c ,Market_Rent__c from lead where id= :lead.Id];     
            System.debug('bla' + newLead);
            
            //expected result  yield = current rent /min yield = 120000/10 =12000
            System.assertEquals(newLead.Listing_Markets__c ,'Atlanta');
            System.assertEquals(newLead.Yield_Value__c, 1200000);
            System.assertEquals(newLead.Market_Rent__c, my.Market_Rent__c);
        }
        
    }
    
    static testMethod void deleteTest() {
        Lead l = new Lead();
        l.LastName = 'sfdc';
        l.Company = 'sfdc';
        l.Email = 'a@sfdc.com';
        insert l;
        
        Lead ld = [select id from Lead where Id=:l.Id];
        delete ld;
        
        
        
    }
    
    static testMethod void LeadTriggerTestException() {
        TriggerDispatcher.forceException = true;
        Lead l;
        try{
            l = new Lead();
            l.lastName = 'SFDC';
            l.Company = 'Salesforce';
            insert l;
            
            task t = new task();
            t.subject = 'SFDC';
            t.status  = 'Open';
            t.whoId = l.Id;
            
            insert t;
        }
        catch(Exception ex){
            System.debug('=='+l.Id);
        }
        
        
    }
    
    static testMethod void RoofstockOneRecordType() {
        Id roofstockOneRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Roofstock One').getRecordTypeId();
        Lead l = InitLead();
        l.RecordTypeId = roofstockOneRecordTypeId;
        l.Status = 'Qulified';
        insert l;
    }
    static testMethod void convertedOpportunity() {
        Lead newLead = new lead(firstName = 'Cole', lastName = 'Swain', company = 'BlueWave', status = 'contacted') ;
        newLead.FirstName = 'Cole';
        newLead.LastName = 'Swain';
        newLead.Company = 'BlueWave';
        newLead.X1_Ideally_when_would_you_buy_your_first__c = Date.today();
        insert newLead;
        
        
        test.startTest();
        
        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(newLead.id);
        
        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        //lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setConvertedStatus('Appointment');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        lc.setOpportunityName('Cole Swain');
        
        
        test.stopTest();
    }
    static testMethod void convertedOpportunityRetailSeller() {
        Id retailSellerLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        
        Lead newLead = new lead(firstName = 'Cole', lastName = 'Swain', company = 'BlueWave', status = 'contacted') ;
        newLead.FirstName = 'Cole';
        newLead.LastName = 'Swain';
        newLead.Company = 'BlueWave';
        newLead.RecordTypeId = retailSellerLeadRecordTypeId;
        newLead.X1_Ideally_when_would_you_buy_your_first__c = Date.today();
        insert newLead;
        
        
        test.startTest();
        
        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(newLead.id);
        
        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        lc.setOpportunityName('Cole Swain');
        
        
        test.stopTest();
    }
    static testMethod void convertedOpportunityInstitutionalBuyer() {
        Id institutionalBuyerLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Institutional Buyer').getRecordTypeId();        
        
        Lead newLead = new lead(firstName = 'Cole', lastName = 'Swain', company = 'BlueWave', status = 'contacted') ;
        newLead.FirstName = 'Cole';
        newLead.LastName = 'Swain';
        newLead.Company = 'BlueWave';
        newLead.RecordTypeId = institutionalBuyerLeadRecordTypeId;
        newLead.X1_Ideally_when_would_you_buy_your_first__c = Date.today();
        insert newLead;
        
        
        test.startTest();
        
        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(newLead.id);
        
        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        //lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setConvertedStatus('Appointment');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        lc.setOpportunityName('Cole Swain');
        
        
        test.stopTest();
    }
    static testMethod void convertedOpportunityInstitutionalSeller() {
        Id institutionalSellerLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Institutional Seller').getRecordTypeId();        
        
        Lead newLead = new lead(firstName = 'Cole', lastName = 'Swain', company = 'BlueWave', status = 'contacted') ;
        newLead.FirstName = 'Cole';
        newLead.LastName = 'Swain';
        newLead.Company = 'BlueWave';
        newLead.RecordTypeId = institutionalSellerLeadRecordTypeId;
        newLead.X1_Ideally_when_would_you_buy_your_first__c = Date.today();
        insert newLead;
        
        
        test.startTest();
        
        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(newLead.id);
        
        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        lc.setOpportunityName('Cole Swain');
        
        
        test.stopTest();
    }
    static testMethod void convertedOpportunityDirectBuy() {
        Id retailSellerLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        
        Lead newLead = new lead(firstName = 'Cole', lastName = 'Swain', company = 'BlueWave', status = 'contacted') ;
        newLead.FirstName = 'Cole';
        newLead.LastName = 'Swain';
        newLead.Company = 'BlueWave';
        newLead.RecordTypeId = retailSellerLeadRecordTypeId;
        newLead.Direct_Buy_Lead__c = 'Yes';
        newLead.X1_Ideally_when_would_you_buy_your_first__c = Date.today();
        insert newLead;
        
        
        test.startTest();
        
        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(newLead.id);
        
        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        lc.setOpportunityName('Cole Swain');
        
        
        test.stopTest();
    }
    static testMethod void convertedOpportunityRoofstockOne() {
        Id roofstockOneRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Roofstock One').getRecordTypeId();
        
        Lead newLead = new lead(firstName = 'Cole', lastName = 'Swain', company = 'BlueWave', status = 'contacted') ;
        newLead.FirstName = 'Cole';
        newLead.LastName = 'Swain';
        newLead.Company = 'BlueWave';
        newLead.RecordTypeId = roofstockOneRecordTypeId;
        newLead.X1_Ideally_when_would_you_buy_your_first__c = Date.today();
        insert newLead;
        
        
        test.startTest();
        
        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(newLead.id);
        
        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        lc.setOpportunityName('Cole Swain');
        
        
        test.stopTest();
    }
    static testMethod void deleteLead() {
        Id roofstockOneRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Roofstock One').getRecordTypeId();
        
        Lead newLead = new lead(firstName = 'Cole', lastName = 'Swain', company = 'BlueWave', status = 'contacted') ;
        newLead.FirstName = 'Cole';
        newLead.LastName = 'Swain';
        newLead.Company = 'BlueWave';
        newLead.RecordTypeId = roofstockOneRecordTypeId;
        newLead.X1_Ideally_when_would_you_buy_your_first__c = Date.today();
        insert newLead;
        List<Lead> leadList = [select Id from Lead where Id=:newLead.Id];
        delete leadList;
    }
    
    static testMethod void UpdateLeasingOpportunityNameAfterLeadConversion(){
        Id leasingLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
        
        lead newLead = new lead() ;
        newLead.FirstName = 'Cole';
        newLead.LastName = 'Swain';
        newLead.Company = 'BlueWave';
        newLead.Status = 'New';
        newLead.RecordTypeId = leasingLeadRTId;
        insert newLead;
        
        
        test.startTest();
        
        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(newLead.id);
        
        //leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus('Interested');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        lc.setOpportunityName('Cole Swain');
        Set<Id> convertedLead = new Set<Id>();
        convertedLead.add(newLead.Id);
        
        LeadHelper.UpdateLeasingOpportunityNameAfterLeadConversion(convertedLead);
        
        test.stopTest();
        
    }
    
    static testMethod void transferTaskOwners() {
        Id retailBuyerRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId()))
		{
        QueuesObject q1 = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Lead');
        insert q1;
        }
        Lead newLead = new lead() ;
        newLead.FirstName = 'Cole';
        newLead.LastName = 'Swain';
        newLead.Company = 'BlueWave';
        newLead.Status = 'Working';
        newLead.OwnerId = testGroup.Id;
        newLead.No_Convert_Reason__c = 'Working';
        newLead.RecordTypeId = retailBuyerRecordTypeId;
        //newLead.X1_Ideally_when_would_you_buy_your_first__c = Date.today();
        insert newLead;
        
        task t = new task();
        t.whoId = newLead.Id;
        t.subject = 'SFDC';
        t.Status = 'Open';
        insert t;
        
        Map<Id,Lead> leadMap = new Map<Id,Lead>();
        leadMap.put(newLead.Id,newLead);
        Lead updatedLead = [select Id,OwnerId from Lead where Id=:newLead.Id];
        updatedLead.OwnerId =UserInfo.getUserId();
        update updatedLead;
        
        List<Lead> newLeadList = new List<Lead>();
        newLeadList.add(updatedLead);
        LeadHelper.transferTaskOwners(newLeadList,leadMap);
    }
    
    static testMethod void UpdateLeadRecordTypes() {
        Lead newLead = new lead() ;
        newLead.FirstName = 'Cole';
        newLead.LastName = 'Swain';
        newLead.Company = 'BlueWave';
        //newLead.Lead_Interest__c = 'Roofstock One';
        newLead.Certified_Roofstock_Agent__c = 'Yes';
        insert newLead;
    }

    
}
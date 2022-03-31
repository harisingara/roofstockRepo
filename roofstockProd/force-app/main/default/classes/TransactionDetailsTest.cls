@isTest
public with sharing class TransactionDetailsTest {
    @testSetup
    static void setupTestData() {
        TestDataFactory.insertHierarchyCustomSettingData();
        Id transRecordtypeId = Schema.SObjectType.Transaction__C.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        Id propertyRecordtypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByName().get('Roofstock').getRecordTypeId();
        Id propertyRecordtypeId1 = Schema.SObjectType.Property2__c.getRecordTypeInfosByName().get('Asset Management').getRecordTypeId();
        List<Property2__c> propList = new List<Property2__c>();
        List<Property_Unit__c> propUnitList = new List<Property_Unit__c>();
        List<Transaction__c> transactionList = new List<Transaction__c>();
        
        
        //User
        String orgId = UserInfo.getOrganizationId(); 
        Profile prof = [select id from profile where name = 'System Administrator'];
    	String dateString =  String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');  
    	Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
    	String uniqueName = orgId + dateString + randomInt;  
    	User tempUser = new User(  FirstName = 'sfdc0021',  
                            LastName = 'Salesforce2022',  
                            email = 'salesforce@sfdc.com',  
                            Username = uniqueName + '@test' + orgId + '.org',  
                            EmailEncodingKey = 'ISO-8859-1',  
                            Alias = uniqueName.substring(18, 23),  
                            TimeZoneSidKey = 'America/Los_Angeles',  
                            LocaleSidKey = 'en_US',  
                            LanguageLocaleKey = 'en_US',  
                            ProfileId = prof.Id);  
    	insert tempUser;  

        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.US_Resident__c='Yes';
        insert acc;

        Contact con = new Contact();
        con.firstname = 'Test ';
        con.lastname = 'contact';
        con.BPM_Contact_Id__c = '1234';
        con.Email = 'test@test.com';
        con.AccountId = acc.Id;
        insert con;
        
        Property2__C prop = new Property2__C();
        prop.Name = 'Test property';
        
        
        prop.RecordtypeId = propertyRecordtypeId;
        propList.add(prop);
        
        Property2__C prop1 = new Property2__C();
        prop1.Name = 'Test property1';
        prop1.RecordtypeId = propertyRecordtypeId1;
        prop1.Client__c = 'Project Spartan Capital Group';
        propList.add(prop1);
        
        insert propList;
        
        Property_Unit__c propU = new Property_Unit__c();
        propU.Name = 'Test Property Unit';
        propU.Property__c = prop.Id;
        propU.PropertyUnitId__c ='PU00000';
        propUnitList.add(propU);
        
        Property_Unit__c propU1 = new Property_Unit__c();
        propU1.Name = 'Test Property Unit';
        propU1.Property__c = prop1.Id;
        propU1.PropertyUnitId__c ='PU00001';
        propUnitList.add(propU1);
        
        insert propUnitList;
        
        Transaction__c trans = new Transaction__c();
        trans.Name = 'Test Transaction';
        trans.Transaction_Type__c = 'Acquisition Buy';
       
        trans.Buyer_Property_Instance__c = prop.id;
        trans.RecordtypeId = transRecordtypeId;
        trans.Stage__c = 'Pre-PSA';
       
        trans.Transaction_Id__c ='Test000000';
       
        transactionList.add(trans);
        insert transactionList;

        Task tsk = new Task();
        tsk.OwnerId = UserInfo.getUserId();
        tsk.Priority = 'Select One';
        
     
        tsk.Status = 'Completed';
        tsk.Subject = 'CS Check-In';
        //tsk.Type = 'Select One';
        tsk.Type = 'QC: Contract Audit';
        tsk.whatId = transactionList[0].id;
        insert tsk;

        List<Task> taskLists = [SELECT Id, whatId, Status
        from TASK
        WHERE Type = 'QC: Contract Audit' AND WhatId IN:transactionList];
        System.debug('***log'+taskLists);

        System.debug('***log'+transactionList[0].Roofstock_TC_User__c);
        transactionList[0].Roofstock_TC_User__c = tempUser.id;
        update  transactionList[0];
        System.debug('***log'+transactionList[0].Roofstock_TC_User__c);
        System.debug('***log'+transactionList[0].Transaction_Type__c);
    }
    @isTest
    static void TransactionDetailsTest() {
        
        TransactionDetails.getMilestonePicklistValues();
        //TransactionDetails.getFieldSetFieldsByFieldSetName()
        Transaction__c tran= [Select id from Transaction__c where Transaction_Id__c ='Test000000' limit 1];
        Property2__C pro = [Select id from Property2__C limit 1 ];
        TransactionDetails.getRequiredValues(tran.id);
        TransactionDetails.getPropertyDetails(tran.id);
        TransactionDetails.getFieldSetFieldsByFieldSetName('Task','activities__CreateTasks');
        Contact con = [Select id from contact limit 1];
        TransactionDetails.getContactName(con.id);
       
        TransactionDetails.saveTask(tran.id);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseBPMRESOURCE());
        TransactionDetails.senddata(tran.id,'Test');
        test.stopTest();
    }
   
}
@isTest
public with sharing class TransactionUpdateHelperTest {
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
       // insert acc;

        Contact con = new Contact();
        con.firstname = 'Test ';
        con.lastname = 'contact';
        con.BPM_Contact_Id__c = '1234';
        con.Email = 'test@test.com';
       // con.AccountId = acc.Id;
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
        trans.Buyer_Property_Instance__c = prop.id;
        trans.RecordtypeId = transRecordtypeId;
        trans.Stage__c = 'Pre-PSA';
        trans.Transaction_Id__c ='Test000000';
       
        transactionList.add(trans);
        
        Transaction__c trans1 = new Transaction__c();
        trans1.Name = 'Test Transaction';
        trans1.Buyer_Property_Instance__c = prop1.id;
        trans1.RecordtypeId = transRecordtypeId;
        trans1.Stage__c = 'Pre-PSA';
        trans1.Transaction_Id__c ='Test000001';
        transactionList.add(trans1);
        
        insert transactionList;

        Transaction_Settlement__c transactionsettlement=new Transaction_Settlement__c();
        transactionsettlement.Unit_Price__c=200;
        transactionsettlement.Description__c='Earnest Money Deposit';
        transactionsettlement.Transaction__c=trans.id;
        insert transactionsettlement;
        Transaction_Settlement__c transactionsettlement2=new Transaction_Settlement__c();
        transactionsettlement2.Unit_Price__c=10;
        transactionsettlement2.Description__c='Option Fee';
        transactionsettlement2.Transaction__c=trans.id;
        insert transactionsettlement2;

        Transaction_Contact__c txnContact =new Transaction_Contact__c();
        txnContact.Transaction__c = trans.id;
        txnContact.Contact_Type__c = 'Buyer';
        txnContact.Contact_Count__c = 1;
        txnContact.Contact__c=con.id;
        insert txnContact;
        
        Inspection__c insp = new Inspection__C();
        insp.Name = 'Test Inspection';
        insp.Inspection_Type__c = 'Diligence';
        insp.Inspection_Status__c = 'Completed';
        insp.Property__c = prop.id;
        insp.Property_Unit__c = propU.id;
        insp.Transaction__c = trans.id;
        insp.Dilligence_Id__c = '1234';
        insert insp;   
    }
    @isTest
    static void updateTransactionAdhocTest() {
        Test.startTest();

        String jsonString = '{ "transactionContacts": [{"email":"test@test.com","contactNumber":"1","type":"Buyer","roofstockUserId":"","bpmContactId":1234,"rsAccountId":569308,"firstName":"test","lastName":"tet","companyName":"test comp","mobile":"900090000009"}] }';
		String jsonInspection = '{"Inspections":[{"inspectionId":"845ff09b-d937-46b5-ac5b-90fad17f3958","diligenceDeadline":"2021-12-25","inspectionDueDate":"2021-12-26"}]}';     
      
        Transaction_Update__e tuevent = new Transaction_Update__e();
        tuevent.Transaction_Id__c ='Test000000';
        tuevent.Transaction_Coordinator__c ='salesforce@sfdc.com';
        tuevent.Customer_Service__c = 'salesforce@sfdc.com';
        tuevent.Underwriting_Analyst__c = 'salesforce@sfdc.com';
        tuevent.Roofstock_Advisor__c = 'salesforce@sfdc.com';
        tuevent.Roofstock_Inventory_Owner__c = 'salesforce@sfdc.com';
        tuevent.Transaction_Contact__c =jsonString;
        tuevent.Inspection__c = jsonInspection;
        tuevent.Event_Type__c = 'Adhoc Update';
        
        List<Transaction_Update__e> transUpdateEvents = new List<Transaction_Update__e>();
        transUpdateEvents.add(tuevent);
        List<Database.SaveResult> results = EventBus.publish(transUpdateEvents);
        Test.getEventBus().deliver();
        Test.stopTest();    
    }
    @isTest
    static void updateTransactionContractQCTest() {
        Test.startTest();

        String jsonString = '{ "transactionContacts": [{"email":"test@test.com","contactNumber":"1","type":"Buyer","roofstockUserId":"","bpmContactId":1234,"rsAccountId":569308,"firstName":"test","lastName":"tet","companyName":"test comp","mobile":"900090000009"}] }';
		String jsonInspection = '{"inspections":[{"inspectionId":"1234","diligenceDeadline":"2021-12-25","inspectionDueDate":"2021-12-26"}]}';     
        String jsonPropertyUnit = '{"property_units":[{"id":"PU00000","property_access_notes":"propertyAccessNotes","property_access_method_type":"accessmethodtype","occupancy":"vacant"}]}';     
      
      
        Transaction_Update__e tuevent = new Transaction_Update__e();
        tuevent.Transaction_Id__c ='Test000000';
        tuevent.Transaction_Coordinator__c ='salesforce@sfdc.com';
        tuevent.Customer_Service__c = 'salesforce@sfdc.com';
        tuevent.Underwriting_Analyst__c = 'salesforce@sfdc.com';
        tuevent.Roofstock_Advisor__c = 'salesforce@sfdc.com';
        tuevent.Roofstock_Inventory_Owner__c = 'salesforce@sfdc.com';
        tuevent.Transaction_Contact__c =jsonString;
        tuevent.Inspection__c = jsonInspection;
        tuevent.Property_Unit__c = jsonPropertyUnit;
        tuevent.Event_Type__c = 'Contract QC';
        
        List<Transaction_Update__e> transUpdateEvents = new List<Transaction_Update__e>();
        transUpdateEvents.add(tuevent);
        List<Database.SaveResult> results = EventBus.publish(transUpdateEvents);
        Test.getEventBus().deliver();
        Test.stopTest();    
    }
    @isTest
    static void updateTransactionSubmitEmdTest() {
        Test.startTest();

        String jsonString = '{ "transactionContacts": [{"email":"test@test.com","contactNumber":"1","type":"Buyer","roofstockUserId":"","bpmContactId":1234,"rsAccountId":569308,"firstName":"test","lastName":"tet","companyName":"test comp","mobile":"900090000009"}] }';
        //String jsonString = '{ "transactionContacts": [{"bpmContactId":000001,"rsAccountId":000001,"roofstockUserId":"","type":"Seller","contactNumber":001,"email":"test@test.com.demo","mobile":"","firstName":"Jimmy","lastName":"Rado","companyName":"David M. Weekley"}] }';
      
      
        Transaction_Update__e tuevent = new Transaction_Update__e();
        tuevent.Transaction_Id__c ='Test000000';
        tuevent.Transaction_Coordinator__c ='salesforce@sfdc.com';
        tuevent.Customer_Service__c = 'salesforce@sfdc.com';
        tuevent.Underwriting_Analyst__c = 'salesforce@sfdc.com';
        tuevent.Roofstock_Advisor__c = 'salesforce@sfdc.com';
        tuevent.Roofstock_Inventory_Owner__c = 'salesforce@sfdc.com';
        tuevent.Transaction_Contact__c =jsonString;
        tuevent.Event_Type__c = 'Submit EMD';
        
        List<Transaction_Update__e> transUpdateEvents = new List<Transaction_Update__e>();
        transUpdateEvents.add(tuevent);
        List<Database.SaveResult> results = EventBus.publish(transUpdateEvents);
        Test.getEventBus().deliver();
        Test.stopTest();    
    }
}
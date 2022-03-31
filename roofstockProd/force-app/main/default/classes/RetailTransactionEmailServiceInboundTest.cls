/**
 * @author            : Guru Sandhu
 * @last modified on  : 03-30-2022
 * @last modified by  : Guru Sandhu
**/
@isTest
public class RetailTransactionEmailServiceInboundTest {

    @isTest
    static void testInboundEmail_RetailTransaction(){
             // create a new email and envelope object
       Messaging.InboundEmail email = new Messaging.InboundEmail() ;
       Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       
       // setup the data for the email
      email.subject = 'Test TRNS-Test000000';
      email.fromAddress = 'test@test.com';
      email.toAddresses = new List<String>{'test@transaction.com'};
      email.htmlBody = 'email body\n2225256325\nTitle  ref:TRNS-1234567<o:p></o:p></p>';

      Transaction__c transRec = [Select Id, Transaction_Id__c FROm Transaction__c WHERE Transaction_Id__c ='1234567' LIMIT 1] ;
      
      // add an Binary attachment
      Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
      attachment.body = blob.valueOf('my attachment text');
      attachment.fileName = 'textfileone.txt';
      attachment.mimeTypeSubType = 'text/plain';
     // attachment.ParentId = transRec.id;
      email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

      // add an Text atatchment
      Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
      attachmenttext.body = 'my attachment text';
      attachmenttext.fileName = 'textfiletwo3.txt';
      attachmenttext.mimeTypeSubType = 'texttwo/plain';
     // attachment.ParentId = transRec.id;
      email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };

        // call the email service class and test it with the data in the testMethod
        RetailTransactionEmailServiceInbound ib= new RetailTransactionEmailServiceInbound();
        Messaging.InboundEmailResult res = ib.handleInboundEmail(email, env);
    }
    @isTest
    static void testInboundEmail_NoRef_RetailTransaction(){
             // create a new email and envelope object
       Messaging.InboundEmail email = new Messaging.InboundEmail() ;
       Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       
       // setup the data for the email
      email.subject = 'Test TRNS-12345';
      email.fromAddress = 'test@test.com';
      email.toAddresses = new List<String>{'test@transaction.com'};
      email.htmlBody = 'email body\n2225256325\nTitle ';

      Transaction__c transRec = [Select Id, Transaction_Id__c FROm Transaction__c WHERE Transaction_Id__c ='1234567' LIMIT 1] ;
      
      // add an Binary attachment
      Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
      attachment.body = blob.valueOf('my attachment text');
      attachment.fileName = 'textfileone.txt';
      attachment.mimeTypeSubType = 'text/plain';
     // attachment.ParentId = transRec.id;
      email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

      // add an Text atatchment
      Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
      attachmenttext.body = 'my attachment text';
      attachmenttext.fileName = 'textfiletwo3.txt';
      attachmenttext.mimeTypeSubType = 'texttwo/plain';
     // attachment.ParentId = transRec.id;
      email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };

        // call the email service class and test it with the data in the testMethod
        RetailTransactionEmailServiceInbound ib= new RetailTransactionEmailServiceInbound();
        Messaging.InboundEmailResult res = ib.handleInboundEmail(email, env);
    }
    @isTest
    static void testInboundEmail_FwdEmail_RetailTransaction(){
             // create a new email and envelope object
       Messaging.InboundEmail email = new Messaging.InboundEmail() ;
       Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       
       // setup the data for the email
      email.subject = 'Test TRNS-Test000000';
      email.fromAddress = 'test@test.com';
      email.toAddresses = new List<String>{'test@rs.com'};
      email.htmlBody = 'email body\n2225256325\nTitle ';

      Transaction__c transRec = [Select Id, Transaction_Id__c FROm Transaction__c WHERE Transaction_Id__c ='1234567' LIMIT 1] ;
      
      // add an Binary attachment
      Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
      attachment.body = blob.valueOf('my attachment text');
      attachment.fileName = 'textfileone.txt';
      attachment.mimeTypeSubType = 'text/plain';
     // attachment.ParentId = transRec.id;
      email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };

      // add an Text atatchment
      Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
      attachmenttext.body = 'my attachment text';
      attachmenttext.fileName = 'textfiletwo3.txt';
      attachmenttext.mimeTypeSubType = 'texttwo/plain';
     // attachment.ParentId = transRec.id;
      email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };

        // call the email service class and test it with the data in the testMethod
        RetailTransactionEmailServiceInbound ib= new RetailTransactionEmailServiceInbound();
        Messaging.InboundEmailResult res = ib.handleInboundEmail(email, env);
    }
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
        trans.Transaction_Id__c ='1234567';
       
        transactionList.add(trans);
        
        Transaction__c trans1 = new Transaction__c();
        trans1.Name = 'Test Transaction 2';
        trans1.Buyer_Property_Instance__c = prop1.id;
        trans1.RecordtypeId = transRecordtypeId;
        trans1.Stage__c = 'Pre-PSA';
        trans1.Transaction_Id__c ='98765432';
        transactionList.add(trans1);
        
        insert transactionList;
/*
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
        insert insp;   */
    }
}
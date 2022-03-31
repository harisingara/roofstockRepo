/**
 * @description       : 
 * @author            : Guru Sandhu
 * @group             : 
 * @last modified on  : 03-30-2022
 * @last modified by  : Guru Sandhu
**/
@isTest
public class GenericEmailNotificationTest {
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    @testSetup static void setup() {
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);

        System.runAs(u) {
        
        	EmailTemplate e = new EmailTemplate (developerName = 'test',FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = 'test'); // plus any other fields that you want to set
			insert e;
        }
        TestDataFactory.insertHierarchyCustomSettingData();
        Id transRecordtypeId = Schema.SObjectType.Transaction__C.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        Id propertyRecordtypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByName().get('Roofstock').getRecordTypeId();
        Id propertyRecordtypeId1 = Schema.SObjectType.Property2__c.getRecordTypeInfosByName().get('Asset Management').getRecordTypeId();
        
        List<Property2__c> propList = new List<Property2__c>();
        List<Property_Unit__c> propUnitList = new List<Property_Unit__c>();
        List<Transaction__c> transactionList = new List<Transaction__c>();
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
        trans1.Name = 'Test Transaction 2';
        trans1.Buyer_Property_Instance__c = prop1.id;
        trans1.RecordtypeId = transRecordtypeId;
        trans1.Stage__c = 'Pre-PSA';
        trans1.Transaction_Id__c ='Test000001';
        transactionList.add(trans1);
        
        insert transactionList;
    }
    static testMethod void sendEmail1() {
        Lead newLead = new Lead();
        newLead.LastName ='sfdc';
        newLead.Company ='sfdc';
        insert newLead;
        
		EmailTemplate e = [select Id,RelatedEntityType from EmailTemplate Limit 1];
        //e.RelatedEntityType = 'Lead';
        //update e;
        EmailMessage taskEmailMessage = new EmailMessage();
        taskEmailMessage.ToAddress =  'chidanand.Magadum@roofstock.com';
        taskEmailMessage.FromAddress = 'chidanand.Magadum@roofstock.com';
        taskEmailMessage.FromName = 'sfdc';
        taskEmailMessage.Subject = 'sfdc';
        taskEmailMessage.status = '2';
        taskEmailMessage.HtmlBody = 'sfdc'+' '+'ref:'+newLead.Id;
        taskEmailMessage.Incoming= True;
        taskEmailMessage.TextBody = 'sfdc'+' '+'ref:'+newLead.Id;
        taskEmailMessage.EmailServiceParentId__c=newLead.Id;
        insert taskEmailMessage;
        
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = blob.valueof('Test Content Data'),
            IsMajorVersion = true
        );
        insert cv;
        
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=taskEmailMessage.id;  
        contentlink.ContentDocumentId=documents[0].Id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        
        
        List<Map<String, Object>> objectList = new List<Map<String, Object>>();
        Map<String, Object> objMap = new Map<String, Object>();
        GenericEmailNotification.relatedFile rf = new GenericEmailNotification.relatedFile();
        rf.PathOnClient = 'file';
        rf.Title='abc';
        rf.VersionData = Blob.valueOf('a');   
        objMap.put('abc',rf);
        objectList.add(objMap);
        
        EmailServicesFunction emailFunction;
        String emailServiceAddress = '';
        emailFunction = [SELECT Id FROM EmailServicesFunction WHERE FunctionName='iBuy'];
        List<EmailServicesAddress> emailServicesAddress = [SELECT Id,DeveloperName,RunAsUserId,LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId = :emailFunction.Id];
        emailServiceAddress =  emailServicesAddress[0].LocalPart+ '@' + emailServicesAddress[0].EmailDomainName;
        //GenericEmailNotification.sendEmail('chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','SFDC','SFDC'+' '+'ref:'+newLead.Id,'SFDC'+' '+'ref:'+newLead.Id,emailServiceAddress,'forward',newLead.Id,objectList);
        List<String> fLst = new List<String>();
        fLst.addAll(objMap.keySet());
        GenericEmailNotification.sendEmails('chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','SFDC','SFDC'+' '+'ref:'+newLead.Id,'SFDC'+' '+'ref:'+newLead.Id,emailServiceAddress,'forward',newLead.Id,fLst,e.Id,newLead.Id);
		GenericEmailNotification.getEmailTempaltes(newLead.Id);      
    }
    
    static testMethod void sendEmail2() {
        Lead newLead = new Lead();
        newLead.LastName ='sfdc';
        newLead.Company ='sfdc';
        insert newLead;
        EmailTemplate e = [select Id from EmailTemplate Limit 1];
        Account acc = new Account();
        acc.Name='sfdc';
        insert acc;
        
        contact con = new Contact();
        con.LastName='sfdc';
        con.AccountId = acc.Id;
        insert con;

        Investment_Account__c ia = new Investment_Account__c();
        ia.Name='sfdc';
        ia.Account__c = acc.Id;
        insert ia;
        EmailMessage taskEmailMessage = new EmailMessage();
        taskEmailMessage.ToAddress =  'chidanand.Magadum@roofstock.com';
        taskEmailMessage.FromAddress = 'chidanand.Magadum@roofstock.com';
        taskEmailMessage.FromName = 'sfdc';
        taskEmailMessage.Subject = 'sfdc';
        taskEmailMessage.status = '2';
        taskEmailMessage.HtmlBody = 'sfdc'+' '+'ref:'+ia.Id;
        taskEmailMessage.Incoming= True;
        taskEmailMessage.TextBody = 'sfdc'+' '+'ref:'+ia.Id;
        taskEmailMessage.EmailServiceParentId__c=ia.Id;
        insert taskEmailMessage;
        
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = blob.valueof('Test Content Data'),
            IsMajorVersion = true
        );
        insert cv;
        
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=taskEmailMessage.id;  
        contentlink.ContentDocumentId=documents[0].Id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        
        
        List<Map<String, Object>> objectList = new List<Map<String, Object>>();
        Map<String, Object> objMap = new Map<String, Object>();
        GenericEmailNotification.relatedFile rf = new GenericEmailNotification.relatedFile();
        rf.PathOnClient = 'file';
        rf.Title='abc';
        rf.VersionData = Blob.valueOf('a');   
        objMap.put('abc',rf);
        objectList.add(objMap);
        
        EmailServicesFunction emailFunction;
        String emailServiceAddress = '';
        emailFunction = [SELECT Id FROM EmailServicesFunction WHERE FunctionName='iBuy'];
        List<EmailServicesAddress> emailServicesAddress = [SELECT Id,DeveloperName,RunAsUserId,LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId = :emailFunction.Id];
        emailServiceAddress =  emailServicesAddress[0].LocalPart+ '@' + emailServicesAddress[0].EmailDomainName;
        //GenericEmailNotification.sendEmail('chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','SFDC','SFDC'+' '+'ref:'+ia.Id,'SFDC'+' '+'ref:'+ia.Id,emailServiceAddress,'forward',ia.Id,objectList);
        List<String> fLst = new List<String>();
        fLst.addAll(objMap.keySet());
        GenericEmailNotification.sendEmails('chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','SFDC','SFDC'+' '+'ref:'+ia.Id,'SFDC'+' '+'ref:'+ia.Id,emailServiceAddress,'forward',ia.Id,fLst,newLead.Id,e.Id);

        
    }
    
    static testMethod void sendEmail3() {
        Lead newLead = new Lead();
        newLead.LastName ='sfdc';
        newLead.Company ='sfdc';
        insert newLead;
        EmailTemplate e = [select Id from EmailTemplate Limit 1];
        Account acc = new Account();
        acc.Name='sfdc';
        insert acc;
      	
        contact con = new Contact();
        con.LastName='sfdc';
        con.AccountId = acc.Id;
        insert con;
        
        Investment_Account__c ia = new Investment_Account__c();
        ia.Name='sfdc';
        ia.Account__c = acc.Id;
        insert ia;
        
        ATF_Work_Queue__c wq = new ATF_Work_Queue__c();
        wq.Investment_Account__c = ia.Id;
        wq.Contact__c = con.Id;
        insert wq;
        
        EmailMessage taskEmailMessage = new EmailMessage();
        taskEmailMessage.ToAddress =  'chidanand.Magadum@roofstock.com';
        taskEmailMessage.FromAddress = 'chidanand.Magadum@roofstock.com';
        taskEmailMessage.FromName = 'sfdc';
        taskEmailMessage.Subject = 'sfdc';
        taskEmailMessage.status = '2';
        taskEmailMessage.HtmlBody = 'sfdc'+' '+'ref:'+wq.Id;
        taskEmailMessage.Incoming= True;
        taskEmailMessage.TextBody = 'sfdc'+' '+'ref:'+wq.Id;
        taskEmailMessage.EmailServiceParentId__c=wq.Id;
        insert taskEmailMessage;
        
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = blob.valueof('Test Content Data'),
            IsMajorVersion = true
        );
        insert cv;
        
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=taskEmailMessage.id;  
        contentlink.ContentDocumentId=documents[0].Id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        
        
        List<Map<String, Object>> objectList = new List<Map<String, Object>>();
        Map<String, Object> objMap = new Map<String, Object>();
        GenericEmailNotification.relatedFile rf = new GenericEmailNotification.relatedFile();
        rf.PathOnClient = 'file';
        rf.Title='abc';
        rf.VersionData = Blob.valueOf('a');   
        objMap.put('abc',rf);
        objectList.add(objMap);
        
        EmailServicesFunction emailFunction;
        String emailServiceAddress = '';
        emailFunction = [SELECT Id FROM EmailServicesFunction WHERE FunctionName='iBuy'];
        List<EmailServicesAddress> emailServicesAddress = [SELECT Id,DeveloperName,RunAsUserId,LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId = :emailFunction.Id];
        emailServiceAddress =  emailServicesAddress[0].LocalPart+ '@' + emailServicesAddress[0].EmailDomainName;
        //GenericEmailNotification.sendEmail('chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','SFDC','SFDC'+' '+'ref:'+wq.Id,'SFDC'+' '+'ref:'+wq.Id,emailServiceAddress,'forward',wq.Id,objectList);
        List<String> fLst = new List<String>();
        fLst.addAll(objMap.keySet());
        GenericEmailNotification.sendEmails('chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','SFDC','SFDC'+' '+'ref:'+wq.Id,'SFDC'+' '+'ref:'+wq.Id,emailServiceAddress,'forward',wq.Id,fLst,newLead.Id,e.Id);
        
    }
    static testMethod void sendEmail4() {
        Account acc = new Account();
        acc.Name='sfdc';
        insert acc;
        Lead newLead = new Lead();
        newLead.LastName ='sfdc';
        newLead.Company ='sfdc';
        insert newLead;
        EmailTemplate e = [select Id from EmailTemplate Limit 1];
      	
        contact con = new Contact();
        con.LastName='sfdc';
        con.AccountId = acc.Id;
        insert con;
        
        Investment_Account__c ia = new Investment_Account__c();
        ia.Name='sfdc';
        ia.Account__c = acc.Id;
        insert ia;
        
        ATF_Work_Queue__c wq = new ATF_Work_Queue__c();
        wq.Investment_Account__c = ia.Id;
        wq.Contact__c = con.Id;
        insert wq;
        
        EmailMessage taskEmailMessage = new EmailMessage();
        taskEmailMessage.ToAddress =  'chidanand.Magadum@roofstock.com';
        taskEmailMessage.FromAddress = 'chidanand.Magadum@roofstock.com';
        taskEmailMessage.FromName = 'sfdc';
        taskEmailMessage.Subject = 'sfdc';
        taskEmailMessage.status = '2';
        taskEmailMessage.HtmlBody = 'sfdc'+' '+'ref:'+wq.Id;
        taskEmailMessage.Incoming= True;
        taskEmailMessage.TextBody = 'sfdc'+' '+'ref:'+wq.Id;
        taskEmailMessage.EmailServiceParentId__c=wq.Id;
        insert taskEmailMessage;
        
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = blob.valueof('Test Content Data'),
            IsMajorVersion = true
        );
        insert cv;
        
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=taskEmailMessage.id;  
        contentlink.ContentDocumentId=documents[0].Id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        
        
        List<Map<String, Object>> objectList = new List<Map<String, Object>>();
        Map<String, Object> objMap = new Map<String, Object>();
        GenericEmailNotification.relatedFile rf = new GenericEmailNotification.relatedFile();
        rf.PathOnClient = 'file';
        rf.Title='abc';
        rf.VersionData = Blob.valueOf('a');   
        objMap.put('abc',rf);
        objectList.add(objMap);
        
        EmailServicesFunction emailFunction;
        String emailServiceAddress = '';
        emailFunction = [SELECT Id FROM EmailServicesFunction WHERE FunctionName='iBuy'];
        List<EmailServicesAddress> emailServicesAddress = [SELECT Id,DeveloperName,RunAsUserId,LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId = :emailFunction.Id];
        emailServiceAddress =  emailServicesAddress[0].LocalPart+ '@' + emailServicesAddress[0].EmailDomainName;
        //GenericEmailNotification.sendEmail('chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','SFDC','SFDC'+' '+'ref:'+wq.Id,'SFDC'+' '+'ref:'+wq.Id,emailServiceAddress,'forward',taskEmailMessage.Id,objectList);
        List<String> fLst = new List<String>();
        fLst.addAll(objMap.keySet());
        GenericEmailNotification.sendEmails('chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','SFDC','SFDC'+' '+'ref:'+wq.Id,'SFDC'+' '+'ref:'+wq.Id,emailServiceAddress,'forward',taskEmailMessage.Id,fLst,newLead.Id,e.Id);
        
    }
    
    /**
    * @description : Handle the Transaction__c Email 
    * @author Guru Sandhu | 03-30-2022 
    * @return testMethod 
    **/
    @isTest
    static void sendEmail5() {
        Transaction__c transRec = [Select Id, Transaction_Id__c FROm Transaction__c WHERE Transaction_Id__c ='Test000000' LIMIT 1] ;
        
        System.Debug('transRec >> ' + transRec);
        
        EmailTemplate e = [select Id from EmailTemplate Limit 1];        
        EmailMessage taskEmailMessage = new EmailMessage();
        taskEmailMessage.ToAddress =  'chidanand.Magadum@roofstock.com';
        taskEmailMessage.FromAddress = 'chidanand.Magadum@roofstock.com';
        taskEmailMessage.FromName = 'sfdc';
        taskEmailMessage.Subject = 'sfdc';
        taskEmailMessage.status = '2';
        taskEmailMessage.HtmlBody = 'sfdc'+' '+'ref:'+transRec.Transaction_Id__c;
        taskEmailMessage.Incoming= True;
        taskEmailMessage.TextBody = 'sfdc'+' '+'ref:'+transRec.Transaction_Id__c;
        taskEmailMessage.EmailServiceParentId__c=transRec.Id;
        insert taskEmailMessage;
        
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = blob.valueof('Test Content Data'),
            IsMajorVersion = true
        );
        insert cv;
        
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=taskEmailMessage.id;  
        contentlink.ContentDocumentId=documents[0].Id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        
        
        List<Map<String, Object>> objectList = new List<Map<String, Object>>();
        Map<String, Object> objMap = new Map<String, Object>();
        GenericEmailNotification.relatedFile rf = new GenericEmailNotification.relatedFile();
        rf.PathOnClient = 'file';
        rf.Title='abc';
        rf.VersionData = Blob.valueOf('a');   
        objMap.put('abc',rf);
        objectList.add(objMap);
        
        EmailServicesFunction emailFunction;
        String emailServiceAddress = '';
        emailFunction = [SELECT Id FROM EmailServicesFunction WHERE FunctionName='iBuy'];
        List<EmailServicesAddress> emailServicesAddress = [SELECT Id,DeveloperName,RunAsUserId,LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId = :emailFunction.Id];
        emailServiceAddress =  emailServicesAddress[0].LocalPart+ '@' + emailServicesAddress[0].EmailDomainName;
        //GenericEmailNotification.sendEmail('chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','SFDC','SFDC'+' '+'ref:'+wq.Id,'SFDC'+' '+'ref:'+wq.Id,emailServiceAddress,'forward',taskEmailMessage.Id,objectList);
        List<String> fLst = new List<String>();
        fLst.addAll(objMap.keySet());
        GenericEmailNotification.sendEmails('chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','chidanandsfdc@gmail.com','Sbj SFDC','Bdy SFDC'+' '+'Body ref:'+transRec.Transaction_Id__c,'SFDC'+' '+'ref:'+transRec.Transaction_Id__c,emailServiceAddress,'forward',transRec.Id,fLst,e.Id,taskEmailMessage.Id);
    }
    
    private static void setupTestData() {

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
        trans1.Name = 'Test Transaction 2';
        trans1.Buyer_Property_Instance__c = prop1.id;
        trans1.RecordtypeId = transRecordtypeId;
        trans1.Stage__c = 'Pre-PSA';
        trans1.Transaction_Id__c ='Test000001';
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
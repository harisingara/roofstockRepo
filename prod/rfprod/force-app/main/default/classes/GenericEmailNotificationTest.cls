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
    
    
}
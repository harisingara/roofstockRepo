@isTest
public class EmailMessagesTest {
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void EmailMessages1(){
        Lead l = new Lead();
        l.LastName = 'sfdc';
        l.Email = 'a@sfdc.com';
        l.Company = 'salesforce';
        insert l;
        EmailMessage taskEmailMessage = new EmailMessage();
        taskEmailMessage.ToAddress =  'chidanand.Magadum@roofstock.com';
        taskEmailMessage.FromAddress = 'chidanand.Magadum@roofstock.com';
        taskEmailMessage.FromName = 'sfdc';
        taskEmailMessage.Subject = 'sfdc';
        taskEmailMessage.status = '2';
        taskEmailMessage.HtmlBody = 'sfdc'+' '+'ref:'+l.Id;
        taskEmailMessage.Incoming= True;
        taskEmailMessage.TextBody = 'sfdc'+' '+'ref:'+l.Id;
        taskEmailMessage.EmailServiceParentId__c=l.Id;
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
        
        EmailMessages.messages(l.Id);
        EmailMessages.emailBodyAttachment(taskEmailMessage.Id);
        EmailMessages.emailBody(taskEmailMessage.Id);
        EmailMessages.emailServiceAddress(l.Id);
        EmailMessages.forwardEmails(taskEmailMessage.Id);
        EmailMessages.fromAddress(l.Id);
                
        
    }
    static testMethod void EmailMessages2(){
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
        EmailMessages.fromAddress(ia.Id);
        EmailMessages.emailServiceAddress(ia.Id);
        
    }
    static testMethod void updateCaseStatus(){
        String caseTransactionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        TestDataFactory.insertHierarchyCustomSettingData();
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        Contact con = new Contact();
        con.firstname = 'Salesforce';
        con.lastname = 'SAP';
        con.BPM_Contact_Id__c = '1234';
        con.Email = 'chidanand.Magadum@Roofstock.com';
        con.AccountId = acc.Id;
        insert con;
        
        Transaction__c trans = new Transaction__c();
        trans.Buyer_Contact_Id_1__c = '1234';
        trans.Buyer_Contact1__c = con.Id;
        trans.Transaction_Status__c = 'Pending Escrow';
        insert trans;
        
        Case c = new Case();
        c.ContactId = con.Id;
        c.Origin = 'Email';
        c.RecordTypeId = caseTransactionRecordTypeId;
        c.Subject = 'Slow new';
        c.status ='In Progress';
        insert c;
        
        System.debug('****'+c.status);
        EmailMessage taskEmailMessage = new EmailMessage();
        taskEmailMessage.ToAddress =  'chidanand.Magadum@roofstock.com';
        taskEmailMessage.FromAddress = 'chidanand.Magadum@roofstock.com';
        taskEmailMessage.FromName = 'sfdc';
        taskEmailMessage.Subject = 'sfdc';
        taskEmailMessage.status = '2';
        taskEmailMessage.HtmlBody = 'sfdc'+' '+'ref:'+c.Id;
        taskEmailMessage.Incoming= True;
        taskEmailMessage.TextBody = 'sfdc'+' '+'ref:'+c.Id;
        taskEmailMessage.EmailServiceParentId__c=c.Id;
        taskEmailMessage.ParentId =c.id;
        insert taskEmailMessage;
        c.status ='Closed';
        update c;
        EmailMessage emsg2 = new EmailMessage();
        emsg2.ToAddress =  'chidanand.Magadum@roofstock.com';
        emsg2.FromAddress = 'chidanand.Magadum@roofstock.com';
        emsg2.FromName = 'sfdc';
        emsg2.Subject = 'sfdc';
        emsg2.status = '2';
        emsg2.HtmlBody = 'sfdc'+' '+'ref:'+c.Id;
        emsg2.Incoming= True;
        emsg2.TextBody = 'sfdc'+' '+'ref:'+c.Id;
        emsg2.EmailServiceParentId__c=c.Id;
        emsg2.ParentId =c.id;
        insert emsg2;
        Case cobj = [Select id,CaseNumber from case where id =:c.id];
        //EmailMessageHelper.sendEmailAlert(cobj.CaseNumber, 'Test@test.com', 'Streetlane Close');

        //EmailMessages.fromAddress(c.Id);
        //EmailMessages.emailServiceAddress(c.Id);
        
    }
}
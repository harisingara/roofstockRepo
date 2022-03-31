@isTest
public class EmailMessageInvestmentAccountTest {
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void EmailMessageInvestmentAccount1(){
        Account acc = new Account();
        acc.NAme='sfdc';
        insert acc;
        
        Investment_Account__c ia = new Investment_Account__c();
        ia.Name = 'sfdc';
        ia.Account__c = acc.Id;
        insert ia;
        
        Contact Con = new Contact();
        con.LastName = 'sample';
        con.Email = 'someaddress@email.com';
        Insert con;
        
        ATF_Work_Queue__c mtask = new ATF_Work_Queue__c();
        mtask.Subject__c = 'sfdc';
        mtask.Contact__c = con.Id;
        mtask.Investment_Account__c = ia.Id;
        insert mtask;
        
        EmailMessage taskEmailMessage = new EmailMessage();
        taskEmailMessage.ToAddress =  'chidanand.Magadum@roofstock.com';
        taskEmailMessage.FromAddress = 'chidanand.Magadum@roofstock.com';
        taskEmailMessage.FromName = 'sfdc';
        taskEmailMessage.Subject = 'sfdc';
        taskEmailMessage.status = '2';
        taskEmailMessage.HtmlBody = 'sfdc';
        taskEmailMessage.Incoming= True;
        taskEmailMessage.TextBody = 'sfdc';
        taskEmailMessage.My_Task__c =mtask.Id;
        insert taskEmailMessage;
        
        EmailMessagesInvestmentAccount.taskEmails(mtask.Id);
        EmailMessagesInvestmentAccount.IAEmails(ia.Id);
    }
    static testMethod void EmailMessageInvestmentAccount2(){
        Account acc = new Account();
        acc.NAme='sfdc';
        insert acc;
        
        Investment_Account__c ia = new Investment_Account__c();
        ia.Name = 'sfdc';
        ia.Account__c = acc.Id;
        insert ia;
        
        Contact Con = new Contact();
        con.LastName = 'sample';
        con.Email = 'someaddress@email.com';
        Insert con;
        
        ATF_Work_Queue__c mtask = new ATF_Work_Queue__c();
        mtask.Subject__c = 'sfdc';
        mtask.Contact__c = con.Id;
        mtask.Investment_Account__c = ia.Id;
        insert mtask;
        
        EmailMessage taskEmailMessage = new EmailMessage();
        taskEmailMessage.ToAddress =  'chidanand.Magadum@roofstock.com';
        taskEmailMessage.FromAddress = 'chidanand.Magadum@roofstock.com';
        taskEmailMessage.FromName = 'sfdc';
        taskEmailMessage.Subject = 'sfdc';
        taskEmailMessage.status = '2';
        taskEmailMessage.HtmlBody = 'sfdc';
        taskEmailMessage.Incoming= True;
        taskEmailMessage.TextBody = 'sfdc';
        taskEmailMessage.Investment_Account__c=ia.Id;
        insert taskEmailMessage;
        
        Attachment attachment = new Attachment();
        attachment.Name = 'sfdc';
        attachment.Body = Blob.valueOf('sfdc');
        attachment.ParentId = taskEmailMessage.Id;
        insert attachment;
        
        EmailMessagesInvestmentAccount.taskEmails(mtask.Id);
        EmailMessagesInvestmentAccount.IAEmails(ia.Id);
        EmailMessagesInvestmentAccount.emailBodyAttachment(taskEmailMessage.Id);
        EmailMessagesInvestmentAccount.emailBody(taskEmailMessage.Id);
        
        
    }
}
@isTest
public class EmailMessagesInvestmentAccountTest {
	static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void EmailMessagesInvestmentAccount1(){
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
        
        ATF_Work_Queue__c awq = new ATF_Work_Queue__c();
        awq.Investment_Account__c = ia.Id;
        awq.Contact__c = con.Id;
        insert awq;
        
        EmailMessage taskEmailMessage = new EmailMessage();
        taskEmailMessage.ToAddress =  'chidanand.Magadum@roofstock.com';
        taskEmailMessage.FromAddress = 'chidanand.Magadum@roofstock.com';
        taskEmailMessage.FromName = 'sfdc';
        taskEmailMessage.Subject = 'sfdc';
        taskEmailMessage.status = '2';
        taskEmailMessage.HtmlBody = 'sfdc'+' '+'ref:'+awq.Id;
        taskEmailMessage.Incoming= True;
        taskEmailMessage.TextBody = 'sfdc'+' '+'ref:'+awq.Id;
        taskEmailMessage.EmailServiceParentId__c=awq.Id;
        taskEmailMessage.My_Task__c = awq.Id;
        insert taskEmailMessage;
        
        EmailMessagesInvestmentAccount.taskEmails(awq.Id);
        EmailMessagesInvestmentAccount.IAEmails(ia.Id);
    }
    static testMethod void EmailMessagesInvestmentAccount2(){
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
        
        ATF_Work_Queue__c awq = new ATF_Work_Queue__c();
        awq.Investment_Account__c = ia.Id;
        awq.Contact__c = con.Id;
        insert awq;
        
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
        taskEmailMessage.Investment_Account__c = ia.Id;
        insert taskEmailMessage;
        
        //EmailMessagesInvestmentAccount.taskEmails(ia.Id);
        EmailMessagesInvestmentAccount.IAEmails(ia.Id);
    }
    
    static testMethod void EmailMessagesInvestmentAccount3(){
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
        
        ATF_Work_Queue__c awq = new ATF_Work_Queue__c();
        awq.Investment_Account__c = ia.Id;
        awq.Contact__c = con.Id;
        insert awq;
        
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
        taskEmailMessage.Investment_Account__c = ia.Id;
        insert taskEmailMessage;
        
        //EmailMessagesInvestmentAccount.taskEmails(ia.Id);
        //EmailMessagesInvestmentAccount.IAEmails(ia.Id);
        EmailMessagesInvestmentAccount.emailBodyAttachment(taskEmailMessage.Id);
        EmailMessagesInvestmentAccount.emailBody(taskEmailMessage.Id);
    }
}
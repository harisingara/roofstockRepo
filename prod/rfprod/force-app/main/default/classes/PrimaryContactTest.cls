@isTest
public class PrimaryContactTest {
    
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void primaryContact1() {
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
        
        Investment_Account_Contact_Role__c iacr = new Investment_Account_Contact_Role__c();
        iacr.Investment_Account__c = ia.Id;
        iacr.Contact__c = con.Id;
        insert iacr;
        
        ATF_Work_Queue__c wq = new ATF_Work_Queue__c();
        wq.Investment_Account__c = ia.Id;
        wq.Contact__c = con.Id;
        insert wq;
        
        EmailMessage em = new EmailMessage();
        em.Investment_Account__c = ia.Id;
        em.EmailServiceParentId__c = ia.Id;
        em.Subject = 'sfdc';
        em.TextBody = 'sfdc';
        em.ToAddress = 'chidanandsfdc@gmail.com';
        insert em;
        PrimaryContact.investmentAccount(em.Id);
        PrimaryContact.investmentAccountContacts(ia.Id,ia.Id);
    }
    static testMethod void primaryContact2() {
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
        
        Investment_Account_Contact_Role__c iacr = new Investment_Account_Contact_Role__c();
        iacr.Investment_Account__c = ia.Id;
        iacr.Contact__c = con.Id;
        insert iacr;
        
        ATF_Work_Queue__c wq = new ATF_Work_Queue__c();
        wq.Investment_Account__c = ia.Id;
        wq.Contact__c = con.Id;
        insert wq;
        
        EmailMessage em = new EmailMessage();
        em.Investment_Account__c = ia.Id;
        em.EmailServiceParentId__c = ia.Id;
        em.Subject = 'sfdc';
        em.TextBody = 'sfdc';
        em.ToAddress = 'chidanandsfdc@gmail.com';
        insert em;
        PrimaryContact.investmentAccount(wq.Id);
        PrimaryContact.investmentAccountContacts(ia.Id,ia.Id);
    }
    static testMethod void primaryContact3() {
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
        
        Investment_Account_Contact_Role__c iacr = new Investment_Account_Contact_Role__c();
        iacr.Investment_Account__c = ia.Id;
        iacr.Contact__c = con.Id;
        insert iacr;
        
        ATF_Work_Queue__c wq = new ATF_Work_Queue__c();
        wq.Investment_Account__c = ia.Id;
        wq.Contact__c = con.Id;
        insert wq;
        
        EmailMessage em = new EmailMessage();
        em.Investment_Account__c = ia.Id;
        em.EmailServiceParentId__c = wq.Id;
        em.Subject = 'sfdc';
        em.TextBody = 'sfdc';
        em.ToAddress = 'chidanandsfdc@gmail.com';
        insert em;
        PrimaryContact.investmentAccount(ia.Id);
        PrimaryContact.investmentAccountContacts(ia.Id,ia.Id);
    }
        
	}
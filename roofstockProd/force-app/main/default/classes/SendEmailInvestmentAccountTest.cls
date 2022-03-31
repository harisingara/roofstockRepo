@isTest
public class SendEmailInvestmentAccountTest {
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void SendEmailInvestmentAccount1() {
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
        iacr.Role__c = 'Primary';
        insert iacr;
        
        SendEmailInvestmentAccount.primaryContactEmail(ia.Id);
        
    }
}
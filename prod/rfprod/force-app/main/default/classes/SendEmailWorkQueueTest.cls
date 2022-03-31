@isTest
public class SendEmailWorkQueueTest {
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void SendEmailWorkQueue1(){
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
        
        Investment_Account_Contact_Role__c iacr = new Investment_Account_Contact_Role__c();
        iacr.Investment_Account__c = ia.Id;
        iacr.Contact__c = con.Id;
        iacr.Role__c = 'Primary';
        insert iacr;
        
        SendEmailWorkQueue.investmentAccount(awq.Id);
        SendEmailWorkQueue.primaryContactEmail(ia.Id);
        
    }

}
@isTest
public class ATF_WorkQueueTest {
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void ATF_WorkQueueTest(){
        
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
        awq.Status__c = 'Resubmitted';        
        insert awq;
        
        ATF_Work_Queue__c awq2 = [select Id,Status__c,Outcome__c from ATF_Work_Queue__c where Id=:awq.Id];
        awq2.Status__c = 'Open';
        //awq2.Outcome__c = 'Approve for AI';
        update awq2;
        
        delete awq2;
        
    }
    static testMethod void ATF_WorkQueueTest2(){
        
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
        awq.Status__c = 'Open';        
        insert awq;
        try{
        ATF_Work_Queue__c awq2 = [select Id,Status__c,Outcome__c from ATF_Work_Queue__c where Id=:awq.Id];
        awq2.Status__c = 'Completed';
        awq2.Outcome__c = 'More info needed';
        update awq2;
        
        delete awq2;
        }
        catch(Exception ex){
            
        }
        
    }
}
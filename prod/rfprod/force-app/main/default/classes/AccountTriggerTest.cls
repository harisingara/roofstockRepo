@isTest
public class AccountTriggerTest {
    static{
        TestDataFactory.insertHierarchyCustomSettingData();
        
    }
    static testMethod void AccountTriggerTestInsert(){
        
        List<Account> accts = new List<Account>();
        
        for (Integer i = 0; i < 2; i++) {
            Account a = new Account(Name = 'TestAccount' + i,US_Resident__c='Yes');
            accts.add(a);
        }
        insert accts;
    }
    
    static testMethod void AccountTriggerTestUpdate(){
        Id retailSellerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        
        List<Account> accts = new List<Account>();
        
        for (Integer i = 0; i < 2; i++) {
            Account a = new Account(Name = 'TestAccount' + i,Domestic_or_International__c='International');
            accts.add(a);
        }
        insert accts;
        
        Opportunity opp = new Opportunity();
        opp.name='Test';
        opp.accountId = accts[0].Id;
        opp.RecordTypeId = retailSellerRecordTypeId;
        opp.CloseDate = System.today();
        opp.StageName = 'Published';
        insert opp;
        
        Account acc = [select Id,Domestic_or_International__c,US_Resident__c,Last_Call_Date__c,Phone from Account where Id=:accts[0].Id];
        acc.Domestic_or_International__c = null;
        acc.US_Resident__c = 'Yes';
        acc.Last_Call_Date__c=System.today();
        acc.Phone = '9876788767';
        update acc;
        
    }
    static testMethod void AccountTriggerTest() {
        TriggerDispatcher.forceException = true;
        try{
        Account acc = new Account();
        acc.Name = 'Salesforce';
        insert acc;
        }
        catch(Exception ex){
            
        }
}
}
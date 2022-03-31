@isTest
public class CoverageTriggerClass_Test {
    
    static{
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    @isTest
    public static void test() {
        Account acct = new Account(Name='TestAcct');
        insert acct;
        
        Opportunity opp = new Opportunity(Name='TestOpp', 
                                          StageName='Qualified Buyer', 
                                          CloseDate=Date.today(),
                                          Probability = 0,
                                          AccountId=acct.Id);
        
        Contact con = new Contact(LastName='TestCon');
        Lead le = new Lead(LastName='TestLead', 
                           Company='FakeCompany',
                           Status = '',
                           X1_Ideally_when_would_you_buy_your_first__c = Date.today() + 1);
        
        Task tk = new Task(Priority='Low', Status='Open', Subject='TestTask');
        Case cs = new Case(SuppliedEmail='test@email.com');
        
        insert opp;
        insert con;
        insert le;
        insert tk;
        insert cs;
    }

}
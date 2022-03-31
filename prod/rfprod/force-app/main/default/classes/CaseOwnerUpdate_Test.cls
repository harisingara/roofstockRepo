@isTest
public class CaseOwnerUpdate_Test {
    @isTest
    public static void test() {
        TestDataFactory.insertHierarchyCustomSettingData();
        User smenon = [SELECT Id FROM User WHERE Name = 'Sreekumar Menon' LIMIT 1];
        
        Case c = new Case();
        insert c;
        
        c.TempOwnerId__c = smenon.Id;
        update c;
    }
}
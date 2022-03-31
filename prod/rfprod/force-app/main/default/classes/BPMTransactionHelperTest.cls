@istest
public class BPMTransactionHelperTest {
    static{        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void BPMTransactionHelperTest(){
        Transaction__c trans = new Transaction__c();
        trans.name='Test';
        insert trans;
        BPMTransactionHelper.transactionRecord(trans.Id);
        BPMTransactionHelper.customMetadata();
    }

}
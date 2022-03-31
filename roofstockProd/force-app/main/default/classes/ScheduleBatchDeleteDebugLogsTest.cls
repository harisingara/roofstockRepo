@isTest
public class ScheduleBatchDeleteDebugLogsTest {
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void ScheduleBatchDeleteDebugLogs() {
        String CRON_EXP = '0 0 0 15 3 ? *';
        
        DebugLog__c dl = new DebugLog__c();
        dl.Class_Name__c = 'test';
        insert dl;
        Test.startTest();        
        String jobId = System.schedule('ScheduleBatchDeleteDebugLogsTest',  CRON_EXP, new ScheduleBatchDeleteDebugLogs());
        BatchDeleteDebugLogs debugBatch = new BatchDeleteDebugLogs();
        Id batchId = Database.executeBatch(debugBatch);
        Test.stopTest();

    }
}
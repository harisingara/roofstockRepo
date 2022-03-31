@IsTest
private class TransactionSnapshotWrapperTest{
    static{
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    @IsTest
    static void testsortTransactionSnapshots(){

        Transaction__c trans = new Transaction__c();
        insert trans;

        List<Transaction_Snapshot__c> snapshotList = new List<Transaction_Snapshot__c>();

        for (Integer i = 0; i < 2; i++){
            Transaction_Snapshot__c txnSnapshot = new Transaction_Snapshot__c();
            txnSnapshot.Transaction__c = trans.Id;
            txnSnapshot.HomeCode__c = String.valueOf(5-i);
            txnSnapshot.Sort_Order__C = i;
            insert txnSnapshot;
            snapshotList.add(txnSnapshot);
        }

        snapshotList = TransactionSnapshotWrapper.sortTransactionSnapshots(snapshotList);
        System.assertEquals('4', snapshotList.get(0).HomeCode__c);
    }

}
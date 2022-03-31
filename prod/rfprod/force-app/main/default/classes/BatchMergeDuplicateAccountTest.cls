@isTest
public class BatchMergeDuplicateAccountTest {
     static{
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void createPropertyUnitRestAPITest() {
        Duplicate_Batch_Job__c dbj = new Duplicate_Batch_Job__c();
        dbj.Name = 'Duplicate Job';
        dbj.status__c = 'Ready to Merge';
        insert dbj;
        
        List<Duplicate_Record_Group__c> drgList = new List<Duplicate_Record_Group__c>();
        
        for(Integer i =0;i<=3;i++){
            Duplicate_Record_Group__c drg = new Duplicate_Record_Group__c();
            drg.Duplicate_Batch_JoB__c = dbj.Id;
            drg.status__c = 'Ready to Merge';
            drgList.add(drg);
        }
        if(drgList.size()>0){
            insert drgList;
            
        }
        Id rsCustomerRecID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('1031 Buyer').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Sfdc';
        acc.RecordTypeId = rsCustomerRecID;
        insert acc;
        
        List<Duplicate_Records__c> drList = new List<Duplicate_Records__c>();
        for(Integer i =0;i<=3;i++){
            Duplicate_Records__c dr = new Duplicate_Records__c();
            dr.Duplicate_Record_Group__c = drgList[i].Id;
            dr.Is_Master__c = true;
            dr.Account__c = acc.Id;
            drList.add(dr);
        }
        if(drList.size()>0){
            insert drList;
        }        
        Test.startTest();
        
        BatchMergeDuplicateAccount bm = new BatchMergeDuplicateAccount();
        bm.customJobID = dbj.Id;
        DataBase.executeBatch(bm); 
        
        Test.stopTest();
        
        
    }
    static testMethod void createPropertyUnitRestAPITest2() {
        Duplicate_Batch_Job__c dbj = new Duplicate_Batch_Job__c();
        dbj.Name = 'Duplicate Job';
        dbj.status__c = 'Ready to Merge';
        insert dbj;
        
        
        Duplicate_Record_Group__c drg = new Duplicate_Record_Group__c();
        drg.Duplicate_Batch_JoB__c = dbj.Id;
        drg.status__c = 'Ready to Merge';
        insert drg;
        
        Id rsCustomerRecID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('1031 Buyer').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Sfdc';
        acc.RecordTypeId = rsCustomerRecID;
        insert acc;
        
        
        Duplicate_Records__c dr = new Duplicate_Records__c();
        dr.Duplicate_Record_Group__c = drg.Id;
        dr.Is_Master__c = true;
        dr.Account__c = acc.Id;
        insert dr;
        Test.startTest();
        
        BatchMergeDuplicateAccount bm = new BatchMergeDuplicateAccount();
        bm.customJobID = dbj.Id;
        DataBase.executeBatch(bm); 
        
        Test.stopTest();
        
    }
    
    static testMethod void createPropertyUnitRestAPITestMultipleDuplicateRecords() {
        Duplicate_Batch_Job__c dbj = new Duplicate_Batch_Job__c();
        dbj.Name = 'Duplicate Job';
        dbj.status__c = 'Ready to Merge';
        insert dbj;
        
        List<Duplicate_Record_Group__c> drgList = new List<Duplicate_Record_Group__c>();
        
        //for(Integer i =0;i<=3;i++){
        Duplicate_Record_Group__c drg = new Duplicate_Record_Group__c();
        drg.Duplicate_Batch_JoB__c = dbj.Id;
        drg.status__c = 'Ready to Merge';
        insert drg;
        //}
        //if(drgList.size()>0){
        //    insert drgList;
        
        // }
        Id rsCustomerRecID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Roofstock Customer').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Sfdc';
        acc.RecordTypeId = rsCustomerRecID;
        insert acc;
        
        List<Duplicate_Records__c> drList = new List<Duplicate_Records__c>();
        for(Integer i =0;i<=3;i++){
            Duplicate_Records__c dr = new Duplicate_Records__c();
            dr.Duplicate_Record_Group__c = drg.Id;
            dr.Is_Master__c = true;
            dr.Account__c = acc.Id;
            drList.add(dr);
        }
        if(drList.size()>0){
            insert drList;
        }        
        Test.startTest();
        
        BatchMergeDuplicateAccount bm = new BatchMergeDuplicateAccount();
        bm.customJobID = dbj.Id;
        DataBase.executeBatch(bm); 
        
        Test.stopTest();
        
        
    }
    
    static testMethod void createPropertyUnitRestAPINoMaster() {
        Duplicate_Batch_Job__c dbj = new Duplicate_Batch_Job__c();
        dbj.Name = 'Duplicate Job';
        dbj.status__c = 'Ready to Merge';
        insert dbj;
        
        List<Duplicate_Record_Group__c> drgList = new List<Duplicate_Record_Group__c>();
        
        //for(Integer i =0;i<=3;i++){
        Duplicate_Record_Group__c drg = new Duplicate_Record_Group__c();
        drg.Duplicate_Batch_JoB__c = dbj.Id;
        drg.status__c = 'Ready to Merge';
        insert drg;
        //}
        //if(drgList.size()>0){
        //    insert drgList;
        
        // }
        Id rsCustomerRecID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Roofstock Customer').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Sfdc';
        acc.RecordTypeId = rsCustomerRecID;
        insert acc;
        
        List<Duplicate_Records__c> drList = new List<Duplicate_Records__c>();
        for(Integer i =0;i<=3;i++){
            Duplicate_Records__c dr = new Duplicate_Records__c();
            dr.Duplicate_Record_Group__c = drg.Id;
            dr.Is_Master__c = false;
            dr.Account__c = acc.Id;
            drList.add(dr);
        }
        if(drList.size()>0){
            insert drList;
        }        
        Test.startTest();
        
        BatchMergeDuplicateAccount bm = new BatchMergeDuplicateAccount();
        bm.customJobID = dbj.Id;
        DataBase.executeBatch(bm); 
        
        Test.stopTest();
        
        
    }
    
    static testMethod void createPropertyUnitRestAPIException() {
        try{
            Duplicate_Batch_Job__c dbj = new Duplicate_Batch_Job__c();
            dbj.Name = 'Duplicate Job';
            dbj.status__c = 'Ready to Merge';
            insert dbj;
            Test.startTest();
            BatchMergeDuplicateAccount bm = new BatchMergeDuplicateAccount();
            bm.customJobID = dbj.Id; 
            DataBase.executeBatch(bm); 
            Database.BatchableContext BC;    
            bm.execute(BC, null);
            Test.stopTest();
        }
        catch(Exception ex){
            
        }
        
    }
    
}
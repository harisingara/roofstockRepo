@isTest
public class BatchMergeDuplicateContactTest {
    static{
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    
    static testMethod void BatchMergeDuplicateContactTest() {
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
        
        Contact con = new Contact();
        con.LastName = 'Sfdc';
        insert con;
        
        List<Duplicate_Records__c> drList = new List<Duplicate_Records__c>();
        for(Integer i =0;i<=3;i++){
            Duplicate_Records__c dr = new Duplicate_Records__c();
            dr.Duplicate_Record_Group__c = drgList[i].Id;
            dr.Is_Master__c = true;
            dr.Contact__c = con.Id;
            drList.add(dr);
        }
        if(drList.size()>0){
            insert drList;
        }        
        Test.startTest();
        
        BatchMergeDuplicateContact bm = new BatchMergeDuplicateContact();
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
        
        Contact con = new Contact();
        con.LastName = 'Sfdc';
        insert con;
        
        
        Duplicate_Records__c dr = new Duplicate_Records__c();
        dr.Duplicate_Record_Group__c = drg.Id;
        dr.Is_Master__c = true;
        dr.Contact__c = con.Id;
        insert dr;
        Test.startTest();
        
        BatchMergeDuplicateContact bm = new BatchMergeDuplicateContact();
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
        
        Contact con = new Contact();
        con.LastName = 'Sfdc';
        insert con;
        
        List<Duplicate_Records__c> drList = new List<Duplicate_Records__c>();
        for(Integer i =0;i<=3;i++){
            Duplicate_Records__c dr = new Duplicate_Records__c();
            dr.Duplicate_Record_Group__c = drg.Id;
            dr.Is_Master__c = true;
            dr.Contact__c = con.Id;
            drList.add(dr);
        }
        if(drList.size()>0){
            insert drList;
        }        
        Test.startTest();
        
        BatchMergeDuplicateContact bm = new BatchMergeDuplicateContact();
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
        
        Contact con = new Contact();
        con.LastName = 'Sfdc';
        insert con;
        
        List<Duplicate_Records__c> drList = new List<Duplicate_Records__c>();
        for(Integer i =0;i<=3;i++){
            Duplicate_Records__c dr = new Duplicate_Records__c();
            dr.Duplicate_Record_Group__c = drg.Id;
            dr.Is_Master__c = false;
            dr.Contact__c = con.Id;
            drList.add(dr);
        }
        if(drList.size()>0){
            insert drList;
        }        
        Test.startTest();
        
        BatchMergeDuplicateContact bm = new BatchMergeDuplicateContact();
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
            BatchMergeDuplicateContact bm = new BatchMergeDuplicateContact();
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
@isTest
public class BatchProcessDuplicateAccountTest {
     static{
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void BatchProcessDuplicateAccountTest() {
        Id leasingCustomerRecID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('1031 Buyer').getRecordTypeId();
        
        Duplicate_Batch_Job__c dbj = new Duplicate_Batch_Job__c();
        dbj.Name = 'Duplicate Job';
        dbj.status__c = 'Ready to Merge';
        insert dbj;
        
        List<Account> accountList = new List<Account>();
        for(Integer i=0;i<10;i++){
            Account acc = new Account();
            acc.Name = 'sfdc'+i;
            acc.Roofstock_Account_ID__c = '1234';
            acc.RecordTypeId = leasingCustomerRecID;
            accountList.add(acc);
        }
        if(accountList.size()>0){
            insert accountList;
        }
        
        Test.startTest();
        BatchProcessDuplicateAccount bpda = new BatchProcessDuplicateAccount();
        bpda.customJobID = dbj.Id;
        DataBase.executeBatch(bpda); 
        Test.stopTest();
    }
    static testMethod void BatchProcessDuplicateAccountTest2() {
        Id leasingCustomerRecID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('1031 Buyer').getRecordTypeId();
        Profile prof = [select id from profile where name = 'System Administrator API'];
        User user = new User();
        user.firstName = 'test';
        user.lastName = 'test2';
        user.Alias = 'batman';
        user.profileId = prof.id;
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.TimeZoneSidKey='America/Chicago';
        user.username = 'test2188@test.com';
        user.EmailEncodingKey='UTF-8';
        user.email = 'test@test.com';
        insert user;
        system.runAs(user){
            Duplicate_Batch_Job__c dbj = new Duplicate_Batch_Job__c();
            dbj.Name = 'Duplicate Job';
            dbj.status__c = 'Ready to Merge';
            insert dbj;
            
            List<Account> accountList = new List<Account>();
            for(Integer i=0;i<10;i++){
                Account acc = new Account();
                acc.Name = 'sfdc'+i;
                acc.Roofstock_Account_ID__c = '1234';
                acc.RecordTypeId = leasingCustomerRecID;
                accountList.add(acc);
            }
            if(accountList.size()>0){
                insert accountList;
            }
            
            
            Test.startTest();
            BatchProcessDuplicateAccount bpda = new BatchProcessDuplicateAccount();
            bpda.customJobID = dbj.Id;
            DataBase.executeBatch(bpda); 
            Test.stopTest();
        }
    }
    static testMethod void BatchProcessDuplicateAccountTestException() {
        try{
            Duplicate_Batch_Job__c dbj = new Duplicate_Batch_Job__c();
            dbj.Name = 'Duplicate Job';
            dbj.status__c = 'Ready to Merge';
            insert dbj;
            Test.startTest();
            BatchProcessDuplicateAccount bm = new BatchProcessDuplicateAccount();
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
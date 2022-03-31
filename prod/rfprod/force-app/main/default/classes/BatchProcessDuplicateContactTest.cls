@isTest
public class BatchProcessDuplicateContactTest {
    static{
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void BatchProcessDuplicateAccountTest() {
        Id rsContactRecID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Roofstock Contact').getRecordTypeId();
        
        Duplicate_Batch_Job__c dbj = new Duplicate_Batch_Job__c();
        dbj.Name = 'Duplicate Job';
        dbj.status__c = 'Ready to Merge';
        insert dbj;
        
        List<Contact> contactList = new List<Contact>();
        for(Integer i=0;i<10;i++){
            Contact con = new Contact();
            con.LastName = 'sfdc'+i;
            con.BPM_Contact_Id__c = '1234';
            con.RecordTypeId = rsContactRecID;
            contactList.add(con);
        }
        if(contactList.size()>0){
            insert contactList;
        }
        
        Test.startTest();
        BatchProcessDuplicateContact bpdc = new BatchProcessDuplicateContact();
        bpdc.customJobID = dbj.Id;
        DataBase.executeBatch(bpdc); 
        Test.stopTest();
    }
    static testMethod void BatchProcessDuplicateContactTest2() {
        Id rsContactRecID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Roofstock Contact').getRecordTypeId();
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
            
            List<Contact> contactList = new List<Contact>();
            for(Integer i=0;i<10;i++){
                Contact con = new Contact();
                con.LastName = 'sfdc'+i;
                con.BPM_Contact_Id__c = '1234';
                con.RecordTypeId = rsContactRecID;
                contactList.add(con);
            }
            if(contactList.size()>0){
                insert contactList;
            }
            
            
            Test.startTest();
            BatchProcessDuplicateContact bpda = new BatchProcessDuplicateContact();
            bpda.customJobID = dbj.Id;
            DataBase.executeBatch(bpda); 
            Test.stopTest();
        }
    }
    static testMethod void BatchProcessDuplicateContactTestException() {
        try{
            Duplicate_Batch_Job__c dbj = new Duplicate_Batch_Job__c();
            dbj.Name = 'Duplicate Job';
            dbj.status__c = 'Ready to Merge';
            insert dbj;
            Test.startTest();
            BatchProcessDuplicateContact bm = new BatchProcessDuplicateContact();
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
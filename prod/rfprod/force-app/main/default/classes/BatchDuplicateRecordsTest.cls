@isTest
public class BatchDuplicateRecordsTest {
    static{
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void DuplicateContact() {
        Id rsContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Inspector').getRecordTypeId();
        Account a = new Account(Name = 'TestAccount');
        a.Roofstock_Account_ID__c = '33434';
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test@nowhere.com',
            BPM_Contact_Id__c = '3433345',
            HasOptedOutOfEmail =false,
            RecordTypeId = rsContact,
            AccountId = a.Id
        );
        insert c;
        c.Id = null; 
        insert c; 
        Test.startTest(); 
        RunDuplicateJob.executeContactDuplicateJob('Duplicate Contact Records TESTING = ing');
      //  RunDuplicateJob.executeContactDuplicateMergeJob([Select Id from Duplicate_Batch_Job__c LIMIT 1 ].Id);
        Test.stopTest(); 
    }
    static testMethod void DuplicateAccount() {
        Id rsContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Inspector').getRecordTypeId();
        Account a = new Account(Name = 'TestAccount');
        a.Roofstock_Account_ID__c = '33434';
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test@nowhere.com',
            BPM_Contact_Id__c = '3433345',
            HasOptedOutOfEmail =false,
            RecordTypeId = rsContact,
            AccountId = a.Id
        );
        insert c;
        a.Id = null; 
        insert a;
        Test.startTest(); 
        RunDuplicateJob.executeAccountDuplicateJob('Duplicate Contact Records TESTING = ing');
      //  RunDuplicateJob.executeAccountDuplicateMergeJob([Select Id from Duplicate_Batch_Job__c LIMIT 1 ].Id);
        Test.stopTest(); 
    }
    static testMethod void mergeContact() {
        Id rsContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Inspector').getRecordTypeId();
        Account a = new Account(Name = 'TestAccount');
        a.Roofstock_Account_ID__c = '33434';
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test@nowhere.com',
            BPM_Contact_Id__c = '3433345',
            HasOptedOutOfEmail =false,
            RecordTypeId = rsContact,
            AccountId = a.Id
        );
        insert c;
        c.Id = null; 
        insert c; 
        Id batchID ; 
        Test.startTest(); 
        RunDuplicateJob.executeContactDuplicateJob('Duplicate Contact Records TESTING = ing');
        batchID = [Select Id from Duplicate_Batch_Job__c LIMIT 1 ].Id;
        Test.stopTest(); 
        RunDuplicateJob.executeContactDuplicateMergeJob(batchID);
        List<Duplicate_Record_Group__c> resl = [Select Id from Duplicate_Record_Group__c];
        List<Duplicate_Record_Group__c> res = new List<Duplicate_Record_Group__c>{new Duplicate_Record_Group__c( 
                                              status__c = 'Ready to Merge', Duplicate_Batch_JoB__c = batchID)};
        insert res; 
        BatchMergeDuplicateContact obatch = new BatchMergeDuplicateContact();   
        obatch.customJobID = batchID;
        Database.BatchableContext BC;
        obatch.execute(BC,resl); 
        resl.addall(res); 
        obatch.execute(BC,resl); 
        obatch.execute(BC,res);
    }
    static testMethod void MergeAccount() {
        Id rsContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Inspector').getRecordTypeId();
        Account a = new Account(Name = 'TestAccount');
        a.Roofstock_Account_ID__c = '33434';
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test@nowhere.com',
            BPM_Contact_Id__c = '3433345',
            HasOptedOutOfEmail =false,
            RecordTypeId = rsContact,
            AccountId = a.Id
        );
        insert c;
        a.Id = null; 
        insert a;
        Id batchID  ;
        Test.startTest(); 
        RunDuplicateJob.executeAccountDuplicateJob('Duplicate Account Records TESTING = ing');
        batchID = [Select Id from Duplicate_Batch_Job__c LIMIT 1 ].Id;
        Test.stopTest(); 
        RunDuplicateJob.executeAccountDuplicateMergeJob(batchID);
        List<Duplicate_Record_Group__c> resl = [Select Id from Duplicate_Record_Group__c];
        List<Duplicate_Record_Group__c> res = new List<Duplicate_Record_Group__c>{new Duplicate_Record_Group__c( 
                                              status__c = 'Ready to Merge', Duplicate_Batch_JoB__c = batchID)};
        insert res; 
        BatchMergeDuplicateAccount obatch = new BatchMergeDuplicateAccount(); 
        obatch.customJobID = batchID;
        Database.BatchableContext BC;
        obatch.execute(BC,resl); 
        resl.addall(res); 
        obatch.execute(BC,resl); 
        obatch.execute(BC,res); 
    }
     static testMethod void MergeAccountscenario() {
        Id rsContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Inspector').getRecordTypeId();
        Account a = new Account(Name = 'TestAccount');
        a.Roofstock_Account_ID__c = '33434';
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test@nowhere.com',
            BPM_Contact_Id__c = '3433345',
            HasOptedOutOfEmail =false,
            RecordTypeId = rsContact,
            AccountId = a.Id
        );
        insert c;
        a.Id = null; 
        insert a;
        Id batchID  ;
        Test.startTest(); 
        RunDuplicateJob.executeAccountDuplicateJob('Duplicate Account Records TESTING = ing');
        batchID = [Select Id from Duplicate_Batch_Job__c LIMIT 1 ].Id;
        Test.stopTest(); 
        RunDuplicateJob.executeAccountDuplicateMergeJob(batchID);
        List<Duplicate_Record_Group__c> resl = [Select Id from Duplicate_Record_Group__c];
        List<Duplicate_Record_Group__c> res = new List<Duplicate_Record_Group__c>{new Duplicate_Record_Group__c( 
                                              status__c = 'Ready to Merge', Duplicate_Batch_JoB__c = batchID)};
        insert res; 
        BatchMergeDuplicateAccount obatch = new BatchMergeDuplicateAccount(); 
        obatch.customJobID = batchID;
        Database.BatchableContext BC;
        obatch.execute(BC,res);  
    }
}
public class RunDuplicateJob {
     
    public static void executeContactDuplicateJob(String DuplicateJobName){
    	Duplicate_Batch_Job__c oDupBatchJob = new Duplicate_Batch_Job__c(Name=DuplicateJobName); 
        oDupBatchJob.Status__c = 'Queued' ; 
        Insert oDupBatchJob;
        BatchProcessDuplicateContact obatch = new BatchProcessDuplicateContact(); 
        obatch.customJobID = oDupBatchJob.Id;
        Database.executeBatch(obatch,1); 
    }
    public static void executeAccountDuplicateJob(String DuplicateJobName){
    	Duplicate_Batch_Job__c oDupBatchJob = new Duplicate_Batch_Job__c(Name=DuplicateJobName); 
        oDupBatchJob.Status__c = 'Queued' ; 
        Insert oDupBatchJob;
        BatchProcessDuplicateAccount obatch = new BatchProcessDuplicateAccount(); 
        obatch.customJobID = oDupBatchJob.Id;
        Database.executeBatch(obatch,1); 
    }
    public static void executeAccountDuplicateMergeJob(Id DuplicateJobId){
    	Duplicate_Batch_Job__c oDupBatchJob = new Duplicate_Batch_Job__c(Id=DuplicateJobId); 
        oDupBatchJob.Status__c = 'Merge Queued' ; 
        Update oDupBatchJob;
        BatchMergeDuplicateAccount obatch = new BatchMergeDuplicateAccount(); 
        obatch.customJobID = oDupBatchJob.Id;
        Database.executeBatch(obatch,1); 
    }
    public static void executeContactDuplicateMergeJob(Id DuplicateJobId){
    	Duplicate_Batch_Job__c oDupBatchJob = new Duplicate_Batch_Job__c(Id=DuplicateJobId); 
        oDupBatchJob.Status__c = 'Merge Queued' ; 
        Update oDupBatchJob;
        BatchMergeDuplicateContact obatch = new BatchMergeDuplicateContact(); 
        obatch.customJobID = oDupBatchJob.Id;
        Database.executeBatch(obatch,1); 
    }
}
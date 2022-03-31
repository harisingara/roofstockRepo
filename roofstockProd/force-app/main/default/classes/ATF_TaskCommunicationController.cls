public class ATF_TaskCommunicationController {
    
	 @AuraEnabled(cacheable=true)
    public static List<ATF_Work_Queue__c> getTasks(string taskId) {
        ATF_Work_Queue__c oMyTask = [Select Id,Investment_Account__c , RecordtypeId from ATF_Work_Queue__c where id =: taskId LIMIT 1]; 
        return [SELECT Subject__c, outcome__c, CreatedDate FROM ATF_Work_Queue__c where 
                 id !=: oMyTask.Id AND Investment_Account__c =: oMyTask.Investment_Account__c 
                AND RecordtypeId =: oMyTask.RecordtypeId]; 
} 
}
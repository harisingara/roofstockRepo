public class TransactionTriggerHandler implements ITriggerHandler{
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //Check if the trigger is disabled from the transaction
    Public Boolean isDisabled(){
        return TriggerDisabled;
    }
    Public void beforeInsert(List<sObject> newRecordsList){
        TransactionHelper.setMilestone((List <Transaction__c>)newRecordsList);
    }
    
    Public void afterInsert(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        TransactionHelper.createTransactionStageHistory((List <Transaction__c>)newRecordsList);
        TransactionHelper.createTasks((List <Transaction__c>)newRecordsList, (Map<Id,Transaction__c>) newRecordsMap);
        //TransactionHelper.createTransationSnapshot((List <Transaction__c>)newRecordsList);
    }
    
    Public void beforeUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
           TransactionHelper.setMilestone((List <Transaction__c>)newRecordsList);
    }
    
    Public void afterUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        TransactionHelper.createJobForInspection((List <Transaction__c>)newRecordsList, (Map<Id,Transaction__c>) oldRecordsMap);
        TransactionHelper.updateTransactionStageHistory((List <Transaction__c>)newRecordsList, (Map<Id,Transaction__c>) oldRecordsMap);
        TransactionHelper.updatePropertyBPOTriggerDate((Map<Id,Transaction__c>) newRecordsMap, (Map<Id,Transaction__c>) oldRecordsMap);
        //TransactionHelper.sendSMS((List<Transaction__c>) newRecordsList, (Map<Id,Transaction__c>) oldRecordsMap);
        TransactionHelper.publishTransactionPlatformEventsAdhoc((List<Transaction__c>) newRecordsList,(Map<Id,Transaction__c>) oldRecordsMap);
        TransactionHelper.createTasks((List <Transaction__c>)newRecordsList, (Map<Id,Transaction__c>) oldRecordsMap);
    }
    
    
    Public void beforeDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    
    Public void afterDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
        
    }
    
    Public void afterUndelete(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        
    }
    
    
}
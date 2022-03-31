public with sharing class AccountTriggerHandler implements ITriggerHandler{
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //Check if the trigger is disabled from the transaction
    Public Boolean isDisabled(){
        return TriggerDisabled;
    }
    Public void beforeInsert(List<sObject> newRecordsList){
        AccountHelper.accountAutomation((List<Account>) newRecordsList,null);
        AccountHelper.processBlueBirdAccs((List<Account>) newRecordsList,null);

    }
    
    Public void afterInsert(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
    }
    
    Public void beforeUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        AccountHelper.accountAutomation((List<Account>) newRecordsList,(Map<Id,Account>) oldRecordsMap);
        AccountHelper.processBlueBirdAccs((List<Account>) newRecordsList,(Map<Id,Account>) oldRecordsMap);
    }
    
    Public void afterUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        AccountHelper.updateAssociatedOpportunities((List<Account>) newRecordsList,(Map<Id,Account>) oldRecordsMap);
    }
    
    Public void beforeDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterUndelete(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        
    }

}
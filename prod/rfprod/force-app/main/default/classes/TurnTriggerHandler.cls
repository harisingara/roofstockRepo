public class TurnTriggerHandler implements ITriggerHandler{
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //Check if the trigger is disabled from the transaction
    Public Boolean isDisabled(){
        return TriggerDisabled;
    }
    Public void beforeInsert(List<sObject> newRecordsList){
		TurnHelper.updatePriorMoveInDate((List<Turn__c>) newRecordsList);
    }
    
    Public void afterInsert(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        
    }
    
    Public void beforeUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        TurnHelper.updateLeasingAvailability((List<Turn__c>) newRecordsList);
    }
    
    Public void beforeDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterUndelete(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        
    }

}
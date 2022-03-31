public class PropertyTriggerHandler implements ITriggerHandler{
//Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //Check if the trigger is disabled from the transaction
    Public Boolean isDisabled(){
        return TriggerDisabled;
    }
    Public void beforeInsert(List<sObject> newRecordsList){
        PropertyHelper.syncBpmTransactionStatus((List<Property__c>) newRecordsList);
        PropertyHelper.populateTransactionLookup((List<Property__c>) newRecordsList,null);
        PropertyHelper.populatePropertyUnitBasedOnUnitRiid((List<Property__c>) newRecordsList);
    }
    
    Public void afterInsert(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){

    }
    
    Public void beforeUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        PropertyHelper.syncBpmTransactionStatus((List<Property__c>) newRecordsList);
        PropertyHelper.populateTransactionLookup((List<Property__c>) newRecordsList,(map<Id,Property__c>) oldRecordsMap);
    }
    
    Public void afterUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
    }
    
    
    Public void beforeDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    
    Public void afterDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterUndelete(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        
    }
}
public with sharing class PropertyUnitTriggerHandler implements ITriggerHandler{
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //Check if the trigger is disabled from the transaction
    Public Boolean isDisabled(){
        return TriggerDisabled;
    }
    Public void beforeInsert(List<sObject> newRecordsList){

    }
    
    Public void afterInsert(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        PropertyUnitHelper.updatePropertyUnitOnAcquisition((List<Property_Unit__c>) newRecordsList);
        PropertyUnitHelper.upsertJobTurn((Map<Id, Property_Unit__c>) newRecordsMap,new Map<Id,Property_Unit__c> { });
    }
    
    Public void beforeUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
    }
    
    Public void afterUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        PropertyUnitHelper.updateTurnStatus((List<Property_Unit__c>) newRecordsList,(Map<Id,Property_Unit__c>) oldRecordsMap);
        PropertyUnitHelper.updateUtilityStatus((List<Property_Unit__c>) newRecordsList,(Map<Id,Property_Unit__c>) oldRecordsMap);
        PropertyUnitHelper.planomaticOrder((List<Property_Unit__c>) newRecordsList,(map<id,Property_Unit__c>) oldRecordsMap);
        PropertyUnitHelper.upsertJobTurn((Map<Id, Property_Unit__c>) newRecordsMap,(Map<Id,Property_Unit__c>) oldRecordsMap);
        PropertyUnitHelper.updateRenewalOppStatus((Map<Id, Property_Unit__c>) newRecordsMap,(Map<Id,Property_Unit__c>) oldRecordsMap);
        PropertyUnitHelper.updateCheckStatus((List<Property_Unit__c>) newRecordsList,(Map<Id,Property_Unit__c>) oldRecordsMap);
    }
    
    Public void beforeDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterUndelete(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        
    }

}
public class InspectionTriggerHandler implements ITriggerHandler{
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //Check if the trigger is disabled from the transaction
    Public Boolean isDisabled(){
        return TriggerDisabled;
    }
    Public void beforeInsert(List<sObject> newRecordsList){
        //DiligenceHelper.oneToOneMapping((List<Diligence__c>)newRecordsList);
        InspectionHelper.oneToOneMapping((List<Inspection__c>)newRecordsList);
    }
    
    Public void afterInsert(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        // DiligenceHelper.oneToOneMapping((List<Diligence__c>)newRecordsList);
        InspectionHelper.inspectionCount((List<Inspection__c>)newRecordsList);
    }
    
    Public void beforeUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        InspectionHelper.sendStatusUpdateToBpm((Map<Id, Inspection__c>) oldRecordsMap, (Map<Id, Inspection__c>)newRecordsMap);
    }
    
    
    Public void beforeDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    
    Public void afterDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        //DiligenceHelper.diligenceCount((List<Diligence__c>)oldRecordsList);
        
        
    }
    
    Public void afterUndelete(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        
    }
    
    
}
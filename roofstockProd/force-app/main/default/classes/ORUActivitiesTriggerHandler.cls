public class ORUActivitiesTriggerHandler implements ITriggerHandler{
     //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //Check if the trigger is disabled from the transaction
    Public Boolean isDisabled(){
        return TriggerDisabled;
    }
    Public void beforeInsert(List<sObject> newRecordsList){
        
    }
    Public void afterInsert(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
    	ORUActivityHelper.processLeasingActivities((List<Opportunity_Rental_Unit_Activity__c>) newRecordsList);
       // ORUActivityHelper.createTask((List<Opportunity_Rental_Unit_Activity__c>) newRecordsList);
    }
    Public void beforeUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    Public void afterUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
    	ORUActivityHelper.processLeasingActivities((List<Opportunity_Rental_Unit_Activity__c>) newRecordsList);    
    }
    Public void beforeDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterUndelete(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        
    }

}
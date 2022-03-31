public class JobTriggerHandler implements ITriggerHandler{
	//Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //Check if the trigger is disabled from the transaction
    Public Boolean isDisabled(){
        return TriggerDisabled;
    }
    Public void beforeInsert(List<sObject> newRecordsList){
		//JobHelper.updatePriorMoveInDate((List<Job__c>) newRecordsList); //[KM] - 12/21/2021 - Commented for job turn logic for PMC2022-100
		JobHelper.updateJobSequence((List<Job__c>) newRecordsList); 
	}
    
    Public void afterInsert(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        //JobHelper.updatePropertyUnitFields((List<Job__c>) newRecordsList);
    }
    
    Public void beforeUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        //JobHelper.updateLeasingAvailability((List<Job__c>) newRecordsList); //[KM] - 12/21/2021 - Commented for job turn logic for PMC2022-100
        //JobHelper.updatePropertyUnitFields((List<Job__c>) newRecordsList);
		JobHelper.updatePropertyBPOTriggerDate((Map<Id,Job__c>) newRecordsMap, (Map<Id,Job__c>) oldRecordsMap);
    }
    
    Public void beforeDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterUndelete(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        
    }

}
/*
	Modified By: Anh Phan
	Modified Date: 11/25/2021
	Purpose: Added new method populateCaseAgeHours to calculate case age in hours based on business hours.

*/
public class CaseTriggerHandler implements ITriggerHandler{
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //Check if the trigger is disabled from the transaction
    Public Boolean isDisabled(){
        return TriggerDisabled;
    }
    Public void beforeInsert(List<sObject> newRecordsList){
        CaseHandler.CaseRoundRobinValidate((List<Case>)newRecordsList, null,null, null, 'isInsert');
        CaseHandler.filterEmailToCaseRecords((List<Case>)newRecordsList); 
        
        CaseHandler.updateCommunicationStatus((List<Case>)newRecordsList);
    }
    
    Public void afterInsert(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        
    }
    
    Public void beforeUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        CaseHandler.updateTransactionCase((List<Case>)newRecordsList,(Map<Id, Case>)oldRecordsMap);
        CaseHandler.CaseRoundRobinValidate((List<Case>)Trigger.new, null,(Map<Id, Case>)newRecordsMap, (Map<Id, Case>)Trigger.oldMap, 'isUpdate');
        
        CaseHandler.updateCommunicationStatus((List<Case>)newRecordsList);
        CaseHandler.updateCaseOwnerEmail((List<Case>)newRecordsList);
        
    }
    
    Public void afterUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        CaseOwnerUpdate.updateOwner((List<Case>)newRecordsList, 'isUpdate');
        //Anh Phan: New method to populate cage age hours
        CaseHandler.populateCaseAgeHours((List<Case>)newRecordsList);
    }
    
    Public void beforeDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterUndelete(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        
    }
    
}
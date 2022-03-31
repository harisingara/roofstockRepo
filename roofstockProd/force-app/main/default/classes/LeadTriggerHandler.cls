public class LeadTriggerHandler implements ITriggerHandler{
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //Check if the trigger is disabled from the transaction
    Public Boolean isDisabled(){
        return TriggerDisabled;
    }
    Public void beforeInsert(List<sObject> newRecordsList){
        LeadHelper.UpdateLeadRecordTypes((List<Lead>) newRecordsList); 
        LeadHelper.LeadroundRobin((List<Lead>) newRecordsList,null,null,null,'isInsert'); 
        LeadHelper.leadConversionBeforeUpdates((List<Lead>) newRecordsList);
        LeadHelper.updateBluebird((List<Lead>) newRecordsList);
        LeadHelper.recordTypeAssignment((List<Lead>) newRecordsList);
        LeadHelper.setCalendlyAE((List<Lead>) newRecordsList);
    }
    
    Public void afterInsert(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        LeadHelper.UpdateListingMarketAndYieldFutureAsync(newRecordsMap.keyset());
        LeadHelper.runAssignmentRules((List<Lead>) newRecordsList);
    }
    
    Public void beforeUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        LeadHelper.LeadroundRobin((List<Lead>) newRecordsList,(List<Lead>) oldRecordsList,(map<id,Lead>) newRecordsMap,(map<id,Lead>) oldRecordsMap,'isUpdate'); 
        LeadHelper.leadConversionBeforeUpdates((List<Lead>) newRecordsList); 
        LeadHelper.updateBluebird((List<Lead>) newRecordsList);
        
    }
    
    Public void afterUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        LeadHelper.UpdateListingMarketAndYieldFutureAsync(newRecordsMap.keyset());
        LeadHelper.UpdateOpportunityNameAfterLeadConversion(newRecordsMap.keyset());
        LeadHelper.UpdateLeasingOpportunityNameAfterLeadConversion(newRecordsMap.keyset());
        LeadHelper.leadConversionAfterUpdates((List<Lead>) newRecordsList);
        LeadHelper.transferTaskOwners((List<Lead>) newRecordsList,(map<id,Lead>) oldRecordsMap);
    }
    
    Public void beforeDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterUndelete(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        
    }
    
}
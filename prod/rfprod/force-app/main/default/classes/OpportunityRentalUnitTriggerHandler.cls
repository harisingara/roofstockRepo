public class OpportunityRentalUnitTriggerHandler implements ITriggerHandler{
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //Check if the trigger is disabled from the transaction
    Public Boolean isDisabled(){
        return TriggerDisabled;
    }
    Public void beforeInsert(List<sObject> newRecordsList){
        
    }
    Public void afterInsert(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        //Pass Filtered Leasing Ids
        Set<Id> updateListingIds = new Set<Id>(); 
        Set<Id> newOppIds = new Set<Id>();
        for (OpportunityRentalUnit__c newUnit : (List<OpportunityRentalUnit__c>) newRecordsList) {
            newOppIds.add(newUnit.Opportunity__c);
            if(newUnit.status__c == 'Lease Signed'){
                updateListingIds.add(newUnit.Leasing__c);
            }    
        }
        if(newOppIds.size()>0){
            OpportunityRentalUnitHelper.UpdateOpportunityRent((List<OpportunityRentalUnit__c>) newRecordsList);
            OpportunityRentalUnitHelper.UpdateOpportunityStatus((List<OpportunityRentalUnit__c>) newRecordsList);
            OpportunityRentalUnitHelper.UpdatePropertyAddressOnOpp((List<OpportunityRentalUnit__c>) newRecordsList);
            OpportunityRentalUnitHelper.UpdateOppRentalUnitStatus(updateListingIds);
        }
    } 
    Public void beforeUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    Public void afterUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        Map<id, String> oldOppRentalUnitStatus = new Map<id, String>();
        Set<Id> updateListingIds = new Set<Id>();
        Set<Id> newOppIds = new Set<Id>();
        for (OpportunityRentalUnit__c oldUnit : (List<OpportunityRentalUnit__c>) oldRecordsList) {
            oldOppRentalUnitStatus.put(oldUnit.id, oldUnit.Status__c);
        }
        for (OpportunityRentalUnit__c newUnit : (List<OpportunityRentalUnit__c>) newRecordsList) {
            newOppIds.add(newUnit.Opportunity__c);
            if(oldOppRentalUnitStatus.get(newUnit.id) != newUnit.status__c && newUnit.status__c == 'Lease Signed') {
                updateListingIds.add(newUnit.Leasing__c);
                
            }    
        }
        if (newOppIds.size() > 0) {
            OpportunityRentalUnitHelper.UpdateOppRentalUnitStatus(updateListingIds);
            OpportunityRentalUnitHelper.UpdateOpportunityStatus((List<OpportunityRentalUnit__c>) newRecordsList);
        }
    }
    Public void beforeDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterUndelete(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        
    }
    
}
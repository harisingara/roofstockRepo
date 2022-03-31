public class OpportunityTriggerHandler implements ITriggerHandler{
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //Check if the trigger is disabled from the transaction
    Public Boolean isDisabled(){
        return TriggerDisabled;
    }
    Public void beforeInsert(List<sObject> newRecordsList){
        opportunityHelper.marketBasedOwnerAssignment((List<Opportunity>) newRecordsList);
        opportunityHelper.updateOpportunityNameAndRoofstockRevenueOnInsert((List<Opportunity>) newRecordsList);
        opportunityHelper.updateOpportunityOwnerMirrorField((List<Opportunity>) newRecordsList);
        opportunityHelper.updateCampaignOnOpportunity((List<Opportunity>) newRecordsList); 
        opportunityHelper.procStgSubStgLeasingOppsIns((List<Opportunity>) newRecordsList);
    }
    
    Public void afterInsert(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        opportunityHelper.updateAccConOwnerBasedOnOppty((List<Opportunity>) newRecordsList);
        opportunityHelper.RetailBuyerClosedWonOptyCallout((List<Opportunity>) newRecordsList);
    }
    
    Public void beforeUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        opportunityHelper.updateRetailBuyerOpportunityStages((List<Opportunity>) newRecordsList,(Map<Id, Opportunity>) oldRecordsMap);
        //opportunityHelper.UpdateLeasingOpportunityOwnerByMarket((Map<Id, Opportunity>) oldRecordsMap, (List<Opportunity>) newRecordsList);
        opportunityHelper.leasingOpportunityUpdate((List<Opportunity>) newRecordsList, (Map<Id, Opportunity>) oldRecordsMap);
        opportunityHelper.updateOpportunityOwnerMirrorField((List<Opportunity>) newRecordsList);
        opportunityHelper.procStgSubStgLeasingOppsUpd((List<Opportunity>) newRecordsList, (Map<Id, Opportunity>) oldRecordsMap);
        opportunityHelper.assignLCToLeasingPrOppsUpd((List<Opportunity>) newRecordsList, (Map<Id,Opportunity>) oldRecordsMap);
    }
    
    Public void afterUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        opportunityHelper.RetailBuyerClosedWonOptyCallout((List<Opportunity>) newRecordsList);
        OpportunityHelper.updateORU((List<Opportunity>) newRecordsList, (Map<Id, Opportunity>) oldRecordsMap);
		OpportunityHelper.updateRetailSellerOpportunities((List<Opportunity>) newRecordsList, (Map<Id, Opportunity>) oldRecordsMap);
        OpportunityHelper.closeOpenTaskOnOpportunity((List<Opportunity>) newRecordsList);
        OpportunityHelper.updateOpportunityTeamMember((List<Opportunity>) newRecordsList);
        OpportunityHelper.leasingOpportunityUpdateORU((List<Opportunity>) newRecordsList);
        opportunityHelper.assignLCToLeasingSecOppsUpd((List<Opportunity>) newRecordsList, (Map<Id,Opportunity>) oldRecordsMap);
    }
    
    Public void beforeDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterUndelete(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        
    }

}
/*
	Modified By: Anh Phan
	Modified Date: 12/22/2021
	Purpose: Created new method to populate First Auto Showing date field on Rental Listing to calculate Days on Market
------------------------------------------------------------------------------------------------------------------------
	Modified By:
	Modified Date:
	Purpose: 
*/

public class RentalListingTriggerHandler implements ITriggerHandler{
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //Check if the trigger is disabled from the transaction
    Public Boolean isDisabled(){
        return TriggerDisabled;
    }
    Public void beforeInsert(List<sObject> newRecordsList){
        RentalListingHelper.getPlanomaticOrderInfo((List<Rental_Listing__c>) newRecordsList);
        
        RentalListingHelper.updateFirstLease((List<Rental_Listing__c>) newRecordsList);
    }
    
    Public void afterInsert(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
    	RentalListingHelper.updateRelevantDateOnPropertyUnit((List<Rental_Listing__c>) newRecordsList,null , true);
        RentalListingHelper.PlanomaticOrder((List<Rental_Listing__c>) newRecordsList);
    }
    
    Public void beforeUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
    	RentalListingHelper.updateORU((List<Rental_Listing__c>) newRecordsList,(Map<Id,Rental_Listing__c>)  oldRecordsMap); 
        RentalListingHelper.updateRelevantDateOnPropertyUnit((List<Rental_Listing__c>) newRecordsList,(Map<Id,Rental_Listing__c>)  oldRecordsMap , false);    
    }

    Public void beforeDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterUndelete(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        
    }

}
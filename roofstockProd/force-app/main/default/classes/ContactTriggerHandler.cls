public class ContactTriggerHandler implements ITriggerHandler{
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //Check if the trigger is disabled from the transaction
    Public Boolean isDisabled(){
        return TriggerDisabled;
    }
    Public void beforeInsert(List<sObject> newRecordsList){
        
    }
    
    Public void afterInsert(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
       ContactHelper.updateHubspotScoreFromContact((List<Contact>) newRecordsList,null);
       ContactHelper.updateMadeAnOfferDate((List<Contact>) newRecordsList);

    }
    
    Public void beforeUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
       RetailBuyerOfferMade.checkOffer((List<Contact>) newRecordsList,(Map<Id, Contact>) oldRecordsMap);
       //SF-88 - Update ORU
       ContactHelper.updateORU((List<Contact>) newRecordsList,(Map<Id, Contact>) oldRecordsMap); 
        
       ContactHelper.updateHubspotScoreFromContact((List<Contact>) newRecordsList,(Map<Id, Contact>) oldRecordsMap);
       ContactHelper.updateMadeAnOfferDate((List<Contact>) newRecordsList);
       
        ContactHelper.syncHSContactFields((List<Contact>) newRecordsList,(Map<Id, Contact>) oldRecordsMap);
    }
    
    
    Public void beforeDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }

    
    Public void afterDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterUndelete(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        
    }
    
    
}
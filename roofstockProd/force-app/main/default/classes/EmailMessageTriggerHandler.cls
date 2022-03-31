public class EmailMessageTriggerHandler implements ITriggerHandler{
//Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //Check if the trigger is disabled from the transaction
    Public Boolean isDisabled(){
        return TriggerDisabled;
    }
    Public void beforeInsert(List<sObject> newRecordsList){
       
    }
    
    Public void afterInsert(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        
        //Track Email Sent 
        //EmailMessageHelper.trackEmails(newRecordsMap.keySet(),GlobalConstants.EMAIL_TRACKING_STATUS_EMAIL_DELIVERED);
        EmailMessageHelper.updateCaseStatus(newRecordsList);
        EmailMessageHelper.updateEmailMsgTransaction(newRecordsList);
        //Anh Phan: Send email to user when case is closed
        EmailMessageHelper.validateClosedCase(newRecordsList);
    }
    
    Public void beforeUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
        EmailMessageHelper.updateEmailMsgTransaction(newRecordsList);
    }
    
    Public void afterUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        // EmailMessageHelper.updateEmailMsgTransaction(newRecordsList);
    }
    
    Public void beforeDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    Public void afterUndelete(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        
    }
}
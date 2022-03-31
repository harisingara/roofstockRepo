public class TaskTriggerHandler implements ITriggerHandler{
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //Check if the trigger is disabled from the transaction
    Public Boolean isDisabled(){
        return TriggerDisabled;
    }
    Public void beforeInsert(List<sObject> newRecordsList){
        TaskHelper.updateTaskType((List<Task>) newRecordsList);
        //TaskHelper.updateTaskLead((List<Task>) newRecordsList);
        TaskHelper.updateTaskOpportunity((List<Task>) newRecordsList);
        
        //askQuestion API
        TaskHelper.updateTaskOwner((List<Task>) newRecordsList);
    }
    
    Public void afterInsert(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        if(!System.isFuture()){
            TaskHelper.updateParentFromTasks((List<Task>) newRecordsList);        	  
            TaskHelper.updateParentCountFromTasks((List<Task>) newRecordsList);  
        }
        TaskHelper.IntercomChatUpdateLeadFromTask((List<Task>) newRecordsList);
        
        TaskHelper.appointmentCheck((List<Task>) newRecordsList);
        TaskHelper.updateStatusAndStatusReason((List<Task>) newRecordsList);
        TaskHelper.updateLastCallDateOnLead((List<Task>) newRecordsList);
        TaskHelper.leadSQLDate((List<Task>) newRecordsList);
        TaskHelper.updateLeadStatus((List<Task>) newRecordsList);
        TaskHelper.webinarRegistered((List<Task>) newRecordsList);
    }
    
    Public void beforeUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        TaskHelper.updateTaskType((List<Task>) newRecordsList);
        TaskHelper.updateTaskOpportunity((List<Task>) newRecordsList);    
    }
    
    Public void afterUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        if(!System.isFuture()){
            TaskHelper.updateParentCountFromTasks((List<Task>) newRecordsList); 
        }
        TaskHelper.IntercomChatUpdateLeadFromTask((List<Task>) newRecordsList);
        
        TaskHelper.appointmentCheck((List<Task>) newRecordsList);
        TaskHelper.updateStatusAndStatusReason((List<Task>) newRecordsList);
        TaskHelper.updateLeadStatus((List<Task>) newRecordsList);
        TaskHelper.webinarRegistered((List<Task>) newRecordsList);

    }
    
    
    Public void beforeDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        
    }
    
    
    Public void afterDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap){
        if(!System.isFuture()){
            TaskHelper.updateParentCountFromTasks((List<Task>) oldRecordsList);
        }
        
    }
    
    Public void afterUndelete(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap){
        
    }
    
    
}
trigger ATFWorkQueueTrigger on ATF_Work_Queue__c (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
try{
        
        TriggerDispatcher.run(new ATF_WorkQueueTriggerHandler(),'ATF_Work_Queue__c');
    }
    catch(Exception exe){
    
        DebugLogHandler.logAppException('ATFWorkQueueTrigger','ATF_WorkQueueTriggerHandler',exe.getMessage(),
                                        
                                        exe.getStackTraceString(),'Trigger');
        
        throw exe;
        
    }   
}
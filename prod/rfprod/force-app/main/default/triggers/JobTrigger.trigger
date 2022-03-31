trigger JobTrigger on Job__c (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    try{
        TriggerDispatcher.run(new JobTriggerHandler(),'Job__c');

    }
    catch(Exception exe){
        
        DebugLogHandler.logAppException('JobTrigger','JobTriggerHandler',exe.getMessage(),
                                        
                                        exe.getStackTraceString(),'Trigger');
        
        throw exe;
        
    }
}
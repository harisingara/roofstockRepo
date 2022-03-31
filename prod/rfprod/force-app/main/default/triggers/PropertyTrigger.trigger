trigger PropertyTrigger on Property__c (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    try{
        System.debug('=EventTrigger=');
        TriggerDispatcher.run(new PropertyTriggerHandler(),'Event');
    }
    catch(Exception exe){
        
        DebugLogHandler.logAppException('PropertyTrigger','PropertyTriggerHandler',exe.getMessage(),
                                        
                                        exe.getStackTraceString(),'Trigger');
        
        throw exe;
        
    }
}
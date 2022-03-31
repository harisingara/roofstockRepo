trigger EventTrigger on Event (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    try{
        System.debug('=EventTrigger=');
        TriggerDispatcher.run(new EventTriggerHandler(),'Event');
    }
    catch(Exception exe){
        
        DebugLogHandler.logAppException('EventTrigger','EventTriggerHandler',exe.getMessage(),
                                        
                                        exe.getStackTraceString(),'Trigger');
        
        throw exe;
        
    }
}
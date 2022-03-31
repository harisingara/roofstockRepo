trigger AccountTrigger on Account (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    try{
        
        TriggerDispatcher.run(new AccountTriggerHandler(),'Account');
    }
    catch(Exception exe){
    
        DebugLogHandler.logAppException('AccountTrigger','AccountTriggerHandler',exe.getMessage(),
                                        
                                        exe.getStackTraceString(),'Trigger');
        
        throw exe;
        
    }   
}
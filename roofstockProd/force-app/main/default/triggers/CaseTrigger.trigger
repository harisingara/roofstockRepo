trigger CaseTrigger on Case (before insert, before update, after insert, after update) {
    try{
    TriggerDispatcher.run(new CaseTriggerHandler(),'Case');
    }catch(Exception exe){
        DebugLogHandler.logAppException('CaseTrigger','CaseTriggerHandler',exe.getMessage(),
                                        
                                        exe.getStackTraceString(),'Trigger');
        
        throw exe;
        
    }
}
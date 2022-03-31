trigger TurnTrigger on Turn__c(before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    try{
        
        TriggerDispatcher.run(new TurnTriggerHandler(),'Turn__c');
    }
    catch(Exception exe){
        
        DebugLogHandler.logAppException('TurnTrigger ','TurnTrigger Handler',exe.getMessage(),
                                        
                                        exe.getStackTraceString(),'Trigger');
        
        throw exe;
        
    }   
}
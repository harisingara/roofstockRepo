trigger TransactionTrigger on Transaction__c (before insert, after insert, before update, after update) {
    try{
        TriggerDispatcher.run(new TransactionTriggerHandler(),'Transaction__c');
    }
    catch(Exception exe){
        
        DebugLogHandler.logAppException('TransactionTrigger','TransactionTriggerHandler',exe.getMessage(),
                                        
                                        exe.getStackTraceString(),'Trigger');
        
        throw exe;
        
    }

}
trigger FeedItemTrigger on FeedItem(before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    try{
        TriggerDispatcher.run(new FeedItemTriggerHandler(),'Task');
    }
    catch(Exception exe){
        
        DebugLogHandler.logAppException('FeedItemTrigger','FeedItemTriggerHandler',exe.getMessage(),
                                        
                                        exe.getStackTraceString(),'Trigger');
        
        throw exe;
        
    }
    
}
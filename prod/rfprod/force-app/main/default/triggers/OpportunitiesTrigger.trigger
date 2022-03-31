trigger OpportunitiesTrigger on Opportunity (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    try{
        
        TriggerDispatcher.run(new OpportunityTriggerHandler(),'Opportunity');
    }
    catch(Exception exe){
        
        DebugLogHandler.logAppException('OpportunitiesTrigger','OpportunityTriggerHandler',exe.getMessage(),
                                        
                                        exe.getStackTraceString(),'Trigger');
        
        throw exe;
        
    }   
}
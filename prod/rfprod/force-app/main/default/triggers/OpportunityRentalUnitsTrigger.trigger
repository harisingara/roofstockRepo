trigger OpportunityRentalUnitsTrigger on OpportunityRentalUnit__c (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    try{
    TriggerDispatcher.run(new OpportunityRentalUnitTriggerHandler(),'OpportunityRentalUnit__c');
    }
    catch(Exception exe){
        
        DebugLogHandler.logAppException('OpportunityRentalUnitsTrigger','OpportunityRentalUnitTriggerHandler',exe.getMessage(),
                                        
                                        exe.getStackTraceString(),'Trigger');
        
        throw exe;
        
    }   
}
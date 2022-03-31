trigger ORUActivitiesTrigger on Opportunity_Rental_Unit_Activity__c (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    try{
    TriggerDispatcher.run(new ORUActivitiesTriggerHandler(),'Opportunity_Rental_Unit_Activity__c');
    }
    catch(Exception exe){
        
        DebugLogHandler.logAppException('ORUActivitiesTrigger','ORUActivitiesTriggerHandler',exe.getMessage(),
                                        
                                        exe.getStackTraceString(),'Trigger');
        
        throw exe;
        
    }   
}
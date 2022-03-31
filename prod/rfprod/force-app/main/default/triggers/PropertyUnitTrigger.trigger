trigger PropertyUnitTrigger on Property_Unit__c (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
try{
    
    TriggerDispatcher.run(new PropertyUnitTriggerHandler(),'Property_Unit__c');
}
catch(Exception exe){

    DebugLogHandler.logAppException('PropertyUnitTrigger','PropertyUnitTriggerHandler',exe.getMessage(),
                                    
                                    exe.getStackTraceString(),'Trigger');
    
    throw exe;
    
}   
}
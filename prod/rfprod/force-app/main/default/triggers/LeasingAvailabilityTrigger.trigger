trigger LeasingAvailabilityTrigger on Leasing_Availability__c (before insert, before update, after insert, after update,before delete,after delete) {
    try{
        TriggerDispatcher.run(new LeasingAvailabilityTriggerHandler(),'Leasing_Availability__c');
    }catch(Exception exe){
        DebugLogHandler.logAppException('LeasingAvailabilityTrigger','LeasingAvailabilityTriggerHandler',exe.getMessage(),
                                                  exe.getStackTraceString(),'Trigger'); 
        throw exe;
    }
}
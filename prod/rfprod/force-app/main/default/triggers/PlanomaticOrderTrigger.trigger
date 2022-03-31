trigger PlanomaticOrderTrigger on Planomatic_Order__c (before insert, before update, after insert, after update,before delete,after delete) {
    try{
        TriggerDispatcher.run(new PlanomaticOrderTriggerHandler(),'Planomatic_Order__c');
    }catch(Exception exe){
        DebugLogHandler.logAppException('PlanomaticOrderTrigger','LeadTriggerHandler',exe.getMessage(),
                                                  exe.getStackTraceString(),'Trigger'); 
        throw exe;
    }
}
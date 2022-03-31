trigger LeadTrigger on Lead (before insert, before update, after insert, after update,before delete,after delete) {
   try{
        TriggerDispatcher.run(new LeadTriggerHandler(),'Lead');
    }catch(Exception exe){
   		DebugLogHandler.logAppException('LeadTrigger','LeadTriggerHandler',exe.getMessage(),
                                                  exe.getStackTraceString(),'Trigger'); 
        throw exe;
    }
}
trigger InspectionTrigger on Inspection__c (before insert,after insert,before update,after update,before delete,after delete,after undelete) {
	try{
        TriggerDispatcher.run(new InspectionTriggerHandler(),'Inspection__c');
    }
    catch(Exception exe){
        
        DebugLogHandler.logAppException('InspectionTrigger','InspectionTriggerHandler',exe.getMessage(),
                                        
                                        exe.getStackTraceString(),'Trigger');
        
        throw exe;
        
    }
}
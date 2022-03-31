trigger OpportunityTeamMemberTrigger on OpportunityTeamMember(before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    try{
        TriggerDispatcher.run(new OpportunityTeamMemberHandler(),'Task');
    }
    catch(Exception exe){
        
        DebugLogHandler.logAppException('OpportunityTeamMemberTrigger','OpportunityTeamMemberHandler',exe.getMessage(),
                                        
                                        exe.getStackTraceString(),'Trigger');
        
        throw exe;
        
    }
    
}
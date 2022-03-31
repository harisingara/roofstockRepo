public class OpportunityTeamMemberHelper {
   // Process Builder - OpportunityTeamMember: 
   	// 1. CS Check-In
    public static void CSCheckIn(List<OpportunityTeamMember> otmList){
        List<Task> taskList = new List<Task>();
        for(OpportunityTeamMember otm :otmList){
            if(otm.TeamMemberRole == 'CSR'){
                Task tsk = new Task();
                tsk.IsRecurrence = true;
                tsk.OwnerId = otm.UserId;
                tsk.Priority = 'Select One';
                tsk.RecurrenceEndDateOnly = Date.today() + 28;
                tsk.RecurrenceInterval = 7;
                tsk.RecurrenceStartDateOnly = Date.today() + 7;
                tsk.RecurrenceType = 'RecursDaily';
                tsk.Status = 'Open';
                tsk.Subject = 'CS Check-In';
                tsk.Type = 'Select One';
                tsk.whatId = otm.OpportunityId;
                taskList.add(tsk);
            }
        }
        if(taskList.size()>0){
            insert taskList;
        }
    }
    //2.Post-Transaction Follow-Up Tasks
    public static void postTransactionFollowUpTasks(List<OpportunityTeamMember> otmList){
        Map<String,String> memberOpIdMap = new Map<String,String>();
        for(OpportunityTeamMember otm :otmList){
            if(otm.OpportunityId!=null){
                memberOpIdMap.put(otm.Id,otm.OpportunityId);
            }
        }
        Map<String,String> opportunityStageMap = new Map<String,String>();
        List<Opportunity> matchingOpportunity = [select Id,StageName from Opportunity where Id IN:memberOpIdMap.values()];
        for(Opportunity opp :matchingOpportunity){
            opportunityStageMap.put(opp.Id,opp.StageName);
        }
		System.debug('=opportunityStageMap='+opportunityStageMap);        
        List<Task> taskList = new List<Task>();
        for(OpportunityTeamMember opportunityTeamMember:otmList){
            if(opportunityStageMap?.get(opportunityTeamMember.OpportunityId) == 'Closed Won' &&
              opportunityTeamMember.TeamMemberRole == 'CSR' &&
              opportunityTeamMember.CSR_Closed_Won__c == true){
                Task tsk = new Task();
                tsk.IsRecurrence = true;
                tsk.OwnerId = opportunityTeamMember.UserId;
                tsk.Priority = 'Select One';
                tsk.RecurrenceEndDateOnly = Date.today() + 120;
                tsk.RecurrenceInterval = 30;
                tsk.RecurrenceStartDateOnly = Date.today()+30;
                tsk.RecurrenceType = 'RecursDaily';
                tsk.Status = 'Open';
                tsk.Subject = 'Post-Transaction Follow-Up';
                tsk.Type = 'Select One';
                tsk.whatId = opportunityTeamMember.OpportunityId;
                taskList.add(tsk);
            }
        }
        if(taskList.size()>0){
            insert taskList;
        }
    }
}
//may 26
public class TaskHelper {
    static Map<String, String> keys = new Map<String, String>();
    static string SEARCH_FILTER_SAVED = 'Search Filter Saved';
    static string REGISTRATION_COMPLETED = 'Roofstock New User Registration';
    static string OUTBOUND_CALL_RECORDED = 'OBC';
    static string OUTBOUND_CALL_MADE = 'Call';
    static string LEASING = 'Leasing';
    
    static string TYPE_FEEDBACK = 'Feedback';
    
    
    public static void updateParentFromTasks(List<Task> newTasks) {
        LoadTypes();
        updateLeadsFromTask(newTasks); //update parent lead oject for newly created task
        updateOpportunitiesFromTask(newTasks); //update parent opportunity oject for newly created task
        updateContactsFromTask(newTasks);
        createOpportunityTasks(newTasks);
    }
    public static void updateParentCountFromTasks(List<Task> tasks) {
        LoadTypes();
        updateORUCountFromTask(tasks); //leasing records update feedback count!
    }
    private static void LoadTypes() {
        if (keys.isEmpty()) {
            //load only once
            Map<String, Schema.SobjectType> describe = Schema.getGlobalDescribe();
            for (String s : describe.keyset()) {
                keys.put(describe.get(s).getDescribe().getKeyPrefix(), s);
            }
        }
    }
    
    private static void updateORUCountFromTask(List<Task> tasks) {
        Set<id> Ids = new Set<id>();
        for (Task tk : tasks) {
            //add only opportunity records!
            if (tk.WhatId != null && keys.get(String.valueOf(tk.WhatId).substring(0, 3)) =='opportunityrentalunit__c') {
                Ids.add(tk.WhatId);
            }
        }
        
        if (ids.size() == 0) {
            return;
        }
        
        List<opportunityrentalunit__c> oru_list = new List<opportunityrentalunit__c>();
        
        //Map<id,opportunityrentalunit__c> oppMap2 = new Map<id,opportunityrentalunit__c>([Select Id,Feedback_Count__c from opportunityrentalunit__c Where Id in :Ids]);
        oru_list = [
            SELECT
            Id,
            Open_Feedback_Count__c,
            (
                SELECT Id
                FROM Tasks
                WHERE Status != 'Completed' AND type = :TYPE_FEEDBACK
            )
            FROM opportunityrentalunit__c
            WHERE Id IN :Ids
        ];
        
        for (opportunityrentalunit__c oru : oru_list) {
            if (oru_list.size() > 0)
                oru.Open_Feedback_Count__c = oru.Tasks.size();
            else
                oru.Open_Feedback_Count__c = 0;
        }
        
        if (!oru_list.isEmpty())
            update oru_list;
    }
    
    //for tasks unde ORU ,clone a similar task under the opp as well!
    private static void createOpportunityTasks(List<Task> tasks) {
        Set<id> oruIds = new Set<id>();
        for (Task tk : tasks) {
            //add only opportunity records!
            if (
                tk.WhatId != null &&
                keys.get(String.valueOf(tk.WhatId).substring(0, 3)) ==
                'opportunityrentalunit__c'
            ) {
                oruIds.add(tk.WhatId);
            }
        }
        System.debug(LoggingLevel.ERROR,'count' + oruIds);
        
        if (oruIds.size() == 0) {
            return;
        }
        
        List<opportunityrentalunit__c> oru_list = [
            SELECT
            Id, Opportunity__c 
            FROM opportunityrentalunit__c
            WHERE Id IN :oruIds
        ];
        
        Map<id,id> oruToOppMap = new  Map<id,id>();
        for (opportunityrentalunit__c oru : oru_list) {
            oruToOppMap.put(oru.id, oru.Opportunity__c);
        }
        
        List<Task> opp_tasks = new List<Task>();
        System.debug(LoggingLevel.ERROR,'tasks' + tasks);
        
        for (Task task : tasks) {
            if(task.subject.contains(LEASING)) {
                Task clonedTask = new Task();
                clonedTask.whoId =  task.whoId;
                clonedTask.whatId = oruToOppMap.get(task.whatId);  //assign to opp from oru
                clonedTask.subject =  task.subject;
                clonedTask.status=  task.status;
                clonedTask.ActivityDate  = task.ActivityDate ;
                
                System.debug(LoggingLevel.ERROR,'*** task to add' + task.whatId + oruToOppMap.get(task.whatId));
                
                opp_tasks.add(clonedTask);
            }
        } //for
        
        System.debug(LoggingLevel.ERROR,'opp_tasks' + opp_tasks);
        
        if (opp_tasks.size() > 0){
            insert opp_tasks;
        }
        
    }
    
    @TestVisible
    private static void updateOpportunitiesFromTask(List<Task> newTasks) {
        boolean bbcUpdate = false;
        
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Id leasingOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
        
        Set<id> Ids = new Set<id>();
        for (Task tk : newTasks) {
            //add only opportunity records!
            if (
                tk.WhatId != null &&
                keys.get(String.valueOf(tk.WhatId).substring(0, 3)) == 'Opportunity'
            ) {
                Ids.add(tk.WhatId);
            }
        }
        
        if (ids.size() == 0) {
            return;
        }
        
        Map<id, Opportunity> oppMap2 = new Map<id, Opportunity>(
            [SELECT Id, buy_box_complete_date__c,recordtypeid, stagename FROM Opportunity WHERE Id IN :Ids]
        );
        
        for (Task t : newTasks) {
            if (t.Subject != null && t.Subject.contains(SEARCH_FILTER_SAVED)) {
                Opportunity o = oppMap2.get(t.WhatId);
                //  if(l.buy_box_complete_date__c == null) {
                bbcUpdate = true; //there are some changes to updat!
                o.buy_box_complete_date__c = date.today();
                oppMap.put(o.id, o);
                // }
            }
        }
        
        for (Task t : newTasks) {
            if ((t.Subject != null && t.Subject.contains(OUTBOUND_CALL_MADE)) 
                || (t.Type != null && t.Type.contains(OUTBOUND_CALL_MADE))) { //TODO
                    Opportunity o = oppMap2.get(t.WhatId);
                    if(o.recordtypeid == leasingOppRTId && o.stagename == 'New') {
                        bbcUpdate = true; //there are some changes to updat!
                        o.stagename = 'Contacted';
                        oppMap.put(o.id, o);
                    }
                }
        }
        if (bbcUpdate)
            update oppMap.values();
    }
    
    private static void updateContactsFromTask(List<Task> newTasks) {
        boolean updatesFound = false;
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        
        Set<id> Ids = new Set<id>();
        for (Task tk : newTasks) {
            //add only Contact records!
            System.debug(LoggingLevel.ERROR,'count' + tk.WhoId + keys);
            if (
                tk.WhoId != null &&
                (keys.get(String.valueOf(tk.WhoId).substring(0, 3)) == 'Contact')
            ) {
                Ids.add(tk.WhoId);
            }
        }
        System.debug('count' + Ids.size());
        if (ids.size() == 0) {
            return;
        }
        Map<id, Contact> contactMap2 = new Map<id, Contact>(
            [SELECT Id, Last_Outbound_Call_Date__c FROM Contact WHERE Id IN :Ids]
        );
        
        for (Task t : newTasks) {
            if (t.Subject != null && t.Subject.contains(OUTBOUND_CALL_RECORDED)) {
                Contact l = contactMap2.get(t.WhoId);
                updatesFound = true; //there are some changes to updat!
                l.Last_Outbound_Call_Date__c = date.today();
                contactMap.put(l.id, l);
            }
        }
        
        if (updatesFound) {
            update contactMap.values();
        }
    }
    
    private static void updateLeadsFromTask(List<Task> newTasks) {
        boolean updatesFound = false;
        
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        
        Set<id> Ids = new Set<id>();
        for (Task tk : newTasks) {
            //add only Lead records!
            System.debug('count' + tk.WhoId + keys);
            if (
                tk.WhoId != null &&
                (keys.get(String.valueOf(tk.WhoId).substring(0, 3)) == 'Lead')
            ) {
                Ids.add(tk.WhoId);
            }
        }
        System.debug('count' + Ids.size());
        if (ids.size() == 0) {
            return;
        }
        Map<id, Lead> leadMap2 = new Map<id, Lead>(
            [
                SELECT
                Id,
                Last_Outbound_Call_Date__c,
                Registration_Date__c,
                buy_box_complete_date__c
                FROM Lead
                WHERE Id IN :Ids
            ]
        );
        
        for (Task t : newTasks) {
            if (t.Subject != null && t.Subject.contains(SEARCH_FILTER_SAVED)) {
                Lead l = leadMap2.get(t.WhoId);
                updatesFound = true; //there are some changes to updat!
                l.buy_box_complete_date__c = date.today();
                leadMap.put(l.id, l);
            }
            if (t.Subject != null && t.Subject.contains(REGISTRATION_COMPLETED)) {
                Lead l = leadMap2.get(t.WhoId);
                updatesFound = true; //there are some changes to updat!
                l.Registration_Date__c = date.today();
                leadMap.put(l.id, l);
            }
            if (t.Subject != null && t.Subject.contains(OUTBOUND_CALL_RECORDED)) {
                Lead l = leadMap2.get(t.WhoId);
                updatesFound = true; //there are some changes to updat!
                l.Last_Outbound_Call_Date__c = date.today();
                leadMap.put(l.id, l);
            }
        }
        
        if (updatesFound) {
            update leadMap.values();
        }
    }
    
    //IntercomChatUpdateLeadFromTask - Merged this trigger in trigger framework
    public static void IntercomChatUpdateLeadFromTask(List<Task> newRecords){
        List<Task> taskIds = [ SELECT WhoId
                              FROM Task
                              WHERE Subject LIKE '%Intercom%Chat%' AND
                              Status = 'Completed' AND
                              Id IN :newRecords];
        
        List<Id> leadIds = new List<Id>();
        
        for( Task t : taskIds )
        {
            leadIds.add( t.WhoId );
        }
        
        List<Lead> leadsToUpdate = [ SELECT Id, Intercom_Chat__c
                                    FROM Lead
                                    WHERE Id IN :leadIds ];
        
        List<Lead> updatedLeads = new List<Lead>();
        
        for( Lead leads : leadsToUpdate )
        {
            leads.Intercom_Chat__c = true;
            updatedLeads.add( leads );
        }
        
        update updatedLeads;
    }
    
    
    /* 
public static void inflateTest() {
Integer j = 0;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;    j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;    j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;    j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;    j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;
j++;

}
*/
    //Process Builder - Appointment Created (Outbound)
    public static void appointmentCheck(List<Task> newTaskList){
        Set<String> leadIdSet = new Set<String>();
        String appointment = 'Appt';
        for(Task tsk : newTaskList){
            if(tsk.Subject.containsIgnoreCase(appointment)) {
                if(tsk.WhoId!=null){
                    leadIdSet.add(tsk.whoId);
                }
            }
        }
        List<Lead> updateLeadList = new List<Lead>();
        List<Lead> matchingLeadList = [Select Id,Appointment__c from Lead where Id IN:leadIdSet];
        if(!matchingLeadList.isEmpty()){
            for(Lead ld : matchingLeadList){
                ld.Appointment__c = true;
                updateLeadList.add(ld);
            }
        }
        
        if(!updateLeadList.isEmpty()){
            update updateLeadList;
        }
        
    }
    //Process Builder - Appt Task Flips Activity to Appointment Type + Lead Status and Lead Status Reason to Appointment
    public static void updateTaskType(List<Task> newTaskList){
        String appointment = 'Appt';
        for(Task tsk :newTaskList){
            if(tsk.Subject.containsIgnoreCase(appointment)) {
                tsk.Type = 'Appointment';
            }
        }
    }
    public static void updateStatusAndStatusReason(List<Task> newTaskList){
        System.debug('=newTaskList='+newTaskList);
        Set<String> leadIdSet = new Set<String>();
        Set<String> contactIdSet = new Set<String>();
        String appointment = 'Appt';
        for(Task tsk :newTaskList){
            if(tsk.Subject.containsIgnoreCase(appointment)) {
                System.debug('=sub='+tsk.Subject);
                if(tsk.whoId!=null){
                    leadIdSet.add(tsk.WhoId);    
                }
            }
             //RET-3494 
             if(tsk.whoId!= null && String.valueOf(tsk.whoId).startsWith('003') && tsk.Subject != null && ( tsk.Subject.containsIgnoreCase(System.Label.RCCallConnect) || tsk.Subject.containsIgnoreCase(System.label.RCCallLeftVM) ) ){
                contactIdSet.add(tsk.whoId);
            }
        }
        if(!contactIdSet.isEmpty()){
            Set<id> accidSet = new Set<id>();
            for(Contact con: [Select id,AccountId from contact where id in : contactIdSet]){
                accidSet.add(con.AccountId);
            }
            if(!accidSet.isEmpty()){
                List<Account> accList = new List<Account>();
                for(Id accId:accIdSet){
                    Account acc= new Account();
                    acc.id = accId;
                    acc.Retail_Seller_Contacted__c = true;
                    accList.add(acc);

                }
                Database.update(accList, false);
             }
        }
        List<Lead> updateLeadList = new List<Lead>();
        List<Lead> matchingLeadList = [select Id,Status,No_Convert_Reason__c from Lead where Id IN:leadIdSet];
        for(Lead ld :matchingLeadList){
            ld.Status = 'Appointment';
            ld.No_Convert_Reason__c = 'Appointment';
            updateLeadList.add(ld);
        }
        if(!updateLeadList.isEmpty()){
            update updateLeadList;
        }
        
    }
    //Process Builder - Last Call Date - version 3
    public static void updateLastCallDateOnLead(List<Task> newTaskList){
        Set<String> whoIdSet = new Set<String>();
        Set<String> whatIdSet = new Set<String>();
        Set<String> accountIdSet = new Set<String>();
        
        for(Task tsk :newTaskList){
            if(tsk.Subject.containsIgnoreCase('Outreach') && tsk.Subject.containsIgnoreCase('Call')) {
                if(tsk.WhoId!=null){
                    whoIdSet.add(tsk.WhoId); 
                }
                if(tsk.whatId!=null){
                    whatIdSet.add(tsk.whatId); 
                }
            }
            if(tsk.Subject.containsIgnoreCase('RC Call') || tsk.Subject.containsIgnoreCase('Outbound') || tsk.Subject.containsIgnoreCase('Inbound')){
                if(tsk.WhoId!=null){
                    whoIdSet.add(tsk.WhoId); 
                }
                if(tsk.whatId!=null){
                    whatIdSet.add(tsk.whatId); 
                }
                if(tsk.AccountId!=null){
                    accountIdSet.add(tsk.AccountId);
                }
            }
           
            
        }
        
        List<Lead> updateLeadList = new List<Lead>();
        List<Contact> updateContactList = new List<Contact>();
        List<Account> updateAccountList = new List<Account>();
        List<Account> updateRelatedAccountList = new List<Account>();
        List<Opportunity> updateOpportunityList = new List<Opportunity>();
        //Lead
        List<Lead> matchingLeadList = [select Id,Last_Call_Date__c from Lead where Id IN:whoIdSet];       
        if(!matchingLeadList.isEmpty()){
            for(Lead ld : matchingLeadList){
                ld.Last_Call_Date__c = Date.today();
                updateLeadList.add(ld);
            }
        }
        if(!updateLeadList.isEmpty()){
            update updateLeadList;      
        }
        //Contact
        List<Contact> matchingContactList = [select Id,Last_Call_Date__c from Contact where Id IN:whoIdSet];       
        if(!matchingContactList.isEmpty()){
            for(Contact con : matchingContactList){
                con.Last_Call_Date__c = Date.today();
                updateContactList.add(con);
            }
        }
        if(!updateContactList.isEmpty()){
            update updateContactList;       
        }
        //Account as whatId
        List<Account> matchingAccountList = [select Id,Last_Call_Date__c from Account where Id IN:whatIdSet];       
        System.debug('=matchingAccountList='+matchingAccountList);
        if(!matchingAccountList.isEmpty()){
            for(Account acc : matchingAccountList){
                acc.Last_Call_Date__c = Date.today();
                updateAccountList.add(acc);
            }
        }
        
        System.debug('=updateAccountList='+updateAccountList);
        if(!updateAccountList.isEmpty()){
            update updateAccountList;       
        }
        //Opportunity as whatId
        List<Opportunity> matchingOpportunityList = [select Id,Last_Call_Date__c from Opportunity where Id IN:whatIdSet];       
        if(!matchingOpportunityList.isEmpty()){
            for(Opportunity opp : matchingOpportunityList){
                opp.Last_Call_Date__c = Date.today();
                updateOpportunityList.add(opp);
            }
        }
        if(!updateOpportunityList.isEmpty()){
            update updateOpportunityList;       
        }
        
        //Related Account
        List<Account> matchingRelatedAccountList = [select Id,Last_Call_Date__c from Account where Id IN:accountIdSet];       
        System.debug('=matchingRelatedAccountList='+matchingRelatedAccountList);
        if(!matchingRelatedAccountList.isEmpty()){
            for(Account relAcc : matchingRelatedAccountList){
                relAcc.Last_Call_Date__c = Date.today();
                updateRelatedAccountList.add(relAcc);
            }
        }
        
        System.debug('=updateRelatedAccountList='+updateRelatedAccountList);
        if(!updateRelatedAccountList.isEmpty()){
            update updateRelatedAccountList;        
        }
    }
    //Process Builder - Lead SQL Date
    public static void leadSQLDate(List<Task> newTaskList){
        Set<String> whoIdSet = new Set<String>();
        for(Task newTask : newTaskList){
            if(newTask.Type == 'Appointment'){
                whoIdSet.add(newTask.whoId);
            }
        }
        List<Lead> matchingLeadList = [select Id,BypassValidationForProcessBuilder__c,SQL_Date__c from Lead where Id IN:whoIdSet];
        List<Lead> updateLeads = new List<Lead>();
        for(Lead newLead :matchingLeadList){
            newLead.BypassValidationForProcessBuilder__c = true;
            newLead.SQL_Date__c = Date.today();
            updateLeads.add(newLead);
        }
        if(!updateLeads.isEmpty()){
            update updateLeads;
        }
    }
    
    //Process Builder - Update Lead Status Field
    public static void updateLeadStatus(List<Task> newTaskList){
        Set<String> whoIdSet = new Set<String>();
        for(Task newTask : newTaskList){
            if(newTask.Status == 'No-Show'){
                whoIdSet.add(newTask.whoId);
            }
        }
        List<Lead> matchingLeadList = [select Id,Status,No_Convert_Reason__c from Lead where Id IN:whoIdSet];
        System.debug('=matchingLeadList='+matchingLeadList);
        List<Lead> updateLeads = new List<Lead>();
        for(Lead newLead :matchingLeadList){
            System.debug('=matchingLeadList='+newLead.No_Convert_Reason__c);
            newLead.Status = 'Missed Appointment';
            newLead.No_Convert_Reason__c = '';
            updateLeads.add(newLead);
        }
        if(!updateLeads.isEmpty()){
            update updateLeads;
        }
    }
    
    //Process Builder - Task lookup Opp
    public static void updateTaskOpportunity(List<Task> newTaskList){
        for(Task newTask : newTaskList){
            if(newTask.WhatId!=null){
                String whatId = newTask.WhatId;
                if(whatId.startsWith('006')){
                    newTask.RelatedOpp__c = newTask.WhatId;
                }
            }
        }
    }
    //Process Builder - Webinar Registered
    public static void webinarRegistered(List<Task> newTaskList){
        Set<String> whoIdSet = new Set<String>();
        for(Task newTask : newTaskList){
            if(newTask.Subject.containsIgnoreCase('Covid')) {
                if(newTask.WhoId!=null){
                    whoIdSet.add(newTask.WhoId);
                }
            }
        }
        List<Lead> matchLeadList = [select Id,Webinar_Reg__c from Lead where ID IN:whoIdSet];
        List<Lead> updateLeadList = new List<Lead>();
        if(!matchLeadList.isEmpty()){
            for(Lead ld : matchLeadList){
                ld.Webinar_Reg__c = true;
                updateLeadList.add(ld);
            }
        }
        if(!updateLeadList.isEmpty()){
            update updateLeadList;
        }
    }
    
    public Static void updateTaskOwner(List<Task> newTaskList){
        Map<String, String> leadIdOwnerIdMap = new Map<String, String>();
        
        Set<String> whoIdSet = new Set<String>();
        for(Task tsk:newTaskList){
            String parentId = tsk.whoId;
            if(tsk.Task_from_Ask_Question_API__c && parentId.contains('00Q')){
                whoIdSet.add(tsk.WhoId);
            }
        }
        if(whoIdSet.size()>0){        
            List<Lead> leadList = [Select Id,OwnerId,Owner.Name from Lead where Id IN:whoIdSet];
            for(Lead ld:leadList){
                leadIdOwnerIdMap.put(ld.Id,ld.OwnerId);
            }
            for(Task tk:newTaskList){
                if(leadIdOwnerIdMap.containsKey(tk.WhoId)){
                    String Owner=leadIdOwnerIdMap.get(tk.WhoId);
                    if(Owner.startsWith('005')){
                        tk.OwnerId = leadIdOwnerIdMap.get(tk.WhoId);
                    }
                }
            }
            
        }
        
    }
    
}
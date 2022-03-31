@isTest
public class TaskTriggerTest {
    
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void TaskControllerInsert() {
        Lead l = new Lead();
        l.lastName = 'SFDC';
        l.Company = 'Salesforce';
        insert l;
        
        task t = new task();
        t.subject = 'ehhjhj';
        t.status  = 'Open';
        t.whoId = l.Id;
        //t.whatId='a0E0200000062TuEAI';
        insert t;
        
        
        
    }
    static testMethod void TaskControllerUpdate() {
        Lead l = new Lead();
        l.lastName = 'SFDC';
        l.Company = 'Salesforce';
        insert l;
        
        task t = new task();
        t.subject = 'SFDC';
        t.status  = 'Open';
        t.whoId = l.Id;
        insert t;
        Task task = [select Id from Task where Id =:t.Id];
        update task;
        
        Task task1 = [select Id from Task where Id =:task.Id];
        task1.Status ='Salesforce';
        update task1;
        
        Task task2 = [select Id from Task where Id =:task1.Id];
        task2.Status ='SAP';
        update task2;
        
        Task task3 = [select Id from Task where Id =:task1.Id];
        task3.Status ='SAP';
        update task3;
        
        Task task4 = [select Id from Task where Id =:task1.Id];
        task4.Status ='SAP';
        update task4;
        
    }
    static testMethod void TaskControllerDelete() {
        Lead l = new Lead();
        l.lastName = 'SFDC';
        l.Company = 'Salesforce';
        insert l;
        
        task t = new task();
        t.subject = 'SFDC';
        t.status  = 'Open';
        t.whoId = l.Id;
        insert t;
        Task task = [select Id from Task where Id =:t.Id];
        delete task;
    }
    
    static testMethod void TaskControllerException() {
        TriggerDispatcher.forceException = true;
        Lead l;
        try{
            l = new Lead();
            l.lastName = 'SFDC';
            l.Company = 'Salesforce';
           // insert l;
            
            task t = new task();
            t.subject = 'SFDC';
            t.status  = 'Open';
            //t.whoId = l.Id;
            
            insert t;
        }
        catch(Exception ex){
            System.debug('=='+l.Id);
        }
        
        
    }
    static testMethod void taskAppointmentCheck() {
        Lead l = new Lead();
        l.lastName = 'SFDC';
        l.Company = 'Salesforce';
        insert l;
        
        task t = new task();
        t.subject = 'My appts';
        t.status  = 'Open';
        t.whoId = l.Id;
        insert t;
    }
    static testMethod void lastCallDateOnLead() {
        Lead l = new Lead();
        l.lastName = 'SFDC';
        l.Company = 'Salesforce';
        insert l;
        
        task t = new task();
        t.subject = 'SFDC Outreach Call';
        t.status  = 'Open';
        t.whoId = l.Id;
        insert t;
    }
    static testMethod void lastCallDateOnLeadRCCall() {
        Lead l = new Lead();
        l.lastName = 'SFDC';
        l.Company = 'Salesforce';
        insert l;
        
        task t = new task();
        t.subject = 'SFDC RC Call';
        t.status  = 'Open';
        t.whoId = l.Id;
        insert t;
    }
    static testMethod void lastCallDateOnContactRCCall() {
        Contact con = new Contact();
        con.lastName = 'SFDC';
        insert con;
        
        task t = new task();
        t.subject = 'SFDC RC Call';
        t.status  = 'Open';
        t.whoId = con.Id;
        insert t;
    }
    static testMethod void lastCallDateOnOpportunityRCCall() {
        Opportunity opp = new Opportunity();
        opp.Name = 'SFDC';
        opp.CloseDate = System.today();
        opp.StageName = 'Closed Won';
        insert opp;
        
        task t = new task();
        t.subject = 'SFDC RC Call';
        t.status  = 'Open';
        t.whatId = opp.Id;
        insert t;
    }
    static testMethod void lastCallDateOnAccountOutreachAndCall() {
        Account acc = new Account();
        acc.Name = 'SFDC';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'SFDC';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Closed Won';
        insert opp;
        
        task t = new task();
        t.subject = 'SFDC Outreach And Call';
        t.status  = 'Open';
        t.whatId = opp.Id;
        insert t;
    }
    static testMethod void lastCallDateOnAccountRcCall() {
        Account acc = new Account();
        acc.Name = 'SFDC';
        insert acc;
        task t = new task();
        t.subject = 'SFDC inbound';
        t.status  = 'Open';
        t.whatId = acc.Id;
        insert t;
    }
    static testMethod void updateLeadStatus() {
        Lead l = new Lead();
        l.lastName = 'SFDC';
        l.Company = 'Salesforce';
        insert l;
        
        task t = new task();
        t.subject = 'SFDC';
        t.status  = 'No-Show';
        t.whoId = l.Id;
        insert t;
    }
    static testMethod void webinarRegistered() {
        Lead l = new Lead();
        l.lastName = 'SFDC';
        l.Company = 'Salesforce';
        insert l;
        
        task t = new task();
        t.subject = 'covid19';
        t.status  = 'new';
        t.whoId = l.Id;
        insert t;
        //TaskHelper.inflateTest();
    }
    static testMethod void searchFilterSaved() {
       Opportunity opp = new Opportunity();
        opp.Name = 'SFDC';
        opp.CloseDate = System.today();
        opp.StageName = 'Closed Won';
        insert opp;
        
        opportunityrentalunit__c oru = new opportunityrentalunit__c();
        oru.Opportunity__c = opp.Id;
        insert oru;
        
        task t = new task();
        t.subject = 'Search Filter Saved';
        t.whatId = oru.Id;
        insert t;
        
        List<Task> taskList = new List<Task>();
        taskList.add(t);
        TaskHelper.updateOpportunitiesFromTask(taskList);
    }
    static testMethod void Leasing() {
       Opportunity opp = new Opportunity();
        opp.Name = 'SFDC';
        opp.CloseDate = System.today();
        opp.StageName = 'Closed Won';
        insert opp;
        
        opportunityrentalunit__c oru = new opportunityrentalunit__c();
        oru.Opportunity__c = opp.Id;
        insert oru;
        
        task t = new task();
        t.subject = 'Leasing';
        t.whatId = oru.Id;
        insert t;
        
        List<Task> taskList = new List<Task>();
        taskList.add(t);
    }
    static testMethod void OBC() {
       Opportunity opp = new Opportunity();
        opp.Name = 'SFDC';
        opp.CloseDate = System.today();
        opp.StageName = 'Closed Won';
        insert opp;
        
        opportunityrentalunit__c oru = new opportunityrentalunit__c();
        oru.Opportunity__c = opp.Id;
        insert oru;
        
        task t = new task();
        t.subject = 'OBC';
        t.whatId = oru.Id;
        insert t;
        
        List<Task> taskList = new List<Task>();
        taskList.add(t);
    }
}
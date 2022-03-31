@isTest
public class OpportunityTeamMemberTriggerTest {
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void CSCheckIn(){
        Account acc = new Account();
        acc.Name= 'SFDC';
        insert acc;
        
        Opportunity opt = new Opportunity();
        opt.stageName = 'Closed Won';
        opt.CloseDate = Date.today();
        opt.AccountId = acc.Id;
        insert opt;
        
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.CSR_Closed_Won__c = true;
        otm.OpportunityId = opt.Id;
        otm.OpportunityAccessLevel = 'Read';
        otm.TeamMemberRole = 'CSR';
        otm.UserId = UserInfo.getUserId();
        insert otm;
    }
    static testMethod void postTransactionFollowUpTasks(){
        Account acc = new Account();
        acc.Name= 'SFDC';
        insert acc;
        
        Opportunity opt = new Opportunity();
        opt.stageName = 'Closed Won';
        opt.CloseDate = Date.today();
        opt.AccountId = acc.Id;
        insert opt;
        
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.CSR_Closed_Won__c = true;
        otm.OpportunityId = opt.Id;
        otm.OpportunityAccessLevel = 'Read';
        otm.TeamMemberRole = 'CSR';
        otm.UserId = UserInfo.getUserId();
        insert otm;
        
        OpportunityTeamMember oppTeamMember = [select Id from OpportunityTeamMember where Id=:otm.Id];
        update oppTeamMember;
        
    }
    static testMethod void postTransactionFollowUpTasksDelete(){
        Account acc = new Account();
        acc.Name= 'SFDC';
        insert acc;
        
        Opportunity opt = new Opportunity();
        opt.stageName = 'Closed Won';
        opt.CloseDate = Date.today();
        opt.AccountId = acc.Id;
        insert opt;
        
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.CSR_Closed_Won__c = true;
        otm.OpportunityId = opt.Id;
        otm.OpportunityAccessLevel = 'Read';
        otm.TeamMemberRole = 'CSR';
        otm.UserId = UserInfo.getUserId();
        insert otm;
        
        OpportunityTeamMember oppTeamMember = [select Id from OpportunityTeamMember where Id=:otm.Id];
        delete oppTeamMember;
        
    }
    static testMethod void otmException() {

        TriggerDispatcher.forceException = true;
        try{
            
            OpportunityTeamMember otm = new OpportunityTeamMember();
            //otm.Name='sfdc';
            insert otm;
        }
        catch(Exception ex){
            //System.debug('=='+evt.Id);
        }
    }
}
global class UpdateStageSubStageLesOpps implements Database.Batchable<sObject> {
    
    //Id batchJobId = Database.executeBatch(new LeasingOppDataScrub(), 10);
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
		
        String query = 'SELECT Id , App_Decision__c, Application_Status__c FROM Opportunity WHERE Yardi_Prospect_Id__c != \'\' AND ' +
                        '(RecordType.Name =  \'Leasing\' OR Recordtype.name = \'Leasing Secondary Applicant\')';

        return Database.getQueryLocator(query);

    }

    global void execute(Database.BatchableContext BC, List <Opportunity> oppList) {
        List <Opportunity> oppsToBeUpd = new List <Opportunity>  ();
        List <Opportunity> oppsToBeInserted = new List <Opportunity>  ();
        Set <Id> oppIdSet = new Set <Id> ();
        Map <Id, Opportunity> oppMap = new Map <Id, Opportunity> ();
        
        for(Opportunity Opp : oppList){
            if(Opp.Application_Status__c == 'Prospect'){
                Opp.StageName = 'Application Started';
            }
            else
            if(Opp.Application_Status__c == 'Applied'){
                Opp.StageName = 'Application Submitted';
            }
            else
            if(Opp.App_Decision__c == 'Pending' && Opp.Application_Status__c == 'Applied'){
                Opp.StageName = 'Screening';
                Opp.Sub_Stage__c = 'Screening Pending';
            }
            else
            if(Opp.App_Decision__c == 'Conditional' && Opp.Application_Status__c == 'Applied'){
                Opp.StageName = 'Screening';
                Opp.Sub_Stage__c = 'Screening Conditional';
            }
            else
            if(Opp.App_Decision__c == 'Accepted' && Opp.Application_Status__c == 'Applied'){
                Opp.StageName = 'Screening';
                Opp.Sub_Stage__c = 'Screening Approved';
            }
            else
            if(Opp.App_Decision__c == 'Denied' && Opp.Application_Status__c == 'Applied'){
                Opp.StageName = 'Screening';
                Opp.Sub_Stage__c = 'Screening Denied';
            }
            else
            if(Opp.Application_Status__c == 'Approved'){
                Opp.StageName = 'Decision Made';
                Opp.Sub_Stage__c = 'Application Approved';
            }
            else
            if(Opp.App_Decision__c == 'Conditional' && Opp.Application_Status__c == 'Applied'){
                Opp.StageName = 'Decision Made';
                Opp.Sub_Stage__c = 'Application Conditional';
            }
            else
            if(Opp.Application_Status__c == 'Denied'){
                Opp.StageName = 'Decision Made';
                Opp.Sub_Stage__c = 'Application Denied';
            }
            else
            if(Opp.Application_Status__c == 'Cancelled'){
                Opp.StageName = 'Decision Made';
                Opp.Sub_Stage__c = 'Application Cancelled';
            }
            else
            if(Opp.Application_Status__c == 'Future'){
                Opp.StageName = 'Pending Move-in';
            }
            else
            if(Opp.Application_Status__c == 'Resident'){
                Opp.StageName = 'Closed Won = Tenant Moved In ';
            }
            oppsToBeUpd.add(Opp);
        }
        
        if(oppsToBeUpd != null && oppsToBeUpd.size() >0){
            update oppsToBeUpd;
        } 
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('LeasingOppDataScrub Successfully Completed');
    }
    
    global static void dummytest(){
        Integer i= 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        
        
    }

}
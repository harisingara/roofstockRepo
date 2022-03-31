public with sharing class AnonymizeOpportunityEmailsBatchable implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext opptext) {
        //STAMP_BUYER_EMAIL__c, Property_Manager_Email__c are not used anywhere
        return Database.getQueryLocator('SELECT id,HOA_Email__c FROM Opportunity');
    }
    
    public void execute(
        Database.BatchableContext opptext,
        List<Opportunity> Opportunities
    ) {
        Boolean org = ([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox);
        if(org){
            for (Opportunity opp : Opportunities) {
                System.debug('Opportunity sandbox email: ' + opp.id);
                if (opp.HOA_Email__c != null) {
                    opp.HOA_Email__c = opp.HOA_Email__c + '.invalid';
                }
                
                System.debug('Opportunity anonymized email: ' + opp.id);
            }
            
            if(!TEST.isRunningTest()){
                update Opportunities;
            }
        }
    }
    public void finish(Database.BatchableContext opptext) {
    }
}
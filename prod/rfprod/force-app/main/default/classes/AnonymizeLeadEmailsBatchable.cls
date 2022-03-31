public with sharing class AnonymizeLeadEmailsBatchable implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(
            'SELECT id, email FROM Lead WHERE isConverted=false'
        );
    }
    
    public void execute(Database.BatchableContext context, List<Lead> leads) {
        Boolean org = ([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox);
        if(org){
            for (Lead l : leads) {
                System.debug('lead sandbox email: ' + l.email);
                if (l.email != null) {
                    l.email = l.email + '.invalid';
                }
                
                System.debug('lead anonymized email: ' + l.email);
            }
            
            update leads;
        }
    }
    
    public void finish(Database.BatchableContext context) {
    }
}
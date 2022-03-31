public with sharing class AnonymizeContactEmailsBatchable implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT id, email FROM Contact');
    }
    
    public void execute(
        Database.BatchableContext context,
        List<Contact> contacts
    ) {
        Boolean org = ([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox);
        if(org){
            for (Contact con : contacts) {
                System.debug('contact sandbox email: ' + con.email);
                if (con.email != null) {
                    con.email = con.email + '.invalid';
                }
                
                System.debug('contact anonymized email: ' + con.email);
            }
            
            update contacts;
        }
    }
    
    public void finish(Database.BatchableContext context) {
    }
}
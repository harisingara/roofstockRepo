public with sharing class AnonymizeAccountEmailsBatchable implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext acctext) {
        return Database.getQueryLocator(
            'SELECT id, Alternative_Email__c, Company_Email__c FROM Account'
        );
    }
    
    public void execute(
        Database.BatchableContext acctext,
        List<Account> Accounts
    ) {
        Boolean org = ([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox);
        if(org){
            for (Account acc : Accounts) {
                System.debug('Account sandbox email: ' + acc.id);
                if (acc.Company_Email__c != null) {
                    acc.Company_Email__c = acc.Company_Email__c + '.invalid';
                }
                if (acc.Alternative_Email__c != null) {
                    acc.Alternative_Email__c = acc.Alternative_Email__c + '.invalid';
                }
                System.debug('Account anonymized email: ' + acc.id);
            }
            
            update Accounts;
        }
    }
    public void finish(Database.BatchableContext acctext) {
    }
}
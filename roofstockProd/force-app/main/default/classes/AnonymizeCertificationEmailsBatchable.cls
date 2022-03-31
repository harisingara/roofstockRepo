public class AnonymizeCertificationEmailsBatchable implements Database.Batchable<SObject>{
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT id, Roofstock_Account_Coordinator_Email__c,Roofstock_Account_Executive_Email__c,Roofstock_Account_Manager_Email__c FROM Certification__c');
    }
    
    public void execute(
        Database.BatchableContext context,
        List<Certification__c> certifications
    ) {
        Boolean org = ([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox);
        if(org){
            for (Certification__c cert : certifications) {
                System.debug('contact sandbox email: ' + cert.Roofstock_Account_Coordinator_Email__c);
                if (cert.Roofstock_Account_Coordinator_Email__c != null) {
                    cert.Roofstock_Account_Coordinator_Email__c = cert.Roofstock_Account_Coordinator_Email__c + '.invalid';
                }
                if (cert.Roofstock_Account_Executive_Email__c != null) {
                    cert.Roofstock_Account_Executive_Email__c = cert.Roofstock_Account_Executive_Email__c + '.invalid';
                }
                if (cert.Roofstock_Account_Manager_Email__c != null) {
                    cert.Roofstock_Account_Manager_Email__c = cert.Roofstock_Account_Manager_Email__c + '.invalid';
                }
                
                
                System.debug('contact anonymized email: ' + cert.Roofstock_Account_Manager_Email__c);
            }
            
            update certifications;
        }
    }
    public void finish(Database.BatchableContext context) {
    }
}
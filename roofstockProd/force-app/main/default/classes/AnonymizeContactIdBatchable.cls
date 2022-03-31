public class AnonymizeContactIdBatchable implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT id,BPM_Contact_Id__c FROM Contact WHERE BPM_Contact_Id__c != Null');
    }
    
    public void execute(
        Database.BatchableContext context,
        List<Contact> Contacts
    ) {
        Boolean org = ([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox);
        if(org){
            for (Contact con : Contacts) {
                    con.BPM_Contact_Id__c = con.BPM_Contact_Id__c + '0';
            }
            
            update Contacts;
        }
    }
    
    public void finish(Database.BatchableContext context) {
    }

}
public class AnonymizeLeadIdBatchable implements Database.Batchable<SObject>{
	public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT id,BPM_Contact_Id__c,Roofstock_Account_ID__c FROM Lead WHERE (BPM_Contact_Id__c != Null OR Roofstock_Account_ID__c != Null) AND (isConverted = false)');
    }
    
    public void execute(
        Database.BatchableContext context,
        List<Lead> leads
    ) {
        Boolean org = ([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox);
        if(org){
            for (Lead ld : leads) {
                    ld.BPM_Contact_Id__c = ld.BPM_Contact_Id__c + '0';
                    ld.Roofstock_Account_ID__c = ld.Roofstock_Account_ID__c + '0';                
            }
            
            update leads;
        }
    }
    
    public void finish(Database.BatchableContext context) {
    }
}
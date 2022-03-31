public class AnonymizeAccountIdBatchable implements Database.Batchable<SObject> {
	public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT id,Roofstock_Account_ID__c FROM Account WHERE Roofstock_Account_ID__c !=Null');
    }
    
    public void execute(
        Database.BatchableContext context,
        List<Account> accounts
    ) {
        Boolean org = ([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox);
        if(org){
            for (Account acc : accounts) {
                    acc.Roofstock_Account_ID__c = acc.Roofstock_Account_ID__c + '0';
            }
            
            update accounts;
        }
    }
    
    public void finish(Database.BatchableContext context) {
    }
}
public class AnonymizePropertyIdBatchable implements Database.Batchable<SObject>{
	public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT id, PropertyId__c FROM Property2__c WHERE PropertyId__c != NULL');
    }
    
    public void execute(
        Database.BatchableContext context,
        List<Property2__c> properties
    ) {
        Boolean org = ([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox);
        if(org){
            for (Property2__c property2 : properties) {
                if (property2.PropertyId__c != null) {
                    property2.PropertyId__c = property2.PropertyId__c + '0';
                }
                
            }
            
            update properties;
        }
    }
    
    public void finish(Database.BatchableContext context) {
    }
}
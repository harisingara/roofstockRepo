public class AnonymizePropertyUnitIdBatchable implements Database.Batchable<SObject>{
	public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT id, PropertyUnitId__c FROM Property_Unit__c WHERE PropertyUnitId__c != Null');
    }
    
    public void execute(
        Database.BatchableContext context,
        List<Property_Unit__c> propertyUnits
    ) {
        Boolean org = ([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox);
        if(org){
            for (Property_Unit__c propertyUnit : propertyUnits) {
                if (propertyUnit.PropertyUnitId__c != null) {
                    propertyUnit.PropertyUnitId__c = propertyUnit.PropertyUnitId__c + '0';
                }
                
            }
            
            update propertyUnits;
        }
    }
    
    public void finish(Database.BatchableContext context) {
    }
}
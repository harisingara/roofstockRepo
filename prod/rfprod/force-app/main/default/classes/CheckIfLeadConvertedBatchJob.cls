public class CheckIfLeadConvertedBatchJob implements Database.Batchable<sObject> {
    public List<Lead> start(Database.BatchableContext BC)
    {
        List<Lead> res = [SELECT id,RecordType.name, IsConverted,Lead_Created_Date__c,createddate  
                            FROM lead 
                           WHERE RecordType.name='Retail Buyer' and IsConverted = False and Email != null and LastActivityDate = null
                                 and createddate = LAST_N_DAYS:61 and createddate < LAST_N_DAYS:60]; 
        system.debug('leads are::'+res);
        return res; 
    }
    public void execute(Database.BatchableContext BC, List<Lead> leads)
    {
        for(Lead ld : leads){
            ld.Trigger_60_Days_Survey__c = true;
        }
        update leads;
    }
    public void finish(Database.BatchableContext BC)
    {
        system.debug('Completed Batch Job');
    }

}
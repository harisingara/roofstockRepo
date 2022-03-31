@isTest
public class CheckIfLeadConvertedBatchJobTest {
	//static {        
      //  TestDataFactory.insertHierarchyCustomSettingData();
    //}
    
    @isTest(SeeAllData = true)
    static void checkBatch(){
        Id leadRecordtypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        system.debug('rec type'+leadRecordtypeId);

        Lead l = new Lead();
        l.lead_created_date__c = Date.today()-61;
        l.IsConverted = false;
        l.RecordTypeId = leadRecordtypeId;
        l.LastName = 'test lead new ';
        l.Company = 'test company new';
        insert l;
        
        
        CheckIfLeadConvertedBatchJob batchTest = new CheckIfLeadConvertedBatchJob();
        Database.executeBatch(batchTest);
        
        
    }
}
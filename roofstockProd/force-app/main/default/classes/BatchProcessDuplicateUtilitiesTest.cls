@isTest
public class BatchProcessDuplicateUtilitiesTest {
     static{
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void BatchProcessDuplicateAccountTest() {
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
        p.Year_Built__c = '1972';
        p.name = '123 Main St Tracy CA 95391';
        insert p;
        
        Property_Unit__c pu = new Property_Unit__c();
        pu.name = '123 Main St Tracy CA 95391';
        pu.Property__c = p.Id;
        pu.Bathrooms__c = 3;
        pu.Bedrooms__c = 2.5;
        pu.HomeCode__c = 'q2000';
        pu.Occupancy_Status__c = 'Vacant Unrented Not Ready';   
        insert pu;
        
        Property_Unit__c pu1 = new Property_Unit__c();
        pu1.name = '123 Main St Tracy CA 95391';
        pu1.Property__c = p.Id;
        pu1.Bathrooms__c = 3;
        pu1.Bedrooms__c = 2.5;
        pu1.HomeCode__c = 'q2000';
        pu1.Occupancy_Status__c = 'Vacant Unrented Not Ready';  
        insert pu1;
        
        Turn__c t = new Turn__c();
        t.Property_Unit__c = pu.Id;
        t.Status__c = 'Upcoming';
        insert t;
        
        Property_Unit__c punit = [select Id,Occupancy_Status__c from Property_Unit__c where Id=:pu.Id];
        punit.Occupancy_Status__c = 'Vacant Rented Not Ready';
        punit.Operating_Status__c = 'Sold';
        
        Utilities__c oUtilites = new Utilities__c(); 
        oUtilites.property_unit__c = punit.Id; 
        insert oUtilites;        
        Utilities__c oUtilites1 = new Utilities__c(); 
        oUtilites1.property_unit__c = pu1.Id; 
        insert oUtilites1;  
        Database.BatchableContext BC;
        Test.startTest();
       // Database.executeBatch(new BatchProcessDuplicateUtilities(), 1);
        BatchProcessDuplicateUtilities otestbatch = new BatchProcessDuplicateUtilities(); 
        List<AggregateResult> olst = otestbatch.start(BC);
        //List<AggregateResult> oBatchlist = new List<AggregateResult>{ olst[0] };
        //otestbatch.execute(BC, oBatchlist);
        //otestbatch.finish(BC);
        Test.stopTest();
    }
}
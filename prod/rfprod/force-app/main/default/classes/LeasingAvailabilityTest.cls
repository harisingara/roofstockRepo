@isTest
public class LeasingAvailabilityTest {
static { 
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void qualifyPlanomaticAllConditionSet() {
        
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
        //p.Year_Built__c = '1972';
        p.name = '123 Main St Tracy CA 95391';
        p.Street_Address__c = '1234 USA';
        p.City__c = 'sdfsd';
        p.County__c = 'US';
        p.Zip__c ='00009';
        p.State__c = 'CO';
        p.Seller_Provided_List_Price__c = 500;
        p.Square_Feet__c = '456';
        insert p;
        
        Property_Unit__c pu = new Property_Unit__c();
        pu.name = '123 Main St Tracy CA 95391';
        pu.Property__c = p.id;
        pu.Bathrooms__c = 3;
        pu.Bedrooms__c = 2.5;
        pu.HomeCode__c = 'q2000';
        pu.Occupancy_Status__c = 'Vacant Unrented Ready';
        pu.Operating_Status__c = 'Leasable';
        insert pu;
        
        Turn__c t = new Turn__c();
        t.Status__c = 'Upcoming';
        t.Move_Out_Date__c = Date.today();
        t.Property_Unit__c = pu.Id;
        t.Lockbox_Code__c = '12345';
        t.Self_Showing_Lockbox__c = '12345';
        insert t;
        
        Leasing_Availability__c la = new Leasing_Availability__c();
        la.Property_Unit__c = pu.Id;
        la.Name = '1234 USA';
        insert la;
        
        Leasing_Availability__c lavailability = [Select Id,Ready_Date__c from Leasing_Availability__c where Id =:la.Id];
        lavailability.Ready_Date__c = Date.Today();
        update lavailability;
        
        delete lavailability;
}
}
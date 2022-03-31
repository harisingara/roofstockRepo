@isTest
public class PlanomaticCreateOrderControllerTest {
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
        
        Rental_Listing__c la = new Rental_Listing__c();
        la.Property_Unit__c = pu.Id;
        la.Name = '1234 USA';
        insert la;
        PlanomaticCreateOrderController.qualifyPlanomatic(la.Id);
        PlanomaticCreateOrderController.accessCodeDetails(la.Id);
        PlanomaticCreateOrderController.checkAccessCodeDetails(la.Id);
        PlanomaticCreateOrderController.planomaticOrder(la.Id,'test notes');
        String leasingAvailability = JSON.serialize(la);
        Map<String,Turn__c> puTurnMap = new Map<String,Turn__c>();
        puTurnMap.put(pu.Id,t);
        
        String accessDetailsSerialized =  JSON.serialize(puTurnMap);
        //PlanomaticCreateOrderHelper.orderDetailsAutomation(leasingAvailability,accessDetailsSerialized);
        
    }
    
     @isTest static void createPlanomaticCallout() {
        // Set mock callout class 
        
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
        
        Rental_Listing__c la = new Rental_Listing__c();
        la.Property_Unit__c = pu.Id;
        la.Name = '1234 USA';
        insert la;
        String leasingAvailability = JSON.serialize(la);
        Map<String,Turn__c> puTurnMap = new Map<String,Turn__c>();
        puTurnMap.put(pu.Id,t);
        
        String accessDetailsSerialized =  JSON.serialize(puTurnMap);
		Test.setMock(HttpCalloutMock.class, new PlanomaticCreateOrderMock()); 
    }
    
    static testMethod void qualifyPlanomaticTypejob() {
        
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
        
        Job__c t = new Job__c();
        t.name = 'test job';
        t.Property_Unit__c = pu.Id;
        t.Lockbox_Code__c = '12345';
        t.Self_Showing_Lockbox__c = '12345';
        insert t;
        
        Rental_Listing__c la = new Rental_Listing__c();
        la.Property_Unit__c = pu.Id;
        la.Name = '1234 USA';
        insert la;
        String leasingAvailability = JSON.serialize(la);
        Map<String,Job__c> puTurnMap = new Map<String,Job__c>();
        puTurnMap.put(pu.Id,t);
        
        String accessDetailsSerialized =  JSON.serialize(puTurnMap);
       // PlanomaticCreateOrderHelper.orderDetailsAutomation(leasingAvailability,accessDetailsSerialized);
        
    }
    
    static testMethod void qualifyPlanomaticAllConditionSetAutomation() {
        
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
        pu.name = '123 Main St Tracy CA 953911';
        pu.Property__c = p.id;
        pu.Bathrooms__c = 3;
        pu.Bedrooms__c = 2.5;
        pu.HomeCode__c = 'q2000';
        pu.Occupancy_Status__c = 'Vacant Rented Ready';
        pu.Operating_Status__c = 'Leasable';
        insert pu;
        
        
        Turn__c t = new Turn__c();
        t.Status__c = 'Upcoming';
        t.Move_Out_Date__c = Date.today();
        t.Property_Unit__c = pu.Id;
        t.Lockbox_Code__c = '12345';
        t.Self_Showing_Lockbox__c = '12345';
        insert t;
        
        Property_Unit__c punit = [select Id,Occupancy_Status__c from Property_Unit__c where Id=:pu.Id limit 1];
        punit.Occupancy_Status__c = 'Vacant Unrented Ready';
        update punit;
        
        Rental_Listing__c la = new Rental_Listing__c();
        la.Property_Unit__c = pu.Id;
        la.Name = '1234 USA';
        insert la;
        PlanomaticCreateOrderController.qualifyPlanomatic(la.Id);
        PlanomaticCreateOrderController.accessCodeDetails(la.Id);
        PlanomaticCreateOrderController.checkAccessCodeDetails(la.Id);
        Test.setMock(HttpCalloutMock.class, new PlanomaticCreateOrderMock());  
        PlanomaticCreateOrderController.planomaticOrder(la.Id, 'Test note');
        
    }
    
    static testMethod void qualifyPlanomaticConditionNotSatisfied() {
        
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
        
        Job__c jb = new Job__c();
        jb.Property_Unit__c = pu.Id;
        jb.Lockbox_Code__c = '12345';
        jb.Self_Showing_Lockbox__c = '12345';
        insert jb;
        
        Turn__c t = new Turn__c();
        t.Status__c = 'Upcoming';
        t.Move_Out_Date__c = Date.today();
        t.Property_Unit__c = pu.Id;
        insert t;
        
        Rental_Listing__c la = new Rental_Listing__c();
        la.Property_Unit__c = pu.Id;
        la.Name = '1234 USA';
        insert la;
        PlanomaticCreateOrderController.qualifyPlanomatic(la.Id);
        PlanomaticCreateOrderController.accessCodeDetails(la.Id);

    }
    static testMethod void qualifyPlanomaticNoLeasingAvailability() {
        
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
        insert t;
        
        Rental_Listing__c la = new Rental_Listing__c();
        la.Property_Unit__c = pu.Id;
        la.Name = '1234 USA';
        //insert la;
        PlanomaticCreateOrderController.qualifyPlanomatic(la.Id);
        
    }
    
}
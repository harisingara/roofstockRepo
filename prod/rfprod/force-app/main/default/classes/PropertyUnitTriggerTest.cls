@isTest
public class PropertyUnitTriggerTest {
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void PropertyUnitTriggerTest() {
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
        p.name = '123 Main St Tracy CA 95391';
        insert p;
        
        Fund_Owner__c f=  new Fund_Owner__c();
        f.name = 'test fund';
        insert f;

        Property__c prop=  new Property__c();
        prop.name = 'test prop';
        prop.Property_Unit_Riid__c = 'test-uiid';
        prop.fund__c = f.id;
        insert prop;
        
        Property_Unit__c pu = new Property_Unit__c();
        pu.name = '123 Main St Tracy CA 95391';
        pu.Property__c = p.Id;
        pu.Bathrooms__c = 3;
        pu.Bedrooms__c = 2.5;
        pu.HomeCode__c = 'q2000';
        pu.Occupancy_Status__c = 'Vacant Unrented Not Ready';	
        insert pu;
        
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
        update punit;
        
        Property_Unit__c punits = [select Id from Property_Unit__c where Id=:pu.Id];
        delete punits;
         
    }
    
    static testMethod void PropertyUnitTriggerPlanomaticTest() {
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
        p.name = '123 Main St Tracy CA 95391';
        p.City__c = 'CA';
        p.Street_Address__c ='CA';
        p.County__c ='US';
        p.Zip__c = '89876';
        p.State__c = 'CA';
        p.Square_Feet__c = '123';
        insert p;
        
        Property_Unit__c pu = new Property_Unit__c();
        pu.name = '123 Main St Tracy CA 95391';
        pu.Property__c = p.Id;
        pu.Bathrooms__c = 3;
        pu.Bedrooms__c = 2.5;
        pu.HomeCode__c = 'q2000';
        pu.Occupancy_Status__c = 'Vacant Unrented Not Ready';	
        insert pu;
        
        Turn__c t = new Turn__c();
        t.Property_Unit__c = pu.Id;
        t.Status__c = 'Upcoming';
        insert t;
        
        Property_Unit__c punit = [select Id,Occupancy_Status__c from Property_Unit__c where Id=:pu.Id];
        punit.Occupancy_Status__c = 'Vacant Unrented Ready';
        punit.Operating_Status__c =  'Leasable';
		punit.operating_reason__c = 'OperatingReason';        
        update punit;
        
        
        Property_Unit__c punits = [select Id from Property_Unit__c where Id=:pu.Id];
        delete punits;
        
    }
    
    static testMethod void PropertyUnitTriggerExceptionTest() {
        TriggerDispatcher.forceException = true;
        try{
            Property_Unit__c pu = new Property_Unit__c();
            pu.name = '123 Main St Tracy CA 95391';
            pu.Bathrooms__c = 3;
            pu.Bedrooms__c = 2.5;
            pu.HomeCode__c = 'q2000';
            pu.Occupancy_Status__c = 'Vacant Unrented Not Ready';   
            insert pu;
        }
        catch(Exception ex){
            
        }
        
    }
    
    static testMethod void updatePropertyUnitOnAcquisition(){
        
        Property2__c p = new Property2__c();
        p.name = '123 Main St Tracy CA 95391';
        insert p;
        
        Fund_Owner__c f=  new Fund_Owner__c();
        f.name = 'test fund';
        insert f;

        Property__c prop=  new Property__c();
        prop.name = 'test prop';
        prop.Property_Unit_Riid__c = 'test-uiid';
        prop.fund__c = f.id;
        prop.Neighborhood_Score__c = '3';
        insert prop;
        
        Property_Unit__c pu = new Property_Unit__c();
        pu.name = '123 Main St Tracy CA 95391';
        pu.Property__c = p.Id;
        pu.Bathrooms__c = 3;
        pu.Bedrooms__c = 2.5;
        pu.HomeCode__c = 'q2000';
        pu.Occupancy_Status__c = 'Vacant Unrented Not Ready';  
        pu.PropertyUnitId__c = 'test-uiid'; 
        insert pu;
        
        
    }
    
    static testMethod void PropertyUnitTriggerJobTurnCreationTest() {
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
        p.name = '123 Main St Tracy CA 95391';
        p.City__c = 'CA';
        p.Street_Address__c ='CA';
        p.County__c ='US';
        p.Zip__c = '89876';
        p.State__c = 'CA';
        p.Square_Feet__c = '123';
        p.property_management_company__c = 'Streetlane Property Management';
        insert p;
        
        Property_Unit__c pu = new Property_Unit__c();
        pu.name = '123 Main St Tracy CA 95391';
        pu.Property__c = p.Id;
        pu.Bathrooms__c = 3;
        pu.Bedrooms__c = 2.5;
        pu.HomeCode__c = 'q2000A';
        pu.Occupancy_Status__c = 'Vacant Unrented Not Ready';
        pu.operating_reason__c = 'Leased';
        pu.Operating_Status__c =  'Leasable';
        pu.Move_Out_Date__c = System.today(); 
        insert pu;
        
        Property_Unit__c pu1 = new Property_Unit__c();
        pu1.name = '123 Main St Tracy CA 95391';
        pu1.Property__c = p.Id;
        pu1.Bathrooms__c = 3;
        pu1.Bedrooms__c = 2.5;
        pu1.HomeCode__c = 'q2000B';
        pu1.Occupancy_Status__c = 'Occupied No Notice';
        pu1.operating_reason__c = 'Leased';
        pu1.Operating_Status__c =  'Leasable';
        pu1.Move_Out_Date__c = System.today(); 
        insert pu1;
        
        Property_Unit__c punit = [select Id,Occupancy_Status__c,Operating_Status__c from Property_Unit__c where Id=:pu.Id];
        punit.Occupancy_Status__c = 'Occupied No Notice';      
        update punit;
        
        List<Job__c> jtList = new List<Job__c>();
        
        Job__c jt = new Job__c();
        jt.Property_Unit__c = pu.Id;
        jt.Job_Status__c = 'Waiting for Move Out';
        jt.Property__c = p.Id;
        jtList.add(jt);
        
        jt = new Job__c();
        jt.Property_Unit__c = pu1.Id;
        jt.Job_Status__c = 'Job Completed';
        jt.Property__c = p.Id;
        jtList.add(jt);
        
        insert jtList;
        
        Property_Unit__c punit1 = [select Id,Occupancy_Status__c,Operating_Status__c,Move_Out_Date__c from Property_Unit__c where Id=:punit.Id];
        punit1.Move_Out_Date__c = (null <> punit1.Move_Out_Date__c) ? punit1.Move_Out_Date__c.adddays(3) : System.today().addDays(3);      
        update punit1;
    }
    
    static testMethod void PropertyUnitTriggerRenOppTest() {
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
        p.name = '123 Main St Tracy CA 95391';
        p.City__c = 'CA';
        p.Street_Address__c ='CA';
        p.County__c ='US';
        p.Zip__c = '89876';
        p.State__c = 'CA';
        p.Square_Feet__c = '123';
        p.property_management_company__c = 'Streetlane Property Management';
        insert p;
        
        Property_Unit__c pu = new Property_Unit__c();
        pu.name = '123 Main St Tracy CA 95391';
        pu.Property__c = p.Id;
        pu.Bathrooms__c = 3;
        pu.Bedrooms__c = 2.5;
        pu.HomeCode__c = 'q2000A';
        pu.Occupancy_Status__c = 'Vacant Unrented Not Ready';
        pu.operating_reason__c = 'Leased';
        pu.Operating_Status__c =  'Leasable';
        pu.Move_Out_Date__c = System.today(); 
        pu.Tenant_Status__c = 'Current'; 
        insert pu;
        
        
        Property_Unit__c punit = [select Id,Tenant_Status__c from Property_Unit__c where Id=:pu.Id];
        punit.Tenant_Status__c = 'Notice';      
        update punit;
        
    }
    
}
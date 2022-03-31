@isTest
public class ORUActivitiesTriggerTest {
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void ORUTriggerTest() {
        
        Account a = new Account(Name = 'TestAccount');
        insert a;
        
        Contact con = new Contact();
        con.firstname = 'Test';
        con.lastname = 'Test';
        con.email= 'Test'+'@nowhere.com';
        con.HasOptedOutOfEmail =false;
        con.AccountId = a.Id;
        
        Opportunity o = new Opportunity();
        o.Name = 'test';
        o.StageName = 'Viewed';
        o.closeDate= System.today();
        insert o;
        
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
        pu.Property__c = p.id;
        pu.Bathrooms__c = 3;
        pu.Bedrooms__c = 2.5;
        pu.HomeCode__c = '1234';
        insert pu;
        
        Rental_Listing__c rl = new Rental_Listing__c();
        rl.Name='test';
        rl.Property_Unit__c = pu.Id;
        rl.Status__c ='Unspecified';
        insert rl;
        
        OpportunityRentalUnit__c ru = new OpportunityRentalUnit__c();
        ru.Opportunity__c = o.Id;
        ru.Name = 'Rental Unit';
        ru.Leasing__c = rl.Id;
        //ru.Primary_Leasing_Contact__c = cons[i].Id;
        insert ru;
        Opportunity_Rental_Unit_Activity__c orua = new Opportunity_Rental_Unit_Activity__c();
        orua.Activity_Name__c = 'SFDC';
        orua.Activity_Code__c = 'controlled_showing';
        orua.Opportunity_Rental_Unit__c = ru.Id;
        insert orua; 
    }
    static testMethod void ORUTriggerDeleteTest() {
        
        Account a = new Account(Name = 'TestAccount');
        insert a;
        
        Contact con = new Contact();
        con.firstname = 'Test';
        con.lastname = 'Test';
        con.email= 'Test'+'@nowhere.com';
        con.HasOptedOutOfEmail =false;
        con.AccountId = a.Id;
        
        Opportunity o = new Opportunity();
        o.Name = 'test';
        o.StageName = 'Viewed';
        o.closeDate= System.today();
        insert o;
        
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
        pu.Property__c = p.id;
        pu.Bathrooms__c = 3;
        pu.Bedrooms__c = 2.5;
        pu.HomeCode__c = '1234';
        insert pu;
        
        Rental_Listing__c rl = new Rental_Listing__c();
        rl.Name='test';
        rl.Property_Unit__c = pu.Id;
        rl.Status__c ='Unspecified';
        insert rl;
        
        OpportunityRentalUnit__c ru = new OpportunityRentalUnit__c();
        ru.Opportunity__c = o.Id;
        ru.Name = 'Rental Unit';
        ru.Leasing__c = rl.Id;
        //ru.Primary_Leasing_Contact__c = cons[i].Id;
        insert ru;
        Opportunity_Rental_Unit_Activity__c orua = new Opportunity_Rental_Unit_Activity__c();
        orua.Activity_Name__c = 'SFDC';
        orua.Activity_Code__c = 'controlled_showing';
        orua.Opportunity_Rental_Unit__c = ru.Id;
        insert orua;
        List<Opportunity_Rental_Unit_Activity__c> oruact = [select Id from Opportunity_Rental_Unit_Activity__c where Id=:orua.Id];
        delete oruact;
    }
    static testMethod void ORUTriggerTestException() {
        TriggerDispatcher.forceException = true;
        try{
           
            Opportunity_Rental_Unit_Activity__c orua = new Opportunity_Rental_Unit_Activity__c();
            orua.Activity_Name__c = 'SFDC';
            orua.Activity_Code__c = 'controlled_showing';
            //orua.Opportunity_Rental_Unit__c = ru.Id;
            insert orua; 
        }
        catch(Exception ex){
            
        }
    }
    
    
}
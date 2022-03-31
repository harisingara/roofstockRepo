@isTest
public class LLRUTriggerTests {
    
    static {
        //create test users        
        TestDataFactory.insertHierarchyCustomSettingData(); 
        TestDataFactory.createTestLeasingUserRecords(1);
        TestDataFactory.createTestLeasingListingRecords(5); 
    }
    
    static testMethod void InsertLLru() {
        User u1 = [SELECT Id, profile.name FROM User WHERE Profile.Name = 'System Administrator' and isActive = true LIMIT 1];
        u1.Assignment_Group_Active__c = true;
        update u1;
        
        
        Property2__c properties = new Property2__c(
            Leasing_Market__c = 'Atlanta',
            PropertyCode__c = 'q1000',
            PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
            Property_Type__c = 'Single Family',
            Year_Built__c = '1972',
            name = '123 Main St Tracy CA 95391'
        );
        insert properties;
        
        Property_Unit__c unit1 = new Property_Unit__c(
            name = '123 Main St Tracy CA 95391',
            Property__c = properties.id,
            Bathrooms__c = 3,
            Bedrooms__c = 2.5,
            HomeCode__c = 'q20000'
        );
        insert unit1;
        
        Rental_Listing__c rl = new Rental_Listing__c(
            name = '123 Main St Tracy CA 95391',
            Property_Unit__c = unit1.id,
            Rental_Listing_Id__c = '21978',
            Rently_Property_Id__c = '21978',
            Current_Rent__c = 1200,
            Status__c = 'Unspecified'
        );
        insert rl;
        
        Property_Unit__c unit2 = new Property_Unit__c(
            name = '345 Main St Tracy CA 95391',
            Property__c = properties.id,
            Bathrooms__c = 3,
            Bedrooms__c = 2.5,
            HomeCode__c = 'q20000'
        );
        insert unit2;
        
        Rental_Listing__c r2 = new Rental_Listing__c(
            name = '345 Main St Tracy CA 95391',
            Property_Unit__c = unit2.id,
            Rental_Listing_Id__c = '21979',
            Rently_Property_Id__c = '21979',
            Current_Rent__c = 1200,
            Status__c = 'Unspecified'
        );
        insert r2;
        
        Id leasingLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Leasing').getRecordTypeId();
        Lead l = new Lead();
        l.LastNAme ='sfdc';
        l.Email = 'testuser123@gmail.com';
        l.Phone = '+13331231234';
        l.Company = 'Salesforce';
        l.LeadSource = 'Rently';
        l.RecordTypeId = leasingLeadRecordTypeId;
        insert l;
        
        
        
        Lead_Leasing_Rental_Unit__c llru = new Lead_Leasing_Rental_Unit__c ();
        llru.Lead__c = l.Id;
        llru.Rental_Listing__c = rl.Id;
        Insert llru;
        
        //llru.Rental_Listing__c = r2.Id;
        //Update llru;
        
        //Delete llru;
        
    }
    
    static testMethod void InsUpdLLru() {
        User u1 = [SELECT Id, profile.name FROM User WHERE Profile.Name = 'System Administrator' and isActive = true LIMIT 1];
        u1.Assignment_Group_Active__c = true;
        update u1;
        
        
        Property2__c properties = new Property2__c(
            Leasing_Market__c = 'Atlanta',
            PropertyCode__c = 'q1000',
            PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
            Property_Type__c = 'Single Family',
            Year_Built__c = '1972',
            name = '123 Main St Tracy CA 95391'
        );
        insert properties;
        
        Property_Unit__c unit1 = new Property_Unit__c(
            name = '123 Main St Tracy CA 95391',
            Property__c = properties.id,
            Bathrooms__c = 3,
            Bedrooms__c = 2.5,
            HomeCode__c = 'q20000'
        );
        insert unit1;
        
        Rental_Listing__c rl = new Rental_Listing__c(
            name = '123 Main St Tracy CA 95391',
            Property_Unit__c = unit1.id,
            Rental_Listing_Id__c = '21978',
            Rently_Property_Id__c = '21978',
            Current_Rent__c = 1200,
            Status__c = 'Unspecified'
        );
        insert rl;
        
        Property_Unit__c unit2 = new Property_Unit__c(
            name = '345 Main St Tracy CA 95391',
            Property__c = properties.id,
            Bathrooms__c = 3,
            Bedrooms__c = 2.5,
            HomeCode__c = 'q20000'
        );
        insert unit2;
        
        Rental_Listing__c r2 = new Rental_Listing__c(
            name = '345 Main St Tracy CA 95391',
            Property_Unit__c = unit2.id,
            Rental_Listing_Id__c = '21979',
            Rently_Property_Id__c = '21979',
            Current_Rent__c = 1200,
            Status__c = 'Unspecified'
        );
        insert r2;
        
        Id leasingLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Leasing').getRecordTypeId();
        Lead l = new Lead();
        l.LastNAme ='sfdc';
        l.Email = 'testuser123@gmail.com';
        l.Phone = '+13331231234';
        l.Company = 'Salesforce';
        l.LeadSource = 'Rently';
        l.RecordTypeId = leasingLeadRecordTypeId;
        insert l;
        
        
        
        Lead_Leasing_Rental_Unit__c llru = new Lead_Leasing_Rental_Unit__c ();
        llru.Lead__c = l.Id;
        llru.Rental_Listing__c = rl.Id;
        Insert llru;
        
        llru.Rental_Listing__c = r2.Id;
        Update llru;
        
        Delete llru;
        
    }
    
    /*
    static testMethod void InsertLLruException() {
        User u1 = [SELECT Id, profile.name FROM User WHERE Profile.Name = 'System Administrator' and isActive = true LIMIT 1];
        u1.Assignment_Group_Active__c = true;
        update u1;
        
        
        Property2__c properties = new Property2__c(
            Leasing_Market__c = 'Atlanta',
            PropertyCode__c = 'q1000',
            PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
            Property_Type__c = 'Single Family',
            Year_Built__c = '1972',
            name = '123 Main St Tracy CA 95391'
        );
        insert properties;
        
        Property_Unit__c unit1 = new Property_Unit__c(
            name = '123 Main St Tracy CA 95391',
            Property__c = properties.id,
            Bathrooms__c = 3,
            Bedrooms__c = 2.5,
            HomeCode__c = 'q20000'
        );
        insert unit1;
        
        
        Id leasingLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Leasing').getRecordTypeId();
        Lead l = new Lead();
        l.LastNAme ='sfdc';
        l.Email = 'testuser123@gmail.com';
        l.Phone = '+13331231234';
        l.Company = 'Salesforce';
        l.LeadSource = 'Rently';
        l.RecordTypeId = leasingLeadRecordTypeId;
        insert l;
        
        lead l1 = [Select Id, LeadSource from Lead limit 1];
        System.debug('NDEBUG lead :::' + l1);
        
        Rental_Listing__c r1 = new Rental_Listing__c(
            name = '123 Main St Tracy CA 95391',
            Property_Unit__c = unit1.id,
            Rental_Listing_Id__c = '21978',
            Current_Rent__c = 1200,
            Status__c = 'Unspecified'
        );
        insert r1;
        
        
        Lead_Leasing_Rental_Unit__c llru = new Lead_Leasing_Rental_Unit__c ();
        llru.Lead__c = l1.Id;
        //llru.Rental_Listing__c = r1.Id;
        Insert llru;
        
    }
	*/
	

}
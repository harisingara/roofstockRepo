@isTest
public class TestDataFactory {
    public static void createTestUserRecords(Integer numUsers) {
        List<User> users = new List<User>();
        //create a RS standard  profile user.
        string RS_STANDARD_PROFILE = 'RS Standard User';
        string RS_USER_ALIAS = 'RSUSER';
        string RS_USER_NAME = 'TestUser';
        
        Profile p = [
            SELECT p.Name, p.Id
            FROM Profile p
            WHERE p.Name LIKE :RS_STANDARD_PROFILE
            LIMIT 1
        ];
        
        for (Integer i = 0; i < numUsers; i++) {
            string userName = RS_USER_NAME + i;
            User u = new User(LastName = userName);
            u.ProfileId = p.Id;
            u.Alias = RS_USER_ALIAS + i;
            u.Username = userName + '@roofstock.com';
            u.email = userName + '@roofstock.com';
            u.CommunityNickname = userName;
            u.TimeZoneSidKey = 'America/New_York';
            u.LocaleSidKey = 'en_US';
            u.EmailEncodingKey = 'UTF-8';
            u.LanguageLocaleKey = 'en_US';
            
            users.add(u);
            System.debug('created' + RS_USER_ALIAS + i);
        }
        insert users;
    }
    
    public static void createTestRecords(
        Integer numAccts,
        Integer numContactsPerAcct
    ) {
        List<Account> accts = new List<Account>();
        
        for (Integer i = 0; i < numAccts; i++) {
            Account a = new Account(Name = 'TestAccount' + i);
            accts.add(a);
        }
        insert accts;
        
        List<Contact> cons = new List<Contact>();
        for (Integer j = 0; j < numAccts; j++) {
            Account acct = accts[j];
            // For each account just inserted, add contacts
            for (
                Integer k = numContactsPerAcct * j;
                k < numContactsPerAcct * (j + 1);
                k++
            ) {
                cons.add(
                    new Contact(
                        firstname = 'Test' + k,
                        lastname = 'Test' + k,
                        email= 'Test' + k + '@nowhere.com',
                        AccountId = acct.Id
                    )
                );
            }
        }
        // Insert all contacts for all accounts
        insert cons;
    }
    
    public static void createTestLeasingUserRecords(Integer count) {
        //Rental_Listing__c
        //Property2__c
        //Property_Unit__c
        string LEASING_PROFILE = 'Leasing';
        string RS_USER_ALIAS = 'SLUSER';
        string RS_USER_NAME = 'LeaseUser';
        
        Profile p = [
            SELECT p.Name, p.Id
            FROM Profile p
            WHERE p.Name = :LEASING_PROFILE
            LIMIT 1
        ];
        List<User> users = new List<User>();
        
        for (Integer i = 0; i < count; i++) {
            string userName = RS_USER_NAME + i;
            User u = new User(LastName = userName);
            u.ProfileId = p.Id;
            u.Alias = RS_USER_ALIAS + i;
            u.Username = userName + '@roofstock.com';
            u.email = userName + '@roofstock.com';
            u.CommunityNickname = userName;
            u.TimeZoneSidKey = 'America/New_York';
            u.LocaleSidKey = 'en_US';
            u.EmailEncodingKey = 'UTF-8';
            u.LanguageLocaleKey = 'en_US';
            users.add(u);
            System.debug('created' + RS_USER_ALIAS + i);
        }
        insert users;
    }
    
    
    public static void createTestPropertyUnitRecords(Integer count) {
        //Property2__c
        //Property_Unit__c
        
        Id leasingAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Leasing')
            .getRecordTypeId();
        Id leasingContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
            .get('Leasing')
            .getRecordTypeId();
        Id leasingPropertyRecordTypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByName()
            .get('Leasing')
            .getRecordTypeId();
        
        Id amPropertyRecordTypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByName()
            .get('Asset Management')
            .getRecordTypeId();
        
        List<Property2__c> properties = new List<Property2__c>();
        
        for (Integer i = 0; i < count; i++) {
            Property2__c p = new Property2__c();
            p.Market__c = 'Atlanta';
            p.PropertyCode__c = 'q1000' + i;
            p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead' + i;
            p.Property_Type__c = 'Single Family';
            p.Year_Built__c = '1972';
            p.name = '123 Main St Tracy CA 95391';
            p.recordtypeid = leasingPropertyRecordTypeId;
            properties.add(p);
        }
        insert properties;
        
        List<Property_Unit__c> units = new List<Property_Unit__c>();
        for (Integer i = 0; i < count; i++) {
            Property_Unit__c pu = new Property_Unit__c();
            pu.name = '123 Main St Tracy CA 95391';
            pu.Property__c = properties[0].id;
            pu.Bathrooms__c = 3;
            pu.Bedrooms__c = 2.5;
            pu.HomeCode__c = 'q2000' + i;
            units.add(pu);
        }
        insert units;
    }
    
    public static void createTestLeasingListingRecords(Integer count) {
        //Rental_Listing__c
        //Property2__c
        //Property_Unit__c
        
        Id leasingAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Leasing')
            .getRecordTypeId();
        Id leasingContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName()
            .get('Leasing')
            .getRecordTypeId();
        Id leasingOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
            .get('Leasing')
            .getRecordTypeId();
        
        Id leasingLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName()
            .get('Leasing')
            .getRecordTypeId();
        
        Id leasingPropertyRecordTypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByName()
            .get('Leasing')
            .getRecordTypeId();
        
        List<Property2__c> properties = new List<Property2__c>();
        
        for (Integer i = 0; i < count; i++) {
            Property2__c p = new Property2__c();
            p.Market__c = 'Atlanta';
            p.PropertyCode__c = 'q1000' + i;
            p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead' + i;
            p.Property_Type__c = 'Single Family';
            p.Year_Built__c = '1972';
            p.name = '123 Main St Tracy CA 95391';
            p.recordtypeid = leasingPropertyRecordTypeId;
            properties.add(p);
        }
        insert properties;
        
        List<Property_Unit__c> units = new List<Property_Unit__c>();
        for (Integer i = 0; i < count; i++) {
            Property_Unit__c pu = new Property_Unit__c();
            pu.name = '123 Main St Tracy CA 95391';
            pu.Property__c = properties[0].id;
            pu.Bathrooms__c = 3;
            pu.Bedrooms__c = 2.5;
            pu.HomeCode__c = 'q2000' + i;
            units.add(pu);
        }
        insert units;
        
        List<Rental_Listing__c> unitListings = new List<Rental_Listing__c>();
        for (Integer i = 0; i < count; i++) {
            Rental_Listing__c l = new Rental_Listing__c();
            l.name = '123 Main St Tracy CA 95391';
            l.Property_Unit__c = units[0].id;
            l.Current_Rent__c = 1200;
            l.Previous_Rent__c = 1000;
            l.Rental_Listing_Id__c = '13922' + i;
            l.Status__c = 'Unspecified';
            unitListings.add(l);
        }
        insert unitListings;
    }
    public static void createTestTenantListingRecords(Integer count) {
        //Id leasingContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Tenant').getRecordTypeId();
        Id leasingPropertyRecordTypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
        List<Property2__c> properties = new List<Property2__c>();
        
        for (Integer i = 0; i < count; i++) {
            Property2__c p = new Property2__c();
            p.Market__c = 'Atlanta';
            p.PropertyCode__c = 'q1000' + i;
            p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead' + i;
            p.Property_Type__c = 'Single Family';
            p.Year_Built__c = '1972';
            p.name = '123 Main St Tracy CA 95391';
            p.recordtypeid = leasingPropertyRecordTypeId;
            properties.add(p);
        }
        insert properties;
        
        List<Property_Unit__c> units = new List<Property_Unit__c>();
        for (Integer i = 0; i < count; i++) {
            Property_Unit__c pu = new Property_Unit__c();
            pu.name = '123 Main St Tracy CA 95391';
            pu.Property__c = properties[0].id;
            pu.Bathrooms__c = 3;
            pu.Bedrooms__c = 2.5;
            pu.HomeCode__c = '1234';
            units.add(pu);
        }
        insert units;
        List<Lease__c> lease = new List<Lease__c>();
        for (Integer i = 0; i < count; i++) {
            Lease__c l = new Lease__c();
            l.name = '123 Main St Tracy CA 95391';
            l.Lease_Id__c = 1234;
            l.Property_Unit__c = units[0].Id;
            lease.add(l);
        }
        insert lease;
        List<Tenant__c> tenant = new List<Tenant__c>();
        for (Integer i = 0; i < count; i++) {
            Tenant__c t = new Tenant__c();
            t.Last_Name__c = 'John';
            t.Tenent_Id__c = 234;
            t.Lease__c = lease[0].Id;
            tenant.add(t);
        }
        insert tenant;
        
    }
    
    public static void createTestTurnListingRecords(Integer count) {
        Id leasingPropertyRecordTypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
        List<Property2__c> properties = new List<Property2__c>();
        
        for (Integer i = 0; i < count; i++) {
            Property2__c p = new Property2__c();
            p.Market__c = 'Atlanta';
            p.PropertyCode__c = 'q1000' + i;
            p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead' + i;
            p.Property_Type__c = 'Single Family';
            p.Year_Built__c = '1972';
            p.name = '123 Main St Tracy CA 95391';
            p.recordtypeid = leasingPropertyRecordTypeId;
            properties.add(p);
        }
        insert properties;
        
        List<Property_Unit__c> units = new List<Property_Unit__c>();
        for (Integer i = 0; i < count; i++) {
            Property_Unit__c pu = new Property_Unit__c();
            pu.name = '123 Main St Tracy CA 95391';
            pu.Property__c = properties[0].id;
            pu.Bathrooms__c = 3;
            pu.Bedrooms__c = 2.5;
            pu.HomeCode__c = '1234';
            units.add(pu);
        }
        insert units;
        List<Turn__c> turns = new List<Turn__c>();
        for (Integer i = 0; i < count; i++) {
            Turn__c t = new Turn__c();
            t.Status__c = 'Upcoming';
            t.Move_Out_Date__c = Date.today();
            t.Property_Unit__c = units[0].Id;
            turns.add(t);
        }
        insert turns;
        
    }
    public static void createTestRentalListingRecords(Integer count) {
        List<Account> accts = new List<Account>();
        
        for (Integer i = 0; i < count; i++) {
            Account a = new Account(Name = 'TestAccount' + i);
            accts.add(a);
        }
        insert accts;
        List<Contact> cons = new List<Contact>();
        for (Integer j = 0; j < count; j++) {
            Account acct = accts[j];
            // For each account just inserted, add contacts
            for (
                Integer k = 1 * j;
                k < 1 * (j + 1);
                k++
            ) {
                cons.add(
                    new Contact(
                        firstname = 'Test' + k,
                        lastname = 'Test' + k,
                        email= 'Test' + k + '@nowhere.com',
                        HasOptedOutOfEmail =false,
                        AccountId = acct.Id
                    )
                );
            }
        }
        // Insert all contacts for all accounts
        insert cons;
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < count; i++) {
            Opportunity o = new Opportunity();
            o.Name = 'test'+' '+i;
            o.StageName = 'Viewed';
            o.closeDate= System.today();
            opportunities.add(o);
        }
        insert opportunities;
        Id leasingPropertyRecordTypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
        List<Property2__c> properties = new List<Property2__c>();
        
        for (Integer i = 0; i < count; i++) {
            Property2__c p = new Property2__c();
            p.Market__c = 'Atlanta';
            p.PropertyCode__c = 'q1000' + i;
            p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead' + i;
            p.Property_Type__c = 'Single Family';
            p.Year_Built__c = '1972';
            p.name = '123 Main St Tracy CA 95391';
            p.recordtypeid = leasingPropertyRecordTypeId;
            properties.add(p);
        }
        insert properties;
        
        List<Property_Unit__c> units = new List<Property_Unit__c>();
        for (Integer i = 0; i < count; i++) {
            Property_Unit__c pu = new Property_Unit__c();
            pu.name = '123 Main St Tracy CA 95391';
            pu.Property__c = properties[0].id;
            pu.Bathrooms__c = 3;
            pu.Bedrooms__c = 2.5;
            pu.HomeCode__c = '1234';
            units.add(pu);
        }
        insert units;
        
        List<Rental_Listing__c> rentalListing = new List<Rental_Listing__c>();
        for (Integer i = 0; i < count; i++) {
            Rental_Listing__c rl = new Rental_Listing__c();
            rl.Name='test'+' '+i;
            rl.Property_Unit__c = units[i].Id;
            rl.Status__c ='Unspecified';
            rentalListing.add(rl);
        }
        insert rentalListing;
        
        List<OpportunityRentalUnit__c> rentalUnit = new List<OpportunityRentalUnit__c>();
        for (Integer i = 0; i < count; i++) {
            OpportunityRentalUnit__c ru = new OpportunityRentalUnit__c();
            ru.Opportunity__c = opportunities[i].Id;
            ru.Name = 'Rental Unit'+' '+i;
            ru.Leasing__c = rentalListing[0].Id;
            ru.Primary_Leasing_Contact__c = cons[i].Id;
            rentalUnit.add(ru);
        }
        insert rentalUnit;
        
    }
    public static void createTestLeasingOpportunityRecords(Integer count) {
        List<Account> accts = new List<Account>();
        
        for (Integer i = 0; i < count; i++) {
            Account a = new Account(Name = 'TestAccount' + i);
            accts.add(a);
        }
        insert accts;
        List<Contact> cons = new List<Contact>();
        for (Integer j = 0; j < count; j++) {
            Account acct = accts[j];
            // For each account just inserted, add contacts
            for (
                Integer k = 1 * j;
                k < 1 * (j + 1);
                k++
            ) {
                cons.add(
                    new Contact(
                        firstname = 'Test' + k,
                        lastname = 'Test' + k,
                        email= 'Test' + k + '@nowhere.com',
                        HasOptedOutOfEmail =false,
                        AccountId = acct.Id
                    )
                );
            }
        }
        // Insert all contacts for all accounts
        insert cons;
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
        
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < count; i++) {
            Opportunity o = new Opportunity();
            o.Name = 'test'+' '+i;
            o.StageName = 'Viewed';
            o.closeDate= System.today();
            o.RecordTypeId = oppRecordTypeId;
            o.AccountId=accts[0].Id;
            opportunities.add(o);
        }
        insert opportunities;
        
    }
    
    public static void createTestRetailBuyerOpportunityRecords(Integer count) {
        List<Account> accts = new List<Account>();
        
        for (Integer i = 0; i < count; i++) {
            Account a = new Account(Name = 'TestAccount' + i);
            accts.add(a);
        }
        insert accts;
        List<Contact> cons = new List<Contact>();
        for (Integer j = 0; j < count; j++) {
            Account acct = accts[j];
            // For each account just inserted, add contacts
            for (
                Integer k = 1 * j;
                k < 1 * (j + 1);
                k++
            ) {
                cons.add(
                    new Contact(
                        firstname = 'Test' + k,
                        lastname = 'Test' + k,
                        email= 'Test' + k + '@nowhere.com',
                        HasOptedOutOfEmail =false,
                        AccountId = acct.Id
                    )
                );
            }
        }
        // Insert all contacts for all accounts
        insert cons;
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < count; i++) {
            Opportunity o = new Opportunity();
            o.Name = 'test'+' '+i;
            o.StageName = 'Closed Won';
            o.closeDate= System.today();
            o.RecordTypeId = oppRecordTypeId;
            o.AccountId=accts[0].Id;
            opportunities.add(o);
        }
        insert opportunities;
        
    }
    Public static void insertHierarchyCustomSettingData(){
        Bypass_Rules_And_Triggers__c settings = Bypass_Rules_And_Triggers__c.getOrgDefaults();
        settings.Trigger_Objects__c = 'Opportunity';
		upsert settings;
		
		Toggle_New_logic__c togglesettings = Toggle_New_logic__c.getOrgDefaults();
        togglesettings.Name = 'Job__c';
        togglesettings.Enable_new_logic__c = true;
        upsert togglesettings;
        
        Toggle_New_logic__c togglesettings1 = new Toggle_New_logic__c();
        togglesettings1.Name = 'BPO';
        togglesettings1.Enable_new_logic__c = true;
        upsert togglesettings1;
        
    }
	
}
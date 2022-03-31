//may10
@isTest
public class searchRentalListingControllerTest {
    static{
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    private static final string userAlias = 'SLUSER1';
    private static final string RB_LEASING = 'Leasing';
    private static Id leasingOpportunityRecordTypeId;
    private static string sMarketkey;
    private static double dbedkey;
    private static double dbathkey;
    private static string sStatuskey;
    private static string sAddresskey;
    private static string oppid;
    private static Integer pagenumber;
    private static Integer numberOfRecords;
    private static Integer pageSize;
    
    static {
        TestDataFactory.createTestLeasingUserRecords(1);
    }
    
    static testMethod void TestcheckForInactiveStatusTrue() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        Property2__c properties = new Property2__c(
            Leasing_Market__c = 'Atlanta',
            PropertyCode__c = 'q1000',
            PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
            Property_Type__c = 'Single Family',
            Year_Built__c = '1972',
            name = '123 Main St Tracy CA 95391'
        );
        insert properties;
        
        Property_Unit__c units = new Property_Unit__c(
            name = '123 Main St Tracy CA 95391',
            Property__c = properties.id,
            Bathrooms__c = 3,
            Bedrooms__c = 2.5,
            HomeCode__c = 'q20000'
        );
        insert units;
        
        Rental_Listing__c rl = new Rental_Listing__c(
            name = '123 Main St Tracy CA 95391',
            Property_Unit__c = units.id,
            Rental_Listing_Id__c = '139221',
            Current_Rent__c = 1200,
            Status__c = 'Inactive'
        );
        insert rl;
        
        // select id from rentallist where rlid = '139221';
        
        list<Id> rentallistingid = new List<Id>();
        rentallistingid.add(rl.Id);
        
        System.runAs(u1) {
            System.test.startTest();
            boolean rlistingStatus = searchRentalListingController.checkForInactiveStatus(
                rentallistingid
            );
            
            System.test.stopTest();
            system.assertEquals(rlistingStatus, true);
        }
    }
    
    static testMethod void TestcheckForInactiveStatusFalse() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        Property2__c properties = new Property2__c(
            Leasing_Market__c = 'Atlanta',
            PropertyCode__c = 'q1000',
            PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
            Property_Type__c = 'Single Family',
            Year_Built__c = '1972',
            name = '123 Main St Tracy CA 95391'
        );
        insert properties;
        
        Property_Unit__c units = new Property_Unit__c(
            name = '123 Main St Tracy CA 95391',
            Property__c = properties.id,
            Bathrooms__c = 3,
            Bedrooms__c = 2.5,
            HomeCode__c = 'q20000'
        );
        insert units;
        
        Rental_Listing__c rl = new Rental_Listing__c(
            name = '123 Main St Tracy CA 95391',
            Property_Unit__c = units.id,
            Current_Rent__c = 1200,
            Status__c = 'Unspecified'
        );
        insert rl;
        
        list<Id> rentallistingid = new List<Id>();
        rentallistingid.add(rl.Id);
        
        System.runAs(u1) {
            System.test.startTest();
            boolean rlistingStatus = searchRentalListingController.checkForInactiveStatus(
                rentallistingid
            );
            System.test.stopTest();
            system.assertEquals(rlistingStatus, false);
        }
    }
    
    static testMethod void TestcheckORURecordExistTrue() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        leasingOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
            .get(RB_LEASING)
            .getRecordTypeId();
        Property2__c properties = new Property2__c(
            Leasing_Market__c = 'Atlanta',
            PropertyCode__c = 'q1000',
            PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
            Property_Type__c = 'Single Family',
            Year_Built__c = '1972',
            name = '123 Main St Tracy CA 95391'
        );
        insert properties;
        
        Property_Unit__c units = new Property_Unit__c(
            name = '123 Main St Tracy CA 95391',
            Property__c = properties.id,
            Bathrooms__c = 3,
            Bedrooms__c = 2.5,
            HomeCode__c = 'q20000'
        );
        insert units;
        
        Rental_Listing__c rl = new Rental_Listing__c(
            name = '123 Main St Tracy CA 95391',
            Property_Unit__c = units.id,
            Current_Rent__c = 1200,
            Status__c = 'Unspecified'
        );
        insert rl;
        
        Opportunity opp = new Opportunity(
            Name = '2020-03-25-Monica-Jones',
            RecordTypeId = leasingOpportunityRecordTypeId,
            StageName = 'New',
            CloseDate = Date.newInstance(2020, 3, 29)
        );
        insert opp;
        
        OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c(
            Name = '123 Main St Tracy CA 95391',
            Leasing__c = rl.id,
            Opportunity__c = opp.id
        );
        insert oru;
        
        list<Id> rentallistingid = new List<Id>();
        rentallistingid.add(oru.Leasing__c);
        oppid = oru.Opportunity__c;
        
        System.runAs(u1) {
            System.test.startTest();
            boolean rlistingStatus = searchRentalListingController.checkORURecordExist(
                rentallistingid,
                oppid
            );
            System.test.stopTest();
            system.assertEquals(rlistingStatus, true);
        }
    }
    
    static testMethod void TestgetRentalListingListForStatusAllValues() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        leasingOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
            .get(RB_LEASING)
            .getRecordTypeId();
        Property2__c properties = new Property2__c(
            Leasing_Market__c = 'Atlanta',
            PropertyCode__c = 'q1000',
            PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
            Property_Type__c = 'Single Family',
            Year_Built__c = '1972',
            name = '123 Main St Tracy CA 95391'
        );
        insert properties;
        
        Property_Unit__c units = new Property_Unit__c(
            name = '123 Main St Tracy CA 95391',
            Property__c = properties.id,
            Bathrooms__c = 3,
            Bedrooms__c = 2.5,
            HomeCode__c = 'q20000'
        );
        insert units;
        
        Rental_Listing__c rl = new Rental_Listing__c(
            name = '123 Main St Tracy CA 95391',
            Property_Unit__c = units.id,
            Current_Rent__c = 1200,
            Status__c = 'Leased'
        );
        insert rl;
        
        System.runAs(u1) {
            System.test.startTest();
            sMarketkey = properties.Leasing_Market__c;
            dbedkey = units.Bedrooms__c;
            dbathkey = units.Bathrooms__c;
            sStatuskey = rl.Status__c;
            sAddresskey = rl.name;
            pagenumber = 1;
            numberOfRecords = 1;
            pageSize = 1;
            list<Rental_Listing__c> rlisting = searchRentalListingController.getRentalListingList(
                pagenumber,
                numberOfRecords,
                pageSize,
                sMarketkey,
                dbedkey,
                dbathkey,
                sStatuskey,
                sAddresskey
            );
            
            System.test.stopTest();
        }
    }
    
    static testMethod void TestgetRentalListingListForStatusAllValuesOtherThanMarket() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        leasingOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
            .get(RB_LEASING)
            .getRecordTypeId();
        Property2__c properties = new Property2__c(
            Leasing_Market__c = 'Atlanta',
            PropertyCode__c = 'q1000',
            PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
            Property_Type__c = 'Single Family',
            Year_Built__c = '1972',
            name = '123 Main St Tracy CA 95391'
        );
        insert properties;
        
        Property_Unit__c units = new Property_Unit__c(
            name = '123 Main St Tracy CA 95391',
            Property__c = properties.id,
            Bathrooms__c = 3,
            Bedrooms__c = 2.5,
            HomeCode__c = 'q20000'
        );
        insert units;
        
        Rental_Listing__c rl = new Rental_Listing__c(
            name = '123 Main St Tracy CA 95391',
            Property_Unit__c = units.id,
            Current_Rent__c = 1200,
            Status__c = 'Leased'
        );
        insert rl;
        
        System.runAs(u1) {
            System.test.startTest();
            sMarketkey = properties.Leasing_Market__c;
            dbedkey = units.Bedrooms__c;
            dbathkey = units.Bathrooms__c;
            sStatuskey = rl.Status__c;
            sAddresskey = rl.name;
            pagenumber = 1;
            numberOfRecords = 1;
            pageSize = 1;
            list<Rental_Listing__c> rlisting = searchRentalListingController.getRentalListingList(
                pagenumber,
                numberOfRecords,
                pageSize,
                sMarketkey,
                dbedkey,
                dbathkey,
                sStatuskey,
                sAddresskey
            );
            
            System.test.stopTest();
        }
    }
    
    static testMethod void TestgetRentalListingListForStatusAllValuesOtherThanMarketBed() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        leasingOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
            .get(RB_LEASING)
            .getRecordTypeId();
        Property2__c properties = new Property2__c(
            Leasing_Market__c = 'Atlanta',
            PropertyCode__c = 'q1000',
            PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
            Property_Type__c = 'Single Family',
            Year_Built__c = '1972',
            name = '123 Main St Tracy CA 95391'
        );
        insert properties;
        
        Property_Unit__c units = new Property_Unit__c(
            name = '123 Main St Tracy CA 95391',
            Property__c = properties.id,
            Bathrooms__c = 3,
            Bedrooms__c = 0.0,
            HomeCode__c = 'q20000'
        );
        insert units;
        
        Rental_Listing__c rl = new Rental_Listing__c(
            name = '123 Main St Tracy CA 95391',
            Property_Unit__c = units.id,
            Current_Rent__c = 1200,
            Status__c = 'Leased'
        );
        insert rl;
        
        System.runAs(u1) {
            System.test.startTest();
            sMarketkey = properties.Leasing_Market__c;
            dbedkey = units.Bedrooms__c;
            dbathkey = units.Bathrooms__c;
            sStatuskey = rl.Status__c;
            sAddresskey = rl.name;
            pagenumber = 1;
            numberOfRecords = 1;
            pageSize = 1;
            list<Rental_Listing__c> rlisting = searchRentalListingController.getRentalListingList(
                pagenumber,
                numberOfRecords,
                pageSize,
                sMarketkey,
                dbedkey,
                dbathkey,
                sStatuskey,
                sAddresskey
            );
            
            System.test.stopTest();
        }
    }
    
    static testMethod void TestgetRentalListingListForStatusAllValuesOtherThanMarketBedBath() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        leasingOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
            .get(RB_LEASING)
            .getRecordTypeId();
        Property2__c properties = new Property2__c(
            Leasing_Market__c = 'Atlanta',
            PropertyCode__c = 'q1000',
            PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
            Property_Type__c = 'Single Family',
            Year_Built__c = '1972',
            name = '123 Main St Tracy CA 95391'
        );
        insert properties;
        
        Property_Unit__c units = new Property_Unit__c(
            name = '123 Main St Tracy CA 95391',
            Property__c = properties.id,
            Bathrooms__c = 0.0,
            Bedrooms__c = 0.0,
            HomeCode__c = 'q20000'
        );
        insert units;
        
        Rental_Listing__c rl = new Rental_Listing__c(
            name = '123 Main St Tracy CA 95391',
            Property_Unit__c = units.id,
            Current_Rent__c = 1200,
            Status__c = 'Leased'
        );
        insert rl;
        
        System.runAs(u1) {
            System.test.startTest();
            sMarketkey = properties.Leasing_Market__c;
            dbedkey = units.Bedrooms__c;
            dbathkey = units.Bathrooms__c;
            sStatuskey = rl.Status__c;
            sAddresskey = rl.name;
            pagenumber = 1;
            numberOfRecords = 1;
            pageSize = 1;
            list<Rental_Listing__c> rlisting = searchRentalListingController.getRentalListingList(
                pagenumber,
                numberOfRecords,
                pageSize,
                sMarketkey,
                dbedkey,
                dbathkey,
                sStatuskey,
                sAddresskey
            );
            
            System.test.stopTest();
        }
    }
    
    static testMethod void TestgetRentalListingListForStatusForAddress() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        leasingOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
            .get(RB_LEASING)
            .getRecordTypeId();
        Property2__c properties = new Property2__c(
            Leasing_Market__c = 'Atlanta',
            PropertyCode__c = 'q1000',
            PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
            Property_Type__c = 'Single Family',
            Year_Built__c = '1972',
            name = '123 Main St Tracy CA 95391'
        );
        insert properties;
        
        Property_Unit__c units = new Property_Unit__c(
            name = '123 Main St Tracy CA 95391',
            Property__c = properties.id,
            Bathrooms__c = 0.0,
            Bedrooms__c = 0.0,
            HomeCode__c = 'q20000'
        );
        insert units;
        
        Rental_Listing__c rl = new Rental_Listing__c(
            name = '123 Main St Tracy CA 95391',
            Property_Unit__c = units.id,
            Current_Rent__c = 1200,
            Status__c = ''
        );
        insert rl;
        
        System.runAs(u1) {
            System.test.startTest();
            sMarketkey = properties.Leasing_Market__c;
            dbedkey = units.Bedrooms__c;
            dbathkey = units.Bathrooms__c;
            sStatuskey = rl.Status__c;
            sAddresskey = rl.name;
            pagenumber = 1;
            numberOfRecords = 1;
            pageSize = 1;
            list<Rental_Listing__c> rlisting = searchRentalListingController.getRentalListingList(
                pagenumber,
                numberOfRecords,
                pageSize,
                sMarketkey,
                dbedkey,
                dbathkey,
                sStatuskey,
                sAddresskey
            );
            
            System.test.stopTest();
        }
    }
    static testMethod void getRentalListingCount1(){
        searchRentalListingController.getRentalListingCount('sfdc',double.valueOf(100.0),double.valueOf(100.0),'sfdc','sfdc');
    }
    static testMethod void getRentalListingCount2(){
        searchRentalListingController.getRentalListingCount(null,double.valueOf(100.0),double.valueOf(100.0),'sfdc','sfdc');
    }
    static testMethod void getRentalListingCount3(){
        searchRentalListingController.getRentalListingCount(null,null,double.valueOf(100.0),'sfdc','sfdc');
    }
    static testMethod void getRentalListingCount4(){
        searchRentalListingController.getRentalListingCount(null,null,null,'sfdc','sfdc');
    }
    static testMethod void getRentalListingCount5(){
        searchRentalListingController.getRentalListingCount(null,null,null,null,'sfdc');
    }
    static testMethod void getRentalListingList1(){
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.Leasing_Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
        p.Year_Built__c = '1972';
        p.name = '123 Main St Tracy CA 95391';
        insert p;
        
        Property_Unit__c pu = new Property_Unit__c();
        pu.name = '123 Main St Tracy CA 95391';
        pu.Property__c = p.id;
        pu.Bathrooms__c = 10;
        pu.Bedrooms__c = 10;
        pu.HomeCode__c = 'q2000';        
        insert pu;
        
        Rental_Listing__c rl = new Rental_Listing__c();
        rl.Property_Unit__c = pu.Id;
        rl.Current_Rent__c = 100;
        rl.Name ='sfdc';
        rl.Property_Unit__c = pu.Id;
        rl.Status__c='Unspecified';
        insert rl;
        
        searchRentalListingController.getRentalListingList(1,1,1,'Atlanta',null,null,null,null);
        
    }
    static testMethod void getRentalListingList2(){
        try{
            Property2__c p = new Property2__c();
            p.Market__c = 'Atlanta';
            p.Leasing_Market__c = 'Atlanta';
            p.PropertyCode__c = 'q1000';
            p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
            p.Property_Type__c = 'Single Family';
            p.Year_Built__c = '1972';
            p.name = '123 Main St Tracy CA 95391';
            insert p;
            
            Property_Unit__c pu = new Property_Unit__c();
            pu.name = '123 Main St Tracy CA 95391';
            pu.Property__c = p.id;
            pu.Bathrooms__c = 10;
            pu.Bedrooms__c = 10;
            pu.HomeCode__c = 'q2000';        
            insert pu;
            
            Rental_Listing__c rl = new Rental_Listing__c();
            rl.Property_Unit__c = pu.Id;
            rl.Current_Rent__c = 100;
            rl.Name ='sfdc';
            rl.Property_Unit__c = pu.Id;
            rl.Status__c='Unspecified';
            insert rl;
            
            searchRentalListingController.getRentalListingList(1,1,1,null,10,10,'Unspecified','Unspecified');
        }
        catch(Exception ex){
            
        }
        
    }
    
    static testMethod void getRentalListingList3(){
        try{
            Property2__c p = new Property2__c();
            p.Market__c = 'Atlanta';
            p.Leasing_Market__c = 'Atlanta';
            p.PropertyCode__c = 'q1000';
            p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
            p.Property_Type__c = 'Single Family';
            p.Year_Built__c = '1972';
            p.name = '123 Main St Tracy CA 95391';
            insert p;
            
            Property_Unit__c pu = new Property_Unit__c();
            pu.name = '123 Main St Tracy CA 95391';
            pu.Property__c = p.id;
            pu.Bathrooms__c = 10;
            pu.Bedrooms__c = 10;
            pu.HomeCode__c = 'q2000';        
            insert pu;
            
            Rental_Listing__c rl = new Rental_Listing__c();
            rl.Property_Unit__c = pu.Id;
            rl.Current_Rent__c = 100;
            rl.Name ='sfdc';
            rl.Property_Unit__c = pu.Id;
            rl.Status__c='Unspecified';
            insert rl;
            
            searchRentalListingController.getRentalListingList(1,1,1,null,null,10,'Unspecified','Unspecified');
        }
        catch(Exception ex) {
            
        }       
    }
    
    static testMethod void getRentalListingList4(){
        try{
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.Leasing_Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
        p.Year_Built__c = '1972';
        p.name = '123 Main St Tracy CA 95391';
        insert p;
        
        Property_Unit__c pu = new Property_Unit__c();
        pu.name = '123 Main St Tracy CA 95391';
        pu.Property__c = p.id;
        pu.Bathrooms__c = 10;
        pu.Bedrooms__c = 10;
        pu.HomeCode__c = 'q2000';        
        insert pu;
        
        Rental_Listing__c rl = new Rental_Listing__c();
        rl.Property_Unit__c = pu.Id;
        rl.Current_Rent__c = 100;
        rl.Name ='sfdc';
        rl.Property_Unit__c = pu.Id;
        rl.Status__c='Unspecified';
        insert rl;
        
        searchRentalListingController.getRentalListingList(1,1,1,null,null,null,'Unspecified','Unspecified');
        }
        catch(Exception ex){
            
        }
    }
    
    static testMethod void getRentalListingList5(){
        try{
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.Leasing_Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
        p.Year_Built__c = '1972';
        p.name = '123 Main St Tracy CA 95391';
        insert p;
        
        Property_Unit__c pu = new Property_Unit__c();
        pu.name = '123 Main St Tracy CA 95391';
        pu.Property__c = p.id;
        pu.Bathrooms__c = 10;
        pu.Bedrooms__c = 10;
        pu.HomeCode__c = 'q2000';        
        insert pu;
        
        Rental_Listing__c rl = new Rental_Listing__c();
        rl.Property_Unit__c = pu.Id;
        rl.Current_Rent__c = 100;
        rl.Name ='sfdc';
        rl.Property_Unit__c = pu.Id;
        rl.Status__c='Unspecified';
        insert rl;
        
        searchRentalListingController.getRentalListingList(1,1,1,null,null,null,null,'Unspecified');
        }
        catch(Exception ex){
            
        }
    }
}
@isTest()
public class CaseRelatedDataControllerTest {
    static testMethod void getTenantNullTest() {
        
        TestDataFactory.insertHierarchyCustomSettingData();
        
        Test.startTest();
        Account acc = new Account(Name='asd');
        insert acc;
        Property2__c property = new Property2__c(Name='abc', Fund_Name__c=acc.id);
        insert property;
        Property_Unit__c property_unit = new Property_Unit__c(Name='1111 George Rd',Property__c = property.Id);
        insert property_unit;
        Lease__c lease = new Lease__c(Name='test_lease', Property_Unit__c = property_unit.Id);
        insert lease;
        Tenant__c tenant = new Tenant__c(Name='JS', Email__c='JohnSmith@gmail.com', Lease__c = lease.Id);
        insert tenant;
        
        Case c = new Case();
        insert c;
        
        //EmailMessage em = new EmailMessage(Subject='Test Email',TextBody='25313',FromAddress='JohnSmith@gmail.com',ParentId=c.Id);
        //insert em;
        List<SObject> data=CaseRelatedDataController.getTenant(c.Id);
        System.assert(data==null,'Return data should be empty');
        Test.stopTest();
    }
    
    
    static testMethod void getTenantTest() {
        
        TestDataFactory.insertHierarchyCustomSettingData();
        
        Test.startTest();
        Account acc = new Account(Name='asd');
        insert acc;
        Property2__c property = new Property2__c(Name='abc', Fund_Name__c=acc.id);
        insert property;
        Property_Unit__c property_unit = new Property_Unit__c(Name='1111 George Rd',Property__c = property.Id);
        insert property_unit;
        Lease__c lease = new Lease__c(Name='test_lease', Property_Unit__c = property_unit.Id);
        insert lease;
        Tenant__c tenant = new Tenant__c(Name='JS', Email__c='JohnSmith@gmail.com', Lease__c = lease.Id);
        insert tenant;
        
        Case c = new Case();
        insert c;
        
        EmailMessage em = new EmailMessage(Subject='Test Email',TextBody='25313',FromAddress='JohnSmith@gmail.com',ParentId=c.Id);
        insert em;
        List<SObject> data=CaseRelatedDataController.getTenant(c.Id);
        System.assert(data!=null,'Return data should not be empty');
        Test.stopTest();
    }
    
    static TestMethod void getListsTest(){
        TestDataFactory.insertHierarchyCustomSettingData();
        Test.startTest();
        Account acc = new Account(Name='asd');
        insert acc;
        Property2__c property = new Property2__c(Name='abc', Fund_Name__c=acc.id);
        insert property;
        Property_Unit__c property_unit = new Property_Unit__c(Name='1111 George Rd',Property__c = property.Id);
        insert property_unit;
        Lease__c lease = new Lease__c(Name='test_lease', Property_Unit__c = property_unit.Id);
        insert lease;
        Tenant__c tenant = new Tenant__c(Name='JS', Email__c='JohnSmith@gmail.com', Lease__c = lease.Id);
        insert tenant;
        Tenant__c tenant2 = new Tenant__c(Name='JS2', Email__c='JohnSmith2@gmail.com', Lease__c = lease.Id);
        insert tenant2;
        Rental_Listing__c rental_listing = new Rental_Listing__c(Name='RL', Property_Unit__c=property_unit.Id);
        insert rental_listing;
        Lead_Leasing_Rental_Unit__c llru = new Lead_Leasing_Rental_Unit__c(Rental_Listing__c=rental_listing.Id);
        insert llru;
        Opportunity opp = new Opportunity(Name='opp',stagename='New',Property_Unit__c=property_unit.id,CloseDate=Date.newInstance(2050, 12, 12));
        insert opp;
        
        List<Tenant__c> tenantList = CaseRelatedDataController.getTenantList(tenant.id,lease.id,0,25);
        List<Lease__c> leaseList = CaseRelatedDataController.getLeaseList(tenant.Id, 0, 25);
        List<Opportunity> oppList = CaseRelatedDataController.getOpportunityList(property_unit.Id, 0, 25);
        List<Rental_Listing__c> rlList = CaseRelatedDataController.getRentalListingList(property_unit.Id, 0, 25);
        List<Lead_Leasing_Rental_Unit__c> llruList = CaseRelatedDataController.getLeadLeasingRentalUnitList(rental_listing.Id,0, 25);
        
        System.assert(tenantList!=null,'Return tenantList should not be empty');
        System.assert(leaseList!=null,'Return leaseList should not be empty');
        System.assert(oppList!=null,'Return oppList should not be empty');
        System.assert(rlList!=null,'Return rlList should not be empty');
        System.assert(llruList!=null,'Return llruList should not be empty');
        Test.stopTest();
    }
    
    static TestMethod void getRelationTest(){
        TestDataFactory.insertHierarchyCustomSettingData();
        Test.startTest();
        Account acc = new Account(Name='asd');
        insert acc;
        Property2__c property = new Property2__c(Name='abc', Fund_Name__c=acc.id);
        insert property;
        Property_Unit__c property_unit = new Property_Unit__c(Name='1111 George Rd',Property__c = property.Id);
        insert property_unit;
        Rental_Listing__c rental_listing = new Rental_Listing__c(Name='RL', Property_Unit__c=property_unit.Id);
        insert rental_listing;
        Lead_Leasing_Rental_Unit__c llru = new Lead_Leasing_Rental_Unit__c(Rental_Listing__c=rental_listing.Id);
        insert llru;
        Opportunity opp = new Opportunity(Name='opp',stagename='New',Property_Unit__c=property_unit.id,CloseDate=Date.newInstance(2050, 12, 12));
        insert opp;
        
        List<SObject> relatedRentals = CaseRelatedDataController.getRelationRentalListingLLRU(property_unit.Id);
        List<Opportunity> relatedOpp = CaseRelatedDataController.getRelationOpportunity(property_unit.Id);
        
        System.assert(relatedRentals!=null,'Return relatedRentals should not be empty');
        System.assert(relatedOpp!=null,'Return relatedOpp should not be empty');
        
        Test.stopTest();
    }
    
    
}
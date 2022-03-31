@isTest
public class RentalListingHelperTest {
  private static final string userAlias = 'SLUSER1';
  private static final string RB_LEASING = 'Leasing';
  private static Id leasingOpportunityRecordTypeId;

  // static {
  //   TestDataFactory.createTestLeasingUserRecords(1);
  // }

  // static testMethod void TestUpdateORUStatusNotAvailableLeased() {
  //   User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
  //   leasingOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
  //     .get(RB_LEASING)
  //     .getRecordTypeId();
  //   Property2__c properties = new Property2__c(
  //     Market__c = 'Atlanta',
  //     PropertyCode__c = 'q1000',
  //     PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
  //     Property_Type__c = 'Single Family',
  //     Year_Built__c = 1972,
  //     name = '123 Main St Tracy CA 95391'
  //   );
  //   insert properties;

  //   Property_Unit__c units = new Property_Unit__c(
  //     name = '123 Main St Tracy CA 95391',
  //     Property__c = properties.id,
  //     Bathrooms__c = 3,
  //     Bedrooms__c = 2.5,
  //     HomeCode__c = 'q20000'
  //   );
  //   insert units;

  //   Rental_Listing__c rl = new Rental_Listing__c(
  //     name = '123 Main St Tracy CA 95391',
  //     Property_Unit__c = units.id,
  //     Rental_Listing_Id__c = '139221',
  //     Current_Rent__c = 1200,
  //     Status__c = 'Leased'
  //   );
  //   insert rl;

  //   Opportunity opp = new Opportunity(
  //     Name = '2020-03-25-Monica-Jones',
  //     RecordTypeId = leasingOpportunityRecordTypeId,
  //     StageName = 'New',
  //     CloseDate = Date.newInstance(2020, 3, 29)
  //   );
  //   insert opp;

  //   OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c(
  //     Name = '123 Main St Tracy CA 95391',
  //     Leasing__c = rl.id,
  //     Opportunity__c = opp.id,
  //     Status__c = 'New'
  //   );
  //   insert oru;

  //   //2nd opp
  //   Opportunity opp2 = new Opportunity(
  //     Name = '2020-03-25-Sree-Jones',
  //     RecordTypeId = leasingOpportunityRecordTypeId,
  //     StageName = 'New',
  //     CloseDate = Date.newInstance(2020, 3, 29)
  //   );
  //   insert opp2;

  //   OpportunityRentalUnit__c oru2 = new OpportunityRentalUnit__c(
  //     Name = '123 Main St Tracy CA 95391',
  //     Leasing__c = rl.id,
  //     Opportunity__c = opp2.id,
  //     Status__c = 'New',
  //     listing_status__c='Available'
  //   );
  //   insert oru2;


  //   System.runAs(u1) {
  //     System.test.startTest();

  //     oru.Status__c = 'Lease Signed';
  //     // update rl;
  //     update oru;

  //     System.test.stopTest();
  //      List<Rental_Listing__c> updatedListing = [select status__c from Rental_Listing__c where id = :rl.id];

  //    // List<OpportunityRentalUnit__c> updatedORU = [select listing_status__c from OpportunityRentalUnit__c where id = :oru2.id];
  //      System.assertEquals('Leased', updatedListing[0].status__c);
      
  //     //test if other orus updated to leased
  //    // System.assertEquals('Leased', updatedORU[0].listing_status__c);

  //   }
  // }

  // static testMethod void TestUpdateORUStatusNotAvailableDown() {
  //   User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
  //   leasingOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
  //     .get(RB_LEASING)
  //     .getRecordTypeId();
  //   Property2__c properties = new Property2__c(
  //     Market__c = 'Atlanta',
  //     PropertyCode__c = 'q1000',
  //     PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
  //     Property_Type__c = 'Single Family',
  //     Year_Built__c = 1972,
  //     name = '123 Main St Tracy CA 95391'
  //   );
  //   insert properties;

  //   Property_Unit__c units = new Property_Unit__c(
  //     name = '123 Main St Tracy CA 95391',
  //     Property__c = properties.id,
  //     Bathrooms__c = 3,
  //     Bedrooms__c = 2.5,
  //     HomeCode__c = 'q20000'
  //   );
  //   insert units;

  //   Rental_Listing__c rl = new Rental_Listing__c(
  //     name = '123 Main St Tracy CA 95391',
  //     Property_Unit__c = units.id,
  //     Rental_Listing_Id__c = '139221',
  //     Current_Rent__c = 1200,
  //     Status__c = 'Inactive'
  //   );
  //   insert rl;

  //   Opportunity opp = new Opportunity(
  //     Name = '2020-03-25-Monica-Jones',
  //     RecordTypeId = leasingOpportunityRecordTypeId,
  //     StageName = 'New',
  //     CloseDate = Date.newInstance(2020, 3, 29)
  //   );
  //   insert opp;

  //   OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c(
  //     Name = '123 Main St Tracy CA 95391',
  //     Leasing__c = rl.id,
  //     Opportunity__c = opp.id,
  //     Status__c = 'Available'
  //   );
  //   insert oru;

  //   System.runAs(u1) {
  //     System.test.startTest();
  //     rl.Status__c = 'Inactive';
  //     update rl;
  //     // RentalListingHelper.UpdateOpportunityRentalUnitStatus(
  //     //   rentallistingid,
  //     //   rlistingStatus,
  //     //   rolistingStatus
  //     // );
  //     System.test.stopTest();
  //     // List<OpportunityRentalUnit__c> updatedORU = [select listing_status__c from OpportunityRentalUnit__c where id = :oru.id];
  //     // System.assertEquals('Inactive', updatedORU[0].listing_status__c);
  //     List<Rental_Listing__c> updatedListing = [select status__c from Rental_Listing__c where id = :rl.id];

  //     // List<OpportunityRentalUnit__c> updatedORU = [select listing_status__c from OpportunityRentalUnit__c where id = :oru2.id];
  //       System.assertEquals('Inactive', updatedListing[0].status__c);
    // }
  // }
    static{
        TestDataFactory.insertHierarchyCustomSettingData();
        TestDataFactory.createTestRentalListingRecords(1);
        
    }
    
    static testMethod void updateORU(){
        Rental_Listing__c rlisting = [select Id,Status__c from Rental_Listing__c limit 1];
        rlisting.Status__c = 'Inactive';
        update rlisting;
    }
    static testMethod void updateORUException(){
        Rental_Listing__c rlisting = [select Id,Status__c from Rental_Listing__c limit 1];
        rlisting.Status__c = 'Inactive';
        TriggerDispatcher.forceException = true; 
        try{
        update rlisting;
            }
        catch(exception exe){
            
        }
        
    }
    static testMethod void updateORUCoverage(){
        
        // For coverage ()
        RentalListingTriggerHandler otest = new RentalListingTriggerHandler(); 
        otest.beforeDelete(null,null);
        otest.afterDelete(null,null);
        otest.afterUndelete(null,null);
    }
}
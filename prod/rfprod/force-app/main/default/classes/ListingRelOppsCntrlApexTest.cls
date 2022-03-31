@isTest
public class ListingRelOppsCntrlApexTest {
    
    private static Id leasingAccountRecordTypeId;
    private static Id leasingContactRecordTypeId;
    private static Id leasingOpportunityRecordTypeId;
    private static Id leasingLeadRecordTypeId;
    
    private static final string userAlias = 'SLUSER1';
    private static final string RB_LEASING = 'Leasing';
    
    //static initialization code (load test data)
    static {
        //create test users
        
        TestDataFactory.insertHierarchyCustomSettingData(); 
        TestDataFactory.createTestLeasingUserRecords(1);
        TestDataFactory.createTestLeasingListingRecords(5); 
        
        //load record type info
        leasingAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(RB_LEASING)
            .getRecordTypeId();
        leasingContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
            .get(RB_LEASING)
            .getRecordTypeId();
        leasingOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
            .get(RB_LEASING)
            .getRecordTypeId();
        leasingLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
            .get(RB_LEASING)
            .getRecordTypeId();
    }
    
    static testMethod void leadCreationEmailEnquiry() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        System.debug('user' + u1);
        
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
            Rental_Listing_Id__c = '21978',
            Current_Rent__c = 1200,
            Status__c = 'Unspecified'
        );
        insert rl;
        
        Account acc = new Account();
        acc.Name ='SFDC';
        insert acc;
        
        Opportunity oppt = new Opportunity();
        oppt.Name = 'Opty';
        oppt.AccountId = acc.Id;  //attach opp to above test account
        oppt.StageName = 'Qualified Listing';
        oppt.Property_Street__c = 'Fake Street Address';  //opp name is generate from adress for retail seller!
        oppt.CloseDate = Date.today();
        oppt.Application_Status__c = 'Prospect';
        //opp.CampaignId = camp.Id;
        oppt.Rental_Listing__c = rl.Id;
        oppt.RecordTypeId = leasingOpportunityRecordTypeId;
        insert oppt;
        
        ListingRelOppsCntrlApex.fetchRelatedOppsApex(oppt.Id);
    }
        
        

}
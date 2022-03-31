@isTest
public class OpportunityRentalUnitHelperTest {
private static final string userAlias = 'SLUSER1';
private static final string RB_LEASING = 'Leasing';
private static Id leasingOpportunityRecordTypeId;
    
 static {    
    TestDataFactory.createTestLeasingUserRecords(1); 
    TestDataFactory.insertHierarchyCustomSettingData();
 }

 static testMethod void TestUpdateOpportunityStageLeaseSigned() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
    leasingOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RB_LEASING).getRecordTypeId();
      Property2__c properties = new Property2__c(
      Market__c = 'Atlanta',
      PropertyCode__c = 'q1000',
      PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
      Property_Type__c = 'Single Family',
      Year_Built__c = '1972',
      name = '123 Main St Tracy CA 95391');
      insert properties;
      
      Property_Unit__c units = new Property_Unit__c(
      name = '123 Main St Tracy CA 95391',
      Property__c = properties.id,
      Bathrooms__c = 3,
      Bedrooms__c = 2.5,
      HomeCode__c = 'q20000');
      insert units;
      
      Rental_Listing__c rl = new Rental_Listing__c(
      name = '123 Main St Tracy CA 95391',
      Property_Unit__c = units.id,
      Rental_Listing_Id__c = '139221',
      Current_Rent__c = 1200,
      Status__c = 'Leased');
      insert rl;
     
     Set<Id> accIdSet = new Set<Id>();
     Account acc = new Account();
     acc.Name='Test Account';
     insert acc;
     accIdSet.add(acc.Id);
     
      Set<Id> oppIdSet = new Set<Id>();
      Opportunity opp = new Opportunity(
      Name='2020-03-25-Monica-Jones',
      RecordTypeId=leasingOpportunityRecordTypeId,
      StageName='New',
      accountId = acc.Id,
      CloseDate= Date.newInstance(2020, 03, 29));
      insert opp; 
     oppIdSet.add(opp.Id);
       
       OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c(
       Name='123 Main St Tracy CA 95391',
       Leasing__c= rl.id,
       Opportunity__c=opp.id,
       Status__c='Lease Signed');
       insert oru;
     
      List<OpportunityRentalUnit__c> newORUList = new List<OpportunityRentalUnit__c>();
      newORUList.add(oru); 
          
      Set<Id> newOppIds = new Set<Id>();
      newOppIds.add(opp.Id) ;
     
      System.runAs(u1) {          
      System.test.startTest();      
      //OpportunityRentalUnitHelper.UpdateOpportunityStatus(newORUList, newOppI);     
      OpportunityRentalUnitHelper.UpdateOpportunityStatus(newORUList);
      OpportunityRentalUnitHelper.UpdateOpportunityFields(newORUList,oppIdSet,accIdSet);
      System.test.stopTest();   
       }
  }    

    static testMethod void TestUpdateOpportunityStageApplied() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
    leasingOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RB_LEASING).getRecordTypeId();
      Property2__c properties = new Property2__c(
      Market__c = 'Atlanta',
      PropertyCode__c = 'q1000',
      PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
      Property_Type__c = 'Single Family',
      Year_Built__c = '1972',
      name = '123 Main St Tracy CA 95391');
      insert properties;
      
      Property_Unit__c units = new Property_Unit__c(
      name = '123 Main St Tracy CA 95391',
      Property__c = properties.id,
      Bathrooms__c = 3,
      Bedrooms__c = 2.5,
      HomeCode__c = 'q20000');
      insert units;
      
      Rental_Listing__c rl = new Rental_Listing__c(
      name = '123 Main St Tracy CA 95391',
      Property_Unit__c = units.id,
      Rental_Listing_Id__c = '139221',
      Current_Rent__c = 1200,
      Status__c = 'Leased');
      insert rl;
      
      Opportunity opp = new Opportunity(
      Name='2020-03-25-Monica-Jones',
      RecordTypeId=leasingOpportunityRecordTypeId,
      StageName='New',
      CloseDate= Date.newInstance(2020, 03, 29));
      insert opp;  
       
       OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c(
       Name='123 Main St Tracy CA 95391',
       Leasing__c= rl.id,
       Opportunity__c=opp.id,
       Status__c='Applied');
       insert oru;
     
      List<OpportunityRentalUnit__c> newORUList = new List<OpportunityRentalUnit__c>();
      newORUList.add(oru); 
          
      Set<Id> newOppIds = new Set<Id>();
      newOppIds.add(opp.Id) ;
     
      System.runAs(u1) {          
      System.test.startTest();      
      //OpportunityRentalUnitHelper.UpdateOpportunityStatus(newORUList, newOppIds);
      OpportunityRentalUnitHelper.UpdateOpportunityStatus(newORUList);
      System.test.stopTest();   
       }
  }   
    
     static testMethod void TestUpdateOpportunityStageApplicationStarted() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
    leasingOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RB_LEASING).getRecordTypeId();
      Property2__c properties = new Property2__c(
      Market__c = 'Atlanta',
      PropertyCode__c = 'q1000',
      PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
      Property_Type__c = 'Single Family',
      Year_Built__c = '1972',
      name = '123 Main St Tracy CA 95391');
      insert properties;
      
      Property_Unit__c units = new Property_Unit__c(
      name = '123 Main St Tracy CA 95391',
      Property__c = properties.id,
      Bathrooms__c = 3,
      Bedrooms__c = 2.5,
      HomeCode__c = 'q20000');
      insert units;
      
      Rental_Listing__c rl = new Rental_Listing__c(
      name = '123 Main St Tracy CA 95391',
      Property_Unit__c = units.id,
      Rental_Listing_Id__c = '139221',
      Current_Rent__c = 1200,
      Status__c = 'Leased');
      insert rl;
      
      Opportunity opp = new Opportunity(
      Name='2020-03-25-Monica-Jones',
      RecordTypeId=leasingOpportunityRecordTypeId,
      StageName='New',
      CloseDate= Date.newInstance(2020, 03, 29));
      insert opp;  
       
       OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c(
       Name='123 Main St Tracy CA 95391',
       Leasing__c= rl.id,
       Opportunity__c=opp.id,
       Status__c='Application Started');
       insert oru;
     
      List<OpportunityRentalUnit__c> newORUList = new List<OpportunityRentalUnit__c>();
      newORUList.add(oru); 
          
      Set<Id> newOppIds = new Set<Id>();
      newOppIds.add(opp.Id) ;
     
      System.runAs(u1) {          
      System.test.startTest();      
      //OpportunityRentalUnitHelper.UpdateOpportunityStatus(newORUList, newOppIds);
      OpportunityRentalUnitHelper.UpdateOpportunityStatus(newORUList);
       update oru;
      System.test.stopTest();   
       }
  }
    
    static testMethod void TestUpdateOpportunityStageDecisionMade() {
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
    leasingOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(RB_LEASING).getRecordTypeId();
      Property2__c properties = new Property2__c(
      Market__c = 'Atlanta',
      PropertyCode__c = 'q1000',
      PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
      Property_Type__c = 'Single Family',
      Year_Built__c = '1972',
      name = '123 Main St Tracy CA 95391');
      insert properties;
      
      Property_Unit__c units = new Property_Unit__c(
      name = '123 Main St Tracy CA 95391',
      Property__c = properties.id,
      Bathrooms__c = 3,
      Bedrooms__c = 2.5,
      HomeCode__c = 'q20000');
      insert units;
      
      Rental_Listing__c rl = new Rental_Listing__c(
      name = '123 Main St Tracy CA 95391',
      Property_Unit__c = units.id,
      Rental_Listing_Id__c = '139221',
      Current_Rent__c = 1200,
      Status__c = 'Leased');
      insert rl;
      
      Opportunity opp = new Opportunity(
      Name='2020-03-25-Monica-Jones',
      RecordTypeId=leasingOpportunityRecordTypeId,
      StageName='New',
      CloseDate= Date.newInstance(2020, 03, 29));
      insert opp;  
       
       OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c(
       Name='123 Main St Tracy CA 95391',
       Leasing__c= rl.id,
       Opportunity__c=opp.id,
       Status__c='Denied');
       insert oru;
     
      List<OpportunityRentalUnit__c> newORUList = new List<OpportunityRentalUnit__c>();
      newORUList.add(oru); 
          
      Set<Id> newOppIds = new Set<Id>();
      newOppIds.add(opp.Id) ;
     
      System.runAs(u1) {          
      System.test.startTest();      
      //OpportunityRentalUnitHelper.UpdateOpportunityStatus(newORUList, newOppIds);
      OpportunityRentalUnitHelper.UpdateOpportunityStatus(newORUList);
       update oru;
      System.test.stopTest();   
       }
 
}
}
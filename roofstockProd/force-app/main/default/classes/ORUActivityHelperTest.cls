@isTest
public class ORUActivityHelperTest {
    static {
        //create test users
        TestDataFactory.insertHierarchyCustomSettingData();  
        TestDataFactory.createTestLeasingUserRecords(1);
        TestDataFactory.createTestLeasingListingRecords(5);
    }
    static testMethod void ORUActivity_application_started() {
        
        Account acc = new Account();
        acc.Name='Test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name='Test';
        opp.StageName = 'Viewed';
        opp.closeDate= System.today();
        insert opp;
        
        OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c();
        oru.Opportunity__c = opp.Id;
        insert oru;
        
        Opportunity_Rental_Unit_Activity__c oruActivity = new Opportunity_Rental_Unit_Activity__c();
        oruActivity.Opportunity_Rental_Unit__c = oru.Id;
        oruActivity.Activity_Code__c = 'application_started';
        insert oruActivity; 
        
        
    }
    static testMethod void ORUActivity_self_registered_viewing() {
        
        Account acc = new Account();
        acc.Name='Test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name='Test';
        opp.StageName = 'Viewed';
        opp.closeDate= System.today();
        insert opp;
        
        OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c();
        oru.Opportunity__c = opp.Id;
        insert oru;
        
        Opportunity_Rental_Unit_Activity__c oruActivity = new Opportunity_Rental_Unit_Activity__c();
        oruActivity.Opportunity_Rental_Unit__c = oru.Id;
        oruActivity.Activity_Code__c = 'self_registered_viewing';
        insert oruActivity; 
        
        
    }
    static testMethod void ORUActivity_self_registered_scheduling() {
        
        Account acc = new Account();
        acc.Name='Test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name='Test';
        opp.StageName = 'Viewed';
        opp.closeDate= System.today();
        insert opp;
        
        OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c();
        oru.Opportunity__c = opp.Id;
        insert oru;
        
        Opportunity_Rental_Unit_Activity__c oruActivity = new Opportunity_Rental_Unit_Activity__c();
        oruActivity.Opportunity_Rental_Unit__c = oru.Id;
        oruActivity.Activity_Code__c = 'self_registered_scheduling';
        insert oruActivity; 
        
        
    }
    static testMethod void ORUActivity_application_applied() {
        
        Account acc = new Account();
        acc.Name='Test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name='Test';
        opp.StageName = 'Viewed';
        opp.closeDate= System.today();
        insert opp;
        
        OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c();
        oru.Opportunity__c = opp.Id;
        insert oru;
        
        Opportunity_Rental_Unit_Activity__c oruActivity = new Opportunity_Rental_Unit_Activity__c();
        oruActivity.Opportunity_Rental_Unit__c = oru.Id;
        oruActivity.Activity_Code__c = 'application_applied';
        insert oruActivity; 
        
        
    }
    static testMethod void ORUActivity_application_approved() {
        
        Account acc = new Account();
        acc.Name='Test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name='Test';
        opp.StageName = 'Viewed';
        opp.closeDate= System.today();
        insert opp;
        
        OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c();
        oru.Opportunity__c = opp.Id;
        insert oru;
        
        Opportunity_Rental_Unit_Activity__c oruActivity = new Opportunity_Rental_Unit_Activity__c();
        oruActivity.Opportunity_Rental_Unit__c = oru.Id;
        oruActivity.Activity_Code__c = 'application_approved';
        insert oruActivity; 
        
        
    }
    static testMethod void ORUActivity_application_canceled() {
        
        Account acc = new Account();
        acc.Name='Test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name='Test';
        opp.StageName = 'Viewed';
        opp.closeDate= System.today();
        insert opp;
        
        OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c();
        oru.Opportunity__c = opp.Id;
        insert oru;
        
        Opportunity_Rental_Unit_Activity__c oruActivity = new Opportunity_Rental_Unit_Activity__c();
        oruActivity.Opportunity_Rental_Unit__c = oru.Id;
        oruActivity.Activity_Code__c = 'application_canceled';
        insert oruActivity; 
        
        
    }
    static testMethod void ORUActivity_prospect_canceled() {
        
        Account acc = new Account();
        acc.Name='Test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name='Test';
        opp.StageName = 'Viewed';
        opp.closeDate= System.today();
        insert opp;
        
        OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c();
        oru.Opportunity__c = opp.Id;
        insert oru;
        
        Opportunity_Rental_Unit_Activity__c oruActivity = new Opportunity_Rental_Unit_Activity__c();
        oruActivity.Opportunity_Rental_Unit__c = oru.Id;
        oruActivity.Activity_Code__c = 'prospect_canceled';
        
        insert oruActivity; 
        
    }
    static testMethod void ORUActivity_prospect_ControlledShowing() {
        
        Account acc = new Account();
        acc.Name='Test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name='Test';
        opp.StageName = 'Viewed';
        opp.closeDate= System.today();
        insert opp;
        
        OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c();
        oru.Opportunity__c = opp.Id;
        insert oru;
        
        Opportunity_Rental_Unit_Activity__c oruActivity = new Opportunity_Rental_Unit_Activity__c();
        oruActivity.Opportunity_Rental_Unit__c = oru.Id;
        oruActivity.Activity_Code__c = 'controlled_showing';
        
        insert oruActivity; 
        
    }
    static testMethod void ORUActivity_application_denied() {
        
        Account acc = new Account();
        acc.Name='Test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name='Test';
        opp.StageName = 'Viewed';
        opp.closeDate= System.today();
        insert opp;
        
        OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c();
        oru.Opportunity__c = opp.Id;
        insert oru;
        
        Opportunity_Rental_Unit_Activity__c oruActivity = new Opportunity_Rental_Unit_Activity__c();
        oruActivity.Opportunity_Rental_Unit__c = oru.Id;
        oruActivity.Activity_Code__c = 'application_denied';
        insert oruActivity; 
        
    }
    static testMethod void ORUActivity_application_transferBlankFeedback() {
        
        Account acc = new Account();
        acc.Name='Test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name='Test';
        opp.StageName = 'Viewed';
        opp.closeDate= System.today();
        insert opp;
        
        OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c();
        oru.Opportunity__c = opp.Id;
        insert oru;
        
        Opportunity_Rental_Unit_Activity__c oruActivity = new Opportunity_Rental_Unit_Activity__c();
        oruActivity.Opportunity_Rental_Unit__c = oru.Id;
        oruActivity.Activity_Code__c = 'application_transfer';
        insert oruActivity; 
        
    }
    static testMethod void ORUActivity_application_transferFeedback() {
        
        Account acc = new Account();
        acc.Name='Test';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name='Test';
        opp.StageName = 'Viewed';
        opp.closeDate= System.today();
        insert opp;
        
        OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c();
        oru.Opportunity__c = opp.Id;
        insert oru;
        
        Opportunity_Rental_Unit_Activity__c oruActivity = new Opportunity_Rental_Unit_Activity__c();
        oruActivity.Opportunity_Rental_Unit__c = oru.Id;
        oruActivity.Activity_Code__c = 'self_registered_viewing';
        oruActivity.Feedback__c = 'SFDC';
        insert oruActivity; 
        
    }
    static testMethod void Exception(){
        TriggerDispatcher.forceException = true;
        
        try{
            OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c();
            // oru.Opportunity__c = opp.Id;
            insert oru;
        }
        Catch(Exception ex){
            
        }
    }
    
    
}
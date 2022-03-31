/////////////////////////////////////////////////////
// Copyright 2018 Cloud Pathfinder Consulting, LLC //
////////////////////////////////////////////////////
//
// RetailBuyerOfferMadeTest.apxc
//
// To Test: Need to create and insert a list of Contacts,
// then update the "Offer Made" field, then push these
// updates into the database. StageNames must be other
// than CW/CL/IC and RecordType must be Retail Buyer

@isTest
public class RetailBuyerOfferMadeTest
{
    static{
        TestDataFactory.insertHierarchyCustomSettingData();
    }
	public static testMethod void test()
    {
        // This is to retrieve the RecordTypeId for "Retail Buyer" without hardcoding
        // so that we can set this on creating our Opportunity
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
                  .get('Retail Buyer').getRecordTypeId();
        
        Contact testCon;
        Opportunity testOpp;
        Account testAcct = new Account( Name = 'TestAcc' );	// Create an Account to associate
        													// with our Contact and Opportunity
        insert testAcct;
        
        // Fill in necessary details for Contact and Opportunity in order to
        // reproduce the correct conditions for our trigger. Making sure to
        // associate both sObjects with the parent Account
        testCon = new Contact( LastName = 'TestCon1', AccountId = testAcct.Id );
        
        testOpp = new Opportunity( Name = 'TestOpp1', StageName = 'Pre-approved', 
                                  CloseDate = Date.today(), AccountId = testAcct.Id,
                                 RecordTypeId = recordTypeId );
        
        insert testCon;
        insert testOpp;
        
        Test.startTest(); /////////////
        
        	// change Made_An_Offer_Date__c to Date.today() and 
        	// perform a SOQL query to test if opp.StageName
        	// has changed.
        	
        	testCon.Made_An_Offer_Date__c = Datetime.now();
        
        	update testCon;
        
        	Opportunity queryOpp = [ SELECT Id, StageName
                                   FROM Opportunity
                                   WHERE Id = :testOpp.Id ];
        
        	System.assertEquals( 'Offer Submitted', queryOpp.StageName );
        
        Test.stopTest(); /////////////
        
        delete testOpp;
        delete testCon;
        delete testAcct;
    }
}
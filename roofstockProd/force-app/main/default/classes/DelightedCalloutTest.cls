/***************************************************************
 * 		Copyright 2018 Cloud Pathfinder Consulting, LLC 	   *
 * *************************************************************
 * 
 * 
 * 
 */

@isTest
public class DelightedCalloutTest {
    static{
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    
    @isTest 
    static void testCallout()
    {
        RecordType rt = [SELECT Id, Name
                         FROM RecordType
                         WHERE Name = 'Retail Buyer' AND
                         sObjectType = 'Opportunity' LIMIT 1];

        Set<Id> testSet = new Set<Id>();
        
        Account acc = new Account(Name = 'USA');
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'America',
                                          StageName = 'Closed Lost',
                                          CloseDate = Date.today(),
                                          RecordTypeId = rt.Id,
                                          AccountId = acc.Id
                                         );
        insert opp;

        Contact con = new Contact(FirstName = 'Josiah',
                                  LastName = 'Anderson',
                                  Phone = '4084696712',
                                  Email = 'josiah@cloudpathfinderconsulting.com',
                                  AccountId = acc.Id
                                 );
        
        insert con;
        testSet.add(opp.Id);
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockDelightedResponse());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        
        // This give us a valid update to Opportunity
        opp.StageName = 'Closed Won';
        update opp;
        
        Test.startTest();
      	
        // This fires trigger and then callout in turn
        //update opp;
        DelightedCallout.createPerson(testSet);
        
        Test.stopTest();
        
        // Verify response received contains fake values
        if(DelightedCallout.global_res != null)
        	System.assertEquals('{"id":"1", "email":"josiah@cloudpathfinderconsulting.com", "phone":"4084696712", "name":null, "survey_scheduled_at":1539819328}',
                            	DelightedCallout.global_res.getBody());

    }
}
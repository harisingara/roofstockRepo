@isTest
public class InspectionUpdateToBMPCalloutTest {

    @isTest(seealldata=true)
    static void testCallout()
    {        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockInspectionUpdateToBMPCallout());

        // Sample Inspection records
        Set<Id> testSet = new Set<Id>();
        for (Inspection__c ins : [select id from Inspection__c limit 5]) {
            testSet.add(ins.Id);
        }

        Test.startTest();
      	
        // This fires trigger and then callout in turn
        //update opp;
        InspectionUpdateToBMPCallout.updateBMPCallout(testSet);
        
        Test.stopTest();
        
        // Verify response received contains fake values
        if(InspectionUpdateToBMPCallout.global_res != null)
        	System.assertEquals('{"inspectionListResponse": [{"bpmId": "10200"}],"isSuccessful": true}',
                                InspectionUpdateToBMPCallout.global_res.getBody());

    }
}
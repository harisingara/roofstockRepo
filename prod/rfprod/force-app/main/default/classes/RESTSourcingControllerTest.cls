@isTest
public class RESTSourcingControllerTest {
    
    static { 
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void sourcingTest() {
        Sourcing__c src = new Sourcing__c();
        src.Phone_Number__c = '9876544567';
        src.Email__c = 'a@gmail.com';
        src.Type_of_Request__c = 'Specific Markets';
        src.Name = 'Sourcing';
        src.States__c = 'CA';
        src.Markets__c = 'market';
        insert src;
        List<RESTSourcingHelper.Sourcing> sourcingList = new List<RESTSourcingHelper.Sourcing>();
        RESTSourcingHelper.Sourcing contextSourcing = new RESTSourcingHelper.Sourcing();
        contextSourcing.firstName = 'fname';
        contextSourcing.lastName = 'lname';
        contextSourcing.phone = '8767233234';
        contextSourcing.email = 'a@gmail.com';
        contextSourcing.state = 'CA';
        contextSourcing.market = 'market';
        contextSourcing.requestType = 'Specific Markets';
        sourcingList.add(contextSourcing);
        
        RESTSourcingHelper.SourcingWrap sourceRequest = new RESTSourcingHelper.SourcingWrap();
        sourceRequest.sourcingList = sourcingList;
        String sReq = JSON.serialize(sourceRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/updateSourcing';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTSourcingController.updateSourcing();
        Test.stopTest();
    }
    static testMethod void sourcingExceptionTest() {
        Sourcing__c src = new Sourcing__c();
        src.Phone_Number__c = '9876544567';
        src.Email__c = 'a@gmail.com';
        src.Type_of_Request__c = 'Specific Markets';
        src.Name = 'Sourcing';
        src.States__c = 'CA';
        src.Markets__c = 'market';
        insert src;
        List<RESTSourcingHelper.Sourcing> sourcingList = new List<RESTSourcingHelper.Sourcing>();
        RESTSourcingHelper.Sourcing contextSourcing = new RESTSourcingHelper.Sourcing();
        contextSourcing.firstName = 'fname';
        contextSourcing.lastName = 'lname';
        contextSourcing.phone = '8767233234';
        contextSourcing.email = 'a@gmail.com';
        contextSourcing.state = 'CA';
        contextSourcing.market = 'market';
        contextSourcing.requestType = 'Specific Markets';
        sourcingList.add(contextSourcing);
        
        RESTSourcingHelper.SourcingWrap sourceRequest = new RESTSourcingHelper.SourcingWrap();
        sourceRequest.sourcingList = sourcingList;
        String sReq = JSON.serialize(sourceRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/updateSourcing';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{');
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTSourcingController.updateSourcing();
        Test.stopTest();
    }
}
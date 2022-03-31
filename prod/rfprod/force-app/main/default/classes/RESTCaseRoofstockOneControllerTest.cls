@isTest
public class RESTCaseRoofstockOneControllerTest {
    static { 
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void RESTTransactionControllerTest1() {
        Account a = new Account(Name = 'TestAccount',Roofstock_Account_ID__c='5678');
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test@nowhere.com',
            BPM_Contact_Id__c = '1234',
            HasOptedOutOfEmail =false,
            AccountId = a.Id
        );
        insert c;
        List<RESTCaseRoofstockOneHelper.CaseRSOne> rsOneCaseList = new List<RESTCaseRoofstockOneHelper.CaseRSOne>();
        RESTCaseRoofstockOneHelper.CaseRSOne contextCase = new RESTCaseRoofstockOneHelper.CaseRSOne();
        contextCase.subject = 'Roofstock One';
        contextCase.description = 'Roofstock One';
        contextCase.email = 'a@gmail.com';
        contextCase.phone='9741733159';
        contextCase.contactId = '1234';
        contextCase.accountId ='5678';
        rsOneCaseList.add(contextCase);
        
        RESTCaseRoofstockOneHelper.CaseRSOneWrap caseRequest = new RESTCaseRoofstockOneHelper.CaseRSOneWrap();
        caseRequest.caseRSOneList = rsOneCaseList;
        String sReq = JSON.serialize(caseRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/createCaseRoofstockOne';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTCaseRoofstockOneController.createCaseRSOne();
        Test.stopTest();
           
    }
    
    static testMethod void RESTTransactionControllerTest2() {
        Account a = new Account(Name = 'TestAccount',Roofstock_Account_ID__c='5678');
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test@nowhere.com',
            BPM_Contact_Id__c = '1234',
            HasOptedOutOfEmail =false,
            AccountId = a.Id
        );
        insert c;
        List<RESTCaseRoofstockOneHelper.CaseRSOne> rsOneCaseList = new List<RESTCaseRoofstockOneHelper.CaseRSOne>();
        RESTCaseRoofstockOneHelper.CaseRSOne contextCase = new RESTCaseRoofstockOneHelper.CaseRSOne();
        contextCase.subject = 'Roofstock One';
        contextCase.description = 'Roofstock One';
        contextCase.email = 'a@gmail.com';
        contextCase.phone='9741733159';
        contextCase.contactId = '1234';
        contextCase.accountId ='5678';
        rsOneCaseList.add(contextCase);
        
        RESTCaseRoofstockOneHelper.CaseRSOneWrap caseRequest = new RESTCaseRoofstockOneHelper.CaseRSOneWrap();
        caseRequest.caseRSOneList = rsOneCaseList;
        String sReq = JSON.serialize(caseRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/createCaseRoofstockOne';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{');
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTCaseRoofstockOneController.createCaseRSOne();
        Test.stopTest();
        
        
    }
    static testMethod void RESTTransactionControllerTest3() {
        Account a = new Account(Name = 'TestAccount',Roofstock_Account_ID__c='5678');
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'a@gmail.com',
            BPM_Contact_Id__c = '1234',
            HasOptedOutOfEmail =false,
            AccountId = a.Id
        );
        insert c;
        List<RESTCaseRoofstockOneHelper.CaseRSOne> rsOneCaseList = new List<RESTCaseRoofstockOneHelper.CaseRSOne>();
        RESTCaseRoofstockOneHelper.CaseRSOne contextCase = new RESTCaseRoofstockOneHelper.CaseRSOne();
        contextCase.subject = 'Roofstock One';
        contextCase.description = 'Roofstock One';
        contextCase.email = 'a@gmail.com';
        contextCase.phone='9741733159';
        contextCase.contactId = '4533';
        contextCase.accountId ='5678';
        rsOneCaseList.add(contextCase);
        
        RESTCaseRoofstockOneHelper.CaseRSOneWrap caseRequest = new RESTCaseRoofstockOneHelper.CaseRSOneWrap();
        caseRequest.caseRSOneList = rsOneCaseList;
        String sReq = JSON.serialize(caseRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/createCaseRoofstockOne';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTCaseRoofstockOneController.createCaseRSOne();
        Test.stopTest();
           
    }
    static testMethod void RESTTransactionControllerTest4() {
        Account a = new Account(Name = 'TestAccount',Roofstock_Account_ID__c='5678');
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'a@gmail.com',
            BPM_Contact_Id__c = '1234',
            HasOptedOutOfEmail =false,
            phone='9741733159',
            AccountId = a.Id
        );
        insert c;
        List<RESTCaseRoofstockOneHelper.CaseRSOne> rsOneCaseList = new List<RESTCaseRoofstockOneHelper.CaseRSOne>();
        RESTCaseRoofstockOneHelper.CaseRSOne contextCase = new RESTCaseRoofstockOneHelper.CaseRSOne();
        contextCase.subject = 'Roofstock One';
        contextCase.description = 'Roofstock One';
        contextCase.email = 'ab@gmail.com';
        contextCase.phone='9741733159';
        contextCase.contactId = '4533';
        contextCase.accountId ='5678';
        rsOneCaseList.add(contextCase);
        
        RESTCaseRoofstockOneHelper.CaseRSOneWrap caseRequest = new RESTCaseRoofstockOneHelper.CaseRSOneWrap();
        caseRequest.caseRSOneList = rsOneCaseList;
        String sReq = JSON.serialize(caseRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/createCaseRoofstockOne';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTCaseRoofstockOneController.createCaseRSOne();
        Test.stopTest();
           
    }
    
}
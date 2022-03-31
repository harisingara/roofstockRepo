@isTest
public class RESTCaseControllerTest {
    static testMethod void RESTCaseControllerCertificationTest() {        
        //List<RESTListingHelper.Listings>listingList = new List<RESTListingHelper.Listings>();
        TestDataFactory.insertHierarchyCustomSettingData();
        RESTCaseHelper.Cases newCase= new RESTCaseHelper.Cases();
        
        RESTCaseHelper.caseWrap caseTest= new RESTCaseHelper.caseWrap();
        Account acc = new Account();
        acc.Name='Test Company';
        acc.Roofstock_Account_ID__c = '1234';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName='sales';
        con.LastName = 'force';
        con.AccountId = acc.Id;
        con.BPM_Contact_Id__c = '1234';
        insert con;
        
        Certification__c cert = new Certification__c();
        cert.BPM_Certification_Id__c = '1234';
        insert cert;
        
        newCase.type = 'certification';
        newCase.externalId = '1234';
        newCase.subject = 'my transaction is taking too long!';
        newCase.description = 'what is going on?';
        newCase.firstName = 'Sree';
        newCase.lastName = 'menon';
        newCase.email = 'sree@gmail.com';
        newCase.phone = '9741733159';
        newCase.contactId = '1234';
        newCase.accountId = '1234';
        newCase.ownerEmailAddress = 'Krystyna@roofstock.com';
        caseTest.case_x = newCase; 
        String sReq = JSON.serialize(caseTest);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/createCase';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTCaseController.createCase();
        Test.stopTest();
    }
    static testMethod void RESTCaseControllerTransactionTest() {        
        //List<RESTListingHelper.Listings>listingList = new List<RESTListingHelper.Listings>();
        TestDataFactory.insertHierarchyCustomSettingData();
        RESTCaseHelper.Cases newCase= new RESTCaseHelper.Cases();
        RESTCaseHelper.caseWrap caseTest= new RESTCaseHelper.caseWrap();
       /* Account acc = new Account();
        acc.Name='Test Company';
        acc.Roofstock_Account_ID__c = '1234';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName='sales';
        con.LastName = 'force';
        con.AccountId = acc.Id;
        con.BPM_Contact_Id__c = '1234';
        insert con;
        
        Transaction__c trans = new Transaction__c();
        trans.Transaction_Id__c = '1234';
        insert trans;*/
        newCase.type = 'Transaction';
        newCase.externalId = '1234';
        newCase.subject = 'my transaction is taking too long!';
        newCase.description = 'what is going on?';
        newCase.firstName = 'Sree';
        newCase.lastName = 'menon';
        newCase.email = 'sree@gmail.com';
        newCase.phone = '9741733159';
        newCase.contactId = '1234';
        newCase.accountId = '1234';
        newCase.ownerEmailAddress = 'Krystyna@roofstock.com';
        newCase.reasonForContact = 'Property Manager';
         caseTest.case_x = newCase; 
        String sReq = JSON.serialize(caseTest);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/createCase';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTCaseController.createCase();
        req.requestBody = Blob.valueOf('');
        RESTCaseController.createCase();
        Test.stopTest(); 
    }
    static testMethod void RESTCaseControllerTransactionTest2() {        
        //List<RESTListingHelper.Listings>listingList = new List<RESTListingHelper.Listings>();
        TestDataFactory.insertHierarchyCustomSettingData();
        RESTCaseHelper.Cases newCase= new RESTCaseHelper.Cases();
        RESTCaseHelper.caseWrap caseTest= new RESTCaseHelper.caseWrap();
      
        newCase.type = 'Transaction';
        newCase.externalId = '1234';
        newCase.subject = 'my transaction is taking too long!';
        newCase.description = 'what is going on?';
        newCase.firstName = 'Sree';
        newCase.lastName = 'menon';
        newCase.email = 'sree@gmail.com';
        newCase.phone = '9741733159';
        newCase.contactId = '1234';
        newCase.accountId = '1234';
        newCase.ownerEmailAddress = 'Krystyna@roofstock.com';
        newCase.reasonForContact = 'Appraisal Contingency';
         caseTest.case_x = newCase; 
        String sReq = JSON.serialize(caseTest);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/createCase';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTCaseController.createCase();
        req.requestBody = Blob.valueOf('');
        RESTCaseController.createCase();
        Test.stopTest(); 
    }
    static testMethod void RESTCaseControllerTransactionTest3() {        
        //List<RESTListingHelper.Listings>listingList = new List<RESTListingHelper.Listings>();
        TestDataFactory.insertHierarchyCustomSettingData();
        RESTCaseHelper.Cases newCase= new RESTCaseHelper.Cases();
        RESTCaseHelper.caseWrap caseTest= new RESTCaseHelper.caseWrap();
      
        newCase.type = 'Transaction';
        newCase.externalId = '1234';
        newCase.subject = 'my transaction is taking too long!';
        newCase.description = 'what is going on?';
        newCase.firstName = 'Sree';
        newCase.lastName = 'menon';
        newCase.email = 'sree@gmail.com';
        newCase.phone = '9741733159';
        newCase.contactId = '1234';
        newCase.accountId = '1234';
        newCase.ownerEmailAddress = 'Krystyna@roofstock.com';
        newCase.reasonForContact = 'Other';
         caseTest.case_x = newCase; 
        String sReq = JSON.serialize(caseTest);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/createCase';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTCaseController.createCase();
        req.requestBody = Blob.valueOf('');
        RESTCaseController.createCase();
        Test.stopTest(); 
    }
    
}
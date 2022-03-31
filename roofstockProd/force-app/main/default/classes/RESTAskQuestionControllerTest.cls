@isTest
public class RESTAskQuestionControllerTest {
    static { 
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void RESTAskQuestionController1() {
        
        List<RESTAskQuestionHelper.Leads> leadList = new List<RESTAskQuestionHelper.Leads>();
        RESTAskQuestionHelper.Leads requestLead = new RESTAskQuestionHelper.Leads();
        requestLead.Email = 'sfdc@salesforce.com';
        requestLead.firstName = 'sfdc';
        requestLead.lastName = 'sfdc';
        requestLead.phone ='3434233456';
        requestLead.rsAccountId ='123458';
        requestLead.rsContactId = '123458';
        requestLead.timeframeForInvesting ='Less than 30 days';
        requestLead.totalCapitalAvailable = 'Less than 20k';
        requestLead.financing = 'Not Pre-qualified';
        requestLead.description = 'Re: <123 Main St, Dallas, Tx, 75214>';
        requestLead.buyerBrokerName = 'sfdc';
        requestLead.buyerBrokerBrokerageName = 'sfdc';
        requestLead.buyerBrokerPhone = '9741733159';
        requestLead.buyerBrokerEmail = 'sfdc@gmail.com';
        requestLead.propertyAddress = 'AZ';
        requestLead.buyerAccountId = '1234';
        leadList.add(requestLead);
        
        RESTAskQuestionHelper.LeadsWrap leadRequest = new RESTAskQuestionHelper.LeadsWrap();
        leadRequest.leadList = leadList;
        String sReq = JSON.serialize(leadRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/askRetailQuestionLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTAskQuestionController.createLeadAndTask();
        Test.stopTest();
        
    }
    
    static testMethod void RESTAskQuestionController2() {
        Lead newLead = new Lead();
        newLead.LastName = 'sfdc';
        newLead.FirstName = 'sfdc';
        newLead.Company = 'sfdc';
        newLead.MobilePhone = '3434233456';
        newLead.Phone = '3434233456';
        insert newLead;
        
        List<RESTAskQuestionHelper.Leads> leadList = new List<RESTAskQuestionHelper.Leads>();
        RESTAskQuestionHelper.Leads requestLead = new RESTAskQuestionHelper.Leads();
        requestLead.Email = 'sfdc@salesforce.com';
        requestLead.firstName = 'sfdc';
        requestLead.lastName = 'sfdc';
        requestLead.phone ='3434233456';
        requestLead.rsAccountId ='123458';
        requestLead.rsContactId = '123458';
        requestLead.timeframeForInvesting ='Less than 30 days';
        requestLead.totalCapitalAvailable = 'Less than 20k';
        requestLead.financing = 'Not Pre-qualified';
        requestLead.description = 'Re: <123 Main St, Dallas, Tx, 75214>';
        requestLead.buyerBrokerName = 'sfdc';
        requestLead.buyerBrokerBrokerageName = 'sfdc';
        requestLead.buyerBrokerPhone = '9741733159';
        requestLead.buyerBrokerEmail = 'sfdc@gmail.com';
        requestLead.propertyAddress = 'AZ';
        requestLead.buyerAccountId = '1234';
        leadList.add(requestLead);
        
        RESTAskQuestionHelper.LeadsWrap leadRequest = new RESTAskQuestionHelper.LeadsWrap();
        leadRequest.leadList = leadList;
        String sReq = JSON.serialize(leadRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/askRetailQuestionLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTAskQuestionController.createLeadAndTask();
        Test.stopTest();
        
    }
    
    static testMethod void RESTAskQuestionController3() {
        Contact con = new Contact();
        con.LastName = 'sfdc';
        con.BPM_Contact_Id__c = '12345';
        con.Phone = '3434233456';
        con.MobilePhone = '3434233456';
        insert con;
        
        Lead newLead = new Lead();
        newLead.LastName = 'sfdc';
        newLead.FirstName = 'sfdc';
        newLead.Company = 'sfdc';
        newLead.Email = 'sfdc@salesforce.com';
        insert newLead;
        
        List<RESTAskQuestionHelper.Leads> leadList = new List<RESTAskQuestionHelper.Leads>();
        RESTAskQuestionHelper.Leads requestLead = new RESTAskQuestionHelper.Leads();
        requestLead.Email = 'sfdc@salesforce.com';
        requestLead.firstName = 'sfdc';
        requestLead.lastName = 'sfdc';
        requestLead.phone ='3434233456';
        requestLead.rsAccountId ='123458';
        requestLead.rsContactId = '12345';
        requestLead.timeframeForInvesting ='Less than 30 days';
        requestLead.totalCapitalAvailable = 'Less than 20k';
        requestLead.financing = 'Not Pre-qualified';
        requestLead.description = 'Re: <123 Main St, Dallas, Tx, 75214>';
        requestLead.buyerBrokerName = 'sfdc';
        requestLead.buyerBrokerBrokerageName = 'sfdc';
        requestLead.buyerBrokerPhone = '9741733159';
        requestLead.buyerBrokerEmail = 'sfdc@gmail.com';
        requestLead.propertyAddress = 'AZ';
        requestLead.buyerAccountId = '1234';
        leadList.add(requestLead);
        
        RESTAskQuestionHelper.LeadsWrap leadRequest = new RESTAskQuestionHelper.LeadsWrap();
        leadRequest.leadList = leadList;
        String sReq = JSON.serialize(leadRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/askRetailQuestionLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTAskQuestionController.createLeadAndTask();
        Test.stopTest();
        
    }
    
    static testMethod void RESTAskQuestionController() {
        Contact con = new Contact();
        con.LastName = 'sfdc';
        con.email = 'sfdc@salesforce.com';
        insert con;

        
        List<RESTAskQuestionHelper.Leads> leadList = new List<RESTAskQuestionHelper.Leads>();
        RESTAskQuestionHelper.Leads requestLead = new RESTAskQuestionHelper.Leads();
        requestLead.Email = 'sfdc@salesforce.com';
        requestLead.firstName = 'sfdc';
        requestLead.lastName = 'sfdc';
        requestLead.phone ='3434233456';
        requestLead.rsAccountId ='123458';
        requestLead.rsContactId = '12345';
        requestLead.timeframeForInvesting ='Less than 30 days';
        requestLead.totalCapitalAvailable = 'Less than 20k';
        requestLead.financing = 'Not Pre-qualified';
        requestLead.description = 'Re: <123 Main St, Dallas, Tx, 75214>';
        requestLead.buyerBrokerName = 'sfdc';
        requestLead.buyerBrokerBrokerageName = 'sfdc';
        requestLead.buyerBrokerPhone = '9741733159';
        requestLead.buyerBrokerEmail = 'sfdc@gmail.com';
        requestLead.propertyAddress = 'AZ';
        requestLead.buyerAccountId = '1234';
        leadList.add(requestLead);
        
        RESTAskQuestionHelper.LeadsWrap leadRequest = new RESTAskQuestionHelper.LeadsWrap();
        leadRequest.leadList = leadList;
        String sReq = JSON.serialize(leadRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/askRetailQuestionLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTAskQuestionController.createLeadAndTask();
        Test.stopTest();
        
    }
    static testMethod void RESTAskQuestionControllerException() {
        Contact con = new Contact();
        con.LastName = 'sfdc';
        con.BPM_Contact_Id__c = '12345';
        insert con;
        
        Lead newLead = new Lead();
        newLead.LastName = 'sfdc';
        newLead.FirstName = 'sfdc';
        newLead.Company = 'sfdc';
        newLead.Email = 'sfdc7687687@salesforce.com';
        newLead.mobilePhone = '3434233456';
        newLead.phone = '3434233456';
        insert newLead;
        
        List<RESTAskQuestionHelper.Leads> leadList = new List<RESTAskQuestionHelper.Leads>();
        RESTAskQuestionHelper.Leads requestLead = new RESTAskQuestionHelper.Leads();
        requestLead.Email = 'sfdc@salesforce.com';
        requestLead.firstName = 'sfdc';
        requestLead.lastName = 'sfdc';
        requestLead.phone ='3434233456';
        requestLead.rsAccountId ='123458';
        requestLead.rsContactId = '12345';
        requestLead.timeframeForInvesting ='1 - 3 months';
        requestLead.totalCapitalAvailable = 'Less than 20k';
        requestLead.financing = 'Not Pre-qualified';
        requestLead.description = 'Re: <123 Main St, Dallas, Tx, 75214>';
        requestLead.buyerBrokerName = 'sfdc';
        requestLead.buyerBrokerBrokerageName = 'sfdc';
        requestLead.buyerBrokerPhone = '9741733159';
        requestLead.buyerBrokerEmail = 'sfdc@gmail.com';
        requestLead.propertyAddress = 'AZ';
        requestLead.buyerAccountId = '1234';
        leadList.add(requestLead);
        
        RESTAskQuestionHelper.LeadsWrap leadRequest = new RESTAskQuestionHelper.LeadsWrap();
        leadRequest.leadList = leadList;
        String sReq = JSON.serialize(leadRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/askRetailQuestionLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTAskQuestionController.createLeadAndTask();
        Test.stopTest();
        
    }

	static testMethod void RESTAskQuestionController10() {
        Contact con = new Contact();
        con.LastName = 'sfdc';
        con.mobilePhone = '3434233456';
        con.Email = 'a@gmil.com';
        insert con;

        
        List<RESTAskQuestionHelper.Leads> leadList = new List<RESTAskQuestionHelper.Leads>();
        RESTAskQuestionHelper.Leads requestLead = new RESTAskQuestionHelper.Leads();
        requestLead.Email = 'sfdc@salesforce.com';
        requestLead.firstName = 'sfdc';
        requestLead.lastName = 'sfdc';
        requestLead.phone ='3434233456';
        requestLead.rsAccountId ='123458';
        requestLead.rsContactId = '12345';
        requestLead.timeframeForInvesting ='Less than 30 days';
        requestLead.totalCapitalAvailable = 'Less than 20k';
        requestLead.financing = 'Not Pre-qualified';
        requestLead.description = 'Re: <123 Main St, Dallas, Tx, 75214>';
        requestLead.buyerBrokerName = 'sfdc';
        requestLead.buyerBrokerBrokerageName = 'sfdc';
        requestLead.buyerBrokerPhone = '9741733159';
        requestLead.buyerBrokerEmail = 'sfdc@gmail.com';
        requestLead.propertyAddress = 'AZ';
        requestLead.buyerAccountId = '1234';
        leadList.add(requestLead);
        
        RESTAskQuestionHelper.LeadsWrap leadRequest = new RESTAskQuestionHelper.LeadsWrap();
        leadRequest.leadList = leadList;
        String sReq = JSON.serialize(leadRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/askRetailQuestionLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTAskQuestionController.createLeadAndTask();
        Test.stopTest();
        
    }
    
}
@isTest
public class RESTMCLeadControllerTest {
static {
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void RESTMCLeadTest() {
        List<RESTMCLeadHelper.Leads> leadList = new List<RESTMCLeadHelper.Leads>();
        RESTMCLeadHelper.Leads contextLead = new RESTMCLeadHelper.Leads();
        contextLead.CompanyName = 'Salesforce';
        contextLead.Email = 'a@gmail.com';
        contextLead.firstName = 'Salesforce';
        contextLead.lastName = 'Com';
        contextLead.phone = '9878766567';
        contextLead.rsAccountId = '1132';
        contextLead.rsUserId = '1232';
        contextLead.leadSource = 'Advertisement';
        contextLead.leadInterest = 'Investing with IRA';

        leadList.add(contextLead);
        
        RESTMCLeadHelper.LeadsWrap leadRequest = new RESTMCLeadHelper.LeadsWrap();
        leadRequest.leadList = leadList;
        String sReq = JSON.serialize(leadRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/createLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTMCLeadController.createLead();
        Test.stopTest();
    }
    static testMethod void RESTMCLeadTestException() {
        try{
        List<RESTMCLeadHelper.Leads> leadList = new List<RESTMCLeadHelper.Leads>();
        RESTMCLeadHelper.Leads contextLead = new RESTMCLeadHelper.Leads();
        contextLead.CompanyName = 'Salesforce';
        contextLead.Email = 'a@gmail.com';
        contextLead.firstName = 'Salesforce';
        contextLead.lastName = 'Com';
        contextLead.phone = '9878766567';
        contextLead.rsAccountId = '1132';
        contextLead.rsUserId = '1232';
        contextLead.leadSource = '1031 Landing page';
        contextLead.leadInterest = 'Roofstock One';
        
        leadList.add(contextLead);
        
        RESTMCLeadHelper.LeadsWrap leadRequest = new RESTMCLeadHelper.LeadsWrap();
        leadRequest.leadList = leadList;
        String sReq = JSON.serialize(leadList);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/createLead';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTMCLeadController.createLead();
        Test.stopTest();
        }
        catch(Exception ex){
            
        }
    }
}
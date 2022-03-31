@isTest
public class RESTMCLeadQuestionnaireControllerTest {
    static {
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void RESTMCLeadTest() {
        Lead l = new Lead(); 
        l.Company ='Salesforce';
        l.LastName ='SAP';
        l.Email = 'a@gmail.com';
        insert l;
        
        List<RESTMCLeadQuestionnaireHelper.Questionnaire> leadList = new List<RESTMCLeadQuestionnaireHelper.Questionnaire>();
        RESTMCLeadQuestionnaireHelper.Questionnaire contextLead = new RESTMCLeadQuestionnaireHelper.Questionnaire();
        contextLead.Email = 'a@gmail.com';
        contextLead.investingExperience = 'I have purchased investment property before';
        contextLead.isAccreditedInvestor = true; 
        contextLead.investmentGoal = 'Goal';
        contextLead.targetInvestmentDeployment = '100,000+';
        contextLead.timeframe = '3 - 6 months';
        contextLead.numberOfPropertiesOwned=1;
        contextLead.okayWithAPoorNeighborhoodScore=true;
        contextLead.okayWithANonInspectedProperty = true;
        contextLead.okayWithMinorRepairWork = true;
        contextLead.okayWithMajorRepairWork = true;
        
        contextLead.preferredRegion = 'USA';
        contextLead.riskTolerance = 'Lower risk and lower return potential';
        contextLead.investmentObjective = 'Income - higher relative cash flow';
        
        
        leadList.add(contextLead);
        
        RESTMCLeadQuestionnaireHelper.LeadsWrap leadRequest = new RESTMCLeadQuestionnaireHelper.LeadsWrap();
        leadRequest.QuestionnaireList = leadList;
        String sReq = JSON.serialize(leadRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/updateLeadQuestionnaire';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
         
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTMCLeadQuestionnaireController.updateLeadQuestionnaire();
        Test.stopTest();
    }
    
    static testMethod void RESTMCLeadTestException() {
        
        Lead l = new Lead();
        l.Company ='Salesforce';
        l.LastName ='SAP';
        l.Email = 'a@gmail.com';
        insert l;
        try{
        List<RESTMCLeadQuestionnaireHelper.Questionnaire> leadList = new List<RESTMCLeadQuestionnaireHelper.Questionnaire>();
        RESTMCLeadQuestionnaireHelper.Questionnaire contextLead = new RESTMCLeadQuestionnaireHelper.Questionnaire();
        contextLead.Email = 'a@gmail.com';
        contextLead.investingExperience = 'I have purchased investment property before';
        contextLead.isAccreditedInvestor = true; 
        contextLead.investmentGoal = 'Goal';
        contextLead.targetInvestmentDeployment = '100,000+';
        contextLead.timeframe = '3 - 6 months';
        contextLead.numberOfPropertiesOwned=1;
        contextLead.okayWithAPoorNeighborhoodScore=true;
        contextLead.okayWithANonInspectedProperty = true;
        contextLead.okayWithMinorRepairWork = true;
        contextLead.okayWithMajorRepairWork = true;
        
        
        leadList.add(contextLead);
        
        RESTMCLeadQuestionnaireHelper.LeadsWrap leadRequest = new RESTMCLeadQuestionnaireHelper.LeadsWrap();
        leadRequest.QuestionnaireList = leadList;
        String sReq = JSON.serialize(leadList);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/updateLeadQuestionnaire';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTMCLeadQuestionnaireController.updateLeadQuestionnaire();
        Test.stopTest();
        }
        catch(Exception ex){
            
        }
    }
}
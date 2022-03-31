@RestResource(urlMapping='/updateLeadQuestionnaire/*')
global class RESTMCLeadQuestionnaireController {
    @HttpPost
    global static void updateLeadQuestionnaire() {
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try{
            
            System.debug('=req='+req.requestBody.toString());
            
            RESTMCLeadQuestionnaireHelper.LeadsWrap leadsData = (RESTMCLeadQuestionnaireHelper.LeadsWrap) System.JSON.deserialize(req.requestBody.toString(),RESTMCLeadQuestionnaireHelper.LeadsWrap.class); // RESTPropertyUnitHelper.parse(String.ValueOf(req.requestBody)); // (List<RESTPropertyUnitHelper.PropertyWrapper> )System.JSON.deserialize(String.ValueOf(req.requestBody),List<RESTPropertyUnitHelper.PropertyWrapper>.class);
            RESTMCLeadQuestionnaireHelper.PostResponse createResponse = RESTMCLeadQuestionnaireHelper.updateQuestionnaire(leadsData.QuestionnaireList);
            
            res.responseBody = Blob.valueOf(
                JSON.serialize(createResponse.responseBody)
            );
            res.statusCode = 200;
            DebugLogHandler.logInboundResponse('RESTMCLeadQuestionnaireController','updateLeadQuestionnaire',req.requestBody.toString(),res.responseBody.toString());
        }catch(Exception exe){
            res.responseBody = Blob.valueOf(
                JSON.serialize(exe.getMessage())
            );
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RESTMCLeadQuestionnaireController','updateLeadQuestionnaire',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        }
        
        
        return;
    }
    
}
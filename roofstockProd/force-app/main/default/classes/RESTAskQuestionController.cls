@RestResource(urlMapping='/askRetailQuestionLead/*')
global class RESTAskQuestionController {
    @HttpPost
    global static void createLeadAndTask() {
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try{
            
            System.debug('=req='+req.requestBody.toString());
            
            RESTAskQuestionHelper.LeadsWrap leadsData = (RESTAskQuestionHelper.LeadsWrap) System.JSON.deserialize(req.requestBody.toString(),RESTAskQuestionHelper.LeadsWrap.class); // RESTPropertyUnitHelper.parse(String.ValueOf(req.requestBody)); // (List<RESTPropertyUnitHelper.PropertyWrapper> )System.JSON.deserialize(String.ValueOf(req.requestBody),List<RESTPropertyUnitHelper.PropertyWrapper>.class);
            RESTAskQuestionHelper.PostResponse createResponse = RESTAskQuestionHelper.createLeadAndTask(leadsData.leadList);
            
            res.responseBody = Blob.valueOf(
                JSON.serialize(createResponse.responseBody)
            );
            res.statusCode = 200;
            DebugLogHandler.logInboundResponse('RESTAskQuestionController','createLeadAndTask',req.requestBody.toString(),res.responseBody.toString());
        }catch(Exception exe){
            res.responseBody = Blob.valueOf(
                JSON.serialize(exe.getMessage())
            );
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RESTAskQuestionController','createLeadAndTask',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        }
        
        
        return;
    }
    
}
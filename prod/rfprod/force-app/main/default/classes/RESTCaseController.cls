@RestResource(urlMapping='/createCase/*')
global class RESTCaseController {
 @HttpPost
    global static void createCase( ) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        savepoint sp = Database.setSavepoint() ; 
        try{
        RESTCaseHelper.caseWrap reqData =  (RESTCaseHelper.caseWrap) System.JSON.deserialize(req.requestBody.toString().replace('"case":', '"case_x":'),RESTCaseHelper.caseWrap.class );
        
        RESTCaseHelper.PostResponse createResponse = RESTCaseHelper.createCase(reqData.case_x
            );
 
        res.responseBody = Blob.valueOf(
            JSON.serialize(createResponse.responseBody)
        );
        res.statusCode = 200;
        DebugLogHandler.logInboundResponse('RESTCaseController','createCase',req.requestBody.toString(),res.responseBody.toString()); 
        }catch(Exception exe){
            Database.rollback(sp); 
            res.responseBody = Blob.valueOf(
                JSON.serialize(exe.getMessage())
            );
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RESTCaseController','createCase',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        
        }
        
    }
}
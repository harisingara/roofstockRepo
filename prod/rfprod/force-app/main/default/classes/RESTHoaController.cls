@RestResource(urlMapping='/UpsertHOA/*')
global with sharing class RESTHoaController {
    @HttpPost
    global static void upsertHoa() {
        
        RestRequest req = RestContext.request;        
        RestResponse res = RestContext.response;
        savepoint sp = Database.setSavepoint() ; 
        try {
            RESTHOAHelper.HOAWrap hoaData = (RESTHOAHelper.HOAWrap) System.JSON.deserialize(req.requestBody.toString(), RESTHOAHelper.HOAWrap.class);            
            RESTHOAHelper.PostResponse createResponse = RESTHOAHelper.upsertHOA(hoaData.hoaList);
        
            res.responseBody = Blob.valueOf(JSON.serialize(createResponse.responseBody));
            res.statusCode = 200;
            DebugLogHandler.logInboundResponse('RESTHoaController','upsertHOA',req.requestBody.toString(),res.responseBody.toString());
        } catch(Exception exe){
            Database.rollback(sp); 
            res.responseBody = Blob.valueOf(JSON.serialize(exe.getMessage()));
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RESTHoaController','upsertHOA',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        }
        return;
    }
}
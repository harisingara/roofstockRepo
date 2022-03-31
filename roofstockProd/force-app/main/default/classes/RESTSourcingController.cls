@RestResource(urlMapping='/updateSourcing/*')
global class RESTSourcingController {
    @HttpPost
    global static void updateSourcing() {
        
        savepoint sp = Database.setSavepoint() ; 
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try{
            
            System.debug('=req='+req.requestBody.toString());
            
            RESTSourcingHelper.SourcingWrap sourcingData = (RESTSourcingHelper.SourcingWrap) System.JSON.deserialize(req.requestBody.toString(),RESTSourcingHelper.SourcingWrap.class); // RESTPropertyUnitHelper.parse(String.ValueOf(req.requestBody)); // (List<RESTPropertyUnitHelper.PropertyWrapper> )System.JSON.deserialize(String.ValueOf(req.requestBody),List<RESTPropertyUnitHelper.PropertyWrapper>.class);
            RESTSourcingHelper.PostResponse createResponse = RESTSourcingHelper.updateSourcing(sourcingData.sourcingList);
            
            res.responseBody = Blob.valueOf(
                JSON.serialize(createResponse.responseBody)
            );
            res.statusCode = 200;
            DebugLogHandler.logInboundResponse('RESTSourcingController','updateSourcing',req.requestBody.toString(),res.responseBody.toString());
        }catch(Exception exe){
            Database.rollback(sp); 
            res.responseBody = Blob.valueOf(
                JSON.serialize(exe.getMessage())
            );
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RESTSourcingController','updateSourcing',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        }
        
        
        return;
        
    }
}
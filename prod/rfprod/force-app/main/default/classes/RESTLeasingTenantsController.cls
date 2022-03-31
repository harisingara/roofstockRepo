@RestResource(urlMapping='/UpdateLease/*')
global class RESTLeasingTenantsController {
    @HttpPost
    global static void updateLease() {
        
        RestRequest req = RestContext.request;        
        RestResponse res = RestContext.response;
        savepoint sp = Database.setSavepoint() ; 
        try{
        RESTLeasingTenantsHelper.LeaseListWrap leasingData = (RESTLeasingTenantsHelper.LeaseListWrap) System.JSON.deserialize(req.requestBody.toString(),RESTLeasingTenantsHelper.LeaseListWrap.class); // RESTPropertyUnitHelper.parse(String.ValueOf(req.requestBody)); // (List<RESTPropertyUnitHelper.PropertyWrapper> )System.JSON.deserialize(String.ValueOf(req.requestBody),List<RESTPropertyUnitHelper.PropertyWrapper>.class);            
        RESTLeasingTenantsHelper.PostResponse createResponse = RESTLeasingTenantsHelper.UpdateLease(leasingData.leaseList);
        
        res.responseBody = Blob.valueOf(
            JSON.serialize(createResponse.responseBody)
        );
        res.statusCode = 200;
        DebugLogHandler.logInboundResponse('RESTLeasingTenantsController','UpdateLease',req.requestBody.toString(),res.responseBody.toString());
            
        }catch(Exception exe){
            Database.rollback(sp); 
            res.responseBody = Blob.valueOf(
                JSON.serialize(exe.getMessage())
            );
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RESTLeasingTenantsController','UpdateLease',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        }
        return;
    }
    
    
}
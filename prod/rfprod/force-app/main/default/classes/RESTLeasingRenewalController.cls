@RestResource(urlMapping='/UpdateLeaseRenewal/*')
global class RESTLeasingRenewalController {
    @HttpPost
    global static void updateLease() {
        
        RestRequest req = RestContext.request;        
        RestResponse res = RestContext.response;
        savepoint sp = Database.setSavepoint() ; 
        try{
        	RESTLeasingRenewalHelper.LeaseListWrap leasingData = (RESTLeasingRenewalHelper.LeaseListWrap) System.JSON.deserialize(req.requestBody.toString(),RESTLeasingRenewalHelper.LeaseListWrap.class); // RESTPropertyUnitHelper.parse(String.ValueOf(req.requestBody)); // (List<RESTPropertyUnitHelper.PropertyWrapper> )System.JSON.deserialize(String.ValueOf(req.requestBody),List<RESTPropertyUnitHelper.PropertyWrapper>.class);            
        	System.debug('NDEBUG Request' + leasingData);
            //RESTLeasingRenewalHelper.PostResponse createResponse = RESTLeasingRenewalHelper.processLeaseRequests(leasingData);
            RESTLeasingRenewalHelper.PostResponse createResponse = new RESTLeasingRenewalHelper.PostResponse (RESTLeasingRenewalHelper.processLeaseRenewalProposals(leasingData.LeaseRenewalProposalList));
            
        
        res.responseBody = Blob.valueOf(
            JSON.serialize(createResponse.responseBody)
        );
        res.statusCode = 200;
        DebugLogHandler.logInboundResponse('RESTLeasingRenewalController','UpdateLeaseRenewal',req.requestBody.toString(),res.responseBody.toString());
            
        }catch(Exception exe){
            Database.rollback(sp); 
            res.responseBody = Blob.valueOf(
                JSON.serialize(exe.getMessage())
            );
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RESTLeasingRenewalController','UpdateLeaseRenewal',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        }
        return;
    }
    
    
}
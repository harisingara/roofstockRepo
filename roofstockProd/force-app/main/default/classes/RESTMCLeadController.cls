@RestResource(urlMapping='/createLead/*')
global class RESTMCLeadController {
    @HttpPost
    global static void createLead() {
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try{
            
            System.debug('=req='+req.requestBody.toString());
            
            RESTMCLeadHelper.LeadsWrap leadsData = (RESTMCLeadHelper.LeadsWrap) System.JSON.deserialize(req.requestBody.toString(),RESTMCLeadHelper.LeadsWrap.class); // RESTPropertyUnitHelper.parse(String.ValueOf(req.requestBody)); // (List<RESTPropertyUnitHelper.PropertyWrapper> )System.JSON.deserialize(String.ValueOf(req.requestBody),List<RESTPropertyUnitHelper.PropertyWrapper>.class);
            RESTMCLeadHelper.PostResponse createResponse = RESTMCLeadHelper.createLead(leadsData.leadList);
            
            res.responseBody = Blob.valueOf(
                JSON.serialize(createResponse.responseBody)
            );
            res.statusCode = 200;
            DebugLogHandler.logInboundResponse('RESTMCLeadController','createLead',req.requestBody.toString(),res.responseBody.toString());
        }catch(Exception exe){
            res.responseBody = Blob.valueOf(
                JSON.serialize(exe.getMessage())
            );
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RESTMCLeadController','createLead',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        }
        
        
        return;
    }
    
}
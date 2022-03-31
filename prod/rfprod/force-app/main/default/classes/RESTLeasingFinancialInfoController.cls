@RestResource(urlMapping='/AddLeasingFinancialInfo/*')
global class RESTLeasingFinancialInfoController {
    @HttpPost
    global static void updateFinancialInfo(
    
  ) {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    savepoint sp = Database.setSavepoint() ; 
      try{
        //leasingFinInfoList
        RESTLeasingFinancialInfoHelper.FinancialInformation oReq = (RESTLeasingFinancialInfoHelper.FinancialInformation) System.JSON.deserialize(req.requestBody.toString(),RESTLeasingFinancialInfoHelper.FinancialInformation.class); 
        List<RESTLeasingFinancialInfoHelper.LeasingFinUpdateResponse> response = RESTLeasingFinancialInfoHelper.UpdateFinancialInfo(
         oReq.leasingFinInfoList 
        );
        res.responseBody = Blob.valueOf(JSON.serialize(response));
        res.statusCode = 200;
        DebugLogHandler.logInboundResponse('RESTLeasingFinancialInfoController','updateFinancialInfo',req.requestBody.toString(),res.responseBody.toString()); 
    }catch(Exception exe){
        	Database.rollback(sp); 
            res.responseBody = Blob.valueOf(
                JSON.serialize(exe.getMessage())
            );
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RESTLeasingFinancialInfoController','updateFinancialInfo',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        
        }
      
  }

}
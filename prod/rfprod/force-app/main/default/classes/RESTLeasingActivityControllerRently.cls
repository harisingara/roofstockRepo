@RestResource(urlMapping='/AddLeasingActivityRently/*')
global with sharing class RESTLeasingActivityControllerRently {
  @HttpPost
  global static void addLeasingActivityRecord(
    
  ) {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    savepoint sp = Database.setSavepoint() ; 
      try{
        //leasingActivityList
        RESTLeasingActivityHelperRently.LeasingActivityData oReq = (RESTLeasingActivityHelperRently.LeasingActivityData) System.JSON.deserialize(req.requestBody.toString(),RESTLeasingActivityHelperRently.LeasingActivityData.class); 
        System.debug('NDEBUG Request is :::' + oReq);
          
          List<RESTLeasingActivityHelperRently.LeasingActivityResponse> response = RESTLeasingActivityHelperRently.AddLeasingActivity(
         oReq.leasingActivityList 
        );
    res.responseBody = Blob.valueOf(JSON.serialize(response));
    res.statusCode = 200;
	DebugLogHandler.logInboundResponse('RESTLeasingActivityControllerRently','addLeasingActivityRecord',req.requestBody.toString(),res.responseBody.toString()); 
       
    //res.statusCode = createResponse.statusCode;
    }catch(Exception exe){
        	Database.rollback(sp); 
            res.responseBody = Blob.valueOf(
                JSON.serialize(exe.getMessage())
            );
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RESTLeasingActivityControllerRently','addLeasingActivityRecord',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        
        }
      
  }
}
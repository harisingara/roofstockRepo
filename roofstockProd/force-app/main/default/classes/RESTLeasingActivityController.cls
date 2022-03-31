@RestResource(urlMapping='/AddLeasingActivity/*')
global with sharing class RESTLeasingActivityController {
  @HttpPost
  global static void addLeasingActivityRecord(
    
  ) {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    savepoint sp = Database.setSavepoint() ; 
      try{
        //leasingActivityList
        RESTLeasingActivityHelper.LeasingActivityData oReq = (RESTLeasingActivityHelper.LeasingActivityData) System.JSON.deserialize(req.requestBody.toString(),RESTLeasingActivityHelper.LeasingActivityData.class); 
        List<RESTLeasingActivityHelper.LeasingActivityResponse> response = RESTLeasingActivityHelper.AddLeasingActivity(
         oReq.leasingActivityList 
        );
    res.responseBody = Blob.valueOf(JSON.serialize(response));
    res.statusCode = 200;
	DebugLogHandler.logInboundResponse('RESTLeasingActivityController','addLeasingActivityRecord',req.requestBody.toString(),res.responseBody.toString()); 
       
    //res.statusCode = createResponse.statusCode;
    }catch(Exception exe){
        	Database.rollback(sp); 
            res.responseBody = Blob.valueOf(
                JSON.serialize(exe.getMessage())
            );
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RESTLeasingActivityController','addLeasingActivityRecord',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        
        }
      
  }
}
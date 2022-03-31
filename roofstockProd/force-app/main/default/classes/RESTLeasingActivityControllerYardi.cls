@RestResource(urlMapping='/AddLeasingActivityYardi/*')
global with sharing class RESTLeasingActivityControllerYardi {
	@HttpPost
	global static void addLeasingActivityRecord() {
    	RestRequest req = RestContext.request;
    	RestResponse res = RestContext.response;
    	savepoint sp = Database.setSavepoint() ; 
      	try{
        	//leasingActivityList
            System.debug('NDEBUG Req :::' + req.requestBody.toString());
            RESTLeasingActivityHelper.LeasingActivityData oReq = (RESTLeasingActivityHelper.LeasingActivityData) System.JSON.deserialize(req.requestBody.toString(),RESTLeasingActivityHelper.LeasingActivityData.class); 
            System.debug('NDEBUG After Conv Req :::' + req.requestBody.toString());
            List<RESTLeasingActivityHelper.LeasingActivityResponse> response = RESTLeasingActivityHelperYardi.AddLeasingActivity(oReq.leasingActivityList);
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.statusCode = 200;
            DebugLogHandler.logInboundResponse('RESTLeasingActivityControllerYardi','addLeasingActivityRecord',req.requestBody.toString(),res.responseBody.toString());            
    	//res.statusCode = createResponse.statusCode;
    	}
    	catch(Exception exe) {
        	Database.rollback(sp); 
            res.responseBody = Blob.valueOf(
                JSON.serialize(exe.getMessage())
            );
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RESTLeasingActivityControllerYardi','addLeasingActivityRecord',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        }      
  	}
}
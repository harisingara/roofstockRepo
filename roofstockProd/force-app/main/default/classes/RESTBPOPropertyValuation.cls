/* Class Name - RESTBPOPropertyValuation
 * Author - Kavitha
 * Description - Rest class for BPO Property Valuation.
 * Test Class - BPOPropertyValuationTest
 * ******************************************************************************************
 * 
 * Date			Name			Comments
 * 11-22-2021	Kavitha			Created class with @HttpPOST
 * 
 */
@RestResource(urlMapping='/BPOPropertyValuation/*')
global with sharing class RESTBPOPropertyValuation {
  @HttpPost
  global static void bpoPropertyValuation(
    
  ) {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    savepoint sp = Database.setSavepoint() ; 
      try{
        
        RESTBPOPropertyValuationHelper.BPOValuationRequest oReq = (RESTBPOPropertyValuationHelper.BPOValuationRequest) System.JSON.deserialize(req.requestBody.toString(),RESTBPOPropertyValuationHelper.BPOValuationRequest.class); 
       	System.debug('oReq---'+oReq);
        RESTBPOPropertyValuationHelper.BPOValuationResponse response = RESTBPOPropertyValuationHelper.updateBPOwithValuation(oReq);
      	System.debug('response---'+response);
        res.responseBody = Blob.valueOf(JSON.serialize(response));
        res.statusCode = 200;
        DebugLogHandler.logInboundResponse('RESTBPOPropertyValuation','bpoPropertyValuation',req.requestBody.toString(),res.responseBody.toString()); 
       
    }catch(Exception exe){	Database.rollback(sp); res.responseBody = Blob.valueOf(JSON.serialize(exe.getMessage())); res.statusCode = 500; DebugLogHandler.logRestServiceException('RESTBPOPropertyValuation','bpoPropertyValuation',exe.getMessage(),exe.getStackTraceString(),req.requestBody.toString()); }
      
  }
}
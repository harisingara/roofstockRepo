@RestResource(urlMapping='/UpdateEmailPreference/*')
global with sharing class RESTEmailPreferenceController {
  @HttpPost
  global static void updatePreference(
  ) {
      RestRequest req = RestContext.request;
      RestResponse res = RestContext.response;
      savepoint sp = Database.setSavepoint() ;
      try{
        RESTEmailPreferenceHelper.EmailRequest reqData =  (RESTEmailPreferenceHelper.EmailRequest) System.JSON.deserialize(req.requestBody.toString(),RESTEmailPreferenceHelper.EmailRequest.class );
        
        RESTEmailPreferenceHelper.EMailPreferenceResponse createResponse = RESTEmailPreferenceHelper.UpdatePreference(
          reqData.preference.email, reqData.preference.action
        );
        res.responseBody = Blob.valueOf(
          JSON.serialize(createResponse.message)
        );
        res.statusCode = 200;
        DebugLogHandler.logInboundResponse('RESTEmailPreferenceController','updatePreference',req.requestBody.toString(),res.responseBody.toString()); 
      }catch(Exception exe){
           Database.rollback(sp);
          res.responseBody = Blob.valueOf(
              JSON.serialize(exe.getMessage())
          );
          res.statusCode = 500;
          DebugLogHandler.logRestServiceException('RESTEmailPreferenceController','updatePreference',exe.getMessage(),
                                                  exe.getStackTraceString(),req.requestBody.toString()); 
          
      }
    return;
  }
}
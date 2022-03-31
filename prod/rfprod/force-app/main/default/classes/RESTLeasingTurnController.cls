@RestResource(urlMapping='/UpdateTurn/*')
global with sharing class RESTLeasingTurnController {
  @HttpPost
  global static void updateTurn( ) {
      RestRequest req = RestContext.request;
      RestResponse res = RestContext.response; 	
      savepoint sp = Database.setSavepoint() ; 
      try{
          RESTLeasingTurnHelper.LeasingTurnData oturnsData= (RESTLeasingTurnHelper.LeasingTurnData) System.JSON.deserialize(req.requestBody.toString(),RESTLeasingTurnHelper.LeasingTurnData.class );
          RESTLeasingTurnHelper.PostResponse createResponse = RESTLeasingTurnHelper.UpdateTurn(oturnsData.turnsList);
          res.responseBody = Blob.valueOf(
              JSON.serialize(createResponse.responseBody)
          );
          res.statusCode = 200;   
          DebugLogHandler.logInboundResponse('RESTLeasingTurnController','updateTurn',req.requestBody.toString(),res.responseBody.toString()); 
      }
      catch(exception exe){
          Database.rollback(sp); 
          res.responseBody = Blob.valueOf(
              JSON.serialize(exe.getMessage())
          );
          res.statusCode = 500;
          DebugLogHandler.logRestServiceException('RESTLeasingTurnController','updateTurn',exe.getMessage(),
                                                  exe.getStackTraceString(),req.requestBody.toString()); 
      }
      return;
      
  }
}
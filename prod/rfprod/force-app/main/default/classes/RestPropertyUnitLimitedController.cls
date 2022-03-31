@RestResource(urlMapping='/addPropertyUnitLimited/*')
global with sharing class RestPropertyUnitLimitedController {
  @HttpPost
  global static void addPropertyUnit(
    
  ) {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response; 
    savepoint sp = Database.setSavepoint() ; 
    try{
        system.debug(req.requestBody.toString()); 
        system.debug('request'+ req.requestBody.toString());
        RestPropertyUnitLimitedHelper.PropertyWrap oPropertydata = RestPropertyUnitLimitedHelper.PropertyWrap.parse(req.requestBody.toString()); 
            //(RESTPropertyUnitHelper.PropertyWrap) System.JSON.deserialize(req.requestBody.toString(),RESTPropertyUnitHelper.PropertyWrap.class); // RESTPropertyUnitHelper.parse(String.ValueOf(req.requestBody)); // (List<RESTPropertyUnitHelper.PropertyWrapper> )System.JSON.deserialize(String.ValueOf(req.requestBody),List<RESTPropertyUnitHelper.PropertyWrapper>.class);
    	system.debug('testing'+ oPropertydata);
       RestPropertyUnitLimitedHelper.PostResponse createResponse = RestPropertyUnitLimitedHelper.AddPropertyUnit(
          oPropertydata.propertyList
        ); 
        res.responseBody = Blob.valueOf(
          JSON.serialize(createResponse.responseBody)
        );
        res.statusCode = 200;
        DebugLogHandler.logInboundResponse('RestPropertyUnitLimitedController','addPropertyUnit',req.requestBody.toString(),res.responseBody.toString()); 
    }catch(exception exe){
        Database.rollback(sp); 
        res.responseBody = Blob.valueOf(
          JSON.serialize(exe.getMessage())
        );
        res.statusCode = 500;
        DebugLogHandler.logRestServiceException('RestPropertyUnitLimitedController','addPropertyUnit',exe.getMessage(),
                                                  exe.getStackTraceString(),req.requestBody.toString()); 
    }
    return;
  }
}
@RestResource(urlMapping='/updatePhotoCallback/*')
global class RESTPlanomaticCreateOrderController{
    @HttpPost
    global static void updatePlanomaticOrder() { 
        savepoint sp = Database.setSavepoint() ; 
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try{
            
            System.debug('=req='+req.requestBody.toString());
           
            RESTPlanomaticCreateOrderHelper.PlanomaticWrap planomaticData = (RESTPlanomaticCreateOrderHelper.PlanomaticWrap) System.JSON.deserialize(req.requestBody.toString(),RESTPlanomaticCreateOrderHelper.PlanomaticWrap.class); // RESTPropertyUnitHelper.parse(String.ValueOf(req.requestBody)); // (List<RESTPropertyUnitHelper.PropertyWrapper> )System.JSON.deserialize(String.ValueOf(req.requestBody),List<RESTPropertyUnitHelper.PropertyWrapper>.class);
            RESTPlanomaticCreateOrderHelper.PostResponse createResponse = RESTPlanomaticCreateOrderHelper.updatePlanomaticOrder(planomaticData.photoOrder);
 
            res.responseBody = Blob.valueOf(
                JSON.serialize(createResponse.responseBody)
            );
            res.statusCode = 200;
            DebugLogHandler.logInboundResponse('RESTPlanomaticCreateOrderController','updatePlanomaticOrder',req.requestBody.toString(),res.responseBody.toString());
        }catch(Exception exe){
            Database.rollback(sp); 
            res.responseBody = Blob.valueOf(
                JSON.serialize(exe.getMessage())
            );
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RESTPlanomaticController','updatePlanomatic',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        }
        
        
        return;
    }
}
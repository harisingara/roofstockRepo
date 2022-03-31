@RestResource(urlMapping='/UpsertInspection/*')
global with sharing class RESTInspectionController {
    @HttpPost
    global static void upsertInspection() {
        
        RestRequest req = RestContext.request;        
        RestResponse res = RestContext.response;
        savepoint sp = Database.setSavepoint() ; 
        try {
            RESTInspectionHelper.InspectionData inspectionData = (RESTInspectionHelper.InspectionData) System.JSON.deserialize(req.requestBody.toString(),RESTInspectionHelper.InspectionData.class);            
            RESTInspectionHelper.PostResponse createResponse = RESTInspectionHelper.UpsertInspection(inspectionData.inspectionList);
        
            res.responseBody = Blob.valueOf(JSON.serialize(createResponse.responseBody));
            res.statusCode = 200;
            DebugLogHandler.logInboundResponse('RESTInspectionController','UpsertInspection',req.requestBody.toString(),res.responseBody.toString());
        } catch(Exception exe){
            Database.rollback(sp); 
            res.responseBody = Blob.valueOf(JSON.serialize(exe.getMessage()));
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RESTInspectionController','UpsertInspection',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        }
        return;
    }
}
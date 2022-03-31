@RestResource(urlMapping='/updateCertification/*')
global class RESTCertificationController {
    @HttpPost
    global static void updateCertification() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        savepoint sp = Database.setSavepoint() ;
        try{
            RESTCertificationHelper.certificationsWrap certificationsData = (RESTCertificationHelper.certificationsWrap) System.JSON.deserialize(req.requestBody.toString(),RESTCertificationHelper.certificationsWrap.class); // RESTPropertyUnitHelper.parse(String.ValueOf(req.requestBody)); // (List<RESTPropertyUnitHelper.PropertyWrapper> )System.JSON.deserialize(String.ValueOf(req.requestBody),List<RESTPropertyUnitHelper.PropertyWrapper>.class);
            System.debug('=certificationsData='+certificationsData);
            
            RESTCertificationHelper.PostResponse createResponse = RESTCertificationHelper.UpdateCertification(certificationsData.certificationList);
            System.debug('=createResponse='+createResponse);
            res.responseBody = Blob.valueOf(
                JSON.serialize(createResponse.responseBody)
            );
            res.statusCode = 200;
            DebugLogHandler.logInboundResponse('RESTCertificationController','UpdateCertification',req.requestBody.toString(),res.responseBody.toString());

        }catch(Exception exe){
            Database.rollback(sp);
            res.responseBody = Blob.valueOf(
                JSON.serialize(exe.getMessage())
            );
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RESTCertificationController','UpdateCertification',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        }
        
        return;
    }    
    
}
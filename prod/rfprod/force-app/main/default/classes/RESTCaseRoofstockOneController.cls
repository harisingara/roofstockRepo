@RestResource(urlMapping='/createCaseRoofstockOne/*')
global class RESTCaseRoofstockOneController {
    @HttpPost
    global static void createCaseRSOne() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        savepoint sp = Database.setSavepoint() ; 
        try{
        	RESTCaseRoofstockOneHelper.CaseRSOneWrap caseData = (RESTCaseRoofstockOneHelper.CaseRSOneWrap) System.JSON.deserialize(req.requestBody.toString(),RESTCaseRoofstockOneHelper.CaseRSOneWrap.class); // RESTPropertyUnitHelper.parse(String.ValueOf(req.requestBody)); // (List<RESTPropertyUnitHelper.PropertyWrapper> )System.JSON.deserialize(String.ValueOf(req.requestBody),List<RESTPropertyUnitHelper.PropertyWrapper>.class);
        	RESTCaseRoofstockOneHelper.PostResponse createResponse = RESTCaseRoofstockOneHelper.createCaseRSOne(caseData.caseRSOneList);

 
        res.responseBody = Blob.valueOf(
            JSON.serialize(createResponse.responseBody)
        );
        res.statusCode = 200;
        DebugLogHandler.logInboundResponse('RESTCaseRoofstockOneController','createCaseRSOne',req.requestBody.toString(),res.responseBody.toString()); 
        }catch(Exception exe){
            Database.rollback(sp); 
            res.responseBody = Blob.valueOf(
                JSON.serialize(exe.getMessage())
            );
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RESTCaseController','createCase',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        
        }
        
    }

}
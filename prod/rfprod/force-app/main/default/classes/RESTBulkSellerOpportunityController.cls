@RestResource(urlMapping='/createBulkSellerOpportunities/*')
global class RESTBulkSellerOpportunityController{
    @HttpPost
    global static void createOpportunities() {
        savepoint sp = Database.setSavepoint(); 
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        //try{
            
            System.debug('=req='+req.requestBody.toString());
           
            RESTBulkSellerOpportunityHelper.SellerOpportunitiesWrap sellerOpportunityData = (RESTBulkSellerOpportunityHelper.SellerOpportunitiesWrap) System.JSON.deserialize(req.requestBody.toString(),RESTBulkSellerOpportunityHelper.SellerOpportunitiesWrap.class); // RESTPropertyUnitHelper.parse(String.ValueOf(req.requestBody)); // (List<RESTPropertyUnitHelper.PropertyWrapper> )System.JSON.deserialize(String.ValueOf(req.requestBody),List<RESTPropertyUnitHelper.PropertyWrapper>.class);
            RESTBulkSellerOpportunityHelper.PostResponse createResponse = RESTBulkSellerOpportunityHelper.createOpportunities(sellerOpportunityData.sellerOpportunityList);
 
            res.responseBody = Blob.valueOf(
                JSON.serialize(createResponse.responseBody)
            );
            res.statusCode = 200;
            DebugLogHandler.logInboundResponse('RESTBulkSellerOpportunityController','createOpportunities',req.requestBody.toString(),res.responseBody.toString());
      /*  }catch(Exception exe){
            Database.rollback(sp); 
            res.responseBody = Blob.valueOf(
                JSON.serialize(exe.getMessage())
            );
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RESTBulkSellerOpportunityController','createOpportunities',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        }
        */
        
        return;
    }

}
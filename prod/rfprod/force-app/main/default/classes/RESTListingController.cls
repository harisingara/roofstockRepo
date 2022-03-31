@RestResource(urlMapping='/updateListing/*')
global class RESTListingController {
    @HttpPost
    global static void updateListing( ) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response; 
        savepoint sp = Database.setSavepoint() ; 
        try{
            RESTListingHelper.ListingData oListingdata = (RESTListingHelper.ListingData) System.JSON.deserialize(req.requestBody.toString(),RESTListingHelper.ListingData.class );
        	RESTListingHelper.PostResponse createResponse = RESTListingHelper.UpdateListing(oListingdata.listingList);
            res.responseBody = Blob.valueOf(
                JSON.serialize(createResponse.responseBody)
            );
            res.statusCode = 200;    
            DebugLogHandler.logInboundResponse('RESTListingController','updateListing',req.requestBody.toString(),res.responseBody.toString()); 
         }
         catch(exception exe){
           Database.rollback(sp); 
           res.responseBody = Blob.valueOf(
          		JSON.serialize(exe.getMessage())
           );
        res.statusCode = 500;
        DebugLogHandler.logRestServiceException('RESTListingController','updateListing',exe.getMessage(),
                                                  exe.getStackTraceString(),req.requestBody.toString()); 
      }
      return;
        
    }    
    
}
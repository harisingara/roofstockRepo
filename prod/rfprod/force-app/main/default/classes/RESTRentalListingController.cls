@RestResource(urlMapping='/AddRentalListing/*')
global with sharing class RESTRentalListingController {

 @HttpPost 
  global static void addRentalListing() {

      savepoint sp = Database.setSavepoint() ;     
      RestRequest req = RestContext.request;
      RestResponse res = RestContext.response; 
      try{
          RESTRentalListingHelper.RentalListingData oRentalListingdata = (RESTRentalListingHelper.RentalListingData) System.JSON.deserialize(req.requestBody.toString(),RESTRentalListingHelper.RentalListingData.class );

      	  RESTRentalListingHelper.PostResponse createResponse = RESTRentalListingHelper.AddRentalListing(oRentalListingdata.rentalListingList);
          res.responseBody =  Blob.valueOf(JSON.serialize(createResponse.responseBody));
          res.statusCode = 200;  
          DebugLogHandler.logInboundResponse('RESTRentalListingController','addRentalListing',req.requestBody.toString(),res.responseBody.toString()); 
      }
      catch(exception exe){
          Database.rollback(sp); 
          res.responseBody = Blob.valueOf(
          JSON.serialize(exe.getMessage())
        );
        res.statusCode = 500;
        DebugLogHandler.logRestServiceException('RESTRentalListingController','addRentalListing',exe.getMessage(),
                                                  exe.getStackTraceString(),req.requestBody.toString()); 
      }
      return;
  }    
 
}
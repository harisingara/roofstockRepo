//@RestResource(urlMapping='/AddProperty/*')
@RestResource(urlMapping='/createSingleSellerOpportunity/*')
global  class RESTSellerController {
     
    /*Waitlist: Property Address, Market, Broker Name/ID, Address, city, State, Rent, Listing Price
Property Submitted: Property Address, State, Market, Rent, Occupancy, List Price, Broker Name/ID, Valuation, 
Seller's Name,When are you ready to list?: "<1month, 1-3 month, +6 months
* “https://na8.salesforce.com/services/apexrest/AddProperty”.
*/
    @HttpPost
    global static void addPropertyToContact(){
        String brokerFirstName;
        String brokerLastName; 
        string brokerId;
        Double listingPrice; 
        String email;
        string listingType; 
        string propertyCity;
        string propertyState;
        string propertyStreet;
        string propertyZip;
        boolean currentlyLeased;
        string expectedTimeForTransaction; 
        string phone; 
        decimal propertyMonthlyRent;
        Integer avmHigh;
        Integer avmLow;
        Integer avmRent;
        String leadSource;
        //PE-494
        double offerPrice;
        String retailConvertReason;
        String collectiveDeclineReason;
        
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request; 
        
        RESTSellerHelper.sellerRequest request = (RESTSellerHelper.sellerRequest) System.JSON.deserialize(req.requestBody.toString(),RESTSellerHelper.sellerRequest.class); // RESTPropertyUnitHelper.parse(String.ValueOf(req.requestBody)); // (List<RESTPropertyUnitHelper.PropertyWrapper> )System.JSON.deserialize(String.ValueOf(req.requestBody),List<RESTPropertyUnitHelper.PropertyWrapper>.class);
       
        brokerFirstName = request.brokerFirstName;
        brokerLastName = request.brokerLastName;
        brokerId = request.brokerId;
        listingPrice = request.listingPrice;
        email = request.email;
        listingType = request.listingType;
        propertyCity = request.propertyCity;
        propertyState = request.propertyState;
        propertyStreet = request.propertyStreet;
        propertyZip = request.propertyZip;
        currentlyLeased = request.currentlyLeased;
        expectedTimeForTransaction = request.expectedTimeForTransaction;
        phone = request.phone;
        propertyMonthlyRent = request.propertyMonthlyRent;
        avmHigh = request.avmHigh;
        avmLow = request.avmLow;
        avmRent = request.avmRent;
        leadSource = request.leadSource;
        offerPrice = request.offerPrice;
        retailConvertReason = request.retailConvertReason;
        collectiveDeclineReason = request.collectiveDeclineReason;
        System.debug('=req='+req.requestBody.toString());
        try{
            RESTSellerHelper.PostResponse createResponse =   RESTSellerHelper.AddListing( brokerFirstName, brokerLastName,  brokerId,  listingPrice,  email, listingType,  propertyCity,
                                                                                         propertyState, propertyStreet, propertyZip, currentlyLeased, expectedTimeForTransaction,  phone,  propertyMonthlyRent,avmHigh,avmLow,avmRent, leadSource,offerPrice,retailConvertReason,collectiveDeclineReason);
            
            System.debug('=createResponse='+createResponse.responseBody);
            //if(!Test.isRunningTest()){                                    
                res.responseBody =  Blob.valueOf(JSON.serialize(createResponse.responseBody));
                res.statusCode = createResponse.statusCode;
            //}
            DebugLogHandler.logInboundResponse('RESTSellerController','addPropertyToContact',req.requestBody.toString(),String.valueOf(createResponse.responseBody));
            
        }catch(Exception exe){
            System.debug('=exe='+exe);
            res.responseBody = Blob.valueOf(
                JSON.serialize(exe.getMessage())
            );
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RESTSellerController','addPropertyToContact',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        }
        return;
        
    }
    
    
    
    
}
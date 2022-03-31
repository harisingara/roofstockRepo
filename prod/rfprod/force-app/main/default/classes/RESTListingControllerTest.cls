@isTest
public class RESTListingControllerTest {
    static testMethod void RESTListingControllerTest() {
        Property2__c p = new Property2__c(); 
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
        p.Year_Built__c = '1972';
        p.name = '123 Main St Tracy CA 95391';
        insert p;
        
        Listing__c listing = new Listing__c();
        listing.Property__c = p.Id;
        listing.Listing_Id__c = '1234';
        insert listing;
        
        List<RESTListingHelper.Listings>listingList = new List<RESTListingHelper.Listings>();
        RESTListingHelper.Listings contextListing= new RESTListingHelper.Listings();
        contextListing.listingId = '1234';
        contextListing.propertyId = '72bcf440-899b-4fe4-b79f-9a14366fead';
        contextListing.status = 'Sold';
        contextListing.listPrice = '1234';
        contextListing.listDate = '2013-07-01';
        contextListing.allowableSaleTypes = 'None';
        contextListing.allowedFundingTypes = 'Cash';
        contextListing.salePendingDate = '2013-07-01';
        contextListing.soldDate = '2013-07-01';
        contextListing.salePrice = '1234';
        contextListing.isAllowOffer = 'true';
        contextListing.sellerAvm = '100';
        contextListing.propertyTaxes = '100';
        contextListing.estimatedRent = '100';
        List<String> pIds = new List<String>();
        pIds.add('12345');
        pIds.add('76578');
        contextListing.portfolioIds = pIds;
        listingList.add(contextListing);
        RESTListingHelper.ListingData oReqData = new RESTListingHelper.ListingData(); 
        oReqData.listingList =  listingList;        
        String sReq = JSON.serialize(oReqData);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/updateListing';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTListingController.updateListing();
         req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        RestContext.response = res;
       
        RESTListingController.updateListing();
        Test.stopTest();
        
        
        
        
    }
    
}
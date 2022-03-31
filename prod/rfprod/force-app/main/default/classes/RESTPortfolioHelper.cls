public class RESTPortfolioHelper {

    
    public static PortfolioResponseWrapper AddPortfolio(list<PortfolioRequest> portfolioList){
        PortfolioResponseWrapper response = new PortfolioResponseWrapper();
    	List<Portfolio__c> portfoliostoUpsert = new List<Portfolio__c>();
        Map<String, PortfolioResponse> portRespMap = new Map<String, PortfolioResponse>();
        List<Portfolio_Listing__c> pfListingList = new List<Portfolio_Listing__c>();
        
        
        Map<string, PortfolioRequest> portReqMap = new Map<String, PortfolioRequest>();
        Map<String, Listing__c> listingIdMap = new Map<String, Listing__c>(); 
        Set<String> listingIdSet = new Set<String>(); 
        
		//Create a map of PortfolioId and incoming Request
		//Gather the PropertyIds        
        for(PortfolioRequest req : portfolioList){            
           portfoliostoUpsert.add(new Portfolio__c(Name = req.Name, Portfolio_Id__c = req.portfolioId));
           portReqMap.put(req.portfolioId, req);
           if(req.listingIds != null && req.listingIds.size() > 0){
                for(String pId : req.listingIds){
                	listingIdSet.add(pId);
                }
            
           }
        }
        
        //Use the propertyIds to gather any Properties existing, 
        //if not present no action will be taken for incoming request for Property Ids
        if(listingIdSet.size() > 0){
            for(Listing__c listing : [Select Id, Listing_Id__c from Listing__c where Listing_Id__c IN : listingIdSet]){
                listingIdMap.put(listing.Listing_Id__c, listing);
            }
        }
        
        //delete existing Portfolio and Property association
        if(portReqMap.size() > 0){
            List<Portfolio_Listing__c > pfplst = [Select Id from Portfolio_Listing__c  where Portfolio__r.Portfolio_Id__c IN : portReqMap.keyset()];
            if(pfplst.size() > 0){
           	 delete pfplst;
            }
            
            
        }
        
        if(portfoliostoUpsert.size() > 0){
            upsert portfoliostoUpsert Portfolio_Id__c;
            
            // Iterate through each returned result and use the resulting Ids to create Portfolio Properties.
            for (Portfolio__c pf : portfoliostoUpsert) {
               portRespMap.put(pf.Portfolio_Id__c, (new PortfolioResponse(pf.Id, pf.Portfolio_Id__c, pf.Name)));
                
                PortfolioRequest req = portReqMap.get(pf.Portfolio_Id__c);
                if(req != null && req.listingIds != null && req.listingIds.size() > 0){
                for(String pId : req.listingIds){
                    if(listingIdMap.containsKey(pId)) { 
             	 	 pfListingList.add( new Portfolio_Listing__c(Portfolio__c = pf.Id, Listing__c = listingIdMap.get(pId).Id, 
                                                            Portfolio_Listing_Unique_Id__c = pId +'-'+req.portfolioId)); 
                    }
                }
                }
            } 
            if(pfListingList.size() > 0){
                upsert pfListingList Portfolio_Listing_Unique_Id__c;
            }  
          
         }
        
        response.portfolioList = portRespMap.values();
        	
        return response;
    }
    
    //Request Wrapper
    public class PortfolioRequestWrapper {
        public List<PortfolioRequest> portfolioList;
    }
    
    public class PortfolioRequest{
        public String name;
        public String portfolioId;
        public List<String> listingIds;
        public PortfolioRequest(String name, String portfolioId) {
            this.name = name;
            this.portfolioId = portfolioId;
        }
    }
     
    
    public class PortfolioResponseWrapper {
        public List<PortfolioResponse> portfolioList;
    }
    
    //Response Wrapper
    public class PortfolioResponse {
        public String salesforceId;
        public String portfolioId;
        public String name;
        public PortfolioResponse(String salesforceId, String portfolioId, String name) {
            this.salesforceId = salesforceId;
            this.portfolioId = portfolioId;
            this.name = name;
        }
    }
    
    public static PortfolioRequestWrapper parse(String json) {
        return (PortfolioRequestWrapper) System.JSON.deserialize(json, PortfolioRequestWrapper.class);
    }
}
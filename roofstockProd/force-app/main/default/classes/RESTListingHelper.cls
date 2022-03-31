global class RESTListingHelper {
    global class ListingData{
        global List<Listings> listingList;
    }
    
    global class Listings{
        global String listingId;
        global String propertyId;
        global String status;
        global String listPrice;
        global String listDate;
        global String allowableSaleTypes;
        global String allowedFundingTypes;
        global String salePendingDate;
        global String soldDate;
        global String salePrice;
        global String isAllowOffer;
        global String sellerAvm;
        global String propertyTaxes; 
        global String estimatedRent; 
        global List<String> portfolioIds;
    }
    
    global class ResponseBody{
        global String listingId;
        global String salesforceId;
        global ResponseBody(String listingId, String salesforceId) {
            this.listingId = listingId;
            this.salesforceId = salesforceId;
        }
    }
    
    global class ResponseWrapper {  
        global List<ResponseBody> listingResponse;  
        global ResponseWrapper(){
            listingResponse = new List<ResponseBody>();
        }
        global ResponseWrapper(List<ResponseBody> listingResponse) {
            this.listingResponse = listingResponse;
        }
    }
    global class PostResponse {
        global ResponseWrapper responseBody;
        global PostResponse(List<ResponseBody> listingResponse) {
            this.responseBody = new ResponseWrapper(listingResponse);
        }
    }
    global static PostResponse UpdateListing(List<Listings> listingList) {
        List<ResponseBody> listingResponseList = new List<ResponseBody>();
        Set<String> listingIdSet = new Set<String>();  
        Set<String> propertyIdSet = new Set<String>();
        Map<String,String> propertyIdMap = new Map<String,String>();
        Map<String,String> propertyIdNameMap = new Map<String,String>();
        Map<String,Listing__c> listingMap = new Map<String,Listing__c>();
        List<Listing__c> updateListingList = new List<Listing__c>();
        List<Listing__c> createListingList = new List<Listing__c>();
        
        Set<String> portfolioIdSet = new Set<String>();
        Set<String> existportfolioIdSet = new Set<String>();
        Map<String, List<String>> listingPortReqMap = new Map<String, List<String>>();
        Map<String, Portfolio__c> pfMap = new Map<String, Portfolio__c>();
        List<Portfolio__c> portfoliosToCreate = new List<Portfolio__c>();
        List<Portfolio_Listing__c> pflList = new List<Portfolio_Listing__c>();
        Map<String,String> listingIdPropertyIdMap = new Map<String,String>();
        List<Listing__c> lstListingWithProperty = new List<Listing__c>();
        List<Listing__c> lstListingWithoutProperty = new List<Listing__c>();
        //Map<String,String> mapFilteredListingIdPropertyId = new Map<String,String>();
        List<Property2__c> lstNewProperty = new List<Property2__c>();
        Set<String> setFilteredPropertyId = new Set<String>();
        
        for(Listings listing :listingList){
            listingIdPropertyIdMap.put(listing.listingId,listing.propertyId);
            listingIdSet.add(listing.listingId);
            propertyIdSet.add(listing.propertyId);
            if(listing.portfolioIds != null && listing.portfolioIds.size() > 0){
                listingPortReqMap.put(listing.listingId, listing.portfolioIds);
                for(String pfId : listing.portfolioIds ){
                    portfolioIdSet.add(pfId);
                }
            }
        }
        List<Property2__c> matchingpropertyList = [select Id,Name,PropertyId__c from Property2__c where PropertyId__c IN:propertyIdSet];
        List<Listing__c>  matchingListingList = [select Id,Seller_AVM__c,Property_Taxes__c,Estimated_Rent__c,Allow_Offer__c,Allowable_Sale_Types__c,Allowed_Funding_Types__c,List_Date__c,
                                                 List_Price__c,Listing_Id__c,Name,Property__c,Sale_Pending_Date__c,Sale_Price__c,Sold_Date__c,
                                                 Status__c from Listing__c where Listing_Id__c IN:listingIdSet];
        
        //Map of Property Id and Property & Property Id and Property Name
        if(!matchingpropertyList.isEmpty()){
            for(Property2__c prop :matchingpropertyList){
                propertyIdMap.put(prop.PropertyId__c,prop.Id); 
                propertyIdNameMap.put(prop.PropertyId__c,prop.Name);
            }
        }
        //Map ListingId and Listing
        if(!matchingpropertyList.isEmpty()){
            for(Listing__c listing :matchingListingList){
                listingMap.put(listing.Listing_Id__c,listing);      
            }
        }
        
        // Create Portfolios
        if(portfolioIdSet.size() > 0){
            for(Portfolio__c pf : [Select Id, Name, Portfolio_Id__c from Portfolio__c where Portfolio_Id__c IN : portfolioIdSet]){
                existportfolioIdSet.add(pf.Portfolio_Id__c);
            }
            
            portfolioIdSet.removeAll(existportfolioIdSet);
            System.debug('portfolioIdSet::'+portfolioIdSet);
            
            for(String s : portfolioIdSet){
                Portfolio__c pf = new Portfolio__c(Portfolio_Id__c = s, Name = s);
                portfoliosToCreate.add(pf); 
            }
            
            if(portfoliosToCreate.size() > 0){
                System.debug('portfoliosToCreate::'+portfoliosToCreate);
                insert portfoliosToCreate;
            }
            portfolioIdSet.addAll(existportfolioIdSet);
            for(Portfolio__c pf : [Select Id, Name, Portfolio_Id__c from Portfolio__c where Portfolio_Id__c IN : portfolioIdSet]){
                pfMap.put(pf.Portfolio_Id__c, pf);
            }
            
        }
        
        //Update Existing transaction/Create a new Transaction
        if(!listingList.isEmpty()){
            for(listings listing :listingList){
                if(listingMap.containsKey(listing.listingId)){
                    Listing__c existingListings = listingMap.get(listing.listingId); 
                    Listing__c updateListing = createUpdateListing(existingListings,listing,propertyIdMap,propertyIdNameMap);
                    updateListingList.add(updateListing);
                }
                else{
                    Listing__c newListing = new Listing__c();
                    Listing__c createListing = createUpdateListing(newListing,listing,propertyIdMap,propertyIdNameMap);
                    createListingList.add(createListing);
                }
            }
            if(!updateListingList.isEmpty()) {
                update updateListingList;
            }
            
            System.debug('-createListingList-'+createListingList);
            if(!createListingList.isEmpty()) {
                for(Listing__c newListing:createListingList) {
                    if(!String.isEmpty(newListing.Property__c)) {
                        lstListingWithProperty.add(newListing);
                    }
                    else{
                        
                        lstListingWithoutProperty.add(newListing);
                        setFilteredPropertyId.add(listingIdPropertyIdMap.get(newListing.Listing_Id__c));
                        //mapFilteredListingIdPropertyId.put(newListing.Listing_Id__c,listingIdPropertyIdMap.get(newListing.Listing_Id__c));
                    }
                    
                }
                System.debug('-setFilteredPropertyId-'+setFilteredPropertyId);
                System.debug('-lstListingWithoutProperty-'+lstListingWithoutProperty);
                if(!setFilteredPropertyId.isEmpty()){
                    for(String propertyId : setFilteredPropertyId){
                        Property2__c property = new Property2__c();
                        property.PropertyId__c = propertyId;
                        property.Name = 'Draft - '+property.PropertyId__c;
                        lstNewProperty.add(property);
                    }
                    Map<String,Property2__c> externalIdPropertyId = new Map<String,Property2__c>();
                    if(!lstNewProperty.isEmpty()){
                        insert lstNewProperty;  
                        for(Property2__c property : lstNewProperty){
                            externalIdPropertyId.put(property.PropertyId__c,property);
                        }
                    }
                    if(!lstListingWithoutProperty.isEmpty()){
                        for(Listing__c listing : lstListingWithoutProperty){
                            listing.Property__c = externalIdPropertyId.get(listingIdPropertyIdMap.get(listing.Listing_Id__c)).Id;
                            listing.Name = externalIdPropertyId.get(listingIdPropertyIdMap.get(listing.Listing_Id__c)).Name;
                        }
                        lstListingWithProperty.addAll(lstListingWithoutProperty);
					                        
                    }
                }

                //insert createListingList; 
            }
            System.debug('-lstListingWithProperty-'+lstListingWithProperty);
            if(!lstListingWithProperty.isEmpty()){
                insert lstListingWithProperty;
            }
        }
        Set<Listing__c> finalSet = new Set<Listing__c>();
        updateListingList.addAll(lstListingWithProperty);
        finalSet.addAll(updateListingList);
        updateListingList.clear();
        updateListingList.addAll(finalSet);
        for(Listing__c listing:updateListingList){
            listingResponseList.add(new ResponseBody(listing.Listing_Id__c, listing.id));   
            
            if(listingPortReqMap.get(listing.Listing_Id__c) <> null && listingPortReqMap.get(listing.Listing_Id__c).size() > 0){
                for(String pfId : listingPortReqMap.get(listing.Listing_Id__c)){
                    if(pfMap.get(pfId) != null){
                        pflList.add(new Portfolio_Listing__c(Listing__c  = listing.Id, Portfolio__c = pfMap.get(pfId).Id,
                                                             Portfolio_Listing_Unique_Id__c = listing.Listing_Id__c + '-'+pfId));
                    }
                }
            }
            
        }
        
        if(pflList.size() > 0){
            upsert pflList Portfolio_Listing_Unique_Id__c;
        }
        
        postResponse res = new postResponse(listingResponseList);
        return res;
    }
    global static Listing__c createUpdateListing(Listing__c ContextListing,listings RequestString,Map<String,String> propertyIdMap,Map<String,String> propertyIdNameMap){
        if(RequestString.propertyId!=null){
            if(propertyIdMap.containsKey(RequestString.propertyId)){
            	ContextListing.Property__c = propertyIdMap.get(RequestString.propertyId);
            	ContextListing.Name = propertyIdNameMap.get(RequestString.propertyId);
            }
        }
        if(RequestString.listingId!=null){
            ContextListing.Listing_Id__c = RequestString.listingId;   
        }
        
        if(RequestString.status!=null){
            ContextListing.Status__c = RequestString.status;            
        }
        if(RequestString.listPrice!=null){
            ContextListing.List_Price__c = Decimal.valueOf(RequestString.listPrice);            
        }
        if(RequestString.listDate!=null){
            ContextListing.List_Date__c = Date.valueOf(RequestString.listDate);         
        }
        if(RequestString.allowableSaleTypes!=null){
            ContextListing.Allowable_Sale_Types__c = RequestString.allowableSaleTypes;          
        }
        if(RequestString.allowedFundingTypes!=null){
            ContextListing.Allowed_Funding_Types__c = RequestString.allowedFundingTypes;
        }
        if(RequestString.salePendingDate!=null){
            ContextListing.Sale_Pending_Date__c = Date.valueOf(RequestString.salePendingDate);
        }
        if(RequestString.soldDate!=null){
            ContextListing.Sold_Date__c = Date.valueOf(RequestString.soldDate);
        }
        if(RequestString.salePrice!=null){
            ContextListing.Sale_Price__c = Decimal.valueOf(RequestString.salePrice);
        }
        if(RequestString.isAllowOffer!=null){
            if((RequestString.isAllowOffer).toLowerCase() == 'true'){
                ContextListing.Allow_Offer__c = true;    
            }
            else{
                ContextListing.Allow_Offer__c = false;
            }
        }
        if(RequestString.sellerAvm!=null){
            ContextListing.Seller_AVM__c = Decimal.valueOf(RequestString.sellerAvm);        
        }
        if(RequestString.propertyTaxes!=null){
            ContextListing.Property_Taxes__c = Decimal.valueOf(RequestString.propertyTaxes);        
        }
        if(RequestString.estimatedRent!=null){
            ContextListing.Estimated_Rent__c = Decimal.valueOf(RequestString.estimatedRent);        
        }
        
        return ContextListing;
    }
}
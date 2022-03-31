public  class SalesfunnelHelper {
    
    public static Map<String, String> getMarketsbyZip(Set<String> zipCodes){
       
        Map<String, String> zipmarkets = new Map<String, String>();
        
        if(zipCodes==NULL || zipCodes.size()==0) return NULL;  //empty map!
  
        //convert set to array
        String[] zipCodelist = new String[]{};
        zipCodelist.addAll(zipCodes);
        
        MarketAreas markets =  callAPI(zipCodelist);
        
        if(markets != NULL && markets.marketAreas != NULL) {
            for(integer i=0; i < markets.marketAreas.Size(); i++) {
                zipmarkets.put(markets.marketAreas[i].lookupZip, markets.marketAreas[i].marketName);
                 System.Debug('foo' + markets.marketAreas[i].lookupZip + markets.marketAreas[i].marketName);
            }
        }
        return zipmarkets;
    }
    
    //to be called from future method!
    public static MarketAreas callAPI(String[] zipCodes) {
        
        if(zipCodes.size() == 0 ) return NULL;
        
		System.Debug('callout');
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        
        Http http = new Http();
        
        //read url from config!
		API_Endpoints__c  apiEndpoint = API_Endpoints__c.getValues('Roofstock_api');
        String host = apiEndpoint.Url__c;
        
        System.Debug(host);
        String reqBody='';
        
        
        for(String zip : zipCodes){
            reqBody += '"' + zip + '",';
        }
        
        reqBody = reqBody.substring(0,reqBody.length()-1);  //trim last ,
        
        reqBody = '{"marketAreaParams": {"zip": [' + reqBody + ']}}';
        
        String url = host + '/api/marketAreas'  ;
        System.debug('url' + url + '-->' + reqBody);
        req.setEndpoint(url);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');

        req.setMethod('POST');
        req.setBody(reqBody);
        
        //req.setCompressed(true); // otherwise we hit a limit of 32000

        try {
            res = http.send(req);
            System.Debug('foo returned@!@@' + res.getBody());
            
            MarketAreas markets = MarketAreas.parse(res.getBody());
            
            return markets; 
           

        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
            return null;
        }

    }
    


    
}
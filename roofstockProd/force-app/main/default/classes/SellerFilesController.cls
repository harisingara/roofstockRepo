public class SellerFilesController {
    
    @AuraEnabled
    public static List<wrapFiles> sellerFiles(String recordId){
        List<wrapFiles> fileWrapperList = new List<wrapFiles>();
        
        Opportunity op = [select Id,Seller_BPM_Opportunity_Id__c from Opportunity where Id =:recordId];
        Integer sellerBPMOpportunityId = Integer.valueOf(op.Seller_BPM_Opportunity_Id__c);
        //Integer sellerBPMOpportunityId = 1030;
        //List<String> fileURLList = fileUrls.split(',');
        
        /***** Callout to get files****/
        Roofstock__mdt[] roofstockHostDetails = [SELECT MasterLabel,RoofstockAuthToken_SellerFiles__c,Roofstock_API_URL__c,DeveloperName,User_Name__c,Password__c,CFS_URL__c,MicroService_URL__c FROM Roofstock__mdt where MasterLabel='Roofstock'];               
        String rsAPIURL = roofstockHostDetails[0].Roofstock_API_URL__c;
        String authToken = roofstockHostDetails[0].RoofstockAuthToken_SellerFiles__c;
        Http http = new Http();
        String authenticationToken = authToken;

        HttpRequest reqRoofstock = new HttpRequest();
        reqRoofstock.setMethod('GET');
		 reqRoofstock.setEndpoint(rsAPIURL+'/Resources/bpm/resources-by-entity-type?callerRole=seller&targetentityType=opportunity&targetentityId='+sellerBPMOpportunityId);

        reqRoofstock.setHeader('Authorization', 'Bearer '+authenticationToken);
        
        HTTPResponse resRoofstock = http.send(reqRoofstock);
        System.debug('***Response***** ' + resRoofstock.getBody());
        //System.debug('***Response Size***** ' + resRoofstock.getBody().size());
        List<roofstockResponseWrapper> roofstockResList = (List<roofstockResponseWrapper>) System.JSON.deserialize(resRoofstock.getBody(), List<roofstockResponseWrapper>.class);
        System.debug('=roofstockResList size='+roofstockResList.size());
        for(roofstockResponseWrapper rsRes:roofstockResList){
            System.debug('-uname-'+rsRes.uploadedByUserName);
            System.debug('-frm-'+rsRes.uploadedFrom);
            wrapFiles wrf = new wrapFiles();
            wrf.fileName = rsRes.fileName;
            wrf.fileLink = rsRes.url;
            wrf.lastModified =rsRes.lastModified;
            wrf.documentType =rsRes.documentType;
            fileWrapperList.add(wrf);
        }
        return fileWrapperList;
    }
    
    public class wrapFiles{
        @AuraEnabled public String fileName;
        @AuraEnabled public String fileLink;
        @AuraEnabled public string lastModified;
        @AuraEnabled public String documentType;
    }
    
    public class roofstockResponseWrapper{
        public String resourceType;
		public String documentType;
		public Boolean isFolder;
		public String folderName;
		public String fileName;
		public String url;
		public String lastModified;
		//public Object uploadedByUserName;
		//public Object uploadedFrom;
		public String uploadedByUserName;
		public String uploadedFrom;
		public Integer length;
		public String contentType;
		public String blobReference;
		public String containerName;
    }

}
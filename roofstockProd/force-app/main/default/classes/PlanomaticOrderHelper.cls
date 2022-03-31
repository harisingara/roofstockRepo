public class PlanomaticOrderHelper {
    
    public static void datafeedAPI(List<Planomatic_Order__c> newPlanomaticOrderList,Map<Id,Planomatic_Order__c> planomaticOrderOldMap){
        Set<String> orderIdSet = new Set<String>();
        for(Planomatic_Order__c po : newPlanomaticOrderList){
            if(po.Status__c == 'Notified' && (po.Status__c!=planomaticOrderOldMap.get(po.Id).Status__c)){
                orderIdSet.add(po.Order_Id__c);
            }
        }
        
        if(orderIdSet.size()>0){
            calldatafeedAPI(orderIdSet);
        }
        
    }
    
    @future(callout=true)
    public static void calldatafeedAPI(Set<String> orderIdSet){
        System.debug('-orderIdSet-'+orderIdSet);
        String rawRequest = '';
        Map<String,Planomatic_Order__c> orderPlanomaticMap = new Map<String,Planomatic_Order__c>();
        List<Planomatic_Order__c> updatePlanomaticRecordList = new List<Planomatic_Order__c>();
        try{
            List<Planomatic_Order__c> planomaticOrderList = [select Id,Order_Id__c,Photos__c from Planomatic_Order__c where Order_Id__c IN:orderIdSet];
            System.debug('-planomaticOrderList-'+planomaticOrderList);
            for(Planomatic_Order__c po:planomaticOrderList){
                orderPlanomaticMap.put(po.Order_Id__c,po);
            }
            System.debug('-orderPlanomaticMap-'+orderPlanomaticMap);
            Roofstock__mdt[] roofstockHostDetails = [SELECT MasterLabel, DeveloperName,User_Name__c,Password__c,CFS_URL__c,MicroService_URL__c FROM Roofstock__mdt];               
            // String username = roofstockHostDetails[0].User_Name__c;
            // String password = roofstockHostDetails[0].Password__c;
            // String cfsURL = roofstockHostDetails[0].CFS_URL__c;
            String microServiceURL = roofstockHostDetails[0].MicroService_URL__c;
            for(String orderId : orderIdSet){
                String authenticationToken;
                /*
                map<String, Object> mapJsonDataAuthentication = new map<String, Object>();
                HttpRequest reqAccess = new HttpRequest();
                String authenticationToken;
                
                //Get Authentication Token
                reqAccess.setMethod('POST');
                reqAccess.setEndpoint(cfsURL+'/api/auth/login');
                //reqAccess.setEndpoint('https://dev.roofstock.com/api/auth/login');            
                reqAccess.setBody('grant_type=credential&username='+username+'&password='+password);
                reqAccess.setTimeout(120000);
                Http httpAccess = new Http();
                
                if(!Test.isRunningTest()){
                    HTTPResponse res = httpAccess.send(reqaccess);
                    mapJsonDataAuthentication = (map<String, Object>)JSON.deserializeUntyped(res.getBody());
                    System.debug('=mapJsonDataAuthentication='+mapJsonDataAuthentication);
                    Object authResponse = mapJsonDataAuthentication.get('authResult');
                    map<String,Object> responseElement = (map<String,Object>) authResponse;
                    authenticationToken = (String) responseElement.get('jwtToken');
                    System.debug('=authenticationToken='+authenticationToken);
                }
                */
                Roofstock__mdt rsdata = [SELECT id, RoofstockAuthToken_RS1__c, MicroService_URL__c FROM Roofstock__mdt WHERE developername = 'Roofstock'];
                System.debug('rs authtoken:: '+rsdata.RoofstockAuthToken_RS1__c);
                authenticationToken = rsdata.RoofstockAuthToken_RS1__c;
                
                //Post Request Id
                OrderRequest order = new OrderRequest();
                //order.orderId = Integer.valueOf(orderId);
                //String jsonBody = json.serialize(order);
                Integer planomaticOrderId = Integer.valueOf(orderId);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                //request.setEndpoint('https://dev-kube.roofstock.com/-api/inspection-server/rest/photo/getPhotos');+unitCode 205604
                request.setEndpoint(microServiceURL+'/-api/inspection-server/rest/photo/getPhotos?orderId='+planomaticOrderId);           
                request.setMethod('GET');
            // request.setHeader('Content-Type', 'application/json;charset=UTF-8');            
                request.setHeader('Authorization', 'Bearer '+authenticationToken);
                //request.setBody('{"orderId":"'+planomaticOrderId+'"}');
            // request.setBody('{"orderId":205604}');
                request.setTimeout(120000);
                rawRequest = request.getBody();
                HttpResponse res = http.send(request);
                system.debug('DEBUGGING RESPOSE: ' + res.getStatusCode() + ' > ' + res.getStatus() + '  >  ' + res.getBody());
                
                //Response
                PlanomaticOrderHelper.DataFeed photoResponse =   (PlanomaticOrderHelper.DataFeed) System.JSON.deserialize(res.getBody(), PlanomaticOrderHelper.DataFeed.class);
                System.debug('-photoResponse-'+photoResponse);
                System.debug('-orderPlanomaticMap-'+orderPlanomaticMap);
                System.debug('-response order id-'+photoResponse.orderId);
                
                if(photoResponse.isSuccessStatusCode == true){

                    Planomatic_Order__c currentPlanomaticOrder= orderPlanomaticMap.get(photoResponse.orderId);
                    String htmlBody = '';
                    List<Photos> photosList = photoResponse.photos;
                    System.debug('-photosList-'+photosList);            
                    htmlBody = '<table border="1" style="border-collapse: collapse"><caption></caption><tr><th>No.</th><th>URL</th></tr>';                
                    htmlBody += '<tr><td>' + '1' + '</td><td>' + photoResponse.tourUrl + '</td></tr>';  
                    for(Photos resPhoto : photosList){
                        
                        Integer seqNo = Integer.valueOf(resPhoto.photoSequence)+1;
                        String url = resPhoto.photoUrl;
                        
                        htmlBody += '<tr><td>' + seqNo + '</td><td>' + url + '</td></tr>';
                        
                    }
                    
                    htmlBody += '</table>';
                    currentPlanomaticOrder.Photos__c = htmlBody;
                    if (photoResponse.matterport3dLink != null && photoResponse.matterport3dLink != '') {
                        currentPlanomaticOrder.Matterport_3D_Link__c = photoResponse.matterport3dLink;
                    }
                    updatePlanomaticRecordList.add(currentPlanomaticOrder);
                    DebugLogHandler.logOutBoundResponse('PlanomaticOrder','calldatafeedAPI','',String.valueOf(request),res.getBody());
                } else {
                    DebugLogHandler.logOutBoundException('PlanomaticOrder','calldatafeedAPI','','Failed to get photos',String.valueOf(request),null,res.getBody());
                }
                
            }
            if(!updatePlanomaticRecordList.isEmpty()){
                update updatePlanomaticRecordList;
            }
        } catch(Exception exe){
            DebugLogHandler.logOutBoundException('PlanomaticOrderHelper','calldatafeedAPI',exe.getStackTraceString(),exe.getMessage(),rawRequest,null,null);
        }
    }

    public static void countOfPlanomaticToRL(List<Planomatic_Order__c> newPlanomaticOrderList){
        set<Id> RLids = new set<Id>();
        try{
            for(Planomatic_Order__c po : newPlanomaticOrderList){
                    RLids.add(po.Rental_Listing__c);
            
            }
            List<Rental_Listing__c> totalPOList = [SELECT id, (SELECT id FROM Planomatic_Orders__r WHERE Submitted_Cancel_Onsite__c=false and Status__c = 'completed') 
                                                    FROM Rental_Listing__c 
                                                    WHERE id IN :RLids];
            for(Rental_Listing__c rl : totalPOList){
                rl.No_Of_Open_Completed_Planomatic_Orders__c = rl.Planomatic_Orders__r.size() > 0 ? rl.Planomatic_Orders__r.size() : 0;
                system.debug('size is::'+rl.Planomatic_Orders__r.size());
            }
            update totalPOList;
        } catch(Exception ex){
                DebugLogHandler.logAppException('PlanomaticOrdeHelper','countOfPlanomaticToRL',ex.getMessage(),ex.getStackTraceString(),'Trigger Context');
        }
    }
    public class DataFeed{
        public boolean isSuccessStatusCode;
        public String errorMessage;
        public String orderId;
        public String tourUrl;
        public String updatedOnUtc;
        public List<Photos> Photos;
        public String matterport3dLink;
    }
    public class Photos{
        public String photoSequence;
        public String photoUrl;
        public String caption;
        public String updatedOnUtc;
        public String modifiedOnUtc;
    }
    public class OrderRequest{
        public Integer orderId;
    }
    
}
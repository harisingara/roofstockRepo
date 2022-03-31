public class ReOpenTurn {
    
    @AuraEnabled
    public static boolean findTurns(String currentRecId) {
        System.debug('=currentRecId='+currentRecId);
        String unitCode;
        Turn__c currentTurn = [select Id,Status__c,Property_Unit__c,Property_Unit__r.HomeCode__c,Move_Out_Date__c from Turn__c where Id=:currentRecId];
        String turnStat =  currentTurn.Status__c;
        String propertyUnitId = currentTurn.Property_Unit__c;
        Date moveOutDt = currentTurn.Move_Out_Date__c;
        unitCode = currentTurn.Property_Unit__r.HomeCode__c;
        if(turnStat == 'Completed'){
            List<Turn__c> turnList = [select Id,Status__c,Property_Unit__c from Turn__c where Property_Unit__c=:propertyUnitId AND Move_Out_Date__c>:moveOutDt AND Id!=:currentRecId];
            System.debug('=turnList='+turnList);
            if(turnList.size()>0){
                return false;
            }
            else{
                Boolean syncYardiDetails = yardiCallout(unitCode,currentRecId);
                return syncYardiDetails;
            }
        }
        else if(turnStat == 'In Progress'){
            Boolean syncYardiDetails = yardiCallout(unitCode,currentRecId);
            return syncYardiDetails;
        }
        else{
            return false;
        }
    }
    
    Public static void updateTurnRecord(String currentRecId,String resMoveOutDate,String resYardiReadyDate,String resYardiAvailableDate,String Status,Boolean rentReady){
        List<Turn__c> yardyResponseList = new List<Turn__c>();
        Turn__c currentTurn = [select Id,Move_Out_Date__c,Yardi_Ready_Date__c,Yardi_Available_Date__c,Status__c,Completed__c from Turn__c where Id=:currentRecId];
        currentTurn.Move_Out_Date__c = resMoveOutDate!=null ? Date.valueOf(resMoveOutDate) : null;
        currentTurn.Yardi_Ready_Date__c = resYardiReadyDate!=null ? Date.valueOf(resYardiReadyDate) : null;
        currentTurn.Yardi_Available_Date__c = resYardiAvailableDate!=null ? Date.valueOf(resYardiAvailableDate) : null;
        currentTurn.Status__c = Status;
        currentTurn.Completed__c = rentReady;
        yardyResponseList.add(currentTurn);
        update yardyResponseList;
        System.debug('=yardyResponseList='+yardyResponseList);
    }
    public static boolean yardiCallout(String unitCode,string currentRecId){
        map<String, Object> mapJsonData = new map<String, Object>();
        map<String, Object> yardiJsonData = new map<String, Object>();
        
        Roofstock__mdt[] roofstockHostDetails = [SELECT MasterLabel, DeveloperName,User_Name__c,Password__c,CFS_URL__c,MicroService_URL__c FROM Roofstock__mdt];               
        String username = roofstockHostDetails[0].User_Name__c;
        String password = roofstockHostDetails[0].Password__c;
        String cfsURL = roofstockHostDetails[0].CFS_URL__c;
        String microServiceURL = roofstockHostDetails[0].MicroService_URL__c;
        String authenticationToken;
        // Generating the Access Token
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        //req.setEndpoint('https://dev.roofstock.com/api/auth/login');// this is the OAuth endpoint where this request will be hit
        //req.setBody('grant_type=credential&username='+username+'&password='+password);
        req.setEndpoint(cfsURL+'/api/auth/login');
        req.setBody('grant_type=credential&username='+username+'&password='+password);
        Http http = new Http();
        
        if(!Test.isRunningTest()){
            HTTPResponse res = http.send(req);
            mapJsonData = (map<String, Object>)JSON.deserializeUntyped(res.getBody());
            System.debug('=mapJsonData='+mapJsonData);
            Object authResponse = mapJsonData.get('authResult');
            map<String,Object> responseElement = (map<String,Object>) authResponse;
            authenticationToken = (String) responseElement.get('jwtToken');
            System.debug('=authenticationToken='+authenticationToken);
        }
        
        
        //API Call
        HttpRequest reqYardi = new HttpRequest();
        reqYardi.setMethod('GET');
        //reqYardi.setEndpoint('https://dev-kube.roofstock.com/-api/yardi-proxy-server/rest/unit-detail?unitCode='+unitCode);
        reqYardi.setEndpoint(microServiceURL+'/-api/yardi-proxy-server/rest/unit-detail?unitCode='+unitCode);
        reqYardi.setHeader('Authorization', 'Bearer '+authenticationToken);
        
        Http httpYardi = new Http();
        HTTPResponse resYardi = http.send(reqYardi);
        System.debug('***Response***** ' + resYardi.getBody());
        
        String resMoveOutDate;
        String resYardiReadyDate;
        String resYardiAvailableDate;  
        Boolean rentReady;
        String Status;
        String Completed; 
        ReOpenTurn.yardiDetails yardyResponse =   (ReOpenTurn.yardiDetails) System.JSON.deserialize(resYardi.getBody(), ReOpenTurn.yardiDetails.class);
        System.debug('==yardyResponse=='+yardyResponse);
        if(yardyResponse.Tenant!=null){
        	resMoveOutDate = yardyResponse.Tenant.moveOut;
        }
        if(yardyResponse.Occupancy!=null){
        	resYardiReadyDate = yardyResponse.Occupancy.readyDate;
            rentReady =  yardyResponse.Occupancy.rentReady; 
        }
        resYardiAvailableDate = yardyResponse.availableDate;
        
        
        
        if(rentReady){
            Status = 'Completed'; 
            
        }
        else{
            Status = 'In Progress'; 
            
        }
        updateTurnRecord(currentRecId,resMoveOutDate,resYardiReadyDate,resYardiAvailableDate,Status,rentReady);
        return true;
    }
    public class yardiDetails {
        @AuraEnabled public String address1;
        @AuraEnabled public Integer bathrooms;
        @AuraEnabled public Integer bedrooms;
        @AuraEnabled public String city;
        @AuraEnabled public String country;
        @AuraEnabled public String state;
        @AuraEnabled public String zip;
        @AuraEnabled public Integer rent;
        //@AuraEnabled public decimal rent;
        @AuraEnabled public String unitCode;
        @AuraEnabled public Occupancy occupancy;
        @AuraEnabled public Tenant tenant;
        @AuraEnabled public String vacantDate;
        @AuraEnabled public String terminationDate;
        @AuraEnabled public String availableDate;
        
    }
    public class Tenant {
        
        @AuraEnabled public String moveIn;
        @AuraEnabled public String moveOut;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
       // @AuraEnabled public Integer rent;
        @AuraEnabled public Decimal rent;
        @AuraEnabled public String status;
        @AuraEnabled public String noticeDate;
    }
    
    public class Occupancy {
        @AuraEnabled public String status;
        @AuraEnabled public String readyDate;
        @AuraEnabled public Boolean rentReady;
    } 
    
}
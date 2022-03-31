public class OutboundMessageRequestHelper {
    public static Outbound_Message_Request__c handleMyTaskStatusUpdateReqs(Outbound_Message_Request__c oDebugHandler) {
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        Boolean isSuccess = false; 
        system.debug('::oDebugHandler::'+oDebugHandler);
        req = formHttpRequestFromLog(req,oDebugHandler); 
        if(!Test.isRunningTest()){
            HTTPResponse res = http.send(req);
            system.debug('response is:: '+res);
            if(res.getStatusCode() == 200) {
                isSuccess = true; 
            }
        }
        //Update Debug log records 
        return (updateLogRequest(oDebugHandler,isSuccess)); 
    }
       
    static HttpRequest formHttpRequestFromLog(HttpRequest oReq,Outbound_Message_Request__c oDebugHandler) {
        String authToken='';
        if(oDebugHandler.Generate_New_Auth_Token__c) {
            
            //Generate New Auth Token Functionality
        }
        else {
            authToken = oDebugHandler.Auth_Token__c;
        }
        system.debug('Invoking formHttpRequestFromLog'+oDebugHandler);
        oReq.setMethod(oDebugHandler.HTTP_Method__c);
        oReq.setHeader('Content-Type', 'application/json;charset=UTF-8');

        if(oDebugHandler.Named_Credential__c <> null && oDebugHandler.Named_Credential__c <> '') {
            oReq.setEndpoint('callout:'+oDebugHandler.Named_Credential__c); 
        } else {
            oReq.setEndpoint(oDebugHandler.HTTP_Endpoint__c); 
        }

        if(oDebugHandler.NC_UserLabel__c <> null ) {
            oReq.setHeader(oDebugHandler.NC_UserLabel__c, '{!$Credential.Username}');
        }

        if (oDebugHandler.NC_PassLabel__c <> null) {
            // req.setHeader('Api-Key', '{!$Credential.Password}');
            oReq.setHeader(oDebugHandler.NC_PassLabel__c, '{!$Credential.Password}');
        } 

        if(authToken <> null && authToken <> '') {
            oReq.setHeader('Authorization', 'Bearer '+authToken);
        }

        if(oDebugHandler.HTTP_Method__c == 'POST' && oDebugHandler.Request__c <> null) {
            oReq.setBody(oDebugHandler.Request__c);    
        }
        oReq.setTimeout(120000);
        system.debug('Invoking formHttpRequestFromLog end'+oReq);
        return oReq;        
    }

    static Outbound_Message_Request__c updateLogRequest(Outbound_Message_Request__c oDebugHandler, Boolean isSuccess) {
        system.debug('Invoking updateLogRequest'+oDebugHandler);
        system.debug('isSuccess:: '+isSuccess);
        oDebugHandler.Retry_Count__c++; 
        if(isSuccess) {
            oDebugHandler.Status__c = 'Retry - Complete';    
        }
        if(oDebugHandler.Retry_Count__c>2 && !isSuccess) {
            oDebugHandler.Status__c = 'Retry - Failed'; 
            DebugLogHandler.logOutBoundException(oDebugHandler.Class_Name__c,oDebugHandler.Method_Name__c,'',oDebugHandler.Error_Description__c,oDebugHandler.Request__c,null,null);	    
        }
        oDebugHandler.Schedule_Run_Time__c = system.now().addMinutes(Integer.valueOf(oDebugHandler.Retry_Count__c*15)) ; 
        system.debug('Invoking updateLogRequest end'+oDebugHandler);
        return oDebugHandler;
    }

    public static Outbound_Message_Request__c logOutboundRetryRequest(HttpRequest oHttpReq,String sRetryOutboundCallout) {
        Outbound_Message_Request__c oReq = new Outbound_Message_Request__c(); 
        oReq.HTTP_Endpoint__c = oHttpReq.getEndpoint() ;
        oReq.HTTP_Method__c = oHttpReq.getMethod() ;
        if(oHttpReq.getMethod() == 'POST' ) {
            oReq.Request__c = oHttpReq.getBody() ;
        }
        oReq.Outbound_HTTP_Callout__c = sRetryOutboundCallout ; 
        return oReq; 
    }
    
}
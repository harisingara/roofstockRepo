public class ATF_WorkQueueTriggerHelper {
    public static void updateContactsFromTask(List<ATF_Work_Queue__c> updatedTasks ,Map<Id,ATF_Work_Queue__c> oldRecordsMap) {
        List<ATF_Work_Queue__c> lstSendInfo = new List<ATF_Work_Queue__c>(); 
        for(ATF_Work_Queue__c oMyTask: updatedTasks) {
            if(oMyTask.Status__c != oldRecordsMap.get(oMyTask.Id).status__c) {
                /*if(String.isEmpty(oMyTask.Outcome__c) && oMyTask.Status__c =='Completed'){
                	oMyTask.addError('Outcome is Mandatory');
                }*/
                if(oMyTask.Status__c =='Completed'){
                	lstSendInfo.add(oMyTask);
                }
            }
        }
        if(!lstSendInfo.IsEmpty()) {
            sendtaskupdateToRSOne(lstSendInfo); 	    
        }
    }
    
    private static void sendtaskupdateToRSOne(List<ATF_Work_Queue__c> lstSendInfo) {
        Set<String> setWorkQueue = new Set<String>();
        for(ATF_Work_Queue__c awq : lstSendInfo) {
            setWorkQueue.add(awq.Id);
        }
        Map<Id,ATF_Work_Queue__c> objWorkQueueMap = new Map<Id,ATF_Work_Queue__c>([select Id,Owner.Email,Investment_Account__r.Investment_Account_Id__c from ATF_Work_Queue__c where ID IN:setWorkQueue]);
        
        // Send this data to third party system 
        ATF_TaskUpdateWrapper lstTaskWrapper = new ATF_TaskUpdateWrapper(); 
        ATF_TaskUpdateWrapper.Tasks oTaskWrap;
        List<ATF_TaskUpdateWrapper.Tasks> oupdateTasks = new List<ATF_TaskUpdateWrapper.Tasks>(); 
        Map<String,List<ATF_TaskUpdateWrapper.Tasks>> requestMap = new Map<String,List<ATF_TaskUpdateWrapper.Tasks>>();
        for(ATF_Work_Queue__c oMyTask: lstSendInfo) {
            oTaskWrap = new ATF_TaskUpdateWrapper.Tasks(); 
            oTaskWrap.status = oMyTask.Status__c; 
            oTaskWrap.taskOutCome = oMyTask.Outcome__c; 
            oTaskWrap.externalId = oMyTask.RS1_Task_Id__c;
            oTaskWrap.taskType = oMyTask.Task_Type__c;
            oTaskWrap.notes = oMyTask.Notes__c;
            oTaskWrap.reviewedBy = objWorkQueueMap.get(oMyTask.Id).Owner.Email;//'chidanandsfdc@gmail.com'; // Task Owners Email Id.
            oTaskWrap.parentId =objWorkQueueMap.get(oMyTask.Id).Investment_Account__r.Investment_Account_Id__c;//'1234'; // investment account's investment account id.
            oupdateTasks.add(oTaskWrap); 
        }
        requestMap.put('taskList',oupdateTasks);
        // code to 
        System.debug('--'+Json.serialize(requestMap));
        calloutToRSOne(Json.serialize(requestMap)); 
    }
    @future(callout=true)
    private static void calloutToRSOne(String sRequest) {
        Http http = new Http();
        // Naveen: Start of Changes to replace the Auth Code from MDT with JWT from Callout
        map<String, Object> mapJsonData = new map<String, Object>();
        Roofstock__mdt rsSetting = [select Id, MasterLabel, RoofstockAuthToken_RS1__c,DeveloperName,User_Name__c,Password__c,CFS_URL__c,MicroService_URL__c from Roofstock__mdt where MasterLabel='Roofstock'];
        String username = rsSetting.User_Name__c;
        String password = rsSetting.Password__c;
        String cfsURL = rsSetting.CFS_URL__c;
        String microServiceURL = rsSetting.MicroService_URL__c;
        String authToken = rsSetting.RoofstockAuthToken_RS1__c;
        /*
        // Generating the Access Token
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        //req.setEndpoint('https://dev.roofstock.com/api/auth/login');// this is the OAuth endpoint where this request will be hit
        req.setEndpoint(cfsURL+'/api/auth/login');
        req.setBody('grant_type=credential&username='+username+'&password='+password);
        
        
        if(!Test.isRunningTest()){
            HTTPResponse res = http.send(req);
            mapJsonData = (map<String, Object>)JSON.deserializeUntyped(res.getBody());
            System.debug('=mapJsonData='+mapJsonData);
            Object authResponse = mapJsonData.get('authResult');
            map<String,Object> responseElement = (map<String,Object>) authResponse;
            authToken = (String) responseElement.get('jwtToken');
            System.debug('=authToken='+authToken);
        }       
		*/
        System.debug('-authToken'+authToken);
        // Naveen: End of Changes to replace the Auth Code from MDT with JWT from Callout
        
        http = new Http();        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(rsSetting.CFS_URL__c+'/-api/shares-server/rest/salesforceStatusUpdate');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Authorization', 'Bearer '+authToken);
        request.setBody(sRequest);
        HttpResponse res = new HttpResponse();
        try{
            if(!Test.isRunningTest()) {
                res = http.send(request);
            }
            system.debug('DEBUGGING RESPOSE: ' + res.getStatusCode() + ' > ' + res.getStatus() + '  >  ' + res.getBody());
            if(res.getStatusCode() != 200) {
                Outbound_Message_Request__c omr = OutboundMessageRequestHelper.logOutboundRetryRequest(request,'Roofstock One');
                omr.Status__c = 'Retry - Pending';
                omr.Generate_New_Auth_Token__c = false;
                omr.Auth_Token__c = authToken;
                omr.Error_Description__c = res.getStatus();
                omr.Response__c = res.getBody();
                insert omr;
            }
            else if(res.getStatusCode() == 200) {
                //DebugLogHandler.logOutBoundResponse('ATF_WorkQueueTriggerHelper','calloutToRSOne','','request','200');
                System.debug('-authToken1'+authToken);
                System.debug('-authToken2'+rsSetting.RoofstockAuthToken_RS1__c);
                Outbound_Message_Request__c omr = OutboundMessageRequestHelper.logOutboundRetryRequest(request,'Roofstock One');
                omr.Status__c = 'Success';
                omr.Generate_New_Auth_Token__c = false;
                omr.Auth_Token__c = authToken;
                omr.Response__c = res.getBody();
                insert omr;
            }
        }
        catch(Exception exe){
            Outbound_Message_Request__c omr = OutboundMessageRequestHelper.logOutboundRetryRequest(request,'Roofstock One');
            omr.Status__c = 'Retry - Pending';
            omr.Generate_New_Auth_Token__c = false;
            omr.Auth_Token__c = authToken;
            omr.Error_Description__c = exe.getMessage();
            insert omr;
        }
        
    }
}
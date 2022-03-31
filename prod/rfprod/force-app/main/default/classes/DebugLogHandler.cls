public class DebugLogHandler {
	//Save exception log when inbound request is executed
    public static void logInboundResponse(String sClassName, String sMethodName,
                                            String sRequest, String sResponse ){
        DebugLog__c log = new DebugLog__c();  
        log.Class_Name__c = sClassName;
        log.Method_Name__c = sMethodName;
        log.Request__c = sRequest;
        log.Response__c = sResponse;
        log.Origin__c = 'Inbound';
        log.Log_Type__c = 'Info';
        insertLogs(new List<DebugLog__c>{log}); 
    }
    //Save exception log when inbound request is executed
    public static void logRestServiceException(String sClassName, String sMethodName,
     String sErrMsg,String sStackTrace, String sRequest ){
        DebugLog__c log = new DebugLog__c(); 
        log.Class_Name__c = sClassName;
        log.Method_Name__c = sMethodName;
        log.Error_Description__c = sErrMsg;
        log.Stack_trace__c = sStackTrace;
        log.Request__c = sRequest;
        log.Origin__c = 'Inbound';
        log.Log_Type__c = 'Error';
        insertLogs(new List<DebugLog__c>{log}); 
    }
    //Save exception log when inbound request is executed
    public static void logAppException(String sClassName, String sMethodName,
     String sErrMsg,String sStackTrace,String Origin){
        DebugLog__c log = new DebugLog__c(); 
        log.Class_Name__c = sClassName;
        log.Method_Name__c = sMethodName;
        log.Error_Description__c = sErrMsg;
        log.Stack_trace__c = sStackTrace;
        log.Origin__c = Origin;
        log.Log_Type__c = 'Error';
        insertLogs(new List<DebugLog__c>{log}); 
    }
    //Save exception log when Outbound call is executed
    public static void logOutBoundResponse(String sClassName, String sMethodName,
                                           String sStackTrace, String sRequest, String sResponse ){
        DebugLog__c log = new DebugLog__c();
        log.Class_Name__c = sClassName;
        log.Method_Name__c = sMethodName;
        log.Stack_trace__c = sStackTrace;
        log.Request__c = sRequest;
        log.Response__c = sResponse;
        log.Origin__c = 'Http Callout';
        log.Log_Type__c = 'Info';                                      
        insertLogs(new List<DebugLog__c>{log}); 
    }
        public static void logOutBoundResponse(String sClassName, String sMethodName,
                                          String sRequest, String sResponse ){
        DebugLog__c log = new DebugLog__c();
        log.Class_Name__c = sClassName;
        log.Method_Name__c = sMethodName;
        log.Request__c = sRequest;
        log.Response__c = sResponse;
        log.Origin__c = 'Platform Event';
        log.Log_Type__c = 'Info';                                      
        insertLogs(new List<DebugLog__c>{log}); 
    }
    public static void platformEventException(String sClassName, String sMethodName,String sStackTrace,
                                          String sRequest, String sResponse ){
        DebugLog__c log = new DebugLog__c();
        log.Class_Name__c = sClassName;
        log.Method_Name__c = sMethodName;
        log.Request__c = sRequest;
        log.Response__c = sResponse;
		log.Stack_trace__c = sStackTrace;                                              
        log.Origin__c = 'Platform Event';
        log.Log_Type__c = 'Error';                                      
        insertLogs(new List<DebugLog__c>{log}); 
    }
     /*New*/
    //Save exception log when Outbound call is executed
    public static void logOutBoundException(String sClassName, String sMethodName,
                                           String sStackTrace, String sErrMsg,String sRequest, String authenticationResponse,String authorizationResponse){
        DebugLog__c log = new DebugLog__c();
        log.Class_Name__c = sClassName;
        log.Method_Name__c = sMethodName;
        log.Stack_trace__c = sStackTrace;
        log.Error_Description__c = sErrMsg;
        log.Origin__c = 'Http Callout';
        log.Log_Type__c = 'Error';
        log.Request__c = sRequest;
        log.Response__c = 'Authentication::'+authenticationResponse+'\nAuthorization::'+authorizationResponse;
        insertLogs(new List<DebugLog__c>{log}); 
    }
    // save errors from saveResult 
      
    //Save result log
    public static void logSaveResult(String sClassName, String sMethodName, 
                                        List<Database.SaveResult> saveResultList){
        List<DebugLog__c> logList = new List<DebugLog__c>();
        for (Database.SaveResult sr: saveResultList) {        
            if (!sr.isSuccess()) {
                DebugLog__c log = new DebugLog__c();
                log.Class_Name__c = sClassName;
                log.Method_Name__c = sMethodName;
                log.Log_Type__c = 'Error';  
                log.Error_Description__c = String.valueOf(sr.getErrors()[0].getMessage());
                logList.add(log);  
            }
        }
        if(!logList.isEmpty()){
            insertLogs(logList); 
        }   
    }
    public static void insertLogs(List<DebugLog__c> lstErrorlogs){
        try{
        if(!System.isBatch() && !System.isFuture()){
            insertLogsinFuture(JSON.serialize(lstErrorlogs));
        }
        else{
            insert lstErrorlogs;
        }
        }catch(Exception exe){
            system.debug('FAILED TO INSERT DEBUG LOGS');
        }
        
    }
    @future
    public static void insertLogsinFuture(String sErrLog){
         List<DebugLog__c> lstErrorlogs = (List<DebugLog__c>)Json.deserialize(sErrLog,List<DebugLog__c>.class);
         insert lstErrorlogs; 
         system.debug('ids'+lstErrorlogs );
    }
}
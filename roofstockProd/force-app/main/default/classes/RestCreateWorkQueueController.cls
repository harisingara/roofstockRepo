@RestResource(urlMapping='/createworkqueue/*')
global class RestCreateWorkQueueController {
    @HttpPost
    global static void createworkqueue() {
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        savepoint sp = Database.setSavepoint() ; 
        try{
            
            System.debug('=req='+req.requestBody.toString()); 
            
            TaskWrapper.TasksWrap tasksData = (TaskWrapper.TasksWrap) System.JSON.deserialize(req.requestBody.toString(),TaskWrapper.TasksWrap.class); // RESTPropertyUnitHelper.parse(String.ValueOf(req.requestBody)); // (List<RESTPropertyUnitHelper.PropertyWrapper> )System.JSON.deserialize(String.ValueOf(req.requestBody),List<RESTPropertyUnitHelper.PropertyWrapper>.class);
            System.debug('=tasksData='+tasksData);
            List<RestCreateWorkQueueHelper.TaskCreateResponse> oResponse = RestCreateWorkQueueHelper.AddMyTasks(tasksData); 
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(
                JSON.serialize(oResponse)
            );
             
            
            DebugLogHandler.logInboundResponse('RestCreateWorkQueueController','createTask',req.requestBody.toString(),res.responseBody.toString());
        }catch(Exception exe){
            res.responseBody = Blob.valueOf(
                JSON.serialize(exe.getMessage())
            );
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RestCreateWorkQueueController','createTask',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        }
        
        
        return;
    }
    
}
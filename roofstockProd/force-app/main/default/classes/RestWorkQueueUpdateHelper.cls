global class RestWorkQueueUpdateHelper {
    
    global class TaskCreateResponse { 
        global string id;
        global string externalId;
        global string taskType;
        global string errorMessage;
        global taskCreateResponse(string updatedId,string externalId, string taskType, String errorMessage){
        	this.id = updatedId; 
            this.externalId = externalId; 
            this.taskType = taskType;
            this.errorMessage = errorMessage;
        } 
    }
    
    global static List<TaskCreateResponse> updateMyTasks(TaskWrapper.TasksWrap tasksData ) {
        
        List<ATF_Work_Queue__c> lstMyTasks = new List<ATF_Work_Queue__c>(); 
        List<TaskCreateResponse> oResponse = new List<TaskCreateResponse>();
        ATF_Work_Queue__c oTemp;
        system.debug('tasksData.taskList??'+tasksData.taskList);
        
        for(TaskWrapper.Tasks oTask: tasksData.taskList){
            if(oTask.externalId == '' || oTask.taskType == ''){
                 oResponse.add(new TaskCreateResponse('', oTask.externalId, oTask.taskType, 'External Id and Task Type cannot be blank'));  
                return oResponse;
            }
            oTemp = new ATF_Work_Queue__c (); 
            oTemp.External_Id__c = oTask.externalId + '-' + oTask.taskType; 
            system.debug('oTask.status::'+oTask.status);
            oTemp.status__c = oTask.status;
            lstMyTasks.add(oTemp);   
        } 
        if(!lstMyTasks.IsEmpty()){
        	//Upsert lstMyTasks External_Id__c;  
        
        Database.UpsertResult[] srList = Database.upsert(lstMyTasks, ATF_Work_Queue__c.External_Id__c, false); 
            
            for(Integer i = 0; i < srList.size(); i++) {
                String extId = lstMyTasks[i].External_Id__c.split('-')[0];
                String taskType = lstMyTasks[i].External_Id__c.split('-')[1];
                if(srList[i].isSuccess()) {
                   oResponse.add(new TaskCreateResponse(srList[i].Id , extId, taskType, '')); 
                }else{
                    
                    for(Database.Error err : srList[i].getErrors()) {
                 	  oResponse.add(new TaskCreateResponse('', extId, taskType, err.getMessage()));  
                    }
                }
            }
        
        }
       /* for(ATF_Work_Queue__c oMyTask: [Select Id, RS1_Task_Id__c , Task_Type__c from ATF_Work_Queue__c where Id IN : lstMyTasks]){
        	oResponse.add(new TaskCreateResponse(oMyTask.Id , oMyTask.RS1_Task_Id__c ,  oMyTask.Task_Type__c) );     
        }*/
        return oResponse;
    }

}
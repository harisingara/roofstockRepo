global class RestCreateWorkQueueHelper {
    
    global class TaskCreateResponse {
        global string id;
        global string externalId; 
        global string taskType;
        global string errorMessage;
        global taskCreateResponse(string id,string externalId, string taskType, String errorMessage){
        	this.id = id; 
            this.externalId = externalId; 
            this.taskType = taskType;
            this.errorMessage = errorMessage;
        }
    }
    
    global static List<TaskCreateResponse> AddMyTasks(TaskWrapper.TasksWrap tasksData ) {
        String objectAPIName = 'ATF_Work_Queue__c' ; //any object api External_Id__c
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<String,Id> mapofTaskRecordTypeNameandId = new Map<String,Id>();
        for(Schema.RecordTypeInfo info : recordTypeInfo){
            mapofTaskRecordTypeNameandId.put(info.getName(),info.getRecordTypeId());
        }
        system.debug('***mapofTaskRecordTypeNameandId*'+mapofTaskRecordTypeNameandId);
        string recTypeId = '' ; 
        List<ATF_Work_Queue__c> lstMyTasks = new List<ATF_Work_Queue__c>(); 
        ATF_Work_Queue__c oTemp; 
        // Collect all external Ids  BPM_Contact_Id__c
        Set<String> setInvestmentAccextIds = new Set<String>(); 
        map<String,Investment_Account__c> mapInvAccIDs = new map<String,Investment_Account__c>(); 
        Set<String> setConExtIds = new Set<String>(); 
        map<String,Id> mapConIDs = new map<String,Id>(); 
        Set<String> setOwnerEmailIds = new Set<String>(); 
        map<String,Id> mapOwnerIDs = new map<String,Id>(); 
        List<TaskCreateResponse> oResponse = new List<TaskCreateResponse>();
        
        for(TaskWrapper.Tasks oTask: tasksData.taskList){
        	setInvestmentAccextIds.add(oTask.parentId);
            if(oTask.rsContactId<>null && oTask.rsContactId != '')
            	setConExtIds.add(oTask.rsContactId);
            setOwnerEmailIds.add(oTask.ownerEmail);
        }
        // get Investment Accounts - 
        List<Investment_Account__c> lstInvAccs = [Select Id,Investment_Account_Id__c,Primary_Contact__c from Investment_Account__c where Investment_Account_Id__c IN:setInvestmentAccextIds ]; 
        if(!lstInvAccs.IsEmpty()){
            for(Investment_Account__c oInvAcc:lstInvAccs){
            	mapInvAccIDs.put(oInvAcc.Investment_Account_Id__c,oInvAcc); 	    
            }    
        }      
        
        List<Contact> lstContacts = [Select Id , BPM_Contact_Id__c from Contact where BPM_Contact_Id__c IN:setConExtIds ];
        if(!lstContacts.IsEmpty()){
            for(Contact oCon:lstContacts){
            	mapConIDs.put(oCon.BPM_Contact_Id__c,oCon.Id); 	    
            }    
        }
        
        // get RS 1 User to default if there is no user. 
        RoofstockOneManageUser__c oRs1User = RoofstockOneManageUser__c.getInstance(UserInfo.getUserId());
        
        List<User> lstOwners = [Select Id,Email from User where Email IN:setOwnerEmailIds OR Email =: oRs1User.RS_One_User_Email__c];
       
        if(!lstOwners.IsEmpty()){
            for(User oUser:lstOwners){
            	mapOwnerIDs.put(oUser.Email, Ouser.Id);  	   
            }
        }
              
        system.debug('tasksData.taskList??'+tasksData.taskList);
        for(TaskWrapper.Tasks oTask: tasksData.taskList){
            if(mapInvAccIDs.get(oTask.parentId) != null){
            if(mapofTaskRecordTypeNameandId.containsKey(oTask.taskType)){
                recTypeId = mapofTaskRecordTypeNameandId.get(oTask.taskType) ;   
            }else{
                recTypeId = mapofTaskRecordTypeNameandId.get('Master'); 
            }
            oTemp = new ATF_Work_Queue__c (); 
            oTemp.External_Id__c = oTask.externalId + '-' +oTask.taskType; 
            oTemp.RS1_Task_Id__c  = oTask.externalId;
            oTemp.Task_Type__c = oTask.taskType;
            oTemp.RecordtypeId = recTypeId;
            oTemp.Description__c = oTask.description;
            oTemp.Investment_Account__c = mapInvAccIDs.get(oTask.parentId).Id;
            if(mapConIDs.containskey(oTask.rsContactId)) 
            	oTemp.Contact__c = mapConIDs.get(oTask.rsContactId);
            else 
				oTemp.Contact__c = mapInvAccIDs.get(oTask.parentId).Primary_Contact__c;                
            if(mapOwnerIDs.containskey(oTask.ownerEmail))
            	oTemp.OwnerId = mapOwnerIDs.get(oTask.ownerEmail);
            else 
                oTemp.OwnerId = mapOwnerIDs.get(oRs1User.RS_One_User_Email__c);
            
            oTemp.Order_ID__c = oTask.orderId; 
            oTemp.Order_date__c = oTask.orderDate;
            oTemp.Investment_Amount__c = oTask.investmentAmount;
            oTemp.Funding_source__c = oTask.fundingSource;
            oTemp.Error_description__c = oTask.errorDescription;
            if(oTask.fundingInitiated != null){
                    oTemp.Funding_Initiated__c = oTask.fundingInitiated;
            }
            oTemp.Cancellation_Date__c = oTask.cancelledDate;
            oTemp.Cancelled_By__c = oTask.cancelledBy;
            
            lstMyTasks.add(oTemp);  
            }else{
                oResponse.add(new TaskCreateResponse('', oTask.externalId, oTask.taskType, 'Investment Account not found for '+oTask.parentId) );
            }
        } 
        if(!lstMyTasks.IsEmpty()){
        	Database.UpsertResult[] srList = Database.upsert(lstMyTasks, ATF_Work_Queue__c.External_Id__c, false); 
            
            for(Integer i = 0; i < srList.size(); i++) {
                if(srList[i].isSuccess()) {
                   oResponse.add(new TaskCreateResponse(srList[i].Id , lstMyTasks[i].RS1_Task_Id__c, lstMyTasks[i].Task_Type__c, '')); 
                }else{
                    for(Database.Error err : srList[i].getErrors()) {
                 	  oResponse.add(new TaskCreateResponse('', lstMyTasks[i].RS1_Task_Id__c, lstMyTasks[i].Task_Type__c, err.getMessage()));  
                    }
                }
            }
        }
       
        /*for(ATF_Work_Queue__c oMyTask:lstMyTasks){
        	oResponse.add(new TaskCreateResponse(oMyTask.Id , oMyTask.RS1_Task_Id__c, oMyTask.Task_Type__c, '') );     
        }*/
        return oResponse;
    }

}
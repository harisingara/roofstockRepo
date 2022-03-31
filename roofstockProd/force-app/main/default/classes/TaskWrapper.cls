global class TaskWrapper {
	global class TasksWrap{
        global List<Tasks> taskList;
    }
    global class Tasks{
        global String externalId;
        global String taskType;
        global String description;
        global String parentId;
        global String rsContactId;
        global String ownerEmail;
        global String status;
        
        global String orderId;
        global date orderDate; 
        global decimal investmentAmount;
        global String fundingSource;
        global String errorDescription;
        
        global Boolean fundingInitiated;
        global date cancelledDate; 
        global String cancelledBy;
        
    }
}
global class ATF_TaskUpdateWrapper {
	global class TasksWrap{
        global List<Tasks> taskList;
    }
    global class Tasks{
        global String status;
        global String taskOutCome;
        global String externalId;
        global String reviewedBy;
        global String parentId;
        global String taskType;
        global String notes;
    }
}
trigger TaskTrigger on Task(before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    try{
        TriggerDispatcher.run(new TaskTriggerHandler(),'Task');
    }
    catch(Exception exe){
        
        DebugLogHandler.logAppException('TaskTrigger','TaskTriggerHandler',exe.getMessage(),
                                        
                                        exe.getStackTraceString(),'Trigger');
        
        throw exe;
        
    }
}

/*trigger TaskTrigger on Task (before insert, before update, after insert, after update,after delete) {
if (Trigger.isAfter ) {
if(!System.isFuture() && checkRecursive.runBeforeOnce(checkRecursive.RecurType.TASK)){
if(Trigger.isInsert) {  
List<Task> tasks = Trigger.New;
TaskHelper.updateParentFromTasks(tasks);  
}//isinsert

//update count of activity on parent
if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete){
List<Task> tasks = new List<Task>();
if(Trigger.isInsert || Trigger.isUpdate) {
tasks.addAll(Trigger.New);
}
if(Trigger.isDelete) {
tasks.addAll(Trigger.Old);
}
TaskHelper.updateParentCountFromTasks(tasks);  
}
} //recursive?
} //before
}*/
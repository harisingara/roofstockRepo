public class TaskController {
    @AuraEnabled
    public static Object getTaskDescription(Id recordId) {
        List<Task> lstTask = [Select Description,Subject from Task where Id=:recordId LIMIT 1]; 
        return  lstTask[0]; 
    }
}
global class ScheduleBatchDeleteDebugLogs implements Schedulable{
    global void execute(SchedulableContext sc)

     {

     BatchDeleteDebugLogs deleteDebugLogs = new BatchDeleteDebugLogs(); // Your batch class

       database.executeBatch(deleteDebugLogs);

     }

}
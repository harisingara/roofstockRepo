global class scheduledErrorLogNotification implements Schedulable {
    global void execute(SchedulableContext SC) {
        new SendErrorLogNotification().sendErrorNotification();   
    }
}
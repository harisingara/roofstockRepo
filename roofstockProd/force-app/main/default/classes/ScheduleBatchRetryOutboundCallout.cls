global class ScheduleBatchRetryOutboundCallout implements Schedulable {
    global void execute(SchedulableContext sc)
    {
        // Implement any logic to be scheduled
        
        // We now call the batch class to be scheduled
        BatchRetryOutboundCallout batchRetryCallout = new BatchRetryOutboundCallout ();
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(batchRetryCallout,1);
    }
}
public class ScheduleBatchCreateRenewalForLease implements Schedulable {
    public void execute(SchedulableContext sc) {
        // We now call the batch class to be scheduled
        BatchCreateRenewalsForLease batchRenewLease = new BatchCreateRenewalsForLease();
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(batchRenewLease, 1);
    }
}
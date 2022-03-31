public class ScheduleBatchSendLeadSurvey implements Schedulable {
	Public void execute(SchedulableContext sc)
    {
        CheckIfLeadConvertedBatchJob batchSendSurvey= new CheckIfLeadConvertedBatchJob();
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(batchSendSurvey,1);
    }
}
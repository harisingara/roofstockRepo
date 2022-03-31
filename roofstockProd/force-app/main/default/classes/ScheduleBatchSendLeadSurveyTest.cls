@isTest
public class ScheduleBatchSendLeadSurveyTest {
    @isTest
    public static void testSurvey() {

        Test.StartTest();

        ScheduleBatchSendLeadSurvey ScheduleBatchSurvey = new ScheduleBatchSendLeadSurvey();
        String sch = '0 0 23 * * ?'; 
        System.schedule('Schedule Batch Lead Survey', sch, ScheduleBatchSurvey);
        Test.stopTest(); 
    }

}
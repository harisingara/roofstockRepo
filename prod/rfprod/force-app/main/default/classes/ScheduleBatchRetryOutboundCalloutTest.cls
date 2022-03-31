@isTest
public class ScheduleBatchRetryOutboundCalloutTest {
    public static testMethod void testschedule() {
        
        Test.StartTest();
        ScheduleBatchRetryOutboundCallout scheduleRetryOutbound = new ScheduleBatchRetryOutboundCallout();
        
        String sch = '0 0 23 * * ?'; 
        system.schedule('Schedule Retry Outbound', sch, scheduleRetryOutbound);
        
        Test.stopTest(); 
    }
}
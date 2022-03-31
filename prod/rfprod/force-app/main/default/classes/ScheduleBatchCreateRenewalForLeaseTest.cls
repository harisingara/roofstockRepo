@isTest
public class ScheduleBatchCreateRenewalForLeaseTest {
    public static testMethod void testschedule() {

        Test.StartTest();

        ScheduleBatchCreateRenewalForLease schBatLeaseRenewal = new ScheduleBatchCreateRenewalForLease();
        String sch = '0 0 23 * * ?'; 
        System.schedule('Schedule Lease renewal', sch, schBatLeaseRenewal);
        
        Test.stopTest(); 
    }
}
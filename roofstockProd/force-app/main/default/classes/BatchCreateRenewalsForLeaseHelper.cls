public with sharing class BatchCreateRenewalsForLeaseHelper {

    public static Opportunity createRenewalOpp(Lease__c lease, Id renewalOppRecTypId) {
        String oppName = 'Renewal - ' + lease.Property_Unit__r.Name + ' - ' + String.ValueOf(lease.Lease_End_Date__c).split(' ')[0];
        oppName = (oppName.length() > 120)?oppName.LEFT(120):oppName;
        Opportunity op = new Opportunity();
        op.Name =  oppName;
        op.Related_Lease__c = lease.Id;
        op.Property_unit__c = lease.Property_Unit__r.Id;
        for(Tenant__c tenant : lease.Tenant1__r) {
            op.Primary_Tenant__c = tenant.Id;
        }
        op.StageName = calculateOpptyStage(lease.Appr_Status__c, lease.isM2M__c, 'Waiting for CMA');
        op.RecordTypeId = renewalOppRecTypId;
        op.CloseDate = lease.Lease_End_Date__c - 1;
        return op;
    }

    public static String calculateOpptyStage(String apprStatus, Boolean isM2m, String defaultStage) {
        
        if (isM2m) {
            defaultStage = 'Closed M2M';
        }
        else if (apprStatus == 'Approved') {
            defaultStage = 'Approved';
        }
        else if (apprStatus == 'Scheduled') {
            defaultStage = 'Scheduled';
        }
        else if (apprStatus == 'Selected') {
            defaultStage = 'Selected';
        }
        else if (apprStatus == '') {
            defaultStage = 'Closed Renewed';
        }
        return defaultStage;

    }

    /*public static Job__c createJobTurn(Lease__c lease, Id jobTurnRecordTypeId) {
        String jobTurnName = 'Turn - ' + lease.Property_Unit__r.Name + ' - ' + String.ValueOf(lease.Lease_End_Date__c).split(' ')[0];
        jobTurnName = (jobTurnName.length() > 120)?jobTurnName.LEFT(120):jobTurnName;
        Job__c turn = new Job__c();
        turn.Name =  jobTurnName;
        turn.Related_Lease__c = lease.Id;
        turn.Property_unit__c = lease.Property_Unit__r.Id;
        turn.Property__c = lease.Property_Unit__r.Property__c;
        turn.Job_Status__c = 'Waiting for Move Out';
        turn.Prior_Move_In_Date__c = lease.Lease_Start_Date__c;
        // update move out date, tenant status, move out reason from addproperty till job is completed
        turn.RecordTypeId = jobTurnRecordTypeId;
        turn.Job_Type__c = 'Turn';
        return turn;
    }

    public static List<Lease__c> getLeaseForJobCreation(List<Lease__c> leaseList) {
        return leaseList;
    }

    public static  List<Job__c>  {
        List<Job__c> jobList = [select id from Job__c where Property_unit__r.Homecode__c IN : AND Job_status__c <> 'Job Completed' AND Job_status__c <> 'Job Cancelled'];
    }*/
}
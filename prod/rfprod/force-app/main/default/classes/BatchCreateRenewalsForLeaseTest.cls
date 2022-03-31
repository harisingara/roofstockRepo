@isTest
public class BatchCreateRenewalsForLeaseTest {
    
    static {   
        TestDataFactory.insertHierarchyCustomSettingData();
    }

    static testMethod void BatchCreateRenewalsForLease() {
        Property2__c p = new Property2__c();
        p.name = '200 w commerce st Dallas TX Lease Ren Test';
        p.property_management_company__c = 'Streetlane Property Management';
        insert p;

        system.debug('Jungle P Id : ' + p.Id);

        Property_Unit__c pu = new Property_Unit__c();
        pu.name = '200 w commerce st Dallas TX';
        pu.Property__c = p.Id;
        pu.Bathrooms__c = 3;
        pu.Bedrooms__c = 2.5;
        pu.HomeCode__c = 'q200com';
        pu.Occupancy_Status__c = 'Occupied No Notice';  
        pu.PropertyUnitId__c = 'q200com-lease-rew-test'; 
        insert pu;

        system.debug('Jungle PU Id : ' + pu.Id);

        Lease__c l = new Lease__c();
        l.name = 'test Class Lease';
        l.Lease_Start_Date__c = System.today() - 300;
        l.Lease_End_Date__c = System.today() + 65;
        l.lease_signed_date__C = System.today() - 320;
        l.Lease_Id__c = 00005.0;
        l.Property_Unit__c = pu.Id;
        Insert l;

        system.debug('Jungle Lease Id : ' + l.Id);

        Tenant__c t = new Tenant__c();
        t.Name = 'Angel Island';
        t.Lease__c = l.Id;
        t.Primary__c = true;
        t.Status__c = 'Current';
        t.Tenant_Type__c = 'Primary';
        t.Tenent_Id__c = 00001.0;
        t.First_Name__c = 'Angel';
        t.Last_Name__c = 'Island';
        Insert t;

        system.debug('Jungle Tenant Id : ' + t.Id);

        Test.startTest();
            BatchCreateRenewalsForLease btLeaseRenewal = new BatchCreateRenewalsForLease();
            DataBase.executeBatch(btLeaseRenewal);
            BatchCreateRenewalsForLeaseHelper.calculateOpptyStage('', true, 'Waiting for CMA');
            BatchCreateRenewalsForLeaseHelper.calculateOpptyStage('Approved', false, 'Waiting for CMA');
            BatchCreateRenewalsForLeaseHelper.calculateOpptyStage('Scheduled', false, 'Waiting for CMA');
            BatchCreateRenewalsForLeaseHelper.calculateOpptyStage('Selected', false, 'Waiting for CMA');
            BatchCreateRenewalsForLeaseHelper.calculateOpptyStage('', false, 'Waiting for CMA');
        Test.stopTest();
    }
}
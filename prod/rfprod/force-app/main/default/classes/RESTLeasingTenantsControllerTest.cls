@isTest
public class RESTLeasingTenantsControllerTest {
    static {
        //create test users
        TestDataFactory.insertHierarchyCustomSettingData();
        TestDataFactory.createTestTenantListingRecords(1);
        // TestDataFactory.createTestTenantListingRecords(5);
    }
    static testMethod void MatchingLeasingRecords() {
        Lease__c l = [select Id from Lease__c][0];
        System.debug('===l=='+l);
        
        Tenant__c t = new Tenant__c();
        t.Last_Name__c = 'John';
        t.Tenent_Id__c = 234;
        t.Lease__c = l.Id;
        //t.Leasing__c = l.Id;
        insert t;
        
        List<RESTLeasingTenantsHelper.Tenants> tenantList = new List<RESTLeasingTenantsHelper.Tenants>();
        RESTLeasingTenantsHelper.Tenants tens = new RESTLeasingTenantsHelper.Tenants();
        tens.fName ='sree';
        tens.lName ='menon';
        tens.status = 'Evicted';
        tens.tenantId = 234;
        tenantList.add(tens);
        
        List<RESTLeasingTenantsHelper.LeaseList> requestList = new List<RESTLeasingTenantsHelper.LeaseList>();
        RESTLeasingTenantsHelper.LeaseList lease = new RESTLeasingTenantsHelper.LeaseList();
        lease.homeCode ='1234';
        lease.leaseId =1234;
        lease.leaseStartDate = String.valueOf(System.today());
        lease.leaseEndDate = String.valueOf(System.today());
        lease.status ='Leased';
        lease.tenants = tenantList;
        lease.rentAmount =1000;
        lease.balance = 190;
        requestList.add(lease);
        
        RESTLeasingTenantsHelper.LeaseListWrap leaseRequest = new RESTLeasingTenantsHelper.LeaseListWrap();
        leaseRequest.LeaseList = requestList;
        String sReq = JSON.serialize(leaseRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/updateLease';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTLeasingTenantsController.updateLease();
        Test.stopTest();
    }
    static testMethod void noMatchingTenentRecords(){
        
        
        List<RESTLeasingTenantsHelper.Tenants> tenantList = new List<RESTLeasingTenantsHelper.Tenants>();
        RESTLeasingTenantsHelper.Tenants tens = new RESTLeasingTenantsHelper.Tenants();
        tens.fName ='sree';
        tens.lName ='menon';
        tens.status = 'Evicted';
        tens.tenantId = 2346;
        tenantList.add(tens);
        
        List<RESTLeasingTenantsHelper.LeaseList> requestList = new List<RESTLeasingTenantsHelper.LeaseList>();
        RESTLeasingTenantsHelper.LeaseList lease = new RESTLeasingTenantsHelper.LeaseList();
        lease.homeCode ='1234';
        lease.leaseId =1234;
        lease.leaseStartDate = String.valueOf(System.today());
        lease.leaseEndDate = String.valueOf(System.today());
        lease.status ='Leased';
        lease.tenants = tenantList;
        lease.rentAmount =1000;
        lease.balance = 500;
        requestList.add(lease);
        
        //String sReq = JSON.serialize(requestList);
        RESTLeasingTenantsHelper.LeaseListWrap leaseRequest = new RESTLeasingTenantsHelper.LeaseListWrap();
        leaseRequest.LeaseList = requestList;
        String sReq = JSON.serialize(leaseRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/updateLease';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTLeasingTenantsController.updateLease();
        Test.stopTest();
    }
    static testMethod void noMatchingLeaseRecords(){
        Id amPropertyRecordTypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByName()
		.get('Asset Management')
		.getRecordTypeId();
        
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
        //p.Year_Built__c = 1972;
        p.name = '123 Main St Tracy CA 95391';
        p.recordtypeid = amPropertyRecordTypeId;
        insert p;
        
        Property_Unit__c pu = new Property_Unit__c();
        pu.name = '123 Main St Tracy CA 95391';
        pu.Property__c = p.id;
        pu.Bathrooms__c = 3;
        pu.Bedrooms__c = 2.5;
        pu.HomeCode__c = '12345';
        insert pu;
        
        List<RESTLeasingTenantsHelper.Tenants> tenantList = new List<RESTLeasingTenantsHelper.Tenants>();
        RESTLeasingTenantsHelper.Tenants tens = new RESTLeasingTenantsHelper.Tenants();
        tens.fName ='sree';
        tens.lName ='menon';
        tens.status = 'Evicted';
        tens.tenantId = 2346;
        tenantList.add(tens);
        
        List<RESTLeasingTenantsHelper.LeaseList> requestList = new List<RESTLeasingTenantsHelper.LeaseList>();
        RESTLeasingTenantsHelper.LeaseList lease = new RESTLeasingTenantsHelper.LeaseList();
        lease.homeCode ='12345';
        lease.leaseId =12347;
        lease.leaseStartDate = String.valueOf(System.today());
        lease.leaseEndDate = String.valueOf(System.today());
        lease.status ='Leased';
        lease.tenants = tenantList;
        lease.rentAmount =1000;
        lease.balance = 10;
        requestList.add(lease);
        
        //String sReq = JSON.serialize(requestList);
        RESTLeasingTenantsHelper.LeaseListWrap leaseRequest = new RESTLeasingTenantsHelper.LeaseListWrap();
        leaseRequest.LeaseList = requestList;
        String sReq = JSON.serialize(leaseRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/updateLease';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTLeasingTenantsController.updateLease();
        Test.stopTest();
    }
    
    static testMethod void noMatchingLeaseRecordsException(){
        
        try{
            List<RESTLeasingTenantsHelper.Tenants> tenantList = new List<RESTLeasingTenantsHelper.Tenants>();
            RESTLeasingTenantsHelper.Tenants tens = new RESTLeasingTenantsHelper.Tenants();
            tens.fName ='sree';
            tens.lName ='menon';
            tens.status = 'Evicted';
            tens.tenantId = 2346;
            tenantList.add(tens);
            
            List<RESTLeasingTenantsHelper.LeaseList> requestList = new List<RESTLeasingTenantsHelper.LeaseList>();
            RESTLeasingTenantsHelper.LeaseList lease = new RESTLeasingTenantsHelper.LeaseList();
            lease.homeCode ='12345';
            lease.leaseId =12347;
            lease.leaseStartDate = String.valueOf(System.today());
            lease.leaseEndDate = String.valueOf(System.today());
            lease.status ='Leased';
            lease.tenants = tenantList;
            lease.rentAmount =1000;
            lease.balance = 0;
            requestList.add(lease);
            
            //String sReq = JSON.serialize(requestList);
            RESTLeasingTenantsHelper.LeaseListWrap leaseRequest = new RESTLeasingTenantsHelper.LeaseListWrap();
            leaseRequest.LeaseList = requestList;
            String sReq = JSON.serialize(requestList);
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/updateLease';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(sReq);
            RestContext.request = req;
            RestContext.response = res;
            Test.startTest();
            RESTLeasingTenantsController.updateLease();
            Test.stopTest();
        }
        catch(Exception ex){
            
        }
    }
    
}
@isTest
public class RESTLeasingRenewalControllerTest {
    static {
        //create test users
        TestDataFactory.insertHierarchyCustomSettingData();
        TestDataFactory.createTestTenantListingRecords(1);
        // TestDataFactory.createTestTenantListingRecords(5);
    }
    
    
	
    
    static testMethod void processLeaseRenewalProposals() {
        Lease__c l = [select Id, Lease_Id__c from Lease__c][0];
        l.Yardi_Lease_Id__c = 123;
        update l;
        System.debug('===l=='+l);
        
        Tenant__c t = new Tenant__c();
        t.Last_Name__c = 'John';
        t.Tenent_Id__c = 234;
        t.Lease__c = l.Id;
        //t.Leasing__c = l.Id;
        insert t;
        
        List<RESTLeasingRenewalHelper.LeaseRenewalProposalList> lrpList = new List<RESTLeasingRenewalHelper.LeaseRenewalProposalList>();
        RESTLeasingRenewalHelper.LeaseRenewalProposalList lrp = new RESTLeasingRenewalHelper.LeaseRenewalProposalList();
        lrp.leaseRenewalProposalId = 11112;    
        lrp.yardiRenewalProposalLeaseHistoryHmy  = 32194;
        lrp.yardiCurrentLeaseHistoryHmy = 123;
        lrp.tenantId = 234;
        lrp.leaseStartDate = String.valueOf(System.today());
        lrp.leaseEndDate = String.valueOf(System.today());
        lrp.status ='Proposed Leased';      
        lrp.proposedRent =1000;
        lrp.term = '12-Months';
        lrp.fName = 'fname';
        lrp.lName = 'lname';
        lrp.prospectLink = 'www.roofstock.com/yardiprospect';
        lrp.tenantLink = 'www.roofstock.com/yarditenant';
        lrpList.add(lrp);
        
        RESTLeasingRenewalHelper.LeaseListWrap leaseRequest = new RESTLeasingRenewalHelper.LeaseListWrap();
        leaseRequest.LeaseRenewalProposalList = lrpList;
        String sReq = JSON.serialize(leaseRequest);
        System.debug('NDEBUG leaseRequest' +leaseRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/UpdateLeaseRenewal';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTLeasingRenewalController.updateLease();
        Test.stopTest();
        
        List <Lease_Renewal_Proposal__c> lrpRecList = [select Id from Lease_Renewal_Proposal__c limit 1];
        System.assertEquals(1, lrpRecList.size(), 'Lease Renewal Proposal request not created');        
    }
    
    static testMethod void processLeaseRenewalProposalsError() {
        Lease__c l = [select Id, Lease_Id__c from Lease__c][0];
        l.Yardi_Lease_Id__c = 123;
        update l;
        System.debug('===l=='+l);
        
        Tenant__c t = new Tenant__c();
        t.Last_Name__c = 'John';
        t.Tenent_Id__c = 234;
        t.Lease__c = l.Id;
        insert t;
        
        List<RESTLeasingRenewalHelper.LeaseRenewalProposalList> lrpList;
        RESTLeasingRenewalHelper.LeaseListWrap leaseRequest = new RESTLeasingRenewalHelper.LeaseListWrap();
        leaseRequest.LeaseRenewalProposalList = lrpList;
        String sReq = JSON.serialize(leaseRequest);
        System.debug('NDEBUG leaseRequest' +leaseRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/UpdateLeaseRenewal';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTLeasingRenewalController.updateLease();
        Test.stopTest();
    }
}
@isTest
public class RESTPlanomaticCreateOrderControllerTest{
    static testMethod void RESTPlanomaticCreateOrderControllerTest() {        
        TestDataFactory.insertHierarchyCustomSettingData();
        RESTPlanomaticCreateOrderHelper.Planomatic plano= new RESTPlanomaticCreateOrderHelper.Planomatic();
        
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
       // p.Year_Built__c = 1972;
        p.name = '123 Main St Tracy CA 95391';
        p.Street_Address__c = '1234 USA';
        p.City__c = 'sdfsd';
        p.County__c = 'US';
        p.Zip__c ='00009';
        p.State__c = 'CO';
        p.Seller_Provided_List_Price__c = 500;
        p.Square_Feet__c = '456';
        insert p;
        
        Property_Unit__c pu = new Property_Unit__c();
        pu.name = '123 Main St Tracy CA 95391';
        pu.Property__c = p.id;
        pu.Bathrooms__c = 3;
        pu.Bedrooms__c = 2.5;
        pu.HomeCode__c = 'q2000';
        pu.Occupancy_Status__c = 'Vacant Unrented Ready';
        pu.Operating_Status__c = 'Leasable';
        insert pu;
        
        Rental_Listing__c rl = new Rental_Listing__c();
        rl.Property_Unit__c = pu.Id;
        rl.Name = 'Rental Listing';
        insert rl;
        /* 
        Leasing_Availability__c la = new Leasing_Availability__c();
        la.Property_Unit__c = pu.Id;
        la.Name = '1234 USA';
        insert la;
        */
        Planomatic_Order__c po = new Planomatic_Order__c();
        po.Request_Id__c = '1234';
        po.Rental_Listing__c = rl.Id;
        insert po;
        
        RESTPlanomaticCreateOrderHelper.PlanomaticWrap PlanWrap= new RESTPlanomaticCreateOrderHelper.PlanomaticWrap();        
        plano.orderedOnUtc = '2021-08-08T16:00:00.000+00:00';
        plano.completedOnUtc = '2021-08-08T16:00:00.000+00:00';
        plano.status = 'Ordered';
        plano.externalId = '4543';
        plano.orderId = '6789';
        plano.requestId = '1234';
        plano.errorMessage = '';
		PlanWrap.photoOrder = plano;
        
        String sReq = JSON.serialize(PlanWrap);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/updatePhotoCallback';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTPlanomaticCreateOrderController.updatePlanomaticOrder();
        Test.stopTest();
    }
    
}
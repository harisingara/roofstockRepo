@isTest(seealldata=true)
public with sharing class RESTInspectionControllerTest {
    static testMethod void RESTInspectionControllerTest() {
        Property2__c p = new Property2__c(); 
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-RESTInspectionControllerTest';
        p.Property_Type__c = 'Single Family';
        //p.Year_Built__c = '1972';
        p.name = '123 Main St Tracy CA 95391';
        insert p;

        Property_Unit__c pu = new Property_Unit__c();
        pu.name = '123 Main St Tracy CA 95391';
        pu.Property__c = p.Id;
        pu.Bathrooms__c = 3;
        pu.Bedrooms__c = 2.5;
        pu.HomeCode__c = 'q2000';
        pu.Occupancy_Status__c = 'Vacant Unrented Not Ready';	
        pu.propertyunitid__c = '48eeb1f8-561c-42ab-RESTInspectionControllerTest';
        insert pu;

        List<RESTInspectionHelper.InspectionRequest> inspectionList = new List<RESTInspectionHelper.InspectionRequest>();
        RESTInspectionHelper.InspectionRequest contextInspection= new RESTInspectionHelper.InspectionRequest();
        contextInspection.sourceId = '52905|48eeb1f8-561c-RESTInspectionControllerTest';
        contextInspection.source = 'Bpm';
        contextInspection.propertyId = '72bcf440-RESTInspectionControllerTest';
        contextInspection.unitId = '48eeb1f8-561c-42ab-RESTInspectionControllerTest';
        contextInspection.name = '110 N Waverly St # 112, Columbus, OH 43213';
        contextInspection.createdByEmail = userInfo.getUseremail();
        contextInspection.accessType = 'Tenant Let In';
        contextInspection.propertyAccessNotes = 'Test';
        contextInspection.status = 'Completed';
        contextInspection.type = 'Diligence';
        contextInspection.inspectionAccountId = 'RInsCTest';
        contextInspection.inspectionAccountName = '162227-RESTInspectionControllerTest';
        contextInspection.scheduledInspectionDate = System.today() + 4;
        contextInspection.scheduledInspectionTime = '11:00 AM';
        contextInspection.scheduledNotes = 'scheduledNotes';
        contextInspection.residentialInformation = 'residentialInformation';
        contextInspection.photographerInformation = 'photographerInformation';
        contextInspection.inspectorsInformation = 'inspectorsInformation';
        contextInspection.estimatedCapexManual = 2000;
        contextInspection.estimatedRentUW = 300;
        contextInspection.inspectedBedRooms = 3;
        contextInspection.inspectedBathRooms = 3;
        contextInspection.inspectedSquareFeet = 1998;
        contextInspection.inspectedEstimatedCost = 5000;
        contextInspection.bpmRenovationCost = 3000;
        inspectionList.add(contextInspection);
        RESTInspectionHelper.InspectionData oReqData = new RESTInspectionHelper.InspectionData(); 
		oReqData.inspectionList =  inspectionList;        
        String sReq = JSON.serialize(oReqData);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/updateListing';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
            RESTInspectionController.upsertInspection();
            req.requestBody = Blob.valueOf('');
            RestContext.request = req;
            RestContext.response = res;
      
            RESTInspectionController.upsertInspection();
        Test.stopTest();
    }
}
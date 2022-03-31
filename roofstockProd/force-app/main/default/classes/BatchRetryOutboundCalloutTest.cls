@isTest
public class BatchRetryOutboundCalloutTest {
    
    static testMethod void BatchRetryOutboundCallout(){
        Test.startTest();
        Outbound_Message_Request__c omr = new Outbound_Message_Request__c();
        omr.HTTP_Endpoint__c = 'https://dev.roofstock.com/-api/shares-server/rest/salesforceStatusUpdate';
        omr.Auth_Token__c = '';
        omr.Generate_New_Auth_Token__c =false;
        omr.HTTP_Method__c = 'POST';
        omr.Status__c ='Retry - Pending';
        omr.Retry_Count__c = 2;
        omr.Request__c = '{"taskList":[{"taskOutCome":null,"status":"New","reviewedBy":"chidanand.magadum@roofstock.com","parentId":"350512","externalId":null}]}';
        insert omr; 
        
        HttpRequest req = new HttpRequest();
        req.setBody(omr.Request__c);
        req.setMethod('POST');
        req.setEndpoint(omr.HTTP_Endpoint__c);
        OutboundMessageRequestHelper.logOutboundRetryRequest(req,'Roofstock One');
        BatchRetryOutboundCallout btoc = new BatchRetryOutboundCallout();
        DataBase.executeBatch(btoc);
        Test.stopTest();
    }
    
}
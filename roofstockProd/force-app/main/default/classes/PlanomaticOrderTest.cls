@isTest
public class PlanomaticOrderTest {
	
    static { 
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void planomaticOrderTest() {
        Planomatic_Order__c po = new Planomatic_Order__c();
        po.Date_Ordered__c = System.now();
        po.Request_Id__c = '1234';
        po.Status__c = 'Ordered';
        po.Order_Id__c = '205604';
        insert po;

		Planomatic_Order__c pOrder = [select Id,Status__c,Order_Id__c from Planomatic_Order__c where Id=:po.Id limit 1];        
        pOrder.Status__c = 'Notified';
        //update pOrder; 
        Set<String> orderSet = new Set<String>();
        orderSet.add('205604');
        Test.setMock(HttpCalloutMock.class, new PlanomaticDataFeedMock());  
        PlanomaticOrderHelper.calldatafeedAPI(orderSet);

    }
}
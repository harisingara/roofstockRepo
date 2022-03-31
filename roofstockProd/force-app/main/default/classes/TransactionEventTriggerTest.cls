@isTest
public class TransactionEventTriggerTest {
	
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }

    static testMethod void txnEventTest() {
        Test.startTest();

        String jsonString = '{ "transactionContacts": [{"email":"test@test.com","contactNumber":"1","type":"Buyer","roofstockUserId":"","bpmContactId":1234,"rsAccountId":569308,"firstName":"test","lastName":"tet","companyName":"test comp","mobile":"900090000009"}] }';
		String jsonInspection = '{"Inspections":[{"inspectionId":"845ff09b-d937-46b5-ac5b-90fad17f3958","diligenceDeadline":"2021-12-25","inspectionDueDate":"2021-12-26"}]}';     
      
        Transaction_Event__e tevent = new Transaction_Event__e ();
        tevent.Transaction_Id__c ='Test000000';
        tevent.Transaction_Coordinator__c ='salesforce@sfdc.com';
        tevent.Customer_Service__c = 'salesforce@sfdc.com';
        tevent.Underwriting_Analyst__c = 'salesforce@sfdc.com';
        tevent.Roofstock_Advisor__c = 'salesforce@sfdc.com';
        tevent.Roofstock_Inventory_Owner__c = 'salesforce@sfdc.com';
        tevent.Transaction_Contact__c =jsonString;
        tevent.Inspection__c = jsonInspection;
        tevent.Event_Type__c = 'Adhoc Update';
        
        List<Transaction_Event__e> transEvents = new List<Transaction_Event__e>();
        transEvents.add(tevent);
        List<Database.SaveResult> results = EventBus.publish(transEvents);
        Test.getEventBus().deliver();
        Test.stopTest(); 
        
    }
}
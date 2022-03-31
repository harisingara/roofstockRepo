@isTest
public class SendErrorLogNotificationTest {
    static{ 
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void RESTContactControllerTestMatchingBPMContactId() {
      //  Id leadBuyerRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        insert new Error_Notification_Last_Run_Time__c(SetupOwnerId=UserInfo.getOrganizationId());
        
        DebugLog__c oLog = new DebugLog__c(Log_Type__c = 'Error'); 
        insert olog ; 

        Test.StartTest();
        SchedulableContext sc = null;
        scheduledErrorLogNotification sh1 = new scheduledErrorLogNotification();      
        sh1.execute(sc);
        Test.stopTest();
    }
}
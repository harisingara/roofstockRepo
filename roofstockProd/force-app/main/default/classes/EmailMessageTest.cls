@isTest
public class EmailMessageTest {

    // varable to test the exception scenario in the EmailMessageTrigger
    public static Boolean TestException = false;

    static testMethod void emailMessageHelper() {
        //Insert test case record
        String caseTransactionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        TestDataFactory.insertHierarchyCustomSettingData();
        Case c = new Case();
        c.Subject = 'Om Test';  
        c.Status ='New';
        c.Priority = 'Medium';
        c.Origin = 'Email';
        c.RecordTypeId = caseTransactionRecordTypeId;
        c.Assigned_User__c = UserInfo.getUserId();
        insert c;
        
        //Insert emailmessage for case
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = True;
        email.ToAddress= c.Assigned_User__r.Email;
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = c.Id; 
        insert email;

    }

    static testMethod void emailMessageHelper1() {
        //Insert test case record
        String caseGeneralRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('General').getRecordTypeId();
        TestDataFactory.insertHierarchyCustomSettingData();
        Case c = new Case();
        c.Subject = 'Email Reopen Test';  
        c.Status ='Open';
        c.Priority = 'Medium';
        c.Origin = 'Email';
        c.RecordTypeId = caseGeneralRecordTypeId;
        c.Assigned_User__c = UserInfo.getUserId();
        insert c;
        
        //Insert emailmessage for case
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = True;
        email.ToAddress= c.Assigned_User__r.Email;
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = c.Id; 
        insert email;

        //Insert emailmessage for case
        EmailMessage email12 = new EmailMessage();
        email12.FromAddress = 'test@abc.org';
        email12.Incoming = False;
        email12.ToAddress= c.Assigned_User__r.Email;
        email12.Subject = 'Test email';
        email12.HtmlBody = 'Test email body';
        email12.ParentId = c.Id; 
        insert email12;

        List<sObject> newRecordsList;
        Map<Id,sObject> newRecordsMap;
        List<sObject> oldRecordsList;
        Map<Id,sObject> oldRecordsMap;
        EmailMessageTriggerHandler emth = new EmailMessageTriggerHandler();
        emth.beforeInsert(newRecordsList);
        emth.beforeUpdate(newRecordsList, newRecordsMap, oldRecordsList, oldRecordsMap);
        emth.afterUpdate(newRecordsList, newRecordsMap, oldRecordsList, oldRecordsMap);
        emth.beforeDelete(oldRecordsList, oldRecordsMap);
        emth.afterDelete(oldRecordsList, oldRecordsMap);
        emth.afterUndelete(newRecordsList, newRecordsMap);
    }
    
    static testMethod void emailMessageHelperException() {
        //Insert test case record
        String caseGeneralRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('General').getRecordTypeId();
        TestDataFactory.insertHierarchyCustomSettingData();
        Case c = new Case();
        c.Subject = 'Email Reopen Test';  
        c.Status ='Open';
        c.Priority = 'Medium';
        c.Origin = 'Email';
        c.RecordTypeId = caseGeneralRecordTypeId;
        c.Assigned_User__c = UserInfo.getUserId();
        insert c;
        
        EmailMessageTest.TestException = true;

        //Insert emailmessage for case
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = True;
        email.ToAddress= c.Assigned_User__r.Email;
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = c.Id; 
        insert email;
    }

}
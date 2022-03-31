@isTest
public class TaskControllerTest {
	static testMethod void TaskController() {
       String caseTransactionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        TestDataFactory.insertHierarchyCustomSettingData();
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        Contact con = new Contact();
        con.firstname = 'Salesforce';
        con.lastname = 'SAP';
        con.BPM_Contact_Id__c = '1234';
        con.Email = 'chidanand.Magadum@Roofstock.com';
        con.AccountId = acc.Id;
        insert con;
        
        Transaction__c trans = new Transaction__c();
        trans.Buyer_Contact_Id_1__c = '1234';
        trans.Buyer_Contact1__c = con.Id;
        trans.Transaction_Id__c = '12345';
        trans.Transaction_Status__c = 'Pending Escrow';
        insert trans;
        
        Case c = new Case();
        c.ContactId = con.Id;
        c.Origin = 'Email';
        c.RecordTypeId = caseTransactionRecordTypeId;
        c.Subject = 'Slow new [txn:12345:txn]';
        c.Assigned_User__c = userinfo.getUserId(); 
        insert c;
        Task oTask= new task(); 
		oTask.Subject = 'test'; 
		oTask.whatId = c.Id;         
        insert oTask;
        TaskController.getTaskDescription(oTask.Id); 
 
    }
}
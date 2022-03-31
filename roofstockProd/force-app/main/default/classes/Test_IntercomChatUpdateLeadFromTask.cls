@isTest
public class Test_IntercomChatUpdateLeadFromTask
{
    
      static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
	static testMethod void IntercomChatTest()
    {
        Lead testLead = new Lead();
        testLead.Company = 'Macrosoft';
        testLead.LastName = 'Gill Bates';
        insert testLead;
        
        Task testTask = new Task();
        testTask.whoId = testLead.Id;
        testTask.Subject = 'Intercom Chat';
        testTask.Status = 'In Progress';
        testTask.Priority = 'Low';
        insert testTask;
        
        testTask.Status = 'Completed';
        
        Test.startTest();
        	update testTask;
		Test.stopTest();
        
        testLead = [ SELECT Id, Intercom_Chat__c
                   FROM Lead
                   WHERE Id = :testLead.Id ];
        
       	System.assertEquals( true, testLead.Intercom_Chat__c );
        
        delete testTask;
        delete testLead;
    }
}
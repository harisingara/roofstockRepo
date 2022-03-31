@isTest
public class RESTCreateWorkQueueControllerTest {
    static { 
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testmethod void RESTCreateWorkQueueController1(){
        
        Account acc = new Account();
        acc.Name='sfdc';
        insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName='sfdc';
        insert con;
        
        
        Investment_Account__c ia = new Investment_Account__c();
        ia.Investment_Account_Id__c = '123';
        ia.Account__c = acc.Id;
        insert ia;
        
        
        
        List<TaskWrapper.Tasks> taskList = new List<TaskWrapper.Tasks>();
        TaskWrapper.Tasks tsk = new TaskWrapper.Tasks();
        tsk.externalId = '123';
        tsk.taskType = 'AI Task';
        tsk.description = 'AI Task';
        tsk.parentId = '123';
        tsk.rsContactId = '123';
        tsk.ownerEmail = 'ai@gmail.com';
        
        tsk.orderId = '123';
        tsk.orderDate = Date.today();
        tsk.investmentAmount = 1500.0;
        tsk.fundingSource = 'sfdc';
        tsk.errorDescription = '123';
        
        tsk.fundingInitiated = true;
        tsk.cancelledDate = Date.today();
        tsk.cancelledBy = 'sfdc';
        taskList.add(tsk);
        
        TaskWrapper.TasksWrap tskRequest = new TaskWrapper.TasksWrap();
        tskRequest.taskList = taskList;
        String sReq = JSON.serialize(tskRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/createworkqueue';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RestCreateWorkQueueController.createworkqueue();
        Test.stopTest();
        
    }
    
}
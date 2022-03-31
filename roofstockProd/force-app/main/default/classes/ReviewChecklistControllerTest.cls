@isTest
public class ReviewChecklistControllerTest {
    
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    
     static testMethod void reviewChecklistUpdateOffMarket() {
         TestDataFactory.createTestUserRecords(2);
         User u = [Select Id from User where Username= 'TestUser1@roofstock.com' limit 1];
         
         Account acc = new Account();
         acc.Name='Test Account';
         insert acc;
        
         contact con = new Contact();
         con.LastName='sfdc';
         con.AccountId = acc.Id;
         con.Email = 'rsTest@roofstock.com';
         insert con;
         
         Transaction__c trans = new Transaction__c();
         trans.Name = 'New Transaction';
         trans.Transaction_Id__c = '123458';
         trans.Roofstock_TC_User__c =u.Id;
         trans.Origination_Source__c = 'Off Market - Internal (RS)';
         trans.Transaction_Status__c = 'Transaction Cancelled';
         insert trans;
         
         Transaction_Contact__c txnCon = new Transaction_Contact__c(Contact_Type__c = 'Buyer Broker', Transaction__c = trans.Id, Contact__c = con.Id);
         
         List<Transaction_Snapshot__c> rchklst = new List<Transaction_Snapshot__c>();
         List<Transaction_Snapshot__c> lstDocuments = new List<Transaction_Snapshot__c>();
         rchklst.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = 'Buyer Entity Old', Review_Checklist_Type__c = 'Buyer Entity', Sort_Order__c =1, TC_Updates__c = 'Buyer Entity New', Transaction__c = trans.Id, Verify__c = true));
         rchklst.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = '1245', Review_Checklist_Type__c = 'Contract Price', Sort_Order__c =2, TC_Updates__c = '3546', Transaction__c = trans.Id, Verify__c = false));
         rchklst.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = '1/1/2021', Review_Checklist_Type__c = 'Acceptance Date', Sort_Order__c =3, TC_Updates__c = '1/2/2021', Transaction__c = trans.Id, Verify__c = true));
         rchklst.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = '1245', Review_Checklist_Type__c = 'EMD Amount', Sort_Order__c =4, TC_Updates__c = '3546', Transaction__c = trans.Id, Verify__c = false));
         rchklst.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = '1/1/2021', Review_Checklist_Type__c = 'EMD Due Date', Sort_Order__c =5, TC_Updates__c = '1/1/2021', Transaction__c = trans.Id, Verify__c = true));
         rchklst.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = '1245', Review_Checklist_Type__c = 'Option Fee', Sort_Order__c =6, TC_Updates__c = '3546', Transaction__c = trans.Id, Verify__c = false));
         rchklst.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = '1/1/2022', Review_Checklist_Type__c = 'Due Diligence Date', Sort_Order__c =7, TC_Updates__c = '1/2/2022', Transaction__c = trans.Id, Verify__c = true));
         rchklst.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = '1/1/2022', Review_Checklist_Type__c = 'Inspection Deadline', Sort_Order__c =8, TC_Updates__c = '1/2/2022', Transaction__c = trans.Id, Verify__c = false));

         lstDocuments.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = '', Review_Checklist_Type__c = 'Contract', Sort_Order__c =9, TC_Updates__c = 'Test Comment', Transaction__c = trans.Id, Verify__c = true));
         lstDocuments.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = '', Review_Checklist_Type__c = 'Buyer Addendum', Sort_Order__c =10, TC_Updates__c = 'Test Comment', Transaction__c = trans.Id, Verify__c = false));
         lstDocuments.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = '', Review_Checklist_Type__c = 'A-B Contract', Sort_Order__c =11, TC_Updates__c = 'Test Comment', Transaction__c = trans.Id, Verify__c = true));

         
         ContractQCController.ReviewWrapper rWrap = new ContractQCController.ReviewWrapper();
         rWrap.lstReviewChecklist = rchklst;
         rWrap.lstDocuments = lstDocuments;
         
         ReviewChecklistController.upsertTransactionSnapshot(rWrap, trans.Id, true);
         
         System.assert([Select Id from Review_Checklist__c where Transaction__c =: trans.Id].size() > 0);
         
     }
    
    
     static testMethod void reviewChecklistUpdateMLS() {
         TestDataFactory.createTestUserRecords(2);
         User u = [Select Id from User where Username= 'TestUser1@roofstock.com' limit 1];
         
         Account acc = new Account();
         acc.Name='Test Account';
         insert acc;
        
         contact con = new Contact();
         con.LastName='sfdc';
         con.AccountId = acc.Id;
         con.Email = 'rsTest@roofstock.com';
         insert con;
         
         Transaction__c trans = new Transaction__c();
         trans.Name = 'New Transaction';
         trans.Transaction_Id__c = '123458';
         trans.Roofstock_TC_User__c =u.Id;
         trans.Origination_Source__c = 'MLS (RS)';
         trans.Transaction_Status__c = 'Pending Escrow';
         insert trans;
         
         Transaction_Contact__c txnCon = new Transaction_Contact__c(Contact_Type__c = 'Broker Buyer', Transaction__c = trans.Id, Contact__c = con.Id);
         insert txnCon;
         
         List<Transaction_Snapshot__c> rchklst = new List<Transaction_Snapshot__c>();
         List<Transaction_Snapshot__c> lstDocuments = new List<Transaction_Snapshot__c>();
         rchklst.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = 'Buyer Entity Old', Review_Checklist_Type__c = 'Buyer Entity', Sort_Order__c =1, TC_Updates__c = 'Buyer Entity New', Transaction__c = trans.Id, Verify__c = true));
         rchklst.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = '1245', Review_Checklist_Type__c = 'Contract Price', Sort_Order__c =2, TC_Updates__c = '3546', Transaction__c = trans.Id, Verify__c = false));
         rchklst.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = '1/1/2021', Review_Checklist_Type__c = 'Acceptance Date', Sort_Order__c =3, TC_Updates__c = '1/2/2021', Transaction__c = trans.Id, Verify__c = true));
         rchklst.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = '1245', Review_Checklist_Type__c = 'EMD Amount', Sort_Order__c =4, TC_Updates__c = '3546', Transaction__c = trans.Id, Verify__c = false));
         rchklst.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = '1/1/2021', Review_Checklist_Type__c = 'EMD Due Date', Sort_Order__c =5, TC_Updates__c = '1/1/2021', Transaction__c = trans.Id, Verify__c = true));
         rchklst.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = '1245', Review_Checklist_Type__c = 'Option Fee', Sort_Order__c =6, TC_Updates__c = '3546', Transaction__c = trans.Id, Verify__c = false));
         rchklst.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = '1/1/2022', Review_Checklist_Type__c = 'Due Diligence Date', Sort_Order__c =7, TC_Updates__c = '1/2/2022', Transaction__c = trans.Id, Verify__c = true));
         rchklst.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = '1/1/2022', Review_Checklist_Type__c = 'Inspection Deadline', Sort_Order__c =8, TC_Updates__c = '1/2/2022', Transaction__c = trans.Id, Verify__c = false));

         lstDocuments.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = '', Review_Checklist_Type__c = 'Contract', Sort_Order__c =9, TC_Updates__c = 'Test Comment', Transaction__c = trans.Id, Verify__c = true));
         lstDocuments.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = '', Review_Checklist_Type__c = 'Buyer Addendum', Sort_Order__c =10, TC_Updates__c = 'Test Comment', Transaction__c = trans.Id, Verify__c = false));
         lstDocuments.add(new Transaction_Snapshot__c(Original_Broker_Entry__c = '', Review_Checklist_Type__c = 'A-B Contract', Sort_Order__c =11, TC_Updates__c = 'Test Comment', Transaction__c = trans.Id, Verify__c = true));

         
         ContractQCController.ReviewWrapper rWrap = new ContractQCController.ReviewWrapper();
         rWrap.lstReviewChecklist = rchklst;
         rWrap.lstDocuments = lstDocuments;
         
         ReviewChecklistController.upsertTransactionSnapshot(rWrap, trans.Id, true);
         
         System.assert([Select Id from Review_Checklist__c where Transaction__c =: trans.Id].size() > 0);
         
     }
    
}
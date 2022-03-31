/*
	Modified By: Anh Phan
	Modified Date: 11/25/2021
	Purpose: Added new method populateCaseAgeHoursTest to test populateCaseAgeHours from CaseHandler.

*/

@isTest
public class CaseHandlerTest {
    
    static{
        TestDataFactory.insertHierarchyCustomSettingData();
        
    }
    
    static testMethod void CaseHandlerTransactionTest() {
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
        trans.Transaction_Status__c = 'Pending Escrow';
        insert trans;
        
        Case c = new Case();
        c.ContactId = con.Id;
        c.Origin = 'Email';
        c.RecordTypeId = caseTransactionRecordTypeId;
        c.Subject = 'Slow new';
        insert c;
        
    }
    static testMethod void CaseHandlerCertificationTest() {
        String caseCertificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Certification').getRecordTypeId();
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
        
        Certification__c cert = new Certification__c();
        cert.Seller_Contact_Id__c = '1234';
        cert.Seller_Contact__c = con.Id;
        cert.Certification_Status__c = 'Quality Control';
        insert cert;
        
        Case c = new Case();
        c.ContactId = con.Id;
        c.Origin = 'Email';
        c.RecordTypeId = caseCertificationRecordTypeId;
        c.Subject = 'Slow new';
        insert c;
        
    }
    static testMethod void CaseHandlerTransactionwithTrxIdTest() {
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
        c.Subject = 'Slow new [ txn:12345:txn ]';
        insert c;
        
    }
    static testMethod void CaseHandlerCertificationwithCertIdTest() {
        String caseCertificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Certification').getRecordTypeId();
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
        
        Certification__c cert = new Certification__c();
        cert.Seller_Contact_Id__c = '1234';
        cert.Seller_Contact__c = con.Id;
        cert.Certification_Status__c = 'Quality Control';
        cert.BPM_Certification_Id__c = '12345' ;
        insert cert;
        
        Case c = new Case();
        c.ContactId = con.Id;
        c.Origin = 'Email';
        c.RecordTypeId = caseCertificationRecordTypeId;
        c.Subject = 'Slow new [ cer:12345:cer ]';
        insert c;
        
    }
    static testMethod void updateCommunicationStatusReceivedDateTest() {
        TestDataFactory.insertHierarchyCustomSettingData();
        
        Case c = new Case();
        c.Origin = 'Email';
        c.Subject = 'Slow new [ cer:12345:cer ]';
        c.Last_Email_Sent_Date__c = System.today();
        //c.Last_Email_Received_Date__c = System.today+1;
        insert c;
    }
    static testMethod void updateCommunicationStatusSentDateTest() {
        TestDataFactory.insertHierarchyCustomSettingData();
        
        Case c = new Case();
        c.Origin = 'Email';
        c.Subject = 'Slow new [ cer:12345:cer ]';
        c.Last_Email_Sent_Date__c = System.today()+1;
        c.Last_Email_Received_Date__c = System.today();
        insert c;
    }
    
    static testMethod void assignCaseToCert(){
        Id caseTransactionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        Id caseCertificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Certification').getRecordTypeId();
        Property2__c prop = new Property2__c();
        prop.Name='90 Alexandria Dr, Mountain House, CA 95391';
        insert prop;
        
        Certification__c cert = new Certification__c();
        cert.BPM_Certification_Id__c = 'sfdc';
        insert cert;
        
        Case c = new Case();
        c.Origin = 'Email';
        c.Subject = '[cer:sfdc:cer]';
        c.Last_Email_Sent_Date__c = System.today()+1;
        c.Last_Email_Received_Date__c = System.today();
        c.Certification__c = cert.Id;
        c.RecordTypeId = caseCertificationRecordTypeId;
        insert c;
        
        List<Case> cseList = new List<Case>();
        cseList.add(c);
        CaseHandler.assignCaseToTransCert(cseList,caseTransactionRecordTypeId,caseCertificationRecordTypeId);
    }
    static testMethod void assignCaseToTrans(){
        Id caseTransactionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        Id caseCertificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Certification').getRecordTypeId();
        
        Transaction__c trans = new Transaction__c();
        trans.Transaction_Id__c = 'sfdc';
        trans.Buyer_Contact_Id_1__c = 'sfdc';
        trans.Roofstock_TC_User__c = UserInfo.getUserId();
        trans.Transaction_Status__c ='New';
        insert trans;
        
        Transaction__c trans2 = new Transaction__c();
        trans2.Transaction_Id__c = 'sfdc';
        trans2.Buyer_Contact_Id_1__c = 'sfdc';
        trans2.Roofstock_TC_User__c = UserInfo.getUserId();
        trans2.Transaction_Status__c ='New';
        insert trans2;
        
        Case c = new Case();
        c.Origin = 'Email';
        c.Subject = '[txn:sfdc:txn]';
        c.Last_Email_Sent_Date__c = System.today()+1;
        c.Last_Email_Received_Date__c = System.today();
        c.Transaction__c = trans.Id;
        insert c;
        
        List<Case> cseList = new List<Case>();
        cseList.add(c);
        CaseHandler.assignCaseToTransCert(cseList,caseTransactionRecordTypeId,caseCertificationRecordTypeId);
    }
    static testMethod void assignCaseToTransMatching(){
        Id caseTransactionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        Id caseCertificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Certification').getRecordTypeId();
        
        Property2__c prop = new Property2__c();
        prop.Name='90 Alexandria Dr, Mountain House, CA 95391';
        insert prop;
        
        Transaction__c trans = new Transaction__c();
        trans.Transaction_Id__c = 'sfdc1';
        trans.Roofstock_TC_User__c = UserInfo.getUserId();
        trans.Transaction_Status__c ='New';
        trans.Property_Instance__c = prop.Id;
        insert trans;
        
        Case c = new Case();
        c.Origin = 'Email';
        c.Subject = 'test 90 Alexandria Dr, Mountain House, CA 95391 more test string';
        c.Last_Email_Sent_Date__c = System.today()+1;
        c.Last_Email_Received_Date__c = System.today();
        c.Transaction__c = trans.Id;
        insert c;
        
        List<Case> cseList = new List<Case>();
        cseList.add(c);
        CaseHandler.assignCaseToTransCert(cseList,caseTransactionRecordTypeId,caseCertificationRecordTypeId);
    }
    
    static testMethod void assignCaseToCertMatchPropertyName(){
        Id caseTransactionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        Id caseCertificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Certification').getRecordTypeId();
        
        Property2__c prop = new Property2__c();
        prop.Name='90 Alexandria Dr, Mountain House, CA 95391';
        insert prop;
        
        Certification__c cert = new Certification__c();
        cert.BPM_Certification_Id__c = 'sfdc';
        cert.Property__c = prop.Id;
        insert cert;
        
        Case c = new Case();
        c.Origin = 'Email';
        c.Subject = 'test 90 Alexandria Dr, Mountain House, CA 95391 more test string';
        c.Last_Email_Sent_Date__c = System.today()+1;
        c.Last_Email_Received_Date__c = System.today();
        c.Certification__c = cert.Id;
        insert c;
        
        List<Case> cseList = new List<Case>();
        cseList.add(c);
        CaseHandler.assignCaseToTransCert(cseList,caseTransactionRecordTypeId,caseCertificationRecordTypeId);
    }
    
    static testMethod void assignCaseToTransNoBuyerTrans(){
        Id caseTransactionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        Id caseCertificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Certification').getRecordTypeId();
        
        Transaction__c trans = new Transaction__c();
        trans.Transaction_Id__c = 'sfdc1';
        trans.Roofstock_TC_User__c = UserInfo.getUserId();
        trans.Transaction_Status__c ='New';
        insert trans;
        
        Case c = new Case();
        c.Origin = 'Email';
        c.Subject = '[txn:sfdc:txn]';
        c.Last_Email_Sent_Date__c = System.today()+1;
        c.Last_Email_Received_Date__c = System.today();
        c.Transaction__c = trans.Id;
        c.RecordTypeId = caseTransactionRecordTypeId;
        insert c;
        
        List<Case> cseList = new List<Case>();
        cseList.add(c);
        CaseHandler.assignCaseToTransCert(cseList,caseTransactionRecordTypeId,caseCertificationRecordTypeId);
    }
    
    static testMethod void assignCaseToTransNonCaseTrans(){
        Id caseTransactionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        Id caseCertificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Certification').getRecordTypeId();
        
        Transaction__c trans = new Transaction__c();
        trans.Transaction_Id__c = 'sfdc1';
        trans.Roofstock_TC_User__c = UserInfo.getUserId();
        trans.Transaction_Status__c ='New';
        insert trans;
        
        Case c = new Case();
        c.Origin = 'Email';
        c.Subject = '[txn:sfdc:txn]';
        c.Last_Email_Sent_Date__c = System.today()+1;
        c.Last_Email_Received_Date__c = System.today();
        c.Transaction__c = trans.Id;
        //c.RecordTypeId = caseTransactionRecordTypeId;
        insert c;
        
        List<Case> cseList = new List<Case>();
        cseList.add(c);
        CaseHandler.assignCaseToTransCert(cseList,caseTransactionRecordTypeId,caseCertificationRecordTypeId);
    }
    
    static testMethod void updateTransactionCase(){
        Id caseTransactionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        Id caseCertificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Certification').getRecordTypeId();
        
        Transaction__c trans = new Transaction__c();
        trans.Transaction_Id__c = 'sfdc1';
        trans.Roofstock_TC_User__c = UserInfo.getUserId();
        trans.Transaction_Status__c ='New';
        insert trans;
        
        Case c = new Case();
        c.Origin = 'Email';
        c.Subject = '[txn:sfdc:txn]';
        c.Last_Email_Sent_Date__c = System.today()+1;
        c.Last_Email_Received_Date__c = System.today();
        //c.Transaction__c = trans.Id;
        c.RecordTypeId = caseTransactionRecordTypeId;
        c.Assigned_User__c = null;
        insert c;
        
        Case cseUpdate = [Select Id,Transaction__c,RecordTypeId,Origin,Assigned_User__c from Case where Id=:c.Id];
        cseUpdate.Transaction__c = trans.Id;
        update cseUpdate;
        
        List<Case> cseList = new List<Case>();
        cseList.add(cseUpdate);
        Map<Id,Case> caseMap = new Map<Id,Case>();
        caseMap.put(c.Id,c);
        
        CaseHandler.updateTransactionCase(cseList,caseMap);
    }
    
    static testMethod void assignCaseToTransUnMatched(){
        Id caseTransactionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        Id caseCertificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Certification').getRecordTypeId();
        
        Property2__c prop = new Property2__c();
        prop.Name='90 Alexandria Dr, Mountain House, CA 95391';
        insert prop;
        
        Transaction__c trans = new Transaction__c();
        trans.Transaction_Id__c = 'sfdc1';
        trans.Roofstock_TC_User__c = UserInfo.getUserId();
        trans.Transaction_Status__c ='New';
        trans.Property_Instance__c = prop.Id;
        insert trans;
        
        Case c = new Case();
        c.Origin = 'Email';
        c.Subject = 'test 90 Alexandria Dr, Mountain House, CA 95391 more test string';
        c.Last_Email_Sent_Date__c = System.today()+1;
        c.Last_Email_Received_Date__c = System.today();
        c.Transaction__c = trans.Id;
        c.RecordTypeId = caseTransactionRecordTypeId;
        insert c;
        
        List<Case> cseList = new List<Case>();
        cseList.add(c);
        CaseHandler.assignCaseToTransCert(cseList,caseTransactionRecordTypeId,caseCertificationRecordTypeId);
    }
    
    static testMethod void caseDelete(){
        
        Case c = new Case();
        c.Origin = 'Email';
        c.Subject = 'Slow new';
        insert c;
        
        Case cse = [select Id from Case where Id=:c.Id];
        delete cse;
    }
    
    static testMethod void populateCaseAgeHoursTest() {
        
        Id caseTransactionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        Id caseCertificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Certification').getRecordTypeId();
        
        Transaction__c trans = new Transaction__c();
        trans.Transaction_Id__c = 'sfdc1';
        trans.Roofstock_TC_User__c = UserInfo.getUserId();
        trans.Transaction_Status__c ='New';
        insert trans;
        
        Case c = new Case();
        c.Origin = 'Email';
        c.Subject = '[txn:sfdc:txn]';
        c.Last_Email_Sent_Date__c = System.today()+1;
        c.Last_Email_Received_Date__c = System.today();
        //c.Transaction__c = trans.Id;
        c.RecordTypeId = caseTransactionRecordTypeId;
        c.Assigned_User__c = null;
        insert c;
        
        Case cseUpdate = [Select Id, isClosed, Status, CreatedDate, ClosedDate from Case where Id=:c.Id];
        cseUpdate.Status = 'Closed';
        update cseUpdate;
        
        List<Case> cseList = new List<Case>();
        cseList.add(cseUpdate);
        
        CaseHandler.populateCaseAgeHours(cseList);
    }
    
}
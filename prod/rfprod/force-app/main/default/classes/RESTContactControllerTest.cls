@isTest
public class RESTContactControllerTest {
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void RESTContactControllerTestMatchingBPMContactId() {
        Id leadBuyerRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        
        Id rsContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Inspector').getRecordTypeId();
        Lead l = new Lead();
        l.LastName = 'sfdc';
        l.Company = 'sfdc';
        l.Email = 'T@nowhere.com';
        l.RecordTypeId = leadBuyerRecordTypeId;
        insert l;
        Account a = new Account(Name = 'TestAccount');
        a.Roofstock_Account_ID__c = '33434';
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test@nowhere.com',
            BPM_Contact_Id__c = '3433345',
            HasOptedOutOfEmail =false,
            RecordTypeId = rsContact,
            AccountId = a.Id
        );
        insert c;
        List<RESTContactHelper.Contacts> requestContactList = new List<RESTContactHelper.Contacts>();
        RESTContactHelper.Contacts requestContact = new RESTContactHelper.Contacts();
        requestContact.bpmContactId = '3433345';
        requestContact.rsAccountId = '33434';
        requestContact.type = 'Buyer';
        requestContact.email = 'T@nowhere.com';
        requestContact.phone = '2343343';
        requestContact.mobile = '343343434';
        requestContact.firstName = 'sree';
        requestContact.lastName = 'meonno';
        requestContact.companyName = 'xyz company';
        requestContact.isQualifiedRetailBuyer = true;
        requestContact.firstQualifiedRetailBuyerDate = System.Today();
        requestContact.lastQualifiedRetailBuyerDate = System.Today();
        requestContactList.add(requestContact);
        
        RESTContactHelper.ContactsWrap conRequest = new RESTContactHelper.ContactsWrap();
        conRequest.ContactList = requestContactList;
        String sReq = JSON.serialize(conRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/updateTransaction';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTContactController.updateContact();
        Test.stopTest();
    }
    
    static testMethod void RESTContactControllerTestMatchingEmailId() {
        Id rsContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Inspector').getRecordTypeId();
        Account a = new Account(Name = 'TestAccount');
        a.Roofstock_Account_ID__c = '33434';
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'test@nowhere.com',
            BPM_Contact_Id__c = '',
            RecordTypeId = rsContact,
            HasOptedOutOfEmail =false,
            AccountId = a.Id
        );
        insert c;
        List<RESTContactHelper.Contacts> requestContactList = new List<RESTContactHelper.Contacts>();
        RESTContactHelper.Contacts requestContact = new RESTContactHelper.Contacts();
        requestContact.bpmContactId = '34345';
        requestContact.rsAccountId = '33434';
        requestContact.roofstockUserId ='1234';
        requestContact.type = 'Buyer';
        requestContact.email = 'Test@nowhere.com';
        requestContact.phone = '2343343';
        requestContact.mobile = '343343434';
        requestContact.firstName = 'sree';
        requestContact.lastName = 'meonno';
        requestContact.companyName = 'xyz company';
        
        requestContact.isQualifiedRetailBuyer = true;
        requestContact.firstQualifiedRetailBuyerDate = System.Today();
        requestContact.lastQualifiedRetailBuyerDate = System.Today();
        
        requestContactList.add(requestContact);
        
        RESTContactHelper.ContactsWrap conRequest = new RESTContactHelper.ContactsWrap();
        conRequest.ContactList = requestContactList;
        String sReq = JSON.serialize(conRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/updateTransaction';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTContactController.updateContact();
        Test.stopTest();
    }
    static testMethod void RESTContactControllerTestWithMatchingPhone() {
        Id rsContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Inspector').getRecordTypeId();
        Account a = new Account(Name = 'TestAccount');
        a.Roofstock_Account_ID__c = '33434';
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test12@nowhere.com',
            Phone='9741733159',
            BPM_Contact_Id__c = '',
            HasOptedOutOfEmail =false,
            RecordTypeId = rsContact,
            AccountId = a.Id
        );
        insert c;
        List<RESTContactHelper.Contacts> requestContactList = new List<RESTContactHelper.Contacts>();
        RESTContactHelper.Contacts requestContact = new RESTContactHelper.Contacts();
        requestContact.bpmContactId = '3434345';
        requestContact.rsAccountId = '33434';
        requestContact.type = 'Buyer';
        requestContact.email = 'sree@gmail.com';
        requestContact.phone = '9741733159';
        requestContact.mobile = '9741733159';
        requestContact.firstName = 'sree';
        requestContact.lastName = 'meonno';
        requestContact.companyName = 'xyz company';
        
        requestContact.isQualifiedRetailBuyer = true;
        requestContact.firstQualifiedRetailBuyerDate = System.Today();
        requestContact.lastQualifiedRetailBuyerDate = System.Today();
        
        requestContactList.add(requestContact);
        
        //String sReq = JSON.serialize(requestContact);
        RESTContactHelper.ContactsWrap conRequest = new RESTContactHelper.ContactsWrap();
        conRequest.ContactList = requestContactList;
        String sReq = JSON.serialize(conRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/updateTransaction';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTContactController.updateContact();
        Test.stopTest();
    }
    static testMethod void RESTContactControllerTestWithMatchingMobile() {
        Id rsContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Inspector').getRecordTypeId();
        Account a = new Account(Name = 'TestAccount');
        a.Roofstock_Account_ID__c = '33434';
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test123@nowhere.com',
            Phone='7741733159',
            MobilePhone = '9741733159',
            BPM_Contact_Id__c = '',
            HasOptedOutOfEmail =false,
            RecordTypeId = rsContact,
            AccountId = a.Id
        );
        insert c;
        List<RESTContactHelper.Contacts> requestContactList = new List<RESTContactHelper.Contacts>();
        RESTContactHelper.Contacts requestContact = new RESTContactHelper.Contacts();
        requestContact.bpmContactId = '3434345';
        requestContact.rsAccountId = '33434';
        requestContact.type = 'Buyer';
        requestContact.email = 'sree@gmail.com';
        requestContact.phone = '8765655456';
        requestContact.mobile = '9741733159';
        requestContact.firstName = 'sree';
        requestContact.lastName = 'meonno';
        requestContact.companyName = 'xyz company';
        
        requestContact.isQualifiedRetailBuyer = true;
        requestContact.firstQualifiedRetailBuyerDate = System.Today();
        requestContact.lastQualifiedRetailBuyerDate = System.Today();
        
        requestContactList.add(requestContact);
        
        //String sReq = JSON.serialize(requestContact);
        RESTContactHelper.ContactsWrap conRequest = new RESTContactHelper.ContactsWrap();
        conRequest.ContactList = requestContactList;
        String sReq = JSON.serialize(conRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/updateTransaction';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTContactController.updateContact();
        Test.stopTest();
    }
    static testMethod void RESTContactControllerTestWithMatchingRsAccountId() {
        Id rsContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Inspector').getRecordTypeId();
        Account a = new Account(Name = 'TestAccount');
        a.Roofstock_Account_ID__c = '33434';
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test1231@nowhere.com',
            Phone='7741733188',
            MobilePhone = '9741663159',
            BPM_Contact_Id__c = '',
            HasOptedOutOfEmail =false,
            RecordTypeId = rsContact,
            AccountId = a.Id
        );
        insert c;
        List<RESTContactHelper.Contacts> requestContactList = new List<RESTContactHelper.Contacts>();
        RESTContactHelper.Contacts requestContact = new RESTContactHelper.Contacts();
        requestContact.bpmContactId = '3434345';
        requestContact.rsAccountId = '33434';
        requestContact.type = 'Buyer';
        requestContact.email = 'sree@gmail.com';
        requestContact.phone = '8765655456';
        requestContact.mobile = '9741733159';
        requestContact.firstName = 'sree';
        requestContact.lastName = 'meonno';
        requestContact.companyName = 'xyz company';
        
        requestContact.isQualifiedRetailBuyer = true;
        requestContact.firstQualifiedRetailBuyerDate = System.Today();
        requestContact.lastQualifiedRetailBuyerDate = System.Today();
        
        requestContactList.add(requestContact);
        
        //String sReq = JSON.serialize(requestContact);
        RESTContactHelper.ContactsWrap conRequest = new RESTContactHelper.ContactsWrap();
        conRequest.ContactList = requestContactList;
        String sReq = JSON.serialize(conRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/updateTransaction';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTContactController.updateContact();
        Test.stopTest();
    }
    static testMethod void RESTContactControllerTestWithMatchingNoMatch() {
        Id rsContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Inspector').getRecordTypeId();
        Account a = new Account(Name = 'TestAccount');
        a.Phone = '9741663159';
        a.Roofstock_Account_ID__c = '332434';
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test1231@nowhere.com',
            Phone='7741733188',
            MobilePhone = '9741663159',
            BPM_Contact_Id__c = '',
            HasOptedOutOfEmail =false,
            RecordTypeId = rsContact,
            AccountId = a.Id
        );
        insert c;
        List<RESTContactHelper.Contacts> requestContactList = new List<RESTContactHelper.Contacts>();
        RESTContactHelper.Contacts requestContact = new RESTContactHelper.Contacts();
        requestContact.bpmContactId = '3434345';
        requestContact.rsAccountId = '33434';
        requestContact.type = 'Buyer';
        requestContact.email = 'sree@gmail.com';
        requestContact.phone = '8765655456';
        requestContact.mobile = '9741733159';
        requestContact.firstName = 'sree';
        requestContact.lastName = 'meonno';
        requestContact.companyName = 'xyz company';
        
        requestContact.isQualifiedRetailBuyer = true;
        requestContact.firstQualifiedRetailBuyerDate = System.Today();
        requestContact.lastQualifiedRetailBuyerDate = System.Today();
        
        requestContactList.add(requestContact);
        
        //String sReq = JSON.serialize(requestContact);
        RESTContactHelper.ContactsWrap conRequest = new RESTContactHelper.ContactsWrap();
        conRequest.ContactList = requestContactList;
        String sReq = JSON.serialize(conRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/updateTransaction';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTContactController.updateContact();
        Test.stopTest();
    }
    static testMethod void RESTContactControllerTestWithMatchingAccountPhone() {
        Id rsContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Inspector').getRecordTypeId();
        Id rsAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Inspector').getRecordTypeId();
        Account a = new Account(Name = 'TestAccount');
        a.RecordTypeId = rsAccount;
        a.Phone = '9741733159';
        a.Roofstock_Account_ID__c = '332434';
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test123112@nowhere.com',
            Phone='3433434454',
            MobilePhone = '2323454345',
            BPM_Contact_Id__c = '',
            HasOptedOutOfEmail =false,
            RecordTypeId = rsContact,
            AccountId = a.Id
        );
        insert c;
        List<RESTContactHelper.Contacts> requestContactList = new List<RESTContactHelper.Contacts>();
        RESTContactHelper.Contacts requestContact = new RESTContactHelper.Contacts();
        requestContact.bpmContactId = '3434345';
        requestContact.rsAccountId = '33434';
        requestContact.type = 'Buyer';
        requestContact.email = 'sree@gmail.com';
        requestContact.phone = '8765655456';
        requestContact.mobile = '9741733159';
        requestContact.firstName = 'sree';
        requestContact.lastName = 'meonno';
        requestContact.companyName = 'xyz company';
        
        requestContact.isQualifiedRetailBuyer = true;
        requestContact.firstQualifiedRetailBuyerDate = System.Today();
        requestContact.lastQualifiedRetailBuyerDate = System.Today();
        
        requestContactList.add(requestContact);
        
        // String sReq = JSON.serialize(requestContact);
        RESTContactHelper.ContactsWrap conRequest = new RESTContactHelper.ContactsWrap();
        conRequest.ContactList = requestContactList;
        String sReq = JSON.serialize(conRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/updateTransaction';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTContactController.updateContact();
        Test.stopTest();
    }
    
    static testMethod void RESTContactControllerTestWithException() {
        try{
            Id rsContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Inspector').getRecordTypeId();
            Id rsAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Inspector').getRecordTypeId();
            Account a = new Account(Name = 'TestAccount');
            a.RecordTypeId = rsAccount;
            a.Phone = '9741733159';
            a.Roofstock_Account_ID__c = '332434';
            insert a;
            Contact c = new Contact(
                firstname = 'Test',
                lastname = 'Test',
                email= 'Test123112@nowhere.com',
                Phone='3433434454',
                MobilePhone = '2323454345',
                BPM_Contact_Id__c = '',
                HasOptedOutOfEmail =false,
                RecordTypeId = rsContact,
                AccountId = a.Id
            );
            insert c;
            List<RESTContactHelper.Contacts> requestContactList = new List<RESTContactHelper.Contacts>();
            RESTContactHelper.Contacts requestContact = new RESTContactHelper.Contacts();
            requestContact.bpmContactId = '3434345';
            requestContact.rsAccountId = '33434';
            requestContact.type = 'Buyer';
            requestContact.email = 'sree@gmail.com';
            requestContact.phone = '8765655456';
            requestContact.mobile = '9741733159';
            requestContact.firstName = 'sree';
            requestContact.lastName = 'meonno';
            requestContact.companyName = 'xyz company';
            
            requestContact.isQualifiedRetailBuyer = true;
            requestContact.firstQualifiedRetailBuyerDate = System.Today();
            requestContact.lastQualifiedRetailBuyerDate = System.Today();
            
            requestContactList.add(requestContact);
            
            // String sReq = JSON.serialize(requestContact);
            RESTContactHelper.ContactsWrap conRequest = new RESTContactHelper.ContactsWrap();
            conRequest.ContactList = requestContactList;
            String sReq = JSON.serialize(requestContactList);
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/updateTransaction';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(sReq);
            RestContext.request = req;
            RestContext.response = res;
            Test.startTest();
            RESTContactController.updateContact();
            Test.stopTest();
        }
        catch(Exception ex){
            
        }
    }
    static testMethod void RESTContactControllerTestWithMatchingLeads() {
        Id leadBuyerRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();        
        Account acc = new Account();
        acc.name='sfdc';
        insert acc;
        
        Lead l = new Lead();
        l.LastName = 'sfdc';
        l.Company = 'sfdc';
        l.Email = 't@nowhere.com';
        l.RecordTypeId = leadBuyerRecordTypeId;
                l.No_Convert_Reason__c = 'New';

        insert l;
        
        Map<String,String> leadAccountMap = new Map<String,String>();
        leadAccountMap.put(l.Id,acc.Id);
        
        Contact con = new Contact();
        con.LastName = 'sfdc';
        con.Email = 't@nowhere.com';
        con.AccountId = acc.Id;
        insert con;
        List<Contact> conList = new List<Contact>();
        conList.add(con);
       
       
        List<RESTContactHelper.Contacts> requestContactList = new List<RESTContactHelper.Contacts>();
        RESTContactHelper.Contacts requestContact = new RESTContactHelper.Contacts();
        requestContact.bpmContactId = '3434345';
        requestContact.rsAccountId = '33434';
        requestContact.type = 'Buyer';
        requestContact.email = 't@nowhere.com';
        requestContact.phone = '8765655456';
        requestContact.mobile = '9741733159';
        requestContact.firstName = 'sree';
        requestContact.lastName = 'meonno';
        requestContact.companyName = 'xyz company';
        
        requestContact.isQualifiedRetailBuyer = true;
        requestContact.firstQualifiedRetailBuyerDate = Date.Today();
        requestContact.lastQualifiedRetailBuyerDate = Date.Today();
        
        requestContactList.add(requestContact);
        
        Map<String,RESTContactHelper.Contacts> leadContactsMap = new Map<String,RESTContactHelper.Contacts>();
        leadContactsMap.put(l.Id,requestContact);
        // String sReq = JSON.serialize(requestContact);
        RESTContactHelper.ContactsWrap conRequest = new RESTContactHelper.ContactsWrap();
        conRequest.ContactList = requestContactList;
        String sReq = JSON.serialize(conRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/updateTransaction';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        Map<String,RESTContactHelper.Contacts> inputStringEmailMap = new Map<String,RESTContactHelper.Contacts>();
        inputStringEmailMap.put('t@nowhere.com',requestContact);
        
        Map<String,RESTContactHelper.Contacts> inputStringphoneMap = new Map<String,RESTContactHelper.Contacts>();
        inputStringphoneMap.put('4534233456',requestContact);
        
        RESTContactController.updateContact();
       // RESTContactHelper.updateContact(conList,inputStringEmailMap,inputStringphoneMap);
        //RESTContactHelper.updateAccounts(conList,inputStringEmailMap,inputStringphoneMap);
        RESTContactHelper.convertExistingLead(leadAccountMap,leadContactsMap);
        Test.stopTest();
    }
    static testMethod void RESTContactControllerTestRetailBuyer() {
        Id leadBuyerRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        
        Id rsContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Inspector').getRecordTypeId();
        Lead l = new Lead();
        l.LastName = 'sfdc';
        l.Company = 'sfdc';
        l.Email = 'T@nowhere.com';
        l.RecordTypeId = leadBuyerRecordTypeId;
        insert l;
        Account a = new Account(Name = 'TestAccount');
        a.Roofstock_Account_ID__c = '33434';
        insert a;
        Account a2 = new Account(Name = 'TestAccount');
        a2.Roofstock_Account_ID__c = '3343433';
        insert a2;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test@nowhere.com',
            BPM_Contact_Id__c = '3433345',
            HasOptedOutOfEmail =false,
            RecordTypeId = rsContact,
            AccountId = a.Id
        );
        insert c;
        Contact c2 = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test@nowhere.com',
            BPM_Contact_Id__c = '3433345',
            HasOptedOutOfEmail =false,
            RecordTypeId = rsContact,
            AccountId = a2.Id
        );
        insert c2;
        List<RESTContactHelper.Contacts> requestContactList = new List<RESTContactHelper.Contacts>();
        RESTContactHelper.Contacts requestContact = new RESTContactHelper.Contacts();
        requestContact.bpmContactId = '3433345';
        requestContact.rsAccountId = '33434';
        requestContact.type = 'Buyer';
        requestContact.email = 'T@nowhere.com';
        requestContact.phone = '2343343';
        requestContact.mobile = '343343434';
        requestContact.firstName = 'sree';
        requestContact.lastName = 'meonno';
        requestContact.companyName = 'xyz company';
        requestContact.isQualifiedRetailBuyer = true;
        requestContact.firstQualifiedRetailBuyerDate = Date.Today();
        requestContact.lastQualifiedRetailBuyerDate = Date.Today();
        requestContactList.add(requestContact);
        
        RESTContactHelper.ContactsWrap conRequest = new RESTContactHelper.ContactsWrap();
        conRequest.ContactList = requestContactList;
        String sReq = JSON.serialize(conRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/updateContact';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTContactController.updateContact();
        Test.stopTest();
    }
    static testMethod void RESTContactControllerTestRetailBuyer2() {
        Id leadBuyerRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        
        Id rsContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Inspector').getRecordTypeId();
        Lead l = new Lead();
        l.LastName = 'sfdc';
        l.Company = 'sfdc';
        l.Email = 'T@nowhere.com';
        l.RecordTypeId = leadBuyerRecordTypeId;
        insert l;
        Account a = new Account(Name = 'TestAccount');
        a.Roofstock_Account_ID__c = '';
        insert a;
        Account a2 = new Account(Name = 'TestAccount');
        a2.Roofstock_Account_ID__c = '';
        insert a2;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test@nowhere.com',
            BPM_Contact_Id__c = '3433345',
            HasOptedOutOfEmail =false,
            RecordTypeId = rsContact,
            AccountId = a.Id
        );
        insert c;
        Contact c2 = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test@nowhere.com',
            BPM_Contact_Id__c = '3433345',
            HasOptedOutOfEmail =false,
            RecordTypeId = rsContact,
            AccountId = a2.Id
        );
        insert c2;
        List<RESTContactHelper.Contacts> requestContactList = new List<RESTContactHelper.Contacts>();
        RESTContactHelper.Contacts requestContact = new RESTContactHelper.Contacts();
        requestContact.bpmContactId = '3433345';
        requestContact.rsAccountId = '33434';
        requestContact.type = 'Buyer';
        requestContact.email = 'T@nowhere.com';
        requestContact.phone = '2343343';
        requestContact.mobile = '343343434';
        requestContact.firstName = 'sree';
        requestContact.lastName = 'meonno';
        requestContact.companyName = 'xyz company';
        requestContact.isQualifiedRetailBuyer = true;
        requestContact.firstQualifiedRetailBuyerDate = Date.Today();
        requestContact.lastQualifiedRetailBuyerDate = Date.Today();
        requestContactList.add(requestContact);
        
        RESTContactHelper.ContactsWrap conRequest = new RESTContactHelper.ContactsWrap();
        conRequest.ContactList = requestContactList;
        String sReq = JSON.serialize(conRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/updateContact';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        RESTContactController.updateContact();
        Test.stopTest();
    }
}
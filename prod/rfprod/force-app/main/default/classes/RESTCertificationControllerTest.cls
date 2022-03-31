@isTest
public class RESTCertificationControllerTest {
                  static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void RESTTransactionControllerTest() {
        Account a = new Account(Name = 'TestAccount');
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test@nowhere.com',
            BPM_Contact_Id__c = '12345',
            HasOptedOutOfEmail =false,
            AccountId = a.Id
        );
        insert c;
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyId__c = '12345';
        p.PropertyCode__c = 'q1000';
        p.Property_Type__c = 'Single Family';
        p.Year_Built__c = '1972';
        p.name = '123 Main St Tracy CA 95391';
        p.Roofstock_Instance_Id__c = '12345';
        insert p;
        
        List<RESTCertificationHelper.Certifications> certificationList = new List<RESTCertificationHelper.Certifications>();
        RESTCertificationHelper.Certifications contextCertification= new RESTCertificationHelper.Certifications();
        contextCertification.name='CER-20205 | 6825 Brittany Pl, Pinson, AL';
        contextCertification.certificationId = '12345';
        contextCertification.propertyId = '12345';
      /*  contextCertification.sellerContactId = '12345';
        contextCertification.inspectorContactId = '12345';
        contextCertification.sellerPmContactId = '12345';
        contextCertification.titleContactId = '12345';
        contextCertification.hoaContactId = '12345';
        contextCertification.rsListingAgentContactId = '12345';*/
        contextCertification.rsAccountExecutiveEmail = 'chidanand.magadum@roofstock.com';
        contextCertification.rsAccountManagerEmail = 'chidanand.magadum@roofstock.com';
        contextCertification.rsAccountCoordinatorEmail = 'chidanand.magadum@roofstock.com';
        contextCertification.certificationStatus = 'New';
        contextCertification.certificationStartDate = '2222-11-11';
        contextCertification.estPublishedDate = '2222-11-11';
        contextCertification.publishDate = '2222-11-11';
        contextCertification.listingSource = 'dontlnwo';
        contextCertification.saleType = 'Direct';
        contextCertification.listingAddendumStatus = 'something';
        
        List<RESTContactHelper.Contacts> conList = new List<RESTContactHelper.Contacts>();
        RESTContactHelper.Contacts con1 = new RESTContactHelper.Contacts();
        con1.bpmContactId = '12345';
        con1.type = 'Title';
        con1.email = 'abc@gmail.com';
        con1.phone = '6754678987';
        con1.firstName = 'First Name';
        con1.lastName = 'Last Name';
        conList.add(con1);
        RESTContactHelper.Contacts con2 = new RESTContactHelper.Contacts();
        con2.bpmContactId = '12345';
        con2.type = 'Seller';
        con2.email = 'abc@gmail.com';
        con2.phone = '6754678987';
        con2.firstName = 'First Name';
        con2.lastName = 'Last Name';
        conList.add(con2);
        RESTContactHelper.Contacts con3 = new RESTContactHelper.Contacts();
        con3.bpmContactId = '12345';
        con3.type = 'Inspector';
        con3.email = 'abc@gmail.com';
        con3.phone = '6754678987';
        con3.firstName = 'First Name';
        con3.lastName = 'Last Name';
        conList.add(con3);
        RESTContactHelper.Contacts con4 = new RESTContactHelper.Contacts();
        con4.bpmContactId = '12345';
        con4.type = 'PM Buyer';
        con4.email = 'abc@gmail.com';
        con4.phone = '6754678987';
        con4.firstName = 'First Name';
        con4.lastName = 'Last Name';
        conList.add(con4);
        contextCertification.contactsList = conList;
        
        certificationList.add(contextCertification);
        
        RESTCertificationHelper.certificationsWrap certRequest = new RESTCertificationHelper.certificationsWrap();
        certRequest.certificationList = certificationList;
        String sReq = JSON.serialize(certRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/updateCertification';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTCertificationController.updateCertification();
        Test.stopTest();
        
    }
    static testMethod void RESTTransactionControllerExceptionTest() {
     /*   Account a = new Account(Name = 'TestAccount');
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test@nowhere.com',
            BPM_Contact_Id__c = '12345',
            HasOptedOutOfEmail =false,
            AccountId = a.Id
        );
        insert c;
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyId__c = '12345';
        p.PropertyCode__c = 'q1000';
        p.Property_Type__c = 'Single Family';
        p.Year_Built__c = 1972;
        p.name = '123 Main St Tracy CA 95391';
        p.Roofstock_Instance_Id__c = '12345';
        insert p;
        */
        try{
        List<RESTCertificationHelper.Certifications> certificationList = new List<RESTCertificationHelper.Certifications>();
        RESTCertificationHelper.Certifications contextCertification= new RESTCertificationHelper.Certifications();
        contextCertification.name='CER-20205 | 6825 Brittany Pl, Pinson, AL';
        contextCertification.certificationId = '12345';
        contextCertification.propertyId = '12345';
       /* contextCertification.sellerContactId = '12345';
        contextCertification.inspectorContactId = '12345';
        contextCertification.sellerPmContactId = '12345';
        contextCertification.titleContactId = '12345';
        contextCertification.hoaContactId = '12345';
        contextCertification.rsListingAgentContactId = '12345';*/
            
        contextCertification.rsAccountExecutiveEmail = 'chidanand.magadum@roofstock.com';
        contextCertification.rsAccountManagerEmail = 'chidanand.magadum@roofstock.com';
        contextCertification.rsAccountCoordinatorEmail = 'chidanand.magadum@roofstock.com';
        contextCertification.certificationStatus = 'New';
        contextCertification.certificationStartDate = '2222-11-11';
        contextCertification.estPublishedDate = '2222-11-11';
        contextCertification.publishDate = '2222-11-11';
        contextCertification.listingSource = 'dontlnwo';
        contextCertification.saleType = 'Direct';
        contextCertification.listingAddendumStatus = 'something';
            
        List<RESTContactHelper.Contacts> conList = new List<RESTContactHelper.Contacts>();
        RESTContactHelper.Contacts con1 = new RESTContactHelper.Contacts();
        con1.bpmContactId = '12345';
        con1.type = 'Title';
        con1.email = 'abc@gmail.com';
        con1.phone = '6754678987';
        con1.firstName = 'First Name';
        con1.lastName = 'Last Name';
        conList.add(con1);
        RESTContactHelper.Contacts con2 = new RESTContactHelper.Contacts();
        con2.bpmContactId = '12345';
        con2.type = 'Seller';
        con2.email = 'abc@gmail.com';
        con2.phone = '6754678987';
        con2.firstName = 'First Name';
        con2.lastName = 'Last Name';
        conList.add(con2);
        RESTContactHelper.Contacts con3 = new RESTContactHelper.Contacts();
        con3.bpmContactId = '12345';
        con3.type = 'HOA';
        con3.email = 'abc@gmail.com';
        con3.phone = '6754678987';
        con3.firstName = 'First Name';
        con3.lastName = 'Last Name';
        conList.add(con3);
        RESTContactHelper.Contacts con4 = new RESTContactHelper.Contacts();
        con4.bpmContactId = '12345';
        con4.type = 'PM Buyer';
        con4.email = 'abc@gmail.com';
        con4.phone = '6754678987';
        con4.firstName = 'First Name';
        con4.lastName = 'Last Name';
        conList.add(con4);
        contextCertification.contactsList = conList;
            
        certificationList.add(contextCertification);
        
       // RESTCertificationHelper.certificationsWrap certRequest = new RESTCertificationHelper.certificationsWrap();
        //certRequest.certificationList = certificationList;
        String sReq = JSON.serialize(certificationList);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/updateCertification';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTCertificationController.updateCertification();
        Test.stopTest();
        }
        catch(Exception ex){
            
        }
    }
}
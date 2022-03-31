@isTest
public class RESTTransactionControllerTest {
    
    static { 
        
        TestDataFactory.insertHierarchyCustomSettingData();
        TestDataFactory.createTestUserRecords(2);
    }
    static testMethod void RESTTransactionControllerTestNoMatch() {
        Account a = new Account(Name = 'TestAccount', Roofstock_Account_Id__c = '12345');
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test@nowhere.com',
            BPM_Contact_Id__c = '123',
            HasOptedOutOfEmail =false,
            AccountId = a.Id
        );
        insert c;
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.Property_Type__c = 'Single Family';
        //p.Year_Built__c = 1972;
        p.name = '123 Main St Tracy CA 95391';
        p.PropertyId__c = '123458';
        p.Roofstock_Instance_Id__c = '123458';
        insert p;
        
        List<RESTContactHelper.Contacts> conList = new List<RESTContactHelper.Contacts>();
        RESTContactHelper.Contacts con1 = new RESTContactHelper.Contacts();
        con1.bpmContactId = '123';
        con1.type = 'Buyer';
        con1.rsAccountId = '12345';
        con1.email = 'abc@gmail.com';
        con1.phone = '6754678987';
        con1.firstName = 'First Name';
        con1.lastName = 'Last Name';
        conList.add(con1);
        RESTContactHelper.Contacts con2 = new RESTContactHelper.Contacts();
        con2.bpmContactId = '123';
        con2.type = 'Seller';
        con2.rsAccountId = '12345';
        con2.email = 'abc@gmail.com';
        con2.phone = '6754678987';
        con2.firstName = 'First Name';
        con2.lastName = 'Last Name';
        conList.add(con2);
        RESTContactHelper.Contacts con3 = new RESTContactHelper.Contacts();
        con3.bpmContactId = '123';
        con3.type = 'Inspector';
        con3.rsAccountId = '12345';
        con3.email = 'abc@gmail.com';
        con3.phone = '6754678987';
        con3.firstName = 'First Name';
        con3.lastName = 'Last Name';
        conList.add(con3);
        RESTContactHelper.Contacts con4 = new RESTContactHelper.Contacts();
        con4.bpmContactId = '123';
        con4.type = 'PM Buyer';
        con4.email = 'abc@gmail.com';
        con4.phone = '6754678987';
        con4.firstName = 'First Name';
        con4.lastName = 'Last Name';
        conList.add(con4);
        RESTContactHelper.Contacts con5 = new RESTContactHelper.Contacts();
        con5.bpmContactId = '123';
        con5.type = 'PM Seller';
        con5.email = 'abc@gmail.com';
        con5.phone = '6754678987';
        con5.firstName = 'First Name';
        con5.lastName = 'Last Name';
        conList.add(con5);
        RESTContactHelper.Contacts con6 = new RESTContactHelper.Contacts();
        con6.bpmContactId = '123';
        con6.type = 'Escrow';
        con6.email = 'abc@gmail.com';
        con6.phone = '6754678987';
        con6.firstName = 'First Name';
        con6.lastName = 'Last Name';
        conList.add(con6);
        RESTContactHelper.Contacts con7 = new RESTContactHelper.Contacts();
        con7.bpmContactId = '123';
        con7.type = 'Title';
        con7.email = 'abc@gmail.com';
        con7.phone = '6754678987';
        con7.firstName = 'First Name';
        con7.lastName = 'Last Name';
        conList.add(con7);
        RESTContactHelper.Contacts con8 = new RESTContactHelper.Contacts();
        con8.bpmContactId = '123';
        con8.type = 'Insurance';
        con8.email = 'abc@gmail.com';
        con8.phone = '6754678987';
        con8.firstName = 'First Name';
        con8.lastName = 'Last Name';
        conList.add(con8);
        RESTContactHelper.Contacts con9 = new RESTContactHelper.Contacts();
        con9.bpmContactId = '123';
        con9.type = 'Lendor';
        con9.email = 'abc@gmail.com';
        con9.phone = '6754678987';
        con9.firstName = 'First Name';
        con9.lastName = 'Last Name';
        conList.add(con9);
        RESTContactHelper.Contacts con10 = new RESTContactHelper.Contacts();
        con10.bpmContactId = '123';
        con10.type = 'Broker Buyer';
        con10.rsAccountId = '12345';
        con10.email = 'abc@gmail.com';
        con10.phone = '6754678987';
        con10.firstName = 'First Name';
        con10.lastName = 'Last Name';
        conList.add(con10);
        RESTContactHelper.Contacts con11 = new RESTContactHelper.Contacts();
        con11.bpmContactId = '123';
        con11.type = 'Broker Seller';
        con11.rsAccountId = '12345';
        con11.email = 'abc@gmail.com';
        con11.phone = '6754678987';
        con11.firstName = 'First Name';
        con11.lastName = 'Last Name';
        conList.add(con11);
        
        
        List<RESTTransactionHelper.Transactions> transactionList = new List<RESTTransactionHelper.Transactions>();
        RESTTransactionHelper.Transactions contextTransaction = new RESTTransactionHelper.Transactions();
        contextTransaction.name = 'TRN-20205 | 6825 Brittany Pl, Pinson, AL';
        contextTransaction.address = '10805 N 17th Drive Unit 1';
        contextTransaction.portfolioTransactionId = '1234';
        contextTransaction.transactionId ='123458';
        contextTransaction.buyerPropertyId ='123458';
        contextTransaction.sellerPropertyId = '123458';
        contextTransaction.listingId ='123458';
        contextTransaction.offerId = '1234';
        contextTransaction.status = 'Open';
        contextTransaction.salePrice = '1234';
        contextTransaction.listPrice = '1234';
        contextTransaction.propertyType = 'bla';
        contextTransaction.createdDate = String.valueOf(System.Today());
        contextTransaction.startDate = String.valueOf(System.Today());
        contextTransaction.inContractDate = String.valueOf(System.Today());
        contextTransaction.estimatedCloseDate = String.valueOf(System.Today());
        contextTransaction.escrowCloseDate = String.valueOf(System.Today());
        contextTransaction.contingencyExpirationDate = String.valueOf(System.Today());
        contextTransaction.isContingency = true;
        contextTransaction.cancellationDate = String.valueOf(System.Today());
        contextTransaction.appraisalExpirationDate = String.valueOf(System.Today());
        contextTransaction.transactionCordinatorEmail = 'TestUser1@roofstock.com';
        contextTransaction.customerServiceEmail = 'TestUser2@roofstock.com';
        contextTransaction.inventoryEmail = 'TestUser1@roofstock.com';
        contextTransaction.accountManagerEmail = 'TestUser1@roofstock.com';
        contextTransaction.accountingEmail = 'TestUser1@roofstock.com';
        contextTransaction.projectManagerEmail = 'TestUser1@roofstock.com';
       /* contextTransaction.buyerContactId1 = '123';
        contextTransaction.buyerContactId2 = '123';
        contextTransaction.sellerContactId = '123';
        contextTransaction.inspectorContactId = '123';
        contextTransaction.financingType = 'sfdc';
        //contextTransaction.pmContactId = '123';
        contextTransaction.pmBuyerContactid = '123';
        contextTransaction.pmSellerContactId = '123';
        contextTransaction.escrowContactId = '123';
        contextTransaction.titleContactId = '123';
        contextTransaction.insuranceContactId = '123';
        contextTransaction.lendorContactId = '123';
        contextTransaction.buyerBrokerContactId = '123';
        contextTransaction.sellerBrokerContactId = '123';*/
        
        contextTransaction.underwritingAnalystEmail = 'chidanand.magadum@roofstock.com';
        contextTransaction.buyerEntity = 'SFDC';
        contextTransaction.roofstockAdvisorEmail = 'chidanand.magadum@roofstock.com';
        //contextTransaction.roofstockInventoryOwnerEmail = 'chidanand.magadum@roofstock.com';
        contextTransaction.transactionType = 'Completed';
        contextTransaction.scheduledInspectionDate = '10/14/2011 11:46 AM';
        contextTransaction.appraisalInspectionDate = '10/14/2011 11:46 AM';
        contextTransaction.listingSource = 'sfdc';
        
        contextTransaction.contingenciesLiftDate = String.valueOf(Date.today());
        contextTransaction.contingencyStatus = 'Contingent'; // PE-619
        contextTransaction.emdDueDate = String.valueOf(Date.today());
        contextTransaction.emdReceivedDate = String.valueOf(Date.today());
        
        contextTransaction.transactionNotes = 'Test Notes';
        contextTransaction.enableYardiUpload = true;
        contextTransaction.sellerEntity = 'Seller Entity';
        contextTransaction.emdAmount = 1234;
        contextTransaction.emdOptionFeeStatus = 'Not Needed';
        contextTransaction.optionFeeAmount = 25;
        contextTransaction.inspectionEmailCc = 'abc@gmail.com';
        contextTransaction.inspectionKickOffNotes = 'Test Notes';
        contextTransaction.emdWiredOnDate = String.valueOf(Date.today());
        
        //contextTransaction.purchasePrice = 1235675;

        contextTransaction.originalSalePrice=1234567;
        contextTransaction.salesChannel = 'SChannel';
        contextTransaction.actualCapex = '123';
        contextTransaction.inspectionDueDate = String.valueOf(Date.today());
        contextTransaction.brokerNotes = 'Test Notes';
        contextTransaction.rootTaskType = 'Transaction';
        contextTransaction.leadOriginationSource = 'MLS(RS)';
        contextTransaction.sellerCommissionMinAmount = 124;
        contextTransaction.buyerCommissionPercentage = 3;
        contextTransaction.sellerCommissionPercentage = 3; 
        
        contextTransaction.inspectionNeeded = 'Yes';
        contextTransaction.sendOpenEscrowEmail = 'Yes';
        
        contextTransaction.contactsList = conList;
        transactionList.add(contextTransaction);
        
        RESTTransactionHelper.TransactionsWrap transRequest = new RESTTransactionHelper.TransactionsWrap();
        transRequest.transactionList = transactionList;
        String sReq = JSON.serialize(transRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/updateTransaction';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTTransactionController.updateTransaction();
        Test.stopTest();
    }
    
    static testMethod void RESTTransactionControllerTestMatch() {
        Account a = new Account(Name = 'TestAccount');
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'abc@gmail.com',
            BPM_Contact_Id__c = '123',
            HasOptedOutOfEmail =false,
            AccountId = a.Id
        );
        insert c;
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.Property_Type__c = 'Single Family';
        //p.Year_Built__c = 1972;
        p.name = '123 Main St Tracy CA 95391';
        p.PropertyId__c = '123458';
        p.Roofstock_Instance_Id__c = '123458';
        insert p;
        
        Transaction__c trans = new Transaction__c();
        trans.Name = 'New Transaction';
        trans.Transaction_Id__c = '123458';
        trans.Transaction_Status__c = 'Transaction Cancelled';
        insert trans;
        /*  
Id masterTransactionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Master Transaction').getRecordTypeId();
Case cse = new Case();
cse.RecordTypeId = masterTransactionRecordTypeId;
cse.Subject =trans.Name;
cse.Origin = 'Transaction Team';
cse.Transaction__c = trans.Id;
insert cse;
*/
          List<RESTContactHelper.Contacts> conList = new List<RESTContactHelper.Contacts>();
       RESTContactHelper.Contacts con1 = new RESTContactHelper.Contacts();
        con1.bpmContactId = '123';
        con1.type = 'Buyer';
        con1.email = 'abc2@gmail.com';
        con1.phone = '6754678987';
        con1.firstName = 'First Name';
        con1.lastName = 'Last Name';
        con1.rsAccountId = '123';
        con1.roofstockUserId = '123';
        con1.contactNumber = 1;
        conList.add(con1);
        /*RESTContactHelper.Contacts con2 = new RESTContactHelper.Contacts();
        con2.bpmContactId = '123';
        con2.type = 'Seller';
        con2.email = 'abc@gmail.com';
        con2.phone = '6754678987';
        con2.firstName = 'First Name';
        con2.lastName = 'Last Name';
        conList.add(con2);
        RESTContactHelper.Contacts con3 = new RESTContactHelper.Contacts();
        con3.bpmContactId = '123';
        con3.type = 'Inspector';
        con3.email = 'abc@gmail.com';
        con3.phone = '6754678987';
        con3.firstName = 'First Name';
        con3.lastName = 'Last Name';
        conList.add(con3);
        RESTContactHelper.Contacts con4 = new RESTContactHelper.Contacts();
        con4.bpmContactId = '123';
        con4.type = 'PM Buyer';
        con4.email = 'abc@gmail.com';
        con4.phone = '6754678987';
        con4.firstName = 'First Name';
        con4.lastName = 'Last Name';
        conList.add(con4);
        RESTContactHelper.Contacts con5 = new RESTContactHelper.Contacts();
        con5.bpmContactId = '123';
        con5.type = 'PM Seller';
        con5.email = 'abc@gmail.com';
        con5.phone = '6754678987';
        con5.firstName = 'First Name';
        con5.lastName = 'Last Name';
        conList.add(con5);
        RESTContactHelper.Contacts con6 = new RESTContactHelper.Contacts();
        con6.bpmContactId = '123';
        con6.type = 'Escrow';
        con6.email = 'abc@gmail.com';
        con6.phone = '6754678987';
        con6.firstName = 'First Name';
        con6.lastName = 'Last Name';
        conList.add(con6);
        RESTContactHelper.Contacts con7 = new RESTContactHelper.Contacts();
        con7.bpmContactId = '123';
        con7.type = 'Title';
        con7.email = 'abc@gmail.com';
        con7.phone = '6754678987';
        con7.firstName = 'First Name';
        con7.lastName = 'Last Name';
        conList.add(con7);
        RESTContactHelper.Contacts con8 = new RESTContactHelper.Contacts();
        con8.bpmContactId = '123';
        con8.type = 'Insurance';
        con8.email = 'abc@gmail.com';
        con8.phone = '6754678987';
        con8.firstName = 'First Name';
        con8.lastName = 'Last Name';
        conList.add(con8);
        RESTContactHelper.Contacts con9 = new RESTContactHelper.Contacts();
        con9.bpmContactId = '123';
        con9.type = 'Lendor';
        con9.email = 'abc@gmail.com';
        con9.phone = '6754678987';
        con9.firstName = 'First Name';
        con9.lastName = 'Last Name';
        conList.add(con9);
        RESTContactHelper.Contacts con10 = new RESTContactHelper.Contacts();
        con10.bpmContactId = '123';
        con10.type = 'Broker Buyer';
        con10.email = 'abc@gmail.com';
        con10.phone = '6754678987';
        con10.firstName = 'First Name';
        con10.lastName = 'Last Name';
        conList.add(con10);
        RESTContactHelper.Contacts con11 = new RESTContactHelper.Contacts();
        con11.bpmContactId = '123';
        con11.type = 'Broker Seller';
        con11.email = 'abc@gmail.com';
        con11.phone = '6754678987';
        con11.firstName = 'First Name';
        con11.lastName = 'Last Name';
        conList.add(con11);
        */
        List<RESTTransactionHelper.Transactions> transactionList = new List<RESTTransactionHelper.Transactions>();
        RESTTransactionHelper.Transactions contextTransaction = new RESTTransactionHelper.Transactions();
        contextTransaction.name = 'TRN-20205 | 6825 Brittany Pl, Pinson, AL';
        contextTransaction.address = '10805 N 17th Drive Unit 1';
        contextTransaction.portfolioTransactionId = '1234';
        contextTransaction.transactionId ='123458';
        contextTransaction.buyerPropertyId ='123458';
        contextTransaction.listingId ='123458';
        contextTransaction.offerId = '1234';
        contextTransaction.status = 'Transaction Cancelled';
        contextTransaction.salePrice = '1234';
        contextTransaction.listPrice = '1234';
        contextTransaction.propertyType = 'bla';
        contextTransaction.createdDate = String.valueOf(System.Today());
        contextTransaction.startDate = String.valueOf(System.Today());
        contextTransaction.inContractDate = String.valueOf(System.Today());
        contextTransaction.estimatedCloseDate = String.valueOf(System.Today());
        contextTransaction.escrowCloseDate = String.valueOf(System.Today());
        contextTransaction.contingencyExpirationDate = String.valueOf(System.Today());
        contextTransaction.isContingency = true;
        contextTransaction.cancellationDate = String.valueOf(System.Today());
        contextTransaction.appraisalExpirationDate = String.valueOf(System.Today());
        contextTransaction.transactionCordinatorEmail = 'TestUser1@roofstock.com';
        contextTransaction.customerServiceEmail = 'TestUser1@roofstock.com';
        contextTransaction.inventoryEmail = 'TestUser2@roofstock.com';
        contextTransaction.accountManagerEmail = 'TestUser2@roofstock.com';
        contextTransaction.accountingEmail = 'TestUser1@roofstock.com';
        contextTransaction.projectManagerEmail = 'TestUser1@roofstock.com';
       /* contextTransaction.buyerContactId1 = '123';
        contextTransaction.buyerContactId2 = '123';
        contextTransaction.sellerContactId = '123';
        contextTransaction.inspectorContactId = '123';
        //contextTransaction.pmContactId = '123';
        contextTransaction.pmBuyerContactid = '123';
        contextTransaction.pmSellerContactId = '123';
        contextTransaction.escrowContactId = '123';
        contextTransaction.titleContactId = '123';
        contextTransaction.insuranceContactId = '123';
        contextTransaction.lendorContactId = '123';
        contextTransaction.buyerBrokerContactId = '123';
        contextTransaction.sellerBrokerContactId = '123';*/
        
        contextTransaction.contingenciesLiftDate = String.valueOf(Date.today());
        contextTransaction.contingencyStatus = 'Contingent'; // PE-619
        contextTransaction.emdDueDate = String.valueOf(Date.today());
        contextTransaction.emdReceivedDate = String.valueOf(Date.today());
        
        contextTransaction.transactionNotes = 'Test Notes';
        contextTransaction.enableYardiUpload = true;
        contextTransaction.sellerEntity = 'Seller Entity';
        contextTransaction.emdAmount = 1234;
        contextTransaction.emdOptionFeeStatus = 'Not Needed';
        contextTransaction.optionFeeAmount = 25;
        contextTransaction.inspectionEmailCc = 'abc@gmail.com';
        contextTransaction.inspectionKickOffNotes = 'Test Notes';
        contextTransaction.emdWiredOnDate = String.valueOf(Date.today());
        
        //contextTransaction.purchasePrice = 1235675;

        contextTransaction.originalSalePrice=1234567;
        contextTransaction.salesChannel = 'SChannel';
        contextTransaction.actualCapex = '123';
        contextTransaction.inspectionDueDate = String.valueOf(Date.today());
        contextTransaction.brokerNotes = 'Test Notes';
        contextTransaction.rootTaskType = 'Transaction';
        contextTransaction.leadOriginationSource = 'MLS(RS)';
        contextTransaction.sellerCommissionMinAmount = 124;
        contextTransaction.buyerCommissionPercentage = 3;
        contextTransaction.sellerCommissionPercentage = 3; 
        
        contextTransaction.inspectionNeeded = 'Yes';
        contextTransaction.sendOpenEscrowEmail = 'Yes';
        
        contextTransaction.contactsList = conList;
        transactionList.add(contextTransaction);
        RESTTransactionHelper.TransactionsWrap transRequest = new RESTTransactionHelper.TransactionsWrap();
        transRequest.transactionList = transactionList;
        String sReq = JSON.serialize(transRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/updateTransaction';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTTransactionController.updateTransaction();
        Test.stopTest();
    }
    static testMethod void checkExceptions() {
        Account a = new Account(Name = 'TestAccount');
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test@nowhere.com',
            BPM_Contact_Id__c = '123',
            HasOptedOutOfEmail =false,
            AccountId = a.Id
        );
        insert c;
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.Property_Type__c = 'Single Family';
        //p.Year_Built__c = 1972;
        p.name = '123 Main St Tracy CA 95391';
        p.PropertyId__c = '123458';
        p.Roofstock_Instance_Id__c = '123458';
        insert p;
        
        Transaction__c trans = new Transaction__c();
        trans.Name = 'New Transaction';
        trans.Transaction_Id__c = '123458';
        trans.Transaction_Status__c = 'Transaction Cancelled';
        insert trans;
        /* 
Id masterTransactionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Master Transaction').getRecordTypeId();
Case cse = new Case();
cse.RecordTypeId = masterTransactionRecordTypeId;
cse.Subject =trans.Name;
cse.Origin = 'Transaction Team';
cse.Transaction__c = trans.Id;
insert cse;
*/
          List<RESTContactHelper.Contacts> conList = new List<RESTContactHelper.Contacts>();
        RESTContactHelper.Contacts con1 = new RESTContactHelper.Contacts();
        con1.bpmContactId = '123';
        con1.type = 'Buyer';
        con1.email = 'abc@gmail.com';
        con1.phone = '6754678987';
        con1.firstName = 'First Name';
        con1.lastName = 'Last Name';
        conList.add(con1);
        RESTContactHelper.Contacts con2 = new RESTContactHelper.Contacts();
        con2.bpmContactId = '123';
        con2.type = 'Seller';
        con2.email = 'abc@gmail.com';
        con2.phone = '6754678987';
        con2.firstName = 'First Name';
        con2.lastName = 'Last Name';
        conList.add(con2);
        RESTContactHelper.Contacts con3 = new RESTContactHelper.Contacts();
        con3.bpmContactId = '123';
        con3.type = 'Inspector';
        con3.email = 'abc@gmail.com';
        con3.phone = '6754678987';
        con3.firstName = 'First Name';
        con3.lastName = 'Last Name';
        conList.add(con3);
        RESTContactHelper.Contacts con4 = new RESTContactHelper.Contacts();
        con4.bpmContactId = '123';
        con4.type = 'PM Buyer';
        con4.email = 'abc@gmail.com';
        con4.phone = '6754678987';
        con4.firstName = 'First Name';
        con4.lastName = 'Last Name';
        conList.add(con4);
        RESTContactHelper.Contacts con5 = new RESTContactHelper.Contacts();
        con5.bpmContactId = '123';
        con5.type = 'PM Seller';
        con5.email = 'abc@gmail.com';
        con5.phone = '6754678987';
        con5.firstName = 'First Name';
        con5.lastName = 'Last Name';
        conList.add(con5);
        RESTContactHelper.Contacts con6 = new RESTContactHelper.Contacts();
        con6.bpmContactId = '123';
        con6.type = 'Escrow';
        con6.email = 'abc@gmail.com';
        con6.phone = '6754678987';
        con6.firstName = 'First Name';
        con6.lastName = 'Last Name';
        conList.add(con6);
        RESTContactHelper.Contacts con7 = new RESTContactHelper.Contacts();
        con7.bpmContactId = '123';
        con7.type = 'Title';
        con7.email = 'abc@gmail.com';
        con7.phone = '6754678987';
        con7.firstName = 'First Name';
        con7.lastName = 'Last Name';
        conList.add(con7);
        RESTContactHelper.Contacts con8 = new RESTContactHelper.Contacts();
        con8.bpmContactId = '123';
        con8.type = 'Insurance';
        con8.email = 'abc@gmail.com';
        con8.phone = '6754678987';
        con8.firstName = 'First Name';
        con8.lastName = 'Last Name';
        conList.add(con8);
        RESTContactHelper.Contacts con9 = new RESTContactHelper.Contacts();
        con9.bpmContactId = '123';
        con9.type = 'Lendor';
        con9.email = 'abc@gmail.com';
        con9.phone = '6754678987';
        con9.firstName = 'First Name';
        con9.lastName = 'Last Name';
        conList.add(con9);
        RESTContactHelper.Contacts con10 = new RESTContactHelper.Contacts();
        con10.bpmContactId = '123';
        con10.type = 'Broker Buyer';
        con10.email = 'abc@gmail.com';
        con10.phone = '6754678987';
        con10.firstName = 'First Name';
        con10.lastName = 'Last Name';
        conList.add(con10);
        RESTContactHelper.Contacts con11 = new RESTContactHelper.Contacts();
        con11.bpmContactId = '123';
        con11.type = 'Broker Seller';
        con11.email = 'abc@gmail.com';
        con11.phone = '6754678987';
        con11.firstName = 'First Name';
        con11.lastName = 'Last Name';
        conList.add(con11);
        
        List<RESTTransactionHelper.Transactions> transactionList = new List<RESTTransactionHelper.Transactions>();
        RESTTransactionHelper.Transactions contextTransaction = new RESTTransactionHelper.Transactions();
        contextTransaction.name = 'TRN-20205 | 6825 Brittany Pl, Pinson, AL';
        contextTransaction.address = '10805 N 17th Drive Unit 1';
        contextTransaction.portfolioTransactionId = '1234';
        contextTransaction.transactionId ='123458';
        contextTransaction.buyerPropertyId ='123458';
        contextTransaction.listingId ='123458';
        contextTransaction.offerId = '1234';
        contextTransaction.status = 'Transaction Cancelled';
        contextTransaction.salePrice = '1234';
        contextTransaction.listPrice = '1234';
        contextTransaction.propertyType = 'bla';
        contextTransaction.createdDate = String.valueOf(System.Today());
        contextTransaction.startDate = String.valueOf(System.Today());
        contextTransaction.inContractDate = String.valueOf(System.Today());
        contextTransaction.estimatedCloseDate = String.valueOf(System.Today());
        contextTransaction.escrowCloseDate = String.valueOf(System.Today());
        contextTransaction.contingencyExpirationDate = String.valueOf(System.Today());
        contextTransaction.isContingency = true;
        contextTransaction.cancellationDate = String.valueOf(System.Today());
        contextTransaction.appraisalExpirationDate = String.valueOf(System.Today());
        contextTransaction.transactionCordinatorEmail = 'chidanand.magadum@roofstock.com';
        contextTransaction.customerServiceEmail = 'chidanand.magadum@roofstock.com';
        contextTransaction.inventoryEmail = 'chidanand.magadum@roofstock.com';
        contextTransaction.accountManagerEmail = 'chidanand.magadum@roofstock.com';
        contextTransaction.accountingEmail = 'chidanand.magadum@roofstock.com';
        contextTransaction.projectManagerEmail = 'chidanand.magadum@roofstock.com';
       /* contextTransaction.buyerContactId1 = '123';
        contextTransaction.buyerContactId2 = '123';
        contextTransaction.sellerContactId = '123';
        contextTransaction.inspectorContactId = '123';
        //contextTransaction.pmContactId = '123';
        contextTransaction.pmBuyerContactid = '123';
        contextTransaction.pmSellerContactId = '123';
        contextTransaction.escrowContactId = '123';
        contextTransaction.titleContactId = '123';
        contextTransaction.insuranceContactId = '123';
        contextTransaction.lendorContactId = '123';
        contextTransaction.buyerBrokerContactId = '123';
        contextTransaction.sellerBrokerContactId = '123';*/
        
        contextTransaction.contactsList = conList;
        transactionList.add(contextTransaction);
        RESTTransactionHelper.TransactionsWrap transRequest = new RESTTransactionHelper.TransactionsWrap();
        transRequest.transactionList = transactionList;
        String sReq = JSON.serialize(transRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/updateTransaction';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{');
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTTransactionController.updateTransaction();
        Test.stopTest();
    }
    
}
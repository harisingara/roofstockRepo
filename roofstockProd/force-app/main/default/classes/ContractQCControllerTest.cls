@IsTest
private class ContractQCControllerTest{
    static{
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    @IsTest
    static void getContractQCData(){
        //  String recordId = 'a0V02000000AblMEAS';
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.US_Resident__c = 'Yes';
        insert acc;

        Contact con = new Contact();
        con.firstname = 'Test ';
        con.lastname = 'contact';
        con.BPM_Contact_Id__c = '1234';
        // con.AccountId = acc.Id;
        insert con;

        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
        p.HOA__c = false;
        //p.Year_Built__c = '1972';
        p.name = '123 Main St Tracy CA 95391';
        insert p;

        Property_Unit__c pu = new Property_Unit__c();
        pu.name = '123 Main St Tracy CA 95391';
        pu.Property__c = p.id;
        pu.Bathrooms__c = 3;
        pu.Bedrooms__c = 2.5;
        pu.HomeCode__c = 'q2000';
        insert pu;

        Transaction__c trans = new Transaction__c();
        trans.Buyer_Contact_Id_1__c = '1234';
        trans.Buyer_Contact1__c = con.Id;
        trans.Transaction_Status__c = 'Pending Escrow';
        trans.Buyer_Property_Instance__c = p.id;
        trans.In_Contract_Price__c = 200;
        trans.Origination_Source__c = 'MLS (Broker)';
        trans.Title_Company_Account__c = acc.Id;
        trans.Date_Contingencies_Lift__c = Date.today() + 28;
        insert trans;

        Transaction_Settlement__c transactionsettlement = new Transaction_Settlement__c();
        transactionsettlement.Unit_Price__c = 200;
        transactionsettlement.Description__c = 'Earnest Money Deposit';
        transactionsettlement.Transaction__c = trans.id;
        insert transactionsettlement;
        Transaction_Settlement__c transactionsettlement2 = new Transaction_Settlement__c();
        transactionsettlement2.Unit_Price__c = 10;
        transactionsettlement2.Description__c = 'Option Fee';
        transactionsettlement2.Transaction__c = trans.id;
        insert transactionsettlement2;

        Transaction_Contact__c txnContact = new Transaction_Contact__c();
        txnContact.Transaction__c = trans.id;
        txnContact.Contact_Type__c = 'Buyer';
        txnContact.Contact_Count__c = 1;
        txnContact.Contact__c = con.id;
        insert txnContact;

        Inspection__c insp = new Inspection__C();
        insp.Name = 'Test Inspection';
        insp.Inspection_Type__c = 'Diligence';
        insp.Inspection_Status__c = 'Completed';
        //insp.Inspection_Scheduled_Date__c = Date.today() + 28;
        insp.Inspection_Due_Date__c = Date.today() + 7;
        insp.Property__c = p.id;
        insp.Property_Unit__c = pu.id;
        insp.Transaction__c = trans.id;
        insert insp;

        Task tsk = new Task();
        tsk.IsRecurrence = true;
        tsk.OwnerId = UserInfo.getUserId();
        tsk.Priority = 'Select One';
        tsk.RecurrenceEndDateOnly = Date.today() + 28;
        tsk.RecurrenceInterval = 7;
        tsk.RecurrenceStartDateOnly = Date.today() + 7;
        tsk.RecurrenceType = 'RecursDaily';
        tsk.Status = 'Completed';
        tsk.Subject = 'CS Check-In';
        //tsk.Type = 'Select One';
        tsk.Type = 'QC: Contract Audit';
        tsk.whatId = trans.id;
        insert tsk;

        System.debug(tsk);
        System.debug(tsk.whatId);

        String recordId = trans.id;

        Test.startTest();

        ContractQCController.ContractQCWrapper contractQCWrapper = ContractQCController.getContractQCData(recordId);
        System.assertEquals(200, contractQCWrapper.transactionRecord.In_Contract_Price__c);
        System.assertEquals(200, contractQCWrapper.emdAmount.Unit_Price__c);
        System.assertEquals(10, contractQCWrapper.optionFeeAmount.Unit_Price__c);
        System.assertEquals(false, contractQCWrapper.propertyRecord.HOA__c);

        System.assertEquals('1234', ContractQCController.getContact(con.Id).BPM_Contact_Id__c);
        System.assertEquals('Completed', ContractQCController.getTask(trans.Id).Status);
        System.assertEquals('Buyer', ContractQCController.getTransactionContact(trans.Id, 'Buyer').Contact_Type__c);
        System.assertNotEquals(null, ContractQCController.getAccountListByRecordType());
        
        System.assertEquals(null, ContractQCController.getContactAccountId(con.Id));
        System.assertEquals(null, ContractQCController.getContactAccountName(con.Id));

        transactionsettlement2.Unit_Price__c = 12;
        ContractQCController.upsertTransactionSettlement(transactionsettlement2, trans.id);

        Test.stopTest();

        // ContractQCController.updateTask(trans.id,'Completed','task Completed');
        // upsertTransactionSettlement
        // getPropertyUnitList
        ContractQCController.updateTransactionContact(trans.id, txnContact, 'Buyer');

        ContractQCController.publishPlatformEvent(JSON.serialize(contractQCWrapper));
    }

}
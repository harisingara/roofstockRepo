@isTest
public class TransactionHelperTest{
    static{        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    
    @testSetup
    static void setupTestData() {
        Id transRecordtypeId = Schema.SObjectType.Transaction__C.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        Id propertyRecordtypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByName().get('Roofstock').getRecordTypeId();
        Id propertyRecordtypeId1 = Schema.SObjectType.Property2__c.getRecordTypeInfosByName().get('Asset Management').getRecordTypeId();
         String orgId = UserInfo.getOrganizationId(); 
        Profile prof = [select id from profile where name = 'System Administrator'];
        String dateString =  String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;  
        User tempUser = new User(  FirstName = 'sfdc0021',  
                            LastName = 'Salesforce2022',  
                            email = 'salesforce@sfdc.com',  
                            Username = uniqueName + '@test' + orgId + '.org',  
                            EmailEncodingKey = 'ISO-8859-1',  
                            Alias = uniqueName.substring(18, 23),  
                            TimeZoneSidKey = 'America/Los_Angeles',  
                            LocaleSidKey = 'en_US',  
                            LanguageLocaleKey = 'en_US',  
                            ProfileId = prof.Id);  
        insert tempUser;  
        List<Property2__c> propList = new List<Property2__c>();
        List<Property_Unit__c> propUnitList = new List<Property_Unit__c>();
        List<Transaction__c> transactionList = new List<Transaction__c>();
        
        Property2__C prop = new Property2__C();
        prop.Name = 'Test property';
        prop.RecordtypeId = propertyRecordtypeId;
        propList.add(prop);
        
        Property2__C prop1 = new Property2__C();
        prop1.Name = 'Test property1';
        prop1.RecordtypeId = propertyRecordtypeId1;
        prop1.Client__c = 'Project Spartan Capital Group';
        propList.add(prop1);
        
        insert propList;
        
        Property_Unit__c propU = new Property_Unit__c();
        propU.Name = 'Test Property Unit';
        propU.Property__c = prop.Id;
        propUnitList.add(propU);
        
        Property_Unit__c propU1 = new Property_Unit__c();
        propU1.Name = 'Test Property Unit';
        propU1.Property__c = prop1.Id;
        propUnitList.add(propU1);
        
        insert propUnitList;
        
        Transaction__c trans = new Transaction__c();
        trans.Name = 'Test Transaction';
        trans.Buyer_Property_Instance__c = prop.id;
        trans.RecordtypeId = transRecordtypeId;
        trans.Stage__c = 'Pre-PSA';
        trans.Transaction_Notes__c = 'sfdc';
        trans.Buyer_Entity__c ='sfdc';
        trans.Origination_Source__c = 'Portfolio (RS)';
        trans.Roofstock_Advisor__c = tempUser.Id;
        trans.Roofstock_Inventory_Owner__c = tempUser.Id;
        trans.Roofstock_TC_User__c = tempUser.Id;
        trans.Roofstock_Customer_Service__c = tempUser.Id;
        trans.Underwriting_Analyst__c = tempUser.Id;
        trans.Transaction_Notes__c = 'test';
        trans.Transaction_Instruction__c = 'test';
        trans.Sale_Price__c = 100.0;
        trans.Seller_Entity__c = 'sfdc';
        trans.In_Contract_Date__c = date.today();
        trans.Est_Close_Date__c = date.today();
        trans.EMD_Amount__c = 200.00;
        trans.Date_Contingencies_Lift__c = date.today();
        trans.Buyer_Commission_Percent__c = 20.00;
        trans.EMD_Due_Date__c = date.today();
        trans.Option_Fee_Amount__c = 20.00;
        trans.Transaction_Id__c = '1234';
        trans.Open_Escrow__c = 'Yes';
        trans.Inspection_Due_Date__c = date.today();
        trans.Inspection_Needed__c = 'Yes';
        trans.Emd_Wired_On_Date__c = date.today();
        trans.EMD_Option_Fee_Status__c = 'Required';
        transactionList.add(trans);
        
        
        Transaction__c trans1 = new Transaction__c();
        trans1.Name = 'Test Transaction';
        trans1.Buyer_Property_Instance__c = prop1.id;
        trans1.RecordtypeId = transRecordtypeId;
        trans1.Stage__c = 'Pre-PSA';
        transactionList.add(trans1);
        
        insert transactionList;
        
        Inspection__c insp = new Inspection__C();
        insp.Name = 'Test Inspection';
        insp.Inspection_Type__c = 'Diligence';
        insp.Inspection_Status__c = 'Completed';
        insp.Property__c = prop.id;
        insp.Property_Unit__c = propU.id;
        insp.Transaction__c = trans.id;
        insert insp;   
    }
    
    @isTest
    static void createJobForInspection() {
        Transaction__c tran = [select id, Name,Stage__c, Transaction_Status__c from Transaction__C LIMIT 1];
        tran.Transaction_Status__c = 'Transaction Completed';
        tran.Stage__c = 'Kick-Off Email Sent';
        update tran;
    }
    
    @isTest
    static void updatePropertyforBPOBatch() {
        Transaction__c tran = [select id, Name,Stage__c, Transaction_Status__c,Buyer_Property_Instance__c from Transaction__C where Buyer_Property_Instance__r.recordtype.name = 'Asset Management'];
        tran.Transaction_Status__c = 'Transaction Completed';
        update tran;
    }
    @isTest
    static void updateTransaction() {
        Transaction__c tran = [select id, Name,Stage__c,
                               Sale_Price__c,Seller_Entity__c,In_Contract_Date__c,Est_Close_Date__c,EMD_Amount__c,
                               Date_Contingencies_Lift__c,Buyer_Commission_Percent__c,EMD_Due_Date__c,
                               Option_Fee_Amount__c,Transaction_Id__c,Transaction_Instruction__c,Open_Escrow__c,
                               Inspection_Due_Date__c,Inspection_Needed__c,Emd_Wired_On_Date__c,EMD_Option_Fee_Status__c,
                               Transaction_Notes__c,Buyer_Entity__c, Origination_Source__c,Transaction_Status__c,Buyer_Property_Instance__c from Transaction__C where Origination_Source__c = 'Portfolio (RS)'];
        tran.Origination_Source__c = 'RS Retail Marketplace';
        update tran;
        Set<TransactionPlatformEventWrapper.TransactionContact> setTc = new Set<TransactionPlatformEventWrapper.TransactionContact>();
        Set<TransactionPlatformEventWrapper.Inspection> setInsp = new Set<TransactionPlatformEventWrapper.Inspection>();
        Set<TransactionPlatformEventWrapper.PropertyUnit> setPU = new Set<TransactionPlatformEventWrapper.PropertyUnit>();
        TransactionPlatformEventWrapper.TransactionContact tc = new TransactionPlatformEventWrapper.TransactionContact();
        tc.bpmContactId = '1234';
        tc.companyName = 'sfdc';
        tc.contactNumber = '1';
        tc.email = 'test@gmail.com';
        tc.firstName = 'sales';
        tc.lastName = 'force';
        tc.mobile = '9876766567';
        tc.roofstockUserId = '1234';
        tc.rsAccountId = '123';
        tc.type = 'Buyer';
        setTc.add(tc);
        TransactionPlatformEventWrapper.Inspection insp = new TransactionPlatformEventWrapper.Inspection();
        insp.inspectionId = '1234';
        insp.diligenceDeadline = '01/02/2021';
        insp.inspectionDueDate = '01/02/2021';
        setInsp.add(insp);
        TransactionPlatformEventWrapper.PropertyUnit PU = new TransactionPlatformEventWrapper.PropertyUnit();
        PU.id = '1234';
        PU.occupancy = 'Notice Rented';
        PU.property_access_method_type ='Rently';
        PU.property_access_notes = 'sfdc';
        PU.unitId = '1234';
        setPU.add(PU);
        TransactionPlatformEventWrapper.transactionSettlement ts = new TransactionPlatformEventWrapper.transactionSettlement();
        ts.emdAmount = 10.0;
        ts.optionFeeAmount = 20.0;
        TransactionPlatformEventWrapper.transactionContractQcTask qc = new TransactionPlatformEventWrapper.transactionContractQcTask();
        qc.description = 'sfdc';
        qc.status = 'Open';
        TransactionPlatformEventWrapper.Property propty = new TransactionPlatformEventWrapper.Property();
        propty.hoa = true;
        
        TransactionHelper.publishTransactionPlatformEvents('Contract QC',tran,setTc,setInsp,setPU,ts,qc,propty);
    }
    @isTest
    static void updateTransaction2() {
        Transaction__c tran = [select id, Sale_Price__c,Seller_Entity__c,In_Contract_Date__c,Est_Close_Date__c,EMD_Amount__c,
                               Date_Contingencies_Lift__c,Buyer_Commission_Percent__c,EMD_Due_Date__c,
                               Emd_Wired_On_Date__c,EMD_Option_Fee_Status__c,
                               Option_Fee_Amount__c,Transaction_Id__c,Transaction_Notes__c,Transaction_Instruction__c,
                               Roofstock_Advisor__c,Roofstock_Inventory_Owner__c,Name,Stage__c,Buyer_Entity__c, Origination_Source__c,Transaction_Status__c,Buyer_Property_Instance__c from Transaction__C where Origination_Source__c = 'Portfolio (RS)'];
        //tran.Origination_Source__c = 'RS Retail Marketplace';
        //update tran;
        Map<String,Schema.RecordTypeInfo> rtMapByDeveloperName = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName();
        String recordTypeId = rtMapByDeveloperName.get('Transaction_Tasks').getRecordTypeId();
        Task tsk = new Task();
        tsk.Type = 'QC: Contract Audit';
        tsk.recordTypeId = recordTypeId;
        tsk.Transaction__c = tran.Id;
        tsk.Subject = 'Documents';
        insert tsk;
        
        Set<TransactionPlatformEventWrapper.TransactionContact> setTc = new Set<TransactionPlatformEventWrapper.TransactionContact>();
        Set<TransactionPlatformEventWrapper.Inspection> setInsp = new Set<TransactionPlatformEventWrapper.Inspection>();
        Set<TransactionPlatformEventWrapper.PropertyUnit> setPU = new Set<TransactionPlatformEventWrapper.PropertyUnit>();
        TransactionPlatformEventWrapper.TransactionContact tc = new TransactionPlatformEventWrapper.TransactionContact();
        tc.bpmContactId = '1234';
        tc.companyName = 'sfdc';
        tc.contactNumber = '1';
        tc.email = 'test@gmail.com';
        tc.firstName = 'sales';
        tc.lastName = 'force';
        tc.mobile = '9876766567';
        tc.roofstockUserId = '1234';
        tc.rsAccountId = '123';
        tc.type = 'Buyer';
        setTc.add(tc);
        TransactionPlatformEventWrapper.Inspection insp = new TransactionPlatformEventWrapper.Inspection();
        insp.inspectionId = '1234';
        //insp.diligenceDeadline = '01/02/2021';
        //insp.inspectionDueDate = '01/02/2021';
        setInsp.add(insp);
        TransactionPlatformEventWrapper.PropertyUnit PU = new TransactionPlatformEventWrapper.PropertyUnit();
        PU.id = '1234';
        PU.occupancy = 'Notice Rented';
        PU.property_access_method_type ='Rently';
        PU.property_access_notes = 'sfdc';
        PU.unitId = '1234';
        setPU.add(PU);
        TransactionPlatformEventWrapper.transactionSettlement ts = new TransactionPlatformEventWrapper.transactionSettlement();
        ts.emdAmount = 10.0;
        ts.optionFeeAmount = 20.0;
        TransactionPlatformEventWrapper.transactionContractQcTask qc = new TransactionPlatformEventWrapper.transactionContractQcTask();
        qc.description = 'sfdc';
        qc.status = 'Open';
        TransactionPlatformEventWrapper.Property propty = new TransactionPlatformEventWrapper.Property();
        propty.hoa = true;
        List<Transaction__c> lstTransactions = new List<Transaction__c>();
        lstTransactions.add(tran);
        //TransactionHelper.assignPermissionSet(lstTransactions);
        TransactionHelper.publishTransactionPlatformEvents('Submit EMD',tran,setTc,setInsp,setPU,ts,qc,propty);
        TransactionHelper.createTransationSnapshot(lstTransactions);
    }
    
    @isTest
    static void acquisitionTransactionUpdate() {
        Transaction__c tran = [select id, Sale_Price__c,Seller_Entity__c,In_Contract_Date__c,Est_Close_Date__c,EMD_Amount__c,
                               Date_Contingencies_Lift__c,Buyer_Commission_Percent__c,EMD_Due_Date__c,
                               Emd_Wired_On_Date__c,EMD_Option_Fee_Status__c, Transaction_Type__c,
                               Option_Fee_Amount__c,Transaction_Id__c,Transaction_Notes__c,Transaction_Instruction__c,
                               Roofstock_Advisor__c,Roofstock_Inventory_Owner__c,Name,Stage__c,Buyer_Entity__c, Origination_Source__c,Transaction_Status__c,Buyer_Property_Instance__c from Transaction__C where Origination_Source__c = 'Portfolio (RS)'];
        tran.Transaction_Type__c = 'Acquisition Buy';
        update tran;
        
       List<Transaction__c> lstTransactions = new List<Transaction__c>();
        lstTransactions.add(tran);
        TransactionHelper.createTransationSnapshot(lstTransactions);
        TransactionHelper.createTasks(lstTransactions, null);
    }
    
    static testMethod void TaskControllerException() {
        TriggerDispatcher.forceException = true;
        Transaction__c trans;
        try{
            trans = new Transaction__c();
            trans.name = 'SFDC';
            trans.Transaction_Id__c = '1234';
            insert trans;
        }
        catch(Exception ex){
            System.debug('=='+trans.Id);
        }
        
        
    }
}
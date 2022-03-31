public with sharing class ContractQCController{
    public ContractQCController(){
    }

    // wrapper class with @AuraEnabled and {get;set;} properties
    public class ContractQCWrapper{
        @AuraEnabled
        public Transaction__c transactionRecord{ get; set; }

        @AuraEnabled
        public Inspection__c inspectionRecord{ get; set; }

        //for HOA
        @AuraEnabled
        public Property2__c propertyRecord{ get; set; }

        @AuraEnabled
        public List<Property_Unit__c> propertyUnitList{ get; set; }

        @AuraEnabled
        public Task task{ get; set; }

        @AuraEnabled
        public Transaction_Contact__c buyerTransactionContact{ get; set; }

        @AuraEnabled
        public Contact buyerSignerContact{ get; set; }

        @AuraEnabled
        public String buyerSignerContactId{ get; set; }

        @AuraEnabled
        public String buyerSignerContactName{ get; set; }

        @AuraEnabled
        public Transaction_Contact__c sellerTransactionContact{ get; set; }

        @AuraEnabled
        public Contact brokerSellerContact{ get; set; }

        @AuraEnabled
        public Transaction_Contact__c titleCompanyContact{ get; set; }

        @AuraEnabled
        public Contact titleContact{ get; set; }

        @AuraEnabled
        public Account emdAccount{ get; set; }

        @AuraEnabled
        public String sellerContactAccountId{ get; set; }

        @AuraEnabled
        public String sellerContactAccountName{ get; set; }

        @AuraEnabled
        public String titleCompanyContactAccountName{ get; set; }

        @AuraEnabled
        public User accountingContact{ get; set; }

        @AuraEnabled
        public User projectManager{ get; set; }

        @AuraEnabled
        public String state{ get; set; }

        @AuraEnabled
        public Transaction_Settlement__c emdAmount{ get; set; }

        @AuraEnabled
        public Transaction_Settlement__c optionFeeAmount{ get; set; }

        @AuraEnabled
        public ReviewWrapper reviewWrapper{ get; set; }

        @AuraEnabled
        public String titleAccountRecordTypeId{ get; set; }

    }

    @AuraEnabled
    public static ContractQCWrapper getContractQCData(String recordId){
        ContractQCWrapper contractQCWrapper = new ContractQCWrapper();

        //Transaction Object
        Transaction__c transactionObj = [SELECT Id, transaction_id__c, In_Contract_Price__c, Buyer_Entity__c, Seller_Entity__c, In_Contract_Date__c, Est_Close_Date__c, EMD_Option_Fee_Status__c, EMD_Due_Date__c, EMD_Account__c, Inspection_Email_Cc__c, Roofstock_Accounting__c, Seller_Contact__c, Title_Company_Contact__c, Transaction_Notes__c, Date_Contingencies_Lift__c, Open_Escrow__c, Inspection_Due_Date__c, Origination_Source__c, Assignment_Fee__c, Buyer_Commission_Percent__c, Inspection_Needed__c, Title_Company_Account__c
                                         FROM Transaction__c
                                         WHERE id = :recordId
                                         limit 1];
        contractQCWrapper.transactionRecord = transactionObj;

        // Set EMD Account & Accounting Contact to display names in View page
        contractQCWrapper.emdAccount = getEMDAccount();
        contractQCWrapper.accountingContact = getUser(transactionObj.Roofstock_Accounting__c);

        //Inspection Object
        contractQCWrapper.inspectionRecord = getInspection(recordId);

        if (null != contractQCWrapper.inspectionRecord){
            // Set EMD Account for View Page
            contractQCWrapper.projectManager = getUser(contractQCWrapper.inspectionRecord.Project_Manager__c);

            // Should this be defaulted to Yes only if blank?
            // contractQCWrapper.inspectionRecord.Send_Email_to_Inspector__c = 'Yes';
            // contractQCWrapper.inspectionRecord.Inspection_Needed__c = 'Yes';

            // If inspection due date is blank, then set it to 1 business day before contingencies lift date
            if (contractQCWrapper.transactionRecord.Inspection_Due_Date__c == null){
                if (null != contractQCWrapper.transactionRecord.Date_Contingencies_Lift__c){
                    String businessHoursName = System.label.Business_Days_Acquisition_Buy;
                    BusinessDays bDay = new BusinessDays(businessHoursName);
                    Datetime previousBusinessDateTime = bDay.getPreviousWorkingDay(contractQCWrapper.transactionRecord.Date_Contingencies_Lift__c);
                    Date previousBusinessDate = Date.newinstance(previousBusinessDateTime.year(), previousBusinessDateTime.month(), previousBusinessDateTime.day());

                    // contractQCWrapper.transactionRecord.Inspection_Due_Date__c = contractQCWrapper.transactionRecord.Date_Contingencies_Lift__c - 1;
                    contractQCWrapper.transactionRecord.Inspection_Due_Date__c = previousBusinessDate;
                }
            }
        }

        contractQCWrapper.state = getState(recordId);

        //Property Object
        contractQCWrapper.propertyRecord = getProperty(recordId); //HOA

        //Transaction Settlement Objects
        contractQCWrapper.optionFeeAmount = getTransactionSettlement(recordId, 'Option Fee');
        contractQCWrapper.emdAmount = getTransactionSettlement(recordId, 'Earnest Money Deposit');

        // If Option Fee is <0, then set Option Fee Required as Not Needed
        // if (contractQCWrapper.optionFeeAmount.Unit_Price__c <= 0 || null == contractQCWrapper.optionFeeAmount.Unit_Price__c){
        //     contractQCWrapper.transactionRecord.EMD_Option_Fee_Status__c = 'Not Needed';
        // } else{
        //     contractQCWrapper.transactionRecord.EMD_Option_Fee_Status__c = 'Required';
        // }

        //Property Unit List
        contractQCWrapper.propertyUnitList = getPropertyUnitList(recordId);

        contractQCWrapper.task = getTask(recordId);

        // Contacts from Transaction_Contact__c
        // contractQCWrapper.buyerTransactionContact = getTransactionContact(recordId, 'Buyer Signer');
        // if (null != contractQCWrapper.buyerTransactionContact){
        //     contractQCWrapper.buyerSignerContact = getContact(contractQCWrapper.buyerTransactionContact.Contact__c);
        //     if (null != contractQCWrapper.buyerSignerContact){
        //         contractQCWrapper.buyerSignerContactId = contractQCWrapper.buyerSignerContact.Id;
        //         contractQCWrapper.buyerSignerContactName = contractQCWrapper.buyerSignerContact.Name;
        //     }
        // }
        // contractQCWrapper.sellerTransactionContact = getTransactionContact(recordId, 'Broker Seller');
        // contractQCWrapper.brokerSellerContact = getContact(contractQCWrapper.sellerTransactionContact.Contact__c);

        contractQCWrapper.titleCompanyContact = getTransactionContact(recordId, 'Title');
        contractQCWrapper.titleContact = getContact(contractQCWrapper.titleCompanyContact.Contact__c);

        // Accounts for the Contacts
        // contractQCWrapper.sellerContactAccountId = getContactAccountId(contractQCWrapper.sellerTransactionContact.Contact__c);
        // contractQCWrapper.sellerContactAccountName = getContactAccountName(contractQCWrapper.sellerTransactionContact.Contact__c);

        contractQCWrapper.titleCompanyContactAccountName = getAccountName(contractQCWrapper.transactionRecord.Title_Company_Account__c);

        if (null != transactionObj.Origination_Source__c){
            contractQCWrapper.reviewWrapper = getReviewChecklistRecords(recordId, contractQCWrapper.state, transactionObj.Origination_Source__c);
        } else{
            throw new AuraHandledException('Origination source is blank, please check');
        }

        contractQCWrapper.titleAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Title').getRecordTypeId();

        return contractQCWrapper;
    }

    public static Transaction_Contact__c getTransactionContact(String txnRecordId, String contactType){
        List<Transaction_Contact__c> transactionContactList = null;
        Transaction_Contact__c transactionContactOjb = new Transaction_Contact__c();

        // Order by Contact_Count_c & take first record
        try{
            transactionContactList = [SELECT Contact__c, Id, Contact_Type__c
                                      FROM Transaction_Contact__c
                                      WHERE Transaction__c = :txnRecordId AND Contact_Type__c = :contactType
                                      ORDER BY Contact_Count__c
                                      LIMIT 1];

            if (null != transactionContactList){
                if (!transactionContactList.isEmpty()){
                    transactionContactOjb = transactionContactList.get(0);
                }
            }
        } catch (QueryException exp){
            System.debug('No transaction contact found with for txn Id :' + txnRecordId);
            throw new AuraHandledException('Transaction contact details not found, please check : ' + contactType);
        }

        return transactionContactOjb;
    }

    @AuraEnabled
    public static List<Map<String, String>> getAccountListByRecordType(){
        List<Map<String, String>> accountOptionsList = new List<Map<String, String>>();

        try{
            String recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Owner Entity').getRecordTypeId();
            // recordTypeId = '0013K00000pr9m2QAA';//'0121C000001JUTqQAO';//Sandbox
            //recordTypeId = '0124v000000AZENAA4';
            System.debug('getAccountListByRecordType() - recordTypeId : ' + recordTypeId);

            if (String.isNotBlank(recordTypeId)){
                List<Account> accountObjList = [SELECT Id, Name
                                                From Account
                                                WHERE RecordTypeId = :recordTypeId];

                System.debug('getAccountListByRecordType() - accountObjList : ' + accountObjList);
                for (Account accountObj : accountObjList){
                    accountOptionsList.add(new Map<String, String>{ 'value' => accountObj.Name, 'label' => accountObj.Name });
                }
            }
        } catch (Exception exp){
            System.debug('Account list not found for the record type');
            throw new AuraHandledException('Account list not found for the record type, please check');
        }
        return accountOptionsList;
    }

    public static String getContactAccountId(String contactId){
        String contactAccountId = '';

        if (null != contactId){
            List<Contact> contactObjList = null;

            try{
                contactObjList = [SELECT AccountId
                                  FROM Contact
                                  WHERE Id = :contactId];

                if (!contactObjList.isEmpty()){
                    Contact contactOjb = contactObjList.get(0);
                    contactAccountId = contactOjb.AccountId;
                }
            } catch (QueryException exp){
                System.debug('No contact found for Id :' + contactId);
            }
        }
        return contactAccountId;
    }

    public static String getContactAccountName(String contactId){

        List<Contact> contactObjList = [SELECT AccountId, Account_Asher_Formula__c
                                        FROM Contact
                                        WHERE Id = :contactId];

        String contactAccountName;
        if (!contactObjList.isEmpty()){
            Contact contactOjb = contactObjList.get(0);
            contactAccountName = contactOjb.Account_Asher_Formula__c;
        }
        return contactAccountName;
    }

    public static Contact getContact(String recordId){
        Contact contact = new Contact();

        if (null != recordId){
            try{
                contact = [SELECT Id, Type__c, AccountId, Name, Account_Asher_Formula__c, Phone, Email, BPM_Contact_Id__c, Roofstock_Account_ID_F__c, Roofstock_User_Id__c, FirstName, LastName
                           FROM Contact
                           WHERE Id = :recordId
                           LIMIT 1];
            } catch (QueryException exp){
                System.debug('No contact found with Id :' + recordId);
            }
        }
        return contact;
    }

    private static Account getEMDAccount(){
        Account account = new Account();
        try{
            account = [SELECT Id, Name
                       FROM Account
                       WHERE Roofstock_Account_ID__c = '1'
                       LIMIT 1];
        } catch (QueryException exp){
            System.debug('No account found with Roofstock_Account_ID__c = 1');
        }
        return account;
    }

    private static User getUser(String recordId){
        User user = new User();

        if (null != recordId){
            try{
                user = [SELECT Id, Name
                        FROM User
                        WHERE Id = :recordId
                        LIMIT 1];
            } catch (QueryException exp){
                System.debug('No user found with Id :' + recordId);
            }
        }
        return user;
    }

    private static Transaction_Settlement__c getTransactionSettlement(String recordId, String description){
        Transaction_Settlement__c txnSettlement = new Transaction_Settlement__c();

        if (null != recordId){
            try{
                txnSettlement = [SELECT Id, Description__c, Unit_Price__c, Unique_Id__c, Transaction_Id__c
                                 FROM Transaction_Settlement__c
                                 WHERE Transaction__c = :recordId AND Description__c = :description
                                 LIMIT 1];
            } catch (QueryException exp){
                System.debug('No transaction settlement found with Id :' + recordId);
            }
        }
        return txnSettlement;
    }

    private static Inspection__c getInspection(String recordId){
        Inspection__c inspection = new Inspection__c();

        if (String.isNotBlank(recordId)){
            try{
                inspection = [SELECT Access_Notes__c, Access_Type__c, Acquisition_Id__c, Acquisition_Notes__c, BPM_Inspection_Id__c, Dilligence_Id__c, Due_Diligence_Notes__c, Id, Inspection_Account__c, Inspection_Completed_Date__c, Inspection_Due_Date__c, Inspection_Needed__c, Inspection_Scheduled_Date__c, Inspection_Status__c, Inspection_Type__c, Name, Project_Manager__c, Property__c, Scheduled_Notes__c, Send_Email_to_Inspector__c, Source__c, Transaction__c
                              FROM Inspection__c
                              WHERE Transaction__c = :recordId
                              ORDER BY CreatedDate DESC
                              limit 1];

            } catch (QueryException exp){
                System.debug('No inspection found with Id :' + recordId);
                // throw new AuraHandledException('Inspection details not found, please check');
            }
        }
        return inspection;
    }

    //HOA
    private static Property2__c getProperty(String recordId){
        Property2__c Property = new Property2__c();

        if (String.isNotBlank(recordId)){
            try{
                property = [SELECT HOA__c, Id, Name
                            FROM Property2__c
                            WHERE id = :[
                            SELECT Buyer_Property_Instance__c
                            FROM Transaction__c
                            WHERE id = :recordId].Buyer_Property_Instance__c
                            LIMIT 1];
            } catch (QueryException exp){
                System.debug('No Property found with Id :' + recordId);
                throw new AuraHandledException('Property details not found, please check');
            }
        }
        return property;
    }

    public static Task getTask(String recordId){
        Task task = new Task();
        if (null != recordId){

            try{
                task = [SELECT Id, Status, Subject, CompletedDateTime, Completed_Date__c, Description, ActivityDate, ActivityCreatedDateTime__c, Owner_Stamp__c, Assigned_On__c, OwnerId
                        from TASK
                        WHERE Type = 'QC: Contract Audit' AND WhatId = :recordId
                        LIMIT 1];
            } catch (QueryException e){
                System.debug('No QC contract audit task found for txn :' + recordId);
                throw new AuraHandledException('Task details not found, please check');
            }
        }
        return task;
    }

    public static List<Property_Unit__c> getPropertyUnitList(String recordId){
        List<Property_Unit__c> propertyUnitList = new List<Property_Unit__c>();

        if (null != recordId){
            try{
                propertyUnitList = [SELECT Id, name, Occupancy_at_Closing__c, Property_Access_Notes__c, PropertyUnitId__c, Property_Access_Method_Type__c, HomeCode__c
                                    FROM Property_Unit__c
                                    where Property__c = :[
                                    select id
                                    FROM property2__c
                                    where id = :[
                                    SELECT Buyer_Property_Instance__c
                                    FROM Transaction__c
                                    where id = :recordId].Buyer_Property_Instance__c].id
                                    ORDER BY HomeCode__c];
            } catch (QueryException exp){
                System.debug('No QC contract audit task found for txn :' + recordId);
                throw new AuraHandledException('Property unit details not found, please check');
            }
        }
        return propertyUnitList;
    }

    private static String getState(String recordId){
        String state = '';

        if (null != recordId){
            try{
                Property2__c Property = [SELECT State__c
                                         FROM Property2__c
                                         where id = :[
                                         SELECT Buyer_Property_Instance__c
                                         FROM Transaction__c
                                         where id = :recordId and Transaction_Type__c = 'Acquisition Buy'].Buyer_Property_Instance__c
                                         limit 1];
                state = Property.State__c;

            } catch (QueryException exp){
                System.debug('No state found for record Id : ' + recordId);
            }
        }
        return state;
    }

    @AuraEnabled
    public static void updateTask(ContractQCController.ContractQCWrapper wrapper){

        if (null != wrapper){
            try{
                Task taskRecord = new Task(Id = wrapper.task.Id);
                taskRecord.Status = wrapper.task.Status;
                taskRecord.Description = wrapper.task.Description;
                taskRecord.OwnerId = wrapper.task.OwnerId;

                update taskRecord;
            } catch (DmlException exp){
                System.debug('Error updatinng task object for txn : ' + wrapper.task.Id);
                throw new AuraHandledException('Error updating the Task!');
            }
        }
    }

    @AuraEnabled
    public static void updateTransactionContact(String recordId, Transaction_Contact__c txnContact, String contactType){
        try{
            if (String.isBlank(txnContact.Id)){
                // Transaction contact doesnt exist, set values for insert
                if (String.isNotBlank(txnContact.Contact__c)){
                    System.debug('Transaction contact object is not present so inserting');
                    txnContact.Transaction__c = recordId;
                    txnContact.Contact_Type__c = contactType;
                    txnContact.Contact_Count__c = 1;
                    txnContact.Contact__c = txnContact.Contact__c;
                    txnContact.Unique_Id__c = txnContact.Contact__c + recordId + contactType + 1;
                    insert txnContact;
                }
            } else{
                System.debug('Transaction contact object to update : ' + txnContact);
                update txnContact;
            }
        } catch (DmlException exp){
            System.debug('Error inserting/updating transaction contact object for txn : ' + recordId);
            throw new AuraHandledException('Error updating the transaction contact!');
        }
    }

    @AuraEnabled
    public static void upsertTransactionSettlement(Transaction_Settlement__c txnSettlement, String txnRecordId){
        try{
            if (null != txnSettlement){
                if (String.isBlank(txnSettlement.Id)){
                    // Transaction settlement doesnt exist, set values for insert
                    System.debug('Transaction settlement object is not present so inserting');
                    txnSettlement.Transaction__c = txnRecordId;
                    txnSettlement.Unique_Id__c = txnSettlement.Transaction_Id__c + txnSettlement.Description__c;
                    insert txnSettlement;
                } else{
                    System.debug('Transaction Settlment object to update : ' + txnSettlement);
                    update txnSettlement;
                }
            }
        } catch (DmlException exp){
            System.debug('Error inserting/updating transaction settlement object for txn : ' + txnRecordId);
            throw new AuraHandledException('Error updating the transaction settlement!');
        }
    }

    @AuraEnabled
    public static void publishPlatformEvent(String eventStringJSON){
        String stageType = 'Contract QC';

        ContractQCController.ContractQCWrapper wrapper = (ContractQCController.ContractQCWrapper)JSON.deserialize(eventStringJSON, ContractQCController.ContractQCWrapper.class);

        Set<TransactionPlatformEventWrapper.TransactionContact> transactionContactSet = new Set<TransactionPlatformEventWrapper.TransactionContact>();
        Set<TransactionPlatformEventWrapper.Inspection> inspectionSet = new Set<TransactionPlatformEventWrapper.Inspection>();
        Set<TransactionPlatformEventWrapper.PropertyUnit> propertyUnitSet = new Set<TransactionPlatformEventWrapper.PropertyUnit>();
        Transaction__c transactionRecord = new Transaction__c();

        if (wrapper != null){

            if (wrapper.transactionRecord != null){
                transactionRecord = wrapper.transactionRecord;
                if (null == transactionRecord.Transaction_Notes__c){
                    transactionRecord.Transaction_Notes__c = '';
                }
            }

            if (wrapper.inspectionRecord != null){
                TransactionPlatformEventWrapper.Inspection inspectionObj = new TransactionPlatformEventWrapper.Inspection();
                inspectionObj.inspectionId = wrapper.inspectionRecord.Id;
                //inspectionObj.diligenceDeadline = wrapper.inspectionRecord.Inspection_Scheduled_Date__c.format();
                inspectionObj.inspectionDueDate = wrapper.inspectionRecord.Inspection_Due_Date__c.format();
                inspectionSet.add(inspectionObj);
            }

            if (wrapper.propertyUnitList != null && wrapper.propertyUnitList.size() > 0){
                for (Property_Unit__c propertyUnitWrap : wrapper.propertyUnitList){
                    TransactionPlatformEventWrapper.PropertyUnit propertyUnitObj = new TransactionPlatformEventWrapper.PropertyUnit();
                    propertyUnitObj.id = propertyUnitWrap.Id;
                    propertyUnitObj.unitId = propertyUnitWrap.PropertyUnitId__c;
                    propertyUnitObj.property_access_notes = propertyUnitWrap.Property_Access_Notes__c;
                    propertyUnitObj.property_access_method_type = propertyUnitWrap.Property_Access_Method_Type__c;//Fixme
                    propertyUnitObj.occupancy = propertyUnitWrap.Occupancy_at_Closing__c;
                    propertyUnitSet.add(propertyUnitObj);
                }
            }

            TransactionPlatformEventWrapper.Property property;
            if (wrapper.propertyRecord != null){
                property = new TransactionPlatformEventWrapper.Property();
                property.hoa = wrapper.propertyRecord.HOA__c;
            }

            TransactionPlatformEventWrapper.transactionSettlement transactionSettlementObj = new TransactionPlatformEventWrapper.transactionSettlement();
            if (null != wrapper.emdAmount){
                transactionSettlementObj.emdAmount = wrapper.emdAmount.Unit_Price__c;
            }
            if (null != wrapper.optionFeeAmount){
                transactionSettlementObj.optionFeeAmount = wrapper.optionFeeAmount.Unit_Price__c;
            }

            if (wrapper.buyerTransactionContact != null && wrapper.buyerSignerContact != null){
                TransactionPlatformEventWrapper.TransactionContact transactionContact = new TransactionPlatformEventWrapper.TransactionContact();
                transactionContact.type = wrapper.buyerTransactionContact.Contact_Type__c;
                // Contact Object
                transactionContact.mobile = wrapper.buyerSignerContact.Phone;
                transactionContact.email = wrapper.buyerSignerContact.Email;
                transactionContact.bpmContactId = wrapper.buyerSignerContact.BPM_Contact_Id__c;
                transactionContact.rsAccountId = wrapper.buyerSignerContact.Roofstock_Account_ID_F__c;
                transactionContact.roofstockUserId = wrapper.buyerSignerContact.Roofstock_User_Id__c;
                transactionContact.firstName = wrapper.buyerSignerContact.FirstName;
                transactionContact.lastName = wrapper.buyerSignerContact.LastName;
                transactionContact.companyName = wrapper.buyerSignerContact.Account_Asher_Formula__c;
                transactionContactSet.add(transactionContact);
            }

            if (wrapper.sellerTransactionContact != null && wrapper.brokerSellerContact != null){
                TransactionPlatformEventWrapper.TransactionContact transactionContact = new TransactionPlatformEventWrapper.TransactionContact();
                transactionContact.type = wrapper.sellerTransactionContact.Contact_Type__c;
                // Contact Object
                transactionContact.mobile = wrapper.brokerSellerContact.Phone;
                transactionContact.email = wrapper.brokerSellerContact.Email;
                transactionContact.bpmContactId = wrapper.brokerSellerContact.BPM_Contact_Id__c;
                transactionContact.rsAccountId = wrapper.brokerSellerContact.Roofstock_Account_ID_F__c;
                transactionContact.roofstockUserId = wrapper.brokerSellerContact.Roofstock_User_Id__c;
                transactionContact.firstName = wrapper.brokerSellerContact.FirstName;
                transactionContact.lastName = wrapper.brokerSellerContact.LastName;
                transactionContact.companyName = wrapper.brokerSellerContact.Account_Asher_Formula__c;
                transactionContactSet.add(transactionContact);
            }

            if (wrapper.titleCompanyContact != null && wrapper.titleContact != null){
                TransactionPlatformEventWrapper.TransactionContact transactionContact = new TransactionPlatformEventWrapper.TransactionContact();
                transactionContact.type = wrapper.titleCompanyContact.Contact_Type__c;
                // Contact Object
                transactionContact.mobile = wrapper.titleContact.Phone;
                transactionContact.email = wrapper.titleContact.Email;
                transactionContact.bpmContactId = wrapper.titleContact.BPM_Contact_Id__c;
                transactionContact.rsAccountId = wrapper.titleContact.Roofstock_Account_ID_F__c;
                transactionContact.roofstockUserId = wrapper.titleContact.Roofstock_User_Id__c;
                transactionContact.firstName = wrapper.titleContact.FirstName;
                transactionContact.lastName = wrapper.titleContact.LastName;
                transactionContact.companyName = wrapper.titleContact.Account_Asher_Formula__c;
                transactionContactSet.add(transactionContact);
            }

            TransactionPlatformEventWrapper.transactionContractQcTask transactionTask = new TransactionPlatformEventWrapper.transactionContractQcTask();
            if (wrapper.task != null){
                transactionTask.status = wrapper.task.Status;
                transactionTask.description = wrapper.task.Description;
            }

            TransactionHelper.publishTransactionPlatformEvents(stageType, transactionRecord, transactionContactSet, inspectionSet, propertyUnitSet, transactionSettlementObj, transactionTask, property);
        }
    }

    @AuraEnabled(cacheable = true)
    public static Id getRecordTypeId(String recordTypeLabel){
        Id recTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();
        return recTypeId;
    }

    private static ReviewWrapper getReviewChecklistRecords(String transactionRecordId, String state, String originationSource){

        ReviewWrapper reviewWrapper = new ReviewWrapper();

        //Property Unit List
        List<Property_Unit__c> propertyUnitList = getPropertyUnitList(transactionRecordId);

        Integer occupancyStatusOrder;
        Set<String> setChecklistsBySource = new Set<String>();
        Set<String> setDocumentsBySource = new Set<String>();
        Map<String, String> mapDocumentHelpText = new Map<String, String>();
        for (FieldMapping__mdt FieldMapping : [SELECT Id, MasterLabel, IsDocument__c, Origination_Source__c, Sort_Order__c, Help_Text__c
                                               FROM FieldMapping__mdt
                                               ORDER BY Sort_Order__c]){
            if (FieldMapping.Origination_Source__c != null){
                if (originationSource.startsWith('MLS')){
                    if ((FieldMapping.Origination_Source__c).contains('MLS')){
                        if (FieldMapping.IsDocument__c){
                            setDocumentsBySource.add(FieldMapping.MasterLabel);
                            mapDocumentHelpText.put(FieldMapping.MasterLabel, FieldMapping.Help_Text__c);
                        } else{
                            setChecklistsBySource.add(FieldMapping.MasterLabel);
                            if (FieldMapping.MasterLabel == 'Occupancy Status'){
                                occupancyStatusOrder = Integer.valueOf(FieldMapping.Sort_Order__c);
                            }
                        }
                    }
                } else if (originationSource.startsWith('Off Market')){
                    if ((FieldMapping.Origination_Source__c).contains('Off Market')){
                        if (FieldMapping.IsDocument__c){
                            setDocumentsBySource.add(FieldMapping.MasterLabel);
                            mapDocumentHelpText.put(FieldMapping.MasterLabel, FieldMapping.Help_Text__c);
                        } else{
                            setChecklistsBySource.add(FieldMapping.MasterLabel);
                            if (FieldMapping.MasterLabel == 'Occupancy Status'){
                                occupancyStatusOrder = Integer.valueOf(FieldMapping.Sort_Order__c);
                            }
                        }
                    }
                }
            }
        }

        // Allowed occupancy status fields based on property unit #
        Set<String> allowedOccupancySet = new Set<String>();
        for (Property_Unit__c pu : propertyUnitList){
            String occupancyField = 'Occupancy Status';
            if (null != pu.HomeCode__c){
                occupancyField = occupancyField + '-' + pu.HomeCode__c;
            }
            allowedOccupancySet.add(occupancyField);
        }

        List<Transaction_Snapshot__c> checklists = new List<Transaction_Snapshot__c>();
        List<Transaction_Snapshot__c> documents = new List<Transaction_Snapshot__c>();
        // Populate the lists from database (split checklists & documents)
        Set<String> txnSnapshotFromDB = new Set<String>();
        List<Transaction_Snapshot__c> transactionSnapshotList = null;
        try{
            transactionSnapshotList = [SELECT Id, Review_Checklist_Type__c, Original_Broker_Entry__c, TC_Updates__c, Verify__c, Sort_Order__C, Help_Text__c, HomeCode__c
                                       FROM Transaction_Snapshot__c
                                       WHERE Transaction__c = :transactionRecordId
                                       ORDER BY Sort_Order__C];

            for (Transaction_Snapshot__c rc : transactionSnapshotList){

                if (setDocumentsBySource.contains(rc.Review_Checklist_Type__c)){
                    rc.Help_Text__c = mapDocumentHelpText.get(rc.Review_Checklist_Type__c);
                    documents.add(rc);
                } else if (setChecklistsBySource.contains(rc.Review_Checklist_Type__c) && rc.Review_Checklist_Type__c != 'Occupancy Status'){
                    if ('Option Fee' == rc.Review_Checklist_Type__c){
                        if ('TX' == state || 'NC' == state){
                            checklists.add(rc);
                        }
                    } else{
                        checklists.add(rc);
                    }
                } else if (rc.Review_Checklist_Type__c.startsWith('Occupancy Status')){
                    // Display Occupancy Status only if it is in the allowed list
                    if (allowedOccupancySet.contains(rc.Review_Checklist_Type__c)){
                        checklists.add(rc);
                    }
                }
                txnSnapshotFromDB.add(rc.Review_Checklist_Type__c);
            }
        } catch (QueryException exp){
            System.debug('No transaction snapshots found for txn Id :' + transactionRecordId);
        }

        // Populate lists from picklist if no records in transaction snapshot
        if (transactionSnapshotList.isEmpty()){

            reviewWrapper.isDefaultChecklist = true;

            Integer i = 0;
            // Add checklists
            for (String checklistType : setChecklistsBySource){
                Transaction_Snapshot__c transactionSnapshot = new Transaction_Snapshot__c();
                transactionSnapshot.Review_Checklist_Type__c = checklistType;
                transactionSnapshot.Sort_Order__C = i++;

                //Metadata has Occupancy status so skip here to avoid duplicate
                if (!'Occupancy Status'.equalsIgnoreCase(checklistType)){
                    checklists.add(transactionSnapshot);
                }
            }

            // Add documents
            for (String documentType : setDocumentsBySource){
                Transaction_Snapshot__c transactionSnapshot = new Transaction_Snapshot__c();
                transactionSnapshot.Review_Checklist_Type__c = documentType;
                transactionSnapshot.Sort_Order__C = i++;

                transactionSnapshot.Help_Text__c = mapDocumentHelpText.get(documentType);
                documents.add(transactionSnapshot);
            }

            // Add 'Occupancy Status' for each property unit if not already present
            for (Property_Unit__c pu : propertyUnitList){
                String occupancyField = 'Occupancy Status';
                if (null != pu.HomeCode__c){
                    occupancyField = occupancyField + '-' + pu.HomeCode__c;
                }
                if (!txnSnapshotFromDB.contains(occupancyField)){
                    Transaction_Snapshot__c transactionSnapshot = new Transaction_Snapshot__c();
                    transactionSnapshot.Review_Checklist_Type__c = occupancyField;
                    transactionSnapshot.Sort_Order__C = i++;
                    transactionSnapshot.HomeCode__c = pu.HomeCode__c;
                    checklists.add(transactionSnapshot);
                }
            }
        } else{
            // Add 'Occupancy Status' for each property unit if not already present
            for (Property_Unit__c pu : propertyUnitList){
                String occupancyField = 'Occupancy Status';
                if (null != pu.HomeCode__c){
                    occupancyField = occupancyField + '-' + pu.HomeCode__c;
                }

                if (!txnSnapshotFromDB.contains(occupancyField)){
                    Transaction_Snapshot__c transactionSnapshot = new Transaction_Snapshot__c();
                    transactionSnapshot.Review_Checklist_Type__c = occupancyField;
                    transactionSnapshot.Sort_Order__C = occupancyStatusOrder++;
                    transactionSnapshot.HomeCode__c = pu.HomeCode__c;
                    checklists.add(transactionSnapshot);
                }
            }
        }

        reviewWrapper.lstReviewChecklist = TransactionSnapshotWrapper.sortTransactionSnapshots(checklists);
        reviewWrapper.lstDocuments = documents;
        return reviewWrapper;
    }

    public class ReviewWrapper{
        @AuraEnabled
        public List<Transaction_Snapshot__c> lstReviewChecklist{ get; set; }

        @AuraEnabled
        public List<Transaction_Snapshot__c> lstDocuments{ get; set; }

        @AuraEnabled
        public Boolean isDefaultChecklist{ get; set; }

    }

    private static String getAccountName(String recordId){
        String accountName = '';

        if (String.isNotBlank(recordId)){
            try{
                Account account = [SELECT Id, Name
                                   FROM Account
                                   WHERE Id = :recordId
                                   LIMIT 1];
                if (null != account){
                    accountName = account.Name;
                }
            } catch (QueryException exp){
                System.debug('No account found with Id :' + recordId);
                throw new AuraHandledException('Account not found, please check');
            }
        }
        return accountName;
    }

}
public with sharing class SubmitEMDController{
    public class SubmitEMDWrapper{
        @AuraEnabled
        public Transaction__c transactionRecord{ get; set; }

        @AuraEnabled
        public Transaction_Settlement__c txnSettlementRecord{ get; set; }

        @AuraEnabled
        public Task task{ get; set; }

        @AuraEnabled
        public String state{ get; set; }

        @AuraEnabled
        public Account buyerPMAccount{ get; set; }

        @AuraEnabled
        public Account titleContactAccount{ get; set; }

        @AuraEnabled
        public Contact buyerPMContact{ get; set; }

        @AuraEnabled
        public Contact titleContact{ get; set; }

        @AuraEnabled
        public Transaction_Settlement__c emdAmount{ get; set; }

        @AuraEnabled
        public Transaction_Settlement__c optionFeeAmount{ get; set; }

    }

    @AuraEnabled
    public static SubmitEMDWrapper getSubmitEMDData(String recordId){
        SubmitEMDWrapper submitEMDWrapper = new SubmitEMDWrapper();

        //Transaction Object
        Transaction__c transactionObj = [SELECT Id, Sale_Price__c, EMD_Status__c, Emd_Wired_On_Date__c, In_Contract_Date__c, Est_Close_Date__c, EMD_Option_Fee_Status__c, EMD_Due_Date__c, EMD_Account__c, Roofstock_Accounting__c, Title_Company_Contact__c, Account__c, Transaction_Id__c, Transaction_Notes__c
                                         FROM Transaction__c
                                         WHERE id = :recordId
                                         limit 1];
        submitEMDWrapper.transactionRecord = transactionObj;

        // If EMD Wired On Date is blank, set it to current date
        if (null == submitEMDWrapper.transactionRecord.Emd_Wired_On_Date__c){
            submitEMDWrapper.transactionRecord.Emd_Wired_On_Date__c = Date.today();
        }

        //Transaction Settlement Objects
        submitEMDWrapper.optionFeeAmount = getTransactionSettlement(recordId, 'Option Fee');
        submitEMDWrapper.emdAmount = getTransactionSettlement(recordId, 'Earnest Money Deposit');

        // If Option Fee is <0, then set Option Fee Required as Not Needed
        // if (submitEMDWrapper.optionFeeAmount.Unit_Price__c <= 0 || null == submitEMDWrapper.optionFeeAmount.Unit_Price__c){
        //     submitEMDWrapper.transactionRecord.EMD_Option_Fee_Status__c = 'Not Needed';
        // } else{
        //     submitEMDWrapper.transactionRecord.EMD_Option_Fee_Status__c = 'Required';
        // }

        //Task Object
        submitEMDWrapper.task = getTask(recordId);

        // Buyer PM Account
        Transaction_Contact__c buyerPMTransactionContact = getTransactionContact(recordId, 'PM Buyer');
        Contact buyerPMContact = getContact(buyerPMTransactionContact.Contact__c);
        if (null != buyerPMContact){
            submitEMDWrapper.buyerPMContact = buyerPMContact;
            submitEMDWrapper.buyerPMAccount = getAccount(buyerPMContact.AccountId);
        }

        // Title Contact Account
        Transaction_Contact__c titleCompanyContact = getTransactionContact(recordId, 'Title');
        Contact tileContact = getContact(titleCompanyContact.Contact__c);
        if (null != tileContact){
            submitEMDWrapper.titleContact = tileContact;
            submitEMDWrapper.titleContactAccount = getAccount(tileContact.AccountId);
        }

        submitEMDWrapper.state = getState(recordId);

        return submitEMDWrapper;
    }

    private static Contact getContact(String recordId){

        Contact contact = new Contact();
        if (String.isNotBlank(recordId)){
            try{
                contact = [SELECT Id, Type__c, AccountId, Name, Account_Asher_Formula__c, Phone, Email, BPM_Contact_Id__c, Roofstock_Account_ID_F__c, Roofstock_User_Id__c, FirstName, LastName
                           FROM Contact
                           WHERE Id = :recordId
                           LIMIT 1];
            } catch (QueryException exp){
                System.debug('No contact found with Id :' + recordId);
                throw new AuraHandledException('Contact not found, please check');
            }
        }
        return contact;
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

    private static Transaction_Contact__c getTransactionContact(String txnRecordId, String contactType){
        List<Transaction_Contact__c> transactionContactList = null;
        Transaction_Contact__c transactionContactOjb = new Transaction_Contact__c();

        // Order by Contact_Count_c & take first record
        try{
            transactionContactList = [SELECT Contact__c, Id, Contact_Type__c
                                      FROM Transaction_Contact__c
                                      WHERE Transaction__c = :txnRecordId AND Contact_Type__c = :contactType
                                      ORDER BY Contact_Type__c];

            if (null != transactionContactList){
                if (!transactionContactList.isEmpty()){
                    transactionContactOjb = transactionContactList.get(0);
                }
            }
        } catch (QueryException exp){
            System.debug('No transaction contact found for txn Id :' + txnRecordId);
            throw new AuraHandledException('Transaction contact details not found, please check : ' + contactType);
        }

        return transactionContactOjb;
    }

    private static Task getTask(String recordId){
        Task task = new Task();
        if (null != recordId){

            try{
                task = [SELECT Id, Status, Subject, CompletedDateTime, Completed_Date__c, Description, ActivityDate, ActivityCreatedDateTime__c, Owner_Stamp__c, Assigned_On__c, OwnerId
                        from TASK
                        WHERE Type = 'Submit EMD' AND WhatId = :recordId
                        limit 1];
            } catch (QueryException e){
                System.debug('No Submt EMD audit task found for txn Id :' + recordId);
                throw new AuraHandledException('Task details not found, please check');
            }
        }
        return task;
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

    private static Account getAccount(String recordId){
        Account account = new Account();

        if (String.isNotBlank(recordId)){
            try{
                account = [SELECT Id, Name, Transaction_Instructions__c
                           FROM Account
                           WHERE Id = :recordId
                           LIMIT 1];
            } catch (QueryException exp){
                System.debug('No account found with Id :' + recordId);
                throw new AuraHandledException('Account not found, please check');
            }
        }
        return account;
    }

    @AuraEnabled
    public static void completeTask(String taskId, String recordId){
        Task taskRecord = new Task(Id = taskId, Status = 'Completed');
        update taskRecord;

        TransactionDetails.updateMilestone(recordId);
    }

    @AuraEnabled
    public static void updateTask(SubmitEMDController.SubmitEMDWrapper wrapper){

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
    public static void publishPlatformEvent(String eventStringJSON){

        String stageType = 'Submit EMD';

        SubmitEMDController.SubmitEMDWrapper wrapper = (SubmitEMDController.SubmitEMDWrapper)JSON.deserialize(eventStringJSON, SubmitEMDController.SubmitEMDWrapper.class);


        Set<TransactionPlatformEventWrapper.TransactionContact> transactionContactSet = new Set<TransactionPlatformEventWrapper.TransactionContact>();
        Transaction__c transactionRecord = new Transaction__c();
        System.debug('-wrapper-' + wrapper);
        if (wrapper != null){

            if (wrapper.transactionRecord != null){
                transactionRecord = wrapper.transactionRecord;
                if (null == transactionRecord.Transaction_Notes__c){
                    transactionRecord.Transaction_Notes__c = '';
                }
            }

            TransactionPlatformEventWrapper.transactionSettlement transactionSettlementObj;
            if (wrapper.txnSettlementRecord != null){
                transactionSettlementObj = new TransactionPlatformEventWrapper.transactionSettlement();
                if (null != wrapper.emdAmount){
                    transactionSettlementObj.emdAmount = wrapper.emdAmount.Unit_Price__c;
                }
                if (null != wrapper.optionFeeAmount){
                    transactionSettlementObj.optionFeeAmount = wrapper.optionFeeAmount.Unit_Price__c;
                }
            }

            if (null != wrapper.buyerPMContact){
                TransactionPlatformEventWrapper.TransactionContact transactionContact = new TransactionPlatformEventWrapper.TransactionContact();
                transactionContact.type = 'PM Buyer';

                // Contact Object
                transactionContact.mobile = wrapper.buyerPMContact.Phone;
                transactionContact.email = wrapper.buyerPMContact.Email;
                transactionContact.bpmContactId = wrapper.buyerPMContact.BPM_Contact_Id__c;
                transactionContact.rsAccountId = wrapper.buyerPMContact.Roofstock_Account_ID_F__c;
                transactionContact.roofstockUserId = wrapper.buyerPMContact.Roofstock_User_Id__c;
                transactionContact.firstName = wrapper.buyerPMContact.FirstName;
                transactionContact.lastName = wrapper.buyerPMContact.LastName;
                transactionContact.companyName = wrapper.buyerPMContact.Account_Asher_Formula__c;
                transactionContactSet.add(transactionContact);
            }

            if (null != wrapper.titleContact){
                TransactionPlatformEventWrapper.TransactionContact transactionContact = new TransactionPlatformEventWrapper.TransactionContact();
                transactionContact.type = 'Title';

                // Contact Object
                transactionContact.email = wrapper.titleContact.Email;
                transactionContact.bpmContactId = wrapper.titleContact.BPM_Contact_Id__c;
                transactionContact.rsAccountId = wrapper.titleContact.Roofstock_Account_ID_F__c;
                transactionContact.roofstockUserId = wrapper.titleContact.Roofstock_User_Id__c;
                transactionContact.firstName = wrapper.titleContact.FirstName;
                transactionContact.lastName = wrapper.titleContact.LastName;
                transactionContact.companyName = wrapper.titleContact.Account_Asher_Formula__c;

                transactionContactSet.add(transactionContact);
            }
            System.debug('-wrapper-' + wrapper);
            TransactionPlatformEventWrapper.transactionContractQcTask transactionTask = new TransactionPlatformEventWrapper.transactionContractQcTask();
            if (wrapper.task != null){
                transactionTask.status = wrapper.task.Status;
                transactionTask.description = wrapper.task.Description;
            }

            System.debug('transactionRecord::' + transactionRecord);

           TransactionHelper.publishTransactionPlatformEvents(stageType, transactionRecord, transactionContactSet, null, null, transactionSettlementObj, transactionTask, null);
        }
    }

}
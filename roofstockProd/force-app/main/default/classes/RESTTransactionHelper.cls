global class RESTTransactionHelper{
    global class TransactionsWrap{
        global List<Transactions> transactionList;
    }

    global class Transactions{
        global String name;
        global String transactionId;
        global String portfolioTransactionId;
        //global String propertyId;
        global String sellerPropertyId;
        global String buyerPropertyId;
        global String listingId;
        global String offerId;
        global String city;
        global string state;
        global string zip;
        global String status;
        global String salePrice;
        global String listPrice;
        global String address;
        global String propertyType;
        global String startDate;
        global String createdDate;
        global String inContractDate;
        global String estimatedCloseDate;
        global String escrowCloseDate;
        global String contingencyExpirationDate;
        global boolean isContingency;
        global String cancellationDate;
        global String appraisalExpirationDate;
        global String transactionCordinatorEmail;
        global String customerServiceEmail;
        global String inventoryEmail;
        global String accountManagerEmail;
        global String accountingEmail;
        global String projectManagerEmail;
        global String buyerContact1Email;
        global String buyerContact1Phone;
        global String buyerContact2Email;
        global String buyerContact2Phone;
        global String sellerContactEmail;
        global String sellerContactPhone;
        //PE-713
        global String titleCompanyRSAccountId;
        /*global string buyerContactId1;
         global string buyerContactId2;
         global string sellerContactId;
         global string inspectorContactId;
         //global string pmContactId;
         global string pmBuyerContactid ;
         global string pmSellerContactId;
         global string escrowContactId;
         global string titleContactId;
         global string insuranceContactId;
         global string lendorContactId;
         global string buyerBrokerContactId;
         global String sellerBrokerContactId;*/
        //RC-12304
        global String underwritingAnalystEmail;
        global String buyerEntity;
        global String roofstockAdvisorEmail;
        global String transactionType;
        global String scheduledInspectionDate;
        global String appraisalInspectionDate;
        global String underwritingAnalyst;
        global String listingSource; //Listing_Source__c
        //RC-14051 - financing Type
        global String financingType;
        //PMC-37
        global String contingenciesLiftDate;
        global String application;
        // PE-619
        global String contingencyStatus;
        //PE-630
        global String emdDueDate;
        global String emdReceivedDate;
        global List<RESTContactHelper.Contacts> contactsList;
        //TRN-415
        global String transactionNotes;
        global boolean enableYardiUpload;
        global String sellerEntity;
        global decimal emdAmount;
        global String emdOptionFeeStatus;
        global decimal optionFeeAmount;
        global String inspectionEmailCc;
        global String inspectionKickOffNotes;
        global String emdWiredOnDate;
        // PMC2022-231
        global decimal originalSalePrice;
        global String salesChannel;
        global String actualCapex;
        global String inspectionDueDate;
        global String brokerNotes;
        //Broker_Notes__c
        global String rootTaskType;
        global String leadOriginationSource;
        global decimal sellerCommissionMinAmount;
        global decimal buyerCommissionPercentage;
        global decimal sellerCommissionPercentage;
        global String inspectionNeeded;
        global String sendOpenEscrowEmail;
    }

    global class PostResponse{
        global ResponseWrapper responseBody;
        global PostResponse(List<ResponseBody> transactionResponse){
            this.responseBody = new ResponseWrapper(transactionResponse);
        }

    }

    global class ResponseWrapper{
        global List<ResponseBody> transactionResponse;

        global ResponseWrapper(){
            transactionResponse = new List<ResponseBody>();
        }

        global ResponseWrapper(List<ResponseBody> transactionResponse){
            this.transactionResponse = transactionResponse;
        }

    }

    global class ResponseBody{
        global String transactionId;
        global String salesforceId;
        global String threadId;
        global ResponseBody(String transactionId, String salesforceId, String threadId){
            this.transactionId = transactionId;
            this.salesforceId = salesforceId;
            this.threadId = threadId;
        }

    }

    global static PostResponse UpdateTransaction(List<Transactions> transactionList){
        List<ResponseBody> transactionResponseList = new List<ResponseBody>();
        Set<String> userInputEmailSet = new Set<String>();
        Set<String> transactionIdSet = new Set<String>();
        Set<String> contactIds = new Set<String>();
        Set<String> sellerPropertyInstanceIdSet = new Set<String>();
        Set<String> buyerPropertyInstanceIdSet = new Set<String>();
        Set<String> portfolioTransactionIdSet = new Set<String>();
        Map<String, RESTContactHelper.Contacts> allContactListMap = new Map<String, RESTContactHelper.Contacts>();
        RESTContactHelper.PostResponse conResponse;
        List<RESTContactHelper.ResponseBody> conRespBody = new List<RESTContactHelper.ResponseBody>();

        for (Transactions trans : transactionList){

            //Get Emails from the input string for users
            userInputEmailSet.add(trans.transactionCordinatorEmail);
            userInputEmailSet.add(trans.customerServiceEmail);
            userInputEmailSet.add(trans.inventoryEmail);
            userInputEmailSet.add(trans.accountManagerEmail);
            userInputEmailSet.add(trans.accountingEmail);
            userInputEmailSet.add(trans.projectManagerEmail);
            userInputEmailSet.add(trans.roofstockAdvisorEmail);
            //userInputEmailSet.add(trans.roofstockInventoryOwnerEmail);
            userInputEmailSet.add(trans.underwritingAnalystEmail);

            /* contactIds.add(trans.buyerContactId1);
             contactIds.add(trans.buyerContactId2);
             contactIds.add(trans.sellerContactId);
             contactIds.add(trans.inspectorContactId);
             //contactIds.add(trans.pmContactId);
             contactIds.add(trans.pmBuyerContactid);
             contactIds.add(trans.pmSellerContactId);
             contactIds.add(trans.escrowContactId);
             contactIds.add(trans.titleContactId);
             contactIds.add(trans.insuranceContactId);
             contactIds.add(trans.lendorContactId);
             contactIds.add(trans.buyerBrokerContactId);
             contactIds.add(trans.sellerBrokerContactId);*/
            //Set Of Tansaction Id's
            transactionIdSet.add(trans.transactionId);

            portfolioTransactionIdSet.add(trans.portfolioTransactionId);
            // seller Property Id's
            sellerPropertyInstanceIdSet.add(trans.sellerPropertyId);
            //buyer Property Id
            if (trans.buyerPropertyId != null){
                buyerPropertyInstanceIdSet.add(trans.buyerPropertyId);
            }

            for (RESTContactHelper.Contacts conWrap : trans.contactsList){
                allContactListMap.put(conWrap.bpmContactId, conWrap);
            }

        }
        // remove blanks and nulls
        contactIds.remove('');
        contactIds.remove(null);
        System.debug('-contact values-' + allContactListMap.values());
        if (allContactListMap.size() > 0){
            conResponse = RESTContactHelper.UpdateContact(allContactListMap.values());
            if (conResponse != null && conResponse.responseBody != null){
                RESTContactHelper.ResponseWrapper respWrap = conResponse.responseBody;
                conRespBody = respWrap.contactResponse;
                for (RESTContactHelper.ResponseBody res : conRespBody){
                    contactIds.add(res.bpmContactId);
                }
            }
        }

        //get record types
        Map<String, String> transactionRecordTypesMap = new Map<String, String>();
        List<RecordType> recTypeList = [select Id, developername, sObjectType
                                        from Recordtype
                                        where sObjectType = 'Transaction__c'];
        for (RecordType recordtype : recTypeList){
            transactionRecordTypesMap.put(recordtype.developername, recordtype.Id);
        }
        //Query for matching property and create a map of RoofstockInstanceId and Property
        Map<String, String> rsInstancePropertyMap = new Map<String, String>();
        List<Property2__c> matchingPropertyList = [select Id, PropertyId__c
                                                   from Property2__c
                                                   where (PropertyId__c IN:sellerPropertyInstanceIdSet OR PropertyId__c IN:buyerPropertyInstanceIdSet)];
        for (Property2__c ppt : matchingPropertyList){
            rsInstancePropertyMap.put(ppt.PropertyId__c, ppt.Id);
        }
        System.debug('=contactIds=' + contactIds);
        System.debug('=rsInstancePropertyMap=' + rsInstancePropertyMap);

        string transactionPortfolioRecordTypeId = transactionRecordTypesMap.get('Portfolio_Transaction');

        //Query for matching portfolio transactions and create a map !
        Map<String, String> portfolioTransactionsMap = new Map<String, String>();
        List<Transaction__c> matchingTransactionsList = [select Id, Listing_Source__c, Financing_Type__c, Portfolio_Transaction_Id__c
                                                         from Transaction__c
                                                         where Portfolio_Transaction_Id__c IN:portfolioTransactionIdSet and recordtypeid = :transactionPortfolioRecordTypeId];

        for (Transaction__c tt : matchingTransactionsList){
            portfolioTransactionsMap.put(tt.Portfolio_Transaction_Id__c, tt.Id);
        }

        //Query for the matching Contacts and create a map BPM Contact Id and Contact Id.
        Map<String, String> bpmContactIdMap = new Map<String, String>();
        List<Contact> matchingContactList = [select Id, BPM_Contact_Id__c, Email, Phone
                                             from Contact
                                             where (BPM_Contact_Id__c IN:contactIds)];

        if (matchingContactList.size() > 0){
            for (Contact con : matchingContactList){
                bpmContactIdMap.put(con.BPM_Contact_Id__c, con.Id);
            }
        }
        System.debug('=bpmContactIdMap=' + bpmContactIdMap);
        //Query for the matching Users and create a map of email and UserId
        Map<String, String> emailUserMap = new Map<String, String>();
        List<User> matchingUserList = [select Id, Email
                                       from User
                                       where Email IN:userInputEmailSet];
        if (matchingUserList.size() > 0){
            for (User usr : matchingUserList){
                emailUserMap.put((usr.Email).toLowerCase(), usr.Id);
            }
        }
        System.debug('=emailUserMap=' + emailUserMap);
        //TRN-415
        map<String, map<String, Transaction_Contact__c>> mapTransactionContact = new map<String, map<String, Transaction_Contact__c>>();
        for (Transaction_Contact__c transContact : [select Id, Type__c, Contact__c, Transaction__c, Transaction__r.Transaction_Id__c
                                                    from Transaction_Contact__c
                                                    where Transaction__r.Transaction_Id__c IN:transactionIdSet]){
            if (!mapTransactionContact.containskey(transContact.Transaction__r.Transaction_Id__c)){
                mapTransactionContact.put(transContact.Transaction__r.Transaction_Id__c, new map<String, Transaction_Contact__c>());
            }
            mapTransactionContact.get(transContact.Transaction__r.Transaction_Id__c).put(transContact.Type__c, transContact);
        }
        //Transaction Settlement
        map<String, map<String, Transaction_Settlement__c>> mapTransactionSettlement = new map<String, map<String, Transaction_Settlement__c>>();
        for (Transaction_Settlement__c transSettlement : [select Id, Description__c, Transaction__c, Transaction__r.Transaction_Id__c
                                                          from Transaction_Settlement__c
                                                          where Transaction__r.Transaction_Id__c IN:transactionIdSet]){
            if (!mapTransactionSettlement.containskey(transSettlement.Transaction__r.Transaction_Id__c)){
                mapTransactionSettlement.put(transSettlement.Transaction__r.Transaction_Id__c, new map<String, Transaction_Settlement__c>());
            }
            mapTransactionSettlement.get(transSettlement.Transaction__r.Transaction_Id__c).put(transSettlement.Transaction__r.Transaction_Id__c + transSettlement.Description__c, transSettlement);
        }

        //Query for existing transaction Id's and Create a map of transaction Id and Transactiion Record
        Map<String, Transaction__c> transactionIdTransactionMap = new Map<String, Transaction__c>();
        List<Transaction__c> existingTransactionList = [select Id, Name, Address1__c, Appraisal_Exp_Date__c, Bpm_Property_Id__c, Buyer_Broker_Contact__c, Buyer_Broker_Contact_Email__c, Buyer_Broker_Contact_Phone__c, Buyer_Contact1__c, Financing_Type__c, Buyer_Contact1_Email__c, Buyer_Contact2__c, Buyer_Contact2_Email__c, Buyer_Contact1_Phone__c, Buyer_Contact2_Phone__c, Buyer_PM_Contact_Phone__c, Cancellation_Date__c, Buyer_BPM_Contact_Email__c, City__c, Close_of_Escrow_Date__c, Closing_Attorney_Contact__c, Closing_Attorney_Contact_Email__c, Closing_Attorney_Contact_Phone__c, Escrow_Company_Contact__c, Escrow_Company_Contact_Email__c, Escrow_Company_Contact_Phone__c, Est_Close_Date__c, IC_Expiration_Date__c, Seller_Contact__c, In_Contract_Date__c, Inspection_Contingency__c, Insurance_Company_Contact__c, Insurance_Company_Contact_Email__c, Insurance_Company_Contact_Phone__c, Lender_Broker_Contact__c, Lender_Broker_Contact_Email__c, Lender_Broker_Contact_Phone__c, List_Price__c, Listing_Id__c, Offer_Id__c, Property_Type__c, Roofstock_Accounting__c, Roofstock_Accounting_Email__c, Roofstock_Account_Manager__c, Roofstock_Account_Manager_Email__c, Roofstock_Customer_Service__c, Roofstock_Customer_Service_Email__c, Roofstock_Inventory_Owner__c, Roofstock_Inventory_Owner_Email__c, Roofstock_Project_Manager__c, Roofstock_Project_Manager_Email__c, Roofstock_TC_User__c, Roofstock_TC_User_Email__c, Sale_Price__c, Seller_Contact_Email__c, Seller_Contact_Phone__c, Seller_Listing_Agent_Contact__c, Seller_Listing_Agent_Contact_Email__c, Seller_Listing_Agent_Contact_Phone__c, Seller_PM_Contact__c, Seller_PM_Contact_Email__c, Seller_PM_Contact_Phone__c, Start_Date__c, State__c, Title_Company_Contact__c, Title_Company_Contact_Email__c, Title_Company_Contact_Phone__c, Transaction_Id__c, Transaction_Created_Date__c, Transaction_Status__c, Zip__c, Buyer_Contact_Id_1__c, Buyer_Contact_Id_2__c, Seller_Contact_Id__c, Inspector_Contact_Id__c, Escrow_Contact_Id__c, Title_Contact_Id__c, Insurance_Contact_Id__c, Buyer_Broker_Contact_Id__c, Seller_Broker_Contact_Id__c, Property_Instance__c, Escrow_Contact__c, Lender_Contact__c, Inspector_Contact__c, Thread_Id__c, Title_Contact__c, Insurance_Contact__c, Lender_Contact_Id__c, Seller_Broker_Contact__c, PM_Buyer_Contact_Id__c, Property_Id__c, PM_Seller_Contact_Id__c, PM_Buyer_Contact__c, PM_Seller_Contact__c, Underwriting_Analyst_Email__c, Buyer_Entity__c, Roofstock_Advisor__c, Roofstock_Advisor_Email__c, Transaction_Type__C, Underwriting_Analyst__c, Scheduled_Inspection_Date__c, Appraisal_Inspection_Date__c, Listing_Source__c, Buyer_Property_Id__c, Buyer_Property_Instance__c, Application__c, Contingency_Status__c, EMD_Due_Date__c, EMD_Received_Date__c, Transaction_Notes__c, Enable_Yardi_Upload__c, Seller_Entity__c, EMD_Option_Fee_Status__c, Inspection_Email_Cc__c, Inspection_Kickoff_Notes__c, Origination_Source__c, Emd_Wired_On_Date__c, Broker_Notes__c, RootTaskType__c, Seller_Commission_Min_Amount__c, Buyer_Commission_Percent__c, Seller_Commission_Percent__c, Title_Company_Account__c
                                                        from Transaction__c
                                                        where Transaction_Id__c IN:transactionIdSet];

        if (existingTransactionList.size() > 0){
            for (Transaction__c existingtransact : existingTransactionList){
                transactionIdTransactionMap.put((existingtransact.Transaction_Id__c), existingtransact);
            }
        }

        //Update Existing transaction/Create a new Transaction
        List<Transaction__c> createNewTransaction = new List<Transaction__c>();
        List<Transaction__c> updateExistingTransaction = new List<Transaction__c>();
        Map<String, Transaction__c> transIdTransactionMapCreate = new Map<String, Transaction__c>();
        Map<String, Transaction__c> transIdTransactionMapUpdate = new Map<String, Transaction__c>();
        Id masterTransactionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Master Transaction').getRecordTypeId();
        List<Transaction_Contact__c> lstTransactionContact = new List<Transaction_Contact__c>();
        List<Transaction_Settlement__c> lstTransactionSettlement = new List<Transaction_Settlement__c>();
        for (Transactions inputtransaction : transactionList){

            if (transactionIdTransactionMap.containsKey(inputtransaction.transactionId)){
                Transaction__c existingTransaction = transactionIdTransactionMap.get(inputtransaction.transactionId);
                RESTTransactionHelper.TransactionAndTransContact updatedTransaction = createUpdateTransaction(existingTransaction, inputtransaction, emailUserMap, bpmContactIdMap, rsInstancePropertyMap, portfolioTransactionsMap, transactionRecordTypesMap, mapTransactionContact, mapTransactionSettlement);
                //updateExistingTransaction.add(updatedTransaction);
                transIdTransactionMapUpdate.put(updatedTransaction.trans.Transaction_Id__c, updatedTransaction.trans);
                if (updatedTransaction.transContact != null){
                    lstTransactionContact.addAll(updatedTransaction.transContact);
                }
                if (updatedTransaction.transSettlement != null){
                    lstTransactionSettlement.addAll(updatedTransaction.transSettlement);
                }
            } else{
                Transaction__c newTransaction = new Transaction__c();
                //newTransaction.Milestone__c = 'New Transaction';
                RESTTransactionHelper.TransactionAndTransContact newCreatedTransaction = createUpdateTransaction(newTransaction, inputtransaction, emailUserMap, bpmContactIdMap, rsInstancePropertyMap, portfolioTransactionsMap, transactionRecordTypesMap, mapTransactionContact, mapTransactionSettlement);
                //newCreatedTransaction.Thread_Id__c ='';
                System.debug('-newCreatedTransaction-' + newCreatedTransaction);
                if (newCreatedTransaction != null){
                    if (newCreatedTransaction.trans != null && newCreatedTransaction.trans.Transaction_Id__c != null)
                        transIdTransactionMapCreate.put(newCreatedTransaction.trans.Transaction_Id__c, newCreatedTransaction.trans);
                    if (newCreatedTransaction.transContact != null)
                        lstTransactionContact.addAll(newCreatedTransaction.transContact);
                    if (newCreatedTransaction.transSettlement != null)
                        lstTransactionSettlement.addAll(newCreatedTransaction.transSettlement);
                }
                //createNewTransaction.add(newCreatedTransaction);
            }
        }

        if (transIdTransactionMapUpdate.keyset().size() > 0){
            //update updateExistingTransaction;
            for (String transID : transIdTransactionMapUpdate.keyset()){
                updateExistingTransaction.add(transIdTransactionMapUpdate.get(transID));
            }
            if (!updateExistingTransaction.isEmpty()){
                update updateExistingTransaction;
            }

        }
        if (transIdTransactionMapCreate.keyset().size() > 0){
            //insert createNewTransaction;
            for (String transID : transIdTransactionMapCreate.keyset()){
                createNewTransaction.add(transIdTransactionMapCreate.get(transID));
            }
            if (!createNewTransaction.isEmpty()){
                insert createNewTransaction;
            }

        }

        /****create case for each of the new and existing Transactions if there is no thread id and update transaction with thread Id****/
        List<Transaction__c> newTransactionsWithUpdatedThredIdList = new List<Transaction__c>();
        Set<Transaction__c> mergedTransactionSet = new Set<Transaction__c>();
        System.debug('=createNewTransaction=' + createNewTransaction);

        //Logic to dedupe records
        updateExistingTransaction.addAll(createNewTransaction);

        set<Transaction__c> dedupeTransactionset = new set<Transaction__c>();
        dedupeTransactionset.addAll(updateExistingTransaction);
        updateExistingTransaction.clear();
        updateExistingTransaction.addAll(dedupeTransactionset);

        //TRN-415
        Map<String, String> transactionIdMap = new Map<String, String>();
        List<Transaction_Contact__c> lstTransactionContactUpdate = new List<Transaction_Contact__c>();
        Set<Transaction_Contact__c> setTransactionContactUpdate = new Set<Transaction_Contact__c>();
        List<Transaction_Settlement__c> lstTransactionSettlementUpdate = new List<Transaction_Settlement__c>();
        Set<Transaction_Settlement__c> setTransactionSettlementUpdate = new Set<Transaction_Settlement__c>();
        System.debug('-updateExistingTransaction-' + updateExistingTransaction);
        System.debug('-lstTransactionContact-' + lstTransactionContact);
        for (Transaction__c currentTrans : updateExistingTransaction){
            transactionIdMap.put(currentTrans.Transaction_Id__c, currentTrans.Id);
        }
        if (!lstTransactionContact.isEmpty()){
            for (Transaction_Contact__c transCon : lstTransactionContact){
                if (transactionIdMap.get(transCon.Transaction_Id__c) != null){
                    transCon.Transaction__c = transactionIdMap.get(transCon.Transaction_Id__c);
                    String conCount = '';
                    if (transCon.Contact_Count__c > 0){
                        conCount = String.valueOf(transCon.Contact_Count__c);
                    }
                    transCon.Unique_Id__c = transactionIdMap.get(transCon.Transaction_Id__c) + transCon.Contact__c + transCon.Contact_Type__c + conCount;
                    setTransactionContactUpdate.add(transCon);
                }
            }
            lstTransactionContactUpdate.addAll(setTransactionContactUpdate);
            System.debug('-lstTransactionContactUpdate-' + lstTransactionContactUpdate);
            upsert lstTransactionContactUpdate Unique_Id__c;
        }

        if (!lstTransactionSettlement.isEmpty()){
            for (Transaction_Settlement__c ts : lstTransactionSettlement){
                if (transactionIdMap.get(ts.Transaction_Id__c) != null){
                    ts.Transaction__c = transactionIdMap.get(ts.Transaction_Id__c);
                    ts.Unique_Id__c = ts.Transaction_Id__c + ts.Description__c;
                    setTransactionSettlementUpdate.add(ts);
                }
            }
            lstTransactionSettlementUpdate.addAll(setTransactionSettlementUpdate);
            System.debug('-lstTransactionSettlementUpdate-' + lstTransactionSettlementUpdate);
            upsert lstTransactionSettlementUpdate Unique_Id__c;
        }
        // calling to create transation snapshot for created transations.
        if (!createNewTransaction.isEmpty() || !updateExistingTransaction.isEmpty()){
            TransactionHelper.createTransationSnapshot(createNewTransaction.size() > 0 ? createNewTransaction : updateExistingTransaction);
        }

        for (Transaction__c trans : updateExistingTransaction){
            //trans.Case_Thread_Id__c = null;
            transactionResponseList.add(new ResponseBody(trans.Transaction_Id__c, trans.id, null));
        }
        System.debug('=transactionResponseList=' + transactionResponseList);
        postResponse res = new postResponse(transactionResponseList);
        return res;
    }

    /*** Function to Insert and update Transaction Records**/
    global static RESTTransactionHelper.TransactionAndTransContact createUpdateTransaction(Transaction__c contextTransaction, Transactions inputtransaction, Map<String, String> emailUserMap, Map<String, String> bpmContactIdMap, Map<String, String> rsInstancePropertyMap, Map<String, String> portfolioTransactionsMap, Map<String, String> transactionRecordTypesMap, Map<String, Map<String, Transaction_Contact__c>> mapTransactionContact, Map<String, Map<String, Transaction_Settlement__c>> mapTransactionSettlement){

        List<Transaction_Settlement__c> tsList = new List<Transaction_Settlement__c>();
        if (inputtransaction.name != null){
            contextTransaction.Name = inputtransaction.name;
        } else if (inputtransaction.address != null){
            contextTransaction.Name = inputtransaction.address;
        }
        if (inputtransaction.transactionId != null)
            contextTransaction.Transaction_Id__c = inputtransaction.transactionId;
        if (inputtransaction.listingId != null)
            contextTransaction.Listing_Id__c = inputtransaction.listingId;
        if (inputtransaction.sellerPropertyId != null){
            contextTransaction.Property_Id__c = inputtransaction.sellerPropertyId;
            if (rsInstancePropertyMap.get(inputtransaction.sellerPropertyId) != null){
                contextTransaction.Property_Instance__c = rsInstancePropertyMap.get(inputtransaction.sellerPropertyId);
            }
        }

        if (inputtransaction.buyerPropertyId != null){
            contextTransaction.Buyer_Property_Id__c = inputtransaction.buyerPropertyId;
            if (rsInstancePropertyMap.get(inputtransaction.buyerPropertyId) != null){
                contextTransaction.Buyer_Property_Instance__c = rsInstancePropertyMap.get(inputtransaction.buyerPropertyId);
            }
        }

        //assign record type
        if (transactionRecordTypesMap != null){
            contextTransaction.RecordTypeId = transactionRecordTypesMap.get('Transaction');
        }

        //associate the parent portfolio transaction (self lookup)!
        if (inputtransaction.portfolioTransactionId != null){
            if (portfolioTransactionsMap.get(inputtransaction.portfolioTransactionId) != null){
                contextTransaction.Portfolio_Transaction__c = portfolioTransactionsMap.get(inputtransaction.portfolioTransactionId);
            }
        }
        if (inputtransaction.offerId != null)
            contextTransaction.Offer_Id__c = inputtransaction.offerId;
        if (inputtransaction.status != null)
            contextTransaction.Transaction_Status__c = inputtransaction.status;
        if (inputtransaction.salePrice != null)
            contextTransaction.Sale_Price__c = Decimal.valueOf(inputtransaction.salePrice);
        if (inputtransaction.listPrice != null)
            contextTransaction.List_Price__c = Decimal.valueOf(inputtransaction.listPrice);
        if (inputtransaction.address != null)
            contextTransaction.Address1__c = inputtransaction.address;
        if (inputtransaction.propertyType != null)
            contextTransaction.Property_Type__c = inputtransaction.propertyType;
        if (inputtransaction.startDate != null)
            contextTransaction.Start_Date__c = Date.ValueOf(inputtransaction.startDate);
        if (inputtransaction.createdDate != null)
            contextTransaction.Transaction_Created_Date__c = Date.valueOf(inputtransaction.createdDate);
        if (inputtransaction.inContractDate != null)
            contextTransaction.In_Contract_Date__c = Date.valueOf(inputtransaction.inContractDate);
        if (inputtransaction.estimatedCloseDate != null)
            contextTransaction.Est_Close_Date__c = Date.valueOf(inputtransaction.estimatedCloseDate);
        if (inputtransaction.escrowCloseDate != null)
            contextTransaction.Close_of_Escrow_Date__c = Date.valueOf(inputtransaction.escrowCloseDate);
        if (inputtransaction.contingencyExpirationDate != null)
            contextTransaction.IC_Expiration_Date__c = Date.valueOf(inputtransaction.contingencyExpirationDate);
        if (inputtransaction.contingenciesLiftDate != null)
            contextTransaction.Date_Contingencies_Lift__c = Date.valueOf(inputtransaction.contingenciesLiftDate);
        if (inputtransaction.isContingency != null)
            contextTransaction.Inspection_Contingency__c = inputtransaction.isContingency;
        if (inputtransaction.cancellationDate != null)
            contextTransaction.Cancellation_Date__c = Date.valueOf(inputtransaction.cancellationDate);
        if (inputtransaction.appraisalExpirationDate != null)
            contextTransaction.Appraisal_Exp_Date__c = Date.valueOf(inputtransaction.appraisalExpirationDate);
        if (inputtransaction.transactionCordinatorEmail != null)
            contextTransaction.Roofstock_TC_User_Email__c = inputtransaction.transactionCordinatorEmail;
        if (inputtransaction.customerServiceEmail != null)
            contextTransaction.Roofstock_Customer_Service_Email__c = inputtransaction.customerServiceEmail;
        if (inputtransaction.inventoryEmail != null)
            contextTransaction.Roofstock_Inventory_Owner_Email__c = inputtransaction.inventoryEmail;
        if (inputtransaction.accountManagerEmail != null)
            contextTransaction.Roofstock_Account_Manager_Email__c = inputtransaction.accountManagerEmail;
        if (inputtransaction.accountingEmail != null)
            contextTransaction.Roofstock_Accounting_Email__c = inputtransaction.accountingEmail;
        if (inputtransaction.projectManagerEmail != null)
            contextTransaction.Roofstock_Project_Manager_Email__c = inputtransaction.projectManagerEmail;
        if (inputtransaction.city != null)
            contextTransaction.City__c = inputtransaction.city;
        if (inputtransaction.state != null)
            contextTransaction.State__c = inputtransaction.state;
        if (inputtransaction.zip != null)
            contextTransaction.Zip__c = inputtransaction.zip;
        if (inputtransaction.financingType != null)
            contextTransaction.Financing_Type__c = inputtransaction.financingType;
        if (inputtransaction.emdDueDate != null)
            contextTransaction.EMD_Due_Date__c = Date.valueOf(inputtransaction.emdDueDate);
        if (inputtransaction.emdReceivedDate != null)
            contextTransaction.EMD_Received_Date__c = Date.valueOf(inputtransaction.emdReceivedDate);
        //C-12304
        if (inputtransaction.underwritingAnalystEmail != null)
            contextTransaction.Underwriting_Analyst_Email__c = inputtransaction.underwritingAnalystEmail;
        if (inputtransaction.buyerEntity != null)
            contextTransaction.Buyer_Entity__c = inputtransaction.buyerEntity;
        if (inputtransaction.roofstockAdvisorEmail != null)
            contextTransaction.Roofstock_Advisor_Email__c = inputtransaction.roofstockAdvisorEmail;
        /*if(inputtransaction.roofstockInventoryOwnerEmail!=null)
         contextTransaction.Roofstock_Inventory_Owner_Email__c = inputtransaction.roofstockInventoryOwnerEmail;*/
        if (inputtransaction.transactionType != null)
            contextTransaction.Transaction_Type__C = inputtransaction.transactionType;
        if (inputtransaction.scheduledInspectionDate != null)
            contextTransaction.Scheduled_Inspection_Date__c = DateTime.parse(inputtransaction.scheduledInspectionDate);
        if (inputtransaction.appraisalInspectionDate != null)
            contextTransaction.Appraisal_Inspection_Date__c = DateTime.parse(inputtransaction.appraisalInspectionDate);
        if (inputtransaction.listingSource != null)
            contextTransaction.Listing_Source__c = inputtransaction.listingSource;
        if (inputtransaction.contingencyStatus != null)
            contextTransaction.Contingency_Status__c = inputtransaction.contingencyStatus;
        //Assign Users
        if (inputtransaction.transactionCordinatorEmail != null)
            contextTransaction.Roofstock_TC_User__c = emailUserMap.get((inputtransaction.transactionCordinatorEmail).toLowerCase());
        if (inputtransaction.customerServiceEmail != null)
            contextTransaction.Roofstock_Customer_Service__c = emailUserMap.get((inputtransaction.customerServiceEmail).toLowerCase());
        if (inputtransaction.inventoryEmail != null)
            contextTransaction.Roofstock_Inventory_Owner__c = emailUserMap.get((inputtransaction.inventoryEmail).toLowerCase());
        if (inputtransaction.accountManagerEmail != null)
            contextTransaction.Roofstock_Account_Manager__c = emailUserMap.get((inputtransaction.accountManagerEmail).toLowerCase());
        if (inputtransaction.accountingEmail != null)
            contextTransaction.Roofstock_Accounting__c = emailUserMap.get((inputtransaction.accountingEmail).toLowerCase());
        if (inputtransaction.projectManagerEmail != null)
            contextTransaction.Roofstock_Project_Manager__c = emailUserMap.get((inputtransaction.projectManagerEmail).toLowerCase());
        //C-12304
        if (inputtransaction.roofstockAdvisorEmail != null)
            contextTransaction.Roofstock_Advisor__c = emailUserMap.get((inputtransaction.roofstockAdvisorEmail).toLowerCase());
        /* if(inputtransaction.roofstockInventoryOwnerEmail!=null)
         contextTransaction.Roofstock_Inventory_Owner__c = emailUserMap.get(inputtransaction.roofstockInventoryOwnerEmail);
         */
        if (inputtransaction.underwritingAnalystEmail != null){
            contextTransaction.Underwriting_Analyst__c = emailUserMap.get((inputtransaction.underwritingAnalystEmail).toLowerCase());
        }

        if (inputTransaction.application != null){
            contextTransaction.Application__c = inputTransaction.application;
        }
        /*if(inputTransaction.purchasePrice != null){
         contextTransaction.Purchase_Price__c =  inputTransaction.purchasePrice;
         }*/

        //TRN-415
        if (inputTransaction.transactionNotes != null){
            contextTransaction.Transaction_Notes__c = inputTransaction.transactionNotes;
        }
        if (inputTransaction.enableYardiUpload != null){
            contextTransaction.Enable_Yardi_Upload__c = inputTransaction.enableYardiUpload;
        }
        if (inputTransaction.sellerEntity != null){
            contextTransaction.Seller_Entity__c = inputTransaction.sellerEntity;
        }
        if (inputTransaction.emdAmount != null){
            //contextTransaction.EMD_Amount__c = inputTransaction.emdAmount;
            //Transaction Settlement
            Transaction_Settlement__c ts = createUpdateTransactionSettlementRecordEmd(inputtransaction, contextTransaction);
            tsList.add(ts);
        }
        if (inputTransaction.emdOptionFeeStatus != null){
            contextTransaction.EMD_Option_Fee_Status__c = inputTransaction.emdOptionFeeStatus;
        }
        if (inputTransaction.optionFeeAmount != null){
            //contextTransaction.Option_Fee_Amount__c = inputTransaction.optionFeeAmount;
            //Transaction Settlement
            Transaction_Settlement__c ts = createUpdateTransactionSettlementRecordOption(inputtransaction, contextTransaction);
            tsList.add(ts);
        }
        if (inputTransaction.inspectionEmailCc != null){
            contextTransaction.Inspection_Email_Cc__c = inputTransaction.inspectionEmailCc;
        }
        if (inputTransaction.inspectionKickOffNotes != null){
            contextTransaction.Inspection_Kickoff_Notes__c = inputTransaction.inspectionKickOffNotes;
        }
        if (inputTransaction.emdWiredOnDate != null){
            contextTransaction.Emd_Wired_On_Date__c = Date.valueOf(inputTransaction.emdWiredOnDate);
        }
        if (inputTransaction.brokerNotes != null){
            contextTransaction.Broker_Notes__c = inputTransaction.brokerNotes;
        }
        if (inputTransaction.rootTaskType != null){
            contextTransaction.RootTaskType__c = inputTransaction.rootTaskType;
        }
        if (inputTransaction.leadOriginationSource != null){
            contextTransaction.Origination_Source__c = inputTransaction.leadOriginationSource;
        }
        if (inputTransaction.sellerCommissionPercentage != null){
            contextTransaction.Seller_Commission_Percent__c = inputTransaction.sellerCommissionPercentage;
        }
        if (inputTransaction.buyerCommissionPercentage != null){
            contextTransaction.Buyer_Commission_Percent__c = inputTransaction.buyerCommissionPercentage;
        }
        if (inputTransaction.sellerCommissionMinAmount != null){
            contextTransaction.Seller_Commission_Min_Amount__c = inputTransaction.sellerCommissionMinAmount;
        }

        //Added for cloudhouse project- https://roofstock.atlassian.net/browse/PMC2022-231
        if (inputTransaction.originalSalePrice != null){
            contextTransaction.In_Contract_Price__c = inputTransaction.originalSalePrice;
        }
        if (inputTransaction.salesChannel != null){
            contextTransaction.Disposition_Channel__c = inputTransaction.salesChannel;
        }
        if (inputTransaction.actualCapex != null){
            contextTransaction.Actual_Capex__c = inputTransaction.actualCapex;
        }
        if (inputTransaction.inspectionDueDate != null){
            contextTransaction.Inspection_Due_Date__c = Date.valueOf(inputTransaction.inspectionDueDate);
        }
        if (inputTransaction.inspectionNeeded != null){
            contextTransaction.Inspection_Needed__c = inputTransaction.inspectionNeeded;
        }
        if (inputTransaction.sendOpenEscrowEmail != null){
            contextTransaction.Open_Escrow__c = inputTransaction.sendOpenEscrowEmail;
        }

        if (inputTransaction.titleCompanyRSAccountId != null){
            System.debug('Title Company RS Account Id input to API : ' + inputtransaction.titleCompanyRSAccountId);
            List<Account> accounts = [SELECT Id
                                      FROM Account
                                      WHERE Roofstock_Account_ID__c = :inputtransaction.titleCompanyRSAccountId
                                      LIMIT 1];
            if (null != accounts && accounts.size() > 0){
                contextTransaction.Title_Company_Account__c = accounts[0].Id;
            }
        }

        //Transaction Contact
        integer buyCont = 0;
        List<Transaction_Contact__c> lstTc = new List<Transaction_Contact__c>();
        Transaction_Contact__c tc;
        System.debug('-mapTransactionContact-' + mapTransactionContact);
        for (RESTContactHelper.Contacts con : inputtransaction.contactsList){
            if (mapTransactionContact.containsKey(inputtransaction.transactionId)){
                Map<String, Transaction_Contact__c> typeTransactionContactMap = mapTransactionContact.get(inputtransaction.transactionId);
                if (!typeTransactionContactMap.isEmpty()){
                    if (typeTransactionContactMap.containsKey(con.type + con.contactNumber)){
                        //Do Nothing
                    } else{
                        //Create Transaction Contact
                        tc = createUpdateTransactionContactRecord(con, inputtransaction, contextTransaction, bpmContactIdMap);
                    }
                } else{
                    tc = createUpdateTransactionContactRecord(con, inputtransaction, contextTransaction, bpmContactIdMap);
                }
            } else{
                tc = createUpdateTransactionContactRecord(con, inputtransaction, contextTransaction, bpmContactIdMap);
            }
            if (tc != null){
                lstTc.add(tc);
            }

            if (con.type != null && con.type.equalsignoreCase('Buyer')){
                buyCont++;
                if (buyCont == 1){
                    contextTransaction.Buyer_Contact_Id_1__c = con.bpmContactId;
                    contextTransaction.Buyer_Contact1__c = bpmContactIdMap.get(con.bpmContactId);
                } else if (buyCont == 2){
                    contextTransaction.Buyer_Contact_Id_2__c = con.bpmContactId;
                    contextTransaction.Buyer_Contact2__c = bpmContactIdMap.get(con.bpmContactId);
                }
            }
            if (con.type != null && con.type.equalsignoreCase('Seller')){
                contextTransaction.Seller_Contact_Id__c = con.bpmContactId;
                contextTransaction.Seller_Contact__c = bpmContactIdMap.get(con.bpmContactId);
            }

            if (con.type != null && con.type.equalsignoreCase('Inspector')){
                contextTransaction.Inspector_Contact_Id__c = con.bpmContactId;
                contextTransaction.Inspector_Contact__c = bpmContactIdMap.get(con.bpmContactId);
            }
            if (con.type != null && con.type.equalsignoreCase('PM Buyer')){
                contextTransaction.PM_Buyer_Contact_Id__c = con.bpmContactId;
                contextTransaction.PM_Buyer_Contact__c = bpmContactIdMap.get(con.bpmContactId);
            }
            if (con.type != null && con.type.equalsignoreCase('PM Seller')){
                contextTransaction.PM_Seller_Contact_Id__c = con.bpmContactId;
                contextTransaction.PM_Seller_Contact__c = bpmContactIdMap.get(con.bpmContactId);
            }
            if (con.type != null && con.type.equalsignoreCase('Escrow')){
                contextTransaction.Escrow_Contact_Id__c = con.bpmContactId;
                contextTransaction.Escrow_Contact__c = bpmContactIdMap.get(con.bpmContactId);
            }
            if (con.type != null && con.type.equalsignoreCase('Title')){
                contextTransaction.Title_Contact_Id__c = con.bpmContactId;
                contextTransaction.Title_Contact__c = bpmContactIdMap.get(con.bpmContactId);
            }
            if (con.type != null && con.type.equalsignoreCase('Insurance')){
                contextTransaction.Insurance_Contact_Id__c = con.bpmContactId;
                contextTransaction.Insurance_Contact__c = bpmContactIdMap.get(con.bpmContactId);
            }
            if (con.type != null && con.type.equalsignoreCase('Lender')){
                contextTransaction.Lender_Contact_Id__c = con.bpmContactId;
                contextTransaction.Lender_Contact__c = bpmContactIdMap.get(con.bpmContactId);
            }
            if (con.type != null && con.type.equalsignoreCase('Broker Buyer')){
                contextTransaction.Buyer_Broker_Contact_Id__c = con.bpmContactId;
                contextTransaction.Buyer_Broker_Contact__c = bpmContactIdMap.get(con.bpmContactId);
            }
            if (con.type != null && con.type.equalsignoreCase('Broker Seller')){
                contextTransaction.Seller_Broker_Contact_Id__c = con.bpmContactId;
                contextTransaction.Seller_Broker_Contact__c = bpmContactIdMap.get(con.bpmContactId);
            }
        }

        TransactionAndTransContact transactionTransCon = new TransactionAndTransContact();
        transactionTransCon.trans = contextTransaction;
        if (!lstTc.isEmpty()){
            transactionTransCon.transContact = lstTc;
        }
        if (!tsList.isEmpty()){
            transactionTransCon.transSettlement = tsList;
        }

        return transactionTransCon;
    }

    public static Transaction_Contact__c createUpdateTransactionContactRecord(RESTContactHelper.Contacts con, Transactions inputtransaction, Transaction__c contextTransaction, Map<String, String> bpmContactIdMap){
        System.debug('-bpmContactIdMap-' + bpmContactIdMap);
        Transaction_Contact__c tc = new Transaction_Contact__c();
        tc.Contact_Type__c = con.type;
        if (con.type == 'Buyer Signer' || con.type == 'Buyer'){
            if (con.contactNumber == 0){
                tc.Contact_Count__c = null;
            } else if (con.contactNumber > 0){
                tc.Contact_Count__c = con.contactNumber;
            }
        }
        tc.Transaction_Id__c = inputtransaction.transactionId;
        tc.Contact__c = bpmContactIdMap.get(con.bpmContactId);
        return tc;
    }

    public static Transaction_Settlement__c createUpdateTransactionSettlementRecordEmd(Transactions inputtransaction, Transaction__c contextTransaction){
        Transaction_Settlement__c tsEmd = new Transaction_Settlement__c();
        //tsEmd.EMD_Amount__c = inputtransaction.emdAmount;
        tsEmd.Unit_Price__c = inputtransaction.emdAmount;
        tsEmd.Description__c = 'Earnest Money Deposit';
        tsEmd.Transaction_Id__c = inputtransaction.transactionId;
        //ts.Unique_Id__c = inputtransaction. + inputtransaction.
        return tsEmd;
    }

    public static Transaction_Settlement__c createUpdateTransactionSettlementRecordOption(Transactions inputtransaction, Transaction__c contextTransaction){
        Transaction_Settlement__c tsOption = new Transaction_Settlement__c();
        //tsOption.Option_Fee_Amount__c = inputtransaction.optionFeeAmount;
        tsOption.Unit_Price__c = inputtransaction.optionFeeAmount;
        tsOption.Description__c = 'Option Fee';
        tsOption.Transaction_Id__c = inputtransaction.transactionId;
        //ts.Unique_Id__c = inputtransaction. + inputtransaction.
        return tsOption;
    }

    global class TransactionAndTransContact{
        global Transaction__c trans;
        global List<Transaction_Contact__c> transContact;
        global List<Transaction_Settlement__c> transSettlement;

    }

}
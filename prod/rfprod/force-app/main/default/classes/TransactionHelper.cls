public class TransactionHelper{
    /**
     * This Method is to create Renovation Job automatically when transaction is getting closed.
     * Input  :: new and old Record List of updated transaction
     * Output :: Void
     */
    //public class OtherException extends Exception  {}
    public static void createJobForInspection(List<Transaction__c> newRecordsList, Map<Id, Transaction__c> oldRecordsMap){
        List<Id> transBPropIdList = new List<Id>();
        List<Job__c> jobList = new List<Job__c>();
        Map<Id, Id> mapInspectionPropUnit = new Map<Id, Id>();
        Map<Id, Id> mapPropUnitInspection = new Map<Id, Id>();
        Map<Id, Id> mapSellerBuyerProp = new Map<Id, Id>();
        Map<Id, String> mapPUnitRecordType = new Map<Id, String>();
        Map<String, Id> mapHomecodeBuyerProp = new Map<String, Id>();
        Map<String, Id> mapHomecodeSellerProp = new Map<String, Id>();
        Map<String, String> mapSellerToBuyerPropUnit = new Map<String, String>();
        List<Inspection__C> inspListToUpdate = new List<Inspection__C>();
        List<Id> ListInspectionId = new List<Id>();
        List<Job__c> updateJobPUnitList = new List<Job__c>();
        List<ContentDocumentLink> listCdl = new List<ContentDocumentLink>();
        Map<Id, Id> mapInspectionJob = new Map<Id, Id>();
        String todayDate = Date.today().format();
        String prop = '';
        try{
            Id recordtypeId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Renovation').getRecordTypeId();
            Id sellerPropRecordtypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByName().get('Roofstock').getRecordTypeId();
            for (Transaction__c trans : newRecordsList){
                System.debug('transection record::' + trans);
                if (trans.Transaction_Status__c == 'Transaction Completed' && trans.Transaction_Status__c != oldRecordsMap.get(trans.Id).Transaction_Status__c){
                    transBPropIdList.add(trans.Buyer_Property_Instance__c);
                    transBPropIdList.add(trans.Property_Instance__c);
                    mapSellerBuyerProp.put(trans.Property_Instance__c, trans.Buyer_Property_Instance__c);
                    System.debug('transection buyer record::' + transBPropIdList);
                }
            }

            List<Property_Unit__c> puList = [SELECT Id, Name, Operating_Reason__c, Record_Type_Property__c, HomeCode__c, (SELECT Id, Name, Inspection_Status__c, Property__c, Property_Unit__c, Property__r.RecordTypeId
                                                                                                                          FROM Diligence__r
                                                                                                                          WHERE Inspection_Status__c = 'Completed'
                                                                                                                          ORDER BY lastModifiedDate DESC
                                                                                                                          LIMIT 1)
                                             FROM Property_Unit__c
                                             WHERE Property__c IN:transBPropIdList];

            for (Property_Unit__c pu : puList){
                mapPUnitRecordType.put(pu.Id, pu.Record_Type_Property__c);
                if (pu.Record_Type_Property__c == 'Asset Management'){
                    mapHomecodeBuyerProp.put(pu.HomeCode__c, pu.Id);
                } else if (pu.Record_Type_Property__c == 'Roofstock'){
                    mapHomecodeSellerProp.put(pu.HomeCode__c, pu.Id);
                }
            }

            for (Property_Unit__c pu : puList){
                System.debug('property Unit name ::' + pu.name + pu.Operating_Reason__c);
                String jobStatus = '';

                for (Inspection__c insp : pu.Diligence__r){
                    System.debug('inspection record::: ' + insp.Id + ' inspection status:: ' + insp.Inspection_status__c);

                    If (pu.operating_reason__c <> null && (((pu.operating_reason__c).toUppercase() == ('Temporary Occupancy Agreement').toUppercase()) || ((pu.Operating_Reason__c).toUppercase() == ('Tenant in Place').toUppercase()))){
                        jobStatus = 'Waiting for Move Out';
                    } else{
                        jobStatus = 'Needs Job Start';
                    }

                    if (insp.Property__r.RecordTypeId == sellerPropRecordtypeId){
                        mapSellerToBuyerPropUnit.put(insp.Property_Unit__c, mapHomecodeBuyerProp.get(pu.HomeCode__c));
                        prop = mapSellerBuyerProp.get(insp.Property__c);
                    } else{
                        prop = insp.Property__c;
                    }

                    Job__c newJob = new Job__c();
                    newjob.Job_Status__c = jobStatus;
                    newJob.Job_Type__c = 'Renovation';
                    newJob.Property__c = prop;
                    newjob.Property_Unit__c = insp.Property_Unit__c;
                    newJob.RecordTypeId = recordtypeId;
                    jobList.add(newJob);
                    System.debug('job details:: ' + jobList);

                    mapPropUnitInspection.put(insp.Property_Unit__c, insp.Id);
                    mapInspectionPropUnit.put(insp.Id, insp.Property_Unit__c);
                    //ListInspectionId.add(insp.Id);
                }
            }

            system.debug('map of inspectiona and pro unit::-->' + mapInspectionPropUnit);
            if (jobList <> null && jobList.size() > 0){
                insert jobList;
                for (Job__c insertedJob : jobList){
                    System.debug('property Unit::: ' + insertedJob.Property_unit__c);
                    Id inspId = mapPropUnitInspection.get(insertedJob.Property_unit__c);
                    Inspection__C insp = new Inspection__C();
                    Insp.Id = inspId;
                    insp.Job__c = insertedJob.Id;
                    inspListToUpdate.add(insp);
                    mapInspectionJob.put(inspId, insertedJob.Id);
                    System.debug('inspe to upadate is::' + inspListToUpdate);
                }
                System.debug('inspe list to upadate is::' + inspListToUpdate);
            }

            if (inspListToUpdate <> null && inspListToUpdate.size() > 0){
                update inspListToUpdate;
                System.debug('updated inspection list::' + inspListToUpdate);
                for (Inspection__C updatedInsp : inspListToUpdate){
                    String propUnit = mapInspectionPropUnit.get(updatedInsp.Id);
                    String recordType = mapPUnitRecordType.get(propUnit);

                    if (recordType == 'Roofstock'){
                        Job__c updateJobPUnit = new Job__c();
                        updateJobPUnit.id = updatedInsp.Job__c;
                        updateJobPUnit.Property_Unit__c = mapSellerToBuyerPropUnit.get(propUnit);
                        updateJobPUnitList.add(updateJobPUnit);
                    }
                }
            }

            if (updateJobPUnitList <> null && updateJobPUnitList.size() > 0){
                update updateJobPUnitList;
            }


            /*
             // code to copy notes and attachments to renovation
             List<ContentDocumentLink> cdlist = [SELECT id,ContentDocumentId,LinkedEntityId
             FROM ContentDocumentLink
             WHERE LinkedEntityId IN : ListInspectionId];
             System.debug('doc list::'+cdlist);
             for(ContentDocumentLink cdl : cdlist) {
             ContentDocumentLink newcdl =  new ContentDocumentLink();
             newcdl.LinkedEntityId = mapInspectionJob.get(cdl.LinkedEntityId);
             newcdl.ContentDocumentId = cdl.ContentDocumentId;
             newcdl.shareType = 'V';
             listCdl.add(newcdl);
             }
             if(listCdl <> null && listCdl.size() > 0) {
             insert listCdl;
             }
             */
        } catch (Exception exe){
            DebugLogHandler.logOutBoundException('TransactionHelper', 'createJobForInspection', exe.getStackTraceString(), exe.getMessage(), null, null, null);
        }
    }

    Public static void createTransactionStageHistory(List<Transaction__c> newTransactionList){
        List<Transaction_Stage_History__c> lstTransactionStageHistory = new List<Transaction_Stage_History__c>();
        System.debug('newTransactionList' + newTransactionList);
        for (Transaction__c newTrans : newTransactionList){
            //if(String.isNotBlank(newTrans.Stage__c)){
            Transaction_Stage_History__c transactionStageHistory = new Transaction_Stage_History__c();
            transactionStageHistory.Stage__c = newTrans.Stage__c;
            //transactionStageHistory.Stage_Updated_Date__c = Date.today();
            transactionStageHistory.Start_Date__c = Date.today();
            transactionStageHistory.Transaction__c = newTrans.Id;
            lstTransactionStageHistory.add(transactionStageHistory);
            // }
        }
        if (!lstTransactionStageHistory.isEmpty()){
            insert lstTransactionStageHistory;
        }
    }

    public static void updateTransactionStageHistory(List<Transaction__c> newTransactionList, Map<Id, Transaction__c> oldTransactionMap){
        Map<String, Transaction__c> transactionIdMap = new Map<String, Transaction__c>();
        Map<String, Transaction_Stage_History__c> transactionAndHistoryMap = new Map<String, Transaction_Stage_History__c>();
        List<Transaction_Stage_History__c> lstTransactionStageHistoryUpdate = new List<Transaction_Stage_History__c>();
        List<Transaction__c> lstTransactionCreate = new List<Transaction__c>();

        for (Transaction__c newTrans : newTransactionList){
            System.debug('-stage new-' + newTrans.Stage__c);
            System.debug('-stage old-' + oldTransactionMap.get(newTrans.Id).Stage__c);
            if ((newTrans.Stage__c != oldTransactionMap.get(newTrans.Id).Stage__c)){
                transactionIdMap.put(newTrans.Id, newTrans);
                lstTransactionCreate.add(newTrans);
            }
        }
        System.debug('-transactionIdMap-' + transactionIdMap);
        List<Transaction_Stage_History__c> matchingTransactionStageHistoryList = [select id, End_Date__c, Transaction__c, Stage__c, Stage_Updated_Date__c
                                                                                  from Transaction_Stage_History__c
                                                                                  where Transaction__c IN:transactionIdMap.keySet()
                                                                                  order by createddate asc];
        for (Transaction_Stage_History__c transactionStageHistory : matchingTransactionStageHistoryList){
            transactionAndHistoryMap.put(transactionStageHistory.Transaction__c, transactionStageHistory);
        }
        for (Transaction_Stage_History__c transactionStageHistory : transactionAndHistoryMap.values()){
            transactionStageHistory.End_Date__c = System.today();
            lstTransactionStageHistoryUpdate.add(transactionStageHistory);
        }

        if (!lstTransactionStageHistoryUpdate.isEmpty()){
            update lstTransactionStageHistoryUpdate;
        }
        if (!lstTransactionCreate.isEmpty()){
            createTransactionStageHistory(lstTransactionCreate);
        }
    }

    public static void updatePropertyBPOTriggerDate(Map<Id, Transaction__c> updatedTransactions, Map<Id, Transaction__c> oldTransactionsMap){

        Toggle_New_logic__c bypassnewLogic = [Select id, name, Enable_new_logic__c
                                              from Toggle_New_logic__c
                                              where name = 'BPO'];

        if (null <> bypassnewLogic && bypassnewLogic.Enable_new_logic__c == false){
            return;
        } else{
            Id transactionRecordTypeId = Schema.SObjectType.Transaction__c.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
            Id propertyRecordTypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByName().get('Asset Management').getRecordTypeId();

            Set<Id> contactIdSet = new Set<Id>();
            List<Property2__c> updateProperty = new List<Property2__c>();
            Set<Id> propIdSet = new Set<Id>();

            for (Transaction__c updatedtrans : updatedTransactions.values()){
                if (updatedtrans.RecordTypeId == transactionRecordTypeId && updatedtrans.Buyer_Property_Instance__c != null){
                    propIdSet.add(updatedtrans.Buyer_Property_Instance__c);
                    if (updatedtrans.Transaction_Type__c == 'Disposition Sale' && updatedtrans.Seller_Contact__c != null){
                        contactIdSet.add(updatedtrans.Seller_Contact__c);
                    }
                }
            }

            Map<ID, Property2__c> lstUpdateProperty = new Map<ID, Property2__c>([SELECT Id, Name, BPO_Trigger_Date__c, Type_of_BPO_Trigger__c
                                                                                 FROM Property2__c
                                                                                 WHERE Id IN:propIdSet AND RecordTypeId = :propertyRecordTypeId]);

            Map<ID, Contact> contactMap = new Map<id, Contact>([SELECT ID, Name, Accountid, Account.Roofstock_Account_ID__c
                                                                FROM Contact
                                                                WHERE ID IN:contactIdSet]);
            Property2__c prop;
            if (!lstUpdateProperty.isEmpty()){
                for (Transaction__c updatedtrans : updatedTransactions.values()){
                    if (updatedtrans.RecordTypeId == transactionRecordTypeId && updatedtrans.Buyer_Property_Instance__c != null){
                        prop = lstUpdateProperty.get(updatedtrans.Buyer_Property_Instance__c);
                        //if ((updatedtrans.Transaction_Status__c != oldTransactionsMap.get(updatedtrans.id).Transaction_Status__c && updatedtrans.Transaction_Status__c == 'Transaction Completed')){
                        if((updatedtrans.Transaction_Status__c != oldTransactionsMap.get(updatedtrans.id).Transaction_Status__c && updatedtrans.Transaction_Status__c == 'In Contract')){
                            prop.BPO_Trigger_Date__c = System.today();
                            //prop.Type_of_BPO_Trigger__c = 'Transaction Completed';
                            prop.Type_of_BPO_Trigger__c = 'In Contract';
                            updateProperty.add(prop);
                        }

                        if (updatedtrans.Transaction_Type__c == 'Disposition Sale' && updatedtrans.Seller_Contact__c != null){
                            Contact con = contactMap.get(updatedtrans.Seller_Contact__c);
                            if (con?.Account?.Roofstock_Account_ID__c == System.Label.Starwood_Account_Number){
                                prop.Stop_Annual_BPO_Valuation__c = true;
                                if (!updateProperty.contains(prop)){
                                    updateProperty.add(prop);
                                }
                            }
                        }
                    }
                }
            }

            if (!updateProperty.IsEmpty()){
                update updateProperty;
            }
        }
    }

    /*Public static void sendSMS(List<Transaction__c> updatedTransactions, Map<Id,Transaction__c> oldTransactionsMap){
     if (updatedTransactions.size() == 1 && UserInfo.getFirstName() <> 'Integration' && System.Label.RCSMSTestSwitch == 'Yes') {
     Transaction__c newTran = updatedTransactions[0];
     Transaction__c oldTran = oldTransactionsMap.get(newTran.Id);
     if (newTran.Transaction_Status__c <> oldTran.Transaction_Status__c &&
     newTran.Buyer_Broker_Contact_Phone__c <> null) {
     RingCentralSendSMSApi.sendSMSCallout(newTran.Buyer_Broker_Contact_Phone__c,
     'Transaction Status Changed from ' + oldTran.Transaction_Status__c + ' To ' + newTran.Transaction_Status__c, newTran.Id);
     }
     }
     }
     public static void assignPermissionSet(List<Transaction__c> newTransaction){
     Set<String> rsAdvisorSet = new set<String>();
     Set<String> rsInventoryOwnerSet = new set<String>();
     for(Transaction__c trans:newTransaction){
     if(trans.Roofstock_Advisor__c !=null){
     rsAdvisorSet.add(trans.Roofstock_Advisor__c);
     }
     if(trans.Roofstock_Inventory_Owner__c !=null){
     rsInventoryOwnerSet.add(trans.Roofstock_Inventory_Owner__c);
     }
     }
     permissionset ps = [select id,label from permissionset where label = 'Roofstock Advisor'];
     List<PermissionSetAssignment> lstpsa = [select Id,AssigneeId,PermissionSetId from PermissionSetAssignment where PermissionSetId =:ps.Id];

     } */
    public static void publishTransactionPlatformEventsAdhoc(List<Transaction__c> newTransaction, Map<Id, Transaction__c> oldTransactionsMap){

        List<Transaction_Event__e> lstTransactionEvents = new List<Transaction_Event__e>();
        List<Transaction__c> lstFilteredTransaction = new List<Transaction__c>();

        Id TransactionRecordTypeId = Schema.SObjectType.Transaction__c.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        //Get Transaction Contact
        Set<String> setTransactionRecordId = new Set<String>();
        Map<String, Set<TransactionPlatformEventWrapper.TransactionContact>> transactionContactWrap = new Map<String, Set<TransactionPlatformEventWrapper.TransactionContact>>();
        Map<String, Set<TransactionPlatformEventWrapper.Inspection>> transactionInspectionWrap = new Map<String, Set<TransactionPlatformEventWrapper.Inspection>>();
        try{
            Exclude_Transaction_Events__c exch = Exclude_Transaction_Events__c.getInstance(UserInfo.getUserId());

            System.debug('exch::' + exch + '---Value--' + exch.Exclude_Outbound_Platform_Event__c);
            if (exch != null && !exch.Exclude_Outbound_Platform_Event__c){
                for (Transaction__c transRec : newTransaction){
                    if (transRec.Transaction_Type__c == 'Acquisition Buy' && transRec.RecordtypeId == TransactionRecordTypeId){

                        if (((transRec.Transaction_Notes__c != null) && (transRec.Transaction_Notes__c != oldTransactionsMap.get(transRec.Id).Transaction_Notes__c)) || ((transRec.Est_Close_Date__c != null) && (transRec.Est_Close_Date__c != oldTransactionsMap.get(transRec.Id).Est_Close_Date__c)) || ((transRec.Contingency_Status__c != null) && (transRec.Contingency_Status__c != oldTransactionsMap.get(transRec.Id).Contingency_Status__c)) || ((transRec.Date_Contingencies_Lift__c != null) && (transRec.Date_Contingencies_Lift__c != oldTransactionsMap.get(transRec.Id).Date_Contingencies_Lift__c)) || ((transRec.Appraisal_Exp_Date__c != null) && (transRec.Appraisal_Exp_Date__c != oldTransactionsMap.get(transRec.Id).Appraisal_Exp_Date__c)) || ((transRec.IC_Expiration_Date__c != null) && (transRec.IC_Expiration_Date__c != oldTransactionsMap.get(transRec.Id).IC_Expiration_Date__c)) || ((transRec.Seller_Commission_Percent__c != null) && (transRec.Seller_Commission_Percent__c != oldTransactionsMap.get(transRec.Id).Seller_Commission_Percent__c)) || ((transRec.Buyer_Commission_Percent__c != null) && (transRec.Buyer_Commission_Percent__c != oldTransactionsMap.get(transRec.Id).Buyer_Commission_Percent__c)) || ((transRec.Seller_Commission_Min_Amount__c != null) && (transRec.Seller_Commission_Min_Amount__c != oldTransactionsMap.get(transRec.Id).Seller_Commission_Min_Amount__c)) || ((transRec.Origination_Source__c != null) && (transRec.Origination_Source__c != oldTransactionsMap.get(transRec.Id).Origination_Source__c)) || ((transRec.Roofstock_Inventory_Owner__c != null) && (transRec.Roofstock_Inventory_Owner__c != oldTransactionsMap.get(transRec.Id).Roofstock_Inventory_Owner__c)) || ((transRec.Roofstock_Advisor__c != null) && (transRec.Roofstock_Advisor__c != oldTransactionsMap.get(transRec.Id).Roofstock_Advisor__c)) || ((transRec.Underwriting_Analyst__c != null) && (transRec.Underwriting_Analyst__c != oldTransactionsMap.get(transRec.Id).Underwriting_Analyst__c)) || ((transRec.Roofstock_Customer_Service__c != null) && (transRec.Roofstock_Customer_Service__c != oldTransactionsMap.get(transRec.Id).Roofstock_Customer_Service__c)) || ((transRec.Roofstock_TC_User__c != null) && (transRec.Roofstock_TC_User__c != oldTransactionsMap.get(transRec.Id).Roofstock_TC_User__c))){
                            setTransactionRecordId.add(transRec.Id);
                            lstFilteredTransaction.add(transRec);
                        }

                    }

                }

                Set<String> setUser = new Set<String>();
                for (Transaction__c tran : [Select Id, Roofstock_TC_User__c, Roofstock_Customer_Service__c, Underwriting_Analyst__c, Roofstock_Advisor__c, Roofstock_Inventory_Owner__c
                                            from Transaction__c
                                            where Id IN:setTransactionRecordId]){
                    if (tran.Roofstock_TC_User__c != null){
                        setUser.add(tran.Roofstock_TC_User__c);
                    }
                    if (tran.Roofstock_Customer_Service__c != null){
                        setUser.add(tran.Roofstock_Customer_Service__c);
                    }
                    if (tran.Underwriting_Analyst__c != null){
                        setUser.add(tran.Underwriting_Analyst__c);
                    }
                    if (tran.Roofstock_Advisor__c != null){
                        setUser.add(tran.Roofstock_Advisor__c);
                    }
                    if (tran.Roofstock_Inventory_Owner__c != null){
                        setUser.add(tran.Roofstock_Inventory_Owner__c);
                    }
                }
                Map<String, String> mapUserEmail = new Map<String, String>();
                for (User usr : [select Id, Email
                                 from User
                                 where Id IN:setUser]){
                    mapUserEmail.put(usr.Id, usr.Email);
                }
                //Task
                Map<String, Schema.RecordTypeInfo> rtMapByDeveloperName = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName();
                String recordTypeId = rtMapByDeveloperName.get('Transaction_Tasks').getRecordTypeId();
                Map<String, Task> mapTransactionTask = new Map<String, Task>();
                for (Task tsk : [Select Id, Transaction__c, Transaction__r.Transaction_Id__c, Status, Description
                                 from Task
                                 where Transaction__c IN:setTransactionRecordId and Type = 'QC: Contract Audit' and RecordTypeId = :recordTypeId]){
                    mapTransactionTask.put(tsk.Transaction__c, tsk);
                }
                for (Transaction__c transRec : lstFilteredTransaction){
                    Transaction_Event__e transEvent = new Transaction_Event__e();
                    transEvent.Event_Type__c = 'Adhoc Update';
                    transEvent.Transaction_Id__c = transRec.Transaction_Id__c;
                    transEvent.Transaction_Notes__c = transRec.Transaction_Notes__c;
                    transEvent.Est_Close_Date__c = transRec.Est_Close_Date__c;
                    transEvent.Contingency_Status__c = transRec.Contingency_Status__c;
                    transEvent.Due_Diligence_Material_Deadline__c = transRec.Date_Contingencies_Lift__c;
                    transEvent.Appraisal_Due_Date__c = transRec.Appraisal_Exp_Date__c;
                    //transEvent.Inspection_Contingency_Expiration_Date__c = transRec.IC_Expiration_Date__c;
                    transEvent.Seller_Commission_Percentage__c = transRec.Seller_Commission_Percent__c;
                    transEvent.Buyer_Commission_Percentage__c = transRec.Buyer_Commission_Percent__c;
                    transEvent.Seller_Commission_Min_Amount__c = transRec.Seller_Commission_Min_Amount__c;
                    transEvent.Lead_Origination_Source__c = transRec.Origination_Source__c;
                    if (mapUserEmail.get(transRec.Roofstock_TC_User__c) != null){
                        transEvent.Transaction_Coordinator__c = mapUserEmail.get(transRec.Roofstock_TC_User__c);
                    }
                    if (mapUserEmail.get(transRec.Roofstock_Customer_Service__c) != null){
                        transEvent.Customer_Service__c = mapUserEmail.get(transRec.Roofstock_Customer_Service__c);
                    }
                    if (mapUserEmail.get(transRec.Underwriting_Analyst__c) != null){
                        transEvent.Underwriting_Analyst__c = mapUserEmail.get(transRec.Underwriting_Analyst__c);
                    }
                    if (mapUserEmail.get(transRec.Roofstock_Advisor__c) != null){
                        transEvent.Roofstock_Advisor__c = mapUserEmail.get(transRec.Roofstock_Advisor__c);
                    }
                    if (mapUserEmail.get(transRec.Roofstock_Inventory_Owner__c) != null){
                        transEvent.Roofstock_Inventory_Owner__c = mapUserEmail.get(transRec.Roofstock_Inventory_Owner__c);
                    }
                    transEvent.Sale_Price__c = transRec.Sale_Price__c;
                    //task
                    if (!mapTransactionTask.isEmpty()){
                        if (mapTransactionTask.get(transRec.Id) != null){
                            Task tsk = mapTransactionTask.get(transRec.Id);
                            if (tsk.Status != null){
                                transEvent.Task_Status__c = tsk.Status;
                            }
                            if (tsk.Description != null){
                                transEvent.Task_Description__c = tsk.Description;
                            }
                        }
                    }
                    lstTransactionEvents.add(transEvent);

                }
                System.debug('-lstTransactionEvents-' + lstTransactionEvents);

                Set<Id> lstSuccessIds = new Set<Id>();
                if (!lstTransactionEvents.isEmpty()){

                    List<Database.SaveResult> results = EventBus.publish(lstTransactionEvents);
                    for (Database.SaveResult sr : results){
                        if (sr.isSuccess()){
                            lstSuccessIds.add(sr.getId());
                        }
                    }


                }
                DebugLogHandler.logOutBoundResponse('TransactionHelper', 'publishTransactionPlatformEventsAdhoc', JSON.serialize(lstTransactionEvents), JSON.serialize(lstSuccessIds));
                //throw new OtherException('This is bad');
            }
        }
        //catch(OtherException oe){
        catch (Exception exe){
            DebugLogHandler.platformEventException('TransactionHelper', 'publishTransactionPlatformEventsAdhoc', exe.getStackTraceString(), JSON.serialize(lstTransactionEvents), exe.getMessage());
            //DebugLogHandler.platformEventException('TransactionHelper','publishTransactionPlatformEventsAdhoc',oe.getStackTraceString(),JSON.serialize(lstTransactionEvents),oe.getMessage());

        }
    }

    public static void publishTransactionPlatformEvents(String type, Transaction__c trans, Set<TransactionPlatformEventWrapper.TransactionContact> setTransactionContact, Set<TransactionPlatformEventWrapper.Inspection> setInspection, Set<TransactionPlatformEventWrapper.PropertyUnit> setPropertyUnit, TransactionPlatformEventWrapper.transactionSettlement transSettlement, TransactionPlatformEventWrapper.transactionContractQcTask transactionTask, TransactionPlatformEventWrapper.Property property){

        List<Transaction_Event__e> lstTransactionEvents = new List<Transaction_Event__e>();
        Set<String> setContactId = new Set<String>();
        Set<String> setAccountId = new Set<String>();
        Transaction_Event__e transEvent = new Transaction_Event__e();
        try{
            Exclude_Transaction_Events__c exch = Exclude_Transaction_Events__c.getInstance(UserInfo.getUserId());

            System.debug('exch::' + exch + '---Value--' + exch.Exclude_Outbound_Platform_Event__c);
            if (exch != null && !exch.Exclude_Outbound_Platform_Event__c){
                if (type == 'Contract QC'){
                    // transEvent.Transaction_Contact__c = '{"TransactionContacts":'+JSON.serialize(setTransactionContact)+'}';
                    transEvent.Property_Unit__c = '{"property_units":' + JSON.serialize(setPropertyUnit) + '}';
                    transEvent.HOA__c = property.hoa;
                    transEvent.Inspection__c = '{"Inspections":' + JSON.serialize(setInspection) + '}';
                    //transEvent.Transaction_Settlement__c = '{"TransactionSettlements":'+JSON.serialize(setTransactionSettlement)+'}';
                    transEvent.Transaction_Notes__c = trans.Transaction_Notes__c;
                    transEvent.Buyer_Entity__c = trans.Buyer_Entity__c;
                    //transEvent.Enable_Yardi_Upload__c = trans.Enable_Yardi_Upload__c;
                    transEvent.Sale_Price__c = trans.Sale_Price__c;
                    transEvent.Seller_Signer_Entity__c = trans.Seller_Entity__c;
                    transEvent.Contract_Date__c = trans.In_Contract_Date__c;
                    transEvent.Est_Close_Date__c = trans.Est_Close_Date__c;
                    // transEvent.EMD_Amount__c = trans.EMD_Amount__c;
                    //transEvent.Emd_Option_Fee_Status__c = trans.EMD_Option_Fee_Status__c;
                    transEvent.Due_Diligence_Material_Deadline__c = trans.Date_Contingencies_Lift__c;
                    transEvent.Buyer_Commission_Percentage__c = trans.Buyer_Commission_Percent__c;
                    transEvent.EMD_Due_Date__c = trans.EMD_Due_Date__c;
                    transEvent.Option_Fee_Amount__c = trans.Option_Fee_Amount__c;
                    transEvent.Transaction_Id__c = trans.Transaction_Id__c;
                    transEvent.Event_Type__c = 'Contract QC';
                    transEvent.Inspection_Needed__c = trans.Inspection_Needed__c;
                    transEvent.SendOpenEscrowEmail__c = trans.Open_Escrow__c;
                    transEvent.Inspection_Due_Date__c = trans.Inspection_Due_Date__c;
                    transEvent.Assignment_Fee__c = trans.Assignment_Fee__c;

                    if (transSettlement != null){
                        if (transSettlement.emdAmount != null){
                            transEvent.EMD_Amount__c = transSettlement.emdAmount;
                        }
                        if (transSettlement.optionFeeAmount != null){
                            transEvent.Option_Fee_Amount__c = transSettlement.optionFeeAmount;
                        }
                    }

                    if (transactionTask != null){
                        if (transactionTask.status != null){
                            transEvent.Task_Status__c = transactionTask.status;
                        }
                        if (transactionTask.description != null){
                            transEvent.Task_Description__c = transactionTask.description;
                        }
                    }
                } else if (type == 'Submit EMD'){
                    transEvent.Transaction_Notes__c = trans.Transaction_Notes__c;
                    transEvent.Transaction_Instructions__c = trans.Transaction_Instruction__c;
                    transEvent.Transaction_Contact__c = '{"TransactionContacts":' + JSON.serialize(setTransactionContact) + '}';
                    //transEvent.Transaction_Settlement__c = '{"TransactionSettlements":'+JSON.serialize(setTransactionSettlement)+'}';
                    transEvent.Emd_Wired_On_Date__c = trans.Emd_Wired_On_Date__c;
                    transEvent.Emd_Option_Fee_Status__c = trans.EMD_Option_Fee_Status__c;
                    transEvent.EMD_Status__c = trans.EMD_Status__c;
                    // transEvent.EMD_Amount__c = trans.EMD_Amount__c;
                    // transEvent.Option_Fee_Amount__c = trans.Option_Fee_Amount__c;
                    transEvent.Transaction_Id__c = trans.Transaction_Id__c;
                    transEvent.Event_Type__c = 'Submit EMD';

                    if (transSettlement != null){
                        if (transSettlement.emdAmount != null){
                            transEvent.EMD_Amount__c = transSettlement.emdAmount;
                        }
                        if (transSettlement.optionFeeAmount != null){
                            transEvent.Option_Fee_Amount__c = transSettlement.optionFeeAmount;
                        }
                    }

                    if (transactionTask != null){
                        if (transactionTask.status != null){
                            transEvent.Task_Status__c = transactionTask.status;
                        }
                        if (transactionTask.description != null){
                            transEvent.Task_Description__c = transactionTask.description;
                        }
                    }
                }

                lstTransactionEvents.add(transEvent);
                System.debug('lstTransactionEvents::' + lstTransactionEvents);
                List<Database.SaveResult> results = EventBus.publish(lstTransactionEvents);
                if (results[0].isSuccess()){
                    DebugLogHandler.logOutBoundResponse('TransactionHelper', 'publishTransactionPlatformEvents', JSON.serialize(lstTransactionEvents), results[0].getId());
                }

            }
        } catch (Exception exe){
            DebugLogHandler.platformEventException('TransactionHelper', 'publishTransactionPlatformEvents', exe.getStackTraceString(), JSON.serialize(lstTransactionEvents), exe.getMessage());
        }
    }

    /*
     @AuraEnabled
     public static List<TransactionTaskWrapper> transactionTasks(String taskCategory){
     System.debug('-taskCategory-'+taskCategory);
     List<Task> lstTasks = new List<Task>();
     List<TransactionTaskWrapper> lstTransactionTaskWrapper = new List<TransactionTaskWrapper>();
     Map<String,Transaction__c> transactionMap = new Map<String,Transaction__c>();
     Map<String,Task> mapTransactionTask = new Map<String,Task>();
     Id recTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Transaction Tasks').getRecordTypeId();
     if(taskCategory == 'mytasks'){
     lstTasks = [Select Id,whatId,ActivityDate,Subject from task where ownerId =:UserInfo.getUserId() and RecordTypeId=:recTypeId];
     }
     else if(taskCategory == 'alltasks'){
     lstTasks = [Select Id,whatId,ActivityDate,Subject from task where RecordTypeId=:recTypeId];
     }

     for(Task tsk : lstTasks){
     Id relatedId = tsk.whatId;
     if( 'Transaction__c' == relatedId.getSObjectType().getDescribe().getName()){
     mapTransactionTask.put(tsk.whatId,tsk);

     }
     }
     System.debug('-mapTransactionTask-'+mapTransactionTask);
     List<Transaction__c> transList = [Select Id,Name from Transaction__c where Id IN:mapTransactionTask.keySet()];
     for(Transaction__c trans : transList){
     transactionMap.put(trans.Id,trans);
     }
     System.debug('-transactionMap-'+transactionMap);
     for(Task tsk : mapTransactionTask.values()){
     if(tsk.WhatId != null){
     TransactionTaskWrapper wrap = new TransactionTaskWrapper();
     wrap.transactionId = tsk.whatId;
     if(tsk.subject.length() > 20){
     wrap.subject = (tsk.subject).substring(0,20)+'..';
     }
     else{
     wrap.subject = tsk.subject;
     }
     wrap.dueDate = String.valueOf(tsk.ActivityDate);
     System.debug('-oppid-'+tsk.WhatId);
     if((transactionMap.get(tsk.WhatId).Name).length() > 20){
     wrap.transactionName = (transactionMap.get(tsk.WhatId).Name).substring(0,20)+'..';
     }
     else{
     wrap.transactionName = transactionMap.get(tsk.WhatId).Name;
     }
     lstTransactionTaskWrapper.add(wrap);
     }
     }
     return lstTransactionTaskWrapper;
     }

     public class TransactionTaskWrapper{
     @AuraEnabled public String transactionId;
     @AuraEnabled public String subject;
     @AuraEnabled public String transactionName;
     @AuraEnabled public String dueDate;
     }*/
    public static void createTasks(List<Transaction__c> transactionList, Map<Id, Transaction__c> oldTransactions){

        List<Task> taskList = new List<Task>();
        Map<String, String> MapList = new Map<String, String>();

        List<Task> taskLists = [SELECT Id, whatId, Status
                                from TASK
                                WHERE Type = 'QC: Contract Audit' AND WhatId IN:transactionList];

        for (task tsk : taskLists){
            MapList.put(tsk.WhatId, tsk.WhatId);
        }

        for (Transaction__c transactionObj : transactionList){

            if (MapList.get(transactionObj.Id) == null && transactionObj.Roofstock_TC_User__c != null && transactionObj.Transaction_Type__c == 'Acquisition Buy'){

                Task contractAudittask = new Task();
                contractAudittask.Subject = 'QC: Contract Audit';
                contractAudittask.Status = 'Open';
                contractAudittask.Priority = 'Normal';
                contractAudittask.WhatId = transactionObj.ID;
                contractAudittask.Transaction__c = transactionObj.ID;
                contractAudittask.OwnerId = transactionObj.Roofstock_TC_User__c;
                contractAudittask.IsReminderSet = true;
                contractAudittask.ActivityDate = System.today() + 1;
                contractAudittask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Transaction Tasks').getRecordTypeId();
                //contractAudittask.Assigned_On__c=transactionObj.LastModifiedDate;
                contractAudittask.Type = 'QC: Contract Audit';
                taskList.add(contractAudittask);

                Task submitEMDtask = new Task();
                submitEMDtask.Subject = 'Submit EMD';
                submitEMDtask.Status = 'Open';
                submitEMDtask.Priority = 'Normal';
                submitEMDtask.WhatId = transactionObj.ID;
                submitEMDtask.Transaction__c = transactionObj.ID;
                Milestone_task_assignment__mdt mc = Milestone_task_assignment__mdt.getInstance('Submit_EMD_Task_owner');
                String UserName = mc.Task_owner__c;

                List<user> users = [select id, name, username
                                    from user
                                    where username = :UserName];
                if (users != null){
                    submitEMDtask.OwnerId = users[0].id;
                }
                submitEMDtask.IsReminderSet = true;
                submitEMDtask.ActivityDate = System.today() + 1;
                submitEMDtask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Transaction Tasks').getRecordTypeId();
                //contractAudittask.Assigned_On__c=transactionObj.LastModifiedDate;
                submitEMDtask.Type = 'Submit EMD';
                taskList.add(submitEMDtask);
            }
        }

        if (taskList != null && taskList.size() > 0){
            insert taskList;
        }
    }

    public Static void createTransationSnapshot(List<Transaction__c> transList){

        Map<id, Transaction__c> transMap = new Map<id, Transaction__c>();
        List<Transaction_Snapshot__c> tranSnapList = new List<Transaction_Snapshot__c>();
        Map<String, FieldMapping__mdt> mcs = FieldMapping__mdt.getAll();
        Map<String, FieldMapping__mdt> mcsMap = new Map<String, FieldMapping__mdt>();
        set<String> fieldApis = new Set<String>();
        for (FieldMapping__mdt obj : mcs.values()){
            if (obj.isActive__c && obj.Type__c == 'TransactionToTransactionSnapshot'){
                mcsMap.put(obj.TargetField__c, obj);
                if (obj.SourceField__c != null)
                    fieldApis.add(obj.SourceField__c);
            }
        }
        if (!transList.isEmpty()){
            transMap.putAll(transList);
            Map<id, String> TranContactMap = new Map<id, String>();
            Map<id, String> TranContactNameMap = new Map<id, String>();
            Map<id, Map<String, Transaction_Settlement__c>> TranSettlementtMap = new Map<id, Map<String, Transaction_Settlement__c>>();

            List<Transaction_Contact__c> tranContact = [Select id, Contact__r.name, Contact__r.Account.name, Transaction__c
                                                        from Transaction_Contact__c
                                                        where Transaction__c in:transMap.keyset() and Contact_Type__c = 'Title'];
            for (Transaction_Contact__c obj : tranContact){
                TranContactMap.put(obj.Transaction__c, obj.Contact__r.Account.name);
                TranContactNameMap.put(obj.Transaction__c, obj.Contact__r.Name);
            }
            List<Transaction_Settlement__c> tranStateList = [Select id, Transaction__c, Description__c, Unit_Price__c
                                                             from Transaction_Settlement__c
                                                             where Transaction__c in:transMap.keyset()];
            for (Transaction_Settlement__c obj : tranStateList){
                if (TranSettlementtMap.containskey(obj.Transaction__c)){
                    Map<String, Transaction_Settlement__c> descMap = TranSettlementtMap.get(obj.Transaction__c);
                    descMap.put(obj.Description__c, obj);
                    TranSettlementtMap.put(obj.Transaction__c, descMap);
                } else{
                    Map<String, Transaction_Settlement__c> descMap = new Map<String, Transaction_Settlement__c>();
                    descMap.put(obj.Description__c, obj);
                    TranSettlementtMap.put(obj.Transaction__c, descMap);
                }
            }
            String TransactionFeilds = '';

            for (String field : fieldApis){
                TransactionFeilds += ',' + field;
            }
            System.debug(TransactionFeilds);
            //TransactionFeilds.removeEnd(',');
            System.debug(TransactionFeilds);
            Set<id> trasIdSet = new Set<id>();
            trasIdSet = transMap.keySet();

            String type = 'Acquisition Buy';
           // String QuerySt = 'Select id,Buyer_Property_Instance__c, CreatedDate, Transaction_Type__c' + TransactionFeilds + ', (Select Id from Transaction_Snapshots__r) From Transaction__c where id in : trasIdSet AND CreatedDate = LAST_N_DAYS:'+ Label.Transaction_Snapshot_Creation_Days ;
           String QuerySt = 'Select id,Buyer_Property_Instance__c, CreatedDate, Transaction_Type__c' + TransactionFeilds + ', (Select Id from Transaction_Snapshots__r) From Transaction__c where id in : trasIdSet ';
            System.debug(QuerySt);
            List<Transaction__c> transListData = Database.Query(QuerySt);


            // String objectName = 'Transaction_Snapshot__c';
            // String fieldName = 'Review_Checklist_Type__c';

            // Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
            // Schema.DescribeSObjectResult r = s.getDescribe();
            // Map<String, Schema.SObjectField> fields = r.fields.getMap();
            // Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<String> picklistValue = new List<String>();
            // List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            // for (Schema.PicklistEntry pickListVal : ple){
            //     //System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
            //     picklistValue.add(pickListVal.getValue());
            // }

            for (FieldMapping__mdt fieldMapping : [SELECT MasterLabel FROM FieldMapping__mdt
                            ORDER BY Sort_Order__c]){
                picklistValue.add(fieldMapping.MasterLabel);
            }

            System.debug('mcsMap::' + mcsMap);
            System.debug('picklistValue::' + picklistValue);
            Set<id> propertyIdSet = new Set<id>();

            for (Transaction__c obj : transListData){
                System.debug('obj::'+obj.Transaction_Type__c + '--obj--'+obj);
                if(obj.Transaction_Type__c == 'Acquisition Buy' && obj.Transaction_Snapshots__r.size() == 0 ) {
                if (obj.Buyer_Property_Instance__c != null){
                    propertyIdSet.add(obj.Buyer_Property_Instance__c);
                }
                for (String pickValue : picklistValue){
                    if (mcsMap.containskey(pickValue)){
                        System.debug('pickValue::' + pickValue);
                        FieldMapping__mdt fmObj = mcsMap.get(pickValue);

                        Transaction_Snapshot__c tranSnapObj = new Transaction_Snapshot__c();
                        tranSnapObj.Review_Checklist_Type__c = pickValue;
                        tranSnapObj.Transaction__c = obj.id;
                        tranSnapObj.Sort_Order__c = fmObj.Sort_Order__c;

                        Sobject tobj = (Sobject) obj;
                       
                        if (!fmobj.isBlank__c && fmobj.SourceField__c != null){
                            String Datavalue = ExtractFieldValues(tobj, fmObj.SourceField__c);
                            DataValue = DatatypeConvertValues(Datavalue,fmObj);
                            tranSnapObj.Original_Broker_Entry__c = DataValue;
                        }
                        //tranSnapObj.Original_Broker_Entry__c = String.valueOf(tobj.get(mcsMap.get(pickValue).TargetField__c));
                        //tranSnapObj.Original_Broker_Entry__c = String.valueOf();

                        if (pickValue == 'Title Company' && TranContactMap.containskey(obj.id)){
                            tranSnapObj.Original_Broker_Entry__c = TranContactMap.get(obj.id);
                        }
                        if (pickValue == 'Title Company Contact' && TranContactNameMap.containskey(obj.id)){
                            tranSnapObj.Original_Broker_Entry__c = TranContactNameMap.get(obj.id);
                        }
                        if (pickValue == 'Option Fee' && TranSettlementtMap.containskey(obj.id)){
                            Map<String, Transaction_Settlement__c> tempMap = TranSettlementtMap.get(obj.id);
                            if (tempMap != null && tempMap.containskey('Option Fee'))
                                tranSnapObj.Original_Broker_Entry__c = '$'+String.valueOf(tempMap.get('Option Fee').Unit_Price__c);
                        }
                        if (pickValue == 'EMD Amount' && TranSettlementtMap.containskey(obj.id)){
                            Map<String, Transaction_Settlement__c> tempMap = TranSettlementtMap.get(obj.id);
                            if (tempMap != null && tempMap.containskey('Earnest Money Deposit'))
                                tranSnapObj.Original_Broker_Entry__c = '$'+String.valueOf(tempMap.get('Earnest Money Deposit').Unit_Price__c);
                        }
                        tranSnapList.add(tranSnapObj);
                    }
                }

                }

            }
            if (!propertyIdSet.isEmpty()){
                List<Property_Unit__c> propertyUnitList = [Select id, Occupancy_at_Closing__c, Property__c, Unit_Number__c,HomeCode__c
                                                           from Property_Unit__c
                                                           where Property__c in:propertyIdSet];
                System.debug(propertyUnitList.size());
                Map<id, List<Property_Unit__c>> propertyPropertyUnitMap = new Map<id, List<Property_Unit__c>>();
                for (Property_Unit__c obj : propertyUnitList){
                    if (propertyPropertyUnitMap.containskey(obj.Property__c)){
                        propertyPropertyUnitMap.get(obj.Property__c).add(obj);
                    } else{
                        propertyPropertyUnitMap.put(obj.Property__c, new List<Property_Unit__c>{ obj });
                    }
                }
                
                for (Transaction__c obj : transListData){
                    if(obj.Transaction_Type__c == 'Acquisition Buy' && obj.Transaction_Snapshots__r.size() == 0) {
                    if (obj.Buyer_Property_Instance__c != null && propertyPropertyUnitMap.containsKey(obj.Buyer_Property_Instance__c)){
                        for (Property_Unit__c pobj : propertyPropertyUnitMap.get(obj.Buyer_Property_Instance__c)){
                            integer count=20;
                            Transaction_Snapshot__c tranSnapObj = new Transaction_Snapshot__c();
                            tranSnapObj.Original_Broker_Entry__c = pobj.Occupancy_at_Closing__c;
                            tranSnapObj.Review_Checklist_Type__c = 'Occupancy Status-' + pobj.HomeCode__c;
                            tranSnapObj.Transaction__c = obj.id;
                            tranSnapObj.Sort_Order__c = count+1;
                            tranSnapObj.HomeCode__c = pobj.HomeCode__c;
                            if (pobj.Unit_Number__c != null)
                                tranSnapObj.Unit_Number__c = pobj.Unit_Number__c;
                            else{
                                tranSnapObj.Unit_Number__c = '';
                            }
                            System.debug('Occupancy Status::' + tranSnapObj);
                            tranSnapList.add(tranSnapObj);
                            //tranSnapObj.Transaction__c = obj.id;
                            //tranSnapObj.Sort_Order__c = fmObj.Sort_Order__c;
                        }
                      }
                    }
                }

            }
            if (!tranSnapList.isEmpty()){
                System.debug('tranSnapList::' + tranSnapList);
                Database.insert (tranSnapList, false);
            }


        }
    }

    public static string DatatypeConvertValues(String dvalue, FieldMapping__mdt fm){

            String stValue =dvalue;
            try{
                if(fm.DataType__c != null && fm.DataType__c =='Currency')
                    stValue ='$'+stValue;
                else if(fm.DataType__c != null && fm.DataType__c =='Percentage')
                    stValue =stValue+'%';
                else if(fm.DataType__c != null && fm.DataType__c =='Date')
                {
                    
                        Date dt = Date.valueOf( dvalue );  
                        stValue =dt.format();
                    
                }
                else if(fm.DataType__c != null && fm.DataType__c =='Boolean')
                {
                        Boolean b = Boolean.valueOf(stValue);
                        if(b)
                        stValue ='Yes';
                        else
                        stValue = 'No';
                    
                }
            }
            catch(Exception ex){

            }

            return stValue;

    }

    public static string ExtractFieldValues(sObject sb, string fieldAPIName){
        string fvalue = '';
        if (fieldAPIName.contains('.')){
            List<string> splitedFields = fieldAPIName.split('\\.');
            try{
                for (integer i = 0; i < splitedFields.size() - 1; i++){
                    sb = sb.getSobject(splitedFields[i]);
                }
                fvalue = string.valueof(sb.get(splitedFields[splitedFields.size() - 1]));
            } catch (exception ex){
                system.debug('******exception while fetching fieldValues as relationship ' + fieldAPIName + '  value is blank.' + ex.getmessage());
                fvalue = '';
            }

        } else if (sb.get(fieldAPIName) != null){
            fvalue = string.valueOf(sb.get(fieldAPIName));
        }
        return fvalue;
    }

    public static void setMilestone(List<Transaction__c> transList){
        for (Transaction__c obj : transList){
            if (obj.Transaction_Type__c == 'Acquisition Buy' ){
                obj.Milestone__c = 'New Transaction';
            }
        }
    }

}
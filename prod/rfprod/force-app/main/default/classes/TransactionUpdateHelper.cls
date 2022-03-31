//public class TransactionUpdateHelper {
public class TransactionUpdateHelper{
    //public class OtherException extends Exception  {}
    public static void updateTransaction(List<Transaction_Update__e> newRecordsList){
        try{
            System.debug('-newRecordsList-' + newRecordsList);
            Map<String, Transaction_Update__e> transactionEventMap = new Map<String, Transaction_Update__e>();
            Map<String, Transaction__c> transactionMap = new Map<String, Transaction__c>();
            Map<String, List<Object>> mapTransIdTransContactsRequest = new Map<String, List<object>>();
            Map<String, Map<String, TransactionPlatformEventWrapper.TransactionContact>> mapTransIdTransContactsReq = new Map<String, Map<String, TransactionPlatformEventWrapper.TransactionContact>>();
            Map<String, Map<String, Transaction_Contact__c>> mapTransIdTransContactsMatch = new Map<String, Map<String, Transaction_Contact__c>>();
            Map<String, Map<String, Transaction_Settlement__c>> mapTransIdTransSettlementMatch = new Map<String, Map<String, Transaction_Settlement__c>>();
            Map<String, Map<String, Inspection__c>> mapTransactionInspection = new Map<String, Map<String, Inspection__c>>();
            List<Transaction__c> lstUpdateTransaction = new List<Transaction__c>();
            List<Inspection__c> lstUpdateInspection = new List<Inspection__c>();
            List<Transaction_Settlement__c> lstTransactionSettlement = new List<Transaction_Settlement__c>();
            List<Property_Unit__c> lstUpdatePropertyUnit = new List<Property_Unit__c>();
            Map<String, String> mapTransactionProperty = new Map<String, String>();
            Map<String, Property_Unit__c> mapPropertyUnit = new Map<String, Property_Unit__c>();
            //Map<String,List<Property_Unit__c>> mapPropertyPU = new Map<String,List<Property_Unit__c>>();

            Set<String> setUserEmail = new Set<String>();
            for (Transaction_Update__e tu : newRecordsList){

                transactionEventMap.put(tu.Transaction_Id__c, tu);
                setUserEmail.add(tu.Transaction_Coordinator__c);
                setUserEmail.add(tu.Customer_Service__c);
                setUserEmail.add(tu.Underwriting_Analyst__c);
                setUserEmail.add(tu.Roofstock_Advisor__c);
                setUserEmail.add(tu.Roofstock_Inventory_Owner__c);
                if (tu.Accounting_Contact__c != null){
                    setUserEmail.add((tu.Accounting_Contact__c).toLowerCase());
                }
            }
            DebugLogHandler.logInboundResponse('TransactionUpdateHelper', 'updateTransaction', JSON.serialize(newRecordsList), '');
            Map<String, String> emailUserMap = new Map<String, String>();
            List<User> lstUser = [Select Id, Name, Email
                                  from USer
                                  where Email IN:setUserEmail];
            for (User usr : lstUser){
                emailUserMap.put(usr.email, usr.Id);
            }
            System.debug('-emailUserMap-' + emailUserMap);
            List<Transaction__c> lstTransaction = [select Id, Transaction_Id__c, Buyer_Property_Instance__c, In_Contract_Price__c, Transaction_Notes__c, Buyer_Entity__c, Enable_Yardi_Upload__c, Seller_Entity__c, In_Contract_Date__c, Date_Contingencies_Lift__c, Est_Close_Date__c, Inspection_Contingency__c, Contingency_Status__c, IC_Expiration_Date__c, EMD_Amount__c, Option_Fee_Amount__c, EMD_Due_Date__c, Roofstock_Accounting__c, Inspection_Due_Date__c, Buyer_Commission_Percent__c, Seller_Commission_Min_Amount__c
                                                   from Transaction__c
                                                   where Transaction_Id__c IN:transactionEventMap.keySet()];
            for (Transaction__c trans : lstTransaction){
                mapTransactionProperty.put(trans.Id, trans.Buyer_Property_Instance__c);
            }
            List<Property_Unit__c> lstPropertyUnit = [select Id, PropertyUnitId__c, Property__c, Property_Access_Notes__c, Property_Access_Method_Type__c, Occupancy_Status__c
                                                      from Property_Unit__c
                                                      where Property__c IN:mapTransactionProperty.values()];
            for (Property_Unit__c pu : lstPropertyUnit){
                mapPropertyUnit.put(pu.PropertyUnitId__c, pu);
            }

            for (Transaction_Contact__c tc : [select Id, Transaction__r.Transaction_Id__c, Contact__c, Type__c
                                              from Transaction_Contact__c
                                              where Transaction__r.Transaction_Id__c IN:transactionEventMap.keySet()]){
                if (!mapTransIdTransContactsMatch.containsKey(tc.Transaction__r.Transaction_Id__c)){
                    mapTransIdTransContactsMatch.put(tc.Transaction__r.Transaction_Id__c, new Map<String, Transaction_Contact__c>());
                }
                mapTransIdTransContactsMatch.get(tc.Transaction__r.Transaction_Id__c).put(tc.Type__c, tc);
            }
            for (Transaction_Settlement__c ts : [select Id, Transaction__r.Transaction_Id__c, Description__c
                                                 from Transaction_Settlement__c
                                                 where Transaction__r.Transaction_Id__c IN:transactionEventMap.keySet()]){
                if (!mapTransIdTransSettlementMatch.containsKey(ts.Transaction__r.Transaction_Id__c)){
                    mapTransIdTransSettlementMatch.put(ts.Transaction__r.Transaction_Id__c, new Map<String, Transaction_Settlement__c>());
                }
                mapTransIdTransSettlementMatch.get(ts.Transaction__r.Transaction_Id__c).put(ts.Description__c, ts);
            }
            for (Inspection__c insp : [select Id, Dilligence_Id__c, Transaction__r.Transaction_Id__c, Transaction__c, Diligence_Deadline__c, Inspection_Due_Date__c
                                       from Inspection__c
                                       where Transaction__r.Transaction_Id__c IN:transactionEventMap.keySet()
                                       order by createddate asc]){
                //mapTransactionInspection.put(insp.Transaction__r.Transaction_Id__c,insp);
                if (!mapTransactionInspection.containsKey(insp.Transaction__r.Transaction_Id__c)){
                    mapTransactionInspection.put(insp.Transaction__r.Transaction_Id__c, new Map<String, Inspection__c>());
                }
                mapTransactionInspection.get(insp.Transaction__r.Transaction_Id__c).put(insp.Dilligence_Id__c, insp);
            }

            // Query Tasks
            Map<String, Schema.RecordTypeInfo> rtMapByDeveloperName = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName();
            String recordTypeId = rtMapByDeveloperName.get('Transaction_Tasks').getRecordTypeId();
            Map<String, List<Task>> mapTransactionTask = new Map<String, List<Task>>();
            List<Task> tasks =  new List<Task>();
            for (Task tsk : [Select Id, Transaction__r.Transaction_Id__c, Status, Description, Type
                             from Task
                             where Transaction__r.Transaction_Id__c IN:transactionEventMap.keySet() and Type IN ('QC: Contract Audit', 'Submit EMD') and RecordTypeId = :recordTypeId]){
                if (null != mapTransactionTask.get(tsk.Transaction__r.Transaction_Id__c)){
                    tasks = mapTransactionTask.get(tsk.Transaction__r.Transaction_Id__c);
                    tasks.add(tsk);
                    mapTransactionTask.put(tsk.Transaction__r.Transaction_Id__c, tasks);
                } else {
                    tasks.add(tsk);
                    mapTransactionTask.put(tsk.Transaction__r.Transaction_Id__c, tasks);
                }     
            }

            for (Transaction__c trans : lstTransaction){
                transactionMap.put(trans.Transaction_Id__c, trans);
            }
            Set<String> setAllContactBpmContactIds = new Set<String>();
            Set<String> setRoofstockAccountIds = new Set<String>();
            Map<String, TransactionPlatformEventWrapper.TransactionContact> mapEmailTransContactRequest = new Map<String, TransactionPlatformEventWrapper.TransactionContact>();
            //Get Input Emails,create Existing Contact Map and create new contact if doesn't exist.
            Map<String, RESTContactHelper.Contacts> allContactListMap = new Map<String, RESTContactHelper.Contacts>();
            RESTContactHelper.PostResponse conResponse;
            List<RESTContactHelper.ResponseBody> conRespBody = new List<RESTContactHelper.ResponseBody>();
            List<RESTContactHelper.Contacts> lstContactsWrapper = new List<RESTContactHelper.Contacts>();
            List<TransactionPlatformEventWrapper.TransactionContact> lstTransContact = new List<TransactionPlatformEventWrapper.TransactionContact>();
            Set<String> setBpmContactIds = new Set<String>();
            for (Transaction_Update__e transactionUpdateEvent : newRecordsList){
                if (transactionMap.get(transactionUpdateEvent.Transaction_Id__c) != null){
                    Map<String, Map<String, TransactionPlatformEventWrapper.TransactionContact>> mapTransIdTransContactsReqInitial;

                    String transactionContact;
                    transactionContact = transactionUpdateEvent.Transaction_Contact__c;
                    if (transactionContact != null && transactionContact != ''){
                        mapTransIdTransContactsReqInitial = transactionContactRequest(transactionContact, transactionUpdateEvent);
                        System.debug('-mapTransIdTransContactsReqInitial-' + mapTransIdTransContactsReqInitial);
                        System.debug('-lst-' + mapTransIdTransContactsReq.get(transactionUpdateEvent.Transaction_Id__c));
                        if (mapTransIdTransContactsReqInitial.get(transactionUpdateEvent.Transaction_Id__c) != null){
                            lstTransContact = mapTransIdTransContactsReqInitial.get(transactionUpdateEvent.Transaction_Id__c).values();


                            for (TransactionPlatformEventWrapper.TransactionContact tc : lstTransContact){
                                RESTContactHelper.Contacts cons = new RESTContactHelper.Contacts();
                                cons.bpmContactId = tc.bpmContactId;
                                cons.rsAccountId = tc.rsAccountId;
                                cons.roofstockUserId = tc.roofstockUserId;
                                cons.type = tc.type;
                                cons.email = tc.email;
                                cons.mobile = tc.mobile;
                                cons.firstName = tc.firstName;
                                cons.lastName = tc.lastName;
                                if (tc.contactNumber != null){
                                    cons.contactNumber = Integer.valueOf(tc.contactNumber);
                                }
                                mapEmailTransContactRequest.put(tc.bpmContactId, tc);
                                lstContactsWrapper.add(cons);
                                setRoofstockAccountIds.add(tc.rsAccountId);
                            }
                        }
                    }
                }
            }
            if (!setRoofstockAccountIds.isEmpty()){
                conResponse = RESTContactHelper.UpdateContact(lstContactsWrapper);
                if (conResponse != null && conResponse.responseBody != null){
                    RESTContactHelper.ResponseWrapper respWrap = conResponse.responseBody;
                    conRespBody = respWrap.contactResponse;
                    for (RESTContactHelper.ResponseBody res : conRespBody){
                        setBpmContactIds.add(res.bpmContactId);
                    }
                }
            }
            System.debug('-setBpmContactIds-' + setBpmContactIds);
            Map<String, Contact> mapExistingContacts = new Map<String, Contact>();
            Map<String, Account> mapRsIdAccountMap = new Map<String, Account>();
            List<Contact> lstMatchingContacts = [select Id, Email, BPM_Contact_Id__c, MobilePhone, firstName, lastname
                                                 from Contact
                                                 where BPM_Contact_Id__c IN:setBpmContactIds];
            for (Contact con : lstMatchingContacts){
                mapExistingContacts.put(con.BPM_Contact_Id__c, con);
            }
            for (Account acc : [select Id, Roofstock_Account_ID__c
                                from Account
                                where Roofstock_Account_ID__c IN:setRoofstockAccountIds]){
                mapRsIdAccountMap.put(acc.Roofstock_Account_ID__c, acc);
            }
            List<Contact> lstNewContacts = new List<Contact>();
            List<Contact> lstExistingContacts = new List<Contact>();
            for (TransactionPlatformEventWrapper.TransactionContact reqTC : mapEmailTransContactRequest.values()){
                System.debug('-reqTC-' + reqTC);
                if (mapExistingContacts != null){
                    if (mapExistingContacts.containsKey(reqTC.bpmContactId)){
                        Contact existingContact = mapExistingContacts.get(reqTC.bpmContactId);
                        existingContact.FirstName = reqTC.firstName;
                        existingContact.LastName = reqTC.lastName;
                        existingContact.Phone = reqTC.mobile;
                        existingContact.MobilePhone = reqTC.mobile;
                        if (mapRsIdAccountMap.containsKey(reqTC.rsAccountId)){
                            existingContact.AccountId = mapRsIdAccountMap.get(reqTC.rsAccountId).Id;
                        }
                        lstExistingContacts.add(existingContact);
                    } else{
                        System.debug('-New-');
                        Contact con = new Contact();
                        con.Email = reqTC.email;
                        con.FirstName = reqTC.firstName;
                        con.LastName = reqTC.lastName;
                        con.Phone = reqTC.mobile;
                        con.MobilePhone = reqTC.mobile;
                        if (mapRsIdAccountMap.containsKey(reqTC.rsAccountId)){
                            con.AccountId = mapRsIdAccountMap.get(reqTC.rsAccountId).Id;
                        }
                        lstNewContacts.add(con);
                    }

                }
            }
            if (!lstNewContacts.isEmpty()){
                insert lstNewContacts;
            }
            if (!lstExistingContacts.isEmpty()){
                update lstExistingContacts;
            }
            //Process Request
            List<Task> lstTasks = new List<Task>();
            Map<String, Date> mapTransactionInspectionDueDate = new Map<String, Date>();
            for (Transaction_Update__e transactionUpdateEvent : newRecordsList){
                //mapTransIdTransContactsReq = new Map<String,Map<String,TransactionPlatformEventWrapper.TransactionContact>>()
                if (transactionMap.get(transactionUpdateEvent.Transaction_Id__c) != null){
                    String transactionContact;
                    String inspection;
                    String propertyUnit;

                    Transaction__c trans = transactionMap.get(transactionUpdateEvent.Transaction_Id__c);
                    if (transactionUpdateEvent.Event_Type__c == 'Adhoc Update'){
                        trans.Transaction_Notes__c = transactionUpdateEvent.Transaction_Notes__c;
                        trans.Est_Close_Date__c = transactionUpdateEvent.Est_Close_Date__c;
                        trans.Contingency_Status__c = transactionUpdateEvent.Contingency_Status__c;
                        trans.Date_Contingencies_Lift__c = transactionUpdateEvent.Date_Contingency_Lift__c;
                        trans.Appraisal_Exp_Date__c = transactionUpdateEvent.Appraisal_Due_Date__c;
                        // trans.IC_Expiration_Date__c = transactionUpdateEvent.Inspection_Contingency_Expiration_Date__c;
                        trans.Buyer_Commission_Percent__c = transactionUpdateEvent.Buyer_Commission_Percentage__c;
                        trans.Seller_Commission_Percent__c = transactionUpdateEvent.Seller_Commission_Percentage__c;
                        trans.Seller_Commission_Min_Amount__c = transactionUpdateEvent.Seller_Commission_Min_Amount__c;
                        // trans.Origination_Source__c = transactionUpdateEvent.Lead_Origination_Source__c;
                        if (emailUserMap.get(transactionUpdateEvent.Transaction_Coordinator__c) != null){
                            trans.Roofstock_TC_User__c = emailUserMap.get(transactionUpdateEvent.Transaction_Coordinator__c);
                        }
                        if (emailUserMap.get(transactionUpdateEvent.Customer_Service__c) != null){
                            trans.Roofstock_Customer_Service__c = emailUserMap.get(transactionUpdateEvent.Customer_Service__c);
                        }
                        if (emailUserMap.get(transactionUpdateEvent.Underwriting_Analyst__c) != null){
                            trans.Underwriting_Analyst__c = emailUserMap.get(transactionUpdateEvent.Underwriting_Analyst__c);
                        }
                        if (emailUserMap.get(transactionUpdateEvent.Roofstock_Advisor__c) != null){
                            trans.Roofstock_Advisor__c = emailUserMap.get(transactionUpdateEvent.Roofstock_Advisor__c);
                        }
                        if (emailUserMap.get(transactionUpdateEvent.Roofstock_Inventory_Owner__c) != null){
                            trans.Roofstock_Inventory_Owner__c = emailUserMap.get(transactionUpdateEvent.Roofstock_Inventory_Owner__c);
                        }
                        lstUpdateTransaction.add(trans);

                    } else if (transactionUpdateEvent.Event_Type__c == 'Contract QC'){
                        trans.Transaction_Notes__c = transactionUpdateEvent.Transaction_Notes__c;
                        trans.Buyer_Entity__c = transactionUpdateEvent.Buyer_Entity__c;
                        trans.Enable_Yardi_Upload__c = transactionUpdateEvent.Enable_Yardi_Upload__c;
                        //trans.Contract_Price__c = transactionUpdateEvent.Contract_Price__c;
                        trans.Sale_Price__c = transactionUpdateEvent.Sale_Price__c;
                        trans.In_Contract_Price__c = transactionUpdateEvent.In_Contract_Price__c;
                        trans.Seller_Entity__c = transactionUpdateEvent.Seller_Entity__c;
                        trans.In_Contract_Date__c = Date.valueOf(transactionUpdateEvent.Contract_Date__c);
                        trans.Date_Contingencies_Lift__c = Date.valueOf(transactionUpdateEvent.Date_Contingency_Lift__c);
                        trans.Est_Close_Date__c = Date.valueOf(transactionUpdateEvent.Est_Close_Date__c);
                        trans.Inspection_Contingency__c = transactionUpdateEvent.Inspection_Contingency__c;
                        trans.Contingency_Status__c = transactionUpdateEvent.Contingency_Status__c;
                        //trans.IC_Expiration_Date__c = Date.valueOf(transactionUpdateEvent.Inspection_Contingency_Expiration_Date__c);
                        trans.EMD_Amount__c = transactionUpdateEvent.EMD_Amount__c;
                        trans.Option_Fee_Amount__c = transactionUpdateEvent.Option_Fee_Amount__c;
                        trans.EMD_Due_Date__c = Date.valueOf(transactionUpdateEvent.EMD_Due_Date__c);
                        trans.Inspection_Needed__c = transactionUpdateEvent.Inspection_Needed__c;
                        trans.Open_Escrow__c = transactionUpdateEvent.SendOpenEscrowEmail__c;
                        if (transactionUpdateEvent.Inspection_Due_Date__c != null){
                            if (trans.Inspection_Due_Date__c != transactionUpdateEvent.Inspection_Due_Date__c){
                                trans.Inspection_Due_Date__c = transactionUpdateEvent.Inspection_Due_Date__c;
                                mapTransactionInspectionDueDate.put(trans.Id, transactionUpdateEvent.Inspection_Due_Date__c);
                            }
                        }

                        if (transactionUpdateEvent.Accounting_Contact__c != null){
                            trans.Roofstock_Accounting__c = emailUserMap.get((transactionUpdateEvent.Accounting_Contact__c).toLowerCase());
                        }
                        //Transaction Contact/Property Unit/Inspection
                        transactionContact = transactionUpdateEvent.Transaction_Contact__c;
                        inspection = transactionUpdateEvent.Inspection__c;
                        propertyUnit = transactionUpdateEvent.Property_Unit__c;
                        mapTransIdTransContactsReq = transactionContactRequest(transactionContact, transactionUpdateEvent);
                        System.debug('-mapTransIdTransContactsReq-' + mapTransIdTransContactsReq);
                        if (mapTransIdTransContactsReq.get(transactionUpdateEvent.Transaction_Id__c) != null){
                            lstTransContact = mapTransIdTransContactsReq.get(transactionUpdateEvent.Transaction_Id__c).values();
                            for (TransactionPlatformEventWrapper.TransactionContact tc : lstTransContact){
                                setAllContactBpmContactIds.add(tc.bpmContactId);
                            }
                        }
                        System.debug('-setAllContactBpmContactIds-' + setAllContactBpmContactIds);
                        //setAllContactEmails.add(mapTransIdTransContactsReq.get(transactionUpdateEvent.Transaction_Id__c).values().email);
                        if ((inspection != null && inspection != '')){
                            lstUpdateInspection = inspectionRequest(inspection, transactionUpdateEvent, mapTransactionInspection);
                        }
                        if (propertyUnit != null && propertyUnit != ''){
                            lstUpdatePropertyUnit = propertyUnitRequest(propertyUnit, transactionUpdateEvent, mapPropertyUnit);
                        }
                        lstTransactionSettlement = transactionSettlementRequest(transactionUpdateEvent.EMD_Amount__c, transactionUpdateEvent.Option_Fee_Amount__c, transactionUpdateEvent, mapTransIdTransSettlementMatch, transactionMap);
                        lstUpdateTransaction.add(trans);
                        //Task
                        if (!mapTransactionTask.isEmpty()){
                            if (mapTransactionTask.get(transactionUpdateEvent.Transaction_Id__c) != null){
                                List<Task> qcTasks = mapTransactionTask.get(transactionUpdateEvent.Transaction_Id__c) ;
                                for (Task tsk : qcTasks){
                                    if(tsk.Type == 'QC: Contract Audit'){
                                        if (transactionUpdateEvent.Task_Status__c != null){
                                            tsk.Status = transactionUpdateEvent.Task_Status__c;
                                        }
                                        if (transactionUpdateEvent.Task_Description__c != null){
                                            tsk.Description = transactionUpdateEvent.Task_Description__c;
                                        }
                                        lstTasks.add(tsk);
                                    }
                                }
                            }
                        }
                    } else if (transactionUpdateEvent.Event_Type__c == 'Submit EMD'){
                        trans.Transaction_Notes__c = transactionUpdateEvent.Transaction_Notes__c;
                        trans.Transaction_Instruction__c = transactionUpdateEvent.Transaction_Instructions__c;
                        trans.Emd_Wired_On_Date__c = transactionUpdateEvent.Emd_Wired_On_Date__c;
                        trans.EMD_Status__c = transactionUpdateEvent.EMD_Status__c;
                        trans.EMD_Option_Fee_Status__c = transactionUpdateEvent.Option_Fee_Status__c;
                        trans.EMD_Amount__c = transactionUpdateEvent.EMD_Amount__c;
                        trans.Option_Fee_Amount__c = transactionUpdateEvent.Option_Fee_Amount__c;
                        transactionContact = transactionUpdateEvent.Transaction_Contact__c;
                        lstTransactionSettlement = transactionSettlementRequest(transactionUpdateEvent.EMD_Amount__c, transactionUpdateEvent.Option_Fee_Amount__c, transactionUpdateEvent, mapTransIdTransSettlementMatch, transactionMap);
                        mapTransIdTransContactsReq = transactionContactRequest(transactionContact, transactionUpdateEvent);
                        System.debug('-mapTransIdTransContactsReq-' + mapTransIdTransContactsReq);
                        if (mapTransIdTransContactsReq != null){
                            if (mapTransIdTransContactsReq.get(transactionUpdateEvent.Transaction_Id__c).values() != null){
                                lstTransContact = mapTransIdTransContactsReq.get(transactionUpdateEvent.Transaction_Id__c).values();
                                for (TransactionPlatformEventWrapper.TransactionContact tc : lstTransContact){
                                    setAllContactBpmContactIds.add(tc.bpmContactId);
                                }
                            }
                        }

                        //Task
                        if (!mapTransactionTask.isEmpty()){
                            if (mapTransactionTask.get(transactionUpdateEvent.Transaction_Id__c) != null){
                                List<Task> emdTasks = mapTransactionTask.get(transactionUpdateEvent.Transaction_Id__c) ;
                                for (Task tsk : emdTasks){
                                    if(tsk.Type == 'Submit EMD'){
                                        if (transactionUpdateEvent.Task_Status__c != null){
                                            tsk.Status = transactionUpdateEvent.Task_Status__c;
                                        }
                                        if (transactionUpdateEvent.Task_Description__c != null){
                                            tsk.Description = transactionUpdateEvent.Task_Description__c;
                                        }
                                        lstTasks.add(tsk);
                                    }
                                }
                            }
                        }
                        lstUpdateTransaction.add(trans);
                    }
                }
            }
            Map<String, String> bpmContactMap = new Map<String, String>();
            List<Contact> lstContact = [select Id, BPM_Contact_Id__c, Email, FirstName, LastName
                                        from Contact
                                        where BPM_Contact_Id__c IN:setAllContactBpmContactIds];
            if (!lstContact.isEmpty()){
                for (Contact con : lstContact){
                    bpmContactMap.put(con.BPM_Contact_Id__c, con.Id);
                }
            }
            //Update Inspection Due Date
            List<Inspection__c> lstInspectionUpdate = new List<Inspection__c>();
            if (!mapTransactionInspectionDueDate.isEmpty()){
                for (Inspection__c insp : [select Id, Transaction__c, Inspection_Due_Date__c
                                           from Inspection__c
                                           where Transaction__c = :mapTransactionInspectionDueDate.keyset()]){
                    insp.Inspection_Due_Date__c = mapTransactionInspectionDueDate.get(insp.Transaction__c);
                    lstInspectionUpdate.add(insp);
                }
                update lstInspectionUpdate;
            }

            System.debug('--lstUpdateTransaction--' + lstUpdateTransaction);
            if (!lstUpdateTransaction.isEmpty()){
                update lstUpdateTransaction;
            }
            if (!lstUpdateInspection.isEmpty()){
                update lstUpdateInspection;
            }
            if (!lstUpdatePropertyUnit.isEmpty()){
                update lstUpdatePropertyUnit;
            }
            if (!lstTransactionSettlement.isEmpty()){
                upsert lstTransactionSettlement Unique_Id__c;
            }
            if (!lstTasks.isEmpty()){
                update lstTasks;
            }
            updateTransactionContact(bpmContactMap, transactionMap, mapTransIdTransContactsMatch, mapTransIdTransContactsReq);
            //throw new OtherException('This is bad');
        } catch (Exception exe){
            //catch(OtherException oe){
            DebugLogHandler.platformEventException('TransactionUpdateHelper', 'updateTransaction', exe.getStackTraceString(), JSON.serialize(newRecordsList), exe.getMessage());
            //DebugLogHandler.platformEventException('TransactionUpdateHelper','updateTransaction',oe.getStackTraceString(),JSON.serialize(newRecordsList),oe.getMessage());

        }
    }

    public static Map<String, Map<String, TransactionPlatformEventWrapper.TransactionContact>> transactionContactRequest(String transactionContact, Transaction_Update__e transactionUpdateEvent){
        Map<String, Map<String, TransactionPlatformEventWrapper.TransactionContact>> mapTransIdTransContactsReq = new Map<String, Map<String, TransactionPlatformEventWrapper.TransactionContact>>();

        List<String> lstEmail = new List<String>();
        //Deserialize Transaction Contact JSON
        Map<String, Object> rootTransactionContact = (Map<String, Object>)JSON.deserializeUntyped(transactionContact);
        List<Object> itemsTransactionContact = (List<Object>)rootTransactionContact.get('transactionContacts');
        for (Object item : itemsTransactionContact){
            String contactType = '';
            String count = '';
            TransactionPlatformEventWrapper.TransactionContact transContact = new TransactionPlatformEventWrapper.TransactionContact();
            Map<String, Object> i = (Map<String, Object>)item;
            if (i.get('email') != null){
                transContact.email = String.valueOf(i.get('email'));
                lstEmail.add(String.valueOf(i.get('email')));
            }
            if (i.get('contactNumber') != null){
                transContact.contactNumber = String.valueOf(i.get('contactNumber'));
                count = String.valueOf(i.get('contactNumber'));
            }
            if (i.get('type') != null){
                transContact.type = String.valueOf(i.get('type'));
                contactType = String.valueOf(i.get('type')) + count;
            }
            if (i.get('mobile') != null){
                transContact.mobile = String.valueOf(i.get('mobile'));
            }
            if (i.get('bpmContactId') != null){
                transContact.bpmContactId = String.valueOf(i.get('bpmContactId'));
            }
            if (i.get('companyName') != null){
                transContact.companyName = String.valueOf(i.get('companyName'));
            }
            if (i.get('firstName') != null){
                transContact.firstName = String.valueOf(i.get('firstName'));
            }
            if (i.get('lastName') != null){
                transContact.lastName = String.valueOf(i.get('lastName'));
            }
            if (i.get('roofstockUserId') != null){
                transContact.roofstockUserId = String.valueOf(i.get('roofstockUserId'));
            }
            if (i.get('rsAccountId') != null){
                transContact.rsAccountId = String.valueOf(i.get('rsAccountId'));
            }
            if (!mapTransIdTransContactsReq.containskey(transactionUpdateEvent.Transaction_Id__c)){
                mapTransIdTransContactsReq.put(transactionUpdateEvent.Transaction_Id__c, new map<String, TransactionPlatformEventWrapper.TransactionContact>());
            }
            mapTransIdTransContactsReq.get(transactionUpdateEvent.Transaction_Id__c).put(contactType, transContact);
            System.debug(i.get('type'));

        }
        return mapTransIdTransContactsReq;
    }

    Public static List<Inspection__c> inspectionRequest(String inspection, Transaction_Update__e transactionUpdateEvent, Map<String, Map<String, Inspection__c>> mapTransactionInspection){
        //Deserialize Inspection JSON
        List<Inspection__c> lstUpdateInspection = new List<Inspection__c>();
        Map<String, Object> rootInspection = (Map<String, Object>)JSON.deserializeUntyped(inspection);
        List<Object> itemsInspection = (List<Object>)rootInspection.get('inspections');
        Map<String, Inspection__c> mapInspection = mapTransactionInspection.get(transactionUpdateEvent.Transaction_Id__c);
        for (Object item : itemsInspection){
            Map<String, Object> i = (Map<String, Object>)item;
            if (i.get('inspectionId') != null){
                if (mapInspection.containsKey(String.valueOf(i.get('inspectionId')))){
                    Inspection__c inspectionMatch = mapInspection.get(String.valueOf(i.get('inspectionId')));
                    if (i.get('diligenceDeadline') != null){
                        System.debug('-diligenceDeadline-' + i.get('diligenceDeadline'));
                        String diligenceDeadline = String.valueOf(i.get('diligenceDeadline'));
                        inspectionMatch.Diligence_Deadline__c = Date.valueOf(diligenceDeadline);
                    }
                    if (i.get('inspectionDueDate') != null){
                        String inspectionDueDate = String.valueOf(i.get('inspectionDueDate'));
                        inspectionMatch.Inspection_Due_Date__c = Date.valueOf(inspectionDueDate);
                    }
                    lstUpdateInspection.add(inspectionMatch);
                }

            }


        }
        return lstUpdateInspection;
    }

    Public static List<Property_Unit__c> propertyUnitRequest(String propertyUnit, Transaction_Update__e transactionUpdateEvent, Map<String, Property_Unit__c> mapPropertyUnit){
        //Deserialize Property Unit JSON
        List<Property_Unit__c> lstUpdatePropertyUnit = new List<Property_Unit__c>();

        Map<String, Object> rootPropertyUnit = (Map<String, Object>)JSON.deserializeUntyped(propertyUnit);
        List<Object> itemsPropertyUnit = (List<Object>)rootPropertyUnit.get('property_units');
        //Map<String,Inspection__c> mapPropertyUnit = mapTransactionInspection.get(transactionUpdateEvent.Transaction_Id__c);
        for (Object item : itemsPropertyUnit){
            Map<String, Object> i = (Map<String, Object>)item;
            if (i.get('id') != null){
                if (mapPropertyUnit.containsKey(String.valueOf(i.get('id')))){
                    Property_Unit__c propertyUnitMatch = mapPropertyUnit.get(String.valueOf(i.get('id')));
                    if (i.get('property_access_notes') != null){
                        propertyUnitMatch.Property_Access_Notes__c = String.valueOf(i.get('property_access_notes'));
                    }
                    if (i.get('property_access_method_type') != null){
                        propertyUnitMatch.Property_Access_Method_Type__c = String.valueOf(i.get('property_access_method_type'));
                    }
                    if (i.get('occupancy') != null){
                        propertyUnitMatch.Occupancy_Status__c = String.valueOf(i.get('occupancy'));
                    }
                    lstUpdatePropertyUnit.add(propertyUnitMatch);
                }

            }


        }
        return lstUpdatePropertyUnit;
    }

    Public static List<Transaction_Settlement__c> transactionSettlementRequest(decimal emdAmount, decimal optionFeeAmount, Transaction_Update__e transactionUpdateEvent, Map<String, Map<String, Transaction_Settlement__c>> mapTransactionSettlement, Map<String, Transaction__c> transactionMap){
        //Deserialize Inspection JSON
        List<Transaction_Settlement__c> lstUpdateTransactionSettlement = new List<Transaction_Settlement__c>();
        Map<String, Transaction_Settlement__c> mapts = mapTransactionSettlement.get(transactionUpdateEvent.Transaction_Id__c);
        System.debug('-mapts-' + mapts);
        if (emdAmount != null){
            if (mapts != null){
                if (mapts.get('Earnest Money Deposit') != null){
                    Transaction_Settlement__c tse = mapts.get('Earnest Money Deposit');
                    tse.Description__c = 'Earnest Money Deposit';
                    tse.Unit_Price__c = emdAmount;
                    tse.Unique_Id__c = transactionUpdateEvent.Transaction_Id__c + 'Earnest Money Deposit';
                    lstUpdateTransactionSettlement.add(tse);
                } else{
                    Transaction_Settlement__c tse = new Transaction_Settlement__c();
                    tse.Unit_Price__c = emdAmount;
                    tse.Unique_Id__c = transactionUpdateEvent.Transaction_Id__c + 'Earnest Money Deposit';
                    tse.Transaction__c = transactionMap.get(transactionUpdateEvent.Transaction_Id__c).Id;
                    tse.Description__c = 'Earnest Money Deposit';
                    lstUpdateTransactionSettlement.add(tse);

                }
            }

        }
        if (optionFeeAmount != null){
            if (mapts != null){
                Transaction_Settlement__c tso = mapts.get('Option Fee');
                tso.Unit_Price__c = optionFeeAmount;
                tso.Unique_Id__c = transactionUpdateEvent.Transaction_Id__c + 'Option Fee';
                tso.Description__c = 'Option Fee';
                lstUpdateTransactionSettlement.add(tso);
            } else{
                Transaction_Settlement__c tso = new Transaction_Settlement__c();
                tso.Unit_Price__c = optionFeeAmount;
                tso.Unique_Id__c = transactionUpdateEvent.Transaction_Id__c + 'Option Fee';
                tso.Transaction__c = transactionMap.get(transactionUpdateEvent.Transaction_Id__c).Id;
                tso.Description__c = 'Option Fee';
                lstUpdateTransactionSettlement.add(tso);
            }
        }

        return lstUpdateTransactionSettlement;
    }

    public static void updateTransactionContact(Map<String, String> bpmContactMap, Map<String, Transaction__c> transactionMap, Map<String, Map<String, Transaction_Contact__c>> mapTransIdTransContactsMatch, Map<String, Map<String, TransactionPlatformEventWrapper.TransactionContact>> mapTransIdTransContactsReq){
        System.debug('-mapTransIdTransContactsReq-' + mapTransIdTransContactsReq);
        System.debug('-mapTransIdTransContactsMatch-' + mapTransIdTransContactsMatch);//emailContactMap
        System.debug('-bpmContactMap-' + bpmContactMap);
        List<Transaction_Contact__c> lstUpdateTransactionContact = new List<Transaction_Contact__c>();
        List<Transaction_Contact__c> lstInsertTransactionContact = new List<Transaction_Contact__c>();
        for (String transId : mapTransIdTransContactsReq.keySet()){
            Map<String, TransactionPlatformEventWrapper.TransactionContact> mapTypeTransactionConReq = mapTransIdTransContactsReq.get(transId);
            System.debug('-mapTypeTransactionConReq-' + mapTypeTransactionConReq);

            for (String type : mapTypeTransactionConReq.keySet()){
                if (mapTransIdTransContactsMatch.get(transId) != null){
                    System.debug('-matchContact-' + mapTransIdTransContactsMatch);
                    System.debug('-transId-' + transId);
                    System.debug('-type-' + type);
                    if (mapTransIdTransContactsMatch.get(transId).containsKey(type) ){
                        System.debug('-matchContact-' + mapTransIdTransContactsMatch.get(transId).get(type) .Contact__c);
                        System.debug('-reqContact-' + bpmContactMap.get(mapTransIdTransContactsReq.get(transId).get(type) .bpmContactId));
                        System.debug('-bpmContactMap-' + bpmContactMap);
                        System.debug('-mapTransIdTransContactsReq-' + mapTransIdTransContactsReq);
                        if (mapTransIdTransContactsMatch.get(transId).get(type) .Contact__c != bpmContactMap.get(mapTransIdTransContactsReq.get(transId).get(type) .bpmContactId)){
                            Transaction_Contact__c tcUpdate = new Transaction_Contact__c();
                            tcUpdate.Id = mapTransIdTransContactsMatch.get(transId).get(type) .Id;
                            tcUpdate.Contact__c = bpmContactMap.get(mapTransIdTransContactsReq.get(transId).get(type) .bpmContactId);
                            lstUpdateTransactionContact.add(tcUpdate);
                        }
                    } else{
                        Transaction_Contact__c tc = new Transaction_Contact__c();
                        tc.Transaction__c = transactionMap.get(transId).Id;
                        tc.Contact__c = bpmContactMap.get(mapTransIdTransContactsReq.get(transId).get(type) .bpmContactId);
                        if (mapTransIdTransContactsReq.get(transId).get(type) .type != null){
                            tc.Contact_Type__c = mapTransIdTransContactsReq.get(transId).get(type) .type;
                        }
                        if (mapTransIdTransContactsReq.get(transId).get(type) .contactNumber != null){
                            tc.Contact_Count__c = Integer.valueOf(mapTransIdTransContactsReq.get(transId).get(type) .contactNumber);
                        }
                        tc.Transaction_Id__c = transId;
                        tc.Unique_Id__c = transactionMap.get(transId).Id + bpmContactMap.get(mapTransIdTransContactsReq.get(transId).get(type) .bpmContactId) + tc.Contact_Type__c + tc.Contact_Count__c;
                        lstInsertTransactionContact.add(tc);
                    }
                } else{
                    System.debug('-bpmContactMap-' + bpmContactMap);
                    System.debug('-mapTransIdTransContactsReq-' + mapTransIdTransContactsReq);
                    Transaction_Contact__c tc = new Transaction_Contact__c();
                    tc.Transaction__c = transactionMap.get(transId).Id;
                    System.debug('-mapTransIdTransContactsReq-' + mapTransIdTransContactsReq);
                    System.debug('-con-' + mapTransIdTransContactsReq.get(transId).get(type) .bpmContactId);
                    tc.Contact__c = bpmContactMap.get(mapTransIdTransContactsReq.get(transId).get(type) .bpmContactId);
                    if (mapTransIdTransContactsReq.get(transId).get(type) .type != null){
                        tc.Contact_Type__c = mapTransIdTransContactsReq.get(transId).get(type) .type;
                    }
                    if (mapTransIdTransContactsReq.get(transId).get(type) .contactNumber != null){
                        tc.Contact_Count__c = Integer.valueOf(mapTransIdTransContactsReq.get(transId).get(type) .contactNumber);
                    }
                    tc.Transaction_Id__c = transId;
                    tc.Unique_Id__c = transactionMap.get(transId).Id + bpmContactMap.get(mapTransIdTransContactsReq.get(transId).get(type) .bpmContactId) + tc.Contact_Type__c + tc.Contact_Count__c;
                    lstInsertTransactionContact.add(tc);
                }
            }

        }

        if (!lstUpdateTransactionContact.isEmpty()){
            update lstUpdateTransactionContact;
        }
        if (!lstInsertTransactionContact.isEmpty()){
            insert lstInsertTransactionContact;
        }
    }

}
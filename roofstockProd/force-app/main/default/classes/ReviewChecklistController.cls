public class ReviewChecklistController{
    @AuraEnabled
    public static void upsertTransactionSnapshot(ContractQCController.ReviewWrapper reviewWrapper, String txnRecordId, Boolean updateSendEmail){
        try{
            if (null != reviewWrapper){

                String checklistEmailBody = 'After my review of the contract, the following items are either missing or there is a discrepancy between the information you provided and our audited information.';

                Transaction__c transactionObj = [SELECT Roofstock_TC_User__c, Transaction_Id__c, Origination_Source__c
                                                 FROM Transaction__c
                                                 WHERE id = :txnRecordId
                                                 LIMIT 1];

                User txnCoordinator = getUser(transactionObj.Roofstock_TC_User__c);
                String userName;
                string userEmail;
                if (null != txnCoordinator){
                    userName = txnCoordinator.Name;
                    userEmail = txnCoordinator.email;
                }

                //Upsert documents
                boolean sendChecklistEmail = false;
                checklistEmailBody = checklistEmailBody + '<h4>Missing Documents:<h4><table><tr><th style="width:200px; border: 1px solid black;"></th><th style="width:200px; border: 1px solid black;">Audited Info</th></tr>';
                for (Transaction_Snapshot__c document : reviewWrapper.lstDocuments){
                    if (String.isBlank(document.Id)){
                        // Document doesnt exist & is updated by TC
                        // if (String.isBlank(document.Original_Broker_Entry__c) && String.isNotBlank(document.TC_Updates__c)){
                        System.debug('Document doesnt exist & is updated by TC so inserting');
                        document.Transaction__c = txnRecordId;
                        document.Help_Text__c = '';
                        insert document;
                        // }
                    } else{
                        System.debug('Document object to update : ' + document);
                        document.Help_Text__c = '';
                        update document;
                    }
                    if (!document.Verify__c || null == document.Verify__c){
                        sendChecklistEmail = true;
                        checklistEmailBody = checklistEmailBody + '<tr><td style="width:200px; border: 1px solid black;">' + document.Review_Checklist_Type__c + '</td>';
                        if (null == document.TC_Updates__c){
                            document.TC_Updates__c = '';
                        }
                        checklistEmailBody = checklistEmailBody + '<td style="width:200px; border: 1px solid black;">' + document.TC_Updates__c + '</td></tr>';
                    }
                }
                checklistEmailBody = checklistEmailBody + '</table><h4>Information with discrepancies:</h4><table><tr><th style="width:200px; border: 1px solid black;"></th><th style="width:200px; border: 1px solid black;">Original Entry</th><th style="width:200px; border: 1px solid black;">Audited Info</th></tr>';

                //Upsert Transaction Snapshots

                for (Transaction_Snapshot__c txnSnapshot : reviewWrapper.lstReviewChecklist){

                    if (String.isBlank(txnSnapshot.Id)){
                        txnSnapshot.Transaction__c = txnRecordId;
                        insert txnSnapshot;
                    } else{
                        System.debug('Review checklist object to update : ' + txnSnapshot);
                        update txnSnapshot;
                    }

                    if (!txnSnapshot.Verify__c || null == txnSnapshot.Verify__c){
                        sendChecklistEmail = true;
                        checklistEmailBody = checklistEmailBody + '<tr><td style="width:200px; border: 1px solid black;">' + txnSnapshot.Review_Checklist_Type__c + '</td>';

                        if (null == txnSnapshot.Original_Broker_Entry__c){
                            txnSnapshot.Original_Broker_Entry__c = '';
                        }
                        checklistEmailBody = checklistEmailBody + '<td style="width:200px; border: 1px solid black;">' + txnSnapshot.Original_Broker_Entry__c + '</td>';

                        if (null == txnSnapshot.TC_Updates__c){
                            txnSnapshot.TC_Updates__c = '';
                        }
                        checklistEmailBody = checklistEmailBody + '<td style="width:200px; border: 1px solid black;">' + txnSnapshot.TC_Updates__c + '</td></tr>';
                    }

                }
                checklistEmailBody = checklistEmailBody + '</table><br/>Please provide all missing documents as soon as possible. For all discrepancies, the value verified by the TC will override the value you provided unless you provide additional details. Please reply to this email with documents and/or information on discrepancies.<br/><br/>Thank you,<br/>';

                checklistEmailBody = checklistEmailBody + userName;
                checklistEmailBody = checklistEmailBody + '<br/>Transaction Coordinator';

                // Email only when 'Update & Send Email' button is clicked in the UI & any pending documents/checklists to be verified
                if (sendChecklistEmail && updateSendEmail){
                    upsertReviewChecklistEmail(txnRecordId, checklistEmailBody, transactionObj, userEmail);
                }
            }
        } catch (DmlException exp){
            System.debug('Error inserting/updating transaction contact object for txn : ' + txnRecordId);
            throw new AuraHandledException('Error updating the transaction snapshot!');
        }
    }

    public static Transaction_Contact__c getTransactionContact(String txnRecordId, String contactType){
        List<Transaction_Contact__c> transactionContactList = null;
        Transaction_Contact__c transactionContactOjb = new Transaction_Contact__c();

        // Order by Contact_Count_c & take first record
        try{
            transactionContactList = [SELECT Contact__c, Id, Contact_Type__c
                                      FROM Transaction_Contact__c
                                      WHERE Transaction__c = :txnRecordId AND Contact_Type__c = :contactType
                                      ORDER BY CreatedDate DESC
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

    public static Contact getContact(String recordId){
        Contact contact = new Contact();

        if (null != recordId){
            try{
                contact = [SELECT Id, AccountId, Name, Account_Asher_Formula__c, Phone, Email
                           FROM Contact
                           WHERE Id = :recordId
                           LIMIT 1];
            } catch (QueryException exp){
                System.debug('No contact found with Id :' + recordId);
            }
        }
        return contact;
    }

    private static void upsertReviewChecklistEmail(String recordId, String emailBody, Transaction__c transactionObj, String userEmail){
        try{

            Review_Checklist__c reviewChecklist = null;
            try{
                reviewChecklist = [SELECT Id, Transaction_Id__c, Transaction__c, Broker_Email__c, Email_Body__c, Send_Email__c, Create_task__c, TC_User_Email__c
                                   FROM Review_Checklist__c
                                   WHERE Transaction__c = :recordId];
            } catch (QueryException exp){
                System.debug('Review checklist not present transaction :' + recordId);
            }

            if (null == reviewChecklist){
                reviewChecklist = new Review_Checklist__c();
                reviewChecklist.Transaction__c = recordId;
                reviewChecklist.Transaction_Id__c = transactionObj.Transaction_Id__c;
            }

            if (transactionObj.Origination_Source__c.startsWith('Off Market - Internal')){
                reviewChecklist.Send_Email__c = true;
                reviewChecklist.Broker_Email__c = System.label.Off_Market_Internal_broker_to_email;//'anj.murphy@roofstock.com';
            } else{
                if (transactionObj.Origination_Source__c.startsWith('Off Market')){
                    reviewChecklist.Send_Email__c = false;
                    reviewChecklist.Broker_Email__c = 'a@b.com';
                } else{
                    Transaction_Contact__c brokerBuyer = getTransactionContact(recordId, 'Broker Buyer');
                    Contact brokerBuyerContact = getContact(brokerBuyer.Contact__c);
                    reviewChecklist.Send_Email__c = true;
                    reviewChecklist.Broker_Email__c = brokerBuyerContact.Email;
                }
            }
            reviewChecklist.Create_task__c = true;
            reviewChecklist.Email_Body__c = emailBody;
            reviewChecklist.TC_User_Email__c = userEmail;

            upsert reviewChecklist;
        } catch (Exception e){
            System.debug('Error saving review checklist :' + e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static User getUser(String recordId){
        User user = new User();

        if (null != recordId){
            try{
                user = [SELECT Id, Name, email
                        FROM User
                        WHERE Id = :recordId
                        LIMIT 1];
            } catch (QueryException exp){
                System.debug('No user found with Id :' + recordId);
            }
        }
        return user;
    }

}
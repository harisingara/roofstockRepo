public with sharing class TransactionDetails{
    @AuraEnabled
    public static List<String> getMilestonePicklistValues(){
        List<String> picklistvalues = new List<String>();
        Schema.DescribeFieldResult objFieldDescribe = Transaction__c.Milestone__c.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues){
            System.debug('Value = ' + objPickList.getValue() + ' , Label = ' + objPickList.getLabel());
            picklistvalues.add(objPickList.getValue());
        }
        return picklistvalues;
    }

    @AuraEnabled
    public static List<String> getFieldSetFieldsByFieldSetName(String objectApiName, String fieldSetName){
        List<Schema.FieldSetMember> fieldSetMembers = ((SObject) Type.forName(objectApiName).newInstance()).getSObjectType().getDescribe().FieldSets.getMap().get(fieldSetName).getFields();

        List<String> fields = new List<String>();
        for (Schema.FieldSetMember fieldSetMember : fieldSetMembers){
            fields.add(fieldSetMember.fieldPath);
        }
        return fields;
    }

    @AuraEnabled
    public static List<Transaction__c> getRequiredValues(String recordId){
        return [SELECT Milestone__c, Transaction_Type__c, Id, (SELECT Id
                                                               FROM Inspections__r), (SELECT Id
                                                                                      FROM Transaction_Settlements__r)
                FROM Transaction__c
                where id = :recordId
                limit 1];
    }

    @AuraEnabled
    public static List<Property2__c> getPropertyDetails(String recordId){
        return [SELECT Street_Address__c, City__c, State__c, Zip__c, Bedrooms_SUM__c, Bathrooms_SUM__c, Square_Feet__c, BPM_Buyer__c, Offer_Price__c, Property_Type__c, Seller_Entity__c, Seller_Provided_List_Price__c, Seller_Agent__c, BPM_Source__c, HOA__c, APN__c, Legal_Description__c, County__c, Id, Name, (SELECT Bathrooms__c, Bedrooms__c, CreatedById, CreatedDate, Id, Inspected_Bathrooms__c, Inspected_Bedrooms__c, LastModifiedById, Lease_End__c, Lease_Start__c, Monthly_Rent__c, Move_Out_Date__c, Name, Occupancy_at_Closing__c, Square_Feet__c, Property__c
                                                                                                                                                                                                                                                                                                                     FROM Property_Units__r)
                FROM Property2__c
                where id = :[
                SELECT Buyer_Property_Instance__c
                FROM Transaction__c
                where id = :recordId and Transaction_Type__c = 'Acquisition Buy'].Buyer_Property_Instance__c
                limit 1];
    }

    //API call
    @AuraEnabled
    public static list<FileWrapper> senddata(String recordId, String type){
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        Transaction__c transactionObj = [SELECT Id, Transaction_Id__c
                                         from Transaction__c
                                         where Id = :recordId
                                         LIMIT 1];
        recordId = transactionObj.Transaction_Id__c;

        String url = 'callout:BPMRESOURCE/resource?entityType=transaction&entityId=' + recordId + '&types=' + type;
        request.setEndpoint(url) ;
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Api-Key', '{!$Credential.Password}');

        HttpResponse response = http.send(request);
        String responseBody;
        List<FileWrapper> fileList = new List<FileWrapper>();
        if (response.getStatusCode() == 200){
            responseBody = response.getBody();
            FileWrapper files = (FileWrapper) System.JSON.deserialize(responseBody, FileWrapper.class);
            fileList.add(files);
        } else{
            System.debug('Error retrieving files from BPM for Transaction Id : ' + recordId);
        }

        return fileList;
    }

    @AuraEnabled
    public static void saveTask(String recordId){

        // Complete QC Audit Task
        String qcTaskType = System.label.Task_Type_QC;
        Task qcTaskRecord = [SELECT Id, Status
                             from TASK
                             WHERE Type = :qcTaskType AND WhatId = :recordId
                             LIMIT 1];
        qcTaskRecord.Status = 'Completed';
        update qcTaskRecord;

        // Complete Review Checklist Task
        String rcTaskType = System.label.Task_Type_QC_Review_Checklist;
        for (Task reviewTaskRecord : [SELECT Id, Status
                                      from TASK
                                      WHERE Type = :rcTaskType AND WhatId = :recordId]){
            reviewTaskRecord.Status = 'Completed';
            update reviewTaskRecord;
        }

        //Set Send_Email__c to false on review_checklist__c
        try{
            Review_Checklist__c reviewChecklist = [SELECT Id, Send_Email__c
                                                   from Review_Checklist__c
                                                   WHERE Transaction__c = :recordId];
            if (null != reviewChecklist){
                reviewChecklist.Send_Email__c = false;
                update reviewChecklist;
            }
        } catch (QueryException exp){
            System.debug('Review checklist not present for transaction :' + recordId);
        }

        //All items in transactionsnapshot should be marked as verified
        try{
            List<Transaction_Snapshot__c> transactionSnapshotList = [SELECT Id, Verify__c
                                                                     FROM Transaction_Snapshot__c
                                                                     WHERE Transaction__c = :recordId];
            for (Transaction_Snapshot__c rc : transactionSnapshotList){
                rc.Verify__c = true;
            }
            update transactionSnapshotList;
        } catch (QueryException exp){
            System.debug('No transaction snapshots found for transaction :' + recordId);
        }

        updateMilestone(recordId);
    }

    @AuraEnabled
    public static String getContactName(String contactId){
        String contactName = '';
        List<Contact> conList = [SELECT Id, Name
                                 FROM Contact
                                 WHERE Id = :contactId];
        if (conList != null && conList.size() > 0){
            contactName = conList[0].Name;
        }
        return contactName;
    }

    /**
     * Update to next milestone, if task for each stage under the current milestone are completed
     */
    public static void updateMilestone(String txnRecordId){

        // Transaction__c currentMilestone = [SELECT Milestone__c
        //                            FROM Transaction__c
        //                            WHERE id = :txnRecordId
        //                            LIMIT 1];

        String[] currentMilestoneStages = new String[]{ 'Submit EMD', 'QC: Contract Audit' }; // Get from metadata

        // Check for any open tasks for each stage under the milestone
        List<Task> openTasks = [SELECT Id, Status
                                from TASK
                                WHERE Type IN:currentMilestoneStages AND WhatId = :txnRecordId AND Status != 'Completed'];
        if (openTasks == null){
            Transaction__c txnRecord = new Transaction__c(Id = txnRecordId, Milestone__c = 'Diligence');
            update txnRecord;
        }
    }

}
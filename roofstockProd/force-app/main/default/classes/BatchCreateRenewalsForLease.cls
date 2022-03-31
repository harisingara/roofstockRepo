public class BatchCreateRenewalsForLease implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    public List<Lease__c> start(Database.BatchableContext BC) {

        List<Lease__c> lsList = [SELECT Id, Lease_Id__c, Property_Unit__r.HomeCode__c, Status__c, Lease_Start_Date__c, Lease_End_Date__c, 
                                        Property_Unit__r.Name, Property_Unit__r.Id, Property_Unit__r.Property__c, APPR_Status__c, isM2M__c,
                                        ( SELECT Id,Lease__c,Tenent_Id__c,First_Name__c,Last_Name__c,Status__c 
                                            FROM Tenant1__r 
                                           WHERE Tenant_Type__c = 'Primary' ) 
                                   FROM Lease__c 
                                  WHERE Lease_Start_Date__c <= TODAY
                                    AND Lease_End_Date__c >= TODAY
                                    AND Renewal_opportunity__c = NULL
                                    AND Property_unit__r.property__r.property_management_company__c = 'Streetlane Property Management'
                                    AND Property_unit__r.Occupancy_Status__c <> 'Down'
                                    AND Property_unit__r.Tenant_Status__c <> 'Future'];
        system.debug('Batch Query Count : ' + lsList.size());
        return lsList; 

    }

    public void execute(Database.BatchableContext BC, List<Lease__c> leaseList) {

        try {
            List<Opportunity> renewalOpptyInsert = new List<Opportunity>();
            List<Job__c> turnInsert = new List<Job__c>();
            Map<Id, Lease__c> updateLeasemMap = new Map<Id, Lease__c>();
            Lease__c tempLease;

            Id renewalOpptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                                                                        .get('Renewal')
                                                                        .getRecordTypeId();

            /*Id jobTurnRecordTypeId = Schema.SObjectType.Job__c.getRecordTypeInfosByDeveloperName()
                                                                        .get('Turn')
                                                                        .getRecordTypeId();*/

            // prepare Create renewal opptys and Job Turn for Lease
            for (Lease__c lease : leaseList) {
                //if (lease.Renewal_opportunity__c == null) {
                renewalOpptyInsert.add(BatchCreateRenewalsForLeaseHelper.createRenewalOpp(lease, renewalOpptyRecordTypeId));
                //}
            }

            if (null <> renewalOpptyInsert && renewalOpptyInsert.size() > 0) {
                // Insert renewal Opptys for Lease
                Database.SaveResult[] saveResultList = DataBase.Insert(renewalOpptyInsert, false);
                DebugLogHandler.logSaveResult('BatchCreateRenewalsForLease', 'InsertOpp', saveResultList);

                // Prepare Update Renewal Oppty link in Lease
                for (Opportunity opp : renewalOpptyInsert) {
                    if (opp.Id <> null && opp.Related_Lease__c <> null) {
                        updateLeasemMap.put(opp.Related_Lease__c, new Lease__c(Id=opp.Related_Lease__c, Renewal_Opportunity__c = opp.Id));
                    }
                }
            }

            /*if (System.Label.RunJobTurnBatch == 'Yes') {
                
                List<Lease__c> jobTurnLease = BatchCreateRenewalsForLeaseHelper.getLeaseForJobCreation(leaseList);

                for (Lease__c lease : jobTurnLease) {
                    turnInsert.add(BatchCreateRenewalsForLeaseHelper.createJobTurn(lease, jobTurnRecordTypeId));
                }

                if (null <> turnInsert && turnInsert.size() > 0) {
                    // Insert Job Turn for Lease
                    Database.SaveResult[] saveResultList1 = DataBase.Insert(turnInsert, false);
                    DebugLogHandler.logSaveResult('BatchCreateRenewalsForLease', 'InsertJobTurn', saveResultList1);

                    // Prepare Update Job Turn link in Lease
                    for (Job__c jobTurn : turnInsert) {
                        if (jobTurn.Id <> null && jobTurn.Related_Lease__c <> null) {
                            tempLease = new Lease__c();
                            tempLease.Id = jobTurn.Related_Lease__c;
                            if (updateLeasemMap.ContainsKey(jobTurn.Related_Lease__c)) {
                                tempLease = updateLeasemMap.get(jobTurn.Related_Lease__c);
                            }
                            tempLease.Turn__c = jobTurn.Id;
                            updateLeasemMap.put(jobTurn.Related_Lease__c, tempLease);
                        }
                    }
                }

            }*/

            // Update Lease
            if (null <> updateLeasemMap && updateLeasemMap.size() > 0) {
                Database.SaveResult[] saveResultList1 = DataBase.Update(updateLeasemMap.values(), false);
                DebugLogHandler.logSaveResult('BatchCreateRenewalsForLease', 'UpdateLease', saveResultList1);
            }
        }
        Catch(Exception e) {
            system.debug('Exception Catch Block : ' + e.getMessage());
            DebugLogHandler.logAppException('BatchCreateRenewalsForLease', 'execute', e.getMessage(), e.getStackTraceString(), 'Batch');
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('BatchCreateRenewalsForLease Successfully Completed');
    }

}
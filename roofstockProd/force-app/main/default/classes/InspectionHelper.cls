public class InspectionHelper {
    
    public class TriggerDispatcherException extends Exception{
    }
    public static void inspectionCount(List<Inspection__c> inspectionList){
        Set<String> jobIdSet = new Set<String>();
        for(Inspection__c dil : inspectionList){
            if(dil.Job__c <> null)
                jobIdSet.add(dil.Job__c);
        }
        if(!jobIdSet.IsEmpty()){
            List<Job__c> jobList = [select Id,Diligence_Count__c,(select Id from diligence__r) from Job__c where Id IN:jobIdSet];
            List<Job__c> updateJobList = new List<Job__c>();
            for(Job__c job :jobList){
                job.Diligence_Count__c = job.diligence__r.size();
                updateJobList.add(job);
            }
            if(updateJobList.size()>0){
                update updateJobList;
            }
        }
    }
    public static void oneToOneMapping(List<Inspection__c> inspectionList){
        Set<String> jobIdSet = new Set<String>();
        for(Inspection__c dil : inspectionList){
            if(dil.Job__c<>null)
                jobIdSet.add(dil.Job__c);
        }
        System.debug('-jobIdSet-'+jobIdSet);
        if(!jobIdSet.IsEmpty()){
            List<Inspection__c> dilList = [select Id,Job__c, Job__r.Diligence_Count__c from Inspection__c where Job__c IN:jobIdSet];
            System.debug('-dilList-'+dilList);    
            Map<String,decimal> dilCountMap = new Map<String,decimal>();
            for(Inspection__c dil : dilList){
                dilCountMap.put(dil.Job__c,dil.Job__r.Diligence_Count__c);
            } 
            System.debug('-dilCountMap-'+dilCountMap);
            for(Inspection__c dil :inspectionList){
                decimal count = dilCountMap.get(dil.Job__c);
                System.debug('-'+count);
                if(count>=1){
                    System.debug('inside');
                    dil.addError('Only One Inspection Record can be associated with Job');    
                }
                
                
            }
        }    
    }

    @AuraEnabled
    public static  Inspection__c  inspection(String recordId){
        Inspection__c dil = [select Id, Property_Unit__c,Property_Unit__r.Name, property__c from Inspection__c where Id =:recordId];
        return dil;
    }

    @AuraEnabled
    public static Inspection__c associatedInspection(String recordId){

        Id recID = recordId;  
        String sObjName = recID.getSObjectType().getDescribe().getName();  
        system.debug('Object Name is ' + sObjName);
        String query = 'SELECT Id,Inspection_Status__c,Rehab_Inspector__c,Rehab_Inspector__r.Name,Inspection_Completed_Date__c,'+
            'Inspection_Scheduled_Date__c,Access_Notes__c,Plumbing_Inspector__r.Name,Estimated_Rent_UW__c,HVAC_Inspector__r.Name,'+
            'Roofing_Inspector__r.Name,Foundation_Inspector__r.Name,Pool_Inspector__r.Name,Due_Diligence_Notes__c,'+
            'Estimated_Foundation_Cost__c,Estimated_Gc_Cost__c,Estimated_HVAC_Cost__c,Estimated_Plumbing_Cost__c,Estimated_Pool_Cost__c,Estimated_Roofing_Cost__c,Projected_Capex__c,Total_Estimated_Renovation_Cost__c,'+
            'BPM_Property_URL__c,BPM_Status__c, Estimated_Capex_Manual__c,Tax_ID__c,CMA_Rent__c,Rental_Comparable__c,BPM_Source__c,BPM_Buyer__c,Occupancy_at_Closing__c,UW_Rehab_Cost_Close__c,UW_Rehab_Cost_Offer__c from Inspection__c where'+' '+
            sObjName+'=\''+recordId+'\'' ;
        
        System.debug('=query='+query);
        
        Inspection__c[] inspectionList = Database.query(query);
        
        if(!inspectionList.isEmpty()){
            return inspectionList[0];
        }
        else{
            return null;
        } 
    }

    @AuraEnabled
    public static boolean associatedInspectionToJob(String delRecordId,String jobRecordId){
        Inspection__c del = [select Id,Job__c from Inspection__c where Id=:delRecordId];
        del.Job__c = jobRecordId;
        update del;
        return true;
    }

    @AuraEnabled
    public static Transaction__c associatedTransactionToInspection(String recordId){
        Transaction__c tran;
        //Id insId = [select Property_unit__r.Property__c from Inspection__c where Id=:recordId];
        Inspection__c ins = [select Property_unit__c, Property_unit__r.Property__c from Inspection__c where Id=:recordId];
        if (ins.Property_unit__c <> null && ins.Property_unit__r.Property__c <> null) {
            for (Transaction__C bt : [SELECT Id, Close_Date__c, Cancellation_date__c, Date_Contingencies_Lift__c, 
                           Est_Close_Date__c, IC_Expiration_Date__c, In_Contract_Date__c, Buyer_Property_Instance__r.Purchase_Date__c,
                           Buyer_Property_Instance__r.name, Buyer_Property_Instance__r.Market__C 
                      FROM Transaction__C 
                     WHERE Buyer_Property_Instance__c=:ins.Property_unit__r.Property__c
                  ORDER BY createddate desc 
                     LIMIT 1]) {
                        tran = bt;
            }
            if (tran == null) {
                tran = [SELECT Id, Close_Date__c, Cancellation_date__c, Date_Contingencies_Lift__c, 
                           Est_Close_Date__c, IC_Expiration_Date__c, In_Contract_Date__c, Buyer_Property_Instance__r.Purchase_Date__c,
                           Buyer_Property_Instance__r.name, Buyer_Property_Instance__r.Market__C 
                      FROM Transaction__C 
                     WHERE Property_Instance__c=:ins.Property_unit__r.Property__c
                  ORDER BY createddate desc 
                     LIMIT 1];
            }
        }
        return tran;
    }

    public static void sendStatusUpdateToBpm(Map<Id, Inspection__c> oldMap, Map<Id, Inspection__c> newMap) {
        Set<Id> insIdsToProcess = new Set<Id>();
        for (Inspection__C ins : newMap.values()) {
            if (ins.Inspection_Status__c <> null && ins.Source__c == 'Bpm'  && ins.Dilligence_Id__c <> null && ins.Dilligence_Id__c <> '' && 
               (ins.Inspection_Status__c.contains('Completed') || ins.Inspection_Status__c.contains('Cancelled')) && 
               (ins.Inspection_Status__c <> oldMap.get(ins.Id).Inspection_Status__c || 
                ins.Total_Estimated_Renovation_Cost__c <> oldMap.get(ins.Id).Total_Estimated_Renovation_Cost__c
               )
            )  {
                insIdsToProcess.add(ins.Id);
            }
        }
        if (insIdsToProcess.size() > 0) {
            InspectionUpdateToBMPCallout.updateBMPCallout(insIdsToProcess);
        }
    }
}
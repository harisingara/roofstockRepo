public class JobHelper {
    
    static ID turnRecordtypeId  = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Turn').getRecordTypeId();
    //[KM] - 12/21/2021 - Commented for job turn logic for PMC2022-100
    /*public static void updatePriorMoveInDate(List<Job__c> updatedTurns){
        map<Id,Date> mapPropertyTurn = new map<Id,Date>();
        Set<Id> setUnitIds = new Set<Id>(); 
        for(Job__c oTurn:updatedTurns){
            if(oTurn.Property_Unit__c <> null && oTurn.RecordTypeId == turnRecordtypeId)
                setUnitIds.add(oTurn.Property_Unit__c) ;    
        }
        if(!setUnitIds.IsEmpty()){
            map<Id,Property_Unit__c> mapProperty = new map<Id,Property_Unit__c>([Select Id,Move_In_Date__c from Property_Unit__c where ID IN: setUnitIds AND Move_In_Date__c != null]); 
            for(Job__c oTurn:updatedTurns){
                if(oTurn.Property_Unit__c <> null && mapProperty.containsKey(oTurn.Property_Unit__c))
                    oTurn.Prior_Move_In_Date__c = mapProperty.get(oTurn.Property_Unit__c).Move_In_Date__c;      
            }
        }
    }
    public static void updateLeasingAvailability(List<Job__c> updatedTurns){
        map<Id,Leasing_Availability__c> mapUpdateLeasingAvail = new map<Id,Leasing_Availability__c>();
        for(Job__c updatedTurn : updatedTurns){
            if(updatedTurn.Property_Unit__c!=null && updatedTurn.RecordTypeId == turnRecordtypeId){
                mapUpdateLeasingAvail.put(updatedTurn.Property_Unit__c, 
                                          new Leasing_Availability__c(Vacate_Date__c = updatedTurn.Move_Out_Date__c, Ready_Date__c = updatedTurn.Yardi_Ready_Date__c)); 
                
                
            }
        }
        if(!mapUpdateLeasingAvail.IsEmpty()){
            List<Leasing_Availability__c> lstUpdateLeasing = [ Select Property_Unit__c, Vacate_Date__c , ID , Ready_Date__c 
                                                              from Leasing_Availability__c where Property_Unit__c IN:mapUpdateLeasingAvail.keyset()];     
            for(Leasing_Availability__c oLeasingAvail:lstUpdateLeasing){
                oLeasingAvail.Vacate_Date__c = mapUpdateLeasingAvail.get(oLeasingAvail.Property_Unit__c).Vacate_Date__c;
                oLeasingAvail.Ready_Date__c = mapUpdateLeasingAvail.get(oLeasingAvail.Property_Unit__c).Ready_Date__c;
            }
            update lstUpdateLeasing;
        }
        
    }*/
    
    public static void copyNotesAndAttachments(List<Job__c> newJob) {
        List<Id> jobId =  new List<Id>();
        for(Job__c Job : newJob) {
            jobId.add(Job.Id);
        }
        copyAttachmentsToJob(jobId);
    }

    @Future
    public static void copyAttachmentsToJob(List<Id> jobId) {

        Map<Id,Id> mapInspectionJob = new Map<Id,Id>();
        List<ContentDocumentLink> listCdl =  new List<ContentDocumentLink>();
        try{
            List<Inspection__c> inspList = [SELECT Id, Job__c FROM Inspection__c WHERE Job__c IN :jobId];
            for(Inspection__C ins : inspList) {
                mapInspectionJob.put(ins.Id, ins.Job__c);
            }
            List<ContentDocumentLink> cdlist = [SELECT id,ContentDocumentId,LinkedEntityId 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId IN : mapInspectionJob.keySet()];
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
        } catch(Exception exe) {
            DebugLogHandler.logOutBoundException('JobHelper','copyAttachmentsToJob',exe.getStackTraceString(),exe.getMessage(),null,null,null);
        }
        
    }
    
    /*
    public static void updatePropertyUnitFields(List<Job__c> newJobList){
        List<String> propertyUnitIdSet = new List<String>();
        List<Property_Unit__c> punitUpdateList = new List<Property_Unit__c>();
        for(Job__c job : newJobList){
            if(job.Property_Unit__c!=null){
                propertyUnitIdSet.add(job.Property_Unit__c);
            }
        }
        if(!propertyUnitIdSet.isEmpty()){
            List<Property_Unit__c> punitList = [select Id,Oversight_Fee__c,(select Id,Oversight_Fee__c from Jobs__r) from Property_Unit__c where Id IN:propertyUnitIdSet];
            if(!punitList.isEmpty()){
                decimal oversightFee = 0;
                for(Property_Unit__c pu : punitList){
                    if(pu.Jobs__r.size()>0){
                        for(Job__c job : pu.Jobs__r){
                           // oversightFee = oversightFee + job.Oversight_Fee__c;
                        }
                        
                    }
                    pu.Oversight_Fee__c = oversightFee;
                    punitUpdateList.add(pu);
                    
                }
            }
            
        }
        if(punitUpdateList.size()>0){
            //update punitUpdateList;
        }
        
    }
    */
    
    public static void updatePropertyBPOTriggerDate(Map<Id,Job__c> updatedJobs, Map<Id,Job__c> oldJobsMap) {
        
        Toggle_New_logic__c bypassnewLogic = [Select id,name,Enable_new_logic__c from Toggle_New_logic__c where name = 'BPO'];
        
        if (null <> bypassnewLogic && bypassnewLogic.Enable_new_logic__c == false) {
            return;
        } 
        else {
            Id renovationRecordTypeId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Renovation').getRecordTypeId();
            Set<Id> UpdatePropBPOTrigger = new Set<Id>();
            List<Property2__c> UpdatePropertyList = new List<Property2__c>();
            
            for(Job__c updatedjob : updatedJobs.values()) {
                if(updatedJob.RecordTypeId == renovationRecordTypeId && updatedjob.Property__c != null) {
                    UpdatePropBPOTrigger.add(updatedjob.Property__c);
                }
                
            }

            Map<ID,Property2__c> propertyMap = new Map<ID,Property2__c>([ SELECT Id,Name,BPO_Trigger_Date__c,Type_of_BPO_Trigger__c,
                                                                               		   Owner_Entity__r.name,Client__c 
                                                                               	 FROM  Property2__c 
                                                                                 WHERE Id IN: UpdatePropBPOTrigger]);     
               
            if(!propertyMap.isEmpty()) {
                for(Job__c updatedjob : updatedJobs.values()) {
                    if(updatedJob.RecordTypeId == renovationRecordTypeId && updatedjob.Property__c != null) {
                        Property2__c prop = propertyMap.get(updatedjob.Property__c);
                        if((updatedjob.Job_Status__c != oldJobsMap.get(updatedjob.id).Job_Status__c && updatedjob.Job_Status__c == 'Job Completed')) {
                            if(prop.Client__c != null && prop.Client__c.toUpperCase().equals(System.Label.BPO_Starwood_property.toUppercase())) {
                                prop.BPO_Trigger_Date__c = System.today();
                                prop.Type_of_BPO_Trigger__c = 'Renovation Job Completed';
                                UpdatePropertyList.add(prop);
                            }
                        }
                    }
                }
            }
            
            if(!UpdatePropertyList.IsEmpty()) {
                update UpdatePropertyList;
            }
        }
        
    }
    
    //[KM] This method populates Job Sequence based on record type.
    public static void updateJobSequence(List<Job__c> updatedTurns){
        Set<ID> pUnitIDSet = new Set<ID>();
        Map<Id,Decimal> existJobMap = new Map<ID,Decimal>();
        
        for(Job__c jt: updatedTurns){
            pUnitIDSet.add(jt.Property_Unit__c);
        }
        
        for (AggregateResult ar : [SELECT  Property_Unit__c pid, max(job_sequence__c) jbseq 
                                     FROM  Job__c 
                                     WHERE Property_Unit__c IN :pUnitIDSet AND
                                   		   Recordtypeid = :turnRecordtypeId AND
                                   		   Job_Sequence__c <> null
                                    GROUP BY property_unit__c]) {
            existJobMap.put((ID)ar.get('pid'),(decimal)ar.get('jbseq'));
        }
        
        for(Job__c jb: updatedTurns){
            if(jb.recordtypeid == turnRecordtypeId) {
                jb.Job_Sequence__c = (existJobMap.containsKey(jb.Property_Unit__c)) ? existJobMap.get(jb.Property_Unit__c) + 1 : 1;
            } 
            else {
                jb.Job_Sequence__c = 0;
            }
        }
        
    }
    
}
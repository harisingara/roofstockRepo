public class BatchMergeDuplicateContact implements Database.Batchable<sObject>, Database.Stateful{
    public Id customJobID ; 
    public Boolean customJobUpdated = false; 
    public List<Duplicate_Record_Group__c> start(Database.BatchableContext BC)
    {
        List<Duplicate_Record_Group__c> res = [Select Id from Duplicate_Record_Group__c where 
                                               Duplicate_Batch_JoB__c=:customJobID AND status__c = 'Ready to Merge'];
        return res; 
    }

    public void execute(Database.BatchableContext BC, List<Duplicate_Record_Group__c> lstDupRecGrp)
    {
        savepoint sp = Database.setSavepoint() ; 
        try{
            if(!customJobUpdated){
                Duplicate_Batch_Job__c oDupBatchJob = new Duplicate_Batch_Job__c(Id=customJobID); 
                oDupBatchJob.Status__c = 'Merge Processing' ; 
                update oDupBatchJob;    
                customJobUpdated = true;                 
            }
            // TURN OF CONTACT TRIGGER FOR THIS EXECUTION 
            ContactTriggerHandler.TriggerDisabled = true; 
            // Always batch SIZE = 1 
            if(lstDupRecGrp<>null&&lstDupRecGrp.size() > 1){
                for(Duplicate_Record_Group__c dupRecGrp:lstDupRecGrp){
                	dupRecGrp.status__c = 'Error';
                    dupRecGrp.Error_Message__c = 'Batch Size is greater than 0';
                    update dupRecGrp;
                }
                return; 
            }
            Id rsContactRecID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Roofstock Contact').getRecordTypeId();
            List<Duplicate_Records__c> lstDupRec = [Select Contact__c,Is_Master__c,Contact__r.recordtypeId,Contact__r.recordtype.Name  from Duplicate_Records__c
                                                   where Duplicate_Record_Group__c =:lstDupRecGrp[0].Id];
            // Find The Master Rec 
            Contact oMasterCon ; 
            Integer iMasterCnt = 0; 
            Set<String> setType = new set<String>(); 
            for(Duplicate_Records__c oDupRec:lstDupRec){
                if(oDupRec.Is_Master__c){
                	 oMasterCon = new Contact(Id=oDupRec.Contact__c);
                    if(oDupRec.Contact__r.RecordTypeId != rsContactRecID){
                       oMasterCon.RecordTypeId = rsContactRecID;
                    }
                    iMasterCnt++;
                }
                setType.add(oDupRec.Contact__r.recordtype.Name);
            }
            
            if(iMasterCnt>1){
            	lstDupRecGrp[0].status__c = 'Error';
                lstDupRecGrp[0].Error_Message__c = 'Multipe Master Contact is found';
                update lstDupRecGrp[0];	
                return; 
            }
            string sType ; 
            for(String recType: setType){
                if(sType == null){
                	sType = recType;    
                }  
                else{
                    sType = sType+';'+recType;
                }
            }
            if(oMasterCon<>null)
            oMasterCon.Contact_Type__c = sType; 
            Contact mergeCon; 
            for(Duplicate_Records__c oDupRec:lstDupRec){
                if(!oDupRec.Is_Master__c){
                	mergeCon = new Contact(Id=oDupRec.Contact__c);	
                    merge oMasterCon mergeCon;
                }
            }
            lstDupRecGrp[0].status__c = 'Record Merged';
            update lstDupRecGrp[0];	
         	
        }catch(exception exe){
            Database.rollback(sp); 
            lstDupRecGrp[0].status__c = 'Error';
            lstDupRecGrp[0].Error_Message__c = exe.getMessage();
            update lstDupRecGrp[0];	
            Debugloghandler.logAppException('BatchMergeDuplicateContact' , 'Execute',
                                            exe.getMessage(),exe.getStackTraceString(),'Apex Batch');  
        }
        
    }
    
    public void finish(Database.BatchableContext BC)
    {
        Duplicate_Batch_Job__c oDupBatchJob = new Duplicate_Batch_Job__c(Id=customJobID); 
        oDupBatchJob.Status__c = 'Merge Completed' ; 
        update oDupBatchJob;    
        customJobUpdated = true;        
    }
}
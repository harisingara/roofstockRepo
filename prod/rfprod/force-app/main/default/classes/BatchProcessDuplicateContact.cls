public class BatchProcessDuplicateContact implements Database.Batchable<sObject>, Database.Stateful{
    public Id customJobID ; 
    public Boolean customJobUpdated = false; 
    public List<AggregateResult> start(Database.BatchableContext BC)
    {
        List<AggregateResult> res = [SELECT BPM_Contact_Id__c, COUNT(Id) cnt FROM Contact where Recordtype.Name != 'Leasing' and BPM_Contact_Id__c != NULL GROUP BY BPM_Contact_Id__c  HAVING COUNT(ID) > 1 AND BPM_Contact_Id__c != NULL  ORDER BY COUNT(ID) DESC];
        return res; 
    }
    public static void selectMasterRecord(List<Duplicate_Records__c> lstDuplicRecs,map<Id,Contact> mapConRec,
                                          set<Id> setIntegrationUser,Duplicate_Record_Group__c oDupRec){
        // check if Record is created Manually by user 
        Integer nonIntegrationUserCnt = 0; 
        Duplicate_Records__c oMasterDupRec ;                                       
        for(Duplicate_Records__c oDupRecItem:lstDuplicRecs){
            if(!setIntegrationUser.contains(mapConRec.get(oDupRecItem.Contact__c).CreatedById)){
            	nonIntegrationUserCnt++;  
                oMasterDupRec = oDupRecItem ;   
            }    
        } 
        if(nonIntegrationUserCnt > 1 ){
        	oDupRec.Status__c = 'Need Review'; 
        }else if(nonIntegrationUserCnt == 1){
        	oMasterDupRec.Is_Master__c = true;     
        }else{
            Datetime LastModifieDate; 
            for(Duplicate_Records__c oDupRecItem:lstDuplicRecs){
                if(LastModifieDate == null || LastModifieDate < mapConRec.get(oDupRecItem.Contact__c).LastModifiedDate){
                	oMasterDupRec = oDupRecItem ;   
                    LastModifieDate = mapConRec.get(oDupRecItem.Contact__c).LastModifiedDate; 
                }
            } 
            if(oMasterDupRec<>NULL){
            	oMasterDupRec.Is_Master__c = true;  	    
            }
        }                                          
    }
    public void execute(Database.BatchableContext BC, List<AggregateResult> lstAggreResult)
    {
        savepoint sp = Database.setSavepoint() ; 
        try{
            if(!customJobUpdated){
                Duplicate_Batch_Job__c oDupBatchJob = new Duplicate_Batch_Job__c(Id=customJobID); 
                oDupBatchJob.Status__c = 'Processing' ; 
                update oDupBatchJob;    
                customJobUpdated = true;                 
            }
            
            // Collect all the Unique BPM_Contact_Id__c IDS from the Aggregate RESULT 
            Set<String> setConIds = new Set<String>(); 
            for(AggregateResult ar:lstAggreResult){
                System.debug('EMAIL ID' + ar.get('BPM_Contact_Id__c'));	  
                setConIds.add((String)ar.get('BPM_Contact_Id__c')); 
            }
            // Query all the records related to EMAIL 
            if(!setConIds.IsEmpty()){
                List<Contact> lstCon = [Select Id , BPM_Contact_Id__c,LastModifiedDate,CreatedById from Contact where Recordtype.Name != 'Leasing' and BPM_Contact_Id__c IN: setConIds Order BY BPM_Contact_Id__c,LastModifiedDate DESC]; 
                map<String,set<Id>> mapBPMCon = new map<String,set<Id>>(); 
                set<Id> setTempConIds ; 
                map<Id,Contact> mapConRec = new map<Id,Contact>(); 
                for(Contact oCon:lstCon){
                    setTempConIds = mapBpmCon.get(oCon.BPM_Contact_Id__c) ; 
                    if(setTempConIds == null){
                        setTempConIds = new Set<Id>(); 	       
                    }
                    setTempConIds.add(oCon.Id); 
                    mapConRec.put(oCon.Id,oCon); 
                    mapBpmCon.put(oCon.BPM_Contact_Id__c,setTempConIds); 
                }
                // Query Integration User Record 
                List<User> lstIntegrationUser = [Select Id from User where Profile.Name = 'System Administrator API']; 
                set<Id> setIntegrationUser = new set<Id>();
                for(User oUser:lstIntegrationUser){
                    setIntegrationUser.add(oUser.Id);     
                }
                system.debug('m,mapBpmCon'+ mapBpmCon);
                map<String, Duplicate_Record_Group__c> mapDuplicateGrpId = new 
                    map<String, Duplicate_Record_Group__c>();
                map<String, List<Duplicate_Records__c>> mapDuplicateGrp = new 
                    map<String, List<Duplicate_Records__c>>();
                List<Duplicate_Records__c> lstTempDup; 
                List<Duplicate_Record_Group__c> lstInsertDupRecs = new List<Duplicate_Record_Group__c>();
                // Create RECORDS !! 
                for(String oBpm:mapBpmCon.keySet()){
                    // Create Duplicate Group Record 
                    Duplicate_Record_Group__c oDupRec = new Duplicate_Record_Group__c(); 
                    oDupRec.Duplicate_Batch_JoB__c = customJobID; 
                    oDupRec.Duplicate_Key__c = oBpm; 
                    oDupRec.Duplicate_Match_Criteria__c = 'Duplicate Contact - Based on BPM Contact ID';
                    oDupRec.status__c = 'Ready to Merge';
                    lstTempDup = new List<Duplicate_Records__c>(); 
                    system.debug('check Duplicate_Record_Group__c'+ oDupRec);
                    for(Id oConId:mapBPMCon.get(oBpm)){
                        Duplicate_Records__c oDupRecItem = new Duplicate_Records__c(); 
                        oDupRecItem.Contact__c = oConId; 
                        oDupRecItem.Contact_Id__c = oConId; 
                        lstTempDup.add(oDupRecItem); 
                    }
                    if(lstTempDup.size() > 10 ) {
                        oDupRec.status__c = 'Manual Review & Merge';	
                    }else{
                        selectMasterRecord(lstTempDup,mapConRec,
                                          setIntegrationUser, oDupRec); 
                    }
                    lstInsertDupRecs.add(oDupRec); 
                    mapDuplicateGrpId.put(oBpm,oDupRec);
                    mapDuplicateGrp.put(oBpm,lstTempDup); 
                }
                if(!mapDuplicateGrp.IsEmpty()){
                    insert lstInsertDupRecs;    
                    
                    List<Duplicate_Records__c> lstInsertDupRecItems = new List<Duplicate_Records__c>(); 
                    for(String sEmail:mapDuplicateGrp.keyset()){
                        for(Duplicate_Records__c oDupRecs:mapDuplicateGrp.get(sEmail)){
                            oDupRecs.Duplicate_Record_Group__c = mapDuplicateGrpId.get(sEmail).Id;
                            lstInsertDupRecItems.add(oDupRecs); 
                            system.debug('check Duplicate_Records__c'+ oDupRecs);
                        }     
                    }
                    insert lstInsertDupRecItems; 
                }
            }
        }catch(exception exe){
            Database.rollback(sp); 
            Debugloghandler.logAppException('BatchProcessDuplicateContact' , 'Execute',
                                            exe.getMessage(),exe.getStackTraceString(),'Apex Batch');  
        }
        
    }
    
    public void finish(Database.BatchableContext BC)
    {
        Duplicate_Batch_Job__c oDupBatchJob = new Duplicate_Batch_Job__c(Id=customJobID); 
        oDupBatchJob.Status__c = 'Completed' ; 
        update oDupBatchJob;    
        customJobUpdated = true;        
    }
}
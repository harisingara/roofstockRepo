public class BatchProcessDuplicateAccount implements Database.Batchable<sObject>, Database.Stateful{
    public Id customJobID ; 
    public Boolean customJobUpdated = false; 
    public List<AggregateResult> start(Database.BatchableContext BC)
    {
        List<AggregateResult> res = [SELECT Roofstock_Account_ID__c, COUNT(Id) cnt FROM Account where
                                     Recordtype.Name != 'Leasing' and Roofstock_Account_ID__c != NULL 
                                     GROUP BY Roofstock_Account_ID__c  HAVING COUNT(ID) > 1 AND Roofstock_Account_ID__c != NULL 
                                     ORDER BY COUNT(ID) DESC];
        return res; 
    }
    public static void selectMasterRecord(List<Duplicate_Records__c> lstDuplicRecs,map<Id,Account> mapAccRec,
                                          set<Id> setIntegrationUser,Duplicate_Record_Group__c oDupRec){
        // check if Record is created Manually by user 
        Integer nonIntegrationUserCnt = 0; 
        Duplicate_Records__c oMasterDupRec ;                                       
        for(Duplicate_Records__c oDupRecItem:lstDuplicRecs){
            if(!setIntegrationUser.contains(mapAccRec.get(oDupRecItem.Account__c).CreatedById)){
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
                if(LastModifieDate == null || LastModifieDate < mapAccRec.get(oDupRecItem.Account__c).LastModifiedDate){
                	oMasterDupRec = oDupRecItem ;   
                    LastModifieDate = mapAccRec.get(oDupRecItem.Account__c).LastModifiedDate; 
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
            // TURN OF Account TRIGGER FOR THIS EXECUTION 
            // AccountTriggerHandler.TriggerDisabled = true;  NO TRIGGER FOR ACCOUNT
            // Collect all the Unique EMAIL IDS from the Aggregate RESULT 
            Set<String> setAccIds = new Set<String>(); 
            for(AggregateResult ar:lstAggreResult){
                System.debug('RS ACC ID' + ar.get('Roofstock_Account_ID__c'));	  
                setAccIds.add((String)ar.get('Roofstock_Account_ID__c')); 
            }
            // Query all the records related to EMAIL 
            if(!setAccIds.IsEmpty()){
                //List<Contact> lstCon = [Select Id , EMAIL from Contact where Recordtype.Name != 'Leasing' and EMAIL IN: setConIds ]; 
                List<Account> lstAcc = [SELECT Roofstock_Account_ID__c, Id,LastModifiedDate,CreatedById FROM Account where Recordtype.Name != 'Leasing' and Roofstock_Account_ID__c IN:setAccIds
                                        Order BY Roofstock_Account_ID__c,LastModifiedDate DESC]; 
                map<String,List<Account>> mapRSAccId = new map<String,List<Account>>(); 
                List<Account> lstTempAccIds ; 
                map<Id,Account> mapAccRec = new map<Id,Account>(); 
                for(Account oAcc:lstAcc){
                    mapAccRec.put(oAcc.Id,oAcc); 
                    lstTempAccIds = mapRSAccId.get(oAcc.Roofstock_Account_ID__c) ; 
                    if(lstTempAccIds == null){
                        lstTempAccIds = new List<Account>(); 	       
                    }
                    lstTempAccIds.add(oAcc); 
                    mapRSAccId.put(oAcc.Roofstock_Account_ID__c,lstTempAccIds); 
                }
                // Query Integration User Record 
                List<User> lstIntegrationUser = [Select Id from User where Profile.Name = 'System Administrator API']; 
                set<Id> setIntegrationUser = new set<Id>();
                for(User oUser:lstIntegrationUser){
                    setIntegrationUser.add(oUser.Id);     
                }
                system.debug('m,mapRSAccId'+ mapRSAccId);
                map<String, Duplicate_Record_Group__c> mapDuplicateGrpId = new 
                    map<String, Duplicate_Record_Group__c>();
                map<String, List<Duplicate_Records__c>> mapDuplicateGrp = new 
                    map<String, List<Duplicate_Records__c>>();
                List<Duplicate_Records__c> lstTempDup; 
                List<Duplicate_Record_Group__c> lstInsertDupRecs = new List<Duplicate_Record_Group__c>();
                // Create RECORDS !! 
                for(String sRSAccId:mapRSAccId.keySet()){
                    // Create Duplicate Group Record 
                    Duplicate_Record_Group__c oDupRec = new Duplicate_Record_Group__c(); 
                    oDupRec.Duplicate_Batch_JoB__c = customJobID; 
                    oDupRec.Duplicate_Key__c = sRSAccId; 
                    oDupRec.Duplicate_Match_Criteria__c = 'Duplicate Account - Based on RS AccountID';
                    oDupRec.status__c = 'Ready to Merge';
                    lstTempDup = new List<Duplicate_Records__c>(); 
                    system.debug('check Duplicate_Record_Group__c'+ oDupRec);
                    for(Account oAcc:mapRSAccId.get(sRSAccId)){
                        Duplicate_Records__c oDupRecItem = new Duplicate_Records__c(); 
                        oDupRecItem.Account__c = oAcc.Id; 
                        oDupRecItem.Account_Id__c = oAcc.Id;
                        lstTempDup.add(oDupRecItem); 
                    }
                    if(lstTempDup.size() > 10 ) {
                        oDupRec.status__c = 'Manual Review & Merge';	
                    }else{
                        selectMasterRecord(lstTempDup,mapAccRec,setIntegrationUser,oDupRec); 
                    }
                    
                    lstInsertDupRecs.add(oDupRec); 
                    mapDuplicateGrpId.put(sRSAccId,oDupRec);
                    mapDuplicateGrp.put(sRSAccId,lstTempDup); 
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
// May 4 10.00pm

global class RESTLeasingTurnHelper {
    global class LeasingTurnData{
       global List<LeasingTurnRequest> turnsList;
    }
    global class LeasingTurnRequest {
        global integer turnId;
        global string vendorId;
        global string homeCode;
        global date moveOutDate;
        global date yardiReadyDate;
        global date yardiAvailableDate;
        global string tenantStatus;
        global boolean isCompleted;
        global string moveOutReason;
        
    }
    
    global class PostResponse {
        global ResponseWrapper responseBody;
        global PostResponse(List<ResponseBody> turnResponse) {
            this.responseBody = new ResponseWrapper(turnResponse);
        }
    }
    
    global class ResponseWrapper {  
        global List<ResponseBody> turnResponse;  
        global ResponseWrapper(){
            turnResponse = new List<ResponseBody>();
        }
        global ResponseWrapper(List<ResponseBody> turnResponse) {
            this.turnResponse = turnResponse;
        }
    }  
    
    global class ResponseBody{
        global Decimal turnId;
        global String salesforceId;
        global String status;

        global ResponseBody(Decimal turnId, String salesforceId,String status) {
            this.turnId = turnId;
            this.salesforceId = salesforceId;
            this.status = status;
        }
    }
    global static PostResponse UpdateTurn(List<LeasingTurnRequest> turnsList) {
        Set<string> vendorIds = new Set<string>();
        Set<string> homeCodes = new Set<string>();
        Set<Integer> turnIdSet = new Set<Integer>(); 
        List<ResponseBody> turnsResponseList = new List<ResponseBody>();
        Id jobTurnRTId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Turn').getRecordTypeId();
        //find vendorid
        for (LeasingTurnRequest turn : turnsList) {
            if(!vendorIds.contains(turn.vendorId)){
                vendorIds.add(turn.vendorId);
            }
            
            /* RC-11378  */
            turnIdSet.add(turn.turnId);  
        }

        List<Vendor__c> vendors = [select id,Type__c, Vendor_Code__c ,name from Vendor__c where Vendor_Code__c in :vendorIds and Type__c='Roofstock']; 
        Map<string, id> vendorMap = new Map<string,id>();
        for (Vendor__c vendor : vendors) {
            vendorMap.put(vendor.Vendor_Code__c, vendor.id);
        }
        //find unitId
        for (LeasingTurnRequest turn : turnsList) {
            if(!homeCodes.contains(turn.homeCode)){
                homeCodes.add(turn.homeCode);
            }
        }
        /* RC-11378  */
        Map<Integer,boolean> turnIdCompletedMap = new Map<Integer,boolean>();
        Map<Integer,Date> turnIdMoveOutDateMap = new Map<Integer,Date>();   
        List<Turn__c> matchingTurns = [select Id,BPM_Turn_Id__c,Move_Out_Date__c,completed__c from Turn__c where bpm_turn_id__c IN:turnIdSet];
        for(Turn__c matchedTurn :matchingTurns){
            turnIdCompletedMap.put(Integer.valueOf(matchedTurn.BPM_Turn_Id__c),matchedTurn.Completed__c);
            turnIdMoveOutDateMap.put(Integer.valueOf(matchedTurn.BPM_Turn_Id__c),matchedTurn.Move_Out_Date__c);
        }
        
        map<Id,Leasing_Availability__c> mapUpdateLeasingAvail = new map<Id,Leasing_Availability__c>();
        map<Id,Property_Unit__c> mapPropertyUnit = new map<Id,Property_Unit__c>();
        List<Property_Unit__c> units = [select id, HomeCode__c,Name,Property__r.RecordType.Name  from Property_Unit__c where HomeCode__c in :homeCodes and Property__r.RecordType.DeveloperName ='Asset_Management']; 
        Map<string, Property_Unit__c> unitsMap = new Map<string,Property_Unit__c>();
        for (Property_Unit__c unit : units) {
            unitsMap.put(unit.HomeCode__c, unit);
        }
        
        //upsert turn record
        List<Turn__c> turns = new List<Turn__c>();
        List<Job__c> jobturns = new List<Job__c>();
        Set<Integer> skippedBpmTurnIdSet = new Set<Integer>();
        for (LeasingTurnRequest tr : turnsList) {
            if(!checkTurnCompleteStatus(turnIdCompletedMap,tr)){
                
                
                Turn__c turn = new Turn__c();
                turn.bpm_turn_id__c = tr.turnId;
                turn.Move_Out_Date__c = tr.moveOutDate;
                turn.Yardi_Ready_Date__c = tr.yardiReadyDate;
                turn.Yardi_Available_Date__c = tr.yardiAvailableDate;
                turn.tenant_status__c = tr.tenantStatus;
                turn.completed__c = tr.isCompleted; 
                turn.Move_Out_Reason__c = tr.moveOutReason;
                
                //foreign keys
                if(tr.vendorId != null && vendorMap.containsKey(tr.vendorId)){
                    turn.General_Contractor__c = vendorMap.get(tr.vendorId);
                }
                
                Property_Unit__c unit = unitsMap.get(tr.homeCode);
                if(unitsMap.containsKey(tr.homeCode) && unit != null){
                    turn.Property_Unit__c = unit.id;
                    turn.name = unit.name; // Vacate_Date__c , Ready_Date__c , Property_Unit__c
                    mapUpdateLeasingAvail.put(turn.Property_Unit__c, 
                                              new Leasing_Availability__c(Vacate_Date__c = tr.moveOutDate, Ready_Date__c = tr.yardiReadyDate)); 
                }
                turns.add(turn);
                // Add the JOB records 
                
                //[KM] 12/27/2021 - Commented for job turn logic for PMC2022-100
                /*
                Job__c turnJob = new Job__c();
                turnJob.bpm_turn_id__c = tr.turnId;
                turnJob.Move_Out_Date__c = tr.moveOutDate;
                turnJob.Yardi_Ready_Date__c = tr.yardiReadyDate;
                turnJob.Yardi_Available_Date__c = tr.yardiAvailableDate;
                turnJob.tenant_status__c = tr.tenantStatus;
                turnJob.completed__c = tr.isCompleted; 
                turnJob.Move_Out_Reason__c = tr.moveOutReason;
                turnJob.Job_Type__c = 'Turn';
                
                //foreign keys
                if(tr.vendorId != null && vendorMap.containsKey(tr.vendorId)){
                    turnJob.General_Contractor__c = vendorMap.get(tr.vendorId);
                }
                
                
                if(unitsMap.containsKey(tr.homeCode) && unit != null){
                    turnJob.Property_Unit__c = unit.id;
                    turnJob.name = unit.name; // Vacate_Date__c , Ready_Date__c , Property_Unit__c
                   }
                turnJob.recordtypeId = jobTurnRTId;
                // Add JOB to the Main LIST 
                    jobturns.add(turnJob); */
            }
            else{
                Turn__c turn = new Turn__c();
                turn.bpm_turn_id__c = tr.turnId;
                
                //[KM] 12/27/2021 - Commented for job turn logic for PMC2022-100
                //Job__c turnJob = new Job__c(); 
                //turnJob.bpm_turn_id__c = tr.turnId;
                if(turnIdMoveOutDateMap.containsKey(tr.turnId)){
                    System.debug('=input moveout='+tr.moveOutDate);
                    System.debug('=record moveout='+turnIdMoveOutDateMap.get(tr.turnId));
                    if(tr.moveOutDate!=turnIdMoveOutDateMap.get(tr.turnId)){
                        turn.Move_Out_Date__c = tr.moveOutDate;
                        turns.add(turn);
                        //[KM] 12/27/2021 - Commented for job turn logic for PMC2022-100
                        //turnJob.Move_Out_Date__c = tr.moveOutDate;
                        //jobturns.add(turnJob);
                    }
                    else{
                        skippedBpmTurnIdSet.add(tr.turnId);
                    }
                }
                
            }
        }
        //upsert turns BPM_Turn_Id__c;
        List<Turn__c> createdTurnsList = new List<Turn__c>();
        List<Turn__c> updatedTurnsList = new List<Turn__c>();
        
        //upsert JOBturns BPM_Turn_Id__c;
        List<JOB__c> createdJobTurnsList = new List<JOB__c>();
        List<JOB__c> updatedJobTurnsList = new List<JOB__c>();
        Database.UpsertResult[] turnResults = Database.upsert(turns, Turn__c.BPM_Turn_Id__c);
        //Database.UpsertResult[] jobturnResults = Database.upsert(jobturns, JOB__c.BPM_Turn_Id__c); //[KM] Commented for PMC2022-100
        system.debug('check'+jobturns );
        //system.debug('check'+jobturnResults );
        for(Integer i = 0; i < turnResults.size(); i++) {
            if(turnResults[i].isSuccess()) {
                if(turnResults[i].isCreated()) {
                    createdTurnsList.add(turns[i]);
                } else {
                    updatedTurnsList.add(turns[i]);
                }
            }
        }
        /*for(Integer i = 0; i < jobturnResults.size(); i++) {
            if(jobturnResults[i].isSuccess()) {
                if(jobturnResults[i].isCreated()) {
                    createdJobTurnsList.add(jobturns[i]);
                } else {
                    updatedJobTurnsList.add(jobturns[i]);
                }
            }
        }*/
        if(!mapUpdateLeasingAvail.IsEmpty()){
            List<Leasing_Availability__c> lstUpdateLeasing = [ Select Property_Unit__c, Vacate_Date__c , ID , Ready_Date__c 
                                                              from Leasing_Availability__c where Property_Unit__c IN:mapUpdateLeasingAvail.keyset()];     
            for(Leasing_Availability__c oLeasingAvail:lstUpdateLeasing){
                oLeasingAvail.Vacate_Date__c = mapUpdateLeasingAvail.get(oLeasingAvail.Property_Unit__c).Vacate_Date__c;
                oLeasingAvail.Ready_Date__c = mapUpdateLeasingAvail.get(oLeasingAvail.Property_Unit__c).Ready_Date__c;
            }
            update lstUpdateLeasing;
        }
        
        if(!createdTurnsList.isEmpty()){
            for (Turn__c turn : createdTurnsList) {
                turnsResponseList.add(new ResponseBody(turn.bpm_turn_id__c, turn.id,'Created'));
            }
        }
        if(!updatedTurnsList.isEmpty()){
            for (Turn__c turn : updatedTurnsList) {
                turnsResponseList.add(new ResponseBody(turn.bpm_turn_id__c, turn.id,'Updated'));
            }
        }
        /*
        if(!createdJobTurnsList.isEmpty()){
            for (Job__c turn : createdJobTurnsList) {
                turnsResponseList.add(new ResponseBody(turn.bpm_turn_id__c, turn.id,'Job Turn Created'));
            }
        }
        if(!updatedJobTurnsList.isEmpty()){
            for (Job__c turn : updatedJobTurnsList) {
                turnsResponseList.add(new ResponseBody(turn.bpm_turn_id__c, turn.id,'Job Turn Updated'));
            }
        }*/ 
        
        List<Turn__c> skippedTurnsList= [select Id,bpm_turn_id__c from Turn__c where bpm_turn_id__c IN:skippedBpmTurnIdSet];
        if(!skippedTurnsList.isEmpty()){
            for (Turn__c turn : skippedTurnsList) {
                turnsResponseList.add(new ResponseBody(turn.bpm_turn_id__c, turn.id,'Skipped'));
            }
        }
        
        
        postResponse res = new postResponse(turnsResponseList);
        return res;
    }
    private static boolean checkTurnCompleteStatus(Map<Integer,boolean> turnMap, LeasingTurnRequest requestTurn){
        
        if(turnMap.containskey(requestTurn.turnId)){
            if(turnMap.get(requestTurn.turnId)){
                return true;
            }
            else{
                return false;
            }
        }
        else{
            return false;
        }
        
    }
}
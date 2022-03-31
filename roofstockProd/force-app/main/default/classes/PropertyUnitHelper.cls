public class PropertyUnitHelper {
    
    public static void updateTurnStatus(List<Property_Unit__c> propertyUnitList,Map<Id,Property_Unit__c> propertyUnitOldMap){
        List<String> propertyUnitIdList = new List<String>();
        for(Property_Unit__c pUnit : propertyUnitList){
            if(pUnit.Occupancy_Status__c!=propertyUnitOldMap.get(pUnit.Id).Occupancy_Status__c){
                if(pUnit.Occupancy_Status__c == 'Vacant Unrented Not Ready' || pUnit.Occupancy_Status__c == 'Vacant Rented Not Ready'){
                    propertyUnitIdList.add(pUnit.Id);
                }
                
            }
        }
        System.debug('=propertyUnitIdList='+propertyUnitIdList);
        List<Turn__c> updateTurnList = new List<Turn__c>();
        List<Turn__c> turnList = [select Id,Status__c,Property_Unit__c from Turn__c where Property_Unit__c IN:propertyUnitIdList];
        System.debug('=turnList='+turnList);
        for(Turn__c turn : turnList){
            System.debug('=status='+turn.Status__c);
            if(turn.Status__c!='In Progress' && turn.Status__c!='Completed'){
            	turn.Status__c = 'In Progress';
            	updateTurnList.add(turn);
            }
        }
        System.debug('=updateTurnList='+updateTurnList);
        if(updateTurnList.size()>0){
            update updateTurnList;
        }
        
        // [KM] 12/21/2021 - commented for job turn logic for PMC2022-100
        // For JOB migration 
        /*System.debug('=propertyUnitIdList='+propertyUnitIdList);
        List<Job__c> updateJobTurnList = new List<Job__c>();
        List<Job__c> jobturnList = [select Id,Job_Status__c,Property_Unit__c from Job__c where Property_Unit__c IN:propertyUnitIdList];
        System.debug('=turnList='+jobturnList);
        for(Job__c turn : jobturnList){
            System.debug('=status='+turn.Job_Status__c);
            if(turn.Job_Status__c!='Work In Progress' && turn.Job_Status__c!='Job Completed'){
            	turn.Job_Status__c = 'Work In Progress';
                // commenting it as the status is managed 
            	updateJobTurnList.add(turn);
            }
        }
        System.debug('=updateTurnList='+updateJobTurnList);
        if(updateJobTurnList.size()>0){
            update updateJobTurnList;
        }*/
    }
	
    public static void updateUtilityStatus(List<Property_Unit__c> propertyUnitList,Map<Id,Property_Unit__c> propertyUnitOldMap){
        Set<Id> propertyUnitIdList = new Set<Id>();
        for(Property_Unit__c pUnit : propertyUnitList){
            if(pUnit.Operating_Status__c!=propertyUnitOldMap.get(pUnit.Id).Operating_Status__c){
                if(pUnit.Operating_Status__c == 'Sold'){
                    propertyUnitIdList.add(pUnit.Id);
                }
                
            }
        }
        if(!propertyUnitIdList.IsEmpty()){
        System.debug('=propertyUnitIdList='+propertyUnitIdList);
        List<Utilities__c> updateUtilitiesList = new List<Utilities__c>();
        List<Utilities__c> UtilitiesList = [select Id,Utilities_Status__c from Utilities__c where Property_Unit__c IN:propertyUnitIdList];
        System.debug('=turnList='+UtilitiesList);
        for(Utilities__c oUtility : UtilitiesList){
            
            if(oUtility.Utilities_Status__c!='Needs to be Disconnected'){
            	oUtility.Utilities_Status__c = 'Needs to be Disconnected';
            	updateUtilitiesList.add(oUtility);
            }
        }
        System.debug('=updateTurnList='+updateUtilitiesList);
        if(updateUtilitiesList.size()>0){
            update updateUtilitiesList;
        }
            }
    }
    
    /** Planomatic Callout  **/
    public static void planomaticOrder(List<Property_Unit__c> puList,Map<Id,Property_Unit__c> oldPropertyUnitMap){
        Set<String> propertyUnitIdSet = new Set<String>();
        List<Planomatic_Order__c> newPlanomaticOrderList = new List<Planomatic_Order__c>();
        if(Label.Planomatic_switch == 'Yes'){
        	for(Property_Unit__c pu:puList){
            	if((pu.Occupancy_Status__c <> null && pu.Occupancy_Status__c == 'Vacant Unrented Ready') && (pu.Occupancy_Status__c!=oldPropertyUnitMap.get(pu.Id).Occupancy_Status__c) &&
                  (pu.operating_reason__c <> null && (pu.operating_reason__c).toUppercase()!=('Temporary Occupancy Agreement').toUppercase()) && ((pu.Operating_Reason__c).toUppercase() != ('Tenant in Place').toUppercase())){
                	propertyUnitIdSet.add(pu.Id);        
            	}
            
        	}
        }
        if(propertyUnitIdSet.size()>0) {
            createPlanomaticOrder(propertyUnitIdSet);
        }
        
    }

    public static void createPlanomaticOrder(Set<String> propertyUnitIdSet) {
        Map<String,Job__c> puJobMap = new Map<String,Job__c>();
        Map<String,Turn__c> puTurnMap = new Map<String,Turn__c>();
        List<Property_Unit__c> filteredPUList = [select Id,(select Id from leasing__r) from Property_Unit__c where Id IN:propertyUnitIdSet];
        system.debug('filter pu::'+filteredPUList);
        List<Job__c> filteredJobList = [select Id,Lockbox_Code__c,Property_Unit__c,Self_Showing_Lockbox__c,createddate from Job__c where Property_Unit__c IN:propertyUnitIdSet
                                        and Lockbox_Code__c!=null order by createddate asc];
        system.debug('filteredJobList::'+filteredJobList);
        for(Job__c job:filteredJobList){
            puJobMap.put(job.Property_Unit__c,job);
        }
        if(puJobMap.isEmpty()){
            List<Turn__c> filteredTurnList = [select Id,Lockbox_Code__c,Property_Unit__c,Self_Showing_Lockbox__c,createddate from Turn__c where Property_Unit__c IN:propertyUnitIdSet
                                            and Lockbox_Code__c!=null order by createddate asc];
            system.debug('filteredTurnList::'+filteredTurnList);
            for(Turn__c turn:filteredTurnList){
                puTurnMap.put(turn.Property_Unit__c,turn);
            }
        }
        
        Map<String,String> rentalListingPropertyUnitMap = new Map<String,String>();
        for(Property_Unit__c pu:filteredPUList){
            for(Rental_Listing__c la:pu.leasing__r){
                rentalListingPropertyUnitMap.put(la.Id,pu.Id);
            }
        }
        system.debug('map value::'+rentalListingPropertyUnitMap.values());
        system.debug('map Key::'+rentalListingPropertyUnitMap.keyset());
        System.debug('-propertyUnitIdSet-'+propertyUnitIdSet);
        List<Rental_Listing__c> rlList = [SELECT Id, Name, Property_Unit__r.Occupancy_Status__c,
                                                 Property_Unit__r.Operating_Status__c,
                                                 Property_Unit__r.Property__r.Street_Address__c,
                                                 Property_Unit__r.Property__r.City__c,
                                                 Property_Unit__r.Property__r.County__c,
                                                 Property_Unit__r.Property__r.Zip__c,
                                                 Property_Unit__r.Property__r.State__c,
                                                 Property_Unit__r.Property__r.Property_Type__c,
                                                 Property_Unit__r.Property__r.Seller_Provided_List_Price__c,
                                                 Property_Unit__r.Property__r.Square_Feet__c,
                                                 Property_Unit__r.Property__r.PropertyId__c,
                                                 Property_Unit__r.HomeCode__c,
                                                 Property_Unit__r.Bathrooms__c,
                                                 Property_Unit__r.Bedrooms__c,
                                                 Property_Unit__r.Lockbox_Code__c,
                                                 Property_Unit__r.Client__c
                                            FROM Rental_Listing__c 
                                           WHERE Id IN:rentalListingPropertyUnitMap.keySet() 
                                             AND Property_Unit__r.Occupancy_Status__c = 'Vacant Unrented Ready'
                                             AND Property_Unit__r.Operating_Status__c = 'Leasable'
                                          	 AND Planomatic_Order_created__c = false
                                             AND Existing_Photos__c = false
                                                ];
        
        Map<String,Rental_Listing__c> rentalListingMap = new Map<String,Rental_Listing__c>(); 
        system.debug('rlList::'+rlList);
        if(rlList!=null){
            for(Rental_Listing__c rentalListing : rlList){
                if(!String.isBlank(rentalListing.Property_Unit__r.Property__r.Street_Address__c) &&
                    !String.isBlank(rentalListing.Property_Unit__r.Property__r.City__c) &&
                    !String.isBlank(rentalListing.Property_Unit__r.Property__r.County__c) &&
                    !String.isBlank(rentalListing.Property_Unit__r.Property__r.Zip__c) &&
                    !String.isBlank(rentalListing.Property_Unit__r.Property__r.State__c) &&
                    !String.isBlank(rentalListing.Property_Unit__r.Property__r.Square_Feet__c) &&
                    !String.isBlank(String.valueOf(rentalListing.Property_Unit__r.Bathrooms__c)) &&
                    !String.isBlank(String.valueOf(rentalListing.Property_Unit__r.Bedrooms__c)) ){
                        rentalListingMap.put(rentalListing.Id,rentalListing);
                        
                        
                    }
                
            }
            
            if(rentalListingMap.keyset().size()>0){
                system.debug('rentalListing Map::'+rentalListingMap.values());
                String strRentalListing = JSON.serialize(rentalListingMap.values());
                if(!puJobMap.isEmpty()){
                    String puJobSerialized = JSON.serialize(puJobMap);
                    system.debug('before calling planomatic call job::'+puJobSerialized);
                    PlanomaticCreateOrderHelper.orderDetailsAutomation(strRentalListing,puJobSerialized);
                }
                else if(!puTurnMap.isEmpty()){
                        String puTurnSerialized = JSON.serialize(puTurnMap);
                    system.debug('before calling planomatic call turn::'+puTurnSerialized);
                        PlanomaticCreateOrderHelper.orderDetailsAutomation(strRentalListing,puTurnSerialized);
                    
                }
                else{
                    system.debug('before calling planomatic call ::');
                        PlanomaticCreateOrderHelper.orderDetailsAutomation(strRentalListing,null);
                    
                }
                
                
            }
        }
    }

     /** Method to update Property Unit lookup field on Acquisition (Property__c) Object */
    public static void updatePropertyUnitOnAcquisition(List<Property_Unit__c> puList) {
        Map<String,Id> mapPropUnitIDandUnitRiid = new Map<String,Id>();
        List<Property__c> propListToUpdate = new List<Property__c>();

        for(Property_Unit__c propUnit : puList) {
            if(null <> propUnit.PropertyUnitId__c && '' <> propUnit.PropertyUnitId__c) {
                mapPropUnitIDandUnitRiid.put(propUnit.PropertyUnitId__c,propUnit.Id);
            }
        }
        
        for(Property__c prop : [SELECT Id, Name, Property_Unit_Riid__c 
                                  FROM Property__c 
                                 WHERE Property_Unit_Riid__c IN :mapPropUnitIDandUnitRiid.keyset() 
                                   AND Property_Unit__c = NULL]) { 
            if (mapPropUnitIDandUnitRiid.containskey(prop.Property_Unit_Riid__c)) {
                prop.Property_Unit__c = mapPropUnitIDandUnitRiid.get(prop.Property_Unit_Riid__c);
                propListToUpdate.add(prop);
            }
            system.debug('Value to be updated for Acquisition::'+prop);
        }
        
        if (null <> propListToUpdate && propListToUpdate.size() > 0) {
            Update propListToUpdate;   
        }
        
    }
    
    //[KM] Turn creation or update if move out date is changed
    public static void upsertJobTurn(Map<Id, Property_Unit__c> propertyUnitNewMap,Map<Id,Property_Unit__c> propertyUnitOldMap) {
        
        Toggle_New_logic__c bypassnewLogic = [Select id,name,Enable_new_logic__c from Toggle_New_logic__c where name ='Job__c' Limit 1];
        
        if (null <> bypassnewLogic && bypassnewLogic.Enable_new_logic__c == false) {
            return;
        } 
        else {
            Id jobTurnRTId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Turn').getRecordTypeId();
        	List<Job__c> jobturns = new List<Job__c>();
			Map<Id,Job__c> exisPropTurnMap = new Map<Id,Job__c>();
            Job__c exisJob;

            List<Property_Unit__c> propUnitList = [SELECT Id,name,Property__c,Occupancy_Status__c,Operating_Status__c,Property__r.Property_Management_Company__c,
                                                          Move_Out_Date__c,Move_In_Date__c,Ready_Date__c,Available_Date__c,Tenant_Status__c 
                                                     FROM Property_unit__c 
                                                    WHERE Occupancy_Status__c IN ('Occupied No Notice','Notice Unrented') AND 
                                                   		  Operating_Status__c = 'Leasable' AND 
                                                          Property__r.Property_Management_Company__c = 'Streetlane Property Management' AND 
                                                          Id IN :propertyUnitNewMap.keySet()];
            
            for(Job__c existurn: [SELECT Id,Name,Property_Unit__c,Job_Status__c 
                                    FROM Job__c 
                                WHERE Property_Unit__c = :propertyUnitNewMap.keyset() AND 
                                        (Job_Status__c != 'Job Completed' AND Job_Status__c != 'Job Cancelled')]) {      
                exisPropTurnMap.put(existurn.Property_Unit__c, existurn);
            }
            if (null <> propUnitList && propUnitList.size() > 0) {
                for(Property_Unit__c pUnit : propUnitList) {
                    if(null == propertyUnitOldMap || !propertyUnitOldMap.containsKey(pUnit.Id)) {
                        // Create new Job if the Porperty Unit is newly created
                        jobturns.add(createTurn(pUnit, jobTurnRTId));
                    }
                    else if(pUnit.Occupancy_Status__c <> propertyUnitOldMap.get(pUnit.Id).Occupancy_Status__c) {
                            // Existing Property Unit, Occupancy status is changed to "Occupied No Notice" -> create Job Turn if no open Job exist
                            if(null <> exisPropTurnMap && !exisPropTurnMap.containsKey(pUnit.Id)) { 
                                jobturns.add(createTurn(pUnit, jobTurnRTId));
                            }
                    } 
                }
            }
            
            // Existing Property Unit, with open Job, update Move Out Date
            if (propertyUnitOldMap <> null) {
                for (Property_Unit__c pUnit : propertyUnitNewMap.values()) {
                    if(propertyUnitOldMap.containsKey(pUnit.Id) && pUnit.Move_Out_Date__c <> propertyUnitOldMap.get(pUnit.Id).Move_Out_Date__c) {
                        if(exisPropTurnMap.containsKey(pUnit.Id)) {
                            exisJob = exisPropTurnMap.get(pUnit.Id);
                            exisJob.Move_Out_Date__c = pUnit.Move_Out_Date__c;
                            jobturns.add(exisJob);
                        }
                    }
                }
            }
                
            if(null <> jobturns && jobturns.size()>0) {
                Upsert jobturns;
            }
        }
    }
    
    public static Job__c createTurn(Property_Unit__c pUnit, Id jobTurnRTId) {
        Job__c turnJob = new Job__c();
        turnJob.Move_Out_Date__c = pUnit.Move_Out_Date__c;
        turnJob.Yardi_Ready_Date__c = pUnit.Ready_Date__c;
        turnJob.Yardi_Available_Date__c = pUnit.Available_Date__c;
        turnJob.tenant_status__c = pUnit.Tenant_Status__c;
        turnJob.Job_Type__c = 'Turn';
        turnJob.recordtypeId = jobTurnRTId;            
        turnJob.Property_Unit__c = pUnit.id;
        turnJob.name = pUnit.name;
        turnJob.Prior_Move_In_Date__c = pUnit.Move_In_Date__c;
        turnJob.Job_Status__c = 'Waiting for Move Out'; 
        turnJob.Property__c = pUnit.Property__c;
        return turnJob;
    }
    
    public static void updateRenewalOppStatus(Map<Id, Property_Unit__c> pUnitNewMap,Map<Id,Property_Unit__c> propertyUnitOldMap){
        
        Set<ID> propUnitIDSet = new Set<ID>();
        for(Property_Unit__c pu: pUnitNewMap.values()) {
            if(pu.Tenant_Status__c <> propertyUnitOldMap.get(pu.id).Tenant_Status__c && (pu.Tenant_Status__c == 'Notice' || pu.Tenant_Status__c == 'Eviction')) {
                propUnitIDSet.add(pu.id);
            }
        }
        
        if(propUnitIDSet.size()>0){
            Id renOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
			List<Opportunity> renOppList = [SELECT Id,name,StageName 
                                              FROM Opportunity 
                                             WHERE Property_Unit__c IN:propUnitIDSet 
                                               AND RecordTypeId = :renOppRTId
                                           	   AND isclosed = false];
            
            if(!renOppList.isEmpty()) {
                for(Opportunity renOpp : renOppList){
                    renOpp.StageName = 'Closed Notice';
                }
                
                update renOppList;
            }
		}
    }

    /**
     * Method to updated check status flag on utility Object
     * Condition :: When property unit Operating status is : 'Vacant Unrented Not Ready' 
     *               AND Propery managment compney is: 'Streetlane Property Managment'
     */
    public static void updateCheckStatus(List<Property_Unit__c> propertyUnitList, Map<Id,Property_Unit__c> propertyUnitOldMap) {
        Set<Id> propertyUnitIdList = new Set<Id>();
        Set<Id> filteredPuList = new Set<Id>();
        for(Property_Unit__c pUnit : propertyUnitList){
            system.debug('punit is::'+punit);          

            if( pUnit.Occupancy_Status__c != propertyUnitOldMap.get(pUnit.Id).Occupancy_Status__c && 
                (pUnit.Occupancy_Status__c == 'Vacant Unrented Not Ready' 
                 || pUnit.Occupancy_Status__c == 'Notice Unrented' 
                 || pUnit.Occupancy_Status__c == 'Notice Rented' )
              ) {
                    propertyUnitIdList.add(pUnit.Id);
            }
        }
        if(!propertyUnitIdList.isEmpty()) {
            List<Property_Unit__c> puPMC = [SELECT id,Property__r.Property_Management_Company__c FROM Property_Unit__c WHERE Id In :propertyUnitIdList];
            for(Property_Unit__c pmc: puPMC) {
                system.debug('punit PMC is::'+pmc.Property__r.Property_Management_Company__c);
                if(pmc.Property__r.Property_Management_Company__c == 'Streetlane Property Management') {
                    filteredPuList.add(pmc.Id);
                }
            }
        }
        if(!filteredPuList.isEmpty()) {
            List<Utilities__c> updateUtilitiesList = new List<Utilities__c>();
            List<Utilities__c> UtilitiesList = [SELECT Id,Utilities_Status__c 
                                                  FROM Utilities__c 
                                                 WHERE Property_Unit__c IN :propertyUnitIdList];
            for(Utilities__c oUtility : UtilitiesList){
                oUtility.Check_Status__c = true;
                updateUtilitiesList.add(oUtility);
            }

            System.debug('updateUtilities===>'+updateUtilitiesList);
            if(updateUtilitiesList.size()>0){
                update updateUtilitiesList;
            }

        }
    }
}
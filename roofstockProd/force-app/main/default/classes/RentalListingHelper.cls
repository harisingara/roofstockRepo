//06/05 

public class RentalListingHelper {
    public static boolean run = true;
    
    /*SF-88 - Function to update ORU*/
    Public static void updateORU(List<Rental_Listing__c> rentalListingList,Map<Id,Rental_Listing__c> OldMap){
        Set<String> rentalListingIdSet = new Set<String>();
        List<Opportunity> oppList =  new List<Opportunity>();
        for(Rental_Listing__c rl : rentalListingList){
            if(rl.Status__c!=oldMap.get(rl.Id).Status__c){
                rentalListingIdSet.add(rl.Id);
            }
        }
        system.debug('status change'+ rentalListingIdSet);
        if(!rentalListingIdSet.IsEmpty()){
            List<OpportunityRentalUnit__c> oruList = [SELECT Id, ParentLastUpdated__c, Opportunity__c, Listing_Status__c 
                                                        FROM OpportunityRentalUnit__c 
                                                       WHERE Leasing__c IN:rentalListingIdSet];
            Set<Id> setORUIDs = new Set<Id>();
            for(OpportunityRentalUnit__c oru :oruList){
                // oru.ParentLastUpdated__c = System.now(); As part of SF-209 issue using future meth0d to update
                setORUIDs.add(oru.Id);               
            }

            system.debug('check'+setORUIDs);
            if ( !setORUIDs.IsEmpty() && !( System.isFuture() || System.isBatch())){
                OpportunityRentalUnitHelper.updateORUDMLinFuture(setORUIDs);    
            }
          
        }
        // update oruList;
        RentalListingHelper.run = true;
    }
    
    // Populate Date on Property Unit Class 
    Public static void updateRelevantDateOnPropertyUnit(List<Rental_Listing__c> rentalListingList,Map<Id,Rental_Listing__c> OldMap,Boolean bIsInsert ){
        set<Id> setPropertyUnitIds = new set<Id>(); 
        Rental_Listing__c oldRec; 
        for(Rental_Listing__c oNewRental: rentalListingList){
            if(oNewRental.Property_Unit__c<>null && bIsInsert){
                setPropertyUnitIds.add(oNewRental.Property_Unit__c);    
            } else{
                oldRec = OldMap.get(oNewRental.Id); 
                if( oNewRental.Property_Unit__c<>null && ((oldRec.Rent_Ready_Date__c != oNewRental.Rent_Ready_Date__c) || (oldRec.Vacant_Date__c != oNewRental.Vacant_Date__c) 
                                                          || (oldRec.Available_Date__c != oNewRental.Available_Date__c) || (oldRec.Prelease_Date__c != oNewRental.Prelease_Date__c))){
                                                              setPropertyUnitIds.add(oNewRental.Property_Unit__c); 	    
                                                          }    
            }   
        }
        if(!setPropertyUnitIds.IsEmpty()){
            populateMostRecentDateOnUnit(setPropertyUnitIds);   
        }
    }
    
    Public static void populateMostRecentDateOnUnit(set<Id> setPropertyUnitIds){
        AggregateResult[] groupedResults = [SELECT Property_Unit__c unitId, MAX(Rent_Ready_Date__c) readyDt , MAX(Vacant_Date__c) vacantDt ,
                                            MAX(List_Date__c) listDt, MAX(Prelist_Date__c) prelistDt FROM Rental_Listing__c
                                            where Property_Unit__c IN: setPropertyUnitIds GROUP BY Property_Unit__c ]; 
        // Available_Date__c	 ... 
        if(groupedResults<>null && groupedResults.size() > 0){
            Date readyDt; 
            Date vacantDt; 
            Date listDt; 
            Date prelistDt; 
            Id unitId; 
            List<Property_Unit__c> lstPropertyUnit = new List<Property_Unit__c>(); 
            Property_Unit__c oPropertyUnit; 
            for(AggregateResult ar: groupedResults){
                readyDt = (Date)ar.get('readyDt'); 
                vacantDt = (Date)ar.get('vacantDt'); 
                listDt = (Date)ar.get('listDt'); 
                prelistDt = (Date)ar.get('prelistDt');  
                unitId = (Id)ar.get('unitId'); 
                oPropertyUnit = new Property_Unit__c(Id=unitId);
                if(readyDt<>NULL){
                    oPropertyUnit.Recent_Ready_Date__c = readyDt;    
                }
                if(vacantDt<>NULL){
                    oPropertyUnit.Recent_Vacate_Date__c = vacantDt;
                }
                if(listDt<>NULL){
                    oPropertyUnit.Recent_List_Date__c = listDt;    
                }
                if(prelistDt<>NULL){
                    oPropertyUnit.Recent_Prelist_Date__c = prelistDt;
                }
                lstPropertyUnit.add(oPropertyUnit);
            }
            if(!lstPropertyUnit.IsEmpty()){
                update lstPropertyUnit;    
            }
        }
        /* List<Property_Unit__c> lstPropertyUnits = [Select id , (Select Rent_Ready_Date__c,Vacant_Date__c,
                                                   Prelist_Date__c,List_Date__c from Leasing__r Order by Available_Date__c DESC LIMIT 1) 
                                                   from Property_Unit__c where ID IN:setPropertyUnitIds ]; 
        
        if(lstPropertyUnits<> null && !lstPropertyUnits.isEmpty()){
        	List<Property_Unit__c> lstPropertyUnit = new List<Property_Unit__c>(); 
            Property_Unit__c oPropertyUnit; 
            for(Property_Unit__c oUnit:lstPropertyUnits){
                if(oUnit.Leasing__r <> NULL && !oUnit.Leasing__r.IsEmpty()){
                oPropertyUnit = new Property_Unit__c(Id = oUnit.Id ,Recent_Ready_Date__c = oUnit.Leasing__r[0].Rent_Ready_Date__c,  
                                Recent_Vacate_Date__c = oUnit.Leasing__r[0].Vacant_Date__c,
                                Recent_List_Date__c = oUnit.Leasing__r[0].List_Date__c,
                                Recent_Prelist_Date__c = oUnit.Leasing__r[0].Prelist_Date__c); 	    
                lstPropertyUnit.add(oPropertyUnit);
                }    
            } 
            if(!lstPropertyUnit.IsEmpty()){
                update lstPropertyUnit;    
            }
        }*/

        
    }

    /**
     * Method to create a Planomatic order if new rental listing is created
     */
    public static void planomaticOrder(List<Rental_Listing__c> rlList){
        Set<String> propertyUnitIdSet = new Set<String>();
        if(Label.Planomatic_switch == 'Yes'){
            for(Rental_Listing__c rl : rlList) {
                if(rl.Occupancy_Status__c == 'Vacant Unrented Ready' && rl.Operating_Status__c == 'Leasable')
                propertyUnitIdSet.add(rl.Property_Unit__c);
            }
        }
        if(propertyUnitIdSet.size()>0) {
            PropertyUnitHelper.createPlanomaticOrder(propertyUnitIdSet);
        }
    }
    
    /*
     Method to Check if a completed Planomatic Order exists and has been created in past 3 years for the Property Unit Linked to the
	 Rental Listing being created.
	 If so, update the Planomatic Order on the 'Latest Planomatic Order' field
.    and update the 'Existing Pictures' to true
     */
    public static void getPlanomaticOrderInfo(List<Rental_Listing__c> rlList) {
        
        Set<Id> propertyUnitIds = new Set<Id>();
        Map<Id, Id> propertyIdToPlanomaticOrderId = new Map<Id, Id>();

        for(Rental_Listing__c rl: rlList){
            propertyUnitIds.add(rl.Property_Unit__c);            
        }
        
        // Get the latest Planomatic order of the Property Unit
        for(Planomatic_Order__c po : [SELECT Id, Rental_Listing__r.Property_Unit__c 
                                        FROM Planomatic_Order__c where Rental_Listing__r.Property_Unit__c IN : propertyUnitIds 
                                         AND Status__c = 'Completed'
                                         AND Submitted_Cancel_Onsite__c = false
                                         AND Createddate >= LAST_N_YEARS:3 
                                    ORDER BY Createddate DESC ]){
            if(!propertyIdToPlanomaticOrderId.containsKey(po.Rental_Listing__r.Property_Unit__c)) {
                propertyIdToPlanomaticOrderId.put(po.Rental_Listing__r.Property_Unit__c, po.Id);
            }                
        }

        if (propertyIdToPlanomaticOrderId.size() > 0) {
            for(Rental_Listing__c rl: rlList) {
                if(propertyIdToPlanomaticOrderId.containsKey(rl.Property_Unit__c)) {
                    rl.Existing_Photos__c = true;
                    rl.Latest_Planomatic_Order__c  = propertyIdToPlanomaticOrderId.get(rl.Property_Unit__c);
                }
            }
        }

    }
    

    /**
     * https://roofstock.atlassian.net/browse/PMC2022-164
     * Method to Update 'First Lease' field value at rental listing level.
     * Input: Trigger.New
     */
    public static void updateFirstLease(List<Rental_Listing__c> newRecordsList) {
        Set<Id> puIdList =  new Set<Id>();
        Set<Id> leasePuIdList =  new Set<Id>();

        for(Rental_Listing__c rList : newRecordsList){
            puIdList.add(rList.Property_Unit__c); 
            system.debug('value is::'+rList.Property_Unit__r.Operating_Reason__c);       
        }

        for (lease__c rl : [SELECT id, Property_Unit__c 
                              FROM lease__c 
                             WHERE Property_Unit__c IN :puIdList]) {
                                 leasePuIdList.add(rl.Property_unit__c);
        }

        for(Rental_Listing__c rl : newRecordsList) {
            if(rl.Operating_Reason__c == 'Temporary Occupancy Agreement' || rl.Operating_Reason__c == 'Tenant in Place' || rl.Operating_Reason__c == System.Label.LeaseBack) {
                rl.First_Lease__c = true;
            } else if(!leasePuIdList.contains(rl.Property_unit__c)) {
                rl.First_Lease__c = true;
            }
        }
        
    }
}
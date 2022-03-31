// May 19 12:10pm

global  class RESTRentalListingHelper {
    global class RentalListingData{
       global List<RentalListingWrapper> rentalListingList;
    }

    global class RentalListingWrapper {
        //RS unit instance id
        global string unitId;
        //monthly rent
        global double currentRent;
        //
        global string rentalListingId;
        global double lockboxSerialNo ;
        global date accessEndDate;
        global date accessStartDate;
        global date agentInactiveDate;
        global date agentShowingDate;
        global date autoShowingDate;
        global date availableDate;
        global double depositAmount;
        global string description;
        global string headline;
        global date holdUntilDate;
        global date inactiveDate;
        global Boolean isAllowCat;
        global Boolean isAllowDog;
        global date lbAssignedDate;
        global date lbUnassignDate;
        global integer lockboxSerialNumber;
        global date marketDate;
        global string moveInMoveOutType;
        global string name;
        global date preleaseDate;
        global date preshowDate;
        global double previousRent;
        global string rentCafeUrl;
        global date rentReadyDate;
        global datetime rentUpdatedAt;
        global string rentlyPropertyId;
        global string rentlyRawHash;
        global integer squareFeet;
        global string status;
        global string summary;
        global date vacantDate;
        global string yardiRawHash;
        
        //RC-11384
        global decimal initialListPrice;
        global string incentiveDuration;
        global Date readyDate;
        global Date listDate;
        global Date prelistDate;
        global decimal previousLeasePrice;
        global decimal incentiveAmount;
        global date moveInDate;
        global date leasedDate;
        
        //PMC-349
        global Integer noOfApprovedApplications;
        global Integer noOfPendingApplications;
        global Integer noOfCancelledApplications;
        global Integer noOfDeniedApplications;
        global Integer noOfShowingsAllTime;
        global Integer noOfShowingsCurrentWeek;
        global Integer rentlyWaitlist;
        global decimal initialRent;
    }
    
    global class PostResponse {  
        global ResponseWrapper responseBody;  
        global PostResponse(List<ResponseBody> rentalListingResponse) {
            this.responseBody = new ResponseWrapper(rentalListingResponse);
        }
    }
    
    global class ResponseWrapper {  
        global List<ResponseBody> rentalListingResponse;  
        global ResponseWrapper(){
            rentalListingResponse=new List<ResponseBody>();
        }
        global ResponseWrapper(List<ResponseBody> rentalListingResponse) {
            this.rentalListingResponse = rentalListingResponse;
        }
    }    
    
    global class ResponseBody{
        global String rsId;
        global String salesforceId;
        global ResponseBody(String rsId, String salesforceId) {
            this.rsId=rsId;
            this.salesforceId=salesforceId;        
        }
    }
    global static PostResponse AddRentalListing(list<RentalListingWrapper> rentalListingList) { 
        
        Map<string,double> propertyUnitsPriceMap = new Map<string,double>();
        
        //Map<String, Double> newProdMap = new Map<String, Double>();
        //Map<String, Product2> prodMap = new Map<String, Product2>();
        //Map<String,String> unitHomeCodeMap = new Map<String,String>();
        //List<PricebookEntry> pbesList = new List<PricebookEntry>();
        //Set<Id> unitIds = new Set<Id>();
        //Set<String> homeCodes = new Set<String>();
        List<ResponseBody> listingsResponseList = new List<ResponseBody>();  
        
        //unitIds = [select unitId from rentalListingList];
        
        //List<Property_Unit__c> propertyUnitsList = [select id  from Property_Unit__c 
        //                                           where PropertyUnitId__c in :unitIds];
        
        //for(Property_Unit__c unit : propertyUnitsList) {
        //  unitHomeCodeMap.put(unit.PropertyUnitId__c,unit.id);  
        //}
        //add rental listing record to unit (search for an existing leasing with active status)
        //if exist , update this leasing record
        List<Rental_Listing__C> listingList = new List<Rental_Listing__C>();

        List<Id> updatedLeasing = new List<Id>();
        
        for(RentalListingWrapper rentalListing: rentalListingList){ 
            Rental_Listing__C listing = new Rental_Listing__C();
            listing.Property_unit__C = rentalListing.unitId;
            listing.Rental_Listing_Id__c = rentalListing.rentalListingId;
            listing.Lockbox_Serial_No__c = rentalListing.lockboxSerialNo;
            
            listing.Access_End_Date__c = rentalListing.accessEndDate;
            listing.Access_Start_Date__c = rentalListing.accessStartDate;
            listing.Agent_Inactive_Date__c = rentalListing.agentInactiveDate;
            listing.Agent_Showing_Date__c = rentalListing.agentShowingDate;
            listing.Auto_Showing_Date__c = rentalListing.autoShowingDate;
            listing.Available_Date__c = rentalListing.availableDate;
            listing.Current_Rent__c = rentalListing.currentRent;
            listing.Deposit_Amount__c = rentalListing.depositAmount;
            listing.Description__c = rentalListing.description;
            listing.Headline__c = rentalListing.headline;
            listing.Hold_Until_Date__c = rentalListing.holdUntilDate;
            listing.Inactive_Date__c = rentalListing.inactiveDate;
            listing.Lb_Assigned_Date__c = rentalListing.lbAssignedDate;
            listing.Lb_Unassign_Date__c = rentalListing.lbUnassignDate;
            listing.Lockbox_Serial_No__c = rentalListing.lockboxSerialNo;
            listing.Move_In_Move_Out_Type__c = rentalListing.moveInMoveOutType;
            listing.Name = rentalListing.name;
            listing.Prelease_Date__c = rentalListing.preleaseDate;
            listing.Preshow_Date__c = rentalListing.preshowDate;
            listing.Previous_Rent__c = rentalListing.previousRent;
            listing.Rent_Updated_At__c = rentalListing.rentUpdatedAt;
            listing.Rently_Property_Id__c = rentalListing.rentlyPropertyId;
            listing.Rently_Raw_Hash__c = rentalListing.rentlyRawHash;
            listing.Square_Feet__c = rentalListing.squareFeet;
            listing.Status__c = rentalListing.status;
            listing.Summary__c = rentalListing.summary;
            listing.Vacant_Date__c = rentalListing.vacantDate;
            listing.Yardi_Raw_Hash__c = rentalListing.yardiRawHash;
            
            //RC-11384
            listing.Previous_Lease_Price__c = rentalListing.previousLeasePrice;           
            listing.Initial_Rent__c  = rentalListing.initialListPrice;                
            listing.Incentive_Amount__c = rentalListing.incentiveAmount;
            listing.Incentive_Duration__c = rentalListing.incentiveDuration;
            listing.Rent_Ready_Date__c = rentalListing.readyDate;      
            listing.List_Date__c = rentalListing.listDate;
            if( rentalListing.prelistDate <> null) {
                listing.Prelist_date__c = rentalListing.prelistDate;
            }
            listing.Move_in_Date__c = rentalListing.moveInDate;
            listing.Leased_Date__c = rentalListing.leasedDate;

            //PMC-349
            listing.Rently_Waitlist__c = rentalListing.rentlyWaitlist;            
            listing.Approved_Apps__c = rentalListing.noOfApprovedApplications;
            listing.Pending_Apps__c = rentalListing.noOfPendingApplications;
            listing.Cancelled_Apps__c = rentalListing.noOfCancelledApplications;
            listing.Denied_Apps__c = rentalListing.noOfDeniedApplications;
            listing.Rently_Showings_Total__c = rentalListing.noOfShowingsAllTime;
            listing.Rently_Showings_Past_Week__c = rentalListing.noOfShowingsCurrentWeek;
            listing.Initial_Rent__c = rentalListing.initialRent;            
            
            listingList.add(listing);
        }

        if(listingList <> null && listingList.size() > 0) {
            upsert listingList Rental_Listing_Id__c ;
        
            for(Rental_Listing__C listing : listingList){
                listingsResponseList.add(new ResponseBody(listing.Rental_Listing_Id__c, listing.id));
                updatedLeasing.add(listing.Id);
            }
    
        }
        updateOpptyRentalyStatus(updatedLeasing);
        postResponse res = new postResponse(listingsResponseList); 
        return res;
    }

    @future
    public static void updateOpptyRentalyStatus(List<Id> updatedLeasingList) {
        Map<Id,String> oppListMap = new Map<Id,String>();
        try{
            List<Feature_Toggle__mdt> toggle =    [SELECT id, developername, enable__c FROM Feature_Toggle__mdt WHERE developername='Copy_rentaly_status_to_oppty' ];
            if( toggle != null && toggle.size() == 1 && toggle[0].enable__c ) {
                system.debug('value is::'+toggle[0].enable__c);
                List<OpportunityRentalUnit__c> oruList = [SELECT Id, Leasing__c, Opportunity__c,Listing_status__C, Opportunity__r.Rently_Status__c 
                                                            FROM OpportunityRentalUnit__c 
                                                        WHERE Leasing__c IN:updatedLeasingList];

                system.debug('oru'+oruList.size()+'::'+oruList);

                for(OpportunityRentalUnit__c oru : oruList) {
                    if(oru.Opportunity__r.Rently_Status__c <> oru.Listing_status__C ){
                        oppListMap.put(oru.Opportunity__c, oru.Listing_status__C);
                    }
                }

                List<Opportunity> optyToUpdate = [SELECT id, Rently_Status__c 
                                                    FROM Opportunity 
                                                WHERE Id IN :oppListMap.keySet()];
                for(Opportunity opty : optyToUpdate) {
                    opty.Rently_Status__c = oppListMap.get(opty.Id);
                }
                update optyToUpdate;
                system.debug('List of opportunity to update:::' +optyToUpdate);
            }
        } catch(Exception e) {
            DebugLogHandler.logAppException('RESTRentalListingHelper','updateOpptyRentalyStatus',e.getMessage(),e.getStackTraceString(),'apex');
        }
    }
}
public class PlanomaticCreateOrderController {
    @AuraEnabled
    Public static boolean planomaticOrder(String recordId, String notes){
        boolean orderStatus;
        Map<String,sobject> accessDetailsMap = accessCodeDetails(recordId);
        //try{ 
        system.debug('notes value::'+notes);
        orderStatus = PlanomaticCreateOrderHelper.postOrder(recordId,accessDetailsMap,notes);
        
        return orderStatus;
        //}
        //catch(Exception ex){
        
        //}
        //return orderStatus;
    }
    @AuraEnabled
    public static boolean qualifyPlanomatic(String recordId){
        List<Rental_Listing__c> rentalListingList = [SELECT Id,Property_Unit__r.Occupancy_Status__c,
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
                                                               Property_Unit__r.Bathrooms__c,
                                                               Property_Unit__r.Bedrooms__c,
                                                               Property_Unit__r.Lockbox_Code__c
                                                          FROM Rental_Listing__c where Id=:recordId
                                                               and Property_Unit__r.Operating_Status__c = 'Leasable'
                                                              ];
        
        if(!rentalListingList.isEmpty()){
            if(!String.isBlank(rentalListingList[0].Property_Unit__r.Property__r.Street_Address__c) &&
               !String.isBlank(rentalListingList[0].Property_Unit__r.Property__r.City__c) &&
               !String.isBlank(rentalListingList[0].Property_Unit__r.Property__r.County__c) &&
               !String.isBlank(rentalListingList[0].Property_Unit__r.Property__r.Zip__c) &&
               !String.isBlank(rentalListingList[0].Property_Unit__r.Property__r.State__c) &&
               !String.isBlank(rentalListingList[0].Property_Unit__r.Property__r.Square_Feet__c) &&
               !String.isBlank(String.valueOf(rentalListingList[0].Property_Unit__r.Bathrooms__c)) &&
               !String.isBlank(String.valueOf(rentalListingList[0].Property_Unit__r.Bedrooms__c)) ){
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
    /** Currently this function returns true as we have default lockbox code set in apex code **/
    @AuraEnabled
    public static boolean checkAccessCodeDetails(String recordId){
        if(accessCodeDetails(recordId)!=null){
            Map<String,sObject> accessCodeDetailsMap = accessCodeDetails(recordId);
            Schema.SObjectType sObjectType = accessCodeDetailsMap.values().getSObjectType();
            System.debug('-sObjectType-'+sObjectType);
            
            if(accessCodeDetailsMap!=null){
                return true;
            }
            else{
                //return false;
                return true;
            }
        }
        else{
            return true;
        }
    }
    @AuraEnabled
    public static Map<String,sobject> accessCodeDetails(String recordId){
        Map<String,Job__c> puJobMap = new Map<String,Job__c>();
        Map<String,Turn__c> puTurnMap = new Map<String,Turn__c>();
        List<Rental_Listing__c> currentRentalListing = [select Id,Property_Unit__c from Rental_Listing__c where Id=:recordId];
        String PropertyUnitId = currentRentalListing[0].Property_Unit__c;
        /*** Property Unit - Job Map  ***/
        List<Job__c> filteredJobList = [select Id,Lockbox_Code__c,Property_Unit__c,Self_Showing_Lockbox__c,createddate from Job__c where Property_Unit__c=:PropertyUnitId
                                        and Lockbox_Code__c!=null order by createddate asc];
        
        for(Job__c job:filteredJobList){
            puJobMap.put(job.Property_Unit__c,job);
        }
        /*** Property Unit - Turn Map  ***/
        if(puJobMap.isEmpty()){
            List<Turn__c> filteredTurnList = [select Id,Lockbox_Code__c,Property_Unit__c,Self_Showing_Lockbox__c,createddate from Turn__c where Property_Unit__c=:PropertyUnitId
                                              and Lockbox_Code__c!=null order by createddate asc];
            for(Turn__c turn:filteredTurnList){
                puTurnMap.put(turn.Property_Unit__c,turn);
            }
        }
        
        if(!puJobMap.isEmpty()){
            return puJobMap;
            
        }
        else if(!puTurnMap.isEmpty()){
            return puTurnMap;
        }
        else{
            return null;
        }
        
        
    }
    
    @AuraEnabled
    Public Static Rental_Listing__c displayLeasingAvailabilityDetails(String recordId){
        Rental_Listing__c la = [Select Id,Operating_Status__c,Ready_Date__c,Occupancy_Status__c,Existing_Photos__c  from Rental_Listing__c where Id=:recordId];
        return la;
    }
    
}
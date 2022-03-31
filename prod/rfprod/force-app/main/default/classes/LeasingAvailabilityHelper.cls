public class LeasingAvailabilityHelper {
	/** Planomatic Callout  **/
    public static void planomaticOrder(List<Leasing_Availability__c> laList,Map<Id,Leasing_Availability__c> oldLaMap){
        Set<String> propertyUnitIdSet = new Set<String>();
        Set<String> leasingAvailabilitySet = new Set<String>();
        for(Leasing_Availability__c la:laList){
            if((!String.isEmpty(String.valueOf(la.Ready_Date__c))) && (la.Ready_Date__c!=oldLaMap.get(la.Id).Ready_Date__c) && (String.isEmpty(String.valueOf(oldLaMap.get(la.Id).Ready_Date__c)))){
                propertyUnitIdSet.add(la.Property_Unit__c);
                leasingAvailabilitySet.add(la.Id);
            }
            
        }
        
        if(propertyUnitIdSet.size()>0){
            Map<String,Job__c> puJobMap = new Map<String,Job__c>();
            Map<String,Turn__c> puTurnMap = new Map<String,Turn__c>();
            /*** Property Unit - Job Map  ***/
            List<Job__c> filteredJobList = [select Id,Lockbox_Code__c,Property_Unit__c,Self_Showing_Lockbox__c,createddate from Job__c where Property_Unit__c IN:propertyUnitIdSet
                                           	and Lockbox_Code__c!=null order by createddate asc];
            for(Job__c job:filteredJobList){
                puJobMap.put(job.Property_Unit__c,job);
            }
            /*** Property Unit - Turn Map  ***/
            if(puJobMap.isEmpty()){
            List<Turn__c> filteredTurnList = [select Id,Lockbox_Code__c,Property_Unit__c,Self_Showing_Lockbox__c,createddate from Turn__c where Property_Unit__c IN:propertyUnitIdSet
                                           	and Lockbox_Code__c!=null order by createddate asc];
            for(Turn__c turn:filteredTurnList){
                puTurnMap.put(turn.Property_Unit__c,turn);
            }
            }
           
            System.debug('-propertyUnitIdSet-'+propertyUnitIdSet);
            List<Leasing_Availability__c> leasingAvailabilityList = [Select Id,name,Property_Unit__r.Occupancy_Status__c,
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
                                                    Property_Unit__r.Bedrooms__c
                                                    from Leasing_Availability__c where Id IN:leasingAvailabilitySet
                                                    and Property_Unit__r.Operating_Status__c = 'Leasable'
                                                    ];
            
            Map<String,Leasing_Availability__c> leasingAvailabilityMap = new Map<String,Leasing_Availability__c>(); 
            if(leasingAvailabilityList!=null){
                for(Leasing_Availability__c leaseAvailability : leasingAvailabilityList){
                    if(!String.isBlank(leaseAvailability.Property_Unit__r.Property__r.Street_Address__c) &&
                       !String.isBlank(leaseAvailability.Property_Unit__r.Property__r.City__c) &&
                       !String.isBlank(leaseAvailability.Property_Unit__r.Property__r.County__c) &&
                       !String.isBlank(leaseAvailability.Property_Unit__r.Property__r.Zip__c) &&
                       !String.isBlank(leaseAvailability.Property_Unit__r.Property__r.State__c) &&
                       !String.isBlank(leaseAvailability.Property_Unit__r.Property__r.Square_Feet__c) &&
                       !String.isBlank(String.valueOf(leaseAvailability.Property_Unit__r.Bathrooms__c)) &&
                       !String.isBlank(String.valueOf(leaseAvailability.Property_Unit__r.Bedrooms__c)) ){
                           leasingAvailabilityMap.put(leaseAvailability.Id,leaseAvailability);
                                                      
                       }
                    
                }
                if(leasingAvailabilityMap.keyset().size()>0){
                    String strLeasingAvailability = JSON.serialize(leasingAvailabilityMap.values());
                    if(!puJobMap.isEmpty()){
                        String puJobSerialized = JSON.serialize(puJobMap);
                        PlanomaticCreateOrderHelper.orderDetailsAutomation(strLeasingAvailability,puJobSerialized);
                    }
                    else if(!puTurnMap.isEmpty()){
                         String puTurnSerialized = JSON.serialize(puTurnMap);
                         PlanomaticCreateOrderHelper.orderDetailsAutomation(strLeasingAvailability,puTurnSerialized);
                       
                    }
                    else{
                         PlanomaticCreateOrderHelper.orderDetailsAutomation(strLeasingAvailability,null);
                        
                    }
                    
                    
                }
            }
            
            
        }
    }
}
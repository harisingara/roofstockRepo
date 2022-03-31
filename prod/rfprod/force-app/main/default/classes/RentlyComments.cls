public class RentlyComments {
    @AuraEnabled (cacheable=true)
    public static List<Opportunity_Rental_Unit_Activity__c> retrieveFeedback(String listingId){
        List<Opportunity_Rental_Unit_Activity__c> uruaList =  [SELECT Id, Feedback__c, HasFeedback__c, Opportunity_Rental_Unit__r.Opportunity__c,
                                                                      Opportunity_Rental_Unit__r.Opportunity__r.Name, Activity_Name__c,Source__c
                                                                 FROM Opportunity_Rental_Unit_Activity__c 
                                                                WHERE Opportunity_Rental_Unit__r.Leasing__c =:listingId AND 
                                                                      HasFeedback__c = true];
        
        return uruaList;
        
    }

}
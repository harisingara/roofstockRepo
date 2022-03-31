public class ListingRelOppsCntrlApex {
    
    @Auraenabled
    public static list <Opportunity> fetchRelatedOppsApex (Id oppId){
        Opportunity currOpp = [Select Id, Rental_Listing__c from Opportunity where Id =: oppId];
        
        return ([SELECT Id, Name, StageName, Sub_Stage__c, Ready_for_Approval__c, Ready_For_Approval_Checked_Date1__c FROM Opportunity 
                 WHERE Rental_Listing__c =: currOpp.Rental_Listing__c AND 
                 StageName IN ('Application Submitted', 'Screening', 'Decision Made') AND
                 Sub_Stage__c NOT IN ('Application Canceled', 'Application Declined', 'Application Denied') AND
                 ID !=: currOpp.Id AND
                 Relationship__c  =: 'Self' AND Rental_Listing__c != null] ); 
        
    }

}
public class LeadInfoOppty {
    
     //List
        public static list<Lead> oppty;

    // method
    
        public LeadInfoOppty(){
             
        oppty = [Select Lead_Interest__c, LeadSource, How_did_you_hear_about_Roofstock__c,ConvertedDate ,IP_Timezone__c
                FROM Lead WHERE convertedaccountid in 
                (SELECT accountid from Opportunity where id = :ApexPages.currentPage().getParameters().get('id'))];    
    }
    
        public static List<Lead> getoppty() {return oppty;}    
}
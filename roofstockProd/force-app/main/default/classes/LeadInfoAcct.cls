public class LeadInfoAcct {

 //List
    public static list<Lead> acct;

    // method
    public LeadInfoAcct(){
             
        acct = [select Lead_Interest__c, LeadSource, How_did_you_hear_about_Roofstock__c,ConvertedDate ,IP_Timezone__c
                FROM Lead
                WHERE convertedaccountid =: ApexPages.currentPage().getParameters().get('id')
                ORDER By ConvertedDate DESC];
    
    }
    
    public static List<Lead> getacct() {return acct;}
    }
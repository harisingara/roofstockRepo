public class LeadInfoContact {

 //List
    public static list<Lead> acct;

    // method
    public LeadInfoContact(){
        Id contactId = ApexPages.currentPage().getParameters().get('id');
        //get account id for this contact!
        List<Contact> contact = [select account.id from contact where id= :contactId LIMIT 1] ;
        Id acctid = contact[0].accountId;     
        acct = [select Lead_Interest__c, LeadSource, How_did_you_hear_about_Roofstock__c,ConvertedDate 
                FROM Lead
                WHERE convertedaccountid = :acctid
                ORDER By ConvertedDate DESC];
    
    }  
    
    public static List<Lead> getacct() {return acct;}
    }
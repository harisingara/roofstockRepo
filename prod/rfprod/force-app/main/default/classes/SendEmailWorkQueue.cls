public class SendEmailWorkQueue {
    
    @AuraEnabled
    public static String investmentAccount(String recordId){
        List<ATF_Work_Queue__c> workQueueList = [select Id,Investment_Account__c from ATF_Work_Queue__c where Id=:recordId];
        return workQueueList[0].Investment_Account__c;
        
    }
    @AuraEnabled
    public static String primaryContactEmail(String investmentAccountId){
        List<Investment_Account_Contact_Role__c> contactrole;
        contactrole = [select Id,Role__c,Contact__r.Email from Investment_Account_Contact_Role__c where Investment_Account__c=:investmentAccountId and Role__c='Primary' limit 1];
        if(!contactrole.isEmpty()){
        	return contactrole[0].Contact__r.Email;
        }
        else{
            return null;
        }
        
    }
    
}
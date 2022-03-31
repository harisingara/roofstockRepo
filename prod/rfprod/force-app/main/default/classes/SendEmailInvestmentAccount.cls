public class SendEmailInvestmentAccount {
    @AuraEnabled
    public static String primaryContactEmail(String recordId){
        List<Investment_Account_Contact_Role__c> contactroleList = [select Id,Role__c,Contact__r.Email from Investment_Account_Contact_Role__c where Investment_Account__c=:recordId and Role__c='Primary' limit 1];
        if(!contactroleList.isEmpty()){
        	return contactroleList[0].Contact__r.Email;
        }
        else{
            return null;
        }
        
    }

}
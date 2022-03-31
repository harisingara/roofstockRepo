public class SendEmailLead {
    @AuraEnabled
    public static Lead leadDetails(String recordId){
        Lead currentLead = [select Id,Email from Lead where Id=:recordId];
        return currentLead;
        
    }
    /*
    @AuraEnabled
    public static String emailServiceAddress(String recordId){
        EmailServicesFunction emailFunction;
        Id recId = Id.valueOf(recordId);
        String obj = String.valueOf(recId.getsobjecttype());
        String emailServiceAddress = '';
        if(obj == 'Lead'){
        	emailFunction = [SELECT Id FROM EmailServicesFunction WHERE FunctionName='iBuy'];
        }
        List<EmailServicesAddress> emailServicesAddress = [SELECT Id,DeveloperName,RunAsUserId,LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId = :emailFunction.Id];
        emailServiceAddress =  emailServicesAddress[0].LocalPart+ '@' + emailServicesAddress[0].EmailDomainName;
        return emailServiceAddress;    
        }
	*/
}
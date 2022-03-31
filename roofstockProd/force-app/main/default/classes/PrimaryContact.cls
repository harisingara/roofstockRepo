public class PrimaryContact {
    
    @AuraEnabled
    public static String investmentAccount(String recordId){
        Id recId = Id.valueOf(recordId);
        String obj = String.valueOf(recId.getsobjecttype());
        System.debug('-obj-'+obj);
        if(obj == 'ATF_Work_Queue__c'){
            List<ATF_Work_Queue__c> workQueueList = [Select Id,Investment_Account__c from ATF_Work_Queue__c where Id=:recordId];
            return workQueueList[0].Investment_Account__c;
        }
        else if(obj == 'Investment_Account__c'){
            return recordId;
        }
        else if(obj == 'EmailMessage'){
            List<EmailMessage> emList = [select My_Task__c,My_Task__r.Investment_Account__c,Investment_Account__c,EmailServiceParentId__c from EmailMessage where Id=:recordId];
            System.debug('-emList-'+emList);
            Id parentRecId = Id.valueOf(emList[0].EmailServiceParentId__c);
            System.debug('-parentRecId-'+parentRecId);
        	String parentObj = String.valueOf(parentRecId.getsobjecttype());
            System.debug('-parentObj-'+parentObj);
            if(parentObj == 'ATF_Work_Queue__c'){
                return emList[0].My_Task__r.Investment_Account__c;
            }
            else if(parentObj == 'Investment_Account__c'){
                return emList[0].Investment_Account__c;
            }
            else{
                return null;
            }
            
        }
        else{
            return null;
        }
    }
    
    @AuraEnabled
    public static List<contactWrapper> investmentAccountContacts(String recordId,String investmentAccountId){
        List<contactWrapper> contactList = new List<contactWrapper>();
        
        Id recId = Id.valueOf(recordId);
        String obj = String.valueOf(recId.getsobjecttype());
        
        List<Investment_Account_Contact_Role__c> investmentAccountContacts = new List<Investment_Account_Contact_Role__c>();
        //if(obj == 'ATF_Work_Queue__c'){
            investmentAccountContacts = [select Id,Role__c,Contact__c,Contact__r.Name,Contact__r.Email from Investment_Account_Contact_Role__c where Investment_Account__c=:investmentAccountId];
        //}
        for(Investment_Account_Contact_Role__c iacr:investmentAccountContacts){
            contactWrapper cw = new contactWrapper();
            cw.Id = iacr.Id;
            cw.selected = false;
            cw.name = iacr.Contact__r.Name;
            cw.email = iacr.Contact__r.Email;
            cw.role = iacr.Role__c;
            contactList.add(cw);
        }
        System.debug('=contactList='+contactList);
        return contactList;
        
    }
    public class contactWrapper{
        @AuraEnabled public String Id;
        @AuraEnabled public boolean selected;
        @AuraEnabled public String name;
        @AuraEnabled public String email;
        @AuraEnabled public String role;
    }
    
    
}
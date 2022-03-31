public with sharing class SendEmailHoa {
    @AuraEnabled
    public static Hoa__c hoaDetails(String recordId){
        HOA__c currentHoa = [SELECT Id, HOA_Company_Contact__c,  Payment_Email__c, PM_Email__c FROM HOA__c WHERE Id=:recordId];
        return currentHoa;
    }

    @AuraEnabled
    public static String violationHoaDetails(String recordId){
        String ret = '';
        Violation__c currentViolation = [SELECT Id,HOA__r.HOA_Company_Contact__c, HOA__r.Payment_Email__c, HOA__r.PM_Email__c FROM Violation__c WHERE Id=:recordId];
        if (currentViolation.HOA__c <> null && currentViolation.HOA__r.Payment_Email__c <> null) {
            ret = currentViolation.HOA__r.Payment_Email__c;
        }
        return ret;
    }

    @AuraEnabled
    public static String toAddress(String recordId){
        String ret = '';
        String primaryTenant = '';
        List<Property_Unit__c> propUnitIds = new List<Property_Unit__c>();
        try{
            Violation__c currentViolation = [SELECT Id,HOA__r.Property__c FROM Violation__c WHERE Id=:recordId];
            if (currentViolation.HOA__c <> null && currentViolation.HOA__r.Property__c <> null) {
                propUnitIds = [SELECT id,Property__c,Lease_End__c, Lease_Start__c  FROM Property_Unit__c WHERE Property__c = :currentViolation.HOA__r.Property__c];
            }
            if (!propUnitIds.isEmpty() && propUnitIds.size() == 1) {
                lease__c leaseData = [SELECT id FROM lease__c WHERE Property_Unit__c = :propUnitIds and Lease_Start_Date__c < TODAY and Lease_End_Date__c > today LIMIT 1];
                if(leaseData <> null) {
                    Tenant__c tenantInfo = [SELECT id, Email__c, Name FROM Tenant__c WHERE Lease__c = :leaseData.Id AND Tenant_Type__c = 'Primary'];
                    ret = tenantInfo.Email__c;
                    primaryTenant = tenantInfo.Name;
                }
            }
            Violation__c pTenant =  new Violation__c();
            pTenant.Id = recordId;
            pTenant.Primary_Tenant__c = primaryTenant;
            update pTenant;
            system.debug('return value is:: '+ret);
            return ret;
        } catch(Exception e){
        system.debug('exception '+e.getMessage());return ret;
        }        
    }

    @AuraEnabled
    public static string getTransactionId(String recId){
        system.debug('recId::'+recId);
        String ret ='';
        try {
            Transaction__c trans = [SELECT id, Transaction_id__c from Transaction__c where id = :recId];
            ret = trans.Transaction_id__c;
            return ret;
        } catch (Exception e) {
            system.debug('in catch block'+e.getMessage());
            return ret;
        }
    }
}
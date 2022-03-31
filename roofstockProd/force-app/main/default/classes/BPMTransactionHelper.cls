public class BPMTransactionHelper {
    @AuraEnabled
    public static String customMetadata() {
        List<Roofstock__mdt> rsList = [SELECT Id,MasterLabel,BPM_URL__c FROM Roofstock__mdt];
        return rsList[0].BPM_URL__c;
    }
    
    @AuraEnabled
    public static Transaction__c transactionRecord(String currentRecId) {
        List<Transaction__c> transactionList = [SELECT Id,Transaction_Id__c,RecordTypeId,RecordType.Name,Portfolio_Transaction_Id__c FROM Transaction__c where Id=:currentRecId];
        return transactionList[0];
    }
    

}
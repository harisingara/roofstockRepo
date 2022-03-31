public class DisplayInvestmentAccController {
    
    @AuraEnabled
    public static String customMetadata() {
        List<Roofstock__mdt> rsList = [SELECT Id,MasterLabel,RS_One_URL__c FROM Roofstock__mdt where developername = 'Roofstock'];
        return rsList[0].RS_One_URL__c;
    }
    
    @AuraEnabled
    public static string taskRecord(String currentRecId) {
        system.debug('currentRecId'+currentRecId);
        String externaInvAccId = ''; 
        String sObjName = SchemaGlobalDescribe.findObjectNameFromRecordIdPrefix(currentRecId); 
            if(sObjName == 'Investment_Account__c'){
            	externaInvAccId = [SELECT Investment_Account_Id__c from Investment_Account__c where Id=:currentRecId].Investment_Account_Id__c;	    
            }
            else {
            	externaInvAccId = [SELECT Id,Investment_Account__r.Investment_Account_Id__c FROM ATF_Work_Queue__c where Id=:currentRecId].Investment_Account__r.Investment_Account_Id__c;  
            }
        
        return externaInvAccId;
    }
    

}
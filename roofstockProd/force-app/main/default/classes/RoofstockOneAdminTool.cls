public class RoofstockOneAdminTool {
    @AuraEnabled
    public static String adminToolUrl(String recordId){
        String adminToolURL = '';
        Map<String,String> rs1AdminTooMap = new Map<String,String>();
        Map<String, RS1_Admin_Tool_Mapping__mdt> rs1AdminToolSettings = RS1_Admin_Tool_Mapping__mdt.getAll();
		Roofstock__mdt roofstockSettings = Roofstock__mdt.getInstance('Roofstock');
        
        List<ATF_Work_Queue__c> workQueueList = [SELECT Id,RecordType.DeveloperName,Investment_Account__r.Investment_Account_Id__c FROM ATF_Work_Queue__c where Id=:recordId];  
        System.debug('-workQueueList-'+workQueueList[0].RecordType.DeveloperName);
        System.debug('-rs1AdminToolSettings1-'+rs1AdminToolSettings);
        System.debug('-rs1AdminToolSettings2-'+rs1AdminToolSettings.get(workQueueList[0].RecordType.DeveloperName));
        if(String.isNotBlank(workQueueList[0].Investment_Account__r.Investment_Account_Id__c) && (rs1AdminToolSettings.get(workQueueList[0].RecordType.DeveloperName)!=null)){
            adminToolURL = roofstockSettings.RS_One_URL__c+'/'+rs1AdminToolSettings.get(workQueueList[0].RecordType.DeveloperName).RS1_Type__c+'/'+workQueueList[0].Investment_Account__r.Investment_Account_Id__c;return adminToolURL;
        	
        }
        else if(String.isNotBlank(workQueueList[0].Investment_Account__r.Investment_Account_Id__c)){
        	 adminToolURL = roofstockSettings.RS_One_URL__c+'/fundInvestmentAccount/'+workQueueList[0].Investment_Account__r.Investment_Account_Id__c;
             return adminToolURL;
        }
        else{
            adminToolURL = roofstockSettings.RS_One_URL__c+'/fundInvestmentAccount';return adminToolURL;
        	
        }
                 
    }
    
}
public class BatchRetryOutboundCallout implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    List<Outbound_Message_Request__c> omrList = new List<Outbound_Message_Request__c>();
    public List<Outbound_Message_Request__c> start(Database.BatchableContext BC)
    {
        List<Outbound_Message_Request__c> res = [SELECT Id, HTTP_Endpoint__c, Auth_Token__c,Generate_New_Auth_Token__c,HTTP_Method__c , 
                                                        Request__c,Retry_Count__c, Named_Credential__c, NC_UserLabel__c, NC_PassLabel__c,Class_Name__c,Method_Name__c,Error_Description__c 
                                                   FROM Outbound_Message_Request__c 
                                                  WHERE Status__c = 'Retry - Pending' AND Retry_Count__c < 3]; 
        return res; 
    }
    public void execute(Database.BatchableContext BC, List<Outbound_Message_Request__c> lstDebugLogs)
    {
        System.debug('-lstDebugLogs-'+lstDebugLogs);
        List<Outbound_Message_Request__c> updateOMRList = new List<Outbound_Message_Request__c>();
        for(Outbound_Message_Request__c outBoundLogRequest : lstDebugLogs){
            updateOMRList.add(OutboundMessageRequestHelper.handleMyTaskStatusUpdateReqs(outBoundLogRequest));
        }
        System.debug('-updateOMRList-'+updateOMRList);
        if(!updateOMRList.isEmpty()){
        	update updateOMRList;
        }
                    
    }
    public void finish(Database.BatchableContext BC)
    {
        system.debug('Completed Batch Job');
    }
}
public class TrueDialogSMSApi {
    
    @InvocableMethod(label='Send SMS Thro True Dialog')
  	public static void triggerSMS(List <Id> recordIdList) {
        Set <Id> llruIdSet = new Set <Id> ();
        for(Id recId: recordIdList){
        	String sObjName = recId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Lead_Leasing_Rental_Unit__c'){
                llruIdSet.add(recId);
            }
        }
        if(llruIdSet != null && llruIdSet.size() >0){
            sendSMSCalloutLLru(llruIdSet);
        }
  	}
    @future(callout=true)
    public static void sendSMSCalloutLLru(Set <Id> llruIdSet) {
        
    
        List <Lead_Leasing_Rental_Unit__c> llruList = [SELECT Id, Lead__r.firstName, Lead__r.lastName, Lead__r.LeadSource,
                                                       Lead__r.phone, Rental_Listing__c, Rental_Listing__r.Property_Name__c , Rental_Listing__r.Rently_Property_Id__c  FROM Lead_Leasing_Rental_Unit__c
                                                       WHERE Id IN : llruIdSet];
        for(Lead_Leasing_Rental_Unit__c llru: llruList){
            System.debug('NDEBUG Lead Source :::' + llru.Lead__r.LeadSource);
            if(String.isNotBlank(llru.Lead__r.phone) 
               && String.isNotBlank(llru.Rental_Listing__r.Rently_Property_Id__c)
              && ((llru.Lead__r.LeadSource == 'zillowgroup') || (llru.Lead__r.LeadSource == 'Rently'))){
                String leadName = '';
                if(llru.Lead__r.firstName != 'UNKNOWN'){
                    leadName = llru.Lead__r.firstName + ' ' +  llru.Lead__r.lastName  +'!';                
                }
                leadName = leadName.replace('And ', '');
				leadName = leadName.replace(' Is Interested In A', '');
                // Get the Static Resource
                StaticResource SmsTemplate =  [SELECT Id, name, body FROM StaticResource WHERE NAME = 'LeasingSMSTemplate' limit 1]; 
                String smsBody = SmsTemplate.Body.toString();
                smsBody = smsBody.replace('LEADNAME', leadName);
                String listing = 'https://homes.rently.com/homes-for-rent/properties/' + llru.Rental_Listing__r.Rently_Property_Id__c;
                smsBody = smsBody.replace('LISTING', llru.Rental_Listing__r.Property_Name__c );
                smsBody = smsBody.replace('RENTLYLINK', listing);
                String formattedPh = formatPhone(llru.Lead__r.phone);
                String reqBody = createJsonReqBody('Leasing', formattedPh, smsBody);
                
                // Trigger the SMS
                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:TrueDialogLeasing');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Accept', 'application/json');
                req.setBody(reqBody);
                Http http = new Http();
                if(!Test.isRunningTest() && (System.Label.Enable_Leasing_SMS == 'Yes')){
                    List<Outbound_Message_Request__c> omrList = new List<Outbound_Message_Request__c>();
                    HTTPResponse res = http.send(req);
                    System.debug(res.getBody());
                    if(res.getStatusCode() != 200 && res.getStatusCode() != 201) {
                        Outbound_Message_Request__c omr = OutboundMessageRequestHelper.logOutboundRetryRequest(req,'Trigger SMS');
                        omr.Status__c = 'Retry - Pending';
                        omr.Generate_New_Auth_Token__c = false;
                        omr.HTTP_Status_Code__c = res.getStatusCode();
                        omr.Named_Credential__c = 'TrueDialogLeasing';
                        omr.NC_PassLabel__c = 'Api-Key';
                        omrList.add(omr);
                    }
                    if(!omrList.isEmpty()) {
                    	INSERT omrList;
                	}
                }
            }  
        }        
    }
    
    public static string createJsonReqBody(String context, String targetPh, String smsBody){
        Map <String, Object> valMap = new Map <String, Object> ();
        List <String> channelList = new List <String> ();
        if(context == 'Leasing'){
            channelList.add(getChannelVal().get(context));
            System.debug('NDEBUG Channel :::' + channelList);
        }
        valMap.put('Channels', channelList);
        List <String> targetPhList = new List <String> ();
        targetPhList.add(targetPh);
        valMap.put('Targets', targetPhList);
        valMap.put('Message', smsBody);
        valMap.put('Execute', 'true');
        return(JSON.serialize(valMap));
    }
    
    public static string formatPhone(String phoneNumber){
        String fphone = '';        
        fphone = phoneNumber.replaceAll('\\D','');
        fphone = fphone.right(10);
        fphone = '+1'+fphone;return fphone;
    }
    
    public static Map <String, String> getChannelVal(){
        Map <String, String> channelMap = new Map <String, String> ();
        for (True_Logic_Channel_Mappings__mdt  tlMapping : [SELECT Id, Context__c, Channel_Value__c FROM True_Logic_Channel_Mappings__mdt]) {
    		channelMap.put(tlMapping.Context__c, tlMapping.Channel_Value__c);
		}
        return channelMap;       
    }
}
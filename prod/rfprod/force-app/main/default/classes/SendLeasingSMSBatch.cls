/* Class Name - SendLeasingSMSBatch
 * Author - Naveen Mittapalli
 * Description - Batch class which sends callout to send SMS thro True Dialog Endpoint.
 * Test Class - SendLeasingSMSBatchTest
 * ******************************************************************************************
 * 
 * Date			Name			Comments
 * 03-28-2022	Naveen			Created Batch for Leasing SMS callout
 * 
 */
global with sharing class SendLeasingSMSBatch implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts{
    

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        
        //String Query = 'SELECT Id, Property__c, Pool_Name__c, Product__c, Branch_Id__c, Status__c, Type_of_BPO_Trigger__c FROM Broker_Price_Opinion__c WHERE  Status__c = \'Confirmed\'';
        String Query = 'SELECT Id, Response__c, Retry_Count__c, Status__c, Lead__c, Lead__r.firstName, Lead__r.lastName, Lead__r.LeadSource, Lead__r.phone, Rental_Listing__c, Rental_Listing__r.Property_Name__c , Rental_Listing__r.Rently_Property_Id__c from Lead_Leasing_Rental_Unit__c WHERE (Status__c = \'New\' OR Status__c = \'Send SMS\')AND Converted_To_Opp__c = FALSE AND Lead__r.phone != \'\' AND ( Lead__r.Leadsource = \'Rently\' OR Lead__r.Leadsource =\'zillowgroup\' OR Lead__r.Leadsource =\'Trulia\' OR Lead__r.Leadsource =\'Streeteasy\' OR Lead__r.Leadsource =\'Hotpads\') AND ( Retry_Count__c = null OR Retry_Count__c < 20)';
        return Database.getQueryLocator(Query);
          
    }

    global void execute(Database.BatchableContext bc, List<Lead_Leasing_Rental_Unit__c> llruList)
    {
        List <Lead_Leasing_Rental_Unit__c> updLruList = new List <Lead_Leasing_Rental_Unit__c> ();
        for(Lead_Leasing_Rental_Unit__c llru : llruList){
            if(String.isNotBlank(llru.Lead__r.phone) 
               && String.isNotBlank(llru.Rental_Listing__r.Rently_Property_Id__c)
              && ((llru.Lead__r.LeadSource == 'zillowgroup') || (llru.Lead__r.LeadSource == 'Rently')) ){
                  String leadName = '';
                  if(llru.Lead__r.firstName != 'UNKNOWN'){
                      leadName = llru.Lead__r.firstName + ' ' +  llru.Lead__r.lastName  +'!';                
                  }
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
                  HTTPResponse resp;
                  if(!Test.isRunningTest()){
                      resp = http.send(req);
                      System.debug(resp.getBody());
                  }
                  else{
                      resp = new HttpResponse();
                      resp.setHeader('Content-Type', 'application/json');
                      resp.setBody('{"isSuccessful":true,"error":null}');
                      resp.setStatusCode(200);                      
                  }
                  
                  String response = '';
                  if(resp.getStatusCode() != 200 && resp.getStatusCode() != 201) {
                      Decimal retryCount = 0;
                      
                      if(llru.Retry_Count__c != null){
                          retryCount = llru.Retry_Count__c ;
                      }
                      retryCount++;
                      if(String.isBlank(llru.Response__c)){
                          response = String.valueOf(resp);
                      }
                      else{
                          response = String.valueOf(resp) + '\n' + llru.Response__c; 
                      }
                      updLruList.add(new Lead_Leasing_Rental_Unit__c(Id = llru.Id, Retry_Count__c = retryCount, Response__c = response));
                  }
                  else{
                      if(String.isBlank(llru.Response__c)){
                          response = String.valueOf(resp);
                      }
                      else{
                          response = String.valueOf(resp) + '\n' + llru.Response__c; 
                      }
                      updLruList.add(new Lead_Leasing_Rental_Unit__c(Id = llru.Id, Status__c = 'SMS Sent', Response__c = response));
                  }
                  
              }
        	
        }
        if(updLruList != null && updLruList.size() >0){
            update updLruList;
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

    global void finish(Database.BatchableContext bc){

    }
    
    global void execute (SchedulableContext SC) {
        Database.executeBatch(new SendLeasingSMSBatch(),1);
    }
}
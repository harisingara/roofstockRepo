global class RESTPlanomaticCreateOrderHelper {
    global class PlanomaticWrap{
        global Planomatic photoOrder;
    }
    global class Planomatic{
        global String orderedOnUtc;
        global String scheduledOnUtc;
        global String completedOnUtc;
        global String status;
        global String externalId;
        global String orderId;
        global String requestId;
        global String errorMessage;
    }
    
    global class ResponseBody{
        global String orderId;
        global String salesforceId;
        global ResponseBody(String orderId, String salesforceId) {
            this.orderId = orderId;
            this.salesforceId = salesforceId;
        }
    }
    global class ResponseWrapper {  
        global ResponseBody planomaticResponse;  
        global ResponseWrapper(ResponseBody planomaticResponse){
            this.planomaticResponse = planomaticResponse;
        }
        
    } 
    global class PostResponse {
        global ResponseWrapper responseBody;
        global PostResponse(ResponseBody planomaticResponse) {
            this.responseBody = new ResponseWrapper(planomaticResponse);
        }
        
    }
    global static PostResponse updatePlanomaticOrder(Planomatic reqPhotoOrder){
        
        Map<String,String> statusCodeMap = new Map<String,String>();
        statusCodeMap.put('0','Unspecified');
        statusCodeMap.put('290016010','Requested');
        statusCodeMap.put('290016020','Ordered');
        statusCodeMap.put('290016030','Scheduled');
        statusCodeMap.put('290016035','Assembly');
        statusCodeMap.put('290016040','Notified');
        statusCodeMap.put('290016050','Completed');
        statusCodeMap.put('290016055','Hold');
        statusCodeMap.put('290016060','Cancelled');
        statusCodeMap.put('290016070','SubmittedCancelOnsite');
        statusCodeMap.put('290016071','PendingAppointment');
        statusCodeMap.put('290016072','ReadyToSchedule');
        statusCodeMap.put('290016073','Committed');
        statusCodeMap.put('290016080','OrderError');
        statusCodeMap.put('290016090','DataFeedError');
        
        List<ResponseBody> planomaticResponseList = new List<ResponseBody>();
        
        List<Planomatic_Order__c> matchingplanomaticList = [SELECT Id,Rental_Listing__c,Date_Ordered__c,Date_Photos_Complete__c,submitted_Cancel_Onsite__c,
                                                                   Date_Scheduled__c,Date_Taken__c,Status__c,Order_Id__c,Request_Id__c 
                                                              FROM Planomatic_Order__c 
                                                             WHERE Request_Id__c =:reqPhotoOrder.requestId];
        
        System.debug('-matchingplanomaticList-'+matchingplanomaticList);
        if(!matchingplanomaticList.isEmpty()){
            for(Planomatic_Order__c matchingPlanoResp : matchingplanomaticList){
                
                    if(!String.isBlank(reqPhotoOrder.orderId)){
                        matchingPlanoResp.Order_Id__c = reqPhotoOrder.orderId;
                    }
                    if(!String.isBlank(reqPhotoOrder.status)){
                        //matchingPlanoResp.Status__c = reqPhotoOrder.status;
                        matchingPlanoResp.Status__c = statusCodeMap.get(reqPhotoOrder.status);
                    }
                	if(!String.isBlank(reqPhotoOrder.errorMessage)){
                        matchingPlanoResp.Description__c = reqPhotoOrder.errorMessage;
                    }
                    if(!String.isBlank(reqPhotoOrder.orderedOnUtc)){
                        //matchingPlanoResp.Date_Ordered__c = Datetime.valueOf(reqPhotoOrder.orderedOnUtc);
                        matchingPlanoResp.Date_Ordered__c = (DateTime)JSON.deserialize('"' + reqPhotoOrder.orderedOnUtc + '"', DateTime.class);

                    }
                    if(!String.isBlank(reqPhotoOrder.scheduledOnUtc)){
                        //matchingPlanoResp.Date_Scheduled__c = Datetime.valueOf(reqPhotoOrder.scheduledOnUtc);
                        matchingPlanoResp.Date_Scheduled__c = (DateTime)JSON.deserialize('"' + reqPhotoOrder.scheduledOnUtc + '"', DateTime.class);
                        
                    }
                    
                    if(!String.isBlank(reqPhotoOrder.completedOnUtc)){
                        //matchingPlanoResp.Date_Photos_Complete__c = Datetime.valueOf(reqPhotoOrder.completedOnUtc);
                        matchingPlanoResp.Date_Photos_Complete__c = (DateTime)JSON.deserialize('"' + reqPhotoOrder.completedOnUtc + '"', DateTime.class);
                        
                    }
                    if(!String.isBlank(reqPhotoOrder.status) && reqPhotoOrder.status == '290016070') {
                        matchingPlanoResp.submitted_Cancel_Onsite__c =  true;
                    }
                    
                
                
            }
            
            update matchingplanomaticList;
            List<Rental_Listing__c> laList = new List<Rental_Listing__c>();
            if(!matchingplanomaticList.isEmpty()){
            	for(Planomatic_Order__c po : matchingplanomaticList){
                	Rental_Listing__c la = new Rental_Listing__c();
                	la.Id = po.Rental_Listing__c;
                	if(reqPhotoOrder.orderedOnUtc <> null && reqPhotoOrder.orderedOnUtc != '') {
                        la.Photos_Ordered__c = Date.valueOf(po.Date_Ordered__c);
                    }
                    if(reqPhotoOrder.completedOnUtc <> null && reqPhotoOrder.completedOnUtc != '') {
                        la.Photos_Received__c = Date.valueOf(po.Date_Photos_Complete__c);
                    }
                    la.Photo_Status__c = statusCodeMap.get(reqPhotoOrder.status);
                	laList.add(la);
            	}
                System.debug('rental listing details to be updated::'+laList);
            }
            if(!laList.isEmpty()){
                update laList;
            }
        }        
		System.debug('-matchingplanomaticList-'+matchingplanomaticList);
        if(!matchingplanomaticList.isEmpty()){
        	for(Planomatic_Order__c planResponse : matchingplanomaticList){
            	planomaticResponseList.add(new ResponseBody(planResponse.Order_Id__c, planResponse.Id));     
            
        	}
        }
        postResponse res;
        System.debug('-planomaticResponseList-'+planomaticResponseList);
        if(!planomaticResponseList.isEmpty()){
            res = new postResponse(planomaticResponseList[0]);
            return res;
        }
        else{
            res = new postResponse(new ResponseBody('', ''));
            return res;
        }
  
    }
    
    
}
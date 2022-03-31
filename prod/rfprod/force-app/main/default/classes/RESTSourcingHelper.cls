global class RESTSourcingHelper {
    global class SourcingWrap{
        global List<Sourcing> sourcingList;
    }
    global class Sourcing{
        global String firstName;
        global String lastName;
        global String phone;
        global String email;
        global String state;
        global String market;
        global String requestType;
    }
    global class PostResponse {
        global ResponseWrapper responseBody;
        global PostResponse(List<ResponseBody> sourcingResponse) {
            this.responseBody = new ResponseWrapper(sourcingResponse);
        }
    }
    global class ResponseWrapper {  
        global List<ResponseBody> sourcingResponse;  
        global ResponseWrapper(){
            sourcingResponse = new List<ResponseBody>();
        }
        global ResponseWrapper(List<ResponseBody> sourcingResponse) {
            this.sourcingResponse = sourcingResponse;
        }
    } 
    global class ResponseBody{
        global String sourcingId;
        global String email;
        global ResponseBody(String sourcingId,String email) {
            this.sourcingId = sourcingId;
            this.email = email;
        }
    }
    global static PostResponse updateSourcing(List<Sourcing> sourcingList) {
        List<Sourcing__c> lstSourcing = new List<Sourcing__c>();
        List<ResponseBody> sourcingResponseList = new List<ResponseBody>();
        Set<String> setEmail = new Set<String>();
        Set<String> setPhone = new Set<String>();
        Map<String,Sourcing> mapPhoneEmailRequestSourcing = new Map<String,Sourcing>(); 
        Map<String,Sourcing__c> mapPhoneEmailRecordSourcing = new Map<String,Sourcing__c>(); 
        List<Sourcing__c> lstSourcingCreate = new List<Sourcing__c>();
        List<Sourcing__c> lstSourcingUpdate = new List<Sourcing__c>();
        Id sourceOwner = [select Id from User where Name=:Label.Sourcing_Owner].Id;

        for(Sourcing source : sourcingList){
            if(source.email != null) {
                setEmail.add(source.email);
            }
            if(source.phone!= null) {
                setPhone.add(source.phone);
            }
            if(source.email != null && source.phone!= null) {
                mapPhoneEmailRequestSourcing.put(source.phone+'-'+source.email,source);     
            }            
        }
        Map<Id,Sourcing__c> mapMatchingSourcing = new Map<Id,Sourcing__c>([Select Id,Name,Phone_Number__c,Email__c,States__c from Sourcing__c where (Email__c IN :setEmail and Phone_Number__c IN :setPhone)]);
        if(!mapMatchingSourcing.isEmpty()) {
            for(Sourcing__c source : mapMatchingSourcing.values()){ 
                mapPhoneEmailRecordSourcing.put(source.Phone_Number__c+'-'+source.Email__c,source);
            }
                
        }
        for(String sourcingRequest : mapPhoneEmailRequestSourcing.keySet()) {
             Boolean existing = false;
             if(!mapPhoneEmailRecordSourcing.isEmpty()) {
                 if(mapPhoneEmailRecordSourcing.get(sourcingRequest)!=null){
                    Sourcing__c updateSourcing = upsertSourcing(mapPhoneEmailRecordSourcing.get(sourcingRequest),mapPhoneEmailRequestSourcing.get(sourcingRequest),sourceOwner);                        
                    lstSourcingUpdate.add(updateSourcing);
                     existing = true; 
                 }
            }
            if(existing == false) {
                    Sourcing__c updateSourcing = upsertSourcing(null,mapPhoneEmailRequestSourcing.get(sourcingRequest),sourceOwner); 
                    lstSourcingCreate.add(updateSourcing);
            }
        }
        
        if(!lstSourcingUpdate.isEmpty()){
            update lstSourcingUpdate;     
        }
        if(!lstSourcingCreate.isEmpty()){
            insert lstSourcingCreate;
        }
        lstSourcing.addAll(lstSourcingUpdate);
        lstSourcing.addAll(lstSourcingCreate);
        for(Sourcing__c source : lstSourcing) {
            sourcingResponseList.add(new ResponseBody(source.Id,source.Email__c));                 
        }
        postResponse res = new postResponse(sourcingResponseList);
        return res;        
    }
    
    public static Sourcing__c upsertSourcing(Sourcing__c source,Sourcing requestSource,Id sourceOwner) {
        Sourcing__c sr = new Sourcing__c();
        if(source!=null){
            sr.Id = source.Id;            
        }
        sr.Name = requestSource.firstName+' '+requestSource.lastName;
        sr.Email__c = requestSource.email;
        sr.Phone_Number__c = requestSource.phone;
        sr.States__c = requestSource.state; 
        sr.ownerId = sourceOwner;
        sr.Type_of_Request__c = requestSource.requestType;
        sr.Markets__c = requestSource.market;
        return sr;        
    }
    
}
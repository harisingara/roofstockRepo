global class RESTMCLeadHelper {
    global class LeadsWrap{
        global List<Leads> leadList;
    }
    global class Leads{
        global String CompanyName;
        global String Email;
        global String firstName;
        global String lastName;
        global String phone;
        global String rsAccountId;
        global String rsUserId;
        global String leadSource;
        global String leadInterest;
        
    }
    global class ResponseBody{
        global String salesforceId;
        global String email;
        global String status;
        global ResponseBody(String salesforceId,String email, String status){
            this.salesforceId = salesforceId;
            this.email = email;
            this.status = status;
            
        }
    }
    global class ResponseWrapper {  
        global List<ResponseBody> leadResponse;  
        global ResponseWrapper(){
            leadResponse = new List<ResponseBody>();
        }
        global ResponseWrapper(List<ResponseBody> leadResponse) {
            this.leadResponse = leadResponse;
        }
    } 
    global class PostResponse{
        global ResponseWrapper responseBody;
        global PostResponse(List<ResponseBody> leadResponse){
            this.responseBody = new ResponseWrapper(leadResponse);
        }
    }
    global static PostResponse createLead(List<Leads> mcLeadList) {
        List<ResponseBody> leadResponseList = new List<ResponseBody>();
        
        /* Create Map of Lead Record Type */
        /*    
Map<String,String> leadRecTypeMap = new Map<String,String>();
Map<String,String> LeadInterestRecTypeMap = new Map<String,String>();
List<RecordType> recTypeList = [select Id,Name from Recordtype where sObjectType='Lead'];
for(RecordType rt :recTypeList){
leadRecTypeMap.put(rt.Name,rt.Id);    
}
/*LeadSource Recordtype Map from custom metadata 
Lead_Interest_Record_Type_Map__mdt[] leadInterestRecTypes = [SELECT MasterLabel,LeadRecordType__c FROM Lead_Interest_Record_Type_Map__mdt];
for(Lead_Interest_Record_Type_Map__mdt liRT : leadInterestRecTypes){
LeadInterestRecTypeMap.put(liRT.MasterLabel,liRT.LeadRecordType__c);    
}
*/
        
        Set<String> emailList = new Set<String>();
        Set<String> phoneList = new Set<String>();
        /*Read the input string to check existing lead*/
        List<Leads> newMCLeadList = new List<Leads>();
        Map<String,Leads> emailMap = new Map<String,Leads>();
        Map<String,Leads> phoneMap = new Map<String,Leads>();
		Id rsOneRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Roofstock One').getRecordTypeId();        
        for(Leads inputLead : mcLeadList){
            emailMap.put((inputLead.Email).toLowerCase(),inputLead);
            phoneMap.put(inputLead.phone,inputLead);
            
            if(inputLead.Email!=null && inputLead.Email!=''){
                emailList.add((inputLead.Email).toLowerCase());  
            }
            if(inputLead.Phone!=null && inputLead.Phone!=''){
                phoneList.add(inputLead.phone);  
            }

        }
        
        list<Lead> matchingLead = new list<Lead>();
        Set<String> emailSet = new Set<String>();
        Set<String> phoneSet = new Set<String>();
        if(emailList.size()>0 || phoneList.size() > 0){
            matchingLead = [select Id,LastName,Email,Phone,MobilePhone from Lead where (Email IN:emailList OR Phone IN:phoneList OR mobilePhone IN:phoneList)];  
            for(Lead matchLead :matchingLead){
            	emailSet.add((matchLead.Email).toLowerCase());
                phoneSet.add(matchLead.Phone);
                phoneSet.add(matchLead.MobilePhone);
            }
        }
        
        for(Leads lds : mcLeadList){
        	if(!emailSet.contains((lds.Email).toLowerCase()) && !phoneSet.contains(lds.phone)){
            	newMCLeadList.add(lds); 
        	}
        }
   		System.debug('=newMCLeadList='+newMCLeadList);
        /* Read Input String to create new lead record*/
        List<Lead> newLeadList = new List<Lead>();
        if(!newMCLeadList.isEmpty()){
            for(Leads mcLead : newMCLeadList){
                Lead newLead = new Lead();
                if(mcLead.CompanyName!=null){
                    newLead.Company = mcLead.CompanyName;
                }
                if(mcLead.Email!=null){
                    newLead.Email = mcLead.Email;
                }
                if(mcLead.firstName!=null){
                    newLead.FirstName = mcLead.firstName;
                }
                if(mcLead.lastName!=null){
                    newLead.LastName = mcLead.lastName;
                }
                if(mcLead.phone!=null){
                    newLead.Phone = mcLead.phone;
                    newLead.MobilePhone = mcLead.phone;
                }
                if(mcLead.rsAccountId!=null){
                    newLead.Roofstock_Account_ID__c = mcLead.rsAccountId;
                }
                if(mcLead.rsUserId!=null){
                    newLead.Roofstock_User_Id__c = mcLead.rsUserId;
                }
                if(mcLead.leadSource!=null){
                    newLead.LeadSource = mcLead.leadSource;
                    
                }
                if(mcLead.leadInterest!=null){
                    newLead.Lead_Interest__c = mcLead.leadInterest;
                    if(mcLead.leadInterest == 'Roofstock One'){
                        newLead.RecordTypeId = rsOneRecordTypeId;
                    }
                    //String recTypeId = leadRecTypeMap.get(LeadInterestRecTypeMap.get(mcLead.leadInterest));
                    // newLead.RecordTypeId = recTypeId; 
                }
                
                newLeadList.add(newLead);
            }
        }
        
        
        if(!newLeadList.isEmpty()){
            insert newLeadList;
        }
        //Creating Response
        System.debug('=matchingLead='+matchingLead);
        if(!matchingLead.isEmpty()){
            for(Lead existingLead : matchingLead){
                leadResponseList.add(new ResponseBody(existingLead.Id,existingLead.Email,'Skipped'));     
            }
        }
        System.debug('=newLeadList='+newLeadList);
        if(!newLeadList.isEmpty()){
            for(Lead newLead:newLeadList){
                System.debug('=newLead='+newLead.Id);
                leadResponseList.add(new ResponseBody(newLead.Id,newLead.Email,'created'));     
            }
        }
        System.debug('=leadResponseList='+leadResponseList);
        postResponse res = new postResponse(leadResponseList);
        return res;
        
    }
}
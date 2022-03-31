global class RESTCaseHelper {
    global class caseWrap{
        global Cases case_x;
    }
    global class Cases{
        global String type;
        global String externalId;
        global String subject;
        global String description;
        global String firstName;
        global String lastName;
        global String email;
        global String phone;
        global String contactId;
        global String accountId;
        global String ownerEmailAddress;
        global String reasonForContact;
    }
    global class ResponseBody{
        global String salesforceId;
        global ResponseBody(String salesforceId) {
            this.salesforceId = salesforceId;
        }
    }
    global class ResponseWrapper {  
        global ResponseBody caseResponse;  
        global ResponseWrapper(ResponseBody caseResponse) {
            this.caseResponse = caseResponse;
        }
    }
    global class PostResponse {
        global ResponseWrapper responseBody;
        global PostResponse(ResponseBody caseResponse) {
            this.responseBody = new ResponseWrapper(caseResponse);
        }
    }
    
    global static PostResponse createCase(Cases requestCase) {
        List<RecordType> recTypeList = [select Id,Name from Recordtype where sObjectType='Case'];
        Map<String,String> recTypeMap = new Map<String,String>();
        List<Account> matchingAccountList = new List<Account>();
        List<Contact> matchingContactList = new List<Contact>();
        List<User> matchingUsrList =new List<User>();
        //Create RecordType Map
        for(RecordType rt :recTypeList){
            recTypeMap.put((rt.Name).toLowerCase(),rt.Id);      
        }
        //Query Queue
        List<Group> tcGroupQueueList = [select Id from Group where Name = 'TC Queue' and Type = 'Queue'];
        
        if(requestCase.ownerEmailAddress!=null){
            matchingUsrList = [select Id from User where Email=:requestCase.ownerEmailAddress limit 1];     
        }
        if(requestCase.accountId!=null){
            matchingAccountList = [Select Id,Roofstock_Account_ID__c from Account where Roofstock_Account_ID__c=:requestCase.accountId Limit 1];    
        }
        if(requestCase.contactId!=null){
            matchingContactList = [Select Id,BPM_Contact_Id__c from Contact where BPM_Contact_Id__c=:requestCase.contactId Limit 1];    
        }
        if(matchingContactList.size()== 0 && requestCase.email!=null){
            matchingContactList = [Select Id,Email from Contact where Email=:requestCase.email Limit 1];        
        }
        if(matchingContactList.size()== 0 && requestCase.phone!=null){
            matchingContactList = [Select Id,Phone from Contact where Phone=:requestCase.phone Limit 1];        
        }
        Case newCase;
        if((requestCase.type).toLowerCase() == 'transaction'){
            List<Transaction__c> trans = [Select Id,Roofstock_TC_User__c from Transaction__c where Transaction_Id__c =:requestCase.externalId Limit 1];
            newCase  = createCase(matchingAccountList,matchingContactList,matchingUsrList,recTypeMap,requestCase);
            newCase.Origin = 'Web To Case';
            if(requestCase.reasonForContact!=null){
                if(requestCase.reasonForContact == 'Property Manager'){
                    newCase.Case_Type__c = 'Property Management';
                }
                else if(requestCase.reasonForContact == 'Appraisal Contingency' || requestCase.reasonForContact == 'Inspection Contingency'){
                    newCase.Case_Type__c = 'Contingency Deadline';
                }
                else if(requestCase.reasonForContact == 'Other'){
                    newCase.Case_Type__c = 'Buyer Question';
                }
                else{
        			newCase.Case_Type__c = requestCase.reasonForContact; 
                }
        	}
            if(trans.size()>0){
                newCase.Transaction__c = trans[0].Id;
                newCase.Assigned_Team__c ='Transactions';
                if(!String.isBlank(trans[0].Roofstock_TC_User__c)){
                	//newCase.OwnerId = trans[0].Roofstock_TC_User__c;
                }
                else if(tcGroupQueueList[0]!=null){
                   // newCase.OwnerId = tcGroupQueueList[0].Id;
                }
            }
            insert newCase;
        }
        else if((requestCase.type).toLowerCase() == 'certification'){
            List<Certification__c> cert = [Select Id from Certification__c where BPM_Certification_Id__c=:requestCase.externalId Limit 1];
            newCase  = createCase(matchingAccountList,matchingContactList,matchingUsrList,recTypeMap,requestCase);
            if(cert.size()>0){
                newCase.Certification__c = cert[0].Id;
            }
            if(matchingUsrList.size()>0){
            	newCase.OwnerId = matchingUsrList[0].Id;
        	}
            insert newCase;
        }
        //ResponseWrapper rw = new ResponseWrapper(new ResponseBody(newCase.Id));
        PostResponse pr = new PostResponse(new ResponseBody(newCase.Id));
        return pr;
    }
    global static Case createCase(List<Account> acc,List<Contact> con, List<User> usr,Map<String,String> recTypeMap,Cases requestCase){
        Case cse = new Case();
        if(acc.size()>0){
            cse.AccountId = acc[0].Id;
        }
        if(con.size()>0){
            cse.ContactId = con[0].Id;    
        }
        /*if(usr.size()>0){
            cse.OwnerId = usr[0].Id;
        }
		*/
        
        cse.RecordTypeId = recTypeMap.get((requestCase.type).toLowerCase()); 
        cse.Status = 'New';
        cse.Subject = requestCase.subject;
        cse.Description = requestCase.description;
        return cse;
        
    }
    
}
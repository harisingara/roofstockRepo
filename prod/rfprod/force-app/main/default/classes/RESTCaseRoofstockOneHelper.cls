global class RESTCaseRoofstockOneHelper {
    global class CaseRSOneWrap {
        global List<CaseRSOne> caseRSOneList;
    }
    global class CaseRSOne{
        global String type;
        global String externalId;
        global String subject;
        global String description;
        global String firstNme;
		global String lastName;        
        global String email;
        global String phone;
        global String contactId;
        global String accountId;
        global String ownerEmailAddress;
        global String reasonForContact;
        
    }
    
    global class PostResponse {
        global ResponseWrapper responseBody;
        global PostResponse(List<ResponseBody> caseResponse) {
            this.responseBody = new ResponseWrapper(caseResponse);
        }
    }
    
    global class ResponseWrapper{
        global List<ResponseBody> caseResponse;
        global ResponseWrapper(List<ResponseBody> caseResponse) {
            this.caseResponse = caseResponse;
        }
    }
    
    global class ResponseBody{
        global String externalId;
        global String salesforceId;
        global String statusMsg;
        global ResponseBody(String externalId,String salesforceId,String statusMsg) {
            this.externalId = externalId;
            this.salesforceId = salesforceId;
            this.statusMsg = statusMsg;
        }
    }    
    
    
    global static PostResponse createCaseRSOne(List<CaseRSOne> requestCaseList) {
        List<ResponseBody> caseResponseList = new List<ResponseBody>();
        List<Case> caseList = new List<Case>();
        Set<String> emailSet = new Set<String>();
        Set<String> phoneSet = new Set<String>();
        Set<String> contactIdSet = new Set<String>();
        Set<String> accoutIdSet = new Set<String>();
        Set<String> externalIdSet = new Set<String>();
        
        Map<String,Contact> bpmContactIdContactMap = new Map<String,Contact>();
        Map<String,Contact> emailContactMap = new Map<String,Contact>();
        Map<String,Contact> phoneContactMap = new Map<String,Contact>();
        
        Map<String,Lead> bpmContactIdLeadMap = new Map<String,Lead>();
        Map<String,Lead> emailLeadMap = new Map<String,Lead>();
        Map<String,Lead> phoneLeadMap = new Map<String,Lead>();
        
        Map<String,Account> rsAccountMap = new Map<String,Account>();
        Map<String,Investment_Account__c> iaAccountIdIAMap = new Map<String,Investment_Account__c>();
        List<Contact> matchingContactList = new List<Contact>();
        List<Lead> matchingLeadList = new List<Lead>();
        List<Account> matchingAccountList = new List<Account>();
        List<Investment_Account__c> matchingInvestmentAccountList = new List<Investment_Account__c>();
        
        Id caseRSOneRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Roofstock One').getRecordTypeId();
        List<Group> rsOneQueueList = [select Id from Group where Name = 'Roofstock One' and Type = 'Queue'];
        //Prepare Data
        for(CaseRSOne req : requestCaseList) {
            if(req.email !=null && req.email != ''){
                emailSet.add(req.email);
            }
            if(req.phone!=null && req.phone != ''){
                phoneSet.add(req.phone);
            }
            if(req.contactId !=null && req.contactId != ''){
                contactIdSet.add(req.contactId);
            }
            if(req.accountId !=null && req.accountId != ''){
                accoutIdSet.add(req.accountId);
            }
            if(req.externalId!=null){
                externalIdSet.add(req.externalId);
            }
        }
        
        if(contactIdSet.size() > 0 || emailSet.size()  > 0 || phoneSet.size() > 0){
        matchingContactList = [select Id,Email,Phone,mobilePhone,BPM_Contact_Id__c from Contact where (BPM_Contact_Id__c IN:contactIdSet OR Email IN:emailSet OR phone IN:phoneSet OR mobilePhone IN:phoneSet)];
        matchingLeadList = [select Id,Email,Phone,mobilePhone,BPM_Contact_Id__c from Lead where (BPM_Contact_Id__c IN:contactIdSet OR Email IN:emailSet OR phone IN:phoneSet OR mobilePhone IN:phoneSet)];
        }
        if(accoutIdSet.size() > 0){
            matchingAccountList = [select Id,Roofstock_Account_ID__c from Account where Roofstock_Account_ID__c IN:accoutIdSet];
        }
        if(externalIdSet.size() > 0){
        matchingInvestmentAccountList = [select Id,Investment_Account_Id__c from Investment_Account__c where Investment_Account_Id__c IN:externalIdSet];
        }
        
        if(!matchingContactList.isEmpty()){
            for(Contact con :matchingContactList) {
                if(con.BPM_Contact_Id__c!=null){
                    bpmContactIdContactMap.put(con.BPM_Contact_Id__c,con);
                }
                if(con.Email!=null){
                    emailContactMap.put(con.Email,con);
                }
                if(con.Phone!=null){
                    phoneContactMap.put(con.Phone,con);
                }
                if(con.mobilePhone!=null){
                    phoneContactMap.put(con.mobilePhone,con);
                }
            }
        }
        
        if(!matchingLeadList.isEmpty()){
            for(Lead ld :matchingLeadList) {
                if(ld.BPM_Contact_Id__c!=null){
                    bpmContactIdLeadMap.put(ld.BPM_Contact_Id__c,ld);
                }
                if(ld.Email!=null){
                    emailLeadMap.put(ld.Email,ld);
                }
                if(ld.Phone!=null){
                    phoneLeadMap.put(ld.Phone,ld);
                }
                if(ld.mobilePhone!=null){
                    phoneLeadMap.put(ld.mobilePhone,ld);
                }
            }
        }
        
        if(!matchingAccountList.isEmpty()){
            for(Account acc : matchingAccountList){
                rsAccountMap.put(acc.Roofstock_Account_ID__c,acc);
            }
        }
        if(!matchingInvestmentAccountList.isEmpty()){
            for(Investment_Account__c ia : matchingInvestmentAccountList){
                iaAccountIdIAMap.put(ia.Investment_Account_Id__c,ia);
            }
            
        }
        List<CaseRSOne> errorCaseList = new List<CaseRSOne>();
        for(CaseRSOne inputRequestCase : requestCaseList) {
            Case cse = createCase(inputRequestCase,caseRSOneRecordTypeId,rsOneQueueList[0].Id,
                                  bpmContactIdLeadMap,emailLeadMap,phoneLeadMap,
                                  bpmContactIdContactMap,emailContactMap,phoneContactMap,
                                  rsAccountMap,iaAccountIdIAMap);    
            //PE-646 - 
            if(!String.isEmpty(cse.Investment_Account__c) || !String.isEmpty(cse.AccountId) || !String.isEmpty(cse.Lead__c)){
            	caseList.add(cse);
            }
            else{
                errorCaseList.add(inputRequestCase);
                
            }
        }
        
        if(!caseList.isEmpty()){
            insert caseList;
        }
        Map<Id,Case> objNewCaseMap = new Map<Id,Case>([Select Id,Investment_Account__r.Investment_Account_Id__c from Case where Id IN:caseList]);
        for(Case newCse:caseList){
            //trans.Case_Thread_Id__c = null;
            caseResponseList.add(new ResponseBody(objNewCaseMap.get(newCse.Id).Investment_Account__r.Investment_Account_Id__c,newCse.Id,'Success!'));     
        }
        if(!errorCaseList.isEmpty()){
            for(CaseRSOne req:errorCaseList){
            	caseResponseList.add(new ResponseBody(req.externalId,'','Account/Lead not found!'));     
            }
        }
        System.debug('=caseResponseList='+caseResponseList);
        postResponse res = new postResponse(caseResponseList);
        return res;
        
        
        
    }
    
    global static Case createCase(CaseRSOne requestCase,String recType,String rsQueue,
                                  Map<String,Lead> bpmContactIdLeadMap,Map<String,Lead> emailLeadMap,Map<String,Lead> phoneLeadMap,
                                  Map<String,Contact> bpmContactIdContactMap,Map<String,Contact> emailContactMap,Map<String,Contact> phoneContactMap,
                                  Map<String,Account> rsAccountMap,Map<String,Investment_Account__c> iaAccountIdIAMap){
        Case newCase = new Case();
        newCase.Reason = requestCase.reasonForContact;
        newCase.Case_Owner_Email__c = requestCase.ownerEmailAddress;
        newCase.Status = 'New';
        newCase.Type = requestCase.type;
        newCase.Subject = requestCase.subject;
        newCase.Description = requestCase.description;
        if(rsAccountMap.containsKey(requestCase.accountId)){
            newCase.AccountId = rsAccountMap.get(requestCase.accountId).Id;
        }
        if(iaAccountIdIAMap.containsKey(requestCase.externalId)){
            newCase.Investment_Account__c = iaAccountIdIAMap.get(requestCase.externalId).Id;
        }
        if(bpmContactIdContactMap.containsKey(requestCase.contactId)){
            newCase.ContactId = bpmContactIdContactMap.get(requestCase.contactId).Id;
        }
        else if(emailContactMap.containsKey(requestCase.email)){
            newCase.ContactId = emailContactMap.get(requestCase.email).Id;
        }
        else if(phoneContactMap.containsKey(requestCase.phone)){
            newCase.ContactId = phoneContactMap.get(requestCase.phone).Id;
        }
        
        else if(bpmContactIdLeadMap.containsKey(requestCase.contactId)){
            newCase.Lead__c = bpmContactIdLeadMap.get(requestCase.contactId).Id;
        }
        else if(emailLeadMap.containsKey(requestCase.email)){
            newCase.Lead__c = emailLeadMap.get(requestCase.email).Id;
        }
        else if(phoneLeadMap.containsKey(requestCase.phone)){
            newCase.Lead__c = phoneLeadMap.get(requestCase.phone).Id;
        }
        
        
        newCase.RecordTypeId = recType;
        newCase.OwnerId =  rsQueue;
        return newCase;
    }
    
    
}
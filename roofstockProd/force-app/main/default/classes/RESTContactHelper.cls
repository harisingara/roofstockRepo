global class RESTContactHelper {
    global class ContactsWrap{
        global List<Contacts> ContactList;
    }
    global class Contacts{
        global string bpmContactId;
        global string rsAccountId;
        global string roofstockUserId;
        global string type;
        global string email;
        global string phone;
        global string mobile;
        global string firstName;
        global string lastName ;
        global string companyName;
        global boolean isQualifiedRetailBuyer;
        global datetime firstQualifiedRetailBuyerDate;
        global datetime lastQualifiedRetailBuyerDate;
        global datetime buyboxCompleteDate;
        global Integer contactNumber;
        global string txnInstructions;
        
    }
    global class PostResponse {
        global ResponseWrapper responseBody;
        global PostResponse(List<ResponseBody> contactResponse) {
            this.responseBody = new ResponseWrapper(contactResponse);
        }
    }
    global class ResponseWrapper {  
        global List<ResponseBody> contactResponse;  
        global ResponseWrapper(){
            contactResponse = new List<ResponseBody>();
        }
        global ResponseWrapper(List<ResponseBody> contactResponse) {
            this.contactResponse = contactResponse;
        }
    } 
    global class ResponseBody{
        global String bpmContactId;
        global String salesforceId;
        global ResponseBody(String bpmContactId,String salesforceId) {
            this.bpmContactId = bpmContactId;
            this.salesforceId = salesforceId;
        }
    }
    global static PostResponse UpdateContact(List<Contacts> contactsList) {
        //System.debug('Entered Update Contact Method');
        //Custom Metadata
        UpdateContact_API_RecordType_Mapping__mdt[] recordTypeMappingList = [SELECT MasterLabel,Record_Type__c FROM UpdateContact_API_RecordType_Mapping__mdt];
        Map<String,String> recTypeMap = new Map<String,String>();
        Map<String,String> accRecordTypeMap = new Map<String,String>();
        Map<String,String> contactRecordTypeMap = new Map<String,String>();
        for (UpdateContact_API_RecordType_Mapping__mdt rType : recordTypeMappingList) {
            recTypeMap.put((rType.MasterLabel).toLowerCase(),rType.Record_Type__c);   
        }
        //Get Roofstock Customer Record Type Id
        Id rsCustomer = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Roofstock Customer').getRecordTypeId();
        
        //Get Roofstock Contact Id
        Id rsContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Roofstock Contact').getRecordTypeId();
        
        
        //Get Lead,Contact and Account Record Types
        List<RecordType> accRecordTypes = [select Id,Name from RecordType where sObjectType='Account'];
        for(RecordType aRT :accRecordTypes){
            //accRecordTypeMap.put(aRT.Name,aRT.Id);
            accRecordTypeMap.put((aRT.Name).toLowerCase(),aRT.Id);
        }
        List<RecordType> conRecordTypes = [select Id,Name from RecordType where sObjectType='Contact'];
        if(conRecordTypes.size()>0){
            for(RecordType cRT :conRecordTypes){
                //contactRecordTypeMap.put(cRT.Name,cRT.Id);
                contactRecordTypeMap.put((cRT.Name).toLowerCase(),cRT.Id);
            }
        }
        Id leadBuyerRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        Id leadrs1RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Roofstock One').getRecordTypeId();
        
        
        List<ResponseBody> contactsResponseList = new List<ResponseBody>();
        //Final update/insert List
        List<Account> updateAccountList = new List<Account>();
        Map<String, Account> createAccountMap = new Map<String, Account>();
        List<Account> createAccountList = new List<Account>();
        List<Contact> updateContactList = new List<Contact>();
        List<Contact> ExistingContactList = new List<Contact>();
        List<Contact> createContactForExistingAccountList = new List<Contact>();
        List<Contacts> pendingContactsList = new List<Contacts>();
        
        //Set to store Email,phone,bpmContactIds,rsAccountIds
        Set<String> requestBpmContactIdSet = new Set<String>();
        Set<String> requestRsAccountIdSet = new Set<String>();
        Set<String> requestPhoneSet = new Set<String>();
        Set<String> requestMobilePhoneSet = new Set<String>();
        Set<String> requestEmailSet = new Set<String>();
        
        
        
        //Map bpmContact,phone,email with ContactId & Map rsAccountId with 
        Map<String,Contact> bpmContactMap = new Map<String,Contact>();
        Map<String,Contact> emailContactMap = new Map<String,Contact>();
        Map<String,Contact> phoneContactMap = new Map<String,Contact>();
        Map<String,Contact> mobilePhoneContactMap = new Map<String,Contact>();
        Map<String,Account> rsAccountMap = new Map<String,Account>();
        Map<String,Account> phoneAccountMap = new Map<String,Account>();
        Map<String,Contacts> inputStringEmailMap = new Map<String,Contacts>();
        Map<String,Contacts> inputStringMobileMap = new Map<String,Contacts>();
        for(Contacts inputRequest : contactsList){
            if(!String.isEmpty(inputRequest.bpmContactId)){
                requestBpmContactIdSet.add(inputRequest.bpmContactId);    
            }
            /*if(!String.isEmpty(inputRequest.phone)){
requestPhoneSet.add(inputRequest.phone);    
}*/
            if(!String.isEmpty(inputRequest.mobile)){
                requestMobilePhoneSet.add(inputRequest.mobile);
                inputStringMobileMap.put(inputRequest.mobile,inputRequest);
            }
            if(!String.isEmpty(inputRequest.email)){
                requestEmailSet.add(inputRequest.email);    
                inputStringEmailMap.put(inputRequest.email,inputRequest);
            }
            if(!String.isEmpty(inputRequest.rsAccountId)){
                requestRsAccountIdSet.add(inputRequest.rsAccountId);   
            }
            
        }
        //Data Preparation for Lead
        Map<String,String> leadAccountIdMap = new Map<String,String>();
        Map<String,Contacts> leadInputRequestMap = new Map<String,Contacts>();
        Map<String,Lead> emailLeadMap = new Map<String,Lead>();
        Map<String,Lead> phoneLeadMap = new Map<String,Lead>();
        Map<String,Lead> mobilePhoneLeadMap = new Map<String,Lead>();
        Map<String,Lead> bpmContactIdLeadMap = new Map<String,Lead>();
        List<Lead> matchingLead = [select Id,RecordTypeId,BPM_Contact_Id__c,Email,Phone,MobilePhone from Lead where ((RecordTypeId=:leadBuyerRecordTypeId OR RecordTypeId=:leadrs1RecordTypeId) AND (BPM_Contact_Id__c IN:requestBpmContactIdSet OR Email IN:requestEmailSet OR Phone IN:requestMobilePhoneSet OR mobilePhone IN:requestMobilePhoneSet) AND isConverted=false)];
        //System.debug('=matchingLead='+matchingLead);
        for(Lead matchLead :matchingLead){
            if(matchLead.Email!=null)
                emailLeadMap.put((matchLead.Email).toLowerCase(),matchLead);
            if(matchLead.Phone!=null)
                phoneLeadMap.put(matchLead.Phone,matchLead);
            if(matchLead.MobilePhone!=null)
                mobilePhoneLeadMap.put(matchLead.MobilePhone,matchLead);
            if(matchLead.BPM_Contact_Id__c!=null)
                bpmContactIdLeadMap.put(matchLead.BPM_Contact_Id__c,matchLead);
        }
        
        List<Contact> matchingContactList = [select Id,BPM_Contact_Id__c,RecordTypeId,Email,Phone,MobilePhone, Account.Roofstock_Account_ID__c from Contact where (BPM_Contact_Id__c IN:requestBpmContactIdSet) OR (Phone IN:requestMobilePhoneSet) OR (MobilePhone IN:requestMobilePhoneSet) OR (Email IN:requestemailSet)];
        //System.debug('=matchingContactList='+matchingContactList);
        for(Contact matchingContact :matchingContactList){
            bpmContactMap.put(matchingContact.BPM_Contact_Id__c,matchingContact);
            if(matchingContact.Email!=null && matchingContact.BPM_Contact_Id__c == null){
                emailContactMap.put((matchingContact.Email).toLowerCase()+matchingContact.RecordTypeId,matchingContact);
            }
            if(matchingContact.Phone!=null && matchingContact.BPM_Contact_Id__c == null){
                phoneContactMap.put(matchingContact.Phone+matchingContact.RecordTypeId,matchingContact);
            }
            if(matchingContact.MobilePhone!=null && matchingContact.BPM_Contact_Id__c == null){
                mobilePhoneContactMap.put(matchingContact.MobilePhone+matchingContact.RecordTypeId,matchingContact);
            }
            
        }
        //List<Account> matchingAccountList = [select Id,Roofstock_Account_ID__c,Phone,RecordTypeId from Account where (Roofstock_Account_ID__c IN:requestRsAccountIdSet) OR (Phone IN:requestPhoneSet)];
        List<Account> matchingAccountList = [select Id,Is_Qualified_Retail_Buyer__c,First_Qualified_Retail_Buyer_Date__c,
                                                        Last_Qualified_Retail_Buyer_Date__c,Roofstock_Account_ID__c,Phone,RecordTypeId, 
                                                    BuyBox_Complete_Date__c,Transaction_Instructions__c from Account where (Roofstock_Account_ID__c IN:requestRsAccountIdSet) OR (Phone IN:requestMobilePhoneSet)];
        
        for(Account matchingAccount : matchingAccountList){
            rsAccountMap.put(matchingAccount.Roofstock_Account_ID__c,matchingAccount);
            if(matchingAccount.Phone != null && matchingAccount.Roofstock_Account_ID__c == null){
                phoneAccountMap.put(matchingAccount.Phone+matchingAccount.RecordTypeId,matchingAccount);
            }
        }
        //Iterate the incoming request
        // FORM SKEY to store all the Account in One set. 
        map<string,Account> mapAccnts = new map<string,Account> (); 
        String accUniqueKey; 
        Set<Id> cnctId = new Set<Id>();
        for(Contacts inputRequest : contactsList){
            String recordType = recTypeMap.containsKey((inputRequest.type).toLowerCase())?recTypeMap.get((inputRequest.type).toLowerCase()):inputRequest.type;    
            recordType = recordType.toLowerCase();
            ///System.debug('=recordType='+recordType);
            String recordTypeContact;
            String recordTypeAccount;
            recordTypeContact = recordType;
            recordTypeAccount = recordType;
            if(recordTypeContact == 'roofstock customer'){
                recordTypeContact = 'roofstock contact';    
            }
            
            if(bpmContactMap.containsKey(inputRequest.bpmContactId)){
                
                Contact existingContact = bpmContactMap.get(inputRequest.bpmContactId);
                
                //if contact already exist ,update name
                existingContact.FirstName = inputRequest.firstName;    
                existingContact.LastName = inputRequest.lastName;    
                
                // updateContactList.add(existingContact);
                
                if (!cnctId.contains(existingContact.Id)) {
                    
                    
                    accUniqueKey = inputRequest.rsAccountId+inputRequest.mobile+inputRequest.type;  
                    //System.debug('existingContact.Account '+existingContact.Account);
                    //System.debug('existingContact.Account.Roofstock_Account_ID__c '+existingContact.Account.Roofstock_Account_ID__c);
                    //System.debug('inputRequest.rsAccountId '+inputRequest.rsAccountId);
                    if(existingContact.Account != null && existingContact.Account.Roofstock_Account_ID__c != inputRequest.rsAccountId){
                        //System.debug('inputRequest.rsAccountId: '+inputRequest.rsAccountId);
                        if(rsAccountMap.get(inputRequest.rsAccountId) != null){
                            existingContact.AccountId = rsAccountMap.get(inputRequest.rsAccountId).Id;
                            
                                Account existingAccount = rsAccountMap.get(inputRequest.rsAccountId);
                                if(inputRequest.txnInstructions != null ){
                                    existingAccount.Transaction_Instructions__c = inputRequest.txnInstructions;
                                }
                                //RET-2688
                                if(inputRequest.type == 'Buyer'){    
                                if(inputRequest.isQualifiedRetailBuyer !=null){
                                    existingAccount.Is_Qualified_Retail_Buyer__c = inputRequest.isQualifiedRetailBuyer;
                                }
                                if(inputRequest.firstQualifiedRetailBuyerDate !=null){
                                    existingAccount.First_Qualified_Retail_Buyer_Date__c = inputRequest.firstQualifiedRetailBuyerDate;
                                    existingContact.First_Qualified_Retail_Buyer_Date__c = inputRequest.firstQualifiedRetailBuyerDate;
                                }
                                if(inputRequest.lastQualifiedRetailBuyerDate !=null){
                                    existingAccount.Last_Qualified_Retail_Buyer_Date__c = inputRequest.lastQualifiedRetailBuyerDate;
                                    existingContact.Last_Qualified_Retail_Buyer_Date__c = inputRequest.lastQualifiedRetailBuyerDate;
                                }
                                if(inputRequest.buyboxCompleteDate != null){
                                   //System.debug('inputRequest.buyboxCompleteDate_225 :::::: '+inputRequest.buyboxCompleteDate);
                                   existingAccount.BuyBox_Complete_Date__c = inputRequest.buyboxCompleteDate;
                                }
                                //System.debug('existingAccount_228 :::::: '+existingAccount);
                                createAccountMap.put(inputRequest.rsAccountId, existingAccount);
                            }
                        }else{
                            Account newAccount = new Account();
                            newAccount.Name = inputRequest.companyName;
                            newAccount.Roofstock_Account_ID__c = inputRequest.rsAccountId;
                            newAccount.Phone = inputRequest.mobile; 
                            if(inputRequest.txnInstructions != null ){
                                newAccount.Transaction_Instructions__c = inputRequest.txnInstructions;
                            }
                            //System.debug('accRecordTypeMap::'+accRecordTypeMap +'--recordTypeAccount--'+recordTypeAccount);
                            newAccount.RecordTypeId = accRecordTypeMap.get(recordTypeAccount);
                            //RET-2688
                            if(inputRequest.type == 'Buyer'){
                                if(inputRequest.isQualifiedRetailBuyer != null){
                                    newAccount.Is_Qualified_Retail_Buyer__c = inputRequest.isQualifiedRetailBuyer;
                                }
                                if(inputRequest.firstQualifiedRetailBuyerDate != null){
                                    newAccount.First_Qualified_Retail_Buyer_Date__c = inputRequest.firstQualifiedRetailBuyerDate;
                                    existingContact.First_Qualified_Retail_Buyer_Date__c = inputRequest.firstQualifiedRetailBuyerDate;
                                }
                                if(inputRequest.lastQualifiedRetailBuyerDate != null){
                                    newAccount.Last_Qualified_Retail_Buyer_Date__c = inputRequest.lastQualifiedRetailBuyerDate;
                                    existingContact.Last_Qualified_Retail_Buyer_Date__c = inputRequest.lastQualifiedRetailBuyerDate;
                                }
                                if(inputRequest.buyboxCompleteDate != null){
                                //System.debug('inputRequest.buyboxCompleteDate_252 :::::: '+inputRequest.buyboxCompleteDate);
                                   newAccount.BuyBox_Complete_Date__c = inputRequest.buyboxCompleteDate;
                                }
                            }
                            createAccountMap.put(inputRequest.rsAccountId, newAccount);
                            mapAccnts.put(accUniqueKey,newAccount); 
                            existingContact.Account = newAccount;
                        }
                        
                    }
                    //RET-2688
                    else if(existingContact.Account != null && existingContact.Account.Roofstock_Account_ID__c == inputRequest.rsAccountId){
                        //System.debug('Entered Else If Condition where account is same');
                            Account existingAccount = rsAccountMap.get(inputRequest.rsAccountId);
                           if(inputRequest.txnInstructions != null ){
                               //System.debug('Entered Condition1');
                                existingAccount.Transaction_Instructions__c = inputRequest.txnInstructions;
                           }
                           if(inputRequest.type == 'Buyer'){
                               //System.debug('Entered Condition2');
                            if(inputRequest.isQualifiedRetailBuyer !=null){
                               //System.debug('Entered Condition21');
                                existingAccount.Is_Qualified_Retail_Buyer__c = inputRequest.isQualifiedRetailBuyer;                                    
                            }
                            if(inputRequest.firstQualifiedRetailBuyerDate!=null){
                                //System.debug('Entered Condition22');
                                existingAccount.First_Qualified_Retail_Buyer_Date__c = inputRequest.firstQualifiedRetailBuyerDate;
                                existingContact.First_Qualified_Retail_Buyer_Date__c = inputRequest.firstQualifiedRetailBuyerDate;
                            }
                            if(inputRequest.lastQualifiedRetailBuyerDate!=null){
                                //System.debug('Entered Condition23');
                                existingAccount.Last_Qualified_Retail_Buyer_Date__c = inputRequest.lastQualifiedRetailBuyerDate;
                                existingContact.Last_Qualified_Retail_Buyer_Date__c = inputRequest.lastQualifiedRetailBuyerDate;
                            }
                            if(inputRequest.buyboxCompleteDate != null){
                            //System.debug('Entered Condition24');
                            //System.debug('inputRequest.buyboxCompleteDate_280 :::::: '+inputRequest.buyboxCompleteDate);
                                 existingAccount.BuyBox_Complete_Date__c = inputRequest.buyboxCompleteDate;
                            }
                        }
                        //System.debug('existingAccount_285 :::::: '+existingAccount);
                        createAccountMap.put(inputRequest.rsAccountId, existingAccount);
                    }
                    
                    updateContactList.add(existingContact);
                    cnctId.add(existingContact.Id);
                }
                
                ExistingContactList.add(bpmContactMap.get(inputRequest.bpmContactId));
                
            }
            //check for matching email & rectype 
            else if(emailContactMap.containsKey((inputRequest.email).toLowerCase()+contactRecordTypeMap.get(recordTypeContact))){
                Contact existingContact = emailContactMap.get((inputRequest.email).toLowerCase()+contactRecordTypeMap.get(recordTypeContact));
                //RET-2688
                
                    Account existingAccount = rsAccountMap.get(inputRequest.rsAccountId);
                    if(existingAccount != null){
                        if(inputRequest.txnInstructions != null){
                        existingAccount.Transaction_Instructions__c = inputRequest.txnInstructions;
                        }
                        if(inputRequest.type == 'Buyer'){
                        if(inputRequest.isQualifiedRetailBuyer != null){
                            existingAccount.Is_Qualified_Retail_Buyer__c = inputRequest.isQualifiedRetailBuyer;
                        }
                        if(inputRequest.firstQualifiedRetailBuyerDate != null){
                            existingAccount.First_Qualified_Retail_Buyer_Date__c = inputRequest.firstQualifiedRetailBuyerDate;
                            existingContact.First_Qualified_Retail_Buyer_Date__c = inputRequest.firstQualifiedRetailBuyerDate;
                        }
                        if(inputRequest.lastQualifiedRetailBuyerDate != null){
                            existingAccount.Last_Qualified_Retail_Buyer_Date__c = inputRequest.lastQualifiedRetailBuyerDate;
                            existingContact.Last_Qualified_Retail_Buyer_Date__c = inputRequest.lastQualifiedRetailBuyerDate;
                        }
                        if(inputRequest.buyboxCompleteDate != null){
                            //System.debug('inputRequest.buyboxCompleteDate_315 :::::: '+inputRequest.buyboxCompleteDate);
                             existingAccount.BuyBox_Complete_Date__c = inputRequest.buyboxCompleteDate;
                         }
                         //System.debug('existingAccount_320 :::::: '+existingAccount);
                        createAccountMap.put(inputRequest.rsAccountId, existingAccount);
                    }
                }
                if(String.isBlank(existingContact.BPM_Contact_Id__c)){
                    existingContact.BPM_Contact_Id__c = inputRequest.bpmContactId;    
                    //updateContactList.add(existingContact);
                    if (!cnctId.contains(existingContact.Id)) {
                        updateContactList.add(existingContact);
                        cnctId.add(existingContact.Id);
                    }
                }
                else{
                    ExistingContactList.add(existingContact);
                }
                
            }
            
            else if(rsAccountMap.containsKey(inputRequest.rsAccountId)){
                Account existingAccount = rsAccountMap.get(inputRequest.rsAccountId);
                if(inputRequest.txnInstructions != null ){
                    existingAccount.Transaction_Instructions__c = inputRequest.txnInstructions;
                }
                //RET-2688
                if(inputRequest.type == 'Buyer'){
                    if(inputRequest.isQualifiedRetailBuyer != null){
                        existingAccount.Is_Qualified_Retail_Buyer__c = inputRequest.isQualifiedRetailBuyer;
                    }
                    if(inputRequest.firstQualifiedRetailBuyerDate != null){
                        existingAccount.First_Qualified_Retail_Buyer_Date__c = inputRequest.firstQualifiedRetailBuyerDate;
                    }
                    if(inputRequest.lastQualifiedRetailBuyerDate != null){
                        existingAccount.Last_Qualified_Retail_Buyer_Date__c = inputRequest.lastQualifiedRetailBuyerDate;
                    }
                    if(inputRequest.buyboxCompleteDate != null){
                        //System.debug('inputRequest.buyboxCompleteDate_352 :::::: '+inputRequest.buyboxCompleteDate);
                         existingAccount.BuyBox_Complete_Date__c = inputRequest.buyboxCompleteDate;
                    }
                    //System.debug('existingAccount_358 :::::: '+existingAccount);
                    createAccountMap.put(inputRequest.rsAccountId, existingAccount);
                }
                //logic to get existing lead and merge account
                Lead existingLead = checkForMatchingLead(inputRequest,bpmContactIdLeadMap,emailLeadMap,phoneLeadMap,mobilePhoneLeadMap);
                if(existingLead!=null){
                    leadAccountIdMap.put(existingLead.Id,existingAccount.Id);
                    leadInputRequestMap.put(existingLead.Id,inputRequest);
                }
                else if(existingLead == null){
                    Contact newContact = createNewContact(existingAccount,recordTypeContact,contactRecordTypeMap,inputRequest);
                    createContactForExistingAccountList.add(newContact);
                }
                //System.debug('=leadAccountIdMap1='+leadAccountIdMap);
            }
            else if(phoneAccountMap.containsKey(inputRequest.mobile+accRecordTypeMap.get(recordTypeAccount))){
                Account existingAccount = phoneAccountMap.get(inputRequest.mobile+accRecordTypeMap.get(recordTypeAccount));
                if(inputRequest.txnInstructions != null ){
                    existingAccount.Transaction_Instructions__c = inputRequest.txnInstructions;
                }
                //RET-2688
                if(inputRequest.type == 'Buyer'){
                    if(inputRequest.isQualifiedRetailBuyer != null){
                        existingAccount.Is_Qualified_Retail_Buyer__c = inputRequest.isQualifiedRetailBuyer;
                    }
                    if(inputRequest.firstQualifiedRetailBuyerDate != null){
                        existingAccount.First_Qualified_Retail_Buyer_Date__c = inputRequest.firstQualifiedRetailBuyerDate;
                    }
                    if(inputRequest.lastQualifiedRetailBuyerDate != null){
                        existingAccount.Last_Qualified_Retail_Buyer_Date__c = inputRequest.lastQualifiedRetailBuyerDate;
                    }
                    if(inputRequest.buyboxCompleteDate != null){
                        //System.debug('inputRequest.buyboxCompleteDate_386 :::::: '+inputRequest.buyboxCompleteDate);
                        existingAccount.BuyBox_Complete_Date__c = inputRequest.buyboxCompleteDate;
                    }
                    //System.debug('existingAccount_393 :::::: '+existingAccount);
                    createAccountMap.put(inputRequest.rsAccountId, existingAccount);
                }
                //logic to get existing lead and merge account
                Lead existingLead = checkForMatchingLead(inputRequest,bpmContactIdLeadMap,emailLeadMap,phoneLeadMap,mobilePhoneLeadMap);
                if(existingLead!=null){
                    leadAccountIdMap.put(existingLead.Id,existingAccount.Id);
                    leadInputRequestMap.put(existingLead.Id,inputRequest);
                }
                else if(existingLead == null){
                    Contact newContact = createNewContact(existingAccount,recordTypeContact,contactRecordTypeMap,inputRequest);
                    createContactForExistingAccountList.add(newContact);
                }
                //System.debug('=leadAccountIdMap2='+leadAccountIdMap);
            }
            //else if(){ //Matching Lead exist convert the lead to con and account}
            else if(checkForMatchingLead(inputRequest,bpmContactIdLeadMap,emailLeadMap,phoneLeadMap,mobilePhoneLeadMap)!=null){
                Lead existingLead = checkForMatchingLead(inputRequest,bpmContactIdLeadMap,emailLeadMap,phoneLeadMap,mobilePhoneLeadMap);
                leadAccountIdMap.put(existingLead.Id,null);
                leadInputRequestMap.put(existingLead.Id,inputRequest);
                //System.debug('=leadAccountIdMap3='+leadAccountIdMap);
                
            }
            else{
                accUniqueKey = inputRequest.rsAccountId+inputRequest.mobile+inputRequest.type;    
                if(!mapAccnts.containsKey(accUniqueKey)){
                    Account newAccount = new Account();
                    newAccount.Name = inputRequest.companyName;
                    newAccount.Roofstock_Account_ID__c = inputRequest.rsAccountId;
                    newAccount.Phone = inputRequest.mobile; 
                    if(inputRequest.txnInstructions != null ){
                    newAccount.Transaction_Instructions__c = inputRequest.txnInstructions;
                    }
                    //System.debug('accRecordTypeMap::'+accRecordTypeMap +'--recordTypeAccount--'+recordTypeAccount);
                    newAccount.RecordTypeId = accRecordTypeMap.get(recordTypeAccount); 
                    //RET-2688
                    if(inputRequest.type == 'Buyer'){
                        if(inputRequest.isQualifiedRetailBuyer != null){
                            newAccount.Is_Qualified_Retail_Buyer__c = inputRequest.isQualifiedRetailBuyer;
                        }
                        if(inputRequest.firstQualifiedRetailBuyerDate != null){
                            newAccount.First_Qualified_Retail_Buyer_Date__c = inputRequest.firstQualifiedRetailBuyerDate;
                        }
                        if(inputRequest.lastQualifiedRetailBuyerDate != null){
                            newAccount.Last_Qualified_Retail_Buyer_Date__c = inputRequest.lastQualifiedRetailBuyerDate;
                        }
                        if(inputRequest.buyboxCompleteDate != null){
                            //System.debug('inputRequest.buyboxCompleteDate_435 :::::: '+inputRequest.buyboxCompleteDate);
                            newAccount.BuyBox_Complete_Date__c = inputRequest.buyboxCompleteDate;
                         }
                    }
                    //System.debug('existingAccount_444 :::::: '+newAccount);
                    createAccountMap.put(inputRequest.rsAccountId, newAccount);
                    mapAccnts.put(accUniqueKey,newAccount); 
                }
                pendingContactsList.add(inputRequest);
            }
            
        }
        
        //System.debug('createAccountList::'+createAccountList);
        if(createAccountMap.size()>0){
            createAccountList.addAll( createAccountMap.values());
            //System.debug('createAccountList::'+createAccountList);
            upsert createAccountList Roofstock_Account_ID__c;    
        }
        
        //System.debug('updateContactList::'+updateContactList);
        if(updateContactList.size()>0){
            update updateContactList;    
        }
        if(createContactForExistingAccountList.size()>0){
            insert createContactForExistingAccountList;    
        }
        
        List<Contact> newContactForNewAccountList = new List<Contact>();
        for(Contacts newContacts : pendingContactsList){
            //String recordType = recTypeMap.get(newContacts.type);
            String recordType = recTypeMap.containsKey((newContacts.type).toLowerCase())?recTypeMap.get((newContacts.type).toLowerCase()):newContacts.type;    
            recordType = recordType.toLowerCase();
            // System.debug('=recordType='+recordType);
            if(recordType == 'roofstock customer'){
                recordType = 'roofstock contact';    
            }
            accUniqueKey = newContacts.rsAccountId+newContacts.mobile+newContacts.type;
            /*for(Account ac:createAccountList){
if(newContacts.rsAccountId == ac.Roofstock_Account_ID__c){*/
            //System.debug('New Contact'+newContacts);
            Contact con = new Contact();
            con.Email = newContacts.email;
            con.Phone = newContacts.mobile;
            con.MobilePhone = newContacts.mobile;
            con.FirstName = newContacts.firstName;
            con.LastName = newContacts.lastName;
            con.Roofstock_User_Id__c = newContacts.roofstockUserId;
            con.BPM_Contact_Id__c = newContacts.bpmContactId;
            con.RecordTypeId = contactRecordTypeMap.get(recordType);
            con.AccountId = mapAccnts.get(accUniqueKey).Id;                     
            newContactForNewAccountList.add(con);
            /*  }    
}   */  
        }
        // system.debug(0/0); 
        if(newContactForNewAccountList.size()>0){
            insert newContactForNewAccountList;    
        }
        //List<Contact> updatedConvertedContacts = new List<Contact>();
        List<Contact> convertedContactList = new List<Contact>();
        if(leadAccountIdMap.keyset().size() > 0){
            convertedContactList = convertExistingLead(leadAccountIdMap,leadInputRequestMap);
            //System.debug('=convertedContactList='+convertedContactList);
            //updatedConvertedContacts = updateContact(convertedContactList,inputStringEmailMap,inputStringMobileMap);
            //System.debug('=updatedConvertedContacts='+updatedConvertedContacts);
            //updateAccounts(convertedContactList,inputStringEmailMap,inputStringMobileMap);
        }
        //Prepare response
        Set<Contact> uniqueContacts = new Set<Contact>();
        updateContactList.addAll(createContactForExistingAccountList);
        updateContactList.addAll(newContactForNewAccountList);
        updateContactList.addAll(ExistingContactList);
        updateContactList.addAll(convertedContactList);
        //createContactForExistingAccountList.addAll(newContactForNewAccountList);
        //uniqueContacts.addAll(createContactForExistingAccountList);
        uniqueContacts.addAll(updateContactList);
        for(Contact ct:uniqueContacts){
            ResponseBody res = new ResponseBody(ct.BPM_Contact_Id__c,ct.Id);
            contactsResponseList.add(res);
        }
        
        postResponse res = new postResponse(contactsResponseList);
        return res;
        
    }
    
    //Code to check for matching Lead
    public static Lead checkForMatchingLead(Contacts inputContact,Map<String,Lead> bpmContactIdLeadMap,Map<String,Lead> emailLeadMap,Map<String,Lead> phoneLeadMap,Map<String,Lead> mobilePhoneLeadMap){
        //System.debug('=emailLeadMap='+emailLeadMap);
        //System.debug('=inputContact='+inputContact);
        String sEmail = '';
        if(inputContact.email != null)
            sEmail = (inputContact.email).toLowerCase(); 
        //system.debug('sEmail='+sEmail);
        if(inputContact.type!='Buyer'){
            return null;
        }
        if(bpmContactIdLeadMap.containsKey(inputContact.bpmContactId)){
            return bpmContactIdLeadMap.get(inputContact.bpmContactId);
        }
        else if(emailLeadMap.containsKey(sEmail)){
            return emailLeadMap.get(sEmail);
        }
        else if(phoneLeadMap.containsKey(inputContact.mobile)){
            return phoneLeadMap.get(inputContact.mobile);
        }
        else if(mobilePhoneLeadMap.containsKey(inputContact.mobile)){
            return mobilePhoneLeadMap.get(inputContact.mobile);
        }
        else{
            return null;
        }
    }
    
    //Lead Convertion
    Public  static List<Contact> convertExistingLead(Map<String,String> leadAccountIdMap,Map<String,Contacts>leadInputRequestMap){
        Id leadrs1RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Roofstock One').getRecordTypeId();
        
        List<Lead> convertedLeadList = [select Id,RecordTypeId,FirstName,OwnerId,owner.type,LastName,Phone,Email,Roofstock_Account_ID__c,MobilePhone,BPM_Contact_Id__c,Roofstock_User_Id__c,isConverted from Lead where Id IN:leadAccountIdMap.keySet()];
        //Roofstock__mdt  integrationUser = Roofstock__mdt.getInstance('Integration_User');        
        Map<String,boolean> convertedLeadAccountIdMap = new Map<String,boolean>();
        Map<Id,Lead> updateLeadPriorConversionMap = new Map<Id,Lead>();
        for(Lead ld : convertedLeadList){
            Contacts inputRequestString = leadInputRequestMap.get(ld.Id);
            ld.FirstName = inputRequestString.firstName;
            ld.LastName = inputRequestString.lastName;
            ld.Company = inputRequestString.companyName;
            ld.MobilePhone = inputRequestString.mobile;
            ld.Phone = inputRequestString.mobile;
            ld.Email = inputRequestString.email;
            ld.Roofstock_User_Id__c = inputRequestString.roofstockUserId;
            ld.Roofstock_Account_ID__c = inputRequestString.rsAccountId;
            ld.BPM_Contact_Id__c = inputRequestString.bpmContactId;
            //RET-2688
            if(inputRequestString.isQualifiedRetailBuyer !=null){
                ld.Is_Qualified_Retail_Buyer__c = inputRequestString.isQualifiedRetailBuyer;
            }
            if(inputRequestString.firstQualifiedRetailBuyerDate !=null){
                ld.First_Qualified_Retail_Buyer_Date__c = inputRequestString.firstQualifiedRetailBuyerDate;
            }
            if(inputRequestString.lastQualifiedRetailBuyerDate !=null){
                ld.Last_Qualified_Retail_Buyer_Date__c = inputRequestString.lastQualifiedRetailBuyerDate;
            }
            
            if(ld.owner.type == 'Queue' || String.isEmpty(ld.OwnerId)){ 
                //ld.OwnerId = integrationUser.User_Id__c;
                ld.OwnerId = UserInfo.getUserId();
            }
            
            updateLeadPriorConversionMap.put(ld.Id,ld);
            convertedLeadAccountIdMap.put(ld.Id,ld.isConverted);            
        }
        
        if(updateLeadPriorConversionMap.values().size()>0){
            update updateLeadPriorConversionMap.values();
        }
        //System.debug('=convertedLeadAccountIdMap='+convertedLeadAccountIdMap);
        //System.debug('=updateLeadPriorConversionMap='+updateLeadPriorConversionMap);
        Set<Id> convertedContactIds = new Set<Id>();
        Database.LeadConvert[] converts = new Database.LeadConvert[0];
        for(String convertLead: updateLeadPriorConversionMap.keySet()) {
            if(convertedLeadAccountIdMap.get(convertLead) != true){
                Database.LeadConvert convert = new Database.LeadConvert();
                convert.setLeadId(convertLead);
                convert.setDoNotCreateOpportunity(True);
                if(updateLeadPriorConversionMap.get(convertLead).RecordTypeId == leadrs1RecordTypeId){
                    convert.setConvertedStatus('Qualified');
                }
                else{
                    convert.setConvertedStatus('Appointment');
                }
                if(leadAccountIdMap.get(convertLead)!=null){
                    convert.setAccountId(leadAccountIdMap.get(convertLead));
                }
                converts.add(convert);
                //System.debug('=converts='+converts);
            }
        }
        List<Database.LeadConvertResult> lcr = Database.convertLead(converts);
        for(Database.LeadConvertResult convertedLead : lcr){
            convertedContactIds.add(convertedLead.getContactId());
        }
        
        List<Contact> convertedContacts = [select Id,BPM_Contact_Id__c,AccountId,Email,Phone,MobilePhone,firstName,LastName from Contact where Id IN:convertedContactIds];
        return convertedContacts;
        
    }
    
    
    
    //Create New Contact
    public static Contact createNewContact(Account acc,String recordType,Map<String,String> contactRecordTypeMap,Contacts inputRequest){
        Contact con = new Contact();
        con.Email = inputRequest.email;
        con.Phone = inputRequest.mobile;
        con.MobilePhone = inputRequest.mobile;
        con.FirstName = inputRequest.firstName;
        con.LastName = inputRequest.lastName;
        con.Roofstock_User_Id__c = inputRequest.roofstockUserId;
        con.BPM_Contact_Id__c = inputRequest.bpmContactId;
        con.Last_Qualified_Retail_Buyer_Date__c = inputRequest.lastQualifiedRetailBuyerDate;
        con.First_Qualified_Retail_Buyer_Date__c= inputRequest.firstQualifiedRetailBuyerDate;
        con.RecordTypeId = contactRecordTypeMap.get(recordType);
        con.AccountId = acc.Id;
        return con;
        
    }
    
}
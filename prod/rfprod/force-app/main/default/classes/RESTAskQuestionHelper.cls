/*
 * 13/09/2021 - PE-504 - update the logic for Listing Source to be at task level

 * 
 * */
global class RESTAskQuestionHelper {
    global class LeadsWrap{
        global List<Leads> leadList;
    }
    global class Leads{
        global String Email;
        global String firstName;
        global String lastName;
        global String listingId;
        global String phone;
        global String rsAccountId;
        global String rsContactId;
        global String timeframeForInvesting;
        global String totalCapitalAvailable;
        global String financing;
        global String description;
        global String buyerBrokerName;
        global String buyerBrokerBrokerageName;
        global String buyerBrokerPhone;
        global String buyerBrokerEmail;
        global String propertyAddress;
        global String buyerAccountId;  
        global String listingSource;
        global String allowableSaleTypes;
    }
    
    global class ResponseBody{
        global String salesforceId;
        
        global ResponseBody(String salesforceId){
            this.salesforceId = salesforceId;
            
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
    
    global static PostResponse createLeadAndTask(List<Leads> askQuestionLeadList) {
        
        List<ResponseBody> leadResponseList = new List<ResponseBody>();
        Set<String> emailSet = new Set<String>();
        Set<String> phoneSet = new Set<String>();
        Set<String> contactIdSet = new Set<String>();
        Map<String,Leads> emailRequestMap = new Map<String,Leads>();
        Map<String,Leads> phoneRequestMap = new Map<String,Leads>();
        Map<String,Leads> contactIdRequestMap = new Map<String,Leads>();
        Map<String,Contact> matchingContactIdContactMap = new Map<String,Contact>();
        Map<String,Contact> matchingEmailContactMap = new Map<String,Contact>();
        Map<String,Contact> matchingPhoneContactMap = new Map<String,Contact>();
        Map<String,Lead> matchingEmailLeadMap = new Map<String,Lead>();
        Map<String,Lead> matchingPhoneLeadMap = new Map<String,Lead>();
        List<Leads> newLeadList = new List<Leads>();
        List<Lead> existingLeadCreateTask = new List<Lead>();
        List<Contact> existingContactCreateTask = new List<Contact>();
        
        for(Leads inputLead : askQuestionLeadList){
            
            emailRequestMap.put((inputLead.Email).toLowerCase(),inputLead);
            String fphone ='';
            String soqlFphone='';              
            String soqlFphone1='';
            //if(inputLead.phone!=null){
			if(!String.isBlank(inputLead.phone )){                
            	fphone = formatPhone(inputLead.phone);
                soqlFphone = soqlFormatPhone(inputLead.phone);                 
                soqlFphone1 = '+1'+ soqlFphone;
				phoneRequestMap.put((fphone).replaceAll('\\D',''),inputLead);                
                phoneRequestMap.put(soqlFphone,inputLead);
                phoneRequestMap.put(soqlFphone1,inputLead);
            	contactIdRequestMap.put(inputLead.rsContactId,inputLead);                                
            }
           
            if(inputLead.Email!=null && inputLead.Email!=''){
                emailSet.add(inputLead.Email);  
            }
            if(inputLead.Phone!=null && inputLead.Phone!=''){                    
                phoneSet.add(soqlFphone1);
                phoneSet.add(soqlFphone);
                phoneSet.add(fphone);
            }
            if(inputLead.rsContactId!=null && inputLead.rsContactId!=''){
                contactIdSet.add(inputLead.rsContactId);
            }
            
        }
        
        System.debug('-phoneSet-'+phoneSet);
        Id buyerRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        List<Contact> matchingContactList = [Select Id,accountId, Email,BPM_Contact_Id__c,OwnerId,MobilePhone,Phone from Contact where (BPM_Contact_Id__c IN:contactIdSet OR Email IN:emailSet OR MobilePhone IN:phoneSet OR Phone IN:phoneSet)];
        //List<Lead> matchingLeadList = [Select Id,Email,OwnerId,MobilePhone,Phone from Lead where ((Email IN:emailSet OR MobilePhone IN:phoneSet OR Phone IN:phoneSet) AND (RecordTypeId=:buyerRecordTypeId) AND (isConverted=false))];
        List<Lead> matchingLeadList = [Select Id,Email,OwnerId,MobilePhone,Phone from Lead where ((Email IN:emailSet OR MobilePhone IN:phoneSet OR Phone IN:phoneSet) AND (isConverted=false))];
        
        System.debug('-matchingContactList-'+matchingContactList);
        System.debug('-matchingLeadList-'+matchingLeadList);
        //Matching Contacts
        for(Contact con:matchingContactList){
            
            matchingContactIdContactMap.put(con.BPM_Contact_Id__c,con);
            
            // Added null check for Contact's Blank email value
            if(!String.isBlank(con.Email)){
            	matchingEmailContactMap.put((con.Email).toLowerCase(),con);
            }
            String conMobilePhone='';
            String conPhone = '';  
            if(!String.isBlank(con.MobilePhone)){
            	conMobilePhone = formatPhone(con.MobilePhone);
				matchingPhoneContactMap.put(conMobilePhone,con);                
            }
            if(!String.isBlank(con.Phone)){
            	conPhone = formatPhone(con.Phone);
				matchingPhoneContactMap.put(conPhone,con);                
            }
            
            
            
        }
        System.debug('-matchingPhoneContactMap-'+matchingPhoneContactMap);
        //Matching Lead
        for(Lead matchingLead:matchingLeadList){
            // Added null check for Lead's Blank email value
            if(!String.isBlank(matchingLead.Email)){
            	matchingEmailLeadMap.put((matchingLead.Email).toLowerCase(),matchingLead);
            }
            String leadMobilePhone;
            String leadMobilePhone1;
            String leadMobilePhone2;
            String leadPhone;
            String leadPhone1;
            String leadPhone2;
            if(!String.isBlank(matchingLead.MobilePhone)){
				leadMobilePhone = formatPhone(matchingLead.MobilePhone);  
                leadMobilePhone1 = soqlFormatPhone(matchingLead.MobilePhone);
                leadMobilePhone2 = '+1'+leadMobilePhone1;
            	matchingPhoneLeadMap.put(leadMobilePhone,matchingLead);
				matchingPhoneLeadMap.put(leadMobilePhone1,matchingLead);
				matchingPhoneLeadMap.put(leadMobilePhone2,matchingLead);                
            }
            if(!String.isBlank(matchingLead.Phone)){
            	leadPhone = formatPhone(matchingLead.Phone);
                leadPhone1 = soqlFormatPhone(matchingLead.Phone);
                leadPhone2 = '+1'+leadPhone1;
            	matchingPhoneLeadMap.put(leadPhone,matchingLead);
                matchingPhoneLeadMap.put(leadPhone1,matchingLead);
                matchingPhoneLeadMap.put(leadPhone2,matchingLead);
            }
        }
        System.debug('-matchingPhoneLeadMap-'+matchingPhoneLeadMap);
        
        for(Leads reqLead : askQuestionLeadList){
            
            String fphone = formatPhone(reqLead.phone);
            //Naveen
            String fphone1 = soqlFormatPhone(reqLead.phone);
            String fphone2 = '+1'+fphone1;
            
            //if(!matchingEmailContactMap.containsKey(reqLead.Email) && !matchingPhoneContactMap.containsKey(reqLead.Phone)){
            if(!matchingContactIdContactMap.containsKey(reqLead.rsContactId) && !matchingEmailContactMap.containsKey((reqLead.Email).toLowerCase()) && !matchingPhoneContactMap.containsKey(fphone)){
                //Naveen
                if(!matchingEmailLeadMap.containsKey((reqLead.Email).toLowerCase()) && !matchingPhoneLeadMap.containsKey(fphone) && !matchingPhoneLeadMap.containsKey(fphone1) && !matchingPhoneLeadMap.containsKey(fphone2)){
                    newLeadList.add(reqLead);
                }
                else{
                    Lead existingLd;
                    //Naveen
                    if(matchingEmailLeadMap.containsKey((reqLead.Email).toLowerCase())){
                        existingLd = matchingEmailLeadMap.get((reqLead.Email).toLowerCase());
                    }
                    else
                        if(matchingPhoneLeadMap.containsKey(fphone)){
                            existingLd = matchingPhoneLeadMap.get(fphone);
                        } 
                     else
                        if(matchingPhoneLeadMap.containsKey(fphone1)){
                            existingLd = matchingPhoneLeadMap.get(fphone1);
                        } 
                     else
                        if(matchingPhoneLeadMap.containsKey(fphone2)){
                            existingLd = matchingPhoneLeadMap.get(fphone2);
                        } 
                    //Lead existingLd = matchingEmailLeadMap.containsKey((reqLead.Email).toLowerCase())?matchingEmailLeadMap.get((reqLead.Email).toLowerCase()):matchingPhoneLeadMap.get(fphone);
                    existingLeadCreateTask.add(existingLd);
                }
                System.debug('-existingLeadCreateTask-'+existingLeadCreateTask);
            }
            else{
                //Contact existingContact = matchingEmailContactMap.containsKey(reqLead.Email)?matchingEmailContactMap.get(reqLead.Email):matchingPhoneContactMap.get(reqLead.Phone);
                if(matchingContactIdContactMap.containsKey(reqLead.rsContactId)){
                    Contact existingContact = matchingContactIdContactMap.get(reqLead.rsContactId);   
                    existingContactCreateTask.add(existingContact);
                }
                else if(matchingEmailContactMap.containsKey(reqLead.Email)){
                    Contact existingContact = matchingEmailContactMap.get(reqLead.Email);   
                    existingContactCreateTask.add(existingContact);                    
                }
                else if(matchingPhoneContactMap.containsKey(fphone)){
                    Contact existingContact = matchingPhoneContactMap.get(fphone);   
                    existingContactCreateTask.add(existingContact); 
                }
            }            
            
        }
        
        System.debug('-existingContactCreateTask-'+existingContactCreateTask);
        Map<Lead,Leads> newLeadreqLeadsMap = new Map<Lead,Leads>();
        for(Leads reqLead:newLeadList){
            String fphone='';
            if(!String.isBlank(reqLead.phone)){
            	fphone = formatPhone(reqLead.phone);
            }
            Lead newLead = new Lead();
            newLead.FirstName = reqLead.firstName;
            newLead.LastName = reqLead.lastName;
            newLead.Phone = fphone;
            newLead.mobilePhone = fphone;
            newLead.Email = reqLead.Email;
            newLead.Roofstock_Account_ID__c = reqLead.rsAccountId;
            newLead.BPM_Contact_Id__c = reqLead.rsContactId;
            newLead.LeadSource = 'Contact Us - Web';
            newLead.Lead_Interest__c = 'Buying Properties';
            newLead.Company = reqLead.firstName+' '+reqLead.lastName;
            newLead.Buyer_Timeframe__c = reqLead.timeframeForInvesting;
            newLead.Capital_Available__c = reqLead.totalCapitalAvailable;
            newLead.Financing__c = reqLead.financing;
            newLead.RecordTypeId = buyerRecordTypeId;
            //newLead.Listing_Source__c  = reqLead.listingSource;
            newLeadreqLeadsMap.put(newLead,reqLead);
        }
        
        List<Lead> insertNewLeadList = new List<Lead>();
        List<Lead> allNewLeads = new List<Lead>();
        if(newLeadreqLeadsMap.keyset().size()>0){
            insertNewLeadList.addAll(newLeadreqLeadsMap.keySet());
            insert insertNewLeadList;
        }
        System.debug('-insertNewLeadList-'+insertNewLeadList);
        Set<Id> newLeadIdSet = new Set<Id>();
        for(Lead newLead:insertNewLeadList){
            newLeadIdSet.add(newLead.Id);
        }
        allNewLeads.addAll(insertNewLeadList);
        allNewLeads.addAll(existingLeadCreateTask);
        List<Case> newCaseList = new List<Case>();
        
        System.debug('-allNewLeads-'+allNewLeads);
        //Task for Matching and New Lead
        System.debug('-phone-'+phoneRequestMap);
        System.debug('-email-'+emailRequestMap);
        
        for(Lead currentLead:allNewLeads){
            Leads requestLead;
            String fphoneMobile = formatPhone(currentLead.MobilePhone);
            String fphone = formatPhone(currentLead.Phone);
			System.debug('-fphoneMobile-'+fphoneMobile);  
            System.debug('-fphone-'+fphone);
            if(emailRequestMap.get((currentLead.Email).toLowerCase())!=null){
                requestLead = emailRequestMap.get((currentLead.Email).toLowerCase());
            }
            else if(phoneRequestMap.get(fphoneMobile.replaceAll('\\D',''))!=null){
                requestLead = phoneRequestMap.get((fphoneMobile).replaceAll('\\D',''));
            }
            else if(phoneRequestMap.get((fphone).replaceAll('\\D',''))!=null){
                requestLead = phoneRequestMap.get((fphone).replaceAll('\\D',''));
            }
            /*else if(phoneRequestMap.get(fphoneMobile)!=null){                              
                requestLead = phoneRequestMap.get(fphoneMobile);
            }
            else if(phoneRequestMap.get(fphone)!=null){
                requestLead = phoneRequestMap.get(fphone);
            }*/
            
            System.debug('-requestLead-'+requestLead);
            Case cse = createCase(currentLead,newLeadIdSet,requestLead,false);
            
            newCaseList.add(cse);
        }
        System.debug('-newCaseList-'+newCaseList);
        //Task For Matching Contact
        for(Contact currentContact:existingContactCreateTask){
            Leads requestLead;            
            String fphoneMobile = formatPhone(currentContact.MobilePhone);
            String fphone = formatPhone(currentContact.Phone);
            System.debug('--phoneRequestMap'+phoneRequestMap);
            System.debug('--fphone'+fphone);
            System.debug('--fphoneMobile'+fphoneMobile);
            if(contactIdRequestMap.get(currentContact.BPM_Contact_Id__c)!=null){
                requestLead = contactIdRequestMap.get(currentContact.BPM_Contact_Id__c);
            }
            else if(emailRequestMap.get((currentContact.Email).toLowerCase())!=null){
                requestLead = emailRequestMap.get((currentContact.Email).toLowerCase());
            }
            else if(phoneRequestMap.get(fphoneMobile.replaceAll('\\D',''))!=null){
                requestLead = phoneRequestMap.get((fphoneMobile).replaceAll('\\D',''));
            }
            else if(phoneRequestMap.get((fphone).replaceAll('\\D',''))!=null){
                requestLead = phoneRequestMap.get((fphone).replaceAll('\\D',''));
            }
            Case cse = createCase(currentContact,null,requestLead,true);
            newCaseList.add(cse);
            
        }
        System.debug('-newCaseList-'+newCaseList);
        if(newCaseList.size()>0){
            insert newCaseList;
        }
        
        for(Lead existingLead : allNewLeads){
            leadResponseList.add(new ResponseBody(existingLead.Id));     
        }
        for(Contact con:existingContactCreateTask){
            leadResponseList.add(new ResponseBody(con.Id)); 
        }
        postResponse res = new postResponse(leadResponseList);
        return res;
        
    }
    
    public static Case createCase(SObject contextObject,Set<Id> newLeadSet,Leads requestLead, Boolean assignContactOwnerToTask){
		System.debug('-requestLead-'+requestLead);
        String generalRecordTypeName = Schema.SObjectType.Case.getRecordTypeInfosByName().get('General').getRecordTypeId();
        System.debug('-generalRecordTypeName-'+generalRecordTypeName);
        System.debug('-requestLead-'+requestLead);
        Case cse = new Case();
        Account updAccount;
        Contact updContact;
        Lead updLead;
            
       
        
        // Get the Sales Team Queue Info
        Group salesTeamqueue= [SELECT Id, Name, DeveloperName, Type FROM Group where Type = 'Queue' and DeveloperName = 'Sales_Team' limit 1];
        if(salesTeamqueue != null){
        
        	String caseNumber;
        	Case c; // = new Case ();
            if(!Test.isRunningTest()){
                // Get the Last 'Ask A Question' Case and Use the CaseNumber on that case to assign the corresponding Member of the Queue
                c = [Select Id, CaseNumber from Case where Subject = 'Ask a question' order by createddate desc limit 1];
                caseNumber= c.CaseNumber;
            }
            else{
                caseNumber= '100';
            }
            
            List <GroupMember> userGrp = [Select Id, UserOrGroupId From GroupMember where GroupId =: salesTeamqueue.Id order by Id];
            
            if(userGrp != null && userGrp.size() >0 && (Test.isRunningTest() || (c != null ))){
            
                List <Id> userGrpIds = new List <Id> ();
                for(GroupMember grpmem: userGrp){
                    userGrpIds.add(grpmem.UserOrGroupId);
                }
                
                if(String.valueOf(contextObject.getSObjectType()) == 'Lead'){
                    cse.Lead__c = contextObject.Id;
                }
                else{
                    cse.ContactId = contextObject.Id;
                }
                
                cse.Subject = 'Ask a question';
                cse.Status = 'Open';
                cse.RecordTypeId = generalRecordTypeName;
                cse.Origin = 'Web To Case';
                cse.Listing_Source__c= requestLead.listingSource;
                
                cse.Allowable_Sale_Type__c = requestLead.allowableSaleTypes;
                
                if(assignContactOwnerToTask == true){
                    Contact con = (Contact) contextObject;
                    cse.ContactId = con.Id;
                    if(userGrpIds.contains(con.ownerId)){
                       cse.OwnerId = con.ownerId;
                    }   
                    else{
                        // Assign the Case using Round Robin mechanism               
                        cse.OwnerId = userGrp[math.mod(Integer.ValueOf(caseNumber) + 1, Integer.ValueOf(System.Label.Sales_Team_Queue_Members_Count))].UserOrGroupId;
                        //System.debug('NDEBUG :: Case Number'+ c.CaseNumber);
                        //System.debug('NDEBUG MOD Value:::' + math.mod(Integer.ValueOf(c.CaseNumber) + 1, Integer.ValueOf(System.Label.Sales_Team_Queue_Members_Count)));
                    }
                }
                System.debug('-contextObject-'+contextObject);
                System.debug('-newLeadSet-'+newLeadSet);
                // Create case for Lead
                if(newLeadSet!=null){
                    if(!newLeadSet.contains(contextObject.Id)){
                        Lead newLead = (Lead) contextObject;
                        cse.Lead__c = newLead.Id;
                        if(userGrpIds.contains(newLead.ownerId)){
                            cse.OwnerId = newLead.ownerId;
                            cse.TempOwnerId1__c = cse.OwnerId;
                        }
                        else{
                            // Assign the Case using Round Robin mechanism                    
                            cse.OwnerId = userGrp[math.mod(Integer.ValueOf(caseNumber) + 1, Integer.ValueOf(System.Label.Sales_Team_Queue_Members_Count))].UserOrGroupId;
                            cse.TempOwnerId1__c = userGrp[math.mod(Integer.ValueOf(caseNumber) + 1, Integer.ValueOf(System.Label.Sales_Team_Queue_Members_Count))].UserOrGroupId;
                            updLead = new Lead (Id = cse.Lead__c, ownerId = cse.OwnerId);
                            //System.debug('NDEBUG MOD Value:::' + math.mod(Integer.ValueOf(c.CaseNumber) + 1, Integer.ValueOf(System.Label.Sales_Team_Queue_Members_Count)));
                        }
                    }
                }
                // Create case for Contact
                else{
                    Contact c1 = (Contact) contextObject;
                    if(userGrpIds.contains(c1.ownerId)){
                        cse.OwnerId = c1.ownerId;
                        cse.TempOwnerId1__c = cse.OwnerId;
                        updAccount = new Account(Id = c1.AccountId ,ownerId = c1.ownerId);
                    }
                    else{
                        // Assign the Case using Round Robin mechanism                    
                        cse.OwnerId = userGrp[math.mod(Integer.ValueOf(caseNumber) + 1, Integer.ValueOf(System.Label.Sales_Team_Queue_Members_Count))].UserOrGroupId;
                        cse.TempOwnerId1__c = userGrp[math.mod(Integer.ValueOf(caseNumber) + 1, Integer.ValueOf(System.Label.Sales_Team_Queue_Members_Count))].UserOrGroupId;
                        updAccount = new Account(Id = c1.AccountId ,ownerId = cse.ownerId);
                        updContact = new Contact(Id = c1.Id ,ownerId = cse.ownerId);
                        //System.debug('NDEBUG MOD Value:::' + math.mod(Integer.ValueOf(c.CaseNumber) + 1, Integer.ValueOf(System.Label.Sales_Team_Queue_Members_Count)));
                    }
                    //cse.OwnerId = userGrp[math.mod(Integer.ValueOf(caseNumber) + 1, Integer.ValueOf(System.Label.Sales_Team_Queue_Members_Count))].UserOrGroupId;
                }
                
                if(requestLead!=null){
                    cse.Additional_Notes__c  = 'First Name:'+' '+requestLead.firstName+'\n'+
                        'Last Name:'+' '+requestLead.lastName+'\n'+
                        'Email:'+' '+requestLead.Email+'\n'+
                        'Listing Id:'+' '+requestLead.listingId+'\n'+
                        'Listing Source:'+' '+requestLead.listingSource+'\n'+
                        'Phone:'+' '+requestLead.phone+'\n'+
                        'RS Account Id:'+' '+requestLead.rsAccountId+'\n'+
                        'RS Contact Id:'+' '+requestLead.rsContactId+'\n'+
                        'Time Frame For Investing:'+' '+requestLead.timeframeForInvesting+'\n'+
                        'Total Capital Available:'+' '+requestLead.totalCapitalAvailable+'\n'+
                        'Financing:'+' '+requestLead.financing+'\n'+
                        'Buyer Broker Name:'+' '+requestLead.buyerBrokerName+'\n'+
                        'Buyer Broker Brokerage Name:'+' '+requestLead.buyerBrokerBrokerageName+'\n'+
                        'Buyer Broker Phone:'+' '+requestLead.buyerBrokerPhone+'\n'+
                        'Buyer Broker Email:'+' '+requestLead.buyerBrokerEmail+'\n'+
                        'Property Address:'+' '+requestLead.propertyAddress+'\n'+
                        'Buyer Account Id:'+' '+requestLead.buyerAccountId+'\n'+
                        'Allowable Sale Type:'+' '+requestLead.allowableSaleTypes+'\n'+
                        'Description:'+' '+requestLead.description+'\n';
                    
                    cse.Description = requestLead.description;
                }
            }
        }  
        
        List<SObject> objects = new List<SObject>();
        if(updAccount != null){
            objects.add(updAccount);
        }
        if(updContact != null){
            objects.add(updContact);
        }
        if(updLead != null){
            objects.add(updLead);            
        }
        
        if(objects != null && objects.size() >0){
            //update objects;
            Database.SaveResult [] updateResult = Database.update(objects, false);
        }
        return cse;
        
    }
    
    public static string formatPhone(String phoneNumber){
        String fphone = '';
        if(String.isNotBlank(phoneNumber)){
            fphone = phoneNumber.replaceAll('\\D','');
            fphone = fphone.right(10);
            if(fphone.length() == 10){
                fphone = '(' + fphone.substring(0, 3) + ') ' + fphone.substring(3, 6) + '-' + fphone.substring(6,10);
            }
            else if(fphone.length() == 11){
                fphone = '(' + fphone.substring(1, 4) + ') ' + fphone.substring(4, 7) + '-' + fphone.substring(7,11);
            }
            System.debug('-fphone-'+fphone);
        }
        return fphone;
    }
    public static string soqlFormatPhone(String phoneNumber){
        String fphone = phoneNumber.replaceAll('\\D','');
        fphone = fphone.right(10);
        if(fphone.length() == 10){
            fphone = fphone.substring(0, 3) + fphone.substring(3, 6) + fphone.substring(6,10);
        }
        else if(fphone.length() == 11){
            fphone = fphone.substring(1, 4)+ fphone.substring(4, 7)+ fphone.substring(7,11);
        }
        return fphone;
    }
}
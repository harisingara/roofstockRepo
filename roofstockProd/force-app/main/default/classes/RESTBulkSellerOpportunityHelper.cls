global class RESTBulkSellerOpportunityHelper {
    global class SellerOpportunitiesWrap{
        global List<SellerOpportunities> sellerOpportunityList;
    }
    global class SellerOpportunities{
        global string propertyState;
        global Integer bulkSaleNumberOfProperties;
        global String sellerNotes;
        global Integer sellerBpmOpportunityId;
        global String sellerContactEmail;
        global String SellerContactphone;
        global String SellerFirstName;
        global String SellerLastName;
        
    }
    
    global class PostResponse {
        global ResponseWrapper responseBody;
        global PostResponse(List<ResponseBody> sellerOpportunityResponse) {
            this.responseBody = new ResponseWrapper(sellerOpportunityResponse);
        }
    }
    global class ResponseWrapper {  
        global List<ResponseBody> sellerOpportunityResponse;  
        global ResponseWrapper(){
            sellerOpportunityResponse = new List<ResponseBody>();
        }
        global ResponseWrapper(List<ResponseBody> sellerOpportunityResponse) {
            this.sellerOpportunityResponse = sellerOpportunityResponse;
        }
    } 
    global class ResponseBody{
        global String salesforceId;
        global String sellerContactEmail;
        global ResponseBody(String salesforceId,String sellerContactEmail) {
            this.salesforceId = salesforceId;
            this.sellerContactEmail = sellerContactEmail;
        }
    }
    
    global static PostResponse createOpportunities(List<SellerOpportunities> sellerOpportunityList) {
        List<ResponseBody> sellerOpportunityResponseList = new List<ResponseBody>();
        Set<String> emailSet = new Set<String>();
        Set<String> phoneSet = new Set<String>();
        for(SellerOpportunities sellerOps:sellerOpportunityList){
            if(sellerOps.sellerContactEmail != null){
                emailSet.add(sellerOps.sellerContactEmail);   
            }
            if(sellerOps.SellerContactphone != null){
                phoneSet.add(sellerOps.SellerContactphone);
            }
            
        }
        
        string queueName = '';                                        
        queueName = 'Inbound_Supply';
        List<Group> lstQueueRecords = [Select Id from Group where Type = 'Queue' and developername=:queueName];                                          
        Map<String,Lead> emailLeadMap= new Map<String,Lead>();
        Map<String,Lead> phoneLeadMap= new Map<String,Lead>();
        /*Map<String,Contact> emailContactMap= new Map<String,Contact>();
Map<String,Contact> phoneContactMap= new Map<String,Contact>();*/
        Map<String,String> contactAccountMap = new Map<String,String>();
        //check for matching Lead
        //
        
        
        List<Lead> matchingLeads = [select id,Email,Phone,MobilePhone  from lead where ((email IN:emailSet OR Phone IN:phoneSet OR mobilePhone IN:phoneSet) and (isconverted=false))];
        for(Lead matchLead : matchingLeads){
            if(matchLead.Email!=null){
                emailLeadMap.put(matchLead.Email,matchLead);
            }
            if(matchLead.Phone!=null){
                phoneLeadMap.put(matchLead.Phone,matchLead);
            }
            if(matchLead.MobilePhone!=null){
                phoneLeadMap.put(matchLead.MobilePhone,matchLead);
            }
        }
        
        //check for matching Contact
        List<Contact> matchingContacts = [select id,AccountId,Email,Phone,MobilePhone  from Contact where ((email IN:emailSet OR Phone IN:phoneSet OR mobilePhone IN:phoneSet))];
        for(Contact matchContact : matchingContacts){
            contactAccountMap.put(matchContact.Id,matchContact.AccountId);
            
        }
        
        
        
        List<SellerOpportunities> matchingSellerOpportunityList = new List<SellerOpportunities>();
        List<SellerOpportunities> matchingConSellerOpportunityList = new List<SellerOpportunities>();
        List<SellerOpportunities> newSellerOpportunityList = new List<SellerOpportunities>();
        
        for(SellerOpportunities inputOpty:sellerOpportunityList){
            if(emailLeadMap.containsKey(inputOpty.sellerContactEmail) || phoneLeadMap.containsKey(inputOpty.SellerContactphone)){
                matchingSellerOpportunityList.add(inputOpty);
            }
            
            else{
                newSellerOpportunityList.add(inputOpty);
            }
            
        }
        
        Map<String,String> unMatchedLeadOpportunityMap = new Map<String,String>();
        Map<String,String> matchedLeadOpportunityMap = new Map<String,String>();
        
        if(newSellerOpportunityList.size() > 0){
            unMatchedLeadOpportunityMap = createNewLeadAndOpportunity(newSellerOpportunityList,contactAccountMap,lstQueueRecords);                      
        }
        
        if(matchingSellerOpportunityList.size() > 0){
            matchedLeadOpportunityMap = matchingSellerOpportunity(matchingSellerOpportunityList,contactAccountMap,emailLeadMap,phoneLeadMap,lstQueueRecords);                      
        }
        
        for(String opId : unMatchedLeadOpportunityMap.keySet()){
            sellerOpportunityResponseList.add(new ResponseBody(opId,unMatchedLeadOpportunityMap.get(opId)));
        }
        for(String opId : matchedLeadOpportunityMap.keySet()){
            sellerOpportunityResponseList.add(new ResponseBody(opId,matchedLeadOpportunityMap.get(opId)));
        }
        
        postResponse res = new postResponse(sellerOpportunityResponseList);
        return res;
        
    }
    
    public static Map<String,String> createNewLeadAndOpportunity(List<SellerOpportunities> newSellerOpportunityList,Map<String,String> contactAccountMap,List<Group> lstQueueRecords){
        Id Profile_id = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User u = [select Id from User where ProfileId =: Profile_id and isActive=true][0];
        Id retailRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        List<Lead> newLeadList = new List<Lead>();
        Map<String,SellerOpportunities> emailInputSellerOptMap = new Map<String,SellerOpportunities>();
        Map<String,SellerOpportunities> phoneInputSellerOptMap = new Map<String,SellerOpportunities>();
        Map<String,Contact> emailContactMap = new Map<String,Contact>();
        Map<String,Contact> phoneContactMap = new Map<String,Contact>();
        //Matching Contact
        List<Contact> matchingContactList = [select Id,Email,Phone,Seller_BPM_Opportunity_Id__c,AccountId,MobilePhone from Contact where Id IN:contactAccountMap.keySet()];
        for(Contact con : matchingContactList){
            if(con.Email!=null){
                emailContactMap.put(con.Email,con);
            }
            if(con.MobilePhone!=null){
                phoneContactMap.put(con.MobilePhone,con);
            }
            if(con.Phone!=null){
                phoneContactMap.put(con.Phone,con);
            }
        }
        
        for(SellerOpportunities newSO : newSellerOpportunityList){
            emailInputSellerOptMap.put(newSO.sellerContactEmail,newSO);
            phoneInputSellerOptMap.put(newSO.SellerContactphone,newSO);
            Lead new_lead = new Lead();
            new_lead.firstname = newSO.SellerFirstName;
            new_lead.lastname = newSO.SellerLastName;
            new_lead.Lead_Interest__c  = 'Selling Properties'; 
            new_lead.Company =  newSO.SellerFirstName + ' ' + newSO.SellerLastName ;
            new_lead.LeadSource = 'Roofstock Registered';
            new_lead.RecordTypeId = retailRecordTypeId;
            new_lead.email = newSO.sellerContactEmail;
            new_lead.mobilePhone = newSO.SellerContactphone;
            new_lead.Phone = newSO.SellerContactphone;
            new_lead.Property_State__c = newSO.propertyState;
            new_lead.Seller_Notes__c = newSO.sellerNotes;
            new_lead.Seller_BPM_Opportunity_Id__c = newSO.sellerBpmOpportunityId;
            new_lead.Bulk_Sale_Number_of_Properties__c = newSO.bulkSaleNumberOfProperties;
            System.debug('=queue id='+lstQueueRecords[0].Id);
            if(lstQueueRecords.size()>0){
                if(Test.isRunningTest()){
                    new_lead.OwnerId = u.Id;
                }
                else{
                    new_lead.OwnerId = lstQueueRecords[0].Id;
                }
            }
            newLeadList.add(new_lead);
        }
        
        if(newLeadList.size()>0){
            insert newLeadList;
        }
        
        Map<String,String> conAccountMap = new Map<String,String>();
        //Convert Leads
        List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();
        for(lead l: newLeadList){
            System.debug('=ownerId='+l.ownerId);
            Database.LeadConvert tempLC = new Database.LeadConvert();
            tempLC.setLeadId(l.id);
            tempLC.setDoNotCreateOpportunity(True); //we will create opportunity later!
            if(emailContactMap.containsKey(l.Email)){
                String contactId = emailContactMap.get(l.Email).Id;
                String AccountId = emailContactMap.get(l.Email).AccountId;
                tempLC.setContactId(contactId);
                tempLC.setAccountId(AccountId);
            }
            else if(phoneContactMap.containsKey(l.MobilePhone)){
                String contactId = phoneContactMap.get(l.MobilePhone).Id;
                String AccountId = phoneContactMap.get(l.MobilePhone).AccountId;
                tempLC.setContactId(contactId);
                tempLC.setAccountId(AccountId);
            }
            else if(phoneContactMap.containsKey(l.Phone)){
                String contactId = phoneContactMap.get(l.Phone).Id;
                String AccountId = phoneContactMap.get(l.Phone).AccountId;
                tempLC.setContactId(contactId);
                tempLC.setAccountId(AccountId);
            }
            tempLC.setConvertedStatus('Qualified');
            MassLeadconvert.add(tempLC);
        }
        List<Database.LeadConvertResult> lc = Database.convertLead(MassLeadconvert);
        for(Database.LeadConvertResult lctemp: lc){
            system.debug(lctemp.getAccountId());
            system.debug(lctemp.getContactId());
            conAccountMap.put(lctemp.getContactId(),lctemp.getAccountId());
        }
        
        List<Contact> conList = [select Id,Email,Phone,mobilePhone,Property_State__c,Account.OwnerId,
                                 Seller_Notes__c,Seller_BPM_Opportunity_Id__c,Bulk_Sale_Number_of_Properties__c from Contact where Id IN:conAccountMap.keyset()];
        
        
        
        Map<String,String> opMap = createOpportunities(conList,emailInputSellerOptMap,phoneInputSellerOptMap);
        
        return opMap;         
    }
    
    public static Map<String,String> matchingSellerOpportunity(List<SellerOpportunities> matchingSellerOpportunityList,Map<String,String> contactAccountMap,Map<String,Lead> emailLeadsMap,Map<String,Lead> phoneLeadMap,List<Group> lstQueueRecords){
        Id Profile_id = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User u = [select Id from User where ProfileId =: Profile_id and isActive=true][0];
        Id retailRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        
        List<Lead> leadUpdateList = new List<Lead>();
        Map<String,Contact> emailContactMap = new Map<String,Contact>();
        Map<String,Contact> phoneContactMap = new Map<String,Contact>();
        Map<String,SellerOpportunities> emailInputSellerOptMap = new Map<String,SellerOpportunities>();
        Map<String,SellerOpportunities> phoneInputSellerOptMap = new Map<String,SellerOpportunities>();
        List<Contact> matchingContactList = [select Id,Email,Phone,Seller_BPM_Opportunity_Id__c,AccountId,MobilePhone from Contact where Id IN:contactAccountMap.keySet()];
        for(Contact con : matchingContactList){
            if(con.Email!=null){
                emailContactMap.put(con.Email,con);
            }
            if(con.MobilePhone!=null){
                phoneContactMap.put(con.MobilePhone,con);
            }
            if(con.Phone!=null){
                phoneContactMap.put(con.Phone,con);
            }
        }
        for(SellerOpportunities inputMatchOps : matchingSellerOpportunityList){
            emailInputSellerOptMap.put(inputMatchOps.sellerContactEmail,inputMatchOps);
            phoneInputSellerOptMap.put(inputMatchOps.SellerContactphone,inputMatchOps);
            if(emailLeadsMap.containsKey(inputMatchOps.sellerContactEmail)){
                Lead ld = emailLeadsMap.get(inputMatchOps.sellerContactEmail);
                ld.RecordTypeId = retailRecordTypeId;
                //ld.Status ='New';
                //ld.No_Convert_Reason__c = 'New';
                if(Test.isRunningTest()){
                    ld.OwnerId = u.Id;
                }
                else{
                    ld.OwnerId = lstQueueRecords[0].Id;
                }
                ld.Property_State__c = inputMatchOps.propertyState;
                ld.Bulk_Sale_Number_of_Properties__c = inputMatchOps.bulkSaleNumberOfProperties;
                ld.Seller_Notes__c = inputMatchOps.sellerNotes;
                ld.Seller_BPM_Opportunity_Id__c = inputMatchOps.sellerBpmOpportunityId;
                leadUpdateList.add(ld);
            }
            else if(phoneLeadMap.containsKey(inputMatchOps.SellerContactphone)){
                Lead ld = phoneLeadMap.get(inputMatchOps.SellerContactphone);
                ld.RecordTypeId = retailRecordTypeId;
                if(Test.isRunningTest()){
                    ld.OwnerId = u.Id;
                }
                else{
                    ld.OwnerId = lstQueueRecords[0].Id;
                }
                ld.Property_State__c = inputMatchOps.propertyState;
                ld.Bulk_Sale_Number_of_Properties__c = inputMatchOps.bulkSaleNumberOfProperties;
                ld.Seller_Notes__c = inputMatchOps.sellerNotes;
                ld.Seller_BPM_Opportunity_Id__c = inputMatchOps.sellerBpmOpportunityId;
                leadUpdateList.add(ld);
            }
            
        }
        
        if(leadUpdateList.size()>0){
            update leadUpdateList;
        }
        
        Map<String,String> conAccMap = new Map<String,String>();        
        //Convert Leads
        List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();
        for(lead l: leadUpdateList){
            
            Database.LeadConvert tempLC = new Database.LeadConvert();
            tempLC.setLeadId(l.id);
            
            tempLC.setDoNotCreateOpportunity(True); //we will create opportunity later!
            
            if(emailContactMap.containsKey(l.Email)){
                String contactId = emailContactMap.get(l.Email).Id;
                String AccountId = emailContactMap.get(l.Email).AccountId;
                tempLC.setContactId(contactId);
                tempLC.setAccountId(AccountId);
            }
            else if(phoneContactMap.containsKey(l.MobilePhone)){
                String contactId = phoneContactMap.get(l.MobilePhone).Id;
                String AccountId = phoneContactMap.get(l.MobilePhone).AccountId;
                tempLC.setContactId(contactId);
                tempLC.setAccountId(AccountId);
            }
            else if(phoneContactMap.containsKey(l.Phone)){
                String contactId = phoneContactMap.get(l.Phone).Id;
                String AccountId = phoneContactMap.get(l.Phone).AccountId;
                tempLC.setContactId(contactId);
                tempLC.setAccountId(AccountId);
            }
            tempLC.setConvertedStatus('Qualified');
            
            MassLeadconvert.add(tempLC);
        }
        List<Database.LeadConvertResult> lc = Database.convertLead(MassLeadconvert);
        for(Database.LeadConvertResult lctemp: lc){
            system.debug(lctemp.getAccountId());
            system.debug(lctemp.getContactId());
            conAccMap.put(lctemp.getContactId(),lctemp.getAccountId());
            
        }
        
        List<Contact> conList = [select Id,Email,Phone,mobilePhone,Property_State__c,AccountId,Account.OwnerId,
                                 Seller_Notes__c,Seller_BPM_Opportunity_Id__c,Bulk_Sale_Number_of_Properties__c from Contact where Id IN:conAccMap.keyset()];
        
        
        
        
        Map<String,String> opMap = createOpportunities(conList,emailInputSellerOptMap,phoneInputSellerOptMap);
        return opMap;
    }
    
    /** Create Opportunities  **/
    public static Map<String,String> createOpportunities(List<Contact> conList,Map<String,SellerOpportunities> emailInputSellerOptMap,Map<String,SellerOpportunities> phoneInputSellerOptMap){
        Id opprRetailRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        List<Opportunity> newOpportunityList = new List<Opportunity>();
        List<Contact> updateContactList = new List<Contact>();
        for(Contact con : conList){
            SellerOpportunities so;
            if(emailInputSellerOptMap.containsKey(con.Email)){
                so = emailInputSellerOptMap.get(con.Email);
            }
            else if(phoneInputSellerOptMap.containsKey(con.phone)){
                so = emailInputSellerOptMap.get(con.phone);
            }
            else if(phoneInputSellerOptMap.containsKey(con.mobilePhone)){
                so = emailInputSellerOptMap.get(con.mobilePhone);
            }
            if(so!=null){
                con.Property_State__c = so.propertyState;
                con.Bulk_Sale_Number_of_Properties__c = so.bulkSaleNumberOfProperties;
                con.Seller_Notes__c = so.sellerNotes;
                con.Seller_BPM_Opportunity_Id__c = so.sellerBpmOpportunityId;
                updateContactList.add(con);
            }
        }
        
        if(updateContactList.size()>0){
            update updateContactList;
        }
        
        
        
        
        for(Contact con : conList){
            
            SellerOpportunities so;
            if(emailInputSellerOptMap.containsKey(con.Email)){
                so = emailInputSellerOptMap.get(con.Email);
            }
            else if(phoneInputSellerOptMap.containsKey(con.phone)){
                so = emailInputSellerOptMap.get(con.phone);
            }
            else if(phoneInputSellerOptMap.containsKey(con.mobilePhone)){
                so = emailInputSellerOptMap.get(con.mobilePhone);
            }
            
            System.debug('-so-'+so);
            System.debug('-con-'+con);
            if(con!=null && so!=null){
                if((so.sellerContactEmail == con.Email) || (so.SellerContactphone == con.Phone) || (so.SellerContactphone == con.MobilePhone)){
                    Opportunity opp = new Opportunity();
                    opp.accountId = con.AccountId;
                    opp.SellerContactName__c = con.Id;  
                    opp.name = 'Property';
                    opp.RecordTypeId = opprRetailRecordTypeId;
                    opp.StageName='Submission Started';
                    opp.CloseDate = date.today();
                    opp.OwnerId = con.Account.OwnerId;
                    if(emailInputSellerOptMap.containskey(con.Email)){
                        opp.Property_State__c = con.Property_State__c; 
                        opp.Seller_Notes__c = con.Seller_Notes__c;
                        opp.Seller_BPM_Opportunity_Id__c = con.Seller_BPM_Opportunity_Id__c;
                        opp.Bulk_Sale_Number_of_Properties__c = con.Bulk_Sale_Number_of_Properties__c;
                    }
                    else if(phoneInputSellerOptMap.containskey(con.Phone) || phoneInputSellerOptMap.containskey(con.mobilePhone)){
                        opp.Property_State__c = con.Property_State__c; 
                        opp.Seller_Notes__c = con.Seller_Notes__c;
                        opp.Seller_BPM_Opportunity_Id__c = con.Seller_BPM_Opportunity_Id__c;
                        opp.Bulk_Sale_Number_of_Properties__c = con.Bulk_Sale_Number_of_Properties__c;
                    }
                    newOpportunityList.add(opp);
                }
            }
        }
        
        if(newOpportunityList.size()>0){
            insert newOpportunityList;
        }
        //sellerFiles();
        
        
        
        List<Opportunity> finalOpList = [select Id,SellerContactName__c,SellerContactName__r.Email from Opportunity where Id IN:newOpportunityList];
        
        List<OpportunityContactRole> oppContactRoleList = new List<OpportunityContactRole>();
        Map<String,String> opportunityEmailMap = new Map<String,String>();
        for(Opportunity opp : finalOpList){
            opportunityEmailMap.put(opp.Id,opp.SellerContactName__r.Email);
            OpportunityContactRole ocr = new OpportunityContactRole();
            ocr.ContactId = opp.SellerContactName__c;
            ocr.OpportunityId = opp.Id;
            ocr.IsPrimary = true;
            oppContactRoleList.add(ocr);
        }
        if(!oppContactRoleList.isEmpty()){
            insert oppContactRoleList;
        }
        
        return opportunityEmailMap;
    }
    
    
}
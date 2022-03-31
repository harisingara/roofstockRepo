global class RESTLeasingActivityHelperRently {
    
    
    global class LeasingActivityData{
        global List<LeasingActivityWrapper> leasingActivityList;
    }
    global class LeasingActivityWrapper {
        global string email;
        global string firstName;
        global string lastName;
        global string phone;
        //global string address;
        global string activityType;
        global string activityId;
        global datetime timeStamp;
        global string timezone;
        global string source;
        global string listingId;
        global string prospectId;
        
        global string transferredToListingId;
        global string feedback;
    }

    global class LeasingActivityResponse {
        global string activityId;
        global string salesforceId;
    }
 
    global class PostResponse {
        global String responseBody;
    }
    
    static Id leasingAccountRecordTypeId = RecordTypes.leasingAccountRecordTypeId;
    static Id leasingContactRecordTypeId = RecordTypes.leasingContactRecordTypeId;
    static Id leasingOpportunityRecordTypeId = RecordTypes.leasingOpportunityRecordTypeId;    
    static Id leasingSecApplOppRecordTypeId = RecordTypes.leasingSecApplOppRecordTypeId;
    static Id leasingLeadRecordTypeId = RecordTypes.leasingLeadRecordTypeId;

    global static List<LeasingActivityResponse> AddLeasingActivity(list <LeasingActivityWrapper> leasingActivityList) {
        
        List<LeasingActivityResponse> finalResp = new List <LeasingActivityResponse> ();
        
        System.debug('NDEBUG lactlist'+ leasingActivityList);
        
        
        List <LeasingActivityWrapper> woActivityLeads = new List <LeasingActivityWrapper> ();
        Set<String> woActivityphoneSet = new Set<String>();
        Set<String> woActivityemailSet = new Set<String>();
        Set<String> woActivityrentlListingSet = new Set<String>();
        
        List <LeasingActivityWrapper> withActivityLeads = new List <LeasingActivityWrapper> ();
        Set<String> withActivityphoneSet = new Set<String>();
        Set<String> withActivityemailSet = new Set<String>();
        Set<String> withActivityrentlListingSet = new Set<String>();
        
        
        for(LeasingActivityWrapper lawrap: leasingActivityList){
            if(String.isNotBlank(lawrap.listingId)){
                if(lawrap.activityType == 'phone_inquiry' || lawrap.activityType == 'email_inquiry'){
                	woActivityLeads.add(lawrap);
                    if (String.isNotBlank(lawrap.email)) {
              			woActivityemailSet.add(lawrap.email);
            		}
                    if (String.isNotBlank(lawrap.phone)) {
                    	woActivityphoneSet.add(lawrap.phone);
                    } //if2
            		woActivityrentlListingSet.add(lawrap.listingId);
                    if(String.isNotBlank(lawrap.transferredToListingId)){
                        woActivityrentlListingSet.add(lawrap.listingId);
                    }
                }
                else{
                    withActivityLeads.add(lawrap);
                    if (String.isNotBlank(lawrap.email)) {
              			withActivityemailSet.add(lawrap.email);
            		}
                    if (String.isNotBlank(lawrap.phone)) {
                    	withActivityphoneSet.add(lawrap.phone);
                    } //if2
            		withActivityrentlListingSet.add(lawrap.listingId);
                    if(String.isNotBlank(lawrap.transferredToListingId)){
                        withActivityrentlListingSet.add(lawrap.listingId);
                    }
                }
            }
        }
        
        if(woActivityLeads != null && woActivityLeads.size() >0){
            List<LeasingActivityResponse> woActivityLeadsResp = processLeadsWithNoActivities(woActivityLeads, woActivityemailSet, woActivityphoneSet, woActivityrentlListingSet );
            if(woActivityLeadsResp != null && woActivityLeadsResp.size() >0){
                finalResp.addAll(woActivityLeadsResp);
            }
        }
        if(withActivityLeads != null && withActivityLeads.size() >0){
            List<LeasingActivityResponse> withActivityLeadsResp = processLeadsWithActivities(withActivityLeads, withActivityemailSet, withActivityphoneSet, withActivityrentlListingSet);
        	if(withActivityLeadsResp != null && withActivityLeadsResp.size() >0){
                finalResp.addAll(withActivityLeadsResp);
            }
        }   
        return finalResp;
    }
    
    Public static String getUUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid =
            h.SubString(0, 8) +
            '-' +
            h.SubString(8, 12) +
            '-' +
            h.SubString(12, 16) +
            '-' +
            h.SubString(16, 20) +
            '-' +
            h.substring(20);
        
        return guid;
    }

    
    Public static List<LeasingActivityResponse> processLeadsWithNoActivities(
    																		List<LeasingActivityWrapper> woActivityLeads,
        																	Set <String> woActivityemailSet,
        																	Set <String> woActivityphoneSet,
        																	Set <String> woActivityrentlListingSet
        
  	){
        List<LeasingActivityResponse> response = new List<LeasingActivityResponse>();
        // Get the Rental Listings
        List <Rental_Listing__c> rlList = [Select Id, Rental_Listing_Id__c  from Rental_Listing__c  WHERE Rental_Listing_Id__c IN: woActivityrentlListingSet];
        Map <String, Id> rlMap = new Map <String, Id> ();
        for(Rental_Listing__c rl: rlList){
           rlMap.put(rl.Rental_Listing_Id__c, rl.Id); 
        }
        
        
        // Get the contacts
        Set <Id> contctIdSet = RESTUtilities.GetContactIdsWithMatchingPhoneEmail(woActivityphoneSet, woActivityemailSet);
        List <Opportunity> leasingOppList = [SELECT Id, Primary_Leasing_Contact__c, Primary_Leasing_Contact__r.email, Primary_Leasing_Contact__r.phone, Rental_Listing__c,  
                              Rental_Listing__r.Rental_Listing_Id__c FROM Opportunity WHERE RecordtypeId =: RecordTypes.leasingOpportunityRecordTypeId AND Primary_Leasing_Contact__c IN: contctIdSet
                              AND Rental_Listing__r.Rental_Listing_Id__c  IN : woActivityrentlListingSet AND (NOT Stagename LIKE '%Closed%')];
                                            
        System.debug('NDEBUG Got these existing Opps::' + leasingOppList);
        Map <String, Opportunity> OppMap = new Map <String, Opportunity> ();
        for(Opportunity Opp: leasingOppList){
            if(String.isNotBlank(Opp.Primary_Leasing_Contact__r.email)){
                OppMap.put(Opp.Primary_Leasing_Contact__r.email, Opp);
            }
            if(String.isNotBlank(Opp.Primary_Leasing_Contact__r.phone)){
                OppMap.put(Opp.Primary_Leasing_Contact__r.phone, Opp);
            }
        }
        
        System.debug('NDEBUG Got these Opps:::' + OppMap);
        
        // Get the Leads
        Set <Id> leadIdSet = RESTUtilities.GetLeadIdsWithMatchingPhoneEmail(woActivityphoneSet, woActivityemailSet);
        // Get the Lead Leasing Rental Units records
        Map <String, Lead_Leasing_Rental_Unit__c> llruMap = new Map <String, Lead_Leasing_Rental_Unit__c> ();
        
        List <Lead_Leasing_Rental_Unit__c > lruList = [SELECT Id, Rental_Listing__c , Rental_Listing_Id__c , Lead__c , Lead__r.Phone, Lead__r.email
                                                      FROM Lead_Leasing_Rental_Unit__c WHERE Rental_Listing_Id__c IN: woActivityrentlListingSet 
                                                      AND Lead__c IN: leadIdSet AND Converted_To_Opp__c =: FALSE];
        
        
        for(Lead_Leasing_Rental_Unit__c llru: lruList){
            if(String.isNotBlank(llru.Lead__r.email)){
                llruMap.put(llru.Lead__r.email, llru);
            }
            if(String.isNotBlank(llru.Lead__r.phone)){
                llruMap.put(llru.Lead__r.phone, llru);
            }
        }
        
        
        
        // Get the lead Info
        Map <String, lead> leadInfoMap = RESTUtilities.GetLeadsWithMatchingPhoneEmail(woActivityphoneSet, woActivityemailSet);
        
        Set <Id> respLeadIdSet = new Set <Id> ();
        Map <Id, LeasingActivityWrapper> lrusToBeCreated = new Map <Id, LeasingActivityWrapper> ();
        List <LeasingActivityWrapper> leadsLrusToBeCreated = new List <LeasingActivityWrapper> ();
        
        List <LeasingActivityResponse> existingLdsOppsResp = new List <LeasingActivityResponse> ();
        
        for(LeasingActivityWrapper lawrap: woActivityLeads){
            Boolean OppLruFound = false;
            Boolean leadFound = false;
            String leadId = '';
            if(String.isNotBlank(lawrap.email)){
                if(OppMap.containsKey(lawrap.email)){
                    if(lawrap.listingId == OppMap.get(lawrap.email).Rental_Listing__r.Rental_Listing_Id__c){
                        LeasingActivityResponse lar= new LeasingActivityResponse();
                        lar.activityId = lawrap.activityId;
                        lar.salesforceId = OppMap.get(lawrap.email).Id;
                        existingLdsOppsResp.add(lar);
                       	OppLruFound = true; 
                    }
                }
                if(!OppLruFound && llruMap.containsKey(lawrap.email)){
                    if(lawrap.listingId == llruMap.get(lawrap.email).Rental_Listing_Id__c){
                       OppLruFound = true; 
                       LeasingActivityResponse lar= new LeasingActivityResponse();
                       lar.activityId = lawrap.activityId;
                       lar.salesforceId = llruMap.get(lawrap.email).lead__c;
                       existingLdsOppsResp.add(lar);
                       //respLeadIdSet.add(llruMap.get(lawrap.email).lead__c);
                    }
                }
            }
            if(String.isNotBlank(lawrap.phone) && !OppLruFound){
                if(OppMap.containsKey(lawrap.phone)){
                    if(lawrap.listingId == OppMap.get(lawrap.phone).Rental_Listing__r.Rental_Listing_Id__c){
                       OppLruFound = true; 
                       LeasingActivityResponse lar= new LeasingActivityResponse();
                       lar.activityId = lawrap.activityId;
                       lar.salesforceId = OppMap.get(lawrap.phone).Id;
                       existingLdsOppsResp.add(lar);
                    }
                }
                if(!OppLruFound && llruMap.containsKey(lawrap.phone)){
                    if(lawrap.listingId == llruMap.get(lawrap.phone).Rental_Listing_Id__c){
                       OppLruFound = true; 
                       LeasingActivityResponse lar= new LeasingActivityResponse();
                       lar.activityId = lawrap.activityId;
                       lar.salesforceId = llruMap.get(lawrap.phone).lead__c;
                       existingLdsOppsResp.add(lar);
                       //respLeadIdSet.add(llruMap.get(lawrap.email).lead__c);
                    }
                }
            }
            
            if(!OppLruFound && String.isNotBlank(lawrap.email)){
                if(leadInfoMap.containsKey(lawrap.email)){
                    leadFound = true;
                    //respLeadIdSet.add(leadInfoMap.get(lawrap.email).Id);
                    lrusToBeCreated.put(leadInfoMap.get(lawrap.email).Id, lawrap);
                }
            }
            if(!OppLruFound && !leadFound && String.isNotBlank(lawrap.phone)){
                if(leadInfoMap.containsKey(lawrap.phone)){
                    leadFound = true;
                    //respLeadIdSet.add(leadInfoMap.get(lawrap.phone).Id);
                    lrusToBeCreated.put(leadInfoMap.get(lawrap.phone).Id, lawrap);
                }
            }
            if(!OppLruFound && !leadFound){
                leadsLrusToBeCreated.add(lawrap);
            }
        }
        
        if(!lrusToBeCreated.isEmpty()){
            // Create LRUs
            List<LeasingActivityResponse> response1 = createLrus(lrusToBeCreated, rlMap);
            if(response1 != null && response1.size() >0){
            	response.addAll(response1);
        	}
        }
        if(!leadsLrusToBeCreated.isEmpty()){
            // Create Leads and LRUs
            List<LeasingActivityResponse> response2 = createLeadsLrus(leadsLrusToBeCreated, rlMap);
            if(response2 != null && response2.size() >0){
            	response.addAll(response2);
        	}
        }
        if(existingLdsOppsResp != null && existingLdsOppsResp.size() >0){
            response.addAll(existingLdsOppsResp);
        }
        return response;
	}

	Public Static List<LeasingActivityResponse> createLeadsLrus (List <LeasingActivityWrapper> leadsLrusToBeCreated, Map <String, Id> rlMap){
        List<LeasingActivityResponse> response = new List<LeasingActivityResponse>();
        List <Id> respLeadIds = new List <Id> ();
        Set <String> emailSet = new Set <String> ();
        Set <String> phoneSet = new Set <String> ();
        List <Lead> newLeads = new List <Lead> ();
        Set <String> emailPhSet = new Set <String> ();
        for(LeasingActivityWrapper lawrap: leadsLrusToBeCreated){  
            Boolean insertLead = false;
            Lead l = new Lead();           
            l.FirstName = lawrap.FirstName == '' ? 'Unknown' : lawrap.FirstName;
            l.LastName = lawrap.LastName == '' ? 'Unknown' : lawrap.LastName;
            l.company = l.FirstName + ' ' + l.LastName;
            l.LeadSource = lawrap.source;
            l.Source_Created_Date__c = lawrap.timestamp;
            // ownerId = LeasingQueue.Id,
            l.X1_Ideally_when_would_you_buy_your_first__c = Date.today().addDays(14);           
            l.RecordTypeId = RecordTypes.leasingLeadRecordTypeId;
            if(String.isNotBlank(lawrap.phone)){
                l.phone = lawrap.phone;
                if(!phoneSet.contains(lawrap.phone)){
                    phoneSet.add(lawrap.phone);
                    insertLead = true;
                }
                
            }
            if(String.isNotBlank(lawrap.email)){
                l.email = lawrap.email;
                if(!emailSet.contains(lawrap.email)){
                    emailSet.add(lawrap.email);
                    insertLead = true;
                }
            }
            if(insertLead){
                newLeads.add(l);
            }
        }
        if(newLeads != null && newLeads.size() >0){
            Insert newLeads;
        }
        
        // Insert the LRUs
        Map <String, lead> leadInfoMap = new Map <String, lead>();
        leadInfoMap = RESTUtilities.GetLeadsWithMatchingPhoneEmail(phoneSet, emailSet);
        List <Lead_Leasing_Rental_Unit__c> newLrus = new List <Lead_Leasing_Rental_Unit__c> ();
        
        for(LeasingActivityWrapper lawrap: leadsLrusToBeCreated){
            if(rlMap.containsKey(lawrap.listingId)){
                Lead_Leasing_Rental_Unit__c  lru = new Lead_Leasing_Rental_Unit__c  ();
                if(string.isNotBlank(lawrap.email)){
                   lru.Lead__c =  leadInfoMap.get(lawrap.email).Id;
                    respLeadIds.add(leadInfoMap.get(lawrap.email).Id);
                }
                else if(string.isNotBlank(lawrap.phone))
                {
                    lru.Lead__c =  leadInfoMap.get(lawrap.phone).Id; 
                    respLeadIds.add(leadInfoMap.get(lawrap.phone).Id);
                }
                lru.Converted_To_Opp__c = false;
                lru.Rental_Listing__c = rlMap.get(lawrap.listingId);
                lru.Status__c = 'Send SMS';
                newLrus.add(lru);
                LeasingActivityResponse lar= new LeasingActivityResponse();
                lar.activityId = lawrap.activityId;
                lar.salesforceId = lru.Lead__c;
                // la.activityId, opp.id
                response.add(lar);
            }
        }
        if(newLrus != null && newLrus.size() >0){
            Insert newLrus;
        } 
        return response;
    }
    
    Public Static List<LeasingActivityResponse> createLrus (Map <Id, LeasingActivityWrapper> lrusToBeCreated, Map <String, Id> rlMap){
        List<LeasingActivityResponse> response = new List<LeasingActivityResponse>();
        List <Lead_Leasing_Rental_Unit__c> newLrus = new List <Lead_Leasing_Rental_Unit__c> ();
        for(Id key : lrusToBeCreated.keySet()){
            LeasingActivityWrapper lawrap = lrusToBeCreated.get(key);
            if(rlMap.containsKey(lawrap.listingId)){
                Lead_Leasing_Rental_Unit__c  lru = new Lead_Leasing_Rental_Unit__c  ();
                lru.Lead__c = key;
                lru.Converted_To_Opp__c = false;
                lru.Status__c = 'Send SMS';
                lru.Rental_Listing__c = rlMap.get(lawrap.listingId);
                newLrus.add(lru);
                LeasingActivityResponse lar= new LeasingActivityResponse();
                lar.activityId = lawrap.activityId;
                lar.salesforceId = key;
                // la.activityId, opp.id
                response.add(lar);
            }
        }
        if(newLrus != null && newLrus.size() >0){
            Insert newLrus;
        }  
        return response;
    }
    
    Public static List<LeasingActivityResponse> processLeadsWithActivities(
    																		List<LeasingActivityWrapper> withActivityLeads,
        																	Set <String> withActivityemailSet,
        																	Set <String> withActivityphoneSet,
        																	Set <String> withActivityrentlListingSet
        
  	){
        // Get the Rental Listings
        List <Rental_Listing__c> rlList = [Select Id, Rental_Listing_Id__c, Property_Unit__r.property__r.Leasing_Market__c, Property_Unit__r.Name  from Rental_Listing__c  WHERE Rental_Listing_Id__c IN: withActivityrentlListingSet];
        Map <String, Rental_Listing__c> rlMap = new Map <String, Rental_Listing__c> ();
        for(Rental_Listing__c rl: rlList){
           rlMap.put(rl.Rental_Listing_Id__c, rl); 
        }
        
        
        // Get the contacts
        Set <Id> contctIdSet = RESTUtilities.GetContactIdsWithMatchingPhoneEmail(withActivityphoneSet, withActivityemailSet);
        System.debug('NDEBUG withActivityphoneSet:::' + withActivityphoneSet);
        System.debug('NDEBUG withActivityemailSet:::' + withActivityemailSet);
        System.debug('NDEBUG ContactIdSet:::' + contctIdSet);
        //List <Contact> contactList = [Select Id, firstName, lastName, phone, AccountId, email, Recordtype.Name from Contact];
        //System.debug('NDEBUG Got these Contacts:::' + contactList);
        
        List <Opportunity> leasingOppList = [SELECT Id, (Select Id, Leasing__c  from Unit_Leasing__r), Primary_Leasing_Contact__c, Primary_Leasing_Contact__r.email, Primary_Leasing_Contact__r.phone, Rental_Listing__c,  
                              Rental_Listing__r.Rental_Listing_Id__c FROM Opportunity WHERE recordtypeId =: RecordTypes.leasingOpportunityRecordTypeId AND Primary_Leasing_Contact__c IN: contctIdSet
                              AND Rental_Listing__r.Rental_Listing_Id__c  =: withActivityrentlListingSet AND (NOT Stagename LIKE '%Closed%')];
                                            
        Map <String, Opportunity> OppMap = new Map <String, Opportunity> ();
        for(Opportunity Opp: leasingOppList){
            if(String.isNotBlank(Opp.Primary_Leasing_Contact__r.email)){
                OppMap.put(Opp.Primary_Leasing_Contact__r.email, Opp);
            }
            if(String.isNotBlank(Opp.Primary_Leasing_Contact__r.phone)){
                OppMap.put(Opp.Primary_Leasing_Contact__r.phone, Opp);
            }
        }
        
        // Get the Leads
        Set <Id> leadIdSet = RESTUtilities.GetLeadIdsWithMatchingPhoneEmail(withActivityemailSet, withActivityemailSet);
        // Get the Lead Leasing Rental Units records
        List <Lead_Leasing_Rental_Unit__c > lruList = [SELECT Id, Rental_Listing__c , Rental_Listing_Id__c , Lead__c , Lead__r.Phone, Lead__r.email
                                                      FROM Lead_Leasing_Rental_Unit__c WHERE Rental_Listing_Id__c IN: withActivityrentlListingSet 
                                                      AND Lead__c IN: leadIdSet AND Converted_To_Opp__c =: false];
        
        Map <String, Lead_Leasing_Rental_Unit__c> llruMap = new Map <String, Lead_Leasing_Rental_Unit__c> ();
        for(Lead_Leasing_Rental_Unit__c llru: lruList){
            if(String.isNotBlank(llru.Lead__r.email)){
                llruMap.put(llru.Lead__r.email, llru);
            }
            if(String.isNotBlank(llru.Lead__r.phone)){
                llruMap.put(llru.Lead__r.phone, llru);
            }
        }
        
        // Get the lead Info
        Map <String, lead> leadInfoMap = RESTUtilities.GetLeadsWithMatchingPhoneEmail(withActivityphoneSet, withActivityemailSet);
        
        //Set <Id> respLeadIdSet = new Set <Id> ();
        Map <Id, LeasingActivityWrapper> lrusToBeCreated = new Map <Id, LeasingActivityWrapper> ();
        List <LeasingActivityWrapper> leadsLrusToBeCreated = new List <LeasingActivityWrapper> ();
        
        Map <String, LeasingActivityWrapper> actMap = new Map <String, LeasingActivityWrapper> ();
        Map <String, Opportunity> actOppMap = new Map <String, Opportunity> ();
        Map <String, Lead_Leasing_Rental_Unit__c> actLruMap = new Map <String, Lead_Leasing_Rental_Unit__c> ();
        
        Set <String> phoneSet = new Set <String> ();
        Set <String> emailSet = new Set <String> ();
        
        
        for(LeasingActivityWrapper lawrap: withActivityLeads){
            Boolean OppFound = false;
            Boolean LruFound = false;
            String leadId = '';
            if(rlMap.containsKey(lawrap.listingId)){
                if(String.isNotBlank(lawrap.email)){
                    if(OppMap.containsKey(lawrap.email)){
                        if(lawrap.listingId == OppMap.get(lawrap.email).Rental_Listing__r.Rental_Listing_Id__c){
                           OppFound = true; 
                           actOppMap.put(lawrap.activityId, OppMap.get(lawrap.email));
                        }
                    }
                    if(!OppFound && llruMap.containsKey(lawrap.email)){
                        if(lawrap.listingId == llruMap.get(lawrap.email).Rental_Listing_Id__c){
                           LruFound = true; 
                           actLruMap.put(lawrap.activityId, llruMap.get(lawrap.email));
                           emailSet.add(lawrap.email);                          
                        }
                    }
                }
                if(String.isNotBlank(lawrap.phone) && !OppFound && !LruFound){
                    if(OppMap.containsKey(lawrap.phone)){
                        if(lawrap.listingId == OppMap.get(lawrap.phone).Rental_Listing__r.Rental_Listing_Id__c){
                           OppFound = true; 
                           actOppMap.put(lawrap.activityId, OppMap.get(lawrap.phone));
                        }
                    }
                    if(!OppFound && llruMap.containsKey(lawrap.phone)){
                        if(lawrap.listingId == llruMap.get(lawrap.phone).Rental_Listing_Id__c){
                           LruFound = true; 
                           actLruMap.put(lawrap.activityId, llruMap.get(lawrap.phone)); 
                           phoneSet.add(lawrap.phone);
                        }
                    }
                }
            }
        }
        
        
        
        // Convert/Merge the Leads
        Map <String, lead> leadMap = RESTUtilities.GetLeadsWithMatchingPhoneEmail(phoneSet,emailSet);
        Map <String, Contact> contactMap = RESTUtilities.GetContactsWithMatchingPhoneEmail(phoneSet,emailSet);
        Id defaultOwnerId = [Select User_Id__c from Roofstock__mdt where DeveloperName = 'Integration_User' ]?.User_Id__c;
        ConvertMergeLeads(leadMap, contactMap, defaultOwnerId);
        
        // Mark the LRUs as converted
        List <Lead_Leasing_Rental_Unit__c> updLruList = new List <Lead_Leasing_Rental_Unit__c> ();
        Set <Id> lruIdSet = new Set <Id> ();
        
        if(!actLruMap.isEmpty()){
            for(Lead_Leasing_Rental_Unit__c llru : actLruMap.values()){
                if(!lruIdSet.contains(llru.Id)){
                    llru.Converted_To_Opp__c = true;
                    updLruList.add(llru);
                    lruIdSet.add(llru.Id);
                }
            }
        }
        if(updLruList != null && updLruList.size() >0){
            update updLruList;
        }
        
        // Create/Update Opportunity, ORUs and ORUAs
        // Get the latest Contacts
        contactMap = RESTUtilities.GetContactsWithMatchingPhoneEmail(phoneSet,emailSet);
        System.debug('NDEBUG ContactMap :::' +ContactMap);
        System.debug('NDEBUG phoneSet :::' +phoneSet);
        System.debug('NDEBUG emailSet :::' +emailSet);
        List <Opportunity> oppsToBeInserted = new List <Opportunity> ();
        
        Set <Id> prContactIdSet = new Set <Id> ();
        Set <Id> rentalListingIdSet = new Set <Id> ();
        
        Map <String, String> actUniqueMap = new Map <String, String> ();
        Set <String> cntctListIdSet = new Set <String> ();
        
        for(LeasingActivityWrapper lawrap: withActivityLeads){
            if(actLruMap.containsKey(lawrap.activityId) && rlMap.containsKey(lawrap.listingId)){
                String uniqueKey = '';
                //oppActIdSet.add(lawrap.activityId);
                Opportunity opp = new Opportunity();
                String oppName = String.valueOf(Date.today().addDays(14)) + '-' + lawrap.firstName + '-' + lawrap.lastName;

                //replace default oppname with phone or email if name is unknown
                if (String.isNotBlank(lawrap.firstName) &&
                  lawrap.firstName.toLowercase() == 'unknown') {
                      if (String.isNotBlank(lawrap.phone)) {
                          oppName = lawrap.phone;
                      } else if (String.isNotBlank(lawrap.email)) {
                          oppName = lawrap.email;
                      }
                }

                opp.name = oppName;
                opp.RecordTypeId = RecordTypes.leasingOpportunityRecordTypeId;
                opp.Rental_Listing__c  = rlMap.get(lawrap.listingId).Id;
                Boolean emailFnd = false;
                if(String.isNotBlank(lawrap.email)){
                    if(contactMap.containsKey(lawrap.email)){
                        opp.AccountId = contactMap.get(lawrap.email).accountId;
                        opp.Primary_Leasing_Contact__c = contactMap.get(lawrap.email).Id;                        
                        emailFnd = true;
                        uniqueKey = opp.Primary_Leasing_Contact__c + '_' + rlMap.get(lawrap.listingId).Id;
                    }                    
                } 
                
                if(String.isNotBlank(lawrap.phone) && !emailFnd){
                    if(contactMap.containsKey(lawrap.phone)){
                        opp.AccountId = contactMap.get(lawrap.phone).accountId;
                        opp.Primary_Leasing_Contact__c = contactMap.get(lawrap.phone).Id;  
                        uniqueKey = opp.Primary_Leasing_Contact__c + '_' + rlMap.get(lawrap.listingId).Id;
                    }                    
                }
                
                
                opp.StageName = 'New';
                opp.CloseDate =  Date.today().addDays(14);
                opp.LeadSource = lawrap.source;
                opp.ownerId = defaultOwnerId;  //assign david as default owner!
                if(String.isNotBlank(rlMap.get(lawrap.listingId).Property_Unit__r.property__r.Leasing_Market__c)){                
                    opp.Leasing_Market__c = rlMap.get(lawrap.listingId).Property_Unit__r.property__r.Leasing_Market__c;
                }
                actUniqueMap.put(lawrap.activityId, opp.Primary_Leasing_Contact__c + '_' + rlMap.get(lawrap.listingId).Id);
                prContactIdSet.add(opp.Primary_Leasing_Contact__c);
        		rentalListingIdSet.add(rlMap.get(lawrap.listingId).Id);
                if(!cntctListIdSet.contains(uniqueKey)){
                    cntctListIdSet.add(uniqueKey);
                	oppsToBeInserted.add(opp);
                }
            }
        }
        
        if(oppsToBeInserted != null && oppsToBeInserted.size() > 0){
            System.debug('NDEBUG Opps being Inserted :::'+ oppsToBeInserted);
            System.debug('NDEBUG Opps Size being Inserted :::'+ oppsToBeInserted.size());
            Insert oppsToBeInserted;
        }
        
        // Create ORUs
        List <Opportunity> insOppList = [Select Id, Rental_Listing__c, Rental_Listing__r.Name, Primary_Leasing_Contact__c FROM Opportunity where Rental_Listing__c IN: rentalListingIdSet
                                        AND Primary_Leasing_Contact__c IN: prContactIdSet AND RecordTypeId =: RecordTypes.leasingOpportunityRecordTypeId
                                        AND (NOT Stagename LIKE '%Closed%')];
        Map <String, Opportunity> oppUniqueKeyMap = new Map <String, Opportunity> ();
        for(Opportunity Opp: insOppList){
           oppUniqueKeyMap.put(opp.Primary_Leasing_Contact__c + '_' + opp.Rental_Listing__c, Opp); 
        }
        
        List <OpportunityRentalUnit__c> oruList = new List <OpportunityRentalUnit__c> ();
        Set <String> OruCntctLstIdSet = new Set <String> ();
        for(LeasingActivityWrapper lawrap: withActivityLeads){
            if(actLruMap.containsKey(lawrap.activityId)){               
                if(oppUniqueKeyMap.containsKey(actUniqueMap.get(lawrap.activityId))){
                    Opportunity Opp = new Opportunity ();
                    OpportunityRentalUnit__c  oru = new OpportunityRentalUnit__c  ();
                    Opp = oppUniqueKeyMap.get(actUniqueMap.get(lawrap.activityId));
                    oru.Opportunity__c = Opp.Id; 
                    oru.Primary_Leasing_Contact__c = Opp.Primary_Leasing_Contact__c;        
        			oru.name = Opp.Rental_Listing__r.Name;
        			oru.Leasing__c = Opp.Rental_Listing__c;
        			oru.Status__c = 'New';
                    String uniqueKey = Opp.Primary_Leasing_Contact__c + '_' + Opp.Rental_Listing__c;
                    if(!OruCntctLstIdSet.contains(uniqueKey)){
                        OruCntctLstIdSet.add(uniqueKey);
                    	oruList.add(oru);
                    }
                }
            }
                
        }
        if(oruList != null && oruList.size() >0){
            System.debug('NDEBUG ORUs being Inserted::' + oruList);
            System.debug('NDEBUG Size of ORUs being Inserted::' + oruList.size());
        	Insert oruList;    
        }
        
        // Get the Opps and ORUs to create ORUAs
        insOppList = [Select Id, (Select Id, Leasing__c  from Unit_Leasing__r), Rental_Listing__c, Rental_Listing__r.Rental_Listing_Id__c  ,Primary_Leasing_Contact__c FROM Opportunity where Rental_Listing__c IN: rentalListingIdSet
                                        AND Primary_Leasing_Contact__c IN: prContactIdSet AND RecordTypeId =: RecordTypes.leasingOpportunityRecordTypeId
                                        AND (NOT Stagename LIKE '%Closed%')];
        for(Opportunity Opp: insOppList){
           oppUniqueKeyMap.put(opp.Primary_Leasing_Contact__c + '_' + opp.Rental_Listing__c, Opp); 
        }
        
        List<LeasingActivityResponse> response = new List<LeasingActivityResponse>();
        
        List <Opportunity_Rental_Unit_Activity__c> oruaList = new List <Opportunity_Rental_Unit_Activity__c> ();
        List<Task> createTaskList = new List <Task>();
        
        // Get the Leasing Markets and their owners, these will be used to assign tasks if feedback is present
        List<Leasing_Markets__c> lms = Leasing_Markets__c.getall().values();
        Map<string, String> lmsMap = new Map<string, String>();
        Set<String> lmsSet = new Set<String>();
    
        //get the market -PM from custom settings~
        for (Leasing_Markets__c lm : lms) {
          lmsMap.put(lm.name, lm.Manager_Email__c);
          lmsSet.add(lm.Manager_Email__c);
        }
        Map<String, id> marketManagerMap = new Map<String, id>();
    
        //get user id from user ,custom setting store email address of manager
        List<User> users = [select id,email from user where email in :lmsSet and isactive=true ];
        Map<String,id> userEmailMap = new  Map<String,id>();
        for (User user : users){
            userEmailMap.put(user.email, user.id);
        }
        //market,email
        for (string market : lmsMap.keySet()) {
          string email = lmsMap.get(market);
            string id = userEmailMap.get(email);
          marketManagerMap.put(market, id);
        }
        
        
        for(LeasingActivityWrapper lawrap: withActivityLeads){
            if(actLruMap.containsKey(lawrap.activityId)){              
                if(oppUniqueKeyMap.containsKey(actUniqueMap.get(lawrap.activityId)) ){                    
                    Opportunity Opp = new Opportunity();
                    Opp = oppUniqueKeyMap.get(actUniqueMap.get(lawrap.activityId));                    
                    for(OpportunityRentalUnit__c oru : Opp.Unit_Leasing__r){
                        Id oruId = oru.Id;
                        // Create the ORUA
                        Opportunity_Rental_Unit_Activity__c orua = new Opportunity_Rental_Unit_Activity__c();
						orua.Opportunity_Rental_Unit__c = oru.Id;
                        orua.Leasing_Opportunity__c  = Opp.Id;
                        orua.Activity_Code__c = lawrap.activityType;
                        orua.Timestamp__c = lawrap.timeStamp;
                        orua.BPM_Activity_Id__c = lawrap.activityId;
                        orua.Timezone__c = lawrap.timezone;   
                        if (String.isNotBlank(lawrap.transferredToListingId)) {                          
                            if (rlMap.containsKey(lawrap.transferredToListingId)) {
                                orua.Transferred_To__c = rlMap.get(lawrap.transferredToListingId).Id;
                            }
                        }
                        
                        if(String.isNotBlank(lawrap.feedback)){
                            orua.feedback__c = lawrap.feedback;
                        	orua.HasFeedback__c = String.isNotBlank(lawrap.feedback);
                            Task t = new Task();     
                            t.OwnerId = marketManagerMap.get(rlMap.get(opp.Rental_Listing__r.Rental_Listing_Id__c).Property_Unit__r.property__r.Leasing_Market__c);
                            t.Subject = 'Feedback Received : ' + rlMap.get(opp.Rental_Listing__r.Rental_Listing_Id__c).Property_Unit__r.Name;
                            t.Description=  lawrap.feedback ;
                            t.Status = 'New';
                            t.type='Feedback';
                            t.Priority = 'High';
                            // t.WhatId = unitExistsInOpportunityId;
                            t.whatId = Opp.Id;
                            t.whoId = Opp.Primary_Leasing_Contact__c;
                            createTaskList.add(t);                           
                        }
                      	oruaList.add(orua);
                        LeasingActivityResponse lar= new LeasingActivityResponse();
                        lar.activityId = lawrap.activityId;
                        lar.salesforceId = Opp.id;
                        response.add(lar);
                        
                    }                    
                }
            }
            else if(actOppMap.containsKey(lawrap.activityId)){
                Opportunity Opp = new Opportunity ();
                Opp = actOppMap.get(lawrap.activityId);
                for(OpportunityRentalUnit__c oru : Opp.Unit_Leasing__r){
                    if(oru.Leasing__c == Opp.Rental_Listing__c){
                        Id oruId = oru.Id;
                        // Create the ORUA
                        Opportunity_Rental_Unit_Activity__c orua = new Opportunity_Rental_Unit_Activity__c();
                        orua.Opportunity_Rental_Unit__c = oru.Id;
                        orua.Leasing_Opportunity__c  = Opp.Id;
                        orua.Activity_Code__c = lawrap.activityType;
                        orua.Timestamp__c = lawrap.timeStamp;
                        orua.BPM_Activity_Id__c = lawrap.activityId;
                        orua.Timezone__c = lawrap.timezone;
                        if (String.isNotBlank(lawrap.transferredToListingId)) {                          
                            if (rlMap.containsKey(lawrap.transferredToListingId)) {
                                orua.Transferred_To__c = rlMap.get(lawrap.transferredToListingId).Id;
                            }
                        }
                        if(String.isNotBlank(lawrap.feedback)){
                            orua.feedback__c = lawrap.feedback;
                            orua.HasFeedback__c = String.isNotBlank(lawrap.feedback);
                            Task t = new Task();     
                            t.OwnerId = marketManagerMap.get(rlMap.get(opp.Rental_Listing__r.Rental_Listing_Id__c).Property_Unit__r.property__r.Leasing_Market__c);
                            t.Subject = 'Feedback Received : ' + rlMap.get(opp.Rental_Listing__r.Rental_Listing_Id__c).Property_Unit__r.Name;
                            t.Description=  lawrap.feedback ;
                            t.Status = 'New';
                            t.type='Feedback';
                            t.Priority = 'High';
                            // t.WhatId = unitExistsInOpportunityId;
                            t.whatId = Opp.Id;
                            t.whoId = Opp.Primary_Leasing_Contact__c;
                            createTaskList.add(t);                           
                        }
                        oruaList.add(orua);
                        LeasingActivityResponse lar= new LeasingActivityResponse();
                        lar.activityId = lawrap.activityId;
                        lar.salesforceId = Opp.id;
                        response.add(lar);
                    }
                }
            }
        }
        if(oruaList != null && oruaList.size() > 0){
            System.debug('NDEBUG ORUALIST ::::'+ oruaList);
            Upsert oruaList BPM_Activity_Id__c;
        }
        return response;
	}
    
    static void ConvertMergeLeads(Map <String, lead> leadMap, Map <String, Contact> contactMap, String defaultOwnerId) 
    {
        list<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
    
        for (String leadId : leadMap.keySet()) {
            Database.Leadconvert lc = new Database.Leadconvert();
            lc.setLeadId(leadMap.get(leadId).Id);
            if(String.isNotBlank(leadMap.get(leadId).email)){
                if(contactMap.containsKey(leadMap.get(leadId).email)){
                    String email = leadMap.get(leadId).email;
                    lc.setAccountId(contactMap.get(email).AccountId);
                	lc.setContactId(contactMap.get(email).Id);
                }
            }
            else if(String.isNotBlank(leadMap.get(leadId).phone)){
                if(contactMap.containsKey(leadMap.get(leadId).phone)){
                    String phone = leadMap.get(leadId).phone;
                    lc.setAccountId(contactMap.get(phone).AccountId);
                	lc.setContactId(contactMap.get(phone).Id);
                }
            }            
            lc.setConvertedStatus('Interested');
            lc.setDoNotCreateOpportunity(true);
            lc.setOwnerId(defaultOwnerId);
            leadConverts.add(lc);
        }
        
        List <Account> accsToBeUpdated = new List <Account> ();
        List <Contact> cntctsToBeUpdated = new List <Contact> ();
    
        if (!leadConverts.isEmpty()) {
          //max 100 lead convert
            for (Integer i = 0; i <= leadConverts.size() / 100; i++) {
                list<Database.LeadConvert> tempList = new List<Database.LeadConvert>();
                Integer startIndex = i * 100;
                Integer endIndex = ((startIndex + 100) < leadConverts.size())
                  ? startIndex + 100
                  : leadConverts.size();
                for (Integer j = startIndex; j < endIndex; j++) {
                    tempList.add(leadConverts[j]);
                }
                System.debug(LoggingLevel.ERROR, '**Converting Lead  ' + tempList);
                System.debug(
                  LoggingLevel.ERROR,
                  '**Converting Lead defaultOwnerId  ' + defaultOwnerId
                );
        
                Database.LeadConvertResult[] lcrList = Database.convertLead(
                  tempList,
                  false
                );
                for (Database.LeadConvertResult lcr : lcrList){
                    System.debug(LoggingLevel.ERROR, '**Converting Lead  ' + lcr);
                    Account a = new Account(Id = lcr.accountId, RecordTypeId = RecordTypes.leasingAccountRecordTypeId);
                    Contact c = new Contact(Id = lcr.contactId, RecordTypeId = RecordTypes.leasingContactRecordTypeId);
                    accsToBeUpdated.add(a);
                    cntctsToBeUpdated.add(c);
                }
                If(accsToBeUpdated != null && accsToBeUpdated.size() >0) Update accsToBeUpdated;
                If(cntctsToBeUpdated != null && cntctsToBeUpdated.size() >0) Update cntctsToBeUpdated;
        	}
        }
  	}
	

    
} //class
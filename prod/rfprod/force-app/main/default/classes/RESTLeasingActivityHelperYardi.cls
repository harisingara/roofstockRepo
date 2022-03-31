global class RESTLeasingActivityHelperYardi {
    
    
	// Method to process the incoming JSON Request
    global static List <RESTLeasingActivityHelper.LeasingActivityResponse>  AddLeasingActivity(
        list<RESTLeasingActivityHelper.LeasingActivityWrapper> leasingActivityList
    )
    {
    	// Below are the scenarios for Yardi
        // Primary Applicant -- Account and Contact will be created
        // Secondary Applicant with Different Contact Info from Primary Applicant -- Account and Contact will be created
        // Secondary Applicant with Same Contact Info as Primary Applicant -- Only Contact under the Primary Applicant Account will be created
        // Minor Applicants with no contact Info -- Will be stored and displayed only on the Primary Applicant Opportunity record
        
        Map <String, RESTLeasingActivityHelper.LeasingActivityWrapper> priSecApplicants = new Map <String, RESTLeasingActivityHelper.LeasingActivityWrapper> ();
        Set <String> prSecApplPhoneSet = new Set <String> ();
        Set <String> prSecApplEmailSet = new Set <String> ();
        Set <String> listingIdsSet = new Set <String> ();
        Set <String> minorsListingIdsSet = new Set <String> ();
        
        List <RESTLeasingActivityHelper.LeasingActivityWrapper> minorApplActivities = new List <RESTLeasingActivityHelper.LeasingActivityWrapper> ();
        
        
        for(RESTLeasingActivityHelper.LeasingActivityWrapper lact : leasingActivityList){
            if(String.isNotBlank(lact.prospectId) && String.isNotBlank(lact.listingId))
            {                
                if(String.isblank(lact.email) && String.isblank(lact.phone)){
                    minorApplActivities.add(lact);
                    minorsListingIdsSet.add(lact.listingId);
                }
                else{
                    System.debug('NDEBUG Email or Phone not blank');
                    String key = lact.prospectId + '_' + lact.activityId;
                    priSecApplicants.put(key , lact);
                    listingIdsSet.add(lact.listingId);
                    if(String.isNotblank(lact.phone)) prSecApplPhoneSet.add(lact.phone);
                    if(String.isNotblank(lact.email)) prSecApplEmailSet.add(lact.email);
                }                
            }
        }
        
        System.debug('NDEBUG priSecApplicants ---'+priSecApplicants);
      
        // Get the Default Owner Here:
        Id defaultOwnerId = [Select User_Id__c from Roofstock__mdt where DeveloperName = 'Integration_User' ]?.User_Id__c;
          
        // Process the Primary and Secondary Applicants with Contact Info here
        // Assuming that Minor Applicants will not have any Contact Info
        
        Map <String, Lead> leadInfo = new Map <String, Lead> ();
        leadInfo = RESTUtilities.GetLeadsWithMatchingPhoneEmail(prSecApplPhoneSet,prSecApplEmailSet );
        
         
        Map <String, Contact> contactInfo = new Map <String, Contact> ();
        contactInfo = RESTUtilities.GetContactsWithMatchingPhoneEmail(prSecApplPhoneSet,prSecApplEmailSet );
        Map <String, Contact> contactInfoMap = new Map <String, Contact> ();
        
        System.debug('NDEBUG Phone Set:::' + prSecApplPhoneSet);
        System.debug('NDEBUG Email Set:::' + prSecApplEmailSet);
        
        contactInfoMap = RESTUtilities.GetContactsInfoWithMatchingPhoneEmail(prSecApplPhoneSet,prSecApplEmailSet );
        System.debug('NDEBUG1 ContactInfoMap--'+ ContactInfoMap);
        
        Set <Id> leadsToBeConverted = new Set <Id> ();
        Map <String, Contact> prospectToExistingContactMap = new Map <String, Contact> ();
        List <Contact> cntctsToBeInserted = new List <Contact> ();
        Set <String> cntctsToBeInsertedUniqKey = new Set <String> ();
        Set <String> actcntctsToBeInsertedUniqKey = new Set <String> ();
        Set <String> prospectsHandled = new Set <String> ();
        List <RESTLeasingActivityHelper.LeasingActivityWrapper> createAccCntctsList = new List <RESTLeasingActivityHelper.LeasingActivityWrapper> ();
      
    	for(String prospectId : priSecApplicants.keyset())
        {
            if(!prospectsHandled.contains(prospectId))
            {
                prospectsHandled.add(prospectId);
                String phonekey = '';
                String emailKey = '';
                Boolean contactExists = false;
                
                // Form a Unique Key Based on FirstName, LastName and Phone/Email
                if(String.isNotBlank(priSecApplicants.get(prospectId).phone))   
                {
                    phoneKey = priSecApplicants.get(prospectId).firstname.toLowercase() + '_' + priSecApplicants.get(prospectId).lastname.toLowercase() + '_' + priSecApplicants.get(prospectId).phone;
                    if(ContactInfoMap.containsKey(phoneKey)){
                        contactExists = true;
                    }
                }
                
                if(String.isNotBlank(priSecApplicants.get(prospectId).email))   
                {
                    emailKey = priSecApplicants.get(prospectId).firstname.toLowercase() + '_' + priSecApplicants.get(prospectId).lastname.toLowercase() + '_' + priSecApplicants.get(prospectId).email;
                    if(ContactInfoMap.containsKey(emailKey)){
                        contactExists = true;
                    }
                }
                
                
                if(!contactExists)
                {
                    if(String.isNotBlank(priSecApplicants.get(prospectId).phone) && ContactInfo.containsKey(priSecApplicants.get(prospectId).phone )) 
                    {
                        System.debug('NDEBUG1 -- Got the Contact Info---');
                        if(priSecApplicants.get(prospectId).firstName.toLowercase() != ContactInfo.get(priSecApplicants.get(prospectId).phone).firstName.toLowercase()
                            || (priSecApplicants.get(prospectId).lastName.toLowercase() != ContactInfo.get(priSecApplicants.get(prospectId).phone).lastName.toLowercase()))
                        {                                
                            // Create New Contact under the same Account as the matching Contact
                            String key = priSecApplicants.get(prospectId).firstName + '_' + priSecApplicants.get(prospectId).lastName + '_' + priSecApplicants.get(prospectId).phone;
                            if(!cntctsToBeInsertedUniqKey.contains(key)){
                                cntctsToBeInsertedUniqKey.add(key);
                                cntctsToBeInserted.add(RESTUtilities.createLeasingContact(priSecApplicants.get(prospectId), ContactInfo.get(priSecApplicants.get(prospectId).phone), defaultOwnerId));
                            }
                            
                        }
                    }
                    else
                    if(String.isNotBlank(priSecApplicants.get(prospectId).email) && ContactInfo.containsKey(priSecApplicants.get(prospectId).email)) 
                    {
                        if(priSecApplicants.get(prospectId).firstName.toLowercase() != ContactInfo.get(priSecApplicants.get(prospectId).email).firstName.toLowercase()
                            || (priSecApplicants.get(prospectId).lastName.toLowercase() != ContactInfo.get(priSecApplicants.get(prospectId).email).lastName.toLowercase()))
                        {
                                
                            // Create New Contact under the same Account as the matching Contact
                            String key = priSecApplicants.get(prospectId).firstName + '_' + priSecApplicants.get(prospectId).lastName + '_' + priSecApplicants.get(prospectId).email;
                            System.debug('NDEBUG Email Key:::' + key);
                            if(!cntctsToBeInsertedUniqKey.contains(key)){
                                cntctsToBeInsertedUniqKey.add(key);
                                cntctsToBeInserted.add(RESTUtilities.createLeasingContact(priSecApplicants.get(prospectId), ContactInfo.get(priSecApplicants.get(prospectId).email), defaultOwnerId));
                            }
                        }
                    }
                    else
                    if(String.isNotBlank(priSecApplicants.get(prospectId).phone) && leadInfo.containsKey(priSecApplicants.get(prospectId).phone)) 
                    {
                        if(priSecApplicants.get(prospectId).firstName.toLowercase() == LeadInfo.get(priSecApplicants.get(prospectId).phone).firstName.toLowercase()
                        && (priSecApplicants.get(prospectId).lastName.toLowercase() == LeadInfo.get(priSecApplicants.get(prospectId).phone).lastName.toLowercase())){
                            // Convert the Lead
                            leadsToBeConverted.add(LeadInfo.get(priSecApplicants.get(prospectId).phone).Id);
                        }
                        else
                        {
                            // Create Account and Contacts for this new Lead
                            String key = priSecApplicants.get(prospectId).firstName.toLowercase() + '_' + priSecApplicants.get(prospectId).lastName.toLowercase() + '_' + priSecApplicants.get(prospectId).phone;
                            if(!actcntctsToBeInsertedUniqKey.contains(key)){
                                actcntctsToBeInsertedUniqKey.add(key);
                            	createAccCntctsList.add(priSecApplicants.get(prospectId));
                            }
                        }
                    }
                    else
                    if(String.isNotBlank(priSecApplicants.get(prospectId).email) && leadInfo.containsKey(priSecApplicants.get(prospectId).email)) 
                    {
                        if(priSecApplicants.get(prospectId).firstName.toLowercase() == LeadInfo.get(priSecApplicants.get(prospectId).email).firstName.toLowercase()
                            && (priSecApplicants.get(prospectId).lastName.toLowercase() == LeadInfo.get(priSecApplicants.get(prospectId).email).lastName.toLowercase()))
                        { 
                                // Convert the Lead
                                leadsToBeConverted.add(LeadInfo.get(priSecApplicants.get(prospectId).email).Id);
                        }
                        else
                        {
                            // Create Account and Contacts for this new Lead
                            String key = priSecApplicants.get(prospectId).firstName + '_' + priSecApplicants.get(prospectId).lastName + '_' + priSecApplicants.get(prospectId).email;
                            if(!actcntctsToBeInsertedUniqKey.contains(key)){
                                actcntctsToBeInsertedUniqKey.add(key);
                            	createAccCntctsList.add(priSecApplicants.get(prospectId));
                            }
                        }
                    } 
                    else
                    {
                        // Create Account and Contacts from the incoming Activities
                        createAccCntctsList.add(priSecApplicants.get(prospectId));
                    }
                }
            }
    	}
    
        // Convert the Leads
        if(leadsToBeConverted != null && leadsToBeConverted.size() >0){
            System.debug('NDEBUG Converting existing leads');
            System.debug('NDEBUG Leads being converted:::' + leadsToBeConverted);
            RESTUtilities.ConvertMatchingLeadsToAccount(leadsToBeConverted, defaultOwnerId);
        }
        //Insert the Accounts/Contacts for new entries
        if(createAccCntctsList != null && createAccCntctsList.size() >0){
            System.debug('NDEBUG Creating new Accounts/Contacts');
            RESTUtilities.createAccountContactsYardi(createAccCntctsList, defaultOwnerId); 
        }
              
        // Insert the Contacts under the existing Accounts
        if(cntctsToBeInserted != null && cntctsToBeInserted.size() > 0)
        {
            System.debug('NDEBUG Creating new Contacts' + cntctsToBeInserted);
            Insert cntctsToBeInserted; 
        }
      
        // At this point all the Accounts/Contacts for Primary and Secondary Applicants are in place
        // Insert/Update the Oportunities and related records here
        List<RESTLeasingActivityHelper.LeasingActivityResponse> oppResponse = new List<RESTLeasingActivityHelper.LeasingActivityResponse>();
        oppResponse = RESTUtilities.createOpportunitiesYardi(priSecApplicants.values(),prSecApplEmailSet ,prSecApplPhoneSet ,listingIdsSet, defaultOwnerId);
            
        // Process the Minor applicants here
        if(minorApplActivities != null && minorApplActivities.size() >0){
        	RESTUtilities.processMinorApplicants(minorApplActivities, minorsListingIdsSet);
        }
            
        return oppResponse;    
	}
}
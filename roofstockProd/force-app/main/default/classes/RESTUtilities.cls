Public class RESTUtilities {
    
    Public Static Map <String, Lead> GetLeadsWithMatchingPhoneEmail(Set<String> phoneSet, Set<String> emailSet) {
        Map <String, lead> leadInfoMap = new Map <String, lead>();
        
        List<Lead> leadPhoneList = [ SELECT firstName, lastName, phone, Id, email FROM Lead WHERE Phone IN : phoneSet AND recordTypeId = : RecordTypes.leasingLeadRecordTypeId AND isConverted =: false];
        List<Lead> leadEmailList = [ SELECT firstName, lastName, phone, Id, email FROM Lead WHERE email IN : emailSet AND recordTypeId = : RecordTypes.leasingLeadRecordTypeId AND isConverted =: false];
        
        for (Lead lead : leadPhoneList) {
            if (String.isNotBlank(lead.phone)) {
                leadInfoMap.put(lead.phone, lead);
            }
        } 
        
        for (Lead lead : leadEmailList) {
            if (String.isNotBlank(lead.email)) {
                leadInfoMap.put(lead.email, lead);
            }
        } 
        return leadInfoMap;
    }
    
    Public Static Set<Id> GetLeadIdsWithMatchingPhoneEmail(Set<String> phoneSet, Set<String> emailSet)
    {
        Set<Id> leadIds = new Set<Id>();
        
        //store the existing SF contacts with matching phones
        List<Lead> leadPhoneList = [
            SELECT phone, id, email
            FROM Lead
            WHERE
            Phone IN :phoneSet
            AND recordTypeId = : RecordTypes.leasingLeadRecordTypeId
        ];
        
        List<Lead> leadEmailList = [
            SELECT phone, id, email
            FROM Lead
            WHERE
            email IN :emailSet
            AND recordTypeId = : RecordTypes.leasingLeadRecordTypeId
        ];
        
        for (Lead lead : leadPhoneList) {
            if (String.isNotBlank(lead.phone)) {
                leadIds.add(lead.Id);
            }
        } //for
        for (Lead lead : leadEmailList) {
            if (String.isNotBlank(lead.email)) {
                leadIds.add(lead.Id);
            }
        } //for
        return leadIds;
    }
    
    Public Static String convertToCamelCase(String input){
        return(input.substring(0,1).toUpperCase() + input.substring(1).toLowerCase());
        
    }
    
	Public Static Map <String, Contact> GetContactsInfoWithMatchingPhoneEmail(Set<String> phoneSet, Set<String> emailSet) {
        Map <String, Contact> contactInfoMap = new Map <String, Contact>();
        
        //Store the existing SF contacts with matching Phones and Emails
        List<Contact> contactPhoneList = [ SELECT Id, FirstName, LastName, Phone, AccountId, Email FROM Contact WHERE Phone IN : phoneSet AND recordTypeId = : RecordTypes.leasingContactRecordTypeId ];
        List<Contact> contactEmailList = [ SELECT Id, FirstName, LastName, Phone, AccountId, Email FROM Contact WHERE Email IN : emailSet AND recordTypeId = : RecordTypes.leasingContactRecordTypeId ];
        
        String key = '';
        String key1 = '';
        String key2 = '';
        for (Contact ctct : contactPhoneList) {            
            if (String.isNotBlank(ctct.phone)) {
                key = ctct.FirstName + '_' + ctct.LastName +'_' + ctct.Phone;
                key1 = convertToCamelCase(ctct.FirstName) + '_' + convertToCamelCase(ctct.LastName) +'_' + ctct.Phone;
                key2 = ctct.FirstName.toLowercase() + '_' + ctct.LastName.toLowercase() +'_' + ctct.Phone;
                contactInfoMap.put(key, ctct);
                contactInfoMap.put(key1, ctct);
                contactInfoMap.put(key2, ctct);
            }
        } //for
        for (Contact ctct : contactEmailList) {
            if (String.isNotBlank(ctct.email)) {
                key = ctct.FirstName + '_' + ctct.LastName +'_' + ctct.Email;
                key1 = convertToCamelCase(ctct.FirstName) + '_' + convertToCamelCase(ctct.LastName) +'_' + ctct.Email;
                key2 = ctct.FirstName.toLowercase() + '_' + ctct.LastName.toLowercase() +'_' + ctct.Email;
                contactInfoMap.put(key, ctct);
                contactInfoMap.put(key1, ctct);
                contactInfoMap.put(key2, ctct);
            }
        } //for
        return contactInfoMap;
    }
    
    Public Static Map <String, Contact> GetContactsWithMatchingPhoneEmail(Set<String> phoneSet, Set<String> emailSet) 
    {
        Map <String, Contact> contactInfoMap = new Map <String, Contact>();
        
        //Store the existing SF contacts with matching Phones and Emails
        List<Contact> contactPhoneList = [ SELECT Id, firstName, lastName, phone, AccountId, email FROM Contact WHERE Phone IN : phoneSet AND recordTypeId = : RecordTypes.leasingContactRecordTypeId ];
        List<Contact> contactEmailList = [ SELECT Id, firstName, lastName, phone, AccountId, email FROM Contact WHERE email IN : emailSet AND recordTypeId = : RecordTypes.leasingContactRecordTypeId ];
        
        for (Contact ctct : contactPhoneList) {
            if (String.isNotBlank(ctct.phone)) {
                contactInfoMap.put(ctct.phone, ctct);
            }
        } //for
        for (Contact ctct : contactEmailList) {
            if (String.isNotBlank(ctct.email)) {
                contactInfoMap.put(ctct.email, ctct);
            }
        } //for
        return contactInfoMap;
    }
    
    Public Static Set<Id> GetContactIdsWithMatchingPhoneEmail(Set<String> phoneSet, Set<String> emailSet) 
    {
        Set<Id> contactIds = new Set<Id>();
        
        //Store the existing SF contacts with matching Phones and Emails
        List<Contact> contactPhoneList = [ SELECT Id, firstName, lastName, phone, AccountId, email FROM Contact WHERE Phone IN : phoneSet AND recordTypeId = : RecordTypes.leasingContactRecordTypeId ];
        List<Contact> contactEmailList = [ SELECT Id, firstName, lastName, phone, AccountId, email FROM Contact WHERE email IN : emailSet AND recordTypeId = : RecordTypes.leasingContactRecordTypeId ];
        
        for (Contact ctct : contactPhoneList) {
            if (String.isNotBlank(ctct.phone)) {
                contactIds.add(ctct.Id);
            }
        } //for
        for (Contact ctct : contactEmailList) {
            if (String.isNotBlank(ctct.email)) {
                contactIds.add(ctct.Id);
            }
        } //for
        return contactIds;
    }
/*    
  Public Static Map <String, Id> GetContactAccIdWithMatchingPhoneEmail( Set<String> emailSet, Set<String> phoneSet)
  {
    Map<String, Id> contactPhoneEmailMap = new Map<String, Id>();
        
    //Lookup existing Contacts with matching Email
    List<Contact> contactList = [SELECT email, phone, accountId FROM Contact WHERE email IN :emailSet AND recordTypeId = : RecordTypes.leasingContactRecordTypeId ];
    for (Contact contact : contactList) {
      if (String.isNotBlank(contact.email)) {
        contactPhoneEmailMap.put(contact.email, contact.account.Id);
      }
    } //for
        
    //store the existing SF contacts with matching phones
    List<Contact> contactNamePhoneList = [ SELECT phone, email, accountId, SearchableNamePhone__c FROM Contact WHERE Phone IN :phoneSet AND 
                                          recordTypeId = : RecordTypes.leasingContactRecordTypeId ];
        
    for (Contact contact : contactNamePhoneList) {
      if (String.isNotBlank(contact.phone)) {
        contactPhoneEmailMap.put(contact.phone, contact.account.Id);
      }
    } //for
    return contactPhoneEmailMap;     
  }
*/
    
    Public Static void ConvertMatchingLeadsToAccount(Set<Id> leadIds, String defaultOwnerId ) {
    	list<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();

        for (Id leadId : leadIds) {
            Database.Leadconvert lc = new Database.Leadconvert();
            lc.setLeadId(leadId);
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
                System.debug( LoggingLevel.ERROR, '**Converting Lead defaultOwnerId  ' + defaultOwnerId);
    
                Database.LeadConvertResult[] lcrList = Database.convertLead(tempList,false);
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
    
    Public Static String getUUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.substring(20);
        return guid;
    }
    
/*    
    Public Static Lead createLeasingLead(RESTLeasingActivityHelper.LeasingActivityWrapper la){
        Lead newLead = new Lead(
          FirstName = la.firstName,
          LastName = (la.lastName == '' ? 'Unknown' : la.lastName),
          company = la.firstName + ' ' + la.lastName,
          Phone = la.phone,
          email = la.email,
          RecordTypeId = RecordTypes.leasingLeadRecordTypeId,
          LeadSource = la.source,
          Source_Created_Date__c = la.timestamp,
         // ownerId = LeasingQueue.Id,
          X1_Ideally_when_would_you_buy_your_first__c = Date.today().addDays(14)
        );
        return newLead;
    }
*/
    
    Public Static Contact createLeasingContact(RESTLeasingActivityHelper.LeasingActivityWrapper la, Contact existingContact, Id defaultOwnerId) {
        Contact newCtct = new Contact (FirstName = la.firstName,
                                       LastName = la.lastName,
                                       Email = la.email,
                                       Phone = la.phone,
                                       RecordTypeId = RecordTypes.leasingContactRecordTypeId,
                                       accountId = existingContact.AccountId,
                                       Ownerid = defaultOwnerId);
        return newCtct;
    }
    
    
    
    Public Static void createAccountContactsYardi( List <RESTLeasingActivityHelper.LeasingActivityWrapper> activitiesWithListing,
                                                   Id defaultOwnerId
                                                 ){
    
          List<sObject> lstAobject = new List<sObject>();
          List<sObject> lstCobject = new List<sObject>();
    
          //store the newly create contacts
          Set<String> createContactsSet = new Set<String>();
    
          for (RESTLeasingActivityHelper.LeasingActivityWrapper la : activitiesWithListing) {
              //extid is required to create account and contact in one DML
              String extId = getUUID();
              
              String emailKey = la.firstName + '-' + la.lastName + '_' + la.email;
              String phoneKey = la.firstName + '-' + la.lastName + '_' + la.phone;
              
              Boolean existingOrAddedInthisBatch =   createContactsSet.contains(emailKey) || createContactsSet.contains(phoneKey);
    
              if (!existingOrAddedInthisBatch) {
                  Contact newContact1 = new Contact(
                      FirstName = la.firstName,
                      LastName = la.lastName,
                      Email = la.email,
                      Phone = la.phone,
                      RecordTypeId = RecordTypes.leasingContactRecordTypeId,
                      Ownerid = defaultOwnerId
                  );
    
              Account accountReference = new Account(RentlyId__c = extId);
              newContact1.Account = accountReference;
    
              Account parentAccount1 = new Account(
                Name = la.firstName + ' ' + la.lastName,
                RentlyId__c = extId,
                RecordTypeId = RecordTypes.leasingAccountRecordTypeId,
                Ownerid = defaultOwnerId
              );
              if (string.isNotBlank(la.phone)) {
                  parentAccount1.phone = la.phone;
              }
              if (string.isNotBlank(la.email)) {
                  parentAccount1.Company_Email__c = la.email;
              }
              
              lstAobject.add(parentAccount1);
              lstCobject.add(newContact1);
    
              //both phone and email should be added to set to avoid duplicates in current batch
              if (String.isNotBlank(la.email)) {
                  createContactsSet.add(emailKey);
              }
              if (String.isNotBlank(la.phone)) {
                  createContactsSet.add(phoneKey);
              }
            } //if
          } //for
    
          System.debug( LoggingLevel.ERROR, '**Successfully created ID: ' + lstAobject + lstCobject);
          //Create all missing accouts and contacts
          Database.SaveResult[] results1 = Database.insert(lstAobject);
          Database.SaveResult[] results2 = Database.insert(lstCobject);
	}
    
   
    
   Public Static List<RESTLeasingActivityHelper.LeasingActivityResponse> createOpportunitiesYardi(
                                                                                               List<RESTLeasingActivityHelper.LeasingActivityWrapper> activityList,
                                                                                               Set<String> emailSet,
                                                                                               Set<String> phoneSet,
                                                                                               Set<String> listingIds,
                                                                                               Id defaultOwnerId
                                                                                           ) 
   {
       //Opportunity Closing date default
       Date dt = Date.today().addDays(14);
       Map <String, RESTLeasingActivityHelper.LeasingActivityWrapper> actMap = new Map <String, RESTLeasingActivityHelper.LeasingActivityWrapper> ();
       
       Map<string, Rental_Listing__c> rentalListingsMap = new Map<string, Rental_Listing__c>();

      // Get the Rental Listing Information
      List<Rental_Listing__c> rentalListingList = [
                                                    SELECT Id, Name, Rental_Listing_Id__c, Current_Rent__c, Status__c, Property_unit__r.name, 
          											Property_Unit__r.property__r.Leasing_Market__c
                                                    FROM Rental_Listing__c
                                                    WHERE Rental_Listing_Id__c IN : listingIds
                                                  ];

       for (Rental_Listing__c rl : rentalListingList) {
           rentalListingsMap.put(rl.Rental_Listing_Id__c, rl);
       }
       
       // Retrieve all the Contacts/Accounts related to the emailSet and phoneSet
       Map <String, Contact> keyContactMap = new Map <String, Contact> ();
       keyContactMap = RESTUtilities.GetContactsInfoWithMatchingPhoneEmail(phoneSet, emailSet);
       
       
       Set<String> contactIds = new Set<String>();

       for (Contact contact : keyContactMap.values()) {
          String key1 = '';
          if (String.isNotBlank(contact.phone)) {           
              contactIds.add(contact.Id);
          }
          if (String.isNotBlank(contact.email)) {                                  
              contactIds.add(contact.Id);
          }
      }

		List <Opportunity> recentlyClosedOppportunityList = new List <Opportunity> ();
       //Get opps that were closed in last n days and ignore any new activities for the same
       /* Commenting below to enable load of historical data
       List <Opportunity> recentlyClosedOppportunityList = [SELECT Id, Primary_Leasing_Contact__r.FirstName, 
                                                                         Primary_Leasing_Contact__r.LastName, Primary_Leasing_Contact__r.Email, 
                                                                         Primary_Leasing_Contact__r.Phone, Yardi_Prospect_Id__c, Rental_Listing__r.Rental_Listing_Id__c 
                                                                         FROM Opportunity 
                                                                         WHERE Primary_Leasing_Contact__c IN : contactIds
                                                                         AND (RecordTypeId = : RecordTypes.leasingOpportunityRecordTypeId
                                                                              OR RecordTypeId = : RecordTypes.leasingSecApplOppRecordTypeId)
                                                                         AND Stagename IN ('Closed Won = Lease Signed') 
                                                                         AND CloseDate = LAST_N_DAYS:30];
	   */
       
       Map <String, String> closedOppsMap = new Map <String, String> ();
       
       for(Opportunity Opp: recentlyClosedOppportunityList){
           String key = '';
           
           if(rentalListingsMap.containsKey(Opp.Rental_Listing__r.Rental_Listing_Id__c)){
               if(String.isNotBlank(Opp.Primary_Leasing_Contact__r.Phone)){
                   key = Opp.Primary_Leasing_Contact__r.firstname.toLowercase() + '_' + Opp.Primary_Leasing_Contact__r.lastname.toLowercase() + '_'+ 
                       Opp.Primary_Leasing_Contact__r.phone + '_' + Opp.Rental_Listing__r.Rental_Listing_Id__c;
                   closedOppsMap.put(key, Opp.Id);
                   
               }
               if(String.isNotBlank(Opp.Primary_Leasing_Contact__r.Email)){
                   key = Opp.Primary_Leasing_Contact__r.firstname.toLowercase() + '_' + Opp.Primary_Leasing_Contact__r.lastname.toLowercase() + '_'+ 
                       Opp.Primary_Leasing_Contact__r.Email + '_' + Opp.Rental_Listing__r.Rental_Listing_Id__c;
                   closedOppsMap.put(key, Opp.Id);                    
               }  
           }           
       }
        
       Set<id> recentlyClosedAccountIDs = new Set<id>(); 
       Set<id> recentlyClosedContactIDs = new Set<id>();
       
       
       System.debug(LoggingLevel.ERROR, '**** recentlyClosedOppportunityList ' + recentlyClosedOppportunityList.size());

       List<RESTLeasingActivityHelper.LeasingActivityWrapper> finalActivitiesToBeProcessed = new List<RESTLeasingActivityHelper.LeasingActivityWrapper>();
       Set <Id> notClosedOppCntctIds = new Set <Id> ();
       Set <String> notClosedOppListingIds = new Set <String> ();
        
       // Create a Unique key based on the incoming Activity List
       for(RESTLeasingActivityHelper.LeasingActivityWrapper act : activityList){
           String phoneKey = '';
           String emailKey = '';
           String phoneKey1 = '';
           String emailKey1 = '';
           
           if(String.isNotBlank(act.phone)){
               phoneKey = act.firstname.toLowercase() + '_' + act.lastname.toLowercase() + '_'+ act.phone;
               phoneKey1 = act.firstname.toLowercase() + '_' + act.lastname.toLowercase() + '_'+ act.phone + '_' + act.listingId;
               
           }
           if(String.isNotBlank(act.email)){
               emailKey = act.firstname.toLowercase() + '_' + act.lastname.toLowercase() + '_'+ act.email ;
               emailKey1 = act.firstname.toLowercase() + '_' + act.lastname.toLowercase() + '_'+ act.email + '_' + act.listingId;
               
           }
           
           if(String.isNotBlank(phoneKey) && closedOppsMap.containsKey(phoneKey1))
           {
               System.debug('Found the matching Closed Opportunity ::::' + closedOppsMap.get(phoneKey1));
           }
           else
               if(String.isNotBlank(emailKey) && closedOppsMap.containsKey(emailKey1)){
                   System.debug('Found the matching Closed Opportunity ::::' + closedOppsMap.get(emailKey1));
               }
           else{
               finalActivitiesToBeProcessed.add(act);
               if(keyContactMap.containsKey(phoneKey)){
                   notClosedOppCntctIds.add(keyContactMap.get(phoneKey).Id);
                   notClosedOppListingIds.add(act.listingId);
               }
               if(keyContactMap.containsKey(emailKey)){
                   notClosedOppCntctIds.add(keyContactMap.get(emailKey).Id);
                   notClosedOppListingIds.add(act.listingId);
               }               
           }
       }
       System.debug('NDEBUG notClosedOppCntctIds ::::' + notClosedOppCntctIds);
       System.debug('NDEBUG notClosedOppListingIds ::::' + notClosedOppListingIds);
      
      
      // Get Existing Open Opportunities For these prospects
	  List <Opportunity> matchingOppportunityList = [SELECT Id, Primary_Leasing_Contact__r.FirstName, 
                                               Primary_Leasing_Contact__r.LastName, Primary_Leasing_Contact__r.Email, 
                                               Primary_Leasing_Contact__r.Phone, Yardi_Prospect_Id__c, Rental_Listing__r.Rental_Listing_Id__c 
                                               FROM Opportunity 
                                               WHERE Primary_Leasing_Contact__c IN : notClosedOppCntctIds
                                               AND (RecordTypeId = : RecordTypes.leasingOpportunityRecordTypeId
                                               OR RecordTypeId = : RecordTypes.leasingSecApplOppRecordTypeId) AND Yardi_Prospect_Id__c != ''
                                                     ORDER BY CREATEDDATE DESC
                                                     ];
       										// Commented below to allow Historical data load
                                             //  AND Stagename NOT IN ('Closed Won = Lease Signed') ];
                                               //AND Opportunity__r.CloseDate = LAST_N_DAYS:30];
      System.debug('NDEBUG matchingOppportunityList :::::' + matchingOppportunityList );
        
      Map <String, String> openOppsMap = new Map <String, String> ();
       Set <String> oppKeySet = new Set <String> ();
        for(Opportunity Opp : matchingOppportunityList){
            String key = '';   
            
            if(rentalListingsMap.containsKey(Opp.Rental_Listing__r.Rental_Listing_Id__c)){           
                if(String.isNotBlank(Opp.Primary_Leasing_Contact__r.Phone)){
                    key = Opp.Primary_Leasing_Contact__r.firstname.toLowercase() + '_' + Opp.Primary_Leasing_Contact__r.lastname.toLowercase() + '_'+ 
                        Opp.Primary_Leasing_Contact__r.phone + '_' + Opp.Rental_Listing__r.Rental_Listing_Id__c + '_' + Opp.Yardi_Prospect_Id__c;
                    if(!oppKeySet.contains(key)){
                        oppKeySet.add(key);
                    	openOppsMap.put(key, Opp.Id);  
                    }
                }
                if(String.isNotBlank(Opp.Primary_Leasing_Contact__r.Email)){
                    key = Opp.Primary_Leasing_Contact__r.firstname.toLowercase() + '_' + Opp.Primary_Leasing_Contact__r.lastname.toLowercase() + '_'+ 
                        Opp.Primary_Leasing_Contact__r.Email + '_' + Opp.Rental_Listing__r.Rental_Listing_Id__c + '_' + Opp.Yardi_Prospect_Id__c;
                    if(!oppKeySet.contains(key)){
                        oppKeySet.add(key);
                    	openOppsMap.put(key, Opp.Id);  
                    }                                       
                } 
            }
        }
     
      System.debug('NDEBUG Existing Opps Map:::' + openOppsMap);

      // For Each Activity
      // Create New Opportunities for ContactIds not in this list
      // else Update the Opportunities
      List<Opportunity> oppsList = new List<Opportunity>();
      Set <String> prospectsSet = new Set <String> ();
      Set <String> listingsSet = new Set <String> ();

      //Keep track of new opportunities with contactId+listing key created in this transaction to prevent duplicate opporutunity creation
      Set <String> oppsCreated = new Set<String>();

      
       System.debug(LoggingLevel.ERROR, '**** Final Activities to be processed ' + finalActivitiesToBeProcessed.size());
       System.debug('NDEBUG ::: keyContactMap' + keyContactMap);
       
       Set <Id> oppsUpdtd = new Set <Id> ();

       for (RESTLeasingActivityHelper.LeasingActivityWrapper act : finalActivitiesToBeProcessed) {
 			Id accountId = null;
           Id contactId = null;
           String phoneKey = '';
           String emailKey = '';
           String phoneKey1 = '';
           String emailKey1 = '';
           
           if(rentalListingsMap.containsKey(act.listingId)) {
               
              Boolean cntctNtFnd = true;
           
              if (String.isNotBlank(act.phone)) {
                  phoneKey = act.firstname.toLowercase() + '_' + act.lastname.toLowercase() + '_'+ act.phone;
                  phoneKey1 = act.firstname.toLowercase() + '_' + act.lastname.toLowercase() + '_'+ act.phone + '_' + act.listingId + '_' + act.prospectId;
                  System.debug('NDEBUG Unique Key:::'+ phoneKey);
                  System.debug('NDEBUG Unique Key:::'+ phoneKey1);
                  if(keyContactMap.containsKey(phoneKey))
                  {
                      contactId = keyContactMap.get(phoneKey).Id;
                      accountId = keyContactMap.get(phoneKey).accountId;
                      cntctNtFnd = false;
                  }
              }
              if (cntctNtFnd && String.isNotBlank(act.email)) {
                  emailKey = act.firstname.toLowercase() + '_' + act.lastname.toLowercase() + '_'+ act.email;
                  emailKey1 = act.firstname.toLowercase() + '_' + act.lastname.toLowercase() + '_'+ act.email + '_' + act.listingId + '_' + act.prospectId; 
                  contactId = keyContactMap.get(emailKey).Id;
                  accountId = keyContactMap.get(emailKey).accountId;
              }
         
              String closeDateFormatted = String.valueOf(dt);
              String oppName = ''; 
               
              //get listing info
               String market;
               Rental_Listing__c oppListing = rentalListingsMap.get(act.listingId);
               if(oppListing != null){
                   market = oppListing.Property_Unit__r.property__r.Leasing_Market__c;
               }
               
              Opportunity Opp;
              if(oppListing != null & !oppsCreated.contains(phoneKey1) && !oppsCreated.contains(emailKey1)){
                  Opp = new Opportunity();
                  Boolean newOpp = true;
                  // Create New Opportunity
                  if(!openOppsMap.containsKey(phoneKey1) &&  !openOppsMap.containsKey(emailKey1)){
                      Opp.name = closeDateFormatted + '-' + act.firstName + '-' + act.lastName; 
                      opp.RecordTypeId = RecordTypes.leasingOpportunityRecordTypeId;
                      opp.AccountId = accountId;
                      opp.Primary_Leasing_Contact__c = contactId;
                      opp.StageName = 'New';
                      opp.CloseDate = dt;
                      opp.ownerId = defaultOwnerId;
                      opp.Rental_Listing__c = rentalListingsMap.get(act.listingId).Id;
                      if(String.isNotBlank(market)){
                          Opp.Leasing_Market__c = market;
                      }
                  }
                  else if (openOppsMap.containsKey(phoneKey1)){   
                      newOpp = false;
                      Opp.Id = openOppsMap.get(phoneKey1);
                  }
                  else if (openOppsMap.containsKey(emailKey1)){
                      newOpp = false;
                      Opp.Id = openOppsMap.get(emailKey1);
                  }
                  
                  if(newOpp || (!newOpp && !oppsUpdtd.contains(Opp.Id)))
                  {                     
					  oppsUpdtd.add(Opp.Id);              
                      // Capture the remaining fields on the Opportunity here
                      // Added for Lead to Leasing
                      opp.Relationship__c = act.relationship;
                      opp.Code__c = act.code;
                      opp.Date_Submitted__c = act.dateSubmitted;
                      if(act.backgroundRun != null) 
                      {
                          opp.Background_Run__c = act.backgroundRun;
                      }
                      opp.Background_Status__c = act.backGroundStatus;
                      opp.Decision_Date__c = act.decisionDate;
                      opp.Applicant_Name__c = act.lastname + ', ' + act.firstname;
                      opp.MoveIn_Date__c = act.moveInDate;
                      opp.Lease_Start__c = act.leaseStart;
                      opp.Lease_End__c = act.leaseEnd;
                      opp.Lease_Sent_Date__c = act.leaseSentDate;
                      opp.Lease_Signed_Tenant__c = act.leaseSignedTenant;
                      opp.PM_Signed_Date__c = act.pmSigned;
                      opp.MovedIn_Date__c = act.movedInDate; 
                      opp.Primary_Applicant_Opp__c = null;
                      //opp.Yardi_Primary_Prospect_Id__c  = act.primaryProspectId;         
                      opp.Number_of_Pets__c = act.numPets;
                      opp.App_Decision__c = act.appDecision;
                      // PMC2022-181
                      opp.Application_Status__c = act.appStatus;
                      opp.Cancelled_Denied_Reason__c =  act.cancelledReason;
                      opp.Report_Id__c = act.reportId;
                      opp.Prospect_Notes__c =  act.prospectNotes;
                      opp.Tenant_Status1__c = act.tenantStatus;
                      // Capture the Listing Ids and Prospect Ids here
                      listingsSet.add(act.listingId);
                      
                      if (String.isNotBlank(act.prospectId) && act.prospectId != '0') 
                      {
                          opp.Yardi_Prospect_Id__c  = act.prospectId; 
                          prospectsSet.add(act.prospectId);
                      }
                      if(String.isNotBlank(act.primaryProspectId) && act.primaryProspectId != '0')
                      {     
                          opp.Yardi_Primary_Prospect_Id__c  = act.primaryProspectId; 
                          prospectsSet.add(act.primaryProspectId);              
                      }
                  
                      // Update the Opportunties to be Inserted/Updated
                      oppsList.add(opp);
                      if(String.isNotBlank(phonekey1)){
                          oppsCreated.add(phonekey1);
                      }
                      if(String.isNotBlank(emailkey1)){
                          oppsCreated.add(emailkey1);
                      }
              	}
                  
              }
           }
       }
      
    
    Upsert oppsList;
    System.debug(LoggingLevel.ERROR,'**** Opportunities Created/Updated ' + oppsList.size());
      
    
	Map <String, Opportunity> prospectListingToOppMap = new Map <String, Opportunity> ();
    List <opportunity> secApplOppList = new List <opportunity>  ();
    List <Opportunity> secOppToUpdateList = new List <Opportunity> ();
      
    // Link the Secondary Applicant Opportunities created above with the Primary Applicant Opportunity
    if(prospectsSet != null && prospectsSet.size() >0 && listingsSet != null && listingsSet.size() > 0)
    {
        System.debug(LoggingLevel.ERROR,'NDEBUG Prospect Set:::' + prospectsSet);
    	System.debug(LoggingLevel.ERROR,'NDEBUG Listings Set:::' + listingsSet);    
      	for(Opportunity Opp: [
                      SELECT Id, Relationship__c, Primary_Applicant_Opp__c ,Yardi_Prospect_Id__c, Yardi_Primary_Prospect_Id__c, Primary_Leasing_Contact__c, 
            		  Rental_Listing__c, Rental_Listing__r.Rental_Listing_Id__c, OwnerId
                      FROM Opportunity
                      WHERE
                        (Yardi_Prospect_Id__c IN :prospectsSet
                    	OR Yardi_Primary_Prospect_Id__c IN :prospectsSet)
                        AND (RecordTypeId = : RecordTypes.leasingOpportunityRecordTypeId OR RecordTypeId = : RecordTypes.leasingSecApplOppRecordTypeId) 
                        AND stagename NOT IN ('Closed Won = Lease Signed', 'Closed Lost')
      	]){
            if(Opp.Relationship__c == 'Self'){
                // This is a Primary Applicant Opportunity
                prospectListingToOppMap.put(Opp.Yardi_Prospect_Id__c + '_' + Opp.Rental_Listing__r.Rental_Listing_Id__c, Opp);
          	}else // Primary Applicant Opportunity is Null on the Secondary Applicant Opportunity
                if(Opp.Primary_Applicant_Opp__c == null){
                    secApplOppList.add(Opp);
          	}
      	}
          
        System.debug('NDEBUG prospectListingToOppMap' +prospectListingToOppMap);
        System.debug('NDEBUG secApplOppList' +secApplOppList); 
         
        // Process the Secondary Applicant Opportunities here
        if(secApplOppList != null && secApplOppList.size() >0){
            for(Opportunity Opp: secApplOppList){
                if(prospectListingToOppMap.containsKey(Opp.Yardi_Primary_Prospect_Id__c + '_' + Opp.Rental_Listing__r.Rental_Listing_Id__c)){
                    Opportunity existingOpp = prospectListingToOppMap.get(Opp.Yardi_Primary_Prospect_Id__c + '_' + Opp.Rental_Listing__r.Rental_Listing_Id__c);
                    Opportunity o = new Opportunity(Id = Opp.Id, 
                                                    RecordTypeId = RecordTypes.leasingSecApplOppRecordTypeId,
                                                    Primary_Applicant_Opp__c = existingOpp.Id,
                                                    OwnerId = existingOpp.OwnerId);
                    //Primary_Leasing_Contact__c = existingOpp.Primary_Leasing_Contact__c);
                    secOppToUpdateList.add(o);
                }
            }
            if(secOppToUpdateList != null && secOppToUpdateList.size() >0){
                update secOppToUpdateList;
            }
        }
    }

	Map<Id, Opportunity> allOppportunitiesMap = new Map<Id, Opportunity>();
    Set<Id> oppIds = new Set<Id>();
       
    Map <String, Opportunity> prospectIdToOppMap = new Map <String, Opportunity> ();
       
    Set <Id> OppIdSet = new  Set <Id> (); 
       
    for(String key : openOppsMap.keySet()){
        OppIdSet.add(openOppsMap.get(key));
    }   
        
	for (Opportunity opp : secOppToUpdateList) {
        OppIdSet.add(opp.Id);
    }
    for (Opportunity opp : oppsList) {
        OppIdSet.add(opp.Id);
    }
    //Missing opportunities are now created at this point!
    System.debug(LoggingLevel.ERROR,'**** opp Id list ' + oppIds);
    System.debug(LoggingLevel.ERROR,'**** opp list ' + oppsList);
    System.debug(LoggingLevel.ERROR,'**** opp related list ' + allOppportunitiesMap);
        
    List <Opportunity> OppList = [SELECT Id, Primary_Leasing_Contact__c, Yardi_Prospect_Id__c,Rental_Listing__c, Rental_Listing__r.Rental_Listing_Id__c  from Opportunity WHERE Id IN : OppIdSet];

      
    CreateOpportunityRelatedLists(finalActivitiesToBeProcessed, 
                                    OppList,
                                    rentalListingsMap, 
                                    defaultOwnerId);
       
    System.debug(LoggingLevel.ERROR,'**** opp prepare response ' + allOppportunitiesMap);
                                 
    return PrepareOpportunityResponse(finalActivitiesToBeProcessed, OppList);                                     
	} //func 
    
    
    
    
  	Public Static List<RESTLeasingActivityHelper.LeasingActivityResponse> PrepareLeadResponse( List<Lead> leads, 
                                  List<RESTLeasingActivityHelper.LeasingActivityWrapper> leasingActivityList)
    {

        List<RESTLeasingActivityHelper.LeasingActivityResponse> response = new List<RESTLeasingActivityHelper.LeasingActivityResponse>();   
        Map<string,id> leadsEmailMap = new Map<string,id>();
        Map<string,id> leadsPhoneMap = new Map<string,id>();
    
        for(Lead lead : leads){
            if (String.isNotBlank(lead.email)) {
            	leadsEmailMap.put(lead.email, lead.id);
          	}
          	if (String.isNotBlank(lead.phone)) {
            	leadsPhoneMap.put(lead.phone, lead.id);
          	}
        }

    	for (RESTLeasingActivityHelper.LeasingActivityWrapper la : leasingActivityList) 
        {
      		Id leadId;
  
            if (String.isNotBlank(la.email)) {
                leadId = leadsEmailMap.get(la.email);
            }
            
            if (String.isBlank(leadId) && String.isNotBlank(la.phone)) {
                leadId = leadsEmailMap.get(la.phone);
            }
            
            if(String.isNotBlank(leadId)) {
                RESTLeasingActivityHelper.LeasingActivityResponse lar= new RESTLeasingActivityHelper.LeasingActivityResponse();
                lar.activityId = la.activityId;
                lar.salesforceId = leadId;
                // la.activityId, opp.id
                response.add(lar);
            }
    	}
    	System.debug(LoggingLevel.ERROR,'**** PrepareResponse return value' + response); 
    	return response;
  	}
    
  	Public Static List<RESTLeasingActivityHelper.LeasingActivityResponse> PrepareOpportunityResponse( List<RESTLeasingActivityHelper.LeasingActivityWrapper> finalActivitiesToBeProcessed,
                              List <Opportunity> OppList)
  	{
        System.debug(LoggingLevel.ERROR,'**** PrepareResponse' + OppList);
        List<RESTLeasingActivityHelper.LeasingActivityResponse> response = new List<RESTLeasingActivityHelper.LeasingActivityResponse>();
        
        Map <String, Opportunity> prospectToOppMap = new Map <String, Opportunity> ();
        for(Opportunity Opp: OppList){
            prospectToOppMap.put(Opp.Yardi_Prospect_Id__c +'_' + Opp.Rental_Listing__r.Rental_Listing_Id__c , Opp);
        }

        for (RESTLeasingActivityHelper.LeasingActivityWrapper act : finalActivitiesToBeProcessed) 
        {
            if(prospectToOppMap.containsKey(act.prospectId + '_' + act.listingId))
            {
                Opportunity opp = prospectToOppMap.get(act.prospectId + '_' + act.listingId);
                System.debug(LoggingLevel.ERROR,'****////// PrepareResponse' + act.activityId + opp.Id);
                RESTLeasingActivityHelper.LeasingActivityResponse lar= new RESTLeasingActivityHelper.LeasingActivityResponse();
                lar.activityId = act.activityId;
                lar.salesforceId = opp.id;
                response.add(lar);
            }
        }
        System.debug(LoggingLevel.ERROR,'**** PrepareResponse return value' + response);
        return response;
	}

    
    
    //Create ORU, ORU Activity, Tasks
	Public Static void CreateOpportunityRelatedLists(List<RESTLeasingActivityHelper.LeasingActivityWrapper> finalActivitiesToBeProcessed,
                                                     List <Opportunity> OppList,
                                                     Map<string, Rental_Listing__c> rentalListingsMap, Id defaultOwnerId)
                        
  	{
        Map <String, Opportunity> prospectToOppMap = new Map <String, Opportunity> ();
        Map <String, Opportunity> ContactIDToOppMap = new Map <String, Opportunity> ();
        //Map <String, RESTLeasingActivityHelper.LeasingActivityWrapper> prospectIdTo
        
        for(Opportunity Opp: OppList){
            prospectToOppMap.put(Opp.Yardi_Prospect_Id__c + '_' + Opp.Rental_Listing__r.Rental_Listing_Id__c, Opp);
            ContactIDToOppMap.put(Opp.Primary_Leasing_Contact__c, Opp);
        }
        
        
        
        //Create Contact role
        //CreateOpportunityContactRoles(leasingActivityList, allContactsEmailMap, allContactsPhoneMap, emailContactIdMap, phoneContactIdMap, allOppportunitiesMap, matchingOppportunityMap);
        
        //Create ORUs
        List<RESTLeasingActivityHelper.LeasingActivityWrapper>  createActivitiesList = CreateOpportunityRentalUnits(finalActivitiesToBeProcessed, rentalListingsMap ,OppList);        
    
        //Create activities and tasks
        CreateActivityRelatedTasks(createActivitiesList, defaultOwnerId, rentalListingsMap, OppList);
	}  //function
    
    
	Private Static void CreateActivityRelatedTasks(List<RESTLeasingActivityHelper.LeasingActivityWrapper>  createActivitiesList, Id defaultOwnerId,  
                            						Map<string, Rental_Listing__c> rentalListingsMap, List <Opportunity> OppList)
    {
    	System.debug(LoggingLevel.ERROR,'**** CreateActivityRelatedTasks' + createActivitiesList);
                                                        
    	Set <Id> oppIdSet = new Set <Id> ();
        for(Opportunity Opp: OppList){
            oppIdSet.add(Opp.Id);                                                
        }
        
        System.debug('NDEBUG Opportunity Id Set::::' + oppIdSet);
    
        Map <String, OpportunityRentalUnit__c> keyToOruMap = new  Map <String, OpportunityRentalUnit__c> ();
        //fetch existing and newly created ORU's
        for(OpportunityRentalUnit__c oru : [
                                                          SELECT
                                                            Id,
                                                            name,
                                                            Current_Market_Rent__c,
                                                            status__c,
        													Opportunity__c,
                                                            Leasing__r.Property_Unit__r.HomeCode__c,
                                                            Opportunity__r.Primary_Leasing_Contact__c,
                                                            Opportunity__r.accountId,
        													Opportunity__r.contactId,
        													Opportunity__r.Yardi_Prospect_Id__c,
                                                            Leasing__r.Rental_Listing_Id__c
                                                          	FROM OpportunityRentalUnit__c
                                                          	WHERE Opportunity__r.Id IN : oppIdSet
                                                        ])
        {
            String Key = oru.Opportunity__r.Yardi_Prospect_Id__c + '_' + oru.Leasing__r.Rental_Listing_Id__c;
            keyToOruMap.put(key, oru);
        }
        
        System.debug('NDEBUG keyToOruMap::::' + keyToOruMap);
    

        List<Opportunity_Rental_Unit_Activity__c> createOpportunityRentalActivityList = new List<Opportunity_Rental_Unit_Activity__c>();
        Set<string> oruaidSet = new Set<string>(); //keep track of duplicate ids in this batch
    
        //Note-change Update ORU activity name workflow field update if you need a differnt display value
        List<String> activityCreateCodes = new List<String>{
                                                          'self_registered_scheduling',
                                                          'controlled_showing',
                                                          'self_registered_viewing',
                                                          'prelease_signup',
                                                          'prelease_alert',
                                                          'application_started',
                                                          'application_applied',
                                                          'application_approved',
                                                          'application_canceled',
                                                          'application_denied',
                                                          'lease_signed',
                                                          'application_transfer',
                                                          'prospect',
                                                          'prospect_updated',
                                                          'prospect_canceled',
                                                          'phone_inquiry',
                                                          'email',
                                                          'other'
                                                        };

        List<Leasing_Markets__c> lms = Leasing_Markets__c.getall().values();
        Map<string, String> lmsMap = new Map<string, String>();
        Set<String> lmsSet = new Set<String>();
    
        //get the market -PM from custom settings~
        for (Leasing_Markets__c lm : lms) {
            lmsMap.put(lm.name, lm.Manager_Email__c);
            lmsSet.add(lm.Manager_Email__c);
        }
        List<Task> createTaskList = new List<Task>();
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

        //update the remaining ORU's
        for (RESTLeasingActivityHelper.LeasingActivityWrapper act : createActivitiesList) {
        	String Key = act.prospectId + '_' + act.listingId;
            if(keyToOruMap.containsKey(key)) {// && activityCreateCodes.contains(act.activityType)){
                Opportunity_Rental_Unit_Activity__c orua = new Opportunity_Rental_Unit_Activity__c();
                Rental_Listing__c rentalListing = new Rental_Listing__c ();
                
                if (String.isNotBlank(act.transferredToListingId)) 
                {
                    rentalListing = rentalListingsMap.get(act.transferredToListingId);
                    if (rentalListing != null) 
                    {
                        orua.Transferred_To__c = rentalListing.id;
                    }
                }
                orua.Opportunity_Rental_Unit__c = keyToOruMap.get(key).Id;
                orua.Leasing_Opportunity__c = keyToOruMap.get(key).Opportunity__c;
                orua.Activity_Code__c = act.activityType;
                orua.Timestamp__c = act.timeStamp;
                orua.BPM_Activity_Id__c = act.activityId;
                orua.Timezone__c = act.timezone;
                orua.feedback__c = act.feedback;
                orua.HasFeedback__c = String.isNotBlank(act.feedback);
                
                //create feedback task
                
                if(String.isNotBlank(act.feedback)){
                    //get the  owner for this market from custom setting
                    Rental_Listing__c taskListing = rentalListingsMap.get(act.listingId);
                    String market = taskListing.Property_Unit__r.property__r.Leasing_Market__c;
                    String marketOwnerId  = marketManagerMap.get(market);
                    if(marketOwnerId == null){
                        marketOwnerId= defaultOwnerId;
                    }
                    System.debug(LoggingLevel.ERROR,'**** Feedback' + market + taskListing.id + '->' + keyToOruMap.get(key).Opportunity__c 
                                 + keyToOruMap.get(key).Opportunity__r.Primary_Leasing_Contact__c);
                    
                    Task t = new Task();
                    
                    t.OwnerId = marketOwnerId;
                    t.Subject = 'Feedback Received : ' + taskListing.property_unit__r.name;
                    t.Description=  act.feedback ;
                    t.Status = 'New';
                    t.type='Feedback';
                    t.Priority = 'High';
                    // t.WhatId = unitExistsInOpportunityId;
                    t.whatId = keyToOruMap.get(key).Opportunity__c;
                    t.whoId = keyToOruMap.get(key).Opportunity__r.Primary_Leasing_Contact__c;
                    createTaskList.add(t);
                }
                
                //check if this batch had duplicate ids  
                if(!oruaidSet.contains(act.activityId))
                {
                    createOpportunityRentalActivityList.add(orua);
                    oruaidSet.add(act.activityId);
                }               
            }

            System.debug(LoggingLevel.ERROR,'**** ORUA activity list' + createOpportunityRentalActivityList);
        
            if (createOpportunityRentalActivityList.size() > 0) {
            	upsert createOpportunityRentalActivityList BPM_Activity_Id__c;
            } //if
    
            //create feedback task
            if (createTaskList.size() > 0) {
            	insert createTaskList;
            } //if
		}
    }
    
 


  	Public Static List<RESTLeasingActivityHelper.LeasingActivityWrapper> CreateOpportunityRentalUnits(
        List<RESTLeasingActivityHelper.LeasingActivityWrapper> finalActivitiesToBeProcessed,
             Map<string, Rental_Listing__c> rentalListingsMap, List <Opportunity> OppList) 
  	{
    	System.debug(LoggingLevel.ERROR,'**** CreateOpportunityRentalUnits' + OppList);
        System.debug(LoggingLevel.ERROR,'**** finalActivitiesToBeProcessed' + finalActivitiesToBeProcessed);
        //List <RESTLeasingActivityHelper.LeasingActivityWrapper> createActivitiesList = new List <RESTLeasingActivityHelper.LeasingActivityWrapper> ();
        
        Set <Id> OppIdSet = new Set <Id> ();
        Map <String, Opportunity> keyToOppMap = new Map <String, Opportunity> ();
        
        for(Opportunity Opp: OppList){
            keyToOppMap.put(Opp.Yardi_Prospect_Id__c + '_' + Opp.Rental_Listing__r.Rental_Listing_Id__c, Opp);
            OppIdSet.add(Opp.Id);
        }
        
        
    	List<OpportunityRentalUnit__c> matchingOppRentalUnitList = [ SELECT Id, name, Current_Market_Rent__c, status__c, Leasing__r.Property_Unit__r.HomeCode__c, Leasing__c,
                                                                Opportunity__r.accountid, Opportunity__r.contactId, Leasing__r.Rental_Listing_Id__c, 
                                                                Opportunity__r.Yardi_Prospect_Id__c, Opportunity__c, Opportunity__r.Primary_Leasing_Contact__c
                                                                FROM OpportunityRentalUnit__c
                                                                WHERE Opportunity__c IN : OppIdSet 
                                                                ];
        
        Map <String, OpportunityRentalUnit__c> uniqueKeyToORUMAP = new Map <String, OpportunityRentalUnit__c> ();
        
        for(OpportunityRentalUnit__c oru : matchingOppRentalUnitList){
            String key = oru.Opportunity__r.Yardi_Prospect_Id__c + '_' + oru.Leasing__r.Rental_Listing_Id__c;
            uniqueKeyToORUMAP.put(key, oru);    
        }
        System.debug('NDEBUG ORU Map:::' +uniqueKeyToORUMAP);
        System.debug('NDEBUG Opp Map:::' +keyToOppMap);
        
        List<OpportunityRentalUnit__c> newOpportunityRentalUnitList = new List<OpportunityRentalUnit__c>();
        OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c();
        Set <String> insertedOrus = new Set <String> ();
        for(RESTLeasingActivityHelper.LeasingActivityWrapper act: finalActivitiesToBeProcessed){
            String key = act.prospectId + '_' + act.listingId;
            System.debug('NDEBUG Key :::' + key);
            if(!uniqueKeyToORUMAP.containsKey(key) && rentalListingsMap.containsKey(act.listingId)){
                //String key1 = act.prospectId;
                if(keyToOppMap.containsKey(key))
                {
                    
                    Rental_Listing__c rentalListing = new Rental_Listing__c ();
                    rentalListing = rentalListingsMap.get(act.listingId);
                    System.debug('NDEBUG Rental Listing :::' + rentalListing.Id);
                    
                    
                    //String key2 = keyToOppMap.get(act.prospectId).Primary_Leasing_Contact__c + '_' + rentalListing.Id;
                    //System.debug('NDEBUG Key2 :::' + key2);
                    if(!insertedOrus.contains(key))
                    {
                        insertedOrus.add(key);
                        oru = new OpportunityRentalUnit__c();
                        oru.Opportunity__c = keyToOppMap.get(key).Id; 
                        oru.Primary_Leasing_Contact__c = keyToOppMap.get(key).Primary_Leasing_Contact__c;
                        oru.ActivityId__c = act.activityId;
                        oru.name = rentalListing != null ? rentalListing.name : 'Missing Listing';
                        oru.Current_Market_Rent__c = rentalListing != null ? rentalListing.Current_Rent__c : 0;
                        oru.Leasing__c = rentalListing != null ? rentalListing.Id : null;
                        oru.Status__c = 'New';
                        newOpportunityRentalUnitList.add(oru);
                    }
                    
                }
            }
            
        }
        
      	
        if (newOpportunityRentalUnitList.size() > 0) {
            System.debug('NDEBUG ORUs being inserted::::' + newOpportunityRentalUnitList);
            insert newOpportunityRentalUnitList;
        }
        
    
        return finalActivitiesToBeProcessed;
	}

    /*
    Public Static void CreateOpportunityContactRoles(List<RESTLeasingActivityHelper.LeasingActivityWrapper> leasingActivityList,
                                                     Map<String, Id> allContactsEmailMap, Map<String, Id> allContactsPhoneMap,                         
                                                     Map<String, Id> emailContactIdMap, Map<String, Id> phoneContactIdMap,  Map<Id, Opportunity> allOppportunitiesMap, Map<Id, Opportunity> matchingOppportunityMap
                                                    )
    {
        List<OpportunityContactRole> newContactRoleList = new List<OpportunityContactRole>();
        //create opporutnuity contact role
        //phoneContactIdMap emailContactIdMap
        Set<Id> opportunityrolesCreatedSet = new Set<Id>();
        
        for (RESTLeasingActivityHelper.LeasingActivityWrapper la : leasingActivityList) 
        {
            Id contactId;
            Id accountId;
            
            if (String.isNotBlank(la.email)) {
                accountId = allContactsEmailMap.get(la.email);
                contactId = emailContactIdMap.get(la.email);
            }
            if (String.isBlank(contactId) && String.isNotBlank(la.phone)) {
                contactId = phoneContactIdMap.get(la.phone);
            }
            if (String.isBlank(accountId) && String.isNotBlank(la.phone)) {
                accountId = allContactsPhoneMap.get(la.phone);
            }
            
            Opportunity opp = allOppportunitiesMap.get(accountId);
            
            //create this contact role only for new opportunities created and for the ones already not created in this session
            //opportunityrolesCreatedSet stores oppid, this could technically also be accid since there can only be one open opp.
            
            if (
                opp != null &&
                accountId != null &&
                contactId != null &&
                !matchingOppportunityMap.containsKey(accountId) &&
                !opportunityrolesCreatedSet.contains(opp.id)
            ) {
                newContactRoleList.add(
                    new OpportunityContactRole(
                        ContactId = contactId,
                        OpportunityId = opp.Id,
                        Role = 'Decision Maker',
                        IsPrimary = true
                    )
                );
                
                opportunityrolesCreatedSet.add(opp.id);
            } //if
        } //for
        if (newContactRoleList.size() > 0) {
            insert newContactRoleList;
        }
    }  
    
    */
    
    Public Static void processMinorApplicants(List<RESTLeasingActivityHelper.LeasingActivityWrapper> minorApplActivityList, Set <String> minorsListingIdsSet)
    {
        Map <String, List <RESTLeasingActivityHelper.LeasingActivityWrapper> > priProspectToMinorApplMap = new Map <String, List <RESTLeasingActivityHelper.LeasingActivityWrapper> > ();
        Set <String> priProspectsSet = new Set <String> ();
        for(RESTLeasingActivityHelper.LeasingActivityWrapper act : minorApplActivityList){
            if(String.isNotBlank(act.primaryProspectId) && act.primaryProspectId != '0' && String.isNotBlank(act.prospectId) && act.prospectId != '0')
            {
                List <RESTLeasingActivityHelper.LeasingActivityWrapper> tempActList = new List <RESTLeasingActivityHelper.LeasingActivityWrapper> ();
                if(priProspectToMinorApplMap.containsKey(act.primaryProspectId + '_' + act.listingId)){
                    tempActList = priProspectToMinorApplMap.get(act.primaryProspectId + '_' + act.listingId);
                }
                tempActList.add(act);
                priProspectToMinorApplMap.put(act.primaryProspectId + '_' + act.listingId,tempActList);
                priProspectsSet.add(act.primaryProspectId);
            }
        }
        if(priProspectToMinorApplMap != null && priProspectToMinorApplMap.size() >0){
            Map <String, Opportunity> prospectToOppMap = new Map <String, Opportunity> ();
            
            Map<string, Rental_Listing__c> rentalListingsMap = new Map<string, Rental_Listing__c>();

            // Get the Rental Listing Information
            List<Rental_Listing__c> rentalListingList = [
                SELECT id, name, Rental_Listing_Id__c, Current_Rent__c, Status__c, property_unit__r.name, 
                Property_Unit__r.property__r.Leasing_Market__c
                FROM Rental_Listing__c
                WHERE Rental_Listing_Id__c IN : minorsListingIdsSet
            ];
            
            for (Rental_Listing__c rl : rentalListingList) {
                rentalListingsMap.put(rl.Rental_Listing_Id__c, rl);
            }
            
            List <Opportunity> priApplOpplist = [SELECT Id, Minor_Applicants__c, Yardi_Prospect_Id__c, Rental_Listing__r.Rental_Listing_Id__c  from Opportunity 
                                                 WHERE Yardi_Prospect_Id__c IN : priProspectsSet
                                                 AND RecordType.Id =: RecordTypes.leasingOpportunityRecordTypeId
                                                 AND stagename NOT IN ('Closed Won = Lease Signed', 'Closed Lost')
                                                 ORDER BY CREATEDDATE DESC];
            for(Opportunity Opp: priApplOpplist){
                if(String.isNotBlank(Opp.Yardi_Prospect_Id__c) && Opp.Yardi_Prospect_Id__c != '0'){
                    prospectToOppMap.put(Opp.Yardi_Prospect_Id__c + '_' + Opp.Rental_Listing__r.Rental_Listing_Id__c, Opp);
                }                	
            }
            
            List <Opportunity> priApplOppsToBeUpdated = new List <Opportunity>  ();
            for(String key: priProspectToMinorApplMap.keySet()){
                String htmlBody = '';
                if(prospectToOppMap.containsKey(key)){
                    if(String.IsBlank(prospectToOppMap.get(key).Minor_Applicants__c)){
                        htmlBody = '<table border="1" style="border-collapse: collapse"><caption></caption><tr><th>Yardi Prospect Id</th><th>Name</th><th>Relationship</th></tr>'; 
                        for(RESTLeasingActivityHelper.LeasingActivityWrapper act : priProspectToMinorApplMap.get(key))
                        {
                            if(!htmlBody.contains(act.prospectId)){
                            	htmlBody += '<tr><td>' + act.prospectId + '</td><td>' + act.lastName +', ' + act.firstName + '</td><td>' + act.relationship + '</td></tr>';
                            }
                        }
                    }
                    else{
                        htmlBody = prospectToOppMap.get(key).Minor_Applicants__c;
                        
                        for(RESTLeasingActivityHelper.LeasingActivityWrapper act : priProspectToMinorApplMap.get(key))
                        {
                            if(!htmlBody.contains(act.prospectId)){
                                htmlBody += '<table border="1" style="border-collapse: collapse">';
                               htmlBody += '<tr><td>' + act.prospectId + '</td><td>' + act.lastName +', ' + act.firstName + '</td><td>' + act.relationship + '</td></tr>'; 
                            }
                        }                        
                    }                   
                    priApplOppsToBeUpdated.add(new Opportunity(Id = prospectToOppMap.get(key).Id, Minor_Applicants__c = htmlBody));
                }
            }
            if(priApplOppsToBeUpdated != null && priApplOppsToBeUpdated.size() >0){
                update priApplOppsToBeUpdated;
            }
            
        }
    }

}
// June 7 10.00pm
global class RESTLeasingActivityHelper {
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
      
    // Added for Lead to Leasing
    global string prospectId;
    global string primaryProspectId;
    global string relationship;
    global string   code;
    global boolean backgroundRun;
    global date  moveInDate;
    global date  leaseStart;
    global date leaseEnd;
    global decimal leaseRent;
    global decimal securityDeposit;
    global Integer numPets;
    global string feedback;
    global boolean isViewing;
    global date movedInDate;
      global date  pmSigned;
      global date  leaseSignedTenant;
      global date  leaseSentDate;
      global date  decisionDate;
      global string backGroundStatus;
      global date dateSubmitted;
      global string transferredToListingId;
      global string appDecision;
      global string appStatus;
      global string tenantStatus;
      global string cancelledReason;
      global string reportId;
      global string  prospectNotes;
  }

  global class LeasingActivityResponse {
    global string activityId;
    global string salesforceId;

  }
 
  global class PostResponse {
    global String responseBody;
  }
  
  static Id leasingAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('Leasing')
    .getRecordTypeId();
  static Id leasingContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
    .get('Leasing')
    .getRecordTypeId();
  static Id leasingOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
    .get('Leasing')
    .getRecordTypeId();
    
  static Id leasingSecApplOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
    .get('Leasing_Secondary_Applicant')
    .getRecordTypeId();

  static Id leasingLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
    .get('Leasing')
    .getRecordTypeId();

  global static List<LeasingActivityResponse> AddLeasingActivity(
    list<LeasingActivityWrapper> leasingActivityList
  ) {
    
    System.debug('NDEBUG lactlist'+ leasingActivityList);

    //hold the opportunity added ,this will be returned alongwith the lead response
    List<LeasingActivityResponse> resp 
              = CreateOpportunityForActivityWithListingInfo(leasingActivityList);

    List<LeasingActivityResponse> leadResp = CreateLeadForActivityWithMissingListing(leasingActivityList);

    //add both lists
    resp.addAll(leadResp);
    return resp;
  }

  static String getUUID() {
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



  static List<LeasingActivityResponse> CreateOpportunityForActivityWithListingInfo(
    list<LeasingActivityWrapper> leasingActivityList
  ) {
    //emails to query contacts
    Set<String> emails = new Set<String>();
    Set<String> phones = new Set<String>();
    Set<String> listingIds = new Set<String>();

    // Set<Id> leadIds = new Set<Id>();
    List<LeasingActivityWrapper> activityWithListing = new List<LeasingActivityWrapper>();

    System.debug('NDEBUG -----');
      System.debug('NDEBUG -----'+leasingActivityList);
    // Iterate through each notification
    for (LeasingActivityWrapper la : leasingActivityList) {
      //create lead for missing listingids (phone inquiries)
      //note- email inquiries are not handled in this logic!
      System.debug('NDEBUG ----+');
      if (String.isNotBlank(la.listingId)) {
        listingIds.add(la.listingId);
        activityWithListing.add(la);

          /*
        if (la.transferredToListingId != null) {
          listingIds.add(la.transferredToListingId);
        }
*/

        if (String.isNotBlank(la.email)) {
          emails.add(la.email);
        }
        if (String.isNotBlank(la.phone)) {
          phones.add(la.phone);
        } //if2
      } //if1
    } //for
    List<User> defaultOwner = [
      SELECT id
      FROM user
      WHERE email like 'dbaker@streetlane.com%'
      and isactive=true
    ];

    Id defaultOwnerId;
    /*if (defaultOwner != null && defaultOwner.size() > 0) {
      defaultOwnerId = defaultOwner[0].id;
    } else {*/
        // REMOVE HARD CODING
      defaultOwnerId = [Select User_Id__c from Roofstock__mdt where DeveloperName = 'Integration_User' ]?.User_Id__c; //fallback to integration, if default not found, admin 0051C000009jS6JQAU
    //}
    System.debug(
      LoggingLevel.ERROR,
      '**Converting Lead searching ' +
      emails +
      phones
    );

    Set<Id> leadIds = GetLeadsWithMatchingPhoneEmail(emails, phones);
    System.debug(LoggingLevel.ERROR, '**Converting Lead  ' + leadIds);

    //convert any existing matching leads to account/contact
    if (leadIds.size() > 0) {
      ConvertMatchingLeadsToAccount(leadIds, defaultOwnerId);
    }
    List<LeasingActivityResponse> oppResponse = new List<LeasingActivityResponse>();
    
    if (activityWithListing.size() > 0) {
      System.debug(LoggingLevel.ERROR, '**creating contact opportunities ' + activityWithListing.size());

      createAccountContacts(
        activityWithListing,
        emails,
        phones,
        defaultOwnerId
      );
      oppResponse =  createOpportunities(
        activityWithListing,
        emails,
        phones,
        listingIds,
        defaultOwnerId
      );
    }
    return oppResponse;
  }

  static void ConvertMatchingLeadsToAccount(
    Set<Id> leadIds,
    String defaultOwnerId
  ) {
    list<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();

    for (Id leadId : leadIds) {
      Database.Leadconvert lc = new Database.Leadconvert();
      lc.setLeadId(leadId);
      lc.setConvertedStatus('Interested');
      lc.setDoNotCreateOpportunity(true);
      lc.setOwnerId(defaultOwnerId);
      leadConverts.add(lc);
    }

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
        for (Database.LeadConvertResult lcr : lcrList)
          System.debug(LoggingLevel.ERROR, '**Converting Lead  ' + lcr);
      }
    }
  }
  static Set<Id> GetLeadsWithMatchingPhoneEmail(
    Set<String> emails,
    Set<String> phones
  ) {
    Set<Id> leadIds = new Set<Id>();

    //store the existing SF contacts with matching phones
    List<Lead> leadPhoneList = [
      SELECT phone, id, email
      FROM Lead
      WHERE
        Phone IN :phones
        AND recordTypeId = :RESTLeasingActivityHelper.leasingLeadRecordTypeId
    ];

    List<Lead> leadEmailList = [
      SELECT phone, id, email
      FROM Lead
      WHERE
        email IN :emails
        AND recordTypeId = :RESTLeasingActivityHelper.leasingLeadRecordTypeId
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
  static void createAccountContacts(
    List<LeasingActivityWrapper> leasingActivityList,
    Set<String> emails,
    Set<String> phones,
    Id defaultOwnerId
  ) {
    //Lookup existing contacts with matching email
    List<Contact> contactList = [
      SELECT email, phone, account.id
      FROM Contact
      WHERE
        email IN :emails
        AND recordTypeId = :RESTLeasingActivityHelper.leasingContactRecordTypeId
    ];

    Map<String, Id> contactEmailMap = new Map<String, Id>();

    for (Contact contact : contactList) {
      if (String.isNotBlank(contact.email)) {
        contactEmailMap.put(contact.email, contact.account.Id);
      }
    } //for

    //store the existing SF contacts with matching phones
    List<Contact> contactNamePhoneList = [
      SELECT phone, email, account.id, SearchableNamePhone__c
      FROM Contact
      WHERE
        Phone IN :phones
        AND recordTypeId = :RESTLeasingActivityHelper.leasingContactRecordTypeId
    ];

    Map<String, Id> contactPhoneMap = new Map<String, Id>();

    for (Contact contact : contactNamePhoneList) {
      if (String.isNotBlank(contact.phone)) {
        contactPhoneMap.put(contact.phone, contact.account.Id);
      }
    } //for

    List<sObject> lstAobject = new List<sObject>();
    List<sObject> lstCobject = new List<sObject>();

    //store the newly create contacts
    Set<String> createContactsSet = new Set<String>();

    for (LeasingActivityWrapper la : leasingActivityList) {
      //extid is required to create account and contact in one DML
      String extId = getUUID();

      Boolean existingOrAddedInthisBatch =
        contactEmailMap.containsKey(la.email) ||
        contactPhoneMap.containsKey(la.phone) ||
        createContactsSet.contains(la.email) ||
        createContactsSet.contains(la.phone);

      if (!existingOrAddedInthisBatch) {
        Contact newContact1 = new Contact(
          FirstName = la.firstName,
          LastName = la.lastName,
          Email = la.email,
          Phone = la.phone,
          RecordTypeId = RESTLeasingActivityHelper.leasingContactRecordTypeId,
          Ownerid = defaultOwnerId
        );

        Account accountReference = new Account(RentlyId__c = extId);
        newContact1.Account = accountReference;

        Account parentAccount1 = new Account(
          Name = la.firstName + ' ' + la.lastName,
          RentlyId__c = extId,
          RecordTypeId = RESTLeasingActivityHelper.leasingAccountRecordTypeId,
          Ownerid = defaultOwnerId
        );
        if (string.isNotBlank(la.phone)) {
          parentAccount1.phone = la.phone;
        }
        if (string.isNotBlank(la.email)) {
          parentAccount1.Company_Email__c = la.email;
        }
        //order is important!
        lstAobject.add(parentAccount1);
        lstCobject.add(newContact1);

        //both phone and email should be added to set to avoid duplicates in cureent batch
        if (String.isNotBlank(la.email)) {
          createContactsSet.add(la.email);
        }
        if (String.isNotBlank(la.phone)) {
          createContactsSet.add(la.phone);
        }
      } //if
    } //for

    System.debug(
      LoggingLevel.ERROR,
      '**Successfully created ID: ' +
      lstAobject +
      lstCobject
    );
    //create all missing accouts and contacts
    Database.SaveResult[] results1 = Database.insert(lstAobject);
    Database.SaveResult[] results2 = Database.insert(lstCobject);
  }

  static List<LeasingActivityResponse> CreateLeadForActivityWithMissingListing(
    List<LeasingActivityWrapper> leasingActivityList
  ) {
    List<LeasingActivityWrapper> activityWithoutListing = new List<LeasingActivityWrapper>();

    Set<String> phones = new Set<String>();
    Set<String> emails = new Set<String>();

    for (LeasingActivityWrapper la : leasingActivityList) {
      //create lead for missing listingids (phone inquiries)
      //note- email inquiries are not handled in this logic!
      if (String.isBlank(la.listingId)) {
        if (String.isNotBlank(la.email)) {
          emails.add(la.email);
        }
        if (String.isNotBlank(la.phone)) {
          phones.add(la.phone);
        } //if2
        activityWithoutListing.add(la);
      }
    }
    List<LeasingActivityResponse> response = new List<LeasingActivityResponse>();
    if (activityWithoutListing.size() > 0) {
      response =  createLeads(activityWithoutListing, phones, emails);
    }
    return response;
  }

  static List<LeasingActivityResponse>  createLeads(
    List<LeasingActivityWrapper> leasingActivityList,
    Set<String> phones,
    Set<String> emails
  ) {
   /* Group LeasingQueue = [
      SELECT Id
      FROM Group
      WHERE Type = 'Queue' AND Name = 'Leasing Queue'
      LIMIT 1
    ];*/ 

    //store the existing SF contacts with matching phones
    List<Lead> leadPhoneList = [
      SELECT phone, id, email
      FROM Lead
      WHERE
        Phone IN :phones
        AND recordTypeId = :RESTLeasingActivityHelper.leasingLeadRecordTypeId
    ];

    List<Lead> leadEmailList = [
      SELECT phone, id, email
      FROM Lead
      WHERE
        email IN :emails
        AND recordTypeId = :RESTLeasingActivityHelper.leasingLeadRecordTypeId
    ];
    Map<String, Id> leadPhoneMap = new Map<String, Id>();
    Map<String, Id> leadEmailMap = new Map<String, Id>();
    Set<String> leadsCreatedInThisTransactionSet = new Set<String>();

    for (Lead lead : leadPhoneList) {
      if (String.isNotBlank(lead.phone)) {
        leadPhoneMap.put(lead.phone, lead.Id);
      }
    } //for
    for (Lead lead : leadEmailList) {
      if (String.isNotBlank(lead.email)) {
        leadEmailMap.put(lead.email, lead.Id);
      }
    } //for

    //check if there is matching contacts before creating leads
    List<Contact> allContactsEmailList = [
      SELECT email, account.id, SearchableNamePhone__c
      FROM Contact
      WHERE
        email IN :emails
        AND recordTypeId = :RESTLeasingActivityHelper.leasingContactRecordTypeId
    ];

    List<Contact> allcontactsPhoneList = [
      SELECT email, account.id, phone
      FROM Contact
      WHERE
        phone IN :phones
        AND recordTypeId = :RESTLeasingActivityHelper.leasingContactRecordTypeId
    ];

    // Map<String, Id> allContactsEmailMap = new Map<String, Id>();
    Set<String> allContactsEmailSet = new Set<String>();
    for (Contact contact : allContactsEmailList) {
      if (String.isNotBlank(contact.email)) {
        allContactsEmailSet.add(contact.email);
      }
    }

    // Map<String, Id> allContactsPhoneMap = new Map<String, Id>();
    Set<String> allContactsPhoneSet = new Set<String>();

    for (Contact contact : allcontactsPhoneList) {
      if (String.isNotBlank(contact.phone)) {
        allContactsPhoneSet.add(contact.phone);
      }
    }

    List<Lead> leads = new List<Lead>();

    for (LeasingActivityWrapper la : leasingActivityList) {
      Boolean existingLead =
        allContactsEmailSet.contains(la.email) || //existing contact
        allContactsPhoneSet.contains(la.phone) || //existing contact
        leadPhoneMap.containsKey(la.phone) || //existing lead
        leadEmailMap.containsKey(la.email) || //existing lead
        leadsCreatedInThisTransactionSet.contains(la.phone) || //new lead  in this batch
        leadsCreatedInThisTransactionSet.contains(la.email); //new lead in this batch

      if (!existingLead) {
        Lead newLead = new Lead(
          FirstName = la.firstName, //name is not known for phone inquiries
          LastName = (la.lastName == '' ? 'Unknown' : la.lastName),
          company = la.firstName + ' ' + la.lastName,
          Phone = la.phone,
          email = la.email,
          RecordTypeId = RESTLeasingActivityHelper.leasingLeadRecordTypeId,
          LeadSource = la.source,
          Source_Created_Date__c = la.timestamp,
         // ownerId = LeasingQueue.Id,
          X1_Ideally_when_would_you_buy_your_first__c = Date.today().addDays(14)
        );
        
        if (String.isNotBlank(la.prospectId) && (la.prospectId != '0')) {
          newLead.Yardi_Prospect_Id__c = la.prospectId;
        }
        if (String.isNotBlank(la.phone)) {
          leadsCreatedInThisTransactionSet.add(la.phone);
        }
        if (String.isNotBlank(la.email)) {
          leadsCreatedInThisTransactionSet.add(la.email);
        }

        leads.add(newLead);
      } //if
    } //for

    //create all missing accouts and contacts
    insert leads;

    List<LeasingActivityResponse> response = PrepareLeadResponse(leads, leasingActivityList);

    return response;
  }

  private static List<LeasingActivityResponse> PrepareLeadResponse( List<Lead> leads, 
                                  List<LeasingActivityWrapper> leasingActivityList){

    List<LeasingActivityResponse> response = new List<LeasingActivityResponse>();

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

    for (LeasingActivityWrapper la : leasingActivityList) {
      Id leadId;
  
      if (String.isNotBlank(la.email)) {
        leadId = leadsEmailMap.get(la.email);
      }
  
      if (String.isBlank(leadId) && String.isNotBlank(la.phone)) {
        leadId = leadsEmailMap.get(la.phone);
      }

      if(String.isNotBlank(leadId)) {
        LeasingActivityResponse lar= new LeasingActivityResponse();
        lar.activityId = la.activityId;
        lar.salesforceId = leadId;
        // la.activityId, opp.id
        response.add(lar);
      }
  
  
    }
    System.debug(LoggingLevel.ERROR,'**** PrepareResponse return value' + response);
  
    return response;
  }


  static List<LeasingActivityResponse> createOpportunities(
    List<LeasingActivityWrapper> activityList,
    Set<String> emails,
    Set<String> phones,
    Set<String> listingIds,
    Id defaultOwnerId
  ) {
    //opportunity closing date default
    Date dt = Date.today().addDays(14);

    //we have created accounts et contacts!
    List<Contact> allContactsEmailList = [
      SELECT email, account.id, SearchableNamePhone__c
      FROM Contact
      WHERE
        email IN :emails
        AND recordTypeId = :RESTLeasingActivityHelper.leasingContactRecordTypeId
    ];

    List<Contact> allcontactsPhoneList = [
      SELECT email, account.id, phone
      FROM Contact
      WHERE
        phone IN :phones
        AND recordTypeId = :RESTLeasingActivityHelper.leasingContactRecordTypeId
    ];

    Map<String, Id> allContactsEmailMap = new Map<String, Id>();
    Map<String, Id> emailContactIdMap = new Map<String, Id>();

    Set<String> accountIds = new Set<String>();

    for (Contact contact : allContactsEmailList) {
      if (String.isNotBlank(contact.email)) {
        allContactsEmailMap.put(contact.email, contact.account.Id);
        emailContactIdMap.put(contact.email, contact.Id);

        accountIds.add(contact.account.Id);
      }
    }

    Map<String, Id> allContactsPhoneMap = new Map<String, Id>();
    Map<String, Id> phoneContactIdMap = new Map<String, Id>();

    for (Contact contact : allcontactsPhoneList) {
      if (String.isNotBlank(contact.phone)) {
        allContactsPhoneMap.put(contact.phone, contact.account.Id);
        phoneContactIdMap.put(contact.phone, contact.Id);

        accountIds.add(contact.account.Id);
      }
    }
    //get opps that were closed in last n days and ignore any new activities for the same
    List<Opportunity> recentlyClosedOppportunityList = [
      SELECT id, account.id, Primary_Leasing_Contact__c
      FROM Opportunity
      WHERE
        accountid IN :accountIds
        AND (RecordType.id = :leasingOpportunityRecordTypeId or RecordType.id = :leasingSecApplOppRecordTypeId)
        AND stagename IN ('Closed Won = Lease Signed') 
        AND CloseDate = LAST_N_DAYS:30
    ];

    Set<id> recentlyClosedAccountIDs = new Set<id>(); 
    for(Opportunity opp : recentlyClosedOppportunityList){
      recentlyClosedAccountIDs.add(opp.account.id);
    }

    System.debug(LoggingLevel.ERROR, '**** recentlyClosedOppportunityList ' + recentlyClosedOppportunityList.size());

    List<LeasingActivityWrapper> leasingActivityList = new List<LeasingActivityWrapper>();
    if(recentlyClosedAccountIDs.size() > 0 ) {
      System.debug(LoggingLevel.ERROR, '**** inside recentlyClosedOppportunityList ' + recentlyClosedOppportunityList.size());

        for (LeasingActivityWrapper la : activityList) {
          Id accountId;
          //email vs phone
          if (String.isNotBlank(la.email)) {
            accountId = allContactsEmailMap.get(la.email);
          }
          //if email did not match ,check for phone
          if (String.isBlank(accountId) && String.isNotBlank(la.phone)) {
            accountId = allContactsPhoneMap.get(la.phone);
          }
            //process this activity if it was not closed won recently!
            if(!recentlyClosedAccountIDs.contains(accountId)) {
              leasingActivityList.add(la);
            }
        }
    } else {
      leasingActivityList = activityList;
    }

    System.debug(LoggingLevel.ERROR, '**** recentlyClosedOppportunityList ' + recentlyClosedOppportunityList.size());

    // get exiting opportunities (open) for this accountIds and put the accountids into a set
    // existing accountid->opportunityid

    // for each activity
    // create new opportunities for accountids not in this list
    // end loop
    List<Opportunity> matchingOppportunityList = [
      SELECT id, account.id, stageName,Primary_Leasing_Contact__c
      FROM Opportunity
      WHERE
        accountid IN :accountIds
        AND (RecordType.id = :leasingOpportunityRecordTypeId OR RecordType.id = : leasingSecApplOppRecordTypeId)
        AND stagename NOT IN ('Closed Won = Lease Signed', 'Closed Lost')
    ];

    //o1 phone 11,o2 phone 12 existing
    //o3 phone 13 new
    Map<Id, Opportunity> matchingOppportunityMap = new Map<Id, Opportunity>();

    for (Opportunity opp : matchingOppportunityList) {
      matchingOppportunityMap.put(opp.account.id, opp);
    }
    List<Opportunity> oppsList = new List<Opportunity>();

    //keep track of new opportunities created in this transcation
    //to prevent duplicate opporutunity creation
    Set<Id> accountIdsopportunityCreated = new Set<Id>();

    Map<string, Rental_Listing__c> rentalListingsMap = new Map<string, Rental_Listing__c>();

    List<Rental_Listing__c> rentalListingList = [
      SELECT id, name, Rental_Listing_Id__c, Current_Rent__c, Status__c, property_unit__r.name, Property_Unit__r.property__r.Leasing_Market__c
      FROM Rental_Listing__c
      WHERE Rental_Listing_Id__c IN :listingIds
    ];

    for (Rental_Listing__c rl : rentalListingList) {
      rentalListingsMap.put(rl.Rental_Listing_Id__c, rl);
    }
    System.debug(LoggingLevel.ERROR, '**** creating opp created ' + leasingActivityList.size());

    // Process the Primary Applicants first     
    
    Set <String> listingsSet = new Set <String> ();
    Map <Id, Opportunity> updOppMap = new Map <Id, Opportunity> ();
    for (LeasingActivityWrapper la : leasingActivityList) {
      Id accountId;
      //email vs phone
      if (String.isNotBlank(la.email)) {
        accountId = allContactsEmailMap.get(la.email);
      }
      //if email did not match ,check for phone
      if (String.isBlank(accountId) && String.isNotBlank(la.phone)) {
        accountId = allContactsPhoneMap.get(la.phone);
      }
      String closeDateFormatted = String.valueOf(dt);
	  Opportunity opp = new Opportunity ();
      if (
        !matchingOppportunityMap.containsKey(accountId) &&
        !accountIdsopportunityCreated.contains(accountId)
      ) {
        String oppName =
          closeDateFormatted +
          '-' +
          la.firstName +
          '-' +
          la.lastName;

        //replace default oppname with phone or email if name is unknown
        if (
          String.isNotBlank(la.firstName) &&
          la.firstName.toLowercase() == 'unknown'
        ) {
          if (String.isNotBlank(la.phone)) {
            oppName = la.phone;
          } else if (String.isNotBlank(la.email)) {
            oppName = la.email;
          }
        }

        Id contactId;

        if (String.isNotBlank(la.email)) {
          contactId = emailContactIdMap.get(la.email);
        }

        if (String.isBlank(contactId) && String.isNotBlank(la.phone)) {
          contactId = phoneContactIdMap.get(la.phone);
        }

        //get listing info
        String market;
        Rental_Listing__c oppListing = rentalListingsMap.get(la.listingId);
        if(oppListing != null){
          market = oppListing.Property_Unit__r.property__r.Leasing_Market__c;
        }
        
        opp = new Opportunity();

        opp.name = oppName;
        opp.RecordTypeId = leasingOpportunityRecordTypeId;
        opp.AccountId = accountId;
        opp.StageName = 'New';
        opp.CloseDate = dt;
        opp.LeadSource = la.source;
        opp.ownerId = defaultOwnerId;  //assign david as default owner!
        if(String.isNotBlank(market)){
          opp.Leasing_Market__c = market;
        }
        //this field is used for leasing email communications!
        if (contactId != null) {
          opp.Primary_Leasing_Contact__c = contactId;
        }
          
        
          
          
          listingsSet.add(la.listingId);
          
          if (String.isNotBlank(la.prospectId) && la.prospectId != '0') {
                 opp.Yardi_Prospect_Id__c  = la.prospectId; 
              }
          
         
        oppsList.add(opp);
        accountIdsopportunityCreated.add(accountId);
      }
        //Update the Existing Opportunities here
        else
        if(matchingOppportunityMap.containsKey(accountId) &&
        !accountIdsopportunityCreated.contains(accountId)){
            Opp = new Opportunity ();
            Opp.Id = matchingOppportunityMap.get(accountId).Id;
            opp.LeadSource = la.source;
            //opp.ownerId = defaultOwnerId;  //assign david as default owner!
            
              
            
            listingsSet.add(la.listingId);
            
            if (String.isNotBlank(la.prospectId) && la.prospectId != '0') {
                opp.Yardi_Prospect_Id__c  = la.prospectId; 
            }
            
            updOppMap.put(opp.Id, opp);
        }
    }
      
      if(!updOppMap.isEmpty()){
          for(Id key: updOppMap.keySet()){
              oppsList.add(updOppMap.get(key));
          }
      }
    
    // Insert/Update the Opportunities here
    upsert oppsList;
    System.debug(LoggingLevel.ERROR,'**** opp created ' + oppsList.size());
     
    Map <String, Id> prospectListingToOppMap = new Map <String, Id> ();
    List <opportunity> secApplOppList = new List <opportunity>  ();
    List <Opportunity> secOppToUpdateList = new List <Opportunity> ();
    
    
    System.debug(LoggingLevel.ERROR,'NDEBUG Listings Set:::' + listingsSet);
      
    

    Map<Id, Opportunity> allOppportunitiesMap = new Map<Id, Opportunity>();
    Set<Id> oppIds = new Set<Id>();

    for (Opportunity opp : matchingOppportunityList) {
      oppIds.add(opp.Id);
      allOppportunitiesMap.put(opp.AccountId, opp);
    }
    for (Opportunity opp : oppsList) {
      oppIds.add(opp.Id);
      allOppportunitiesMap.put(opp.AccountId, opp);
    }
      if(secOppToUpdateList != null && secOppToUpdateList.size() >0){
          for (Opportunity opp : secOppToUpdateList) {
              oppIds.add(opp.Id);
              allOppportunitiesMap.put(opp.AccountId, opp);
          }
      }
    
    System.debug(LoggingLevel.ERROR,'**** opp related list ' + allOppportunitiesMap);

    //-----missing opportunities are now created at this point!
    CreateOpportunityRelatedLists(allOppportunitiesMap, allContactsEmailMap,  allContactsPhoneMap, 
                                    emailContactIdMap, phoneContactIdMap,  matchingOppportunityMap, leasingActivityList, 
                                        rentalListingsMap,defaultOwnerId, oppIds);
       
    System.debug(LoggingLevel.ERROR,'**** opp prepare respomse ' + allOppportunitiesMap);
                                 
    return PrepareOpportunityResponse(allOppportunitiesMap, leasingActivityList,allContactsEmailMap,  allContactsPhoneMap, 
                    emailContactIdMap, phoneContactIdMap);                                    
   
  } //func

private static List<LeasingActivityResponse> PrepareOpportunityResponse( Map<Id, Opportunity> allOppportunitiesMap, List<LeasingActivityWrapper> leasingActivityList,
Map<String, Id> allContactsEmailMap, Map<String, Id> allContactsPhoneMap,
                              Map<String, Id> emailContactIdMap, Map<String, Id> phoneContactIdMap){
  System.debug(LoggingLevel.ERROR,'**** PrepareResponse' + allOppportunitiesMap);

  List<LeasingActivityResponse> response = new List<LeasingActivityResponse>();

  for (LeasingActivityWrapper la : leasingActivityList) {
    Id accountId;

    if (String.isNotBlank(la.email)) {
      accountId = allContactsEmailMap.get(la.email);
    }

    if (String.isBlank(accountId) && String.isNotBlank(la.phone)) {
      accountId = allContactsPhoneMap.get(la.phone);
    }

    Opportunity opp = allOppportunitiesMap.get(accountId);
    System.debug(LoggingLevel.ERROR,'****////// PrepareResponse' + la.activityId + opp.id);
    LeasingActivityResponse lar= new LeasingActivityResponse();
    lar.activityId = la.activityId;
    lar.salesforceId = opp.id;
    // la.activityId, opp.id
    response.add(lar);

  }
  System.debug(LoggingLevel.ERROR,'**** PrepareResponse return value' + response);

  return response;
}

//create oru, oru activity, tasks
 private static void CreateOpportunityRelatedLists(
                        Map<Id, Opportunity> allOppportunitiesMap,  
                            Map<String, Id> allContactsEmailMap, Map<String, Id> allContactsPhoneMap,
                              Map<String, Id> emailContactIdMap, Map<String, Id> phoneContactIdMap,
                                Map<Id, Opportunity> matchingOppportunityMap, List<LeasingActivityWrapper> leasingActivityList,
                                  Map<string, Rental_Listing__c> rentalListingsMap, Id defaultOwnerId  ,Set<Id> oppIds){

  

        //create contact role
        CreateOpportunityContactRoles(leasingActivityList, allContactsEmailMap, allContactsPhoneMap, 
                                    emailContactIdMap, phoneContactIdMap, allOppportunitiesMap, matchingOppportunityMap);
        //create ORUs
        List<LeasingActivityWrapper>  createActivitiesList = 
              CreateOpportunityRentalUnits(leasingActivityList, allContactsEmailMap, allContactsPhoneMap, 
                allOppportunitiesMap, rentalListingsMap, oppIds);        

        //create activities and tasks
        CreateActivityRelatedTasks(createActivitiesList,defaultOwnerId, leasingActivityList,  allContactsEmailMap, allContactsPhoneMap, allOppportunitiesMap, rentalListingsMap, oppids);


  }  //function

private static void CreateActivityRelatedTasks(List<LeasingActivityWrapper>  createActivitiesList, id defaultOwnerId,  List<LeasingActivityWrapper> leasingActivityList,
                            Map<String, Id> allContactsEmailMap, Map<String, Id> allContactsPhoneMap,                         
                              Map<Id, Opportunity> allOppportunitiesMap, Map<string, Rental_Listing__c> rentalListingsMap, Set<id> oppids){
    System.debug(LoggingLevel.ERROR,'**** CreateActivityRelatedTasks' + createActivitiesList);
                              
    //fetch existing and newly created ORU's
    List<OpportunityRentalUnit__c> mergedCurrentOruList = [
      SELECT
        id,
        name,
        Current_Market_Rent__c,
        status__c,
        Leasing__r.Property_Unit__r.HomeCode__c,
        Opportunity__r.Primary_Leasing_Contact__c,
        Opportunity__r.accountid,
        Leasing__r.Rental_Listing_Id__c
      FROM OpportunityRentalUnit__c
      WHERE Opportunity__r.id IN :oppids
    ];

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
    for (LeasingActivityWrapper la : createActivitiesList) {
      Id accountId;
      if (String.isNotBlank(la.email)) {
        accountId = allContactsEmailMap.get(la.email);
      }
      if (String.isBlank(accountId) && String.isNotBlank(la.phone)) {
        accountId = allContactsPhoneMap.get(la.phone);
      }
      Boolean unitExistsInOpportunity = false;
      ID unitExistsInOpportunityId, primaryLeasingContactID, opportunityId;
       

      //find matching unit in opp
      for (OpportunityRentalUnit__c oru : mergedCurrentOruList) {
        
        if (
          accountId == oru.Opportunity__r.accountid &&
          oru.Leasing__r.Rental_Listing_Id__c == la.listingId
        ) {
          unitExistsInOpportunity = true;
          unitExistsInOpportunityId = oru.ID;
          //attach task to opportunity and primary contact!
          primaryLeasingContactID = oru.Opportunity__r.Primary_Leasing_Contact__c;
          opportunityId = oru.Opportunity__c;
          break;
        }
      }

      Opportunity_Rental_Unit_Activity__c orua = new Opportunity_Rental_Unit_Activity__c();

      if (
        unitExistsInOpportunity && activityCreateCodes.contains(la.activityType)
      ) {
        //add to updateOpportunityRentalUnitList
        //update dates
        Rental_Listing__c rentalListing;
        
        if (String.isNotBlank(la.transferredToListingId)) {
          rentalListing = rentalListingsMap.get(la.transferredToListingId);
          if (rentalListing != null) {
            orua.Transferred_To__c = rentalListing.id;
          }
        }

        orua.Opportunity_Rental_Unit__c = unitExistsInOpportunityId;
        orua.Activity_Code__c = la.activityType;
        orua.Timestamp__c = la.timeStamp;
        orua.BPM_Activity_Id__c = la.activityId;
        orua.Timezone__c = la.timezone;
        orua.feedback__c = la.feedback;
        orua.HasFeedback__c = String.isNotBlank(la.feedback);

        System.debug(LoggingLevel.ERROR,'**** ORUA activity code,oruid' + orua.Activity_Code__c + unitExistsInOpportunityId);
        //create feedback task
        
        if(String.isNotBlank(la.feedback)){
          //get the  owner for this market from custom setting
          Rental_Listing__c taskListing = rentalListingsMap.get(la.listingId);
          String market = taskListing.Property_Unit__r.property__r.Leasing_Market__c;
          String marketOwnerId  = marketManagerMap.get(market);
          if(marketOwnerId == null){
            marketOwnerId= defaultOwnerId;
          }
          System.debug(LoggingLevel.ERROR,'**** Feedback' + market + taskListing.id + '->' + opportunityId + primaryLeasingContactID);

          Task t = new Task();
      
          t.OwnerId = marketOwnerId;
          t.Subject = 'Feedback Received : ' + taskListing.property_unit__r.name;
          t.Description=  la.feedback ;
          t.Status = 'New';
          t.type='Feedback';
          t.Priority = 'High';
          // t.WhatId = unitExistsInOpportunityId;
          t.whatId = opportunityId;
          t.whoId = primaryLeasingContactID;
          createTaskList.add(t);
        }
          
        
        //check if theis batch had duplicate ids  
        if(!oruaidSet.contains(la.activityId)){
          createOpportunityRentalActivityList.add(orua);
          oruaidSet.add(la.activityId);
        }
      }
    } //for

    //updates
    System.debug(LoggingLevel.ERROR,'**** ORUA activity list' + createOpportunityRentalActivityList);

    if (createOpportunityRentalActivityList.size() > 0) {
      upsert createOpportunityRentalActivityList BPM_Activity_Id__c;
    } //if

    //create feedback task
    if (createTaskList.size() > 0) {
      insert createTaskList;
    } //if
}
  private static List<LeasingActivityWrapper> CreateOpportunityRentalUnits(List<LeasingActivityWrapper> leasingActivityList,
            Map<String, Id> allContactsEmailMap, Map<String, Id> allContactsPhoneMap,                         
              Map<Id, Opportunity> allOppportunitiesMap, Map<string, Rental_Listing__c> rentalListingsMap, Set<id> oppIds) {
    System.debug(LoggingLevel.ERROR,'**** CreateOpportunityRentalUnits' + allOppportunitiesMap);

    List<OpportunityRentalUnit__c> matchingOppRentalUnitList = [
      SELECT
        id,
        name,
        Current_Market_Rent__c,
        status__c,
        Leasing__r.Property_Unit__r.HomeCode__c,
        Opportunity__r.accountid,
        Leasing__r.Rental_Listing_Id__c
      FROM OpportunityRentalUnit__c
      WHERE Opportunity__r.id IN :oppIds
    ];

    List<OpportunityRentalUnit__c> newOpportunityRentalUnitList = new List<OpportunityRentalUnit__c>();
    List<OpportunityRentalUnit__c> updateOpportunityRentalUnitList = new List<OpportunityRentalUnit__c>();

    //below 2 structures are used to store units that are duplicated in this transaction
    Set<String> unitCreatedInThisTransactionSet = new Set<String>();
    List<LeasingActivityWrapper> createActivitiesList = new List<LeasingActivityWrapper>();

    for (LeasingActivityWrapper la : leasingActivityList) {
      Id accountId;
      if (String.isNotBlank(la.email)) {
        accountId = allContactsEmailMap.get(la.email);
      }
      if (String.isBlank(accountId) && String.isNotBlank(la.phone)) {
        accountId = allContactsPhoneMap.get(la.phone);
      }
      Boolean unitExistsInOpportunity = false;
      ID unitExistsInOpportunityId;

      //find matching unit in opp
      for (OpportunityRentalUnit__c oru : matchingOppRentalUnitList) {
        if (
          accountId == oru.Opportunity__r.accountid &&
          oru.Leasing__r.Rental_Listing_Id__c == la.listingId
        ) {
          unitExistsInOpportunity = true;
          unitExistsInOpportunityId = oru.ID;
          break;
        }
      }

      OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c();

      Opportunity oppty = allOppportunitiesMap.get(accountId);
      Rental_Listing__c rentalListing = rentalListingsMap.get(la.listingId);

      //create new ORU only once, but create activity for each record!
      if (
        !unitExistsInOpportunity &&
        !unitCreatedInThisTransactionSet.contains(
          accountId +
          '|' +
          la.listingId
        )
      ) {
        oru.Opportunity__c = oppty.Id; 
        oru.Primary_Leasing_Contact__c = oppty.Primary_Leasing_Contact__c;
        oru.ActivityId__c = la.activityId;
        oru.name = rentalListing != null
          ? rentalListing.name
          : 'Missing Listing';
        oru.Current_Market_Rent__c = rentalListing != null
          ? rentalListing.Current_Rent__c
          : 0;
        oru.Leasing__c = rentalListing != null ? rentalListing.Id : null;
        //oru.Listing_Status__c = rentalListing.Status__c;
        //update oru status to Available/Not Available - Leased/Not Available - Down/
        String oruStatus = 'New';

        // if (rentalListing != null) {
        //   if (rentalListing.status__c == 'Inactive') {
        //     oruStatus = 'Not Available - Down';
        //   } else if (rentalListing.status__c == 'Leased') {
        //     oruStatus = 'Not Available - Leased';
        //   } else if (
        //     rentalListing.status__c == 'Pre-Leasing' ||
        //     rentalListing.status__c == 'Pre-Leasing And Agent Showing'
        //   ) {
        //     oruStatus = 'Pre-Leasing';
        //   }
        // } //if null

       oru.Status__c = oruStatus;

        newOpportunityRentalUnitList.add(oru);
        unitCreatedInThisTransactionSet.add(accountId + '|' + la.listingId);
      }
      createActivitiesList.add(la);
    } //for

    //new ORU
    if (newOpportunityRentalUnitList.size() > 0) {
      insert newOpportunityRentalUnitList;
    }
    //updates
    if (updateOpportunityRentalUnitList.size() > 0) {
      update updateOpportunityRentalUnitList;
    } //if

    return createActivitiesList;
  }

  private static void CreateOpportunityContactRoles(List<LeasingActivityWrapper> leasingActivityList,
            Map<String, Id> allContactsEmailMap, Map<String, Id> allContactsPhoneMap,                         
              Map<String, Id> emailContactIdMap, Map<String, Id> phoneContactIdMap,  Map<Id, Opportunity> allOppportunitiesMap, Map<Id, Opportunity> matchingOppportunityMap
){
    List<OpportunityContactRole> newContactRoleList = new List<OpportunityContactRole>();
        //create opporutnuity contact role
        //phoneContactIdMap emailContactIdMap
        Set<Id> opportunityrolesCreatedSet = new Set<Id>();
  
        for (LeasingActivityWrapper la : leasingActivityList) {
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
} //class
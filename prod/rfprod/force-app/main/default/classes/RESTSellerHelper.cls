global class RESTSellerHelper {
    @testvisible
    static List<RecordType>  rtsList = new List<RecordType>();
    
    global class sellerRequest{
        @auraEnabled global String brokerFirstName;
        @auraEnabled global String brokerLastName;
        @auraEnabled global String listingType;
        @auraEnabled global String email;
        @auraEnabled global string brokerId; 
        @auraEnabled global Double listingPrice; 
        @auraEnabled global string propertyCity;
        @auraEnabled global string propertyState;
        @auraEnabled global string propertyStreet;
        @auraEnabled global string propertyZip;
        @auraEnabled global boolean currentlyLeased;
        @auraEnabled global string expectedTimeForTransaction; 
        @auraEnabled global string phone; 
        @auraEnabled global decimal propertyMonthlyRent;
        @auraEnabled global Integer avmHigh;
        @auraEnabled global Integer avmLow;
        @auraEnabled global Integer avmRent;
        @auraEnabled global String leadSource;
        @auraEnabled global double offerPrice;
        @auraEnabled global String retailConvertReason;
        @auraEnabled global String collectiveDeclineReason;
    }
    
    public class ConvertResponse{
        public Id AccountId;
        public Id ContactId;
        
        public ConvertResponse(Id accountId,Id contactID){
            this.AccountId = accountId;
            this.ContactId = contactID;
        }
        
        
    }
    //take lead id and return the converted account id!
    static private ConvertResponse ConvertLead(Id leadId,String ContactId,String AccountId) {
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(leadId);
        lc.setDoNotCreateOpportunity(True); //we will create opportunity later!
        System.debug('=ContactId='+ContactId);
        System.debug('=AccountId='+AccountId);
        if(ContactId!=''){
            lc.setContactId(ContactId);
        }
        if(AccountId!=''){
            lc.setAccountId(AccountId);
        }
        
        /*  LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true and MasterLabel='Appointment'  LIMIT 1 ];
System.debug('=convertStatus='+convertStatus.MasterLabel);
lc.setConvertedStatus(convertStatus.MasterLabel);*/
        //lc.setConvertedStatus('Appointment');
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        return new ConvertResponse(lcr.getAccountId(),lcr.getContactId());
        
        
    }
    
    
    static private void updateLeadWithPropertyInfo(Lead lead, string propertyCity,
                                                   string propertyState,string propertyStreet,string propertyZip,Double listingPrice ){
                                                       lead.Property_City__c    = propertyCity;
                                                       lead.Property_State__c   = propertyState;
                                                       lead.Property_State__c   = propertyState;
                                                       lead.Property_Street__c  = propertyStreet;
                                                       // lead.Property_Markets__c = propertyMarket;
                                                       lead.Property_Zip_Code__c = propertyZip; 
                                                       lead.Listing_Price__c = listingPrice;                                                                                   
                                                       update lead;
                                                   }
    static private Lead updateLeadRecordType(Lead lead){
        Id retailRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        lead.RecordTypeId = retailRecordTypeId;
        //update lead;
        return lead;
    }
    
    /*static private void UpdateLeadOwner(Lead lead){
update lead;
}
*/
    
    static private Lead updateLeadInterest(Lead lead){
        System.debug('=lead='+lead);
        lead.Lead_Interest__c = 'Selling Properties';
        //update lead;
        return lead;
    }
    @testvisible
    static private Id getLeadRecordTypeid(String leadRecordTypeName){
        
        for(recordType rt : rtsList){
            if(rt.developername==leadRecordTypeName && rt.SObjectType=='Lead'){
                return rt.id; //opprtid!
            }
        }
        return null;
    }
    
    //return opportunity record type id for the lead record type
    static private Id getRecordTypeid(String leadRecordTypeName){
        
        for(recordType rt : rtsList){
            if(rt.developername==leadRecordTypeName && rt.SObjectType=='Opportunity'){
                return rt.id; //opprtid!
            }
        }
        return null;
    }
    
    static private void getRecordTypes(){
        //cache lead and opportunity record type mapping!  pull both object type rts in one query!
        // for (RecordType objRt : [select id,name,developername,SObjectType from RecordType where SObjectType  in ('lead','opportunity')])
        //  rtsMap.put(objRt.id,objRt);
        rtsList = [select id,name,developername,SObjectType from RecordType where SObjectType  in ('lead','opportunity') and isactive=true];
        System.Debug('rts' + rtsList.size());
    }
    
    public static PostResponse AddListing(String brokerFirstName,String brokerLastName, string brokerId, Double listingPrice, String email,string listingType, string propertyCity,
                                          string propertyState,string propertyStreet,string propertyZip,boolean currentlyLeased,string expectedTimeForTransaction, string phone, decimal propertyMonthlyRent,Integer avmHigh,Integer avmLow,Integer avmRent, String leadSource,
                                          double offerPrice,String retailConvertReason,String collectiveDeclineReason){
                                              
                                             
                                              
                                              postResponse res = new postResponse();
                                              
                                              string retail_seller = 'retail_seller';
                                              string retail_buyer = 'retail_buyer';
                                              
                                              getRecordTypes();
                                              
                                              if(String.isBlank(listingType) || String.isBlank(email) ) {
                                                  
                                                  res.responseBody =  'listingType,email is required.';
                                                  res.statusCode = 400;
                                                  return res;
                                              }
                                              else if(listingType != retail_seller && listingType != retail_buyer){
                                                  res.responseBody =  'listingType should be retail_seller or retail_buyer';
                                                  res.statusCode = 400;
                                                  return res;
                                              } 
                                              //convert expectedTimeForTransaction to date field to store in targetclosedate field
                                              
                                              Date targetdatetoclose = date.today(); //default!
                                              
                                              if(expectedTimeForTransaction == '+6 months' ) {
                                                  targetdatetoclose = date.today().addMonths(6) ;                                    
                                              }
                                              else if(expectedTimeForTransaction == '<1 month' ) {
                                                  targetdatetoclose = date.today().addMonths(1) ;                                      
                                              }
                                              else if(expectedTimeForTransaction == '1-3 months')   {
                                                  targetdatetoclose = date.today().addMonths(3) ;                                      
                                              } else {
                                                  targetdatetoclose = date.today();
                                              }                                   
                                              
                                              Id accountId ;
                                              Id accOwnerId = null;
                                              Id contactId;
                                              string queueName = '';                                        
                                              queueName = 'Inbound_Supply';
                                              List<Group> lstQueueRecords = [Select Id from Group where Type = 'Queue' and developername=:queueName];                                          
                                              System.debug('==lstQueueRecords=='+lstQueueRecords);                                       
                                              try {  
                                                  List<Lead> leads = [select id,Email, RecordType.Name, Lead_Interest__c, OwnerId from lead where email= :email  and isconverted=false ];
                                                  
                                                  if(leads.size() > 0){  //matching email lead exist as lead
                                                      
                                                      Lead match_lead = leads[0];
                                                      
                                                      //Lead updatedLead;
                                                      System.debug('converting..');
                                                      if(listingType == retail_seller) {
                                                          updateLeadWithPropertyInfo(match_lead, propertyCity, propertyState, propertyStreet, propertyZip, listingPrice);  //property price and address is required to convert a seller lead! 
                                                          if(match_lead.RecordType.Name != 'Retail Seller'){
                                                              match_lead = updateLeadRecordType(match_lead);
                                                              match_lead.OwnerId =lstQueueRecords[0].Id;
                                                              System.debug('=lstQueueRecords2='+lstQueueRecords[0].Id);
                                                          }
                                                          /*   List<User> uList = [select Id,IsActive from User where Id =:match_lead.OwnerId and isActive=true];
System.debug('=uList='+uList);
if(uList.size() == 0){
String newOwnerId = defaultAccountOwner();
match_lead.OwnerId = newOwnerId;
//UpdateLeadOwner(match_lead);
}*/
                                                          if(match_lead.Lead_Interest__c!='Selling Properties'){
                                                              match_lead = updateLeadInterest(match_lead);
                                                          }
                                                      }
                                                      
                                                      if(match_lead!=null){
                                                          update match_lead;  
                                                      }
                                                      
                                                      /* Search for matching Contact */
                                                      String AccId='';
                                                      String ConId='';
                                                      List<Contact> matchingContact = [select Id,Email,AccountId from Contact where Email=:match_lead.Email and accountId != null];
                                                      if(matchingContact.size()>0){
                                                          ConId = matchingContact[0].Id;
                                                          AccId = matchingContact[0].AccountId; 
                                                      }
                                                      
                                                      ConvertResponse resp = ConvertLead(match_lead.Id,ConId,AccId);  //assume only one lead with matching email exist!
                                                      accountId = resp.AccountId;
                                                      contactId = resp.ContactId; 
                                                      System.debug('found/converted..' + accountId + contactId); 
                                                  } else {
                                                      //if there is no matching lead , look for a contact with matching email address!
                                                      List<Contact> contacts = [select account.id,account.ownerid from contact where email=:email];
                                                      System.debug('=contacts='+contacts);
                                                      //if matching contact was found
                                                      if(contacts.size() > 0) {
                                                          accountId = contacts[0].account.id;
                                                          accOwnerId = contacts[0].account.ownerid;
                                                          contactId = contacts[0].id;
                                                      }
                                                  }  
                                                  
                                                  //if there were no matching lead or contact with email address, create the lead
                                                  if(accountid == null) {
                                                      System.debug('creating lead');
                                                      Id activeUserId = null;
                                                      //string queueName = '';
                                                      
                                                      /*  04/08/2020 - 
if(brokerId != null ){ //look for broker queue!
queueName = 'Broker_Queue';
} else{ //look for inbound queue
queueName = 'Inbound_Retail_Queue';
} 
*/
                                                      /* queueName = 'Inbound_Supply';

List<Group> lstQueueRecords = [Select Id from Group where Type = 'Queue' and developername=:queueName];*/
                                                      Id ownerQueueId = lstQueueRecords[0].Id;
                                                      //System.debug('user' + ownerQueueId);
                                                      //get active users from queue 
                                                      
                                                      List<GroupMember> gms =  [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :ownerQueueId];
                                                      Set<Id> userIds = new Set<Id>();
                                                      
                                                      for(GroupMember gm : gms){
                                                          userIds.add(gm.UserOrGroupId);
                                                      }
                                                      //System.debug('user' + userIds);
                                                      //pick an active user who is queue member
                                                      List<User> activeUsers=  [select id from user where id in :userIds and isactive=true];
                                                      //System.debug('user' + activeUsers);
                                                      if(activeUsers.size() > 0)
                                                          activeUserId = activeUsers[0].id;            
                                                      
                                                      Lead new_lead = new Lead();
                                                      //new_lead.setOptions(dmlOpts);  //run assignment rule !
                                                      new_lead.firstname = brokerFirstName;
                                                      new_lead.lastname = brokerLastName;
                                                      new_lead.email = email;
                                                      
                                                      if(brokerId != null) { 
                                                          new_lead.Broker_Account_ID__c  = brokerId;
                                                          new_lead.Lead_Interest__c  = 'Inviting Clients as a Broker or Agent';  //TODO
                                                      }
                                                      else
                                                      {
                                                          new_lead.Lead_Interest__c  = 'Selling Properties'; 
                                                      }
                                                      new_lead.Company =  brokerFirstName + ' ' + brokerLastName ;
                                                      new_lead.LeadSource = 'Roofstock Registered';
                                                      new_lead.RecordTypeId = getLeadRecordTypeid(retail_seller); 
                                                      
                                                      
                                                      new_lead.Phone = phone;
                                                      new_lead.Current_Rent__c = propertyMonthlyRent; 
                                                      /* if(activeUserId != null) { 
new_lead.OwnerId = activeUserId; //assign active user from broker queue, and not run assignment rule, lead conversion will fail for queue
}*/
                                                      if(ownerQueueId!=null){
                                                          new_lead.OwnerId = ownerQueueId;
                                                      }
                                                      insert new_lead;
                                                      System.debug('=lead owner id='+new_lead.OwnerId);
                                                      
                                                      if(listingType == retail_seller) {
                                                          updateLeadWithPropertyInfo(new_lead, propertyCity, propertyState, propertyStreet, propertyZip, listingPrice);  //property price and address is required to convert a seller lead! 
                                                      }
                                                      String AccId='';
                                                      String ConId='';
                                                      ConvertResponse resp = ConvertLead(new_lead.Id,ConId,AccId);
                                                      accountId= resp.AccountId;
                                                      contactId = resp.ContactId;  
                                                      System.debug('create/converted lead' + accountId + contactId);  
                                                  }    
                                                  
                                                  
                                                  //at this point if we do not have an account id, return failure!
                                                  if(accountid == null){
                                                      res.responseBody =  'error: no matching contact with the email address was found!';
                                                      res.statusCode = 500;
                                                  } else {
                                                      System.debug('=Account ID='+accountid);
                                                      System.debug('=accOwnerId='+accOwnerId);
                                                      //get the current accountowner for new account created!
                                                      if(accOwnerId == null) { //only if it was converted here!
                                                          List<Account> acc = [select ownerid,owner.isActive from account where id = :accountid and owner.isActive=true  LIMIT 1];
                                                          System.debug('=acc='+acc);	
                                                          if(acc.size()>0){  
                                                              System.debug('=IF=');
                                                              accOwnerId = acc[0].ownerid;
                                                          }
                                                          else{
                                                              accOwnerId =  defaultAccountOwner();
                                                          }
                                                      }
                                                      else{
                                                          List<User> usr = [select Id,isActive from User where Id=:accOwnerId and isActive=true];
                                                          if(usr.size() == 0){
                                                              accOwnerId =  defaultAccountOwner();   
                                                          }
                                                          
                                                          
                                                      }
                                                      // we have accountid ,create an opportunity under this account!
                                                      
                                                      Opportunity opp = new Opportunity();
                                                      opp.accountId = accountid;
                                                      opp.SellerContactName__c = contactId;  
                                                      opp.name = 'Property';
                                                      
                                                      //add more fields here!
                                                      opp.recordtypeid= getRecordTypeid(listingType);
                                                      //opp.StageName='Qualified Listing';
                                                      opp.StageName='Submission Started';
                                                      opp.CloseDate = date.today();
                                                      opp.Property_City__c    = propertyCity;
                                                      opp.Property_State__c   = propertyState;
                                                      opp.Property_State__c   = propertyState;
                                                      opp.Property_Street__c  = propertyStreet;
                                                      opp.Current_Rent__c     = propertyMonthlyRent;
                                                      
                                                      //opp.listing_Market__c = propertyMarket; this is automatically set based on zip!
                                                      opp.Property_Zip_Code__c = propertyZip; 
                                                      opp.Purchase_Price__c = listingPrice;
                                                      //RC-11210
                                                      if(avmHigh!=null){
                                                          opp.AVM_High__c = avmHigh;
                                                      }
                                                      if(avmLow!=null){
                                                          opp.AVM_Low__c = avmLow;
                                                      }
                                                      if(avmRent!=null){
                                                          opp.AVM_Rent__c = avmRent;
                                                      }
                                                      
                                                      if(currentlyLeased!=null){
                                                          opp.Currently_Leased__c = currentlyLeased;
                                                      }
                                                      if(leadSource != null){
                                                          opp.LeadSource = leadSource;
                                                      }
                                                      opp.Target_Date_to_Close__c  = targetdatetoclose;  //target date to close!
                                                      System.debug('accOwnerId'+accOwnerId);
                                                      opp.ownerid = accOwnerId;
                                                      if(offerPrice!=null){
                                                      	opp.Roofstock_Offers_Price_if_available__c =offerPrice;     
                                                      }
                                                      if(!String.isEmpty(retailConvertReason)){
                                                          opp.Reason_for_retail_convert__c = retailConvertReason;
                                                      }
                                                      if(!String.isEmpty(collectiveDeclineReason)){
                                                          opp.Collective_Decline_Reason__c = collectiveDeclineReason;
                                                      }
                                                      //opp.ownerid = '005150000071eYX'; //richard
                                                      Insert opp;
                                                      //System.debug('oppid ' + opp.Id);   
                                                      //insert opportunity contact role!
                                                      if(contactId != null && opp.Id != null ){
                                                          insert new OpportunityContactRole(ContactId=contactId,OpportunityId=opp.Id,IsPrimary=true);
                                                      }
                                                      
                                                      //success!
                                                      if(res != null) {
                                                          res.responseBody = opp.Id;
                                                          res.statusCode = 200;
                                                      }
                                                      // return res ;
                                                  } //if
                                              } //try
                                              catch(Exception ex){
                                                  //System.debug('error***' +ex.getMessage());
                                                  if(res == null) { 
                                                      throw ex;
                                                  } else {
                                                      res.responseBody =  ex.getMessage();
                                                      res.statusCode = 500;
                                                      return res;
                                                  }
                                              }  
                                              
                                              return res;
                                          }
    public static String defaultAccountOwner(){
        List<Retail_Seller_Default_Owner__mdt> listEmpSettings = [SELECT MasterLabel, Email__c FROM Retail_Seller_Default_Owner__mdt];
        String accOwnerId;
        if(listEmpSettings.size()>0){
            List<User> defaultUser = [select Id,Email from User where Email =:listEmpSettings[0].Email__c];
            accOwnerId = defaultUser[0].Id; 
            return accOwnerId;
        }
        else{
            return null;
        }
    }
    
    public class PostResponse {
        public Integer statusCode;
        public String responseBody;
        
    }
    
}
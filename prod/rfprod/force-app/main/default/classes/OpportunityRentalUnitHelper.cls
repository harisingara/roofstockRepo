// june 7
public class OpportunityRentalUnitHelper {
  private static boolean runInsert = true;
  private static boolean runUpdate = true;
  //Check for Recursive
 /* public static boolean runOnceInsert() {
    if (runInsert) {
      runInsert = false;
      return true;
    } else {
      return runInsert;
    }
  }

  //Check for Recursive
  public static boolean runOnceUpdate() {
    if (runUpdate) {
      runUpdate = false;
      return true;
    } else {
      return runUpdate;
    }
  }
*/
  public static void UpdateOpportunityFields(
    List<OpportunityRentalUnit__c> newORUList,
    Set<Id> newOppIds,
    Set<Id> newAccountIds

  ) {

    Map<String,String> narketRoundRobinGroups = new Map<String ,String>();

    Map<id, Opportunity> opps = new Map<id, Opportunity>(
      [
        SELECT id, Current_Market_Rent__c, Primary_Leasing_Contact__c, accountid,leasing_market__c
        FROM opportunity
        WHERE id IN :newOppIds
      ]
    );
    Map<Id,Id> accountContactMap = new Map<Id,Id>();
    List<Contact> contacts=  [select id, accountid from contact where accountid in : newAccountIds];
    for(Contact contact : contacts){
      //add the first contact!
      if(!accountContactMap.containsKey(contact.accountid)){
        accountContactMap.put(contact.accountid, contact.id);
      }
    }

    Map<id, Opportunity> dedupedOpportunitiesMap = new Map<id, Opportunity>();
    for (OpportunityRentalUnit__c oru : newORUList) {

      //update opportunuty rent if no rent in opportunity
      if (!dedupedOpportunitiesMap.containsKey(oru.Opportunity__c)) {
        Opportunity opp = opps.get(oru.Opportunity__c);

        Boolean isOpportunityRentEmpty =  opp.Current_Market_Rent__c == 0 || opp.Current_Market_Rent__c == null;

        Boolean isOpportunityMarketEmpty =  String.isEmpty(opp.leasing_market__c) ;

        Boolean isPrimaryContactEmpty = opp.Primary_Leasing_Contact__c == null;

        if (isOpportunityRentEmpty || isOpportunityMarketEmpty || isPrimaryContactEmpty) {
              //rent
              if(isOpportunityRentEmpty) {
                opp.Current_Market_Rent__c = oru.Current_Market_Rent__c;
              }
              //market
              String market = oru.Leasing__r.Property_Unit__r.property__r.leasing_market__c;
              if(isOpportunityMarketEmpty) {
                    opp.Leasing_Market__c = market;
               }
               //primary contact (PC) may be empty for lead converted to opps 
               //,for opps created through api ,PC is updated by api
               if(isPrimaryContactEmpty){
                   string accountId   = opp.accountid;
                   string contactId   =  accountContactMap.get(accountId);
                   if(String.isNotBlank(contactId)){
                      opp.Primary_Leasing_Contact__c = contactId;
                   }
               }
               //update this opportunity
               dedupedOpportunitiesMap.put(opp.id, opp);
            } //if
      } //if
      //status
    } //for 
    
    List<Opportunity> updateOpps = dedupedOpportunitiesMap.values();
    if (updateOpps.size() > 0) {
      update updateOpps;
    }
  }

  public static void UpdateOpportunityRent(List<OpportunityRentalUnit__c> newORUList) {
    Set<Id> newOppIds = new Set<Id>();
      for(OpportunityRentalUnit__c newUnit : newORUList){
        newOppIds.add(newUnit.Opportunity__c);    
      }
      
    Map<id, Opportunity> opps = new Map<id, Opportunity>(
      [
        SELECT id, Current_Market_Rent__c
        FROM opportunity
        WHERE id IN :newOppIds
      ]
    );

    Map<id, Opportunity> dedupedOpportunitiesMap = new Map<id, Opportunity>();
    for (OpportunityRentalUnit__c oru : newORUList) {
      //update opportunuty rent if no rent in opportunity

      if (
        opps.get(oru.Opportunity__c).Current_Market_Rent__c == 0 ||
        opps.get(oru.Opportunity__c).Current_Market_Rent__c == null
      ) {
        if (!dedupedOpportunitiesMap.containsKey(oru.Opportunity__c)) {
          Opportunity opp = opps.get(oru.Opportunity__c);
          opp.Current_Market_Rent__c = oru.Current_Market_Rent__c;
          dedupedOpportunitiesMap.put(opp.id, opp);
        } //if
      } //if
      //status
    } //for 
    
    List<Opportunity> updateOpps = dedupedOpportunitiesMap.values();
    if (updateOpps.size() > 0) {
      update updateOpps;
    }
  }

  public static void UpdateOpportunityStatus(List<OpportunityRentalUnit__c> newORUList) {
    Set<Id> newOppIds = new Set<Id>();  
    for(OpportunityRentalUnit__c newUnit : newORUList){
        newOppIds.add(newUnit.Opportunity__c);    
     }  
    Map<id, Opportunity> dedupedOpportunitiesMap = new Map<id, Opportunity>();

    Map<id, Opportunity> opps = new Map<id, Opportunity>(
      [SELECT id, Yardi_Prospect_Id__c, stagename FROM opportunity WHERE id IN :newOppIds]
    );

    //no update opportunity stage!
    for (OpportunityRentalUnit__c oru : newORUList) {
      //update opportunuty rent if no rent in opportunity
      Opportunity opp;
      if (!dedupedOpportunitiesMap.containsKey(oru.Opportunity__c)) {
        opp = opps.get(oru.Opportunity__c);        
      } else {
        opp = dedupedOpportunitiesMap.get(oru.Opportunity__c);
      }
      //update stage and dependent picklist values
      opp = UpdateOpportunityStage(oru, opp);

      dedupedOpportunitiesMap.put(opp.id, opp);
      //status
    } //for
    // List<Opportunity> finalOpps = dedupedOpportunitiesMap.values();
    // for (Opportunity opp : finalOpps) {
  //        system.debug('>>>>*** dedupedOppMap>>>' + opp);
  //   }
    List<Opportunity> updateOpps = dedupedOpportunitiesMap.values();
    if (updateOpps.size() > 0) {
      update updateOpps;
    }
  }
    
    
    
  public static void UpdatePropertyAddressOnOpp(List<OpportunityRentalUnit__c> newORUList) {
    List<Opportunity> updateOpps = new List <Opportunity> (); 
    Set <Id> oppIds = new Set <Id> ();
    for(OpportunityRentalUnit__c newUnit : newORUList){
        if(!oppIds.contains(newUnit.Opportunity__c)){
            Opportunity Opp = new Opportunity(Id = newUnit.Opportunity__c, Property_Address1__c = newUnit.Name);
            updateOpps.add(Opp);  
            oppIds.add(newUnit.Opportunity__c);
        }
     }
      if (updateOpps.size() > 0) {
      update updateOpps;
    } 
  }
    
    
    
 private static Opportunity UpdateOpportunityStage(
    OpportunityRentalUnit__c oru,
    Opportunity opp
  ) {
    String oruStatus = oru.Status__c;
    String oppStageName = opp.stagename;
  //  System.debug(LoggingLevel.ERROR, '<<<<  closedate: ' + oruStatus + oru.Lease_Signed_Date__c + date.today());

      if(String.isBlank(opp.Yardi_Prospect_Id__c)){
        //Note opportunity stage is updated to Contacted in email workflow alert!
        if (oruStatus == 'Lease Signed') {
          opp.stagename = 'Closed Won = Lease Signed';
          opp.Current_Market_Rent__c = oru.Current_Market_Rent__c;
            opp.Decision_Made_Stage__c = '';
          opp.closedate = date.today();
          
        } else if (
          oruStatus == 'Approved' &&
          oppStageName <> 'Closed Won = Lease Signed' &&
          oppStageName <> 'Closed Lost'
        ) {
          opp.StageName = 'Decision Made';
          opp.Decision_Made_Stage__c = 'Approved';
        } else if (
          oruStatus == 'Denied' &&
          oppStageName <> 'Closed Won = Lease Signed' &&
          oppStageName <> 'Closed Lost'
        ) {
          opp.StageName = 'Decision Made';
          opp.Decision_Made_Stage__c = 'Denied';
        } else if (
          oruStatus == 'Cancelled' &&
          oppStageName <> 'Closed Won = Lease Signed' &&
          oppStageName <> 'Closed Lost'
        ) {
          opp.StageName = 'Decision Made';
          opp.Decision_Made_Stage__c = 'Cancelled';
    
        } else if (
          oruStatus == 'Applied' &&
          oppStageName <> 'Closed Won = Lease Signed' &&
          oppStageName <> 'Closed Lost' &&
          oppStageName <> 'Decision Made'
        ) {
          opp.StageName = 'Application Submitted';
          opp.Decision_Made_Stage__c = '';
    
        } else if (
          oruStatus == 'Application Started' &&
          oppStageName <> 'Closed Won = Lease Signed' &&
          oppStageName <> 'Closed Lost' &&
          oppStageName <> 'Decision Made' &&
          oppStageName <> 'Application Submitted'
        ) {
          opp.StageName = 'Application Started';
          opp.Decision_Made_Stage__c = '';
    
        }
        else if (
        oruStatus == 'Viewed' &&
        oppStageName <> 'Closed Won = Lease Signed' &&
        oppStageName <> 'Closed Lost' &&
        oppStageName <> 'Decision Made' &&
        oppStageName <> 'Application Started' && 
        oppStageName <> 'Application Submitted'
      ) {
        opp.StageName = 'Viewed';
        opp.Decision_Made_Stage__c = '';
      }
       else if (
        oruStatus == 'Scheduled Viewing' &&
        oppStageName <> 'Closed Won = Lease Signed' &&
        oppStageName <> 'Closed Lost' &&
        oppStageName <> 'Decision Made' &&
        oppStageName <> 'Application Started' && 
        oppStageName <> 'Application Submitted' &&
        oppStageName <> 'Viewed'
    
      ) {
        opp.StageName = 'Scheduled Viewing';
        opp.Decision_Made_Stage__c = '';
      }
  }
  
   return opp;

  }

  /*public static void UpdateOppRentalUnitStatus(List<OpportunityRentalUnit__c> newORUList)  {
      Set<Id> updateListingIds = new Set<Id>(); 
      for (OpportunityRentalUnit__c newUnit : newORUList) {
        if(newUnit.status__c == 'Lease Signed'){
            updateListingIds.add(newUnit.Leasing__c);
          }    
      }*/
    public static void UpdateOppRentalUnitStatus(Set<Id> updateListingIds )  {
    
      List<Rental_Listing__c> listings = new List<Rental_Listing__c>();

      for (id listingId : updateListingIds) {
            Rental_Listing__c listing = new Rental_Listing__c();
            listing.id = listingId;
            listing.Status__c = 'Leased';
            listings.add(listing);
        }
    
        if(listings.size() > 0 ){
            update listings;
        }
  }
  // Added as part of SF - 209 to fix SOQL issue
  @Future
  public static void updateORUDMLinFuture(Set<Id> setORUIDs){
      List<OpportunityRentalUnit__c> lstUpdateORU = new List<OpportunityRentalUnit__c>(); 
      for(ID ORUID :setORUIDs ){
          lstUpdateORU.add( new OpportunityRentalUnit__c(id = ORUID , ParentLastUpdated__c = System.now() )); 
      }
      if(!lstUpdateORU.IsEmpty()){
          update lstUpdateORU ; 
      }
  
  }
  
}
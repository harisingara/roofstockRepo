global class RESTLeasingFinancialInfoHelper {
    
    global class FinancialInformation{
       global List<LeasingFinInfoWrapper> leasingFinInfoList;
    }
  global class LeasingFinInfoWrapper {
    global string prospectId;  
      global string appFeePaid;
      global decimal holdingFeeAmount;
      global boolean holdingFeePaid;
      global decimal leaseRent;
      global decimal rentlyRent;
      global decimal securityDeposit;
      global decimal monthlyPetFee;
      global decimal upfrontPetDeposit;
      global decimal tax;
      global decimal adminFee;
      global decimal smartHomeFee;
      global decimal secondNatureFee;
      global decimal latchelFee;
      global decimal poolFee;
      global decimal utilitiesFee;
      global decimal balancePaid;
      global decimal concessionAmount;
      global string concessionTerm;
      global string listingId;
}
    
    global class LeasingFinUpdateResponse {
        global string prospectId;
        global string salesforceId;
        global string listingId;
    }
 
  global class PostResponse {
    global String responseBody;
  }
    
    static Id leasingOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
    .get('Leasing')
    .getRecordTypeId();
   
    static Id secAppleasingOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
    .get('Leasing_Secondary_Applicant')
    .getRecordTypeId();
    
    global static List<LeasingFinUpdateResponse> UpdateFinancialInfo(
    list<LeasingFinInfoWrapper> leasingFinInfoList
  ) {
    
    System.debug('NDEBUG lfinInfolist'+ leasingFinInfoList);
      Set <String> prospectIdSet = new Set <String> ();
      Set <String> listingIdSet = new Set <String> ();
      Map <String, LeasingFinInfoWrapper> prospectToFinInfoMap = new Map <String, LeasingFinInfoWrapper> ();
      Map <String, Opportunity> prospectToOppMap = new Map <String, Opportunity> ();
      
      List <LeasingFinUpdateResponse> response = new List<LeasingFinUpdateResponse>();
      
      for(LeasingFinInfoWrapper finInfo: leasingFinInfoList){
          
          if(String.isNotBlank(finInfo.listingId) && String.isNotBlank(finInfo.prospectId)){
            prospectIdSet.add(finInfo.prospectId);
          	listingIdSet.add(finInfo.listingId);
          	prospectToFinInfoMap.put(finInfo.prospectId + '_' + finInfo.listingId, finInfo);
          }
      }
      
      
      if(prospectIdSet != null && prospectIdSet.size() >0 && listingIdSet != null && listingIdSet.size() > 0){
          System.debug('NDEBUG Prospect Id Set :::'+prospectIdSet);
          List <Opportunity> leasingOppList = [Select Id, Rental_Listing__r.Rental_Listing_Id__c, Yardi_Prospect_Id__c from Opportunity 
                                               WHERE Yardi_Prospect_Id__c IN: prospectIdSet AND Rental_Listing__r.Rental_Listing_Id__c IN : listingIdSet AND
                                               (RecordType.Id = : leasingOpportunityRecordTypeId OR RecordType.Id = : secAppleasingOpportunityRecordTypeId)];
        										//AND stagename NOT IN ('Closed Won = Lease Signed', 'Closed Lost')];
        										//AND CloseDate = LAST_N_DAYS:30];
          System.debug('NDEBUG Leasing Opportunities ::::' + leasingOppList);
          if(leasingOppList != null && leasingOppList.size() > 0){
              
              List <Opportunity> updLeasingOppList = new List <Opportunity> ();
              
              
              for(Opportunity Opp: leasingOppList)    {
                  System.debug('NDEBUG Opp Info '+ Opp.Yardi_Prospect_Id__c);
                  System.debug('NDEBUG Opp Info '+ Opp.Rental_Listing__r.Rental_Listing_Id__c);
                  prospectToOppMap.put(Opp.Yardi_Prospect_Id__c + '_' + Opp.Rental_Listing__r.Rental_Listing_Id__c, Opp);
              }   
              
              Set <Id> oppIdSet = new Set <Id> ();
              
              for(LeasingFinInfoWrapper finInfo: leasingFinInfoList){
                  if(prospectToOppMap.containsKey(finInfo.prospectId + '_' + finInfo.listingId) 
                     && String.isNotBlank(finInfo.listingId)
                    && String.isNotBlank(finInfo.prospectId)){
                      String Key = finInfo.prospectId + '_' + finInfo.listingId;
                      Opportunity Opp = new Opportunity ();
                      if(!oppIdSet.contains(prospectToOppMap.get(key).Id)){
                        oppIdSet.add(prospectToOppMap.get(key).Id);
                          
                      	Opp.Id = prospectToOppMap.get(key).Id;
                        Opp.Application_Fee_Paid__c = prospectToFinInfoMap.get(key).appFeePaid;                      
                        Opp.Holding_Fee__c = prospectToFinInfoMap.get(key).holdingFeeAmount;
                        Opp.Holding_Fee_Paid__c = prospectToFinInfoMap.get(key).holdingFeePaid;
                        Opp.Lease_Rent__c = prospectToFinInfoMap.get(key).leaseRent;
                        Opp.Rently_Rent__c = prospectToFinInfoMap.get(key).rentlyRent;
                        Opp.Security_Deposit__c = prospectToFinInfoMap.get(key).securityDeposit;
                        Opp.Monthly_Pet_Fee__c = prospectToFinInfoMap.get(key).monthlyPetFee;
                        Opp.Upfront_Pet_Deposit__c = prospectToFinInfoMap.get(key).upfrontPetDeposit;
                        Opp.Tax__c = prospectToFinInfoMap.get(key).tax;
                        Opp.Admin_Fee__c = prospectToFinInfoMap.get(key).adminFee;
                        Opp.Smart_Home__c = prospectToFinInfoMap.get(key).smartHomeFee;
                        Opp.Second_Nature__c = prospectToFinInfoMap.get(key).secondNatureFee;
                        Opp.Latchel_Fee__c = prospectToFinInfoMap.get(key).latchelFee;
                        Opp.Pool_Fee__c = prospectToFinInfoMap.get(key).poolFee;
                        Opp.Utilities_Fee__c = prospectToFinInfoMap.get(key).utilitiesFee;
                        Opp.Balance_Paid__c = prospectToFinInfoMap.get(key).balancePaid;
                      	Opp.Concession_Amount__c = prospectToFinInfoMap.get(key).concessionAmount;
                      	Opp.Concession_Term__c = prospectToFinInfoMap.get(key).concessionTerm;
                        updLeasingOppList.add(Opp);
                      	LeasingFinUpdateResponse lfr = new LeasingFinUpdateResponse();
                      	lfr.prospectId = finInfo.prospectId;
                      	lfr.salesforceId = Opp.Id;
                      	lfr.listingId = finInfo.listingId;
                      	response.add(lfr);
                      }
                  }
              }
              if(updLeasingOppList != null && updLeasingOppList.size() >0){
                  System.debug(LoggingLevel.ERROR,'**** Opportunities Being Updated ' + updLeasingOppList);
                  update updLeasingOppList;
              }
          }
      }
      System.debug(LoggingLevel.ERROR,'**** PrepareResponse return value' + response);
      return response;
  }    
}
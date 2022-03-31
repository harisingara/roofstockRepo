/**********************************************
 * Copyright 2018 Cloud Pathfinder Consulting *
 * ********************************************
 * 
 * Migrated from RetailBuyerOfferMade trigger by CPC
 * 
 */

public class RetailBuyerOfferMade {
    
    //public static void checkOffer(List<Contact> updatedContacts) {
      public static void checkOffer(List<Contact> newContacts,Map<Id,Contact> oldMapContact) {
          List<Contact> updatedContacts = new List<Contact>();
          for(Contact con :newContacts){
              if((con.Made_An_Offer_Date__c != oldMapContact.get(con.Id).Made_An_Offer_Date__c) && con.Made_An_Offer_Date__c != null){
				updatedContacts.add(con);
              }
          }
        
        
		List<Opportunity> updatedOpportunities = new List<Opportunity>();
		List<Id> acctIds = new List<Id>();
    
		for(Contact con : updatedContacts)
		{
			acctIds.add(con.AccountId);
		}

		List<Opportunity> oppList = [SELECT Id, StageName, RecordType.Name, AccountId
                                     FROM Opportunity
                                     WHERE AccountId IN :acctIds];

		for(Opportunity opp : oppList)
		{
			if((opp.StageName != 'Closed Won' &&
				opp.StageName != 'Closed Lost' &&
				opp.StageName != 'In Contract') &&
                opp.RecordType.Name == 'Retail Buyer')
            {        
				opp.StageName = 'Offer Submitted';
            	opp.Offer_Submitted_Through_Hubspot__c = true;
            
            	for(Contact con : updatedContacts)
            	{
                	if(opp.AccountId == con.AccountId)
                	{
                    	DateTime madeAnOffer = con.Made_An_Offer_Date__c;
                    	opp.Offer_Submitted_Date__c = madeAnOffer.date();
           			}
            	}
				updatedOpportunities.add(opp);
			}
		}
		update updatedOpportunities;
    }
}
/////////////////////////////////////////////////////
// Copyright 2018 Cloud Pathfinder Consulting, LLC //
////////////////////////////////////////////////////
//
// RetailBuyerOfferMade.apxt
//
 /*
 / This trigger, when Made_An_Offer_Date__c is 
 / updated on Contact, updates subsequent Opportunities
 / through Account, by advancing their StageName to
 / 'Offer Submitted'
*/

/************************************************
 * Moved into RetailBuyerOfferMade class by CPC *
 ************************************************/
 
trigger RetailBuyerOfferMade on Contact (after update)
{
    /*
    List<Contact> updatedContacts = new List<Contact>();
    List<Opportunity> updatedOpportunities = new List<Opportunity>();
    
    List<Id> acctIDs = new List<Id>();

    for( Contact con : Trigger.New )
    {
        if( ( con.Made_An_Offer_Date__c != Trigger.oldMap.get(con.Id).Made_An_Offer_Date__c ) 
                && con.Made_An_Offer_Date__c != null )
            updatedContacts.add( con );
    }

    for( Contact con : updatedContacts )
    {
        acctIDs.add( con.AccountId );
    }


    List<Opportunity> oppList = [ SELECT Id, StageName, RecordType.Name, AccountId
                                    FROM Opportunity 
                                    WHERE AccountId IN :acctIDs ];


    for( Opportunity opp : oppList )
    {
        if( ( opp.StageName != 'Closed Won'    &&
                opp.StageName != 'Closed Lost' &&
                opp.StageName != 'In Contract' )
            && opp.RecordType.Name == 'Retail Buyer' )
        {
            opp.StageName = 'Offer Submitted';
            opp.Offer_Submitted_Through_Hubspot__c = true;
            
            for( Contact con : updatedContacts )
            {
                if( opp.AccountId == con.AccountId )
                {
                    DateTime madeAnOffer = con.Made_An_Offer_Date__c;
                    opp.Offer_Submitted_Date__c = madeAnOffer.date();
                }
            }
            
            updatedOpportunities.add(opp);
        }
    }
    
    update updatedOpportunities;
	*/
}
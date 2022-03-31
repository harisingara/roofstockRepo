/***********************************************
* 	Copyright 2018 Cloud Pathfinder Consulting *
* *********************************************
* 
* ContactTrigger
* 
*/

trigger ContactTrigger on Contact(before insert,after insert,before update,after update,before delete,after delete,after undelete) {
    try{
        TriggerDispatcher.run(new ContactTriggerHandler(),'Contact');
    }
    catch(Exception exe){
        
        DebugLogHandler.logAppException('ContactTrigger','ContactTriggerHandler',exe.getMessage(),
                                        
                                        exe.getStackTraceString(),'Trigger');
        
        throw exe;
        
    }    
}


/*
trigger ContactTrigger on Contact (after update)
{
List<Contact> updatedContacts = new List<Contact>();

for(Contact con : Trigger.New)
{
if((con.Made_An_Offer_Date__c != Trigger.oldMap.get(con.Id).Made_An_Offer_Date__c) 
&& con.Made_An_Offer_Date__c != null)
updatedContacts.add(con);
}
RetailBuyerOfferMade.checkOffer(updatedContacts);
//SF-88 - Update ORU
ContactHelper.updateORU(trigger.new,trigger.oldMap);
}
*/
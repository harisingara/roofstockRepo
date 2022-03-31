public class RetailEventController {
    Public static void retailEventSubscriber(List<Retail_Event__e> retailEvents) {
        List<Retail_Event__e> retailEventsSellerList = new List<Retail_Event__e>();
        List<Retail_Event__e> retailEventsBuyerList = new List<Retail_Event__e>();
        List<Retail_Event__e> retailEventsMadeAnOfferList = new List<Retail_Event__e>();
        List<Retail_Event__e> retailEventsDocusignList = new List<Retail_Event__e>();
        
        Set<String> docusignEventsSet = new Set<String>{'SELLER_SIGNED_LISTING_ADDENDUM','AGENT_SIGNED_LISTING_ADDENDUM',
                                                         'SELLER_SIGNED_PSA','BUYER_SIGNED_PSA','AGENT_SIGNED_PSA',
            											 'BUYER_RECEIVED_PSA','SELLER_RECEIVED_DISCLOSURES','SELLER_SIGNED_DISCLOSURES'};
                                                             
        Set<String> sellerEventsSet = new Set<String>{'SELLER_PROPERTY_NOT_IN_MARKET','SELLER_PROPERTY_ACTIVE',
                                                      'SELLER_CLOSED_LOST','SELLER_PROPOSAL_DELIVERED',
                                                      'SELLER_PENDING_CERTIFICATION','SELLER_SIGNED_LISTING',
                                                      'SELLER_ESCALATED','SELLER_LISTING_PUBLISHED',
                                                      'SELLER_IN_CONTRACT','SELLER_CLOSED_WON'};  
                                                          
        Set<String> buyerEventsSet = new Set<String>{'BUYER_MADE_AN_OFFER','BUY_BUTTON_CLICKED',
                                                         'CONTACT_UPDATED'};
        for(Retail_Event__e event :retailEvents) {

            if(docusignEventsSet.contains(event.Event_Name__c)){
                retailEventsDocusignList.add(event);
            }
            
            else if(sellerEventsSet.contains(event.Event_Name__c)){
            	retailEventsSellerList.add(event);	 
            }
            
            else if(buyerEventsSet.contains(event.Event_Name__c)){
            	retailEventsBuyerList.add(event);    
            }
            
        }
        if(retailEventsSellerList.size()>0){
        	RetailEventSellerHelper.updateSellerEventsDetails(retailEventsSellerList);
        }
        if(retailEventsBuyerList.size()>0){
        	RetailEventBuyerHelper.updateBuyerEventsDetails(retailEventsBuyerList);	 
            RetailEventBuyerHelper.updateMadeAnOfferEvents(retailEventsBuyerList);
        }

        if(!retailEventsDocusignList.isEmpty()){
            RetailEventDocusignHelper.docusignEvents(retailEventsDocusignList);
        }
        
    }
}
public class RetailEventSellerHelper {
    /*1.Logic to Handle Seller Events
     * 
     */
    Public static void updateSellerEventsDetails(List<Retail_Event__e> sellerRetailEvents) {
        Set<String> currentOpportunitySet = new Set<String>();
        Set<String> listingIdSet = new Set<String>();
        Set<String> transactionId = new Set<String>();
        Set<String> certificationId = new Set<String>();
        Map<String,Opportunity> opportunityStageMap = new Map<String,Opportunity>();
        Map<String,String> listingIdMap = new Map<String,String>();
        Map<String,String> transactionIdMap = new Map<String,String>();
        Map<String,String> certificationIdMap = new Map<String,String>();
        Map<String,Decimal> stageValuekMap = new Map<String,Decimal>();
        //Stage Map
        List<Seller_Stage_Mapping__mdt> sellerStageList = [select id,MasterLabel,Value__c from Seller_Stage_Mapping__mdt];
        for(Seller_Stage_Mapping__mdt stage :sellerStageList){
            stageValuekMap.put(stage.MasterLabel,stage.Value__c);    
        }
        for(Retail_Event__e re :sellerRetailEvents){
            currentOpportunitySet.add(re.AttributeValue1__c);
            if(!String.isBlank(re.AttributeValue3__c)){
                if((re.Attribute3__c).toLowerCase() == 'listingid'){
                      listingIdSet.add(re.AttributeValue3__c);    
                }    
            }
            if(!String.isBlank(re.AttributeValue2__c)){
                if((re.Attribute2__c).toLowerCase() == 'transactionid'){
                      transactionId.add(re.AttributeValue2__c);    
                }    
            }
            if(!String.isBlank(re.AttributeValue2__c)){
                if((re.Attribute2__c).toLowerCase() == 'certificationid'){
                      certificationId.add(re.AttributeValue2__c);    
                }    
            }
          
        }
        //Map of Property Id and Property
        List<Listing__c> listingList = [select Id,Listing_Id__c from Listing__c where Listing_Id__c IN:listingIdSet];
        for(Listing__c prop :listingList){
            listingIdMap.put(prop.Listing_Id__c,prop.Id);    
        }
        
        //Map of Transaction Id and Transaction
        List<Transaction__c> transactionList = [select Id,Transaction_Id__c from Transaction__c where Transaction_Id__c IN:transactionId];
        for(Transaction__c trans :transactionList){
            transactionIdMap.put(trans.Transaction_Id__c,trans.Id);           
        }
        
        //Map of Certification Id and Certification
        List<Certification__c> certificationList = [select Id,BPM_Certification_Id__c from Certification__c where BPM_Certification_Id__c IN:certificationId];
        for(Certification__c cert :certificationList){
            certificationIdMap.put(cert.BPM_Certification_Id__c,cert.Id);           
        }
        
        //Map of Opportunity Id and Opportunity
        List<Opportunity> matchingOpportunityList = [select Id,stageName from Opportunity where Id IN:currentOpportunitySet];
        for(Opportunity op:matchingOpportunityList){
            opportunityStageMap.put(op.Id,op);      
        }
        List<Opportunity> OpportunityUpdateList = new List<Opportunity>();
        Set<Opportunity> opportunitySet = new Set<Opportunity>();
        for(Retail_Event__e re :sellerRetailEvents){
            if(re.Event_Name__c == 'SELLER_PROPERTY_NOT_IN_MARKET'){
                Opportunity currentOpp = opportunityStageMap.get(re.AttributeValue1__c);
                if(currentOpp.stageName == 'Submission Started'){
                    if(stageValuekMap.get('Closed Lost') > stageValuekMap.get(opportunityStageMap.get(currentOpp.Id).stageName)){
                        currentOpp.stageName = 'Closed Lost';    
                    }
                    currentOpp.What_was_lost__c = 'Property Listing';
                    currentOpp.Loss_Reason1__c = 'Not a RS Market';                    
                    OpportunityUpdateList.add(currentOpp);
                }
            }
            else if(re.Event_Name__c == 'SELLER_PROPERTY_ACTIVE'){
                Opportunity currentOpp = opportunityStageMap.get(re.AttributeValue1__c);
                if(stageValuekMap.get('Pending Review') > stageValuekMap.get(opportunityStageMap.get(currentOpp.Id).stageName)){
                    currentOpp.stageName = 'Pending Review';    
                 }
                currentOpp.Property_Submitted_for_Review_Date__c = Date.valueOf(re.AttributeValue2__c);
                OpportunityUpdateList.add(currentOpp);
            }
            else if(re.Event_Name__c == 'SELLER_CLOSED_LOST'){
                Opportunity currentOpp = opportunityStageMap.get(re.AttributeValue1__c);
                if(stageValuekMap.get('Closed Lost') > stageValuekMap.get(opportunityStageMap.get(currentOpp.Id).stageName)){
                    currentOpp.stageName = 'Closed Lost';    
                 }               
                currentOpp.What_was_lost__c = 'Property Listing';
                currentOpp.Loss_Reason1__c = re.AttributeValue2__c;
                OpportunityUpdateList.add(currentOpp);
            }
            else if(re.Event_Name__c == 'SELLER_PROPOSAL_DELIVERED'){
                Opportunity currentOpp = opportunityStageMap.get(re.AttributeValue1__c);
                if(stageValuekMap.get('Proposal Delivered') > stageValuekMap.get(opportunityStageMap.get(currentOpp.Id).stageName)){
                    currentOpp.stageName = 'Proposal Delivered';    
                 }               
                currentOpp.Proposal_Delivered_Date__c = Date.valueOf(re.AttributeValue2__c);
                OpportunityUpdateList.add(currentOpp);
            }
            else if(re.Event_Name__c == 'SELLER_PENDING_CERTIFICATION'){
                Opportunity currentOpp = opportunityStageMap.get(re.AttributeValue1__c);
                if(stageValuekMap.get('Certification') > stageValuekMap.get(opportunityStageMap.get(currentOpp.Id).stageName)){
                    currentOpp.stageName = 'Certification';    
                 }                
                currentOpp.Certifications__c = certificationIdMap.get(re.AttributeValue2__c);
                OpportunityUpdateList.add(currentOpp);
            }
            else if(re.Event_Name__c == 'SELLER_SIGNED_LISTING'){
                Opportunity currentOpp = opportunityStageMap.get(re.AttributeValue1__c);
                currentOpp.Signed_Listing_Date__c = DATE.valueOf(re.AttributeValue2__c);
                OpportunityUpdateList.add(currentOpp);
            }
            else if(re.Event_Name__c == 'SELLER_ESCALATED'){
                Opportunity currentOpp = opportunityStageMap.get(re.AttributeValue1__c);
                if(stageValuekMap.get('Escalated') > stageValuekMap.get(opportunityStageMap.get(currentOpp.Id).stageName)){
                    currentOpp.stageName = 'Escalated';   
                 }                
                currentOpp.Escalated_Date__c = DATE.valueOf(re.AttributeValue2__c);
                OpportunityUpdateList.add(currentOpp);
            }
            else if(re.Event_Name__c == 'SELLER_LISTING_PUBLISHED'){
                Opportunity currentOpp = opportunityStageMap.get(re.AttributeValue1__c);
                if(stageValuekMap.get('Published') > stageValuekMap.get(opportunityStageMap.get(currentOpp.Id).stageName)){
                    currentOpp.stageName = 'Published';   
                 }                
                currentOpp.Published_Date__c = DATE.valueOf(re.AttributeValue2__c);
                currentOpp.Listing__c = listingIdMap.get(re.AttributeValue3__c);
                OpportunityUpdateList.add(currentOpp);
            }
            else if(re.Event_Name__c == 'SELLER_IN_CONTRACT'){
                Opportunity currentOpp = opportunityStageMap.get(re.AttributeValue1__c);
                if(stageValuekMap.get('In Contract') > stageValuekMap.get(opportunityStageMap.get(currentOpp.Id).stageName)){
                    currentOpp.stageName = 'In Contract';  
                 }                
                currentOpp.Transaction__c = transactionIdMap.get(re.AttributeValue2__c);
                OpportunityUpdateList.add(currentOpp);
            }
            else if(re.Event_Name__c == 'SELLER_CLOSED_WON'){
                Opportunity currentOpp = opportunityStageMap.get(re.AttributeValue1__c);
                if(stageValuekMap.get('Closed Won') > stageValuekMap.get(opportunityStageMap.get(currentOpp.Id).stageName)){
                    currentOpp.stageName = 'Closed Won';  
                 }                
                currentOpp.CloseDate = DATE.valueOf(re.AttributeValue2__c);
                OpportunityUpdateList.add(currentOpp);
            }
        }
        
        if(!OpportunityUpdateList.isEmpty()){
            opportunitySet.addAll(OpportunityUpdateList);
            OpportunityUpdateList.clear();
            OpportunityUpdateList.addAll(opportunitySet);
            update OpportunityUpdateList;       
        }
    }
}
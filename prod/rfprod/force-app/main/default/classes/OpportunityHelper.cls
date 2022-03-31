//may 06 11.28
public with sharing class OpportunityHelper{
    static ID retailSellerOpptyRecTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
    @future(callout=true)
    public static void UpdateListingMarketAndYieldFuture(Set<Id> newOppIds) {
        UpdateListingMarketAndYield(newOppIds);
    }
    
    //Method to update Campaign value on Oppty for 'Retail Seller'
    public static void updateCampaignOnOpportunity(List<Opportunity> opList){
		String retailSellerRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        Set<Id> setAccIds = new Set<Id>(); // store Account Ids for which Campaign Id to be queried.  
        List<Opportunity> lstOppsUpdate = new List<Opportunity>(); // store opp Ids for which Campaign needs to be updated 
        for(Opportunity oNewOpp:opList){
            if(oNewOpp.RecordTypeId == retailSellerRecType && oNewOpp.CampaignId == null){
            	lstOppsUpdate.add(oNewOpp); 
                setAccIds.add(oNewOpp.AccountId); 
            }
        }
        if(!setAccIds.IsEmpty()){
        	List<Account> lstAccs = [Select Id ,(select Id,name,CampaignId from opportunities where CampaignId != null 
                                      ORDER BY CreatedDate DESC LIMIT 1 ) from Account where ID IN:setAccIds];  
            if(lstAccs <> NULL && !lstAccs.IsEmpty()){
            	map<Id,Id> mapAccCampaignId = new map<Id,Id>(); 
                for(Account oAcc:lstAccs){
                    if(oAcc.opportunities <> null && !oAcc.opportunities.IsEmpty()){
                    	mapAccCampaignId.put(oAcc.Id,oAcc.opportunities[0].CampaignId); 	    
                    }    
                }
                if(!mapAccCampaignId.IsEmpty()){
                    for(Opportunity oUpdateOpp:lstOppsUpdate){
                        if(mapAccCampaignId.containsKey(oUpdateOpp.AccountId)){
                        	 oUpdateOpp.CampaignId = mapAccCampaignId.get(oUpdateOpp.AccountId);    
                        }    
                    }
                }
            }    
        }
        
    }
    /*
    public static void UpdateLeasingOpportunityOwnerByMarket(Map<Id,Opportunity> oldOppsMap, List<Opportunity> newOppsList){
        String leasingRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
        
        List<Leasing_Markets__c> lms = Leasing_Markets__c.getall().values();
        Map<string, String> lmsMap = new Map<string, String>();
        Set<String> lmsSet = new Set<String>();
        
        Set<String> newAccountIds = new Set<String>();
        
        for(Opportunity opp : newOppsList){
            System.debug('opp::'+opp);
            system.debug('opp.RecordTypeId::'+opp.RecordTypeId);
            system.debug('leasingRecordType::'+leasingRecordType);
            if(opp.RecordTypeId == leasingRecordType) {
                system.debug('inside loop for newaccountId');
                newAccountIds.add(opp.accountid);
            }
           
        }
        newAccountIds.remove(null);
        System.debug('newAccountIds::'+newAccountIds);
        //get the market -PM from custom settings~
        for (Leasing_Markets__c lm : lms) {
            lmsMap.put(lm.name, lm.Agent_Email__c);
            lmsSet.add(lm.Agent_Email__c);
        }
        Map<String, id> marketAgentMap = new Map<String, id>();
        
        //get user id from user ,custom setting store email address of manager
        List<User> users = [select id,email from user where email in :lmsSet and isactive=true ];
        Map<String,id> userEmailMap = new  Map<String,id>();
        for (User user : users){
            userEmailMap.put(user.email, user.id);
        }
        
        List<Opportunity> ownerOpps = new List<Opportunity>();
        
        for (string market : lmsMap.keySet()) {
            string email = lmsMap.get(market);
            string id = userEmailMap.get(email);
            marketAgentMap.put(market, id);
        }
        
        Map<Id,Id> accountContactMap = new Map<Id,Id>();
        List<Contact> contacts=  [select id, accountid from contact where accountid in :newAccountIds];
        system.debug('List of Contact::'+contacts.size()+'::'+contacts);
        for(Contact contact : contacts){
            //add the first contact!
            if(!accountContactMap.containsKey(contact.accountid)){
                accountContactMap.put(contact.accountid, contact.id);
            }
        }
        List<String> postApplicationStages = new List<String>{'Application Started','Application Submitted','Decision Made'};
            List<String> closedApplicationStages = new List<String>{'Closed Won = Lease Signed','Closed Lost'};
                
                for(Opportunity opp : newOppsList) {
                    
                    //dont update if opp is being closed to won or lost
                    if(opp.RecordTypeId == leasingRecordType && !closedApplicationStages.contains(opp.StageName)  ) {
                        Boolean oldOppIsPreApplication = false;
                        
                        // Access the "old" record by its ID in Trigger.oldMap
                        if(oldOppsMap != null) {
                            Opportunity oldOpp = oldOppsMap.get(opp.Id);
                            // System.debug(LoggingLevel.ERROR, '**** rrnNames88->> old stagename' + oldOpp.StageName );
                            //old stage is pre applicaiton started 
                            oldOppIsPreApplication = !postApplicationStages.contains(oldOpp.StageName) && !closedApplicationStages.contains(oldOpp.StageName)  ;
                        } //if
                        // Trigger.new records are conveniently the "new" versions!
                        Boolean newOppIsAppStarted = postApplicationStages.contains(opp.StageName);
                        // System.debug(LoggingLevel.ERROR, '**** rrnNames89new stage name->>' + oldOppIsPreApplication +newOppIsAppStarted+opp.StageName );
                        
                        //update primary contact if empty
                        Boolean isPrimaryContactEmpty = opp.Primary_Leasing_Contact__c == null;
                        Boolean isApplicationStarted  = oldOppIsPreApplication && newOppIsAppStarted;
                        
                        if(isPrimaryContactEmpty || isApplicationStarted) {
                            if(isPrimaryContactEmpty){
                                string accountId   = opp.accountid;
                                string contactId   =  accountContactMap.get(accountId);
                                if(String.isNotBlank(contactId)){
                                    opp.Primary_Leasing_Contact__c = contactId;
                                }
                            }
                            
                            //oldstagename is empty when it is insert   
                            //current owner does not match 
                            // System.debug(LoggingLevel.ERROR, '**** rrnNames90->>' + isApplicationStarted +opp.Leasing_Market__c+marketAgentMap.size() );
                            
                            if(isApplicationStarted && String.isNotBlank(opp.Leasing_Market__c) && marketAgentMap.size() > 0) {
                                string ownerId = marketAgentMap.get(opp.Leasing_Market__c);
                                // System.debug(LoggingLevel.ERROR, '****91 resssigning owner!!!! ->>'+  isApplicationStarted + ownerId );
                                if(String.isNotBlank(ownerId) && opp.ownerid != ownerId){
                                    opp.ownerid = ownerId;
                                }
                            } //if
                            
                        }//if
                    } //if
                }//for
        // if(ownerOpps.size() > 0)
        // {
        //   update ownerOpps;
        // }
    }
    */
    
    public static void UpdateListingMarketAndYield(Set<Id> newOppIds) {
        List<Opportunity> newOpps = [
            SELECT
            id,
            Listing_Market__c,
            Property_Zip_Code__c,
            RecordTypeId,
            Yield_Value__c,
            Market_Rent__c,
            Current_Rent__c
            FROM Opportunity
            WHERE id IN :newOppIds
        ];
        //lookup markets based on postal code of listing address!!
        //populate yield value based on value from lookup table
        
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
        
        Set<String> markets = new Set<String>();
        Set<String> zipcodes = new Set<String>();
        
        for (Opportunity opp : newOpps) {
            if (opp.Property_Zip_Code__c != null) {
                zipcodes.add(opp.Property_Zip_Code__c);
            }
        }
        System.debug('starting..');
        if (zipcodes.size() > 0) {
            //if there were zipcodes in the lead loaded
            
            System.debug('starting zipcode..');
            Map<String, String> zipmarkets = SalesfunnelHelper.getMarketsbyZip(
                zipCodes
            );
            
            System.debug('starting zipcode2..' + zipmarkets.size());
            //assign listing market to alll new leads!
            if (zipmarkets != null && zipmarkets.size() > 0) {
                //only do anything if there is any mapping stored@
                System.debug('starting zipcode2..');
                for (Opportunity opp : newOpps) {
                    if (opp.Property_Zip_Code__c != null) {
                        String mzip = opp.Property_Zip_Code__c;
                        String mtype = rtMap.get(opp.RecordTypeId).getName();
                        if (mtype == 'Retail Seller') {
                            System.debug('starting zipcode3..');
                            String marketzipInfo = zipmarkets.get(mzip);
                            if (marketzipInfo != null) {
                                System.debug('starting zipcode4..');
                                opp.Listing_Market__c = marketzipInfo;
                            }
                        } //rt check
                    } //if zip code
                } //for loop
            } //if
        } //zip code length
        
        for (Opportunity opp : newOpps) {
            if (opp.Listing_Market__c != null) {
                markets.add(opp.Listing_Market__c);
            }
        }
        if (markets.size() > 0) {
            System.debug('starting markets..');
            // System.Debug(lead.Listing_Markets__c)  ;
            
            // Query the yield table for their associated market yield valiue!
            Map<String, MarketYield__c> yields = new Map<String, MarketYield__c>();
            
            for (MarketYield__c myield : [
                SELECT name, Minimum_Gross_Yield__c, Market_Rent__c, Minimum_rent__c
                FROM MarketYield__c
                WHERE name IN :markets
            ]) {
                //System.debug('foo' + myield.Name +  myield.Minimum_Gross_Yield__c + myield.Market_Rent__c  );
                yields.put(myield.Name, myield);
            }
            
            for (Opportunity opp : newOpps) {
                System.debug('starting markets2..');
                if (opp.Listing_Market__c != null) {
                    System.debug('starting markets3..');
                    String market = opp.Listing_Market__c;
                    String type = rtMap.get(opp.RecordTypeId).getName();
                    //System.debug('rent' + opp.Current_Rent__c);
                    if (
                        market != 'Undecided' &&
                        (type == 'Institutional Seller' ||
                         type == 'Retail Seller')
                    ) {
                        // Current rent / minimum gross yield
                        MarketYield__c marketInfo = yields.get(market);
                        
                        if (marketInfo != null) {
                            opp.Minimum_rent__c = marketInfo.Minimum_rent__c;
                            opp.Market_Rent__c = marketInfo.Market_Rent__c; //not stored currently
                            if (opp.Current_Rent__c != null && opp.Current_Rent__c > 0) {
                                double minyield = marketInfo.Minimum_Gross_Yield__c / 100;
                                opp.Yield_Value__c = opp.Current_Rent__c / minyield;
                                opp.Minimum_Gross_Yield__c = marketInfo.Minimum_Gross_Yield__c;
                            }
                        }
                    } else {
                        opp.Yield_Value__c = 0.0;
                    }
                }
            }
            update newOpps;
        } //if
    }
    
   
    /*SF-88 - Function to update ORU*/
    Public static void updateORU(List<Opportunity> opList,Map<Id,Opportunity> OldMap){
        Set<String> opportunityIdSet = new Set<String>();
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
        
        for(Opportunity opty : opList){
            //Naveen: Modified to trigger this logic only for Non-Yardi Opportunities
            if(opty.stageName!=oldMap.get(opty.Id).stageName && (opty.RecordTypeId == oppRecordTypeId) && opty.Yardi_Prospect_Id__c == ''){
                opportunityIdSet.add(opty.Id);
            }
        }
        List<OpportunityRentalUnit__c> oruList = [select Id,ParentLastUpdated__c from OpportunityRentalUnit__c where Opportunity__c IN:opportunityIdSet];
         Set<Id> setORUIDs = new Set<Id>();
        for(OpportunityRentalUnit__c oru :oruList){
           // oru.ParentLastUpdated__c = System.now(); commented As part of SF-209 issue using future meth0d to update
            setORUIDs.add(oru.Id); 
        }
        
        if ( !setORUIDs.IsEmpty() && !( System.isFuture() || System.isBatch())){
            OpportunityRentalUnitHelper.updateORUDMLinFuture(setORUIDs);    
        }
        // update oruList;// commented As part of SF-209 issue 
    }
    
    //Closed Won,Retail Buyer callout
    public static void RetailBuyerClosedWonOptyCallout(List<Opportunity> newOpportunityList){
        
        Set<Id> newDelighted = new Set<Id>();
        
        for(Opportunity opp : newOpportunityList)
        {
            if((opp.StageName == 'Closed Won') && (opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId())) 
            {
                if(!DelightedCallout.alreadyProcessed.contains(opp.Id))
                    newDelighted.add(opp.Id);
            }
        }
        if(newDelighted.size() > 0 && !test.isRunningTest()){
            DelightedCallout.createPerson(newDelighted);
        }    
    
        // System.debug(LoggingLevel.ERROR, 'opportunituy trigger calling RR' +Trigger.isInsert + Trigger.isUpdate);   
        
        //RoundRobin.ExecuteRoundRobin(Trigger.oldMap, Trigger.new);
        
        // System.debug(LoggingLevel.ERROR,'opportunituy trigger done RR');  
        
    }
    //before insert - Update Owner Based on Property State
    public static void marketBasedOwnerAssignment(List<Opportunity> newOppList){
   		map<String,String> mapMarketBroker = new map<String,String>(); 
        List<Market_Based_Assignment__mdt> lstMarketBrokerInfo= [Select MasterLabel,Broker_User_Record_Id__c from Market_Based_Assignment__mdt ];
        for(Market_Based_Assignment__mdt oMarketBroker:lstMarketBrokerInfo){
            mapMarketBroker.put(oMarketBroker.MasterLabel,oMarketBroker.Broker_User_Record_Id__c); 
        }
        for(Opportunity o:newOppList){
            if(o.RecordTypeId ==retailSellerOpptyRecTypeId && o.Property_State__c <> null && mapMarketBroker.containskey(o.Property_State__c)){
            	o.OwnerId = mapMarketBroker.get(o.Property_State__c);     
            }  
        }
    }
    //before insert - Update Owner Based on Property State
    public static void updateAccConOwnerBasedOnOppty(List<Opportunity> newOppList){
    	Set<Id> setAccIds = new Set<Id>(); 
        map<Id,Id> mapAccIdOppOwnerID = new map<Id,Id>();
        List<Market_Based_Assignment__mdt> lstMarketBrokerInfo= [Select MasterLabel,Broker_User_Record_Id__c from Market_Based_Assignment__mdt ];
        map<String,String> mapMarketBroker = new map<String,String>(); 
        for(Market_Based_Assignment__mdt oMarketBroker:lstMarketBrokerInfo){
            mapMarketBroker.put(oMarketBroker.MasterLabel,oMarketBroker.Broker_User_Record_Id__c); 
        }
        for(Opportunity o:newOppList){
            if(o.RecordTypeId ==retailSellerOpptyRecTypeId && o.Property_State__c <> null && mapMarketBroker.containskey(o.Property_State__c)){
            	setAccIds.add(o.AccountId);
                mapAccIdOppOwnerID.put(o.AccountId, o.OwnerId );
            }  
        }
        if(!setAccIds.IsEmpty()){
        	List<Account> lstAccount = [ Select ID , OwnerID , (Select ID,OwnerID from Contacts) from Account where ID IN:setAccIds]; 	    
            if(lstAccount<>null && lstAccount.size()>0){
                List<Account> lstUpdateAccount = new List<Account>(); 
                List<Contact> lstUpdateContact = new List<Contact>();
                for(Account oAcc:lstAccount){
                    if(oAcc.OwnerID != mapAccIdOppOwnerID.get(oAcc.Id)){
                    	lstUpdateAccount.add(new Account( ID = oAcc.Id, OwnerID = mapAccIdOppOwnerID.get(oAcc.Id) ));     
                    }
                    if(oAcc.Contacts <> null && oAcc.Contacts.size() > 0){
                        for(Contact oCon:oAcc.Contacts){
                        	if(oAcc.OwnerID != mapAccIdOppOwnerID.get(oAcc.Id)){
                                lstUpdateContact.add(new Contact( ID = oCon.Id, OwnerID = mapAccIdOppOwnerID.get(oAcc.Id) ));     
                            }    
                        }
                    }
                }
                if(!lstUpdateAccount.IsEmpty()){
                	update lstUpdateAccount;     
                }
                if(!lstUpdateContact.IsEmpty()){
                	update lstUpdateContact;     
                }
                
            }
        }
    }
    //before insert - Process Builder - Opportunity- Init and Stages
    public static void updateOpportunityNameAndRoofstockRevenueOnInsert(List<Opportunity> newOppList){
        String retailBuyerRecTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        String retailSellerRecTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        String propertyRecTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Property').getRecordTypeId();
        
        List<String> accIds = new List<String>();
        
        for(Opportunity o:newOppList){
            if(((o.RecordTypeId ==retailBuyerRecTypeId) || (o.RecordTypeId ==propertyRecTypeId)) && (o.Name == null)){
                accIds.add(o.accountId); 
            }  
        }
        Map<String,String> accIdNameMap = new Map<String,String>();
        Map<String,Decimal> accIdcompletedTransMap = new Map<String,Decimal>();
        List<Account> accountList = [select Id,Name,Completed_Property_Transactions__c from Account where Id IN:accIds];
        
        if(accountList.size()>0){
            for(Account acc :accountList){
                accIdNameMap.put(acc.Id,acc.Name); 
                accIdcompletedTransMap.put(acc.Id,acc.Completed_Property_Transactions__c);
            }
        }
        for(Opportunity opp :newOppList){
            if(((opp.RecordTypeId ==retailBuyerRecTypeId) || (opp.RecordTypeId ==propertyRecTypeId)) && (opp.Name == null)){
                opp.Name = 'Purchase '+(accIdcompletedTransMap.get(opp.accountId)+1)+' '+'-'+' '+accIdNameMap.get(opp.accountId);
            }
            if((opp.RecordTypeId == retailSellerRecTypeId)){
                opp.Name = opp.Property_Address__c;
            }
            //PE-494
            if(!String.isEmpty(opp.Reason_for_retail_convert__c) && (!opp.Name.contains(Label.Previous_RS_Offer))){
            	opp.Name = Label.Previous_RS_Offer+' '+opp.Name;    
            }
            if(opp.RecordTypeId == retailBuyerRecTypeId){
                opp.Roofstock_Investment_Revenue__c = (opp.Purchase_Price__c * opp.Roofstock_Fee__c);
            }
        }
    }
    
    //before update - Process Builder - Opportunity- Init and Stages
    public static void updateRetailBuyerOpportunityStages(List<Opportunity> oppList,Map<Id,Opportunity> OldMap){
        String retailBuyerRecTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        List<Opportunity> OpportunitiesToUpdate = new List<Opportunity>();
        for(Opportunity op:oppList){
            if((oldMap.get(op.Id).Buy_Box_Complete_Date__c == null) && (op.Buy_Box_Complete_Date__c!=null) && (op.RecordTypeId == retailBuyerRecTypeId)){
                op.StageName = 'Buy Box Complete';
                OpportunitiesToUpdate.add(op);
            }
            else if((oldMap.get(op.Id).Pre_Approved_Complete_Date__c == null) && (op.Pre_Approved_Complete_Date__c!=null) && (op.RecordTypeId == retailBuyerRecTypeId)){
                op.StageName = 'Pre-approved';
                OpportunitiesToUpdate.add(op);
            }
            //did not include ischanged
            else if((oldMap.get(op.Id).Offer_Submitted_Date__c == null) && (op.Offer_Submitted_Date__c!=null) && (op.RecordTypeId == retailBuyerRecTypeId)){
                op.StageName = 'Offer Submitted';
                OpportunitiesToUpdate.add(op);
            }
            else if((oldMap.get(op.Id).Published_Date__c == null) && (op.Published_Date__c!=null) && (op.RecordTypeId == retailBuyerRecTypeId)){
                op.StageName = 'Published';
                OpportunitiesToUpdate.add(op);
            }
            else if((oldMap.get(op.Id).In_Contract_Date__c == null) && (op.In_Contract_Date__c!=null) && (op.RecordTypeId == retailBuyerRecTypeId)){
                op.StageName = 'In Contract';
                OpportunitiesToUpdate.add(op);
            }
            else if((oldMap.get(op.Id).Proposal_Delivered_Date__c == null) && (op.Proposal_Delivered_Date__c!=null) && (op.RecordTypeId == retailBuyerRecTypeId)){
                op.StageName = 'Proposal Delivered';
                OpportunitiesToUpdate.add(op);
            }
            else if((op.RecordTypeId == retailBuyerRecTypeId) && (op.Purchase_Price__c!=null) && (op.Roofstock_Fee__c!=null) ){
                
                    op.Roofstock_Investment_Revenue__c = op.Purchase_Price__c * op.Roofstock_Fee__c;
                    OpportunitiesToUpdate.add(op);
                
            }
        }
        if(OpportunitiesToUpdate.size()>0){
            //update OpportunitiesToUpdate;
        }
        
    }
    //Process Builder - Opportunity - Field Update on Associated Opportunities of Same Account
    public static void updateRetailSellerOpportunities(List<Opportunity> oppList,Map<Id,Opportunity> OldMap){
        
        String retailSellerRecTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        Set<String> opStages = new Set<String>{'Qualified Listing','Appointment','Proposal Delivered','Signed Listing'};
            //Set<String> NextStepAccIds = new Set<String>();
            //Set<String> AppointmentAccIds = new Set<String>();
            Map<String,Date> accIdNextStepDateMap = new Map<String,Date>();
        Map<String,Date> accIdAppointmentDateMap = new Map<String,Date>();
        
        
        for(Opportunity opty :oppList){
            if((opty.Next_Step_Date__c!=oldMap.get(opty.Id).Next_Step_Date__c) && (opty.Next_Step_Date__c!=null) && (opty.RecordTypeId == retailSellerRecTypeId) && (opStages.contains(opty.StageName))){
                //NextStepAccIds.add(opty.AccountId);
                accIdNextStepDateMap.put(opty.accountId,opty.Next_Step_Date__c);                
            }
            if((opty.Appointment_Date__c!=oldMap.get(opty.Id).Appointment_Date__c) && (opty.Appointment_Date__c!=null) && (opty.RecordTypeId == retailSellerRecTypeId) && (opStages.contains(opty.StageName))){
                //AppointmentAccIds.add(opty.AccountId);
                accIdAppointmentDateMap.put(opty.accountId,opty.Appointment_Date__c);
            }
        }
        if(!System.isBatch() && !System.isFuture()){
            retailSellerOpportunities(accIdNextStepDateMap,accIdAppointmentDateMap);
        }
    }
    
    @future
    public static void retailSellerOpportunities(Map<String,Date> accIdNextStepDateMap, Map<String,Date> accIdAppointmentDateMap){
        
        List<Opportunity> nextStepOpportunitiesToUpdate = new List<Opportunity>();
        List<Opportunity> appointmentOpportunitiesToUpdate = new List<Opportunity>();
        List<Opportunity> nextStepOpList = [select Id,AccountId,Next_Step_Date__c from Opportunity where StageName='Qualified Listing' AND accountId IN:accIdNextStepDateMap.keySet()];
        List<Opportunity> appointmentOpList = [select Id,AccountId,Appointment_Date__c from Opportunity where StageName='Qualified Listing' AND accountId IN:accIdAppointmentDateMap.keySet()];
            if(nextStepOpList.size()>0){
                for(Opportunity op :nextStepOpList){
                   op.Next_Step_Date__c = accIdNextStepDateMap.get(op.AccountId); 
                   nextStepOpportunitiesToUpdate.add(op);
                }
                if(nextStepOpportunitiesToUpdate.size()>0){
                    update nextStepOpportunitiesToUpdate;
                }
            }
        if(appointmentOpList.size()>0){
            for(Opportunity op :appointmentOpList){
                op.Appointment_Date__c = accIdAppointmentDateMap.get(op.AccountId);
                appointmentOpportunitiesToUpdate.add(op);
            }
            if(appointmentOpportunitiesToUpdate.size()>0){
                update appointmentOpportunitiesToUpdate;
            }
        }
    }
    
    //Process Builder - Opportunity -Close open tasks on closing
    public static void closeOpenTaskOnOpportunity(List<Opportunity> opList){
        Id oppLeasingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
        Set<String> opsListToCloseTask = new Set<String>();
        for(Opportunity op:opList){
            if((op.RecordTypeId == oppLeasingRecordTypeId) && ((op.StageName == 'Closed Won = Lease Signed') || (op.StageName == 'Closed Lost'))){
                opsListToCloseTask.add(op.Id);
            }
        }
        List<Task> closeTaskList = [select Id from Task where whatId IN:opsListToCloseTask and status = 'Open'];
        if(closeTaskList.size()>0){
            for(Task t:closeTaskList){
                t.status = 'Completed';
            }
            update closeTaskList;
        }
    }
    //Process Builder - Opportunity Closed Won
    public static void updateOpportunityTeamMember(List<Opportunity> opList){
        Set<String> opIds = new Set<String>();
        for(Opportunity op:opList){
            if(op.StageName == 'Closed Won'){
                opIds.add(op.Id); 
            }
        }
        List<OpportunityTeamMember> otmList = [SELECT Name,CSR_Closed_Won__c,TeamMemberRole, User.Email FROM OpportunityTeamMember WHERE OpportunityId IN:opIds AND TeamMemberRole = 'CSR'];
        if(otmList.size()>0){
            for(OpportunityTeamMember otm : otmList){
                otm.CSR_Closed_Won__c = true;
            }
            update otmList;
        }
    }
    //Process Builder - Leasing - Opportunity Field Updates
    public static void leasingOpportunityUpdate(List<Opportunity> opList,Map<Id,Opportunity> oldMap){
        Id oppLeasingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
        
        
        for(Opportunity opp :opList ){
            if((opp.RecordTypeId == oppLeasingRecordTypeId) && (opp.StageName == 'Decision Made') && (opp.Decision_Made_Stage__c!=oldMap.get(opp.Id).Decision_Made_Stage__c) && (opp.Decision_Made_Stage__c!=null)){
                opp.Decision_Date__c = System.today();
            }
            
            if(opp.RecordTypeId == oppLeasingRecordTypeId && opp.Ready_for_Approval__c && (opp.Ready_for_Approval__c != oldMap.get(opp.Id).Ready_for_Approval__c) 
               ){
                opp.Ready_For_Approval_Checked_Date1__c	 = DateTime.now();
            }
            
            
            
            //else if of it moved to another method
            
        }
        
    }
    //Part 2 - Process Builder - Leasing - Opportunity Field Updates
    public static void leasingOpportunityUpdateORU(List<Opportunity> opList){
        Id oppLeasingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
        Set<String> opIds = new Set<String>();
        List<OpportunityRentalUnit__c> updateORUList = new List<OpportunityRentalUnit__c>();
        for(Opportunity o : opList){
            if((o.RecordTypeId == oppLeasingRecordTypeId) && (o.stageName == 'Closed Lost') && (o.Reason_for_Close__c == 'Approved- No Lease Sign')){
                opIds.add(o.Id);
            }
        }
        List<OpportunityRentalUnit__c> oruList = [select Id,Status__c from OpportunityRentalUnit__c where Opportunity__c IN:opIds and Status__c = 'Approved'];
        if(oruList.size()>0){
            for(OpportunityRentalUnit__c oru :oruList){
                oru.Status__c = 'Did Not Rent';
                updateORUList.add(oru);
            }
            if(updateORUList.size()>0){
                update updateORUList;
            }
        }
    }
    //Process Builder - Opportunity Owner Mirror Field
    public static void updateOpportunityOwnerMirrorField(List<Opportunity> opList){
        List<String> ownerIds = new List<String>();
        Map<String,String> ownerIdNameMap = new Map<String,String>();
        for(Opportunity op :opList){
            if(op.OwnerId!=null){
                ownerIds.add(op.OwnerId); 
            }
        }
        List<User> userList = [select Id,Name from User where Id IN:ownerIds];
        if(userList.size()>0){
            for(User u:userList){
                ownerIdNameMap.put(u.Id,u.Name);    
            }
        }
        for(Opportunity op :opList){
            if(op.OwnerId!=null){
                op.Opportunity_Owner__c = ownerIdNameMap.get(op.OwnerId);
            }
        }
    }
    
    // Update Stage/Sub Stages based on App Decision and Application Status from Yardi for Leasing Opps -- Insert
    public static void procStgSubStgLeasingOppsIns(List<Opportunity> opList){
        //Id oppLeasingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
        for(Opportunity opp : opList){
            System.debug('NDEBUG Application Status::::' + Opp.Application_Status__c);
            if(opp.RecordTypeId == RecordTypes.leasingOpportunityRecordTypeId || opp.RecordTypeId == RecordTypes.leasingSecApplOppRecordTypeId){               
                if(getStageValue(opp.App_Decision__c, opp.Application_Status__c, opp.Tenant_Status1__c) != 'prevVal'){
                	opp.StageName = getStageValue(opp.App_Decision__c, opp.Application_Status__c, opp.Tenant_Status1__c);
                }
                if(getSubStageValue(opp.App_Decision__c, opp.Application_Status__c, opp.Tenant_Status1__c) != 'prevVal'){
                    opp.Sub_Stage__c = getSubStageValue(opp.App_Decision__c, opp.Application_Status__c, opp.Tenant_Status1__c);
                }
            }
        }
    }
    
    // Assign members from the LC Team as Owners for primary leasing Opps
    public static void assignLCToLeasingPrOppsUpd(List<Opportunity> oppList, Map<Id, Opportunity> oldRecordsMap){
        Set <String> yardiProspectIdSet = new Set <String> ();
        Map <String, Id> oppOwnerMap = new Map <String, Id> ();
        List <Opportunity> finalOppsToBeProcessed = new List <Opportunity> ();
        List <Opportunity> OppsToBeAssgnOwner = new List <Opportunity> ();
        
        // Get the list of Primary Applicant Leasing Opportunities
        for(Opportunity Opp: oppList){
            if((Opp.StageName != oldRecordsMap.get(Opp.Id).StageName) && Opp.StageName == 'Application Submitted'
              && String.isNotBlank(Opp.Relationship__c) && Opp.Relationship__c == 'Self')
            {                
                yardiProspectIdSet.add(Opp.Yardi_Prospect_Id__c);
                finalOppsToBeProcessed.add(Opp);
            }
        }
        // Extract and prepare a map of Yardi Prospect Id to Owner Name for Primary Applicant Opportunties.
        if(yardiProspectIdSet != null && yardiProspectIdSet.size() >0){
            List <Opportunity> existPrOppList = [SELECT Id, Yardi_Prospect_Id__c, OwnerId, Owner.Name FROM Opportunity 
                                               WHERE  Yardi_Prospect_Id__c IN: yardiProspectIdSet 
                                               AND Relationship__c = 'Self'
                                               ORDER BY createddate DESC];
            
            
            if(existPrOppList != null && existPrOppList.size() >0){
                for(Opportunity Opp: existPrOppList){
                    System.debug('NDEBUG Owner Name:::' + Opp.Owner.Name);
                    if(String.isNotBlank(Opp.Yardi_Prospect_Id__c) && Opp.Owner.Name != 'Integration User' && !oppOwnerMap.containsKey(Opp.Yardi_Prospect_Id__c)){
                        oppOwnerMap.put(Opp.Yardi_Prospect_Id__c, Opp.OwnerId);
                    }
                }
            }
        }
        // Process the Opportunities 
        for(Opportunity Opp : finalOppsToBeProcessed){
            if(oppOwnerMap.containsKey(Opp.Yardi_Prospect_Id__c)){
                Opp.OwnerId = oppOwnerMap.get(Opp.Yardi_Prospect_Id__c);
            }
            else{
                OppsToBeAssgnOwner.add(Opp);
            }          
        }
        if(OppsToBeAssgnOwner != null && OppsToBeAssgnOwner.size() >0){
            OpportunityRoundRobin.roundRobin(OppsToBeAssgnOwner);
        }        
    }
    
	// Assign Primary Leasing Opportunities Owners to the Secondary Applicant Leasing Opportunities
    public static void assignLCToLeasingSecOppsUpd(List<Opportunity> oppList, Map<Id, Opportunity> oldRecordsMap){
        List <Id> priOppIdSet = new List <Id> ();
        for(Opportunity Opp: oppList){
            if((Opp.OwnerId != oldRecordsMap.get(Opp.Id).OwnerId) 
              && String.isNotBlank(Opp.Relationship__c) && Opp.Relationship__c == 'Self')
            {                
                priOppIdSet.add(Opp.Id);
            }
        }
        
        List <Opportunity> secUpdOppList = new List <Opportunity> ();
        
        List <Opportunity> secOppList = [SELECT Id, Primary_Applicant_Opp__r.OwnerId FROM Opportunity WHERE Primary_Applicant_Opp__c IN: priOppIdSet];
        
        if(secOppList != null && secOppList.size() >0){
            for(Opportunity secOpp: secOppList){
                secUpdOppList.add(new Opportunity(Id = secOpp.Id, ownerId = secOpp.Primary_Applicant_Opp__r.OwnerId));
            }
        }
        
        if(secUpdOppList != null && secUpdOppList.size() >0){
            update secUpdOppList;
        }
        
    }
    
    public static String getStageValue (String appDecision, String appStatus, String tenantStatus){
        String StageVal = 'prevVal';
        if(String.isBlank(appDecision)  && appStatus == 'Prospect'){
                		StageVal = 'Application Started';
        }
        else
            if(String.isBlank(appDecision)  && appStatus == 'Applied'){
                StageVal = 'Application Submitted';
            }
        else
            if(appDecision == 'Pending' && appStatus == 'Applied'){
                StageVal = 'Screening';
            }
        else
            if(appDecision == 'Conditional' && appStatus == 'Applied'){
                StageVal = 'Screening';
            }
        else
            if(appDecision == 'Accepted' && appStatus == 'Applied'){
                StageVal = 'Screening';
            }
        else
            if(appDecision == 'Denied' && appStatus == 'Applied'){
                StageVal = 'Screening';
            }
        else
            if(appStatus == 'Approved'){
                StageVal = 'Decision Made';
            }
        else
            if(appStatus == 'Denied'){
                StageVal = 'Decision Made';
            }
        else
            if(appStatus == 'Cancelled'){
                StageVal = 'Decision Made';
            }       
        else
            if(appStatus == 'Resident' && tenantStatus == 'Future'){
                StageVal = 'Pending Move-In';
            }
        else
            if(appStatus == 'Resident' && tenantStatus == 'Current'){
                StageVal = 'Closed Won = Tenant Moved In';
            }        
        return StageVal;
        
    }
    
    public static String getSubStageValue (String appDecision, String appStatus, String tenantStatus){
        String SubStageVal = 'prevVal';
        
        if(appDecision == 'Pending' && appStatus == 'Applied'){                        
            SubStageVal = 'Screening Pending';
        }
        else
            if(appDecision == 'Conditional' && appStatus == 'Applied'){
                SubStageVal = 'Screening Conditional';
            }
        else
            if(appDecision == 'Accepted' && appStatus == 'Applied'){
                SubStageVal = 'Screening Approved';
            }
        else
            if(appDecision == 'Denied' && appStatus == 'Applied'){
                SubStageVal = 'Screening Denied';
            }
        else
            if(appStatus == 'Approved'){
                SubStageVal = 'Application Approved';
            }
        else
            if(appStatus == 'Denied'){
                SubStageVal = 'Application Denied';
            }
        else
            if(appStatus == 'Cancelled'){
                SubStageVal = 'Application Cancelled';
            }       
        return SubStageVal;
        
    }
    
    // Update Stage/Sub Stages based on App Decision and Application Status from Yardi for Leasing Opps -- Update
    public static void procStgSubStgLeasingOppsUpd(List<Opportunity> opList,Map<Id,Opportunity> oldMap){
        for(Opportunity opp : opList){
            System.debug('NDEBUG New Value'+ Opp.App_Decision__c);
            System.debug('NDEBUG New Value'+ Opp.Application_Status__c);
            System.debug('NDEBUG Old Value'+ oldMap.get(opp.Id).App_Decision__c);
            System.debug('NDEBUG Old Value'+ oldMap.get(opp.Id).Application_Status__c);
            if((opp.RecordTypeId == RecordTypes.leasingOpportunityRecordTypeId || opp.RecordTypeId == RecordTypes.leasingSecApplOppRecordTypeId)&& 
               (opp.App_Decision__c != oldMap.get(opp.Id).App_Decision__c || opp.Application_Status__c != oldMap.get(opp.Id).Application_Status__c)
              ||(opp.Tenant_Status1__c != oldMap.get(opp.Id).Tenant_Status1__c)){
                   if(getStageValue(opp.App_Decision__c, opp.Application_Status__c, opp.Tenant_Status1__c) != 'prevVal'){
                       opp.StageName = getStageValue(opp.App_Decision__c, opp.Application_Status__c, opp.Tenant_Status1__c);
                   }
                   if(getSubStageValue(opp.App_Decision__c, opp.Application_Status__c, opp.Tenant_Status1__c) != 'prevVal'){
                       opp.Sub_Stage__c = getSubStageValue(opp.App_Decision__c, opp.Application_Status__c, opp.Tenant_Status1__c);
                   }
               }          
        }        
    }
}
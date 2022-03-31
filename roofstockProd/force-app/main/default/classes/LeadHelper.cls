//may 14
public class LeadHelper {
  //  private static  string sadmin ='jmichael@roofstock.com';  //integration user for HS!
    //Round robin for lead 
    public static void LeadroundRobin(List<Lead> lstNewLead, List<Lead> lstOldLead,Map<Id,Lead> mapNew , map<Id,Lead> mapOld, String sDml){
        List<Lead> rrErrors = new List<Lead>();
        rrErrors = LeadRoundRobin.roundRobin(lstNewLead, lstOldLead,mapNew, mapOld, sDml); 
        // Post-trigger errors and cleanup
        if(rrErrors.size() > 0) {
            for(Lead ls : rrErrors)
                ls.addError('ERROR: Could not update Assignment Group records');
        }    
    }
    // Leasing - After lead is converted to opportunity,update the opportunity name   
    public static void UpdateLeasingOpportunityNameAfterLeadConversion(Set<Id> newLeadIds)
    {
        if(!System.isFuture()){
            Id leasingLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
            List<Opportunity> os = new List<opportunity>();
            List<Lead> updateLeads = [select Id,Phone, Company,isConverted,ConvertedOpportunityId,ConvertedContactId ,RecordtypeId,X1_Ideally_when_would_you_buy_your_first__c from lead where id in :newLeadIds ];
            
            for (Lead lead : updateLeads) {
                //after ;lead was converted to opportunity               
                if(lead.isConverted && lead.ConvertedOpportunityId != null && lead.RecordtypeId == leasingLeadRTId){                
                    Opportunity o = new Opportunity();
                    o.Id = lead.ConvertedOpportunityId;                  
                    
                    if(lead.RecordTypeId == leasingLeadRTId){
                        if(lead.X1_Ideally_when_would_you_buy_your_first__c != null) {
                            o.name = lead.X1_Ideally_when_would_you_buy_your_first__c.format() + ' - ' + lead.Company;                            
                        } 
                        else {
                            o.name = 'Leasing1';
                        }
                    }                      
                    os.add(o);                   
                }
            }
            if(os != null && os.Size() > 0) {
                update os;  //update opportunity                            
            } 
        }
    }
    
    // After lead is converted to opportunity,update the opportunity name   
    public static void UpdateOpportunityNameAfterLeadConversion(Set<Id> newLeadIds){
        if(!System.isFuture()){
            Id retailBuyerLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
            Id retailSellerLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
            
            List<Opportunity> os = new List<opportunity>();
            
            System.debug('lll UpdateOpportunityNameAfterLeadConversion');
            List<Lead> updateLeads = [select Id,Phone, Company,isConverted,ConvertedOpportunityId,ConvertedContactId ,RecordtypeId,Property_Address__c from lead where id in :newLeadIds ];
            
            for (Lead lead : updateLeads) {
                //after ;lead was converted to opportunity
                System.debug('foofoo UpdateOpportunityNameAfterLeadConversion loop' + lead.RecordtypeId);
                
                if(lead.isConverted && lead.ConvertedOpportunityId != null && 
                   (lead.RecordtypeId == retailBuyerLeadRTId || lead.RecordTypeId == retailSellerLeadRTId)){
                       // System.debug('lll UpdateOpportunityNameAfterLeadConversion converted');
                       Opportunity o = new Opportunity();
                       o.Id = lead.ConvertedOpportunityId;
                       //  o.Velo__Velocify_Phone__c = lead.Phone; //velocify phone field
                       
                       if(lead.RecordtypeId == retailBuyerLeadRTId){
                           o.name = 'Purchase1-'  + lead.Company ; //lead conversion only happens once ,so start numbering with one
                           //assign the contact as promary buyer/seller contact
                           if(o.Buyer_Contact_Name__c == null) {
                               o.Buyer_Contact_Name__c = lead.ConvertedContactId;
                           }
                       } else if(lead.RecordTypeId == retailSellerLeadRTId){
                           if(!String.isBlank(lead.Property_Address__c)) {
                               o.name =   lead.Property_Address__c.replace('<br>','');
                               o.stagename = 'Qualified Listing';
                           } 
                           else {
                               o.name = 'Listing1';
                           }
                       }
                       os.add(o);                   
                   }
            }
            if(os != null && os.Size() > 0) {
                update os;  //update opportunity 
                System.debug('lll UpdateOpportunityNameAfterLeadConversion updated');
            }
        }
    }
    //update record type of newly created leads
    public static void UpdateLeadRecordTypes(List<Lead> newLeads){
        if(!System.isFuture() ){
            String sadmin = [Select User_Name__c from Roofstock__mdt where developerName = 'Hubspot_Integration'].User_Name__c;
            Id retailBuyerLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
            Id retailSellerLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
            Id leasingLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
            Id certifiedAgetLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Certified Agent').getRecordTypeId();
            
            List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
			String proflieName = PROFILE[0].Name;
            Set<String> allowedProfilesSet = new Set<String>{'System Administrator API','Hubspot API'};

            // System.debug('sree' + retailBuyerLeadRTId + retailSellerLeadRTId );
            for (Lead lead : newLeads) {
                String currentUser = UserInfo.getUserName();  
                
                // change record type only if not coming via HS integrtation!@
                // for HS leads ,detrmine the record type based on lead interest filled in the forms
                System.debug('** outside recordtype update' + Test.isRunningTest());
                //if( !String.isBlank(lead.Lead_Interest__c) && (Test.isRunningTest() || currentUser.containsIgnoreCase(sadmin) ) )  {
                System.debug('-allowedProfilesSet-'+allowedProfilesSet);
                System.debug('-proflieName-'+proflieName);
                if( !String.isBlank(lead.Lead_Interest__c) && (Test.isRunningTest() || allowedProfilesSet.contains(proflieName) ) )  {
                    System.debug('** inside recordtype update' + Lead.Lead_Interest__c);
                    if(Lead.Lead_Interest__c == 'Buying Properties' || Lead.Lead_Interest__c == 'Referring Clients as a Broker/Agent' ) {
                        lead.recordtypeid= retailBuyerLeadRTId;
                    }
                    else if(Lead.Lead_Interest__c == 'Selling Properties' ) {
                        System.debug('-selling rec type-'+retailSellerLeadRTId);
                        lead.recordtypeid= retailSellerLeadRTId;                  
                    }
                    
                    System.debug('FO-ORT' + lead.recordtypeid);
                }  //if blank
                else if((Lead.Certified_Roofstock_Agent__c == 'Yes') && (Test.isRunningTest() || currentUser.containsIgnoreCase(sadmin) )){
                	lead.recordtypeid= certifiedAgetLeadRTId;
                    //User usr = [Select id,Name from User where Name =: Label.CertifiedAgentLeadOwner];
                    Group gr = [select Id,Name,DeveloperName from Group where  Type = 'Queue' AND NAME = 'Certified Agent Lead Queue'];

                    lead.ownerId = gr.Id;
                }
                
                //check if lead close date is 90 days (retail default not changed) for leasing ,then bring it down to 14 days
                if(lead.recordtypeid == leasingLeadRTId && lead.X1_Ideally_when_would_you_buy_your_first__c == Date.Today().addDays(90)){
                    lead.X1_Ideally_when_would_you_buy_your_first__c = Date.Today().addDays(14);
                } 
            }
        }//for
    }
    
    
    public static void UpdateListingMarketAndYieldFutureAsync(Set<Id> newLeadIds){
        if(!System.isFuture()){
            System.debug('UpdateListingMarketAndYieldFutureAsync start' + system.isFuture() + system.isBatch());
            
            try{
                if(system.isFuture() || system.isBatch()){
                    System.debug('UpdateListingMarketAndYieldFutureAsync start,calling normal');
                    
                    // If we're in an async context, just call the normal version of the method.
                    UpdateListingMarketAndYield(newLeadIds);
                } else {
                    if(Limits.getFutureCalls() < Limits.getLimitFutureCalls()){
                        System.debug('UpdateListingMarketAndYieldFutureAsync start,calling future');
                        
                        // Otherwise, we can call the @future version
                        UpdateListingMarketAndYieldFuture(newLeadIds);
                    } else {
                        // Error out using an inner class that extends the standard Exception class
                        System.debug('UpdateListingMarketAndYieldFutureAsync Error' + 'Hit future limit, check code');
                    }
                }
            }catch(Exception e){
                // Notify someone that an exception occurred.
                // This could be a chatter post, an email, running a class that integrates
                //   with Slack, etc...
                System.debug('UpdateListingMarketAndYieldFutureAsync Error' + e.getMessage());
            }
        }
    }
    
    @future (callout=true)
    public static void UpdateListingMarketAndYieldFuture(Set<Id> newLeadIds){
        System.debug('** future callout to zip api' );
        UpdateListingMarketAndYield(newLeadIds);
    }
    
    
    public static void UpdateListingMarketAndYield(Set<Id> newLeadIds){
        System.debug('** normal callout to zip api' +system.isFuture() + system.isBatch());
        
        //System.debug('**** UpdateListingMarketAndYield trigger');
        
        List<Lead> newLeads = [select id,Listing_Markets__c,Property_Zip_Code__c,RecordTypeId,Yield_Value__c,Market_Rent__c,Minimum_Rent__c,Current_Rent__c from lead where id in :newLeadIds];
        //lookup markets based on postal code of listing address!!
        //populate yield value based on value from lookup table   
        
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Lead.getRecordTypeInfosById();
        
        Set<String> markets = new Set<String>();
        Set<String> zipcodes = new Set<String>();
        
        for (Lead lead : newLeads) {
            if(lead.Property_Zip_Code__c != NULL ) {
                zipcodes.add(lead.Property_Zip_Code__c);
            }
        }
        
        //System.debug('starting..');
        if(zipcodes.size() > 0) {  //if there were zipcodes in the lead loaded
            
            System.debug('***starting zipcode..');
            Map<String, String> zipmarkets = SalesfunnelHelper.getMarketsbyZip(zipCodes);
            
            //System.debug('starting zipcode2..' + zipmarkets.size());
            //assign listing market to alll new leads!
            if(zipmarkets!= NULL && zipmarkets.size() > 0 ) { //only do anything if there is any mapping stored@
                //System.debug('starting zipcode2..');
                for (Lead lead : newLeads) {
                    if(lead.Property_Zip_Code__c != null) {
                        String mzip = lead.Property_Zip_Code__c;
                        String mtype = rtMap.get(lead.RecordTypeId).getName();
                        if(mtype == 'Retail Seller') { 
                            //System.debug('starting zipcode3..');
                            String marketzipInfo = zipmarkets.get(mzip);
                            if(marketzipInfo != NULL){
                                //System.debug('starting zipcode4..');
                                lead.Listing_Markets__c = marketzipInfo;
                            }
                        } //rt check
                    } //if zip code
                } //for loop
                
            } //if
            
        } //zip code length
        
        for (Lead lead : newLeads) {
            if(lead.Listing_Markets__c != NULL) {
                markets.add(lead.Listing_Markets__c);
            }
        }
        if(markets.size() > 0){
            System.debug('starting markets..');
            // System.Debug(lead.Listing_Markets__c)  ;  
            
            // Query the yield table for their associated market yield valiue!
            Map<String, MarketYield__c> yields = new Map<String, MarketYield__c>();
            
            for(MarketYield__c myield : [select name, Minimum_Gross_Yield__c ,Market_Rent__c, Minimum_rent__c from MarketYield__c  
                                         where name in :markets]) {
                                             //System.debug('foo' + myield.Name +  myield.Minimum_Gross_Yield__c + myield.Market_Rent__c  );                           
                                             yields.put(myield.Name, myield);
                                         }
            
            
            for (Lead lead : newLeads) {
                System.debug('starting markets2..');
                
                if(lead.Listing_Markets__c != null) {
                    System.debug('starting markets3..');
                    String market = lead.Listing_Markets__c;
                    String type = rtMap.get(lead.RecordTypeId).getName();
                    
                    if(market != 'Undecided' && (type == 'Institutional Seller' || type == 'Retail Seller')) { 
                        // Current rent / minimum gross yield
                        MarketYield__c marketInfo = yields.get(market);
                        
                        if(marketInfo != NULL){
                            lead.Market_Rent__c = marketInfo.Market_Rent__c; //not stored currently
                            lead.Minimum_rent__c = marketInfo.Minimum_rent__c;
                            if(lead.Current_Rent__c != NULL && lead.Current_Rent__c > 0) {
                                double minyield = marketInfo.Minimum_Gross_Yield__c / 100;
                                lead.Yield_Value__c  = lead.Current_Rent__c / minyield;
                                lead.Minimum_Gross_Yield__c = marketInfo.Minimum_Gross_Yield__c;
                                
                            }
                            
                        }
                        
                    }
                    else
                    {
                        lead.Yield_Value__c = 0.0;
                    }
                }
            }
            update newLeads;
        } //if
        
        
    }
    //Process Builder - Lead Conversion updates
    
    public static void leadConversionBeforeUpdates(List<Lead> newLeadList){
        Id roofstockOneRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Roofstock One').getRecordTypeId();
        Id retailBuyerLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        for(Lead ld:newLeadList){
            //1.Active Hubspot Condition
            if(ld.Hubspot_Condition__c == 'Active' && ld.Active_Hubspot_Condition_Date__c == null){
                ld.Active_Hubspot_Condition_Date__c = Date.today();
                ld.Active_Hubspot_Condition__c = true;
            }
            //2.Outreach Lead Status Reasons
            if(ld.No_Convert_Reason__c == null && ld.RecordTypeId == retailBuyerLeadRecordTypeId){
                if(ld.Status == 'New'){
                   // ld.No_Convert_Reason__c = 'New';
                }
                if(ld.Status == 'Working'){
                    ld.No_Convert_Reason__c = 'Working';
                }
                if(ld.Status == 'Appointment'){
                    ld.No_Convert_Reason__c = 'Appointment';
                }
                if(ld.Status == 'No Appointment'){
                    ld.No_Convert_Reason__c = 'No Appointment';
                }
            }
            
            //4.RS1 Qualified Date
            if(ld.RecordTypeId == roofstockOneRecordTypeId && ld.Status == 'Qualified'){
                ld.Qualified_Date__c = Date.today();
            }
            
        }
    }
    
    //Process Builder - Lead Conversion updates
    public static void leadConversionAfterUpdates(List<Lead> newLeadList){
        Map<String,Lead> opptIdCloseDateMap = new Map<String,Lead>();
        Map<String,String> opptIdRecTypeMap = new Map<String,String>();
        Map<String,Lead> propertyPriceMap = new Map<String,Lead>();
        Map<String,Lead> sellerContactNameMap = new Map<String,Lead>();
        
        
        Id roofstockOneRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Roofstock One').getRecordTypeId();
        Id retailBuyerLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        Id retailSellerLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        Id institutionalBuyerLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Institutional Buyer').getRecordTypeId();        
        Id institutionalSellerLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Institutional Seller').getRecordTypeId();        
        
        Id roofstockOneOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Roofstock One').getRecordTypeId();        
        Id retailBuyerOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        Id retailSellerOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        Id institutionalBuyerOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Institutional Buyer').getRecordTypeId();        
        Id institutionalSellerOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Institutional Seller').getRecordTypeId();        
        Id directBuyOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Direct Buy').getRecordTypeId(); 
        for(Lead ld:newLeadList){
            //3.All lead conversions
            if(ld.ConvertedOpportunityId!=null && ld.IsConverted == true){
                //opptIdCloseDateMap.put(ld.ConvertedOpportunityId,ld.X1_Ideally_when_would_you_buy_your_first__c);//Target Date to Close
                opptIdCloseDateMap.put(ld.ConvertedOpportunityId,ld);//Target Date to Close

            }
            //5.Retail Buyer- Is opportunity converted ?
            if(ld.IsConverted == true && ld.RecordTypeId == retailBuyerLeadRecordTypeId && ld.ConvertedOpportunityId!=null){
                opptIdRecTypeMap.put(ld.ConvertedOpportunityId,retailBuyerOpportunityRecordTypeId);
            }
            //6.Retail Seller- Is opportunity converted?
            else if(ld.IsConverted == true && ld.ConvertedOpportunityId != null && ld.RecordTypeId == retailSellerLeadRecordTypeId && ld.Direct_Buy_Lead__c != 'Yes'){
                opptIdRecTypeMap.put(ld.ConvertedOpportunityId,retailSellerOpportunityRecordTypeId);
                propertyPriceMap.put(ld.ConvertedOpportunityId,ld);
                sellerContactNameMap.put(ld.ConvertedOpportunityId,ld);
            }
            //7.Inst Buyer- Is opportunity converted?
            else if(ld.IsConverted == true && ld.ConvertedOpportunityId != null && ld.RecordTypeId == institutionalBuyerLeadRecordTypeId){
                opptIdRecTypeMap.put(ld.ConvertedOpportunityId,institutionalBuyerOpportunityRecordTypeId);
            }
            //8.Inst Seller - Is opportunity converted?
            else if(ld.IsConverted == true && ld.ConvertedOpportunityId !=null && ld.RecordTypeId == institutionalSellerLeadRecordTypeId){
                opptIdRecTypeMap.put(ld.ConvertedOpportunityId,institutionalSellerOpportunityRecordTypeId); 
                propertyPriceMap.put(ld.ConvertedOpportunityId,ld);
                
            }
            //9.Direct Buy - Is opportunity converted?
            else if(ld.IsConverted == true && ld.ConvertedOpportunityId !=null && ld.Direct_Buy_Lead__c == 'Yes'){
                opptIdRecTypeMap.put(ld.ConvertedOpportunityId,directBuyOpportunityRecordTypeId);
            }
            //10.Roofstock One - Is opportunity converted?
            else if(ld.IsConverted == true && ld.ConvertedOpportunityId!=null && ld.RecordTypeId ==roofstockOneRecordTypeId){
                opptIdRecTypeMap.put(ld.ConvertedOpportunityId,roofstockOneOpportunityRecordTypeId);
            }
        }
        
        List<Opportunity> matchingOpportunityList = [select Id,closeDate,Purchase_Price__c,RecordTypeId from Opportunity where (Id IN:opptIdCloseDateMap.keyset() OR Id IN:opptIdRecTypeMap.keyset() OR Id IN:propertyPriceMap.keyset() OR Id IN:sellerContactNameMap.keyset())];
        List<Opportunity> updateOpportunityList = new List<Opportunity>();
        if(!matchingOpportunityList.isEmpty()){
            for(Opportunity opp : matchingOpportunityList){
                if(opptIdCloseDateMap.get(opp.Id).X1_Ideally_when_would_you_buy_your_first__c !=null){
                	opp.closeDate =  opptIdCloseDateMap?.get(opp.Id)?.X1_Ideally_when_would_you_buy_your_first__c;
                }
                opp.Purchase_Price__c = propertyPriceMap?.get(opp.Id)?.Listing_Price__c;
                opp.SellerContactName__c = sellerContactNameMap?.get(opp.Id)?.ConvertedContactId;
                if(opptIdRecTypeMap!=null){
                    if(opptIdRecTypeMap.get(opp.Id)!=null){
                        opp.RecordTypeId = opptIdRecTypeMap.get(opp.Id);
                    }
                    
                }
               // opp.RecordTypeId = opptIdRecTypeMap?.get(opp.Id);
                updateOpportunityList.add(opp);
            }
            if(!updateOpportunityList.isEmpty()){
                update updateOpportunityList;
            }
        }

    }
    
    //Process Builder - Bluebird Label and Assignment
    public static void updateBluebird(List<Lead> newLeadList){
        for(Lead ld : newLeadList){
            if(ld.Made_An_Offer_Date__c!=null){
                ld.Bluebird__c = true;
            } 
        }
    }
    //Process Builder - Lead Record Type Assignment
    public static void recordTypeAssignment(List<Lead> newLeadList){
        Id roofstockOneRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Roofstock One').getRecordTypeId();
        
        for(Lead ld : newLeadList){
            if(ld.Lead_Interest__c == 'Roofstock One'){
                ld.RecordTypeId = roofstockOneRecordTypeId;
            }
        }
    }
    public static void runAssignmentRules(List<Lead> newLeadList){
        Id roofstockOneRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Roofstock One').getRecordTypeId();
        
        List<Lead> leadList = new List<Lead>();
    	for (Lead l : newLeadList) {
            
            if(l.RecordTypeId == roofstockOneRecordTypeId){
        		leadList.add(new Lead(id = l.id));
            }
    	}
        if(!leadList.isEmpty()){
			Database.DMLOptions dmo = new Database.DMLOptions();
    		dmo.assignmentRuleHeader.useDefaultRule = true;
	    	Database.update(leadList, dmo);
        }
        
    }
    //Process Builder - Set Calendly AE on Lead
    public static void setCalendlyAE(List<Lead> newLeadList){
        for(Lead ld : newLeadList){
            if(ld.LeadSource == 'Calendly'){
                ld.Calendly_AE__c = ld.OwnerId;
            }
        }
    }
    //Process Builder - Transfer Task Owners on lead owner change from Queue
    public static void transferTaskOwners(List<Lead> newLeadList,Map<Id,Lead> oldRecordsMap){
        Map<String,String> leadOwnerMap = new Map<String,String>();
        List<Task> updateTaskList = new List<Task>();
        for(Lead ld : newLeadList){
            System.debug('=old='+oldRecordsMap.get(ld.Id).ownerId);
            System.debug('=new='+ld.OwnerId);
            System.debug('=group?='+string.valueOf(oldRecordsMap.get(ld.Id).ownerId).startsWith('00G'));
            System.debug('=user?='+string.valueOf(ld.OwnerId).startsWith('005'));
            
            if((oldRecordsMap.get(ld.Id).ownerId != ld.OwnerId) && (string.valueOf(oldRecordsMap.get(ld.Id).ownerId).startsWith('00G')) && (string.valueOf(ld.OwnerId).startsWith('005'))){
                leadOwnerMap.put(ld.Id,ld.OwnerId);
                System.debug('=leadOwnerMap='+leadOwnerMap);
            }
        }
        List<Task> taskList = [select Id,whoId,Status,OwnerId from Task where whoId IN:leadOwnerMap.keyset() and Status ='Open'];
        System.debug('=taskList='+taskList);
        for(Task tsk : taskList){
            //tsk.OwnerId = leadOwnerMap?.get(tsk.whoId);
            if(leadOwnerMap!=null){
                if(leadOwnerMap.get(tsk.whoId)!=null){
                    tsk.OwnerId = leadOwnerMap.get(tsk.whoId);
                }
                
            }
            updateTaskList.add(tsk);
        }
        System.debug('=updateTaskList='+updateTaskList);
        if(!updateTaskList.isEmpty()){
            update updateTaskList;
        }
    }
    
    
}
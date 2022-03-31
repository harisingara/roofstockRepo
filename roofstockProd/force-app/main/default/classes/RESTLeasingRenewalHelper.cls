global class RESTLeasingRenewalHelper {
    global class LeaseListWrap{
        global List<LeaseRenewalProposalList> leaseRenewalProposalList;
    }
    
    
    
    //Added for Lease Proposal Renewal
    global class LeaseRenewalProposalList  {
        global Integer leaseRenewalProposalId ;
        global Integer yardiCurrentLeaseHistoryHmy ;
        global Integer yardiRenewalProposalLeaseHistoryHmy  ;
        global Decimal proposedRent;
        global String term;
        global String leaseStartDate;
        global String leaseEndDate;
        global String status;
        global Integer tenantId;
        global String fName;
        global String lName;
        global String prospectLink;
        global String tenantLink;
    }
    
    global class PostResponse {
        global ResponseWrapper responseBody;
        global PostResponse(List<ResponseBody> turnResponse) {
            this.responseBody = new ResponseWrapper(turnResponse);
        }
    }
    
    global class ResponseWrapper {  
        global List<ResponseBody> leaseResponse;  
        global ResponseWrapper(){
            leaseResponse = new List<ResponseBody>();
        }
        global ResponseWrapper(List<ResponseBody> leaseResponse) {
            this.leaseResponse = leaseResponse;
        }
    }  
    
    global class ResponseBody{
        global Decimal leaseRenewalProposalId ;
        global String salesforceId;
        global ResponseBody(Decimal leaseRenewalProposalId , String salesforceId) {
            this.leaseRenewalProposalId  = leaseRenewalProposalId ;
            this.salesforceId = salesforceId;
        }
    }
    
    
    global static List <ResponseBody> processLeaseRenewalProposals(List<leaseRenewalProposalList> leaseRenewalProposalList) {
        List<ResponseBody> lrpResponseList = new List<ResponseBody>();
        Set<Integer> tenantIdSet = new Set<Integer>(); 
        Set<Integer> lrpYardiIdSet = new Set<Integer>();
        Set<Integer> leaseYardiIdSet = new Set<Integer>();
        
        List<leaseRenewalProposalList> lrpToProcess = new List<leaseRenewalProposalList> ();
        
        System.debug('NDEBUG ::: Lease Renewal Proposal Request'+leaseRenewalProposalList);
        
        for(leaseRenewalProposalList lrp: leaseRenewalProposalList){
            if(lrp.yardiCurrentLeaseHistoryHmy  != null && lrp.tenantId != null){
                leaseYardiIdSet.add(lrp.yardiCurrentLeaseHistoryHmy);
                lrpYardiIdSet.add(lrp.yardiRenewalProposalLeaseHistoryHmy);
                tenantIdSet.add(lrp.tenantId);
                lrpToProcess.add(lrp);
            }
        }
        
        Map <Integer,Id> leaseyardiIdLeaseIdMap = new Map <Integer,Id> ();
        for(Lease__c l: [SELECT Id, Yardi_Lease_Id__c from Lease__c WHERE Yardi_Lease_Id__c IN: leaseYardiIdSet]){
            if(l.Yardi_Lease_Id__c != null){
               leaseyardiIdLeaseIdMap.put(Integer.valueof(l.Yardi_Lease_Id__c), l.Id); 
            }
        }
        
        // Get the existing Lease Renewal Proposal Records
        Map <String, Lease_Renewal_Proposal__c> existlrpMap = new Map <String, Lease_Renewal_Proposal__c> ();
        List <Lease_Renewal_Proposal__c> lrpList = [SELECT Id, Yardi_Lease_Id__c, Yardi_Lease_Renewal_Id__c, Tenant_Id__c from Lease_Renewal_Proposal__c 
                                                   WHERE Yardi_Lease_Renewal_Id__c  IN: lrpYardiIdSet and Tenant_Id__c IN: tenantIdSet];
        for(Lease_Renewal_Proposal__c lrp: lrpList){
            if(lrp.Yardi_Lease_Renewal_Id__c != null && lrp.Tenant_Id__c != null){
                String key = lrp.Yardi_Lease_Renewal_Id__c + '_' + lrp.Tenant_Id__c;
                existlrpMap.put(key, lrp);
            }
        }
        
        Map <String, Tenant__c> tenantMap = new Map <String, Tenant__c> ();
        
        // Process the existing tenants and leases here
        List<Tenant__c > tenantList = [SELECT Id, Tenent_Id__c, Lease__c , Lease__r.Yardi_Lease_Id__c from Tenant__c WHERE Tenent_Id__c IN: tenantIdSet];
        if(tenantList != null && tenantList.size() >0){
            for(Tenant__c tnt : tenantList){
                String key = '';
                if(tnt.Lease__r.Yardi_Lease_Id__c != null && tnt.Tenent_Id__c != null){
                    key = tnt.Lease__r.Yardi_Lease_Id__c + '_' + tnt.Tenent_Id__c;
                    tenantMap.put(key, tnt);                    
                }
            }
        }
        
        // Processing the incoming valid Lease Renewal Proposals here
        Set <Id> lrpbeingModified = new Set <Id> ();
        List <Lease_Renewal_Proposal__c> lrpListInsUpd = new List <Lease_Renewal_Proposal__c> ();
        for(leaseRenewalProposalList lrpreq: lrpToProcess){
            if(lrpreq.yardiRenewalProposalLeaseHistoryHmy != null && lrpreq.yardiCurrentLeaseHistoryHmy != null){
                String key = lrpreq.yardiRenewalProposalLeaseHistoryHmy  + '_' + lrpreq.tenantId;
                String key1 = lrpreq.yardiCurrentLeaseHistoryHmy   + '_' + lrpreq.tenantId;
                Lease_Renewal_Proposal__c lrpnew = new Lease_Renewal_Proposal__c ();
                if(existlrpMap.containsKey(key)){
                    lrpnew.Id = existlrpMap.get(key).Id;
                }
                
                if(lrpnew.Id == null|| (lrpnew.Id != null && !lrpbeingModified.contains(lrpnew.Id))){
                    if(tenantMap.containsKey(key1)){
                        if(lrpnew.Id != null){
                           lrpbeingModified.add(lrpnew.Id); 
                        }
                        //lrpnew.Lease__c = tenantMap.get(key).Lease__c;
                        if(lrpnew.Id == null){
                        	lrpnew.Lease__c = leaseyardiIdLeaseIdMap.get(lrpreq.yardiCurrentLeaseHistoryHmy);
                        }
                        lrpnew.Tenant__c = tenantMap.get(key1).Id;
                        lrpnew.Name = string.valueof(lrpreq.leaseRenewalProposalId) ;
                        lrpnew.Proposed_Rent__c = lrpreq.proposedRent;
                        lrpnew.Lease_Start_Date__c = lrpreq.leaseStartDate;
                        lrpnew.Lease_End_Date__c = lrpreq.leaseEndDate;
                        lrpnew.Term__c = lrpreq.term;
                        lrpnew.Status__c = lrpreq.status;
                        lrpnew.Tenant_Id__c = lrpreq.tenantId;
                        lrpnew.Yardi_Lease_Id__c = lrpreq.yardiCurrentLeaseHistoryHmy ;
                        lrpnew.Tenant_First_Name__c = lrpreq.fName;
                        lrpnew.Tenant_Last_Name__c = lrpreq.lName;
                        lrpnew.Prospect_Link__c = lrpreq.prospectLink;
                        lrpnew.Tenant_Link__c = lrpreq.tenantLink;
                        lrpnew.Yardi_Lease_Renewal_Id__c = lrpreq.yardiRenewalProposalLeaseHistoryHmy;
                        lrpListInsUpd.add(lrpnew);                   
                    }
                }
            }
        }
        if(lrpListInsUpd != null && lrpListInsUpd.size() >0){
            System.Debug('NDEBUG LRPs being upserted' + lrpListInsUpd);
            upsert lrpListInsUpd;
        }
        
        // Get the Final Lease Renewal Proposal Records
        Map <String, Lease_Renewal_Proposal__c> finallrpMap = new Map <String, Lease_Renewal_Proposal__c> ();
        List <Lease_Renewal_Proposal__c> finalLrpList = [SELECT Id, Name, Yardi_Lease_Renewal_Id__c, Yardi_Lease_Id__c, Tenant_Id__c from Lease_Renewal_Proposal__c 
                                                         WHERE Yardi_Lease_Renewal_Id__c IN: lrpYardiIdSet and Tenant_Id__c IN: tenantIdSet];
        for(Lease_Renewal_Proposal__c lrp: finalLrpList){
            if(lrp.Yardi_Lease_Renewal_Id__c != null && lrp.Tenant_Id__c != null){
                String key = lrp.Yardi_Lease_Renewal_Id__c + '_' + lrp.Tenant_Id__c;
                finallrpMap.put(key, lrp);
            }
        }
        
        for(leaseRenewalProposalList lrpreq: lrpToProcess){
            String key = lrpreq.yardiRenewalProposalLeaseHistoryHmy   + '_' + lrpreq.tenantId;
            if(finallrpMap.containsKey(key)){
                lrpResponseList.add(new ResponseBody(lrpreq.yardiRenewalProposalLeaseHistoryHmy , finallrpMap.get(key).Id)); 
            }
        }
        System.debug('NDEBUG Response being returned is:::' + lrpResponseList);
        return lrpResponseList;
    }
    
}
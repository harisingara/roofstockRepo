global class RESTLeasingTenantsHelper {
    //global List<LeaseList> leaseList;
    global class LeaseListWrap{
        global List<LeaseList> LeaseList;
    }
    global class Tenants {
        global Integer tenantId;
        global String fName;
        global String lName;
        global String status;
        global String tenantType;
        global String email;
        global String phone;        
    }
    
    global class LeaseList {
        global Integer leaseId;
        global String status;
        global String leaseStartDate;
        global String leaseEndDate;
        global String leaseSignedDate;
        global String homeCode;
        global List<Tenants> tenants;
        global String apprStatus;
        global Boolean isMonthToMonth; 
        global Decimal rentAmount;
        global Decimal balance;
        global Decimal otherRentAmount;
        global Integer yardiLeaseHistoryHmy;
        global String renewalStep;
        global String renewalResidentSignedDate;
        global String renewalPmSignedDate;
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
        global Decimal leaseId;
        global String salesforceId;
        global ResponseBody(Decimal leaseId, String salesforceId) {
            this.leaseId = leaseId;
            this.salesforceId = salesforceId;
        }
    }
    
    global static PostResponse UpdateLease(List<LeaseList> leaseList) {
        List<ResponseBody> leaseResponseList = new List<ResponseBody>();
        
        /*  start   */
        Set<String> homeCodeList = new Set<String>(); 
        Map<String,Lease__c> leasingRecordMap = new Map<String,Lease__c>();
        Map<String,String> homeCodePropertyMap = new Map<String,String>();
        Map<String,List<Tenants>> filteredNewHomeCodeTenantRecordsMap = new Map<String,List<Tenants>>();
        List<Lease__c> updateLeasingRecordsList = new List<Lease__c>();
        Set<Lease__c> updateLeasingRecordsSet = new Set<Lease__c>();
        List<Tenant__c> UpdateTenantRecordList = new List<Tenant__c>();
        Set<Tenant__c> UpdateTenantRecordSet = new Set<Tenant__c>();
        List<Tenant__c> insertNewTenantOnExistingLeasing = new List<Tenant__c>();
        List<Lease__c> insertNewLeasingRecorsList = new List<Lease__c>();
        List<Tenant__c> insertNewTenantRecords = new List<Tenant__c>();
        Set<String> homeCodeSet = new Set<String>();
        Set<Integer> tenantIdSet = new Set<Integer>(); 
        Set<Integer> leaseIdSet = new Set<Integer>(); 
        
        /*Capture All the Home code from the input/request string, this helps us to check if we already have leasing record in Salesforce DB*/
        for(LeaseList leaseRec :leaseList){
            homeCodeList.add(leaseRec.homeCode);
        }
        System.debug('=homeCodeList='+homeCodeList);
        
        /* Query the matching records to update them based on the previously captured homecode*/
        List<Lease__c> leasingTenantList = [select Id,Lease_Id__c,Property_Unit__r.HomeCode__c,Status__c,Lease_Start_Date__c,Lease_End_Date__c,Total_Unpaid_Balance__c,Current_Lease_Rent__c,(select Id,Lease__c,Tenent_Id__c,First_Name__c,Last_Name__c,Status__c from Tenant1__r) from Lease__c where Property_Unit__r.HomeCode__c IN:homeCodeList];
        System.debug('=leasingTenantList='+leasingTenantList);
        /*Create a Map of home code and Property Unity to associate new Leasing records to the property unit based on homecode*/
        List<Property_Unit__c> propertyUnityList = [select Id,HomeCode__c from Property_Unit__c where HomeCode__c IN:homeCodeList and Property__r.RecordType.DeveloperName ='Asset_Management'];
        for(Property_Unit__c pu :propertyUnityList){
            homeCodePropertyMap.put(pu.HomeCode__c,pu.Id);
        }
        
        /* Capture Tenant ID's from the Salesforce Database
* 1. To check if tenant record already present in SF 
* 2. If not to create a new tenant record under the leasing record
* */    Map<Integer,Lease__c> mapleaseIdLease = new Map<Integer,Lease__c>();
        Map<Integer,Tenant__c> mapTenantIdTenant = new Map<Integer,Tenant__c>();
        for(Lease__c existingLease :leasingTenantList){
            //cmap leadid with lease
			mapleaseIdLease.put(Integer.valueOf(existingLease.Lease_Id__c),existingLease);
            if (existingLease.Lease_Id__c <> null) {
                leaseIdSet.add(Integer.ValueOf(existingLease.Lease_Id__c));
            }
            homeCodeSet.add(existingLease.Property_Unit__r.HomeCode__c);
            for(Tenant__c existingTenant : existingLease.Tenant1__r){
                //map of tenant id with tenant
                tenantIdSet.add(Integer.ValueOf(existingTenant.Tenent_Id__c));
                //mapTenantIdTenant.put(Integer.valueOf(existingTenant.Tenent_Id__c),existingTenant);
                System.debug('--'+Integer.ValueOf(existingLease.Lease_Id__c)+Integer.valueOf(existingTenant.Tenent_Id__c));
                mapTenantIdTenant.put(Integer.ValueOf(existingLease.Lease_Id__c)+Integer.valueOf(existingTenant.Tenent_Id__c),existingTenant);
            }
        }
        System.debug('-mapTenantIdTenant-'+mapTenantIdTenant);
        /*1. For Every input/request String, check if matching home code preset in Leasing Object
*2. If present, Update the leasing record
*   a. Check if the tenent already present in DB based on tenantid of input/request string.
*   b. If present, Update the tenet Record.
*   c. If not, Create new Tenant record under the leasing record.
*3. If not, Create new Leasing Record and Tenant Records
* */
        for(LeaseList leaseRec :leaseList){
            //if(homeCodeSet.contains(leaseRec.homeCode)){
            //if (leaseIdSet.contains(leaseRec.leaseId)) {
                if(mapleaseIdLease.containsKey(Integer.valueOf(leaseRec.leaseId))){
                    Lease__c l = mapleaseIdLease.get(Integer.valueOf(leaseRec.leaseId));
                //for(Lease__c l:leasingTenantList){
                    //if(leaseRec.homeCode == l.Property_Unit__r.HomeCode__c){
                        //if(leaseRec.leaseId == l.Lease_Id__c){
                            l.Lease_Id__c = leaseRec.leaseId;
                            l.Status__c = leaseRec.status;
                            l.APPR_Status__c = leaseRec.apprStatus;
                            if (leaseRec.isMonthToMonth <> null) {
                                l.isM2M__c = leaseRec.isMonthToMonth;
                            }
                            l.Lease_Start_Date__c = Date.ValueOf(leaseRec.leaseStartDate);
                            if (leaseRec.leaseSignedDate != null) {
                                l.Lease_Signed_Date__c = Date.ValueOf(leaseRec.leaseSignedDate);
                            }
                            l.Lease_End_Date__c = Date.ValueOf(leaseRec.leaseEndDate);
                    		l.Total_Unpaid_Balance__c = leaseRec.balance;
                            l.Current_Lease_Rent__c = leaseRec.rentAmount;

                            // https://roofstock.atlassian.net/browse/PMC2022-256s
                            for(Tenants tnts : leaseRec.tenants){
                                if(tnts.tenantType == 'Primary') {
                                    l.Name = tnts.fName+' '+tnts.lName+' '+leaseRec.leaseStartDate+' '+leaseRec.leaseEndDate;
                                }
                            }
                            
                    		l.Yardi_Lease_Id__c = leaseRec.yardiLeaseHistoryHmy;
                    		if(String.isNotBlank(leaseRec.renewalStep)){
                            	l.Renewal_Step__c = leaseRec.renewalStep;
                            }
                    		if(leaseRec.renewalResidentSignedDate != null){
                            	l.Resident_Signed_Date__c = Date.ValueOf(leaseRec.renewalResidentSignedDate);
                            }
                    		if(leaseRec.renewalPmSignedDate != null){
                            	l.PM_Signed_Date__c = Date.ValueOf(leaseRec.renewalPmSignedDate);
                            }
                            updateLeasingRecordsList.add(l);
                            Boolean primaryonExistingLease = false;
                            for(Tenants tenRequest : leaseRec.tenants){
                                //if(tenantIdSet.contains(tenRequest.tenantId)){
                                    //for(Tenant__c ten : l.Tenant1__r){
                                        //if(tenRequest.tenantId ==Integer.ValueOf(ten.Tenent_Id__c)){
                                    if(mapTenantIdTenant.containsKey(Integer.valueOf(leaseRec.leaseId)+Integer.valueOf(tenRequest.tenantId))){
                                        	Tenant__c ten = mapTenantIdTenant.get(Integer.valueOf(leaseRec.leaseId)+Integer.valueOf(tenRequest.tenantId));
                                            ten.Name = tenRequest.fName+' '+tenRequest.lName;
                                            ten.Tenent_Id__c =  tenRequest.tenantId;
                                            ten.First_Name__c = tenRequest.fName;
                                            ten.Last_Name__c = tenRequest.lName;
                                            ten.Status__c = tenRequest.status;
                                            ten.Tenant_Type__c = tenRequest.tenantType;
                                            ten.Email__c = tenRequest.email;
                                            ten.Phone__c = tenRequest.phone;
                                            UpdateTenantRecordList.add(ten);
                                        //}
                                        
                                   // }
                                         }
                                //}
                                else{
                                    
                                    Tenant__c newTenantOnExistingLeasing = new Tenant__c();
                                    newTenantOnExistingLeasing.Name=tenRequest.fName+' '+tenRequest.lName;
                                    newTenantOnExistingLeasing.Tenent_Id__c = tenRequest.tenantId;
                                    newTenantOnExistingLeasing.First_Name__c = tenRequest.fName;
                                    newTenantOnExistingLeasing.Last_Name__c = tenRequest.lName;
                                    newTenantOnExistingLeasing.Status__c = tenRequest.status;
                                    newTenantOnExistingLeasing.Tenant_Type__c = tenRequest.tenantType;
                                    newTenantOnExistingLeasing.Email__c = tenRequest.email;
                                    newTenantOnExistingLeasing.Phone__c = tenRequest.phone;
                                    newTenantOnExistingLeasing.Lease__c = l.Id;
                                    if(primaryonExistingLease == false){
                                        newTenantOnExistingLeasing.Primary__c = true;
                                    }
                                    primaryonExistingLease = true;
                                    insertNewTenantOnExistingLeasing.add(newTenantOnExistingLeasing);
                                    
                                }
                            }
                      //  }
                    //}
                }
                
            //}
            /*
1. Create New Leasing Records
2. Create a Map of homecode and associated tenants list from the input/reqest string.
a. To create a new tenant record and associate it with the leasing record based on homecode.
*/
            else{
                System.debug('=Inside Else=');
                Lease__c newLeasing = new Lease__c();
                for(Tenants tnts : leaseRec.tenants){
                    if(tnts.tenantType == 'Primary') {
                        newLeasing.Name = tnts.fName+' '+tnts.lName+' '+leaseRec.leaseStartDate+' '+leaseRec.leaseEndDate;
                    }
                }
                newLeasing.Lease_Id__c = leaseRec.leaseId;
                newLeasing.Status__c = leaseRec.status;
                newLeasing.APPR_Status__c = leaseRec.apprStatus;
                if (leaseRec.isMonthToMonth <> null) {
                    newLeasing.isM2M__c = leaseRec.isMonthToMonth;
                }
                if(leaseRec.leaseStartDate!=null){
                    newLeasing.Lease_Start_Date__c = Date.ValueOf(leaseRec.leaseStartDate);
                }
                if (leaseRec.leaseSignedDate != null) {
                    newLeasing.Lease_Signed_Date__c = Date.ValueOf(leaseRec.leaseSignedDate);
                }

                newLeasing.Lease_End_Date__c = Date.ValueOf(leaseRec.leaseEndDate);
                //newLeasing.Home_Code__c = leaseRec.homeCode;
                if(homeCodePropertyMap.containsKey(leaseRec.homeCode)){
                    newLeasing.Property_Unit__c = homeCodePropertyMap.get(leaseRec.homeCode);
                }
                else{
                    //throw new CustomException('The Matching Home Code'+' '+ leaseRec.homeCode + ' '+ 'not found in Property Unit');
                }
                
                newLeasing.Total_Unpaid_Balance__c = leaseRec.balance;
                newLeasing.Current_Lease_Rent__c = leaseRec.rentAmount;
                newLeasing.Yardi_Lease_Id__c = leaseRec.yardiLeaseHistoryHmy;
                if(String.isNotBlank(leaseRec.renewalStep)){
                    newLeasing.Renewal_Step__c = leaseRec.renewalStep;
                }
                if(leaseRec.renewalResidentSignedDate != null){
                    newLeasing.Resident_Signed_Date__c = Date.ValueOf(leaseRec.renewalResidentSignedDate);
                }
                if(leaseRec.renewalPmSignedDate != null){
                    newLeasing.PM_Signed_Date__c = Date.ValueOf(leaseRec.renewalPmSignedDate);
                }
                System.debug('-newLeasing-'+newLeasing);
                insertNewLeasingRecorsList.add(newLeasing);
                //filteredNewHomeCodeTenantRecordsMap.put(leaseRec.homeCode,leaseRec.tenants);
                filteredNewHomeCodeTenantRecordsMap.put(leaseRec.homeCode+leaseRec.leaseId,leaseRec.tenants);
                
                
            }
        }
        updateLeasingRecordsSet.addAll(updateLeasingRecordsList);
        updateLeasingRecordsList.clear();
        updateLeasingRecordsList.addAll(updateLeasingRecordsSet);
        
        UpdateTenantRecordSet.addAll(UpdateTenantRecordList);
        UpdateTenantRecordList.clear();
        UpdateTenantRecordList.addAll(UpdateTenantRecordSet);
        
        if(updateLeasingRecordsList.size()>0){
            try{
                update updateLeasingRecordsList;
            }
            catch(Exception ex){
                System.debug('==Exceptio=='+ex);

            }
        }
        if(UpdateTenantRecordList.size()>0){
            try{
                // update UpdateTenantRecordList;
                Database.SaveResult[] result = Database.update(UpdateTenantRecordList, false);
                for(Database.SaveResult sr : result){
                    if(sr.isSuccess()){
                        system.debug('tenant updated successfully-1');
                    } else {
                        for(Database.error err : sr.getErrors()){
                            system.debug('error occured for record-1:'+err.getFields());
                            system.debug(err.getStatusCode()+' '+err.getMessage());
                            DebugLogHandler.logRestServiceException('RESTLeasingTenantsController','UpdateLease',err.getMessage(),
                                                                    err.getMessage(),JSON.serialize(leaseList)); 
                        }
                    }
                }
            }
            catch(Exception ex){
                System.debug('==Exceptio=='+ex);
            }
        }
        if(insertNewLeasingRecorsList.size()>0){
            try{
                insert insertNewLeasingRecorsList; 
            }
            catch(Exception ex){
                System.debug('==Exception=='+ex);
            }
        }
        if(insertNewTenantOnExistingLeasing.size()>0){
            try{
                // insert insertNewTenantOnExistingLeasing;
                Database.SaveResult[] result = Database.insert(insertNewTenantOnExistingLeasing, false);
                for(Database.SaveResult sr : result){
                    if(sr.isSuccess()){
                        system.debug('tenant updated successfully-2');
                    } else {
                        for(Database.error err : sr.getErrors()){
                            system.debug('error occured for record-2:'+err.getFields());
                            system.debug(err.getStatusCode()+' '+err.getMessage());
                            DebugLogHandler.logRestServiceException('RESTLeasingTenantsController','UpdateLease',err.getMessage(),
                                                                    err.getMessage(),JSON.serialize(leaseList)); 
                        }
                    }
                } 

            }
            catch(Exception Ex){
                System.debug('=Exception='+ex);
            }
        }
        System.debug('=filteredNewHomeCodeTenantRecordsMap='+filteredNewHomeCodeTenantRecordsMap);
        System.debug('=insertNewLeasingRecorsList='+insertNewLeasingRecorsList);
        List<Lease__c> newLeasingRecordsList = [select Id,Lease_Id__c,Property_Unit__r.HomeCode__c from Lease__c where Id IN:insertNewLeasingRecorsList];
        for(Lease__c lease :newLeasingRecordsList){
            System.debug('=homecode='+lease.Property_Unit__r.HomeCode__c);
            List<Tenants> filteredNewTenantList =filteredNewHomeCodeTenantRecordsMap.get(lease.Property_Unit__r.HomeCode__c+lease.Lease_Id__c);
            System.debug('=filteredNewTenantList='+filteredNewTenantList);
            Boolean primaryOnNewLease = false;
            for(Tenants newFilteredTenant : filteredNewTenantList){
                 
                Tenant__c newTenant = new Tenant__c();
                newTenant.Name =  newFilteredTenant.fName+' '+newFilteredTenant.lName;
                newTenant.Tenent_Id__c = newFilteredTenant.tenantId;
                newTenant.First_Name__c = newFilteredTenant.fName;
                newTenant.Last_Name__c = newFilteredTenant.lName;
                newTenant.Status__c = newFilteredTenant.status;
                newTenant.Tenant_Type__c = newFilteredTenant.tenantType;
                newTenant.Email__c = newFilteredTenant.email;
                newTenant.Phone__C = newFilteredTenant.phone;
                newTenant.Lease__c = lease.Id;
                if(primaryOnNewLease == false){
                    newTenant.Primary__c = true;
                }
                primaryOnNewLease = true;
                insertNewTenantRecords.add(newTenant);
                
            }
        }
        
        if(insertNewTenantRecords.size()>0){
            try{
                //insert insertNewTenantRecords;
                Database.SaveResult[] result = Database.insert(insertNewTenantRecords, false);
                for(Database.SaveResult sr : result){
                    if(sr.isSuccess()){
                        system.debug('tenant updated successfully-3');
                    } else {
                        for(Database.error err : sr.getErrors()){
                            system.debug('error occured for record-3:'+err.getFields());
                            system.debug(err.getStatusCode()+' '+err.getMessage());
                            DebugLogHandler.logRestServiceException('RESTLeasingTenantsController','UpdateLease',err.getMessage(),
                                                                    err.getMessage(),JSON.serialize(leaseList)); 
                        }
                    }
                }
            }
            catch(Exception ex){
                System.debug('==Exceptio=='+ex); 
            }
        }
        
        /* end   */
        List<Lease__c> leaseResList = new List<Lease__c>();
        Set<Lease__c> leaseResSet = new Set<Lease__c>();
        if(insertNewLeasingRecorsList.size()>0){
            leaseResList.addAll(insertNewLeasingRecorsList);
        }
        if(updateLeasingRecordsList.size()>0){
            leaseResList.addAll(updateLeasingRecordsList);
        }
        leaseResSet.addAll(leaseResList);
        leaseResList.clear();
        leaseResList.addAll(leaseResSet);
        for(Lease__c l:leaseResList){
            leaseResponseList.add(new ResponseBody(l.Lease_Id__c, l.id));     
        }       
        postResponse res = new postResponse(leaseResponseList);
        return res;
        
    }
    
}
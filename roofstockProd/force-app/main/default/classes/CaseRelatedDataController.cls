public class CaseRelatedDataController {
    @AuraEnabled(cacheable=true)
    public static List<SObject> getTenant(String caseId){
        List<String> emails = new List<String>();
        
        for(EmailMessage em :[SELECT FromAddress,ParentId FROM EmailMessage WHERE ParentId =: caseId]){
            emails.add(em.FromAddress);
        }
        
        List<SObject> display = new List<SObject>();
        List<Tenant__c> tenant = [SELECT Name, Email__c, Lease__c, createdDate From Tenant__c WHERE Email__c in : emails ORDER BY createdDate LIMIT 1];
        if(tenant.size() != 0){
            display.add(tenant[0]);
            //Lease__c should have Property_Unit__c as a required field in page layout
            Lease__c lease = [SELECT Name, Id,Property_Unit__c, Renewal_Opportunity__c From Lease__c WHERE Id =: tenant[0].Lease__c LIMIT 1];
            display.add(lease);
            
            Property_Unit__c property_unit = [Select Name, Id From Property_Unit__c WHERE Id =: lease.Property_Unit__c LIMIT 1];
            display.add(property_unit);
            
            System.debug('Tenant exists from case emails');
        }else{
            System.debug('Tenant does not exist from case emails');
            return null;
        }
        return display;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<SObject> getRelationRentalListingLLRU(String puId){
        List<SObject> display = new List<SObject>();
        List<Rental_Listing__c> rental_listing = [Select Name, Id From Rental_Listing__c WHERE Property_Unit__c =: puId
                                                  ORDER BY CreatedDate LIMIT 1];
        
        if(rental_listing.size() != 0){
            display.add(rental_listing[0]);
            List<Lead_Leasing_Rental_Unit__c> lead_leasing_rental_unit = [Select Name FROM Lead_Leasing_Rental_Unit__c WHERE Rental_Listing__c =: rental_listing[0].Id
                                                                          ORDER BY CreatedDate LIMIT 1];
            if(lead_leasing_rental_unit.size() != 0){
                display.add(lead_leasing_rental_unit[0]);
            }
        }
        
        return display;            
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getRelationOpportunity(String puId){
        
        List<Opportunity> opportunities = [Select Name,StageName,Sub_Stage__c,CloseDate FROM Opportunity WHERE Property_Unit__c =: puId
                                           ORDER BY CreatedDate LIMIT 1];
        return opportunities;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Tenant__c> getTenantList(String tenantId, String leaseId,Integer offset, Integer limitSize){
        string keyTenantId = '%'+tenantId+'%';
        
        list<Tenant__c> tenantRecord = [Select Id, Name,Email__c,Phone__c,Status__c
                                     From Tenant__c
                                        WHERE (Lease__c =: leaseId AND
                                        Id != :tenantId)
                                     LIMIT : limitSize
                                     OFFSET : offset
                                    ];
        
        if(tenantRecord.size() == 0){
            throw new AuraHandledException('No Record Found...'); 
        }
        
        return tenantRecord;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Lease__c> getLeaseList(String tenantId,Integer offset, Integer limitSize){
        
        list<Lease__c> leaseRecord = [Select Id, Name,Lease_Start_Date__c,Lease_End_Date__c,Lease_Signed_Date__c,APPR_Status__c,Renewal_Step__c
                                     From Lease__c
                                     WHERE Id IN 
                                      (Select Lease__c
                                       From Tenant__c
                                       WHERE Id = :tenantId)
                                     LIMIT : limitSize
                                     OFFSET : offset
                                    ];
        
        if(leaseRecord.size() == 0){
            throw new AuraHandledException('No Record Found...'); 
        }
        
        return leaseRecord;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunityList(String puId, Integer offset, Integer limitSize){
        
        list<Opportunity> opportunityRecord = [Select Name, StageName,Sub_Stage__c,CloseDate, Tenant_Status__c 
                           FROM Opportunity 
                           WHERE Property_Unit__c =: puId
                           ORDER BY CreatedDate
                           LIMIT : limitSize
                           OFFSET : offset];
        
        if(opportunityRecord.size() == 0){
            throw new AuraHandledException('No Record Found...'); 
        }
        
        return opportunityRecord;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Rental_Listing__c> getRentalListingList(String puId, Integer offset, Integer limitSize){
        System.debug(puId);
        
        list<Rental_Listing__c> rlRecord = [Select Name
                           FROM Rental_Listing__c 
                           WHERE Property_Unit__c =: puId
                           ORDER BY CreatedDate
                           LIMIT : limitSize
                           OFFSET : offset];
        
        if(rlRecord.size() == 0){
            throw new AuraHandledException('No Record Found...'); 
        }
        
        return rlRecord;
    }
    @AuraEnabled(cacheable=true)
    public static List<Lead_Leasing_Rental_Unit__c> getLeadLeasingRentalUnitList(String rlId, Integer offset, Integer limitSize){
        
        list<Lead_Leasing_Rental_Unit__c> llruRecord = [Select Name
                           FROM Lead_Leasing_Rental_Unit__c 
                           WHERE Rental_Listing__c =: rlId
                           ORDER BY CreatedDate
                           LIMIT : limitSize
                           OFFSET : offset];
        
        if(llruRecord.size() == 0){
            throw new AuraHandledException('No Record Found...'); 
        }
        
        return llruRecord;
    }
    
}
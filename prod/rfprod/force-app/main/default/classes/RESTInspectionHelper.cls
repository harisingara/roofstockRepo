global with sharing class RESTInspectionHelper {
    
    global class InspectionData {
        global List<InspectionRequest> inspectionList;
    }

    global class InspectionRequest {
        global String entityId;  // PMC-347
        global String sourceId;
        global String source;
        global String propertyId;
        global String UnitId;
        global String name;
        global String createdByEmail;
        global String accessType;
        global String propertyAccessNotes;
        global String status;
        global String type;
        global String inspectionAccountId;
        global String inspectionAccountName;
        global Date scheduledInspectionDate;
        global String scheduledInspectionTime;
        global String scheduledNotes;
        global String residentialInformation;
        global String photographerInformation;
        global String inspectorsInformation;
        global Decimal estimatedCapexManual;
        global Decimal estimatedRentUW;
        global Decimal inspectedBedRooms;
        global Decimal inspectedBathRooms;
        global Decimal inspectedSquareFeet;
        global Decimal inspectedEstimatedCost;
        global Decimal bpmRenovationCost;
    }

    global class PostResponse {
        global ResponseWrapper responseBody;
        global PostResponse(List<ResponseBody> inspectionResponse) {
            this.responseBody = new ResponseWrapper(inspectionResponse);
        }
    }
     
    global class ResponseWrapper {  
        global List<ResponseBody> inspectionResponse;  
        /*global ResponseWrapper(){
            inspectionResponse = new List<ResponseBody>();
        }*/
        global ResponseWrapper(List<ResponseBody> inspectionResponse) {
            this.inspectionResponse = inspectionResponse;
        }
    }  
     
    global class ResponseBody{
        global String sourceId;
        global String salesforceId;
        global String status;
 
        global ResponseBody(String sourceId, String salesforceId,String status) {
            this.sourceId = sourceId;
            this.salesforceId = salesforceId;
            this.status = status;
        }
    }

    global static PostResponse UpsertInspection(List<InspectionRequest> inspectionList) {
        Set<string> userEmails = new Set<string>();
        Set<string> homeCodes = new Set<string>();
        Set<Integer> inspectionIdSet = new Set<Integer>(); 
        Set<String> propertyIds = new Set<String>();
        Set<String> unitIds = new Set<String>();
        Set<String> insAccountIds = new Set<String>();
        Set<String> insAccountNames = new Set<String>();
        Set<String> entityIds = new Set<String>(); // PMC-347
        Map<string, id> propIdsMap = new Map<string,id>();
        Map<string, id> propUnitIdsMap = new Map<string,id>();
        Map<string, id> userMap = new Map<string,id>();
        Map<String, String> insacctIdsMap = new Map<String, String>();
        Map<String, Id> inspectionActIdmap = new Map<String, Id>();
        Map<String, String> inspectionActNameIdmap = new Map<String, String>();
        Map<String, Id> transIdsMap = new Map<String, Id>(); //PMC-347
        List<Account> inspectionAccountUpdate = new List<Account>();
        List<Account> inspectionAccountInsert = new List<Account>();
        List<ResponseBody> inspectionResponseList = new List<ResponseBody>();

        //find user ids for email
        for (InspectionRequest inspection : inspectionList) {
            if(inspection.createdByEmail <> null && inspection.createdByEmail <> '' && !userEmails.contains(inspection.createdByEmail)){
                userEmails.add(inspection.createdByEmail);
            }
            if (null <> inspection.propertyId && '' <> inspection.propertyId && !propertyIds.contains(inspection.propertyId)) {
                propertyIds.add(inspection.propertyId);
            }
            if (null <> inspection.unitId && '' <> inspection.unitId && !unitIds.contains(inspection.unitId)) {
                unitIds.add(inspection.unitId);
            }
            if (null <> inspection.inspectionAccountId && '' <> inspection.inspectionAccountId) {
                insAccountIds.add(inspection.inspectionAccountId);
                insAccountNames.add(inspection.inspectionAccountName);
                inspectionActNameIdmap.put(inspection.inspectionAccountName, inspection.inspectionAccountId);
            }
        //  PMC-347
            if(inspection.entityId <> null && inspection.entityId <> ''){
                entityIds.add(inspection.entityId);
            }
        }

        if (userEmails.size() > 0) {
            for (User usr : [select id, email from User where email in :userEmails]) {
                userMap.put(usr.email, usr.id);
            }
        }

        if (propertyIds.size() > 0) {
            for (Property2__c prop : [select id, PropertyId__c from Property2__c where PropertyId__c in :propertyIds]) {
                propIdsMap.put(prop.PropertyId__c, prop.id);
            }
        }

        if (unitIds.size() > 0) {
            for (Property_Unit__c propUnit : [select id, PropertyUnitId__c from Property_Unit__c where PropertyUnitId__c in :unitIds]) {
                propUnitIdsMap.put(propUnit.PropertyUnitId__c, propUnit.id);
            }
        }
    //  PMC-347
        if (entityIds.size() > 0){
            for (Transaction__c trans : [SELECT id, name, Transaction_Id__c FROM Transaction__c where Transaction_Id__c IN :entityIds]) {
                transIdsMap.put(trans.Transaction_Id__c, trans.id);
            }

        }

        if (insAccountIds.size() > 0) {
            for (Account act : [SELECT Id, Roofstock_Account_ID__c 
                                  FROM Account 
                                 WHERE Recordtype.name = 'Vendor' and service_type__c = 'Home Inspection' and
                                       Roofstock_Account_ID__c IN :insAccountIds]) {
                inspectionActIdmap.put(act.Roofstock_Account_ID__c, act.Id);
            }
        }

        if (insAccountNames.size() > 0) {
            for (Account act : [SELECT Id, Roofstock_Account_ID__c, Name 
                                  FROM Account 
                                 WHERE Recordtype.name = 'Vendor' and service_type__c = 'Home Inspection' and
                                       Name IN :insAccountNames and Roofstock_Account_ID__c = null]) {
                inspectionActIdmap.put(inspectionActNameIdmap.get(act.name), act.Id);
                inspectionAccountUpdate.add(new Account(Id=act.Id, Roofstock_Account_ID__c=inspectionActNameIdmap.get(act.name)));
            }
        }

        Id actVendorRecTypId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        Set<String> insActids = new Set<String>();
        for (InspectionRequest ins : inspectionList) {
            if (!inspectionActIdmap.containskey(ins.inspectionAccountId) && !insActids.contains(ins.inspectionAccountId) && 
                ins.inspectionAccountId <> null && ins.inspectionAccountId <> '') {
                inspectionAccountInsert.add(new Account(Roofstock_Account_ID__c=ins.inspectionAccountId, Name=ins.inspectionAccountName,
                                                        RecordtypeId=actVendorRecTypId, service_type__c='Home Inspection'));
                insActids.add(ins.inspectionAccountId);
            }
        }

        if (null <> inspectionAccountInsert && inspectionAccountInsert.size() > 0) {
            if (inspectionAccountInsert.size() > 0) {
                Insert inspectionAccountInsert;
            }

            for (Account act: inspectionAccountInsert) {
                inspectionActIdmap.put(act.Roofstock_Account_ID__c, act.Id);
            }
        }

        //upsert inspection record
        List<Inspection__c> inspections = new List<Inspection__c>();
        for (InspectionRequest ins : inspectionList) {
            Inspection__c rec = new Inspection__c();
            rec.Dilligence_Id__c = ins.sourceId;
            rec.Source__c = ins.source;
            rec.Property__c = getValueForKey(propIdsMap, ins.propertyId);
            rec.Property_unit__c = getValueForKey(propUnitIdsMap, ins.unitId);
            rec.Name = ins.name;
            rec.Created_By__C = getValueForKey(userMap, ins.createdByEmail);
            rec.Access_Type__c = ins.accessType;
            rec.Access_Notes__c = ins.propertyAccessNotes;
            rec.Inspection_Status__c = ins.status;
            rec.Inspection_Type__c = ins.type;
            rec.Inspection_Account__c = inspectionActIdmap.get(ins.inspectionAccountId);
            rec.Inspection_Scheduled_Date__c =  ins.scheduledInspectionDate;
            rec.Inspection_Scheduled_Time__c = ins.scheduledInspectionTime;
            rec.Scheduled_Notes__c = ins.scheduledNotes;
            rec.Residential_Information__c = ins.residentialInformation;
            rec.Photographer_Information__c = ins.photographerInformation;
            rec.Inspectors_Information__c = ins.inspectorsInformation;
            rec.Estimated_Capex_Manual__c = ins.estimatedCapexManual;
            rec.Estimated_Rent_UW__c = ins.estimatedRentUW;
            rec.Inspected_Square_Feet__c = ins.inspectedSquareFeet;
            rec.Inspected_Bedrooms__c = ins.inspectedBedRooms;
            rec.Inspected_Bathrooms__c = ins.inspectedBathRooms;
            rec.Estimated_Inspection_Cost__c = ins.inspectedEstimatedCost;
            rec.Bpm_Renovation_Cost__c = ins.bpmRenovationCost;
            rec.Transaction__c = getValueForKey(transIdsMap, ins.entityId);  // PMC-347
            if (ins.source == 'BPM')
                rec.BPM_Inspection_Id__c = (ins.sourceId.contains(' | ')?(ins.sourceId.split(' | ')[0]).trim():ins.sourceId);
            inspections.add(rec);
        }
        
        //upsert Inspection sourceId
        List<Inspection__c> createdInspectionList = new List<Inspection__c>();
        List<Inspection__c> updatedInspectionList = new List<Inspection__c>();
         
        Database.UpsertResult[] inspectionsResults = Database.upsert(inspections, Inspection__c.Dilligence_Id__c);
        system.debug('check'+inspectionsResults);

        for(Integer i = 0; i < inspectionsResults.size(); i++) {
            if(inspectionsResults[i].isSuccess()) {
                if(inspectionsResults[i].isCreated()) {
                    createdInspectionList.add(inspections[i]);
                } else {
                    updatedInspectionList.add(inspections[i]);
                }
            }
        }
         
        if(!createdInspectionList.isEmpty()){
            for (Inspection__c inspection : createdInspectionList) {
               inspectionResponseList.add(new ResponseBody(inspection.Dilligence_Id__c, inspection.id,'Created'));
            }
        }
        if(!updatedInspectionList.isEmpty()){
            for (Inspection__c inspection : updatedInspectionList) {
               inspectionResponseList.add(new ResponseBody(inspection.Dilligence_Id__c, inspection.id,'Updated'));
            }
        }

        postResponse res = new postResponse(inspectionResponseList);
        return res;
    }

    global static Id getValueForKey(Map<string, id> keyValMap, String key) {
        Id ret = null;
        if (key <> null && '' <> key && null <> keyValMap && 
            keyValMap.size() > 0 && keyValMap.containskey(key)) {
            ret = keyValMap.get(key);
        }
        return ret;
    }
}
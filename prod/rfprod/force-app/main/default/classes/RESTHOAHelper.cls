global with sharing class RESTHOAHelper {
    
    global class HOAWrap{
        global List<HOA> hoaList;
    }

    global class HOA{
        global String certificationId;
        global String propertyId;
        global Boolean hasHOA;
        global Boolean hasRentalRestriction;
        global String rentalRestrictionNotes;
        global String hoaAmount;
        global String hoaPaymentTerm;
        global String hoaBalance;
        global Boolean isHoaFeePaid;
        global Boolean hasTitleTransferFee;
        global String titleTransferAmount;
        global Boolean isHoaLimitOnInvestorOwnedUnits;
        global String numberOfInvestorOwnedUnitsInHoa;
        global Boolean hasAnyViolations;
        global String violationNotes;
        global Boolean hasAnyCapitalContributions;
        global String capitalContributionAmount;
        global String diligenceReviewUrl;
        global HOAContact contact;
    }

    global class HOAContact{
        global String bpmContactId;
        global String rsAccountId;
        global String roofstockUserId;
        global String type;
        global String email;
        global String mobile;
        global String firstName;
        global String lastName;
        global String companyName;
    }

    global class PostResponse {
        global ResponseWrapper responseBody;
        global PostResponse(List<ResponseBody> hoaResponse) {
            this.responseBody = new ResponseWrapper(hoaResponse);
        }
    }

    global class ResponseWrapper {  
        global List<ResponseBody> hoaResponse;  
        global ResponseWrapper(){
            hoaResponse = new List<ResponseBody>();
        }
        global ResponseWrapper(List<ResponseBody> hoaResponse) {
            this.hoaResponse = hoaResponse;
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

    global static PostResponse upsertHOA(List<HOA> hoaList) {

        List<HOA__c> upsertHoa = new List<HOA__c>();
        List<ResponseBody> hoaResponseList = new List<ResponseBody>();
        
        Map<String, HOAContact> rsAccountIdMap = new Map<String, HOAContact>();
        Map<String, HOAContact> bpmContactIdMap = new Map<String, HOAContact>();
        Set<String> existingRsAccountId = new Set<String>();
        Set<String> existingBpmContactId = new Set<String>();
        Map<String, Id> rsAccountIdSFDCIdMap = new Map<String, Id>();
        Map<String, Id> bpmContactIdSFDCIdMap = new Map<String, Id>();
        Map<String, Id> bpmCertificationIdMap = new Map<String, Id>();
        Map<String, Id> propertyIdMap = new Map<String, Id>();
        Map<String, String> propertyIdNameMap = new Map<String, String>();
        List<String> vendorCompany =  new List<String>();
        List<String> vendorContact = new List<String>();

        Id hoaAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HOA').getRecordTypeId();
        Id hoaContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('HOA').getRecordTypeId();

        for(HOA hoa : hoaList) {
            if (hoa.contact <> null && hoa.contact.rsAccountId <> null) {
                rsAccountIdMap.put(hoa.contact.rsAccountId, hoa.contact);
            }
            if (hoa.contact <> null && hoa.contact.bpmContactId <> null) {
                bpmContactIdMap.put(hoa.contact.bpmContactId, hoa.contact);
            }
            if (hoa.certificationId <> null) {
                bpmCertificationIdMap.put(hoa.certificationId, null);
            }
            if (hoa.propertyId <> null) {
                propertyIdMap.put(hoa.propertyId, null);
            }
            if(hoa.contact <> null && hoa.contact.companyName != null && hoa.contact.companyName != '') {
                vendorCompany.add(hoa.contact.companyName.toLowerCase());
            }
            if((hoa.contact <> null && hoa.contact.firstName != null && hoa.contact.firstName != '') || (hoa.contact <> null && hoa.contact.lastName != null && hoa.contact.lastName != '')) {
                String name = hoa.contact.firstName+' '+hoa.contact.lastName;
                vendorContact.add(name.toLowercase());
            }
        }

        // Properties
        if (null <> propertyIdMap && propertyIdMap.size() > 0) {
            for (Property2__c prop : [select id, PropertyId__c, Name from Property2__c where PropertyId__c IN :propertyIdMap.keyset()]) {
                propertyIdMap.put(prop.PropertyId__c, prop.Id);
                propertyIdNameMap.put(prop.PropertyId__c, 'HOA - ' + prop.Name);
            }
        }

        // Certifications
        if (null <> bpmCertificationIdMap && bpmCertificationIdMap.size() > 0) {
            for (Certification__c cert : [select id, BPM_Certification_Id__c from Certification__c where BPM_Certification_Id__c IN :bpmCertificationIdMap.keyset()]) {
                bpmCertificationIdMap.put(cert.BPM_Certification_Id__c, cert.Id);
            }
        }

        // Account
        for (Vendor__c act : [SELECT Id, Name, Vendor_Code__c 
                              FROM Vendor__c 
                             WHERE name IN :vendorCompany and Type__c = 'HOA Company']) {
            existingRsAccountId.add(act.Vendor_Code__c);
            rsAccountIdSFDCIdMap.put(act.Name.toLowerCase(), act.Id);
        }

        List<Vendor__c> insertHoaAccount = new List<Vendor__c>();

        for (String rsActId : rsAccountIdMap.keySet()) {
            String comName = rsAccountIdMap.get(rsActId).companyName;
            if (!rsAccountIdSFDCIdMap.containskey(comName.toLowerCase())) {
                insertHoaAccount.add(new Vendor__c(Name=rsAccountIdMap.get(rsActId).companyName, Vendor_Code__c=rsActId, Type__c = 'HOA Company',Service_Type__c = 'HOA'));
            }
        }

        if (null <> insertHoaAccount) {
            Database.SaveResult[] result = Database.insert(insertHoaAccount, false);
            system.debug('BPM Account ::'+result);
        }

        for (Vendor__c act : insertHoaAccount) {
            rsAccountIdSFDCIdMap.put(act.Name.toLowerCase(), act.Id);
        }

        // Contact
        for (Vendor__c cnct : [SELECT Id, Name, Vendor_Code__c 
                               FROM Vendor__c 
                              WHERE name IN :vendorContact and Type__c = 'HOA Company Contact']) {
            existingBpmContactId.add(cnct.Vendor_Code__c);
            bpmContactIdSFDCIdMap.put(cnct.Name.toLowerCase(), cnct.Id);
        }

        List<Vendor__c> insertHoaContact = new List<Vendor__c>();

        for (String bpmCnctId : bpmContactIdMap.keySet()) {
            String cName = bpmContactIdMap.get(bpmCnctId).firstName +' '+ bpmContactIdMap.get(bpmCnctId).lastName;
            if (!bpmContactIdSFDCIdMap.containskey(cName.toLowerCase())) {
                insertHoaContact.add(new Vendor__c(Name=bpmContactIdMap.get(bpmCnctId).firstName +' '+ bpmContactIdMap.get(bpmCnctId).lastName,
                                                 Email__c =bpmContactIdMap.get(bpmCnctId).email, Phone__c=bpmContactIdMap.get(bpmCnctId).mobile,
                                                 Vendor_Code__c=bpmCnctId, Type__c = 'HOA Company Contact',Service_Type__c = 'HOA'));
            }
        }

        if (null <> insertHoaContact) {
            Database.SaveResult[] result = Database.insert(insertHoaContact, false);
            system.debug('BPM contact ::'+result);
        }

        for (Vendor__c cnct : insertHoaContact) {
            bpmContactIdSFDCIdMap.put(cnct.Name.toLowerCase(), cnct.Id);
        }

        // Create HOA record
        HOA__c hoaRec;
        String contactName;
        for(HOA hoa : hoaList) {
            if((hoa.contact <> null && hoa.contact.firstName != null && hoa.contact.firstName != '') || (hoa.contact<> null && hoa.contact.lastName != null && hoa.contact.lastName != '')) {
                contactName = hoa.contact.firstName+' '+hoa.contact.lastName;
                
            }
            hoaRec = new HOA__c();
            hoaRec.hoa_id__C = hoa.certificationId;
            hoaRec.Name = null<>hoa.propertyId?propertyIdNameMap.get(hoa.propertyId):hoa.certificationId;
            hoaRec.Certification__c = null<>hoa.certificationId?bpmCertificationIdMap.get(hoa.certificationId):null;
            hoaRec.Property__c = null<>hoa.propertyId?propertyIdMap.get(hoa.propertyId):null;
            hoaRec.HOA_Company1__c = null<>hoa.contact&&null<>hoa.contact.companyName&&rsAccountIdSFDCIdMap.containskey(hoa.contact.companyName.toLowerCase())?rsAccountIdSFDCIdMap.get(hoa.contact.companyName.toLowerCase()):null;
            hoaRec.HOA_Company_Contact1__c = null<>hoa.contact&& bpmContactIdSFDCIdMap.containskey(contactName.toLowerCase())?bpmContactIdSFDCIdMap.get(contactName.toLowerCase()):null;
            hoaRec.Has_Rental_restriction__c = hoa.hasRentalRestriction;
            hoaRec.Rental_Restriction_Notes__c = hoa.rentalRestrictionNotes;
            hoaRec.Assessment_Amount__c = null<>hoa.hoaAmount?Decimal.ValueOf(hoa.hoaAmount):null;
            hoaRec.Billing_Frequency__c = hoa.hoaPaymentTerm;
            hoaRec.Assessment_Balance__c = null<>hoa.hoaBalance?Decimal.ValueOf(hoa.hoaBalance):null;
            hoaRec.Is_Assessment_Amount_paid__C = hoa.isHoaFeePaid;
            hoaRec.Has_Title_Transfer_Fee__c = hoa.hasTitleTransferFee;
            hoaRec.Title_Transfer_Amount__c = null<>hoa.titleTransferAmount?Decimal.ValueOf(hoa.titleTransferAmount):null;
            hoaRec.Is_Hoa_Limit_On_Investor_Owned_Units__c = hoa.isHoaLimitOnInvestorOwnedUnits;
            hoaRec.Number_Of_Investor_Owned_Units_In_Hoa__c = hoa.numberOfInvestorOwnedUnitsInHoa;
            hoaRec.Has_Violation_On_Purchase__c = hoa.hasAnyViolations;
            hoaRec.Violation_Notes_On_Purchase__c = hoa.violationNotes;
            hoaRec.Has_Any_Capital_Contributions__c = hoa.hasAnyCapitalContributions;
            hoaRec.Capital_Contribution_Amount__C = null<>hoa.capitalContributionAmount?Decimal.ValueOf(hoa.capitalContributionAmount):null;
            hoaRec.BPM_Document_URL__c = hoa.diligenceReviewUrl;
            hoaRec.No_HOA__c = !hoa.hasHOA;
            upsertHoa.add(hoaRec);
        }

        // Build response
        List<HOA__c> createdHoaList = new List<HOA__c>();
        List<HOA__c> updatedHoaList = new List<HOA__c>();
        
        system.debug('Mango'+upsertHoa);
        Database.UpsertResult[] hoaResults = Database.upsert(upsertHoa, HOA__C.HOA_Id__c);
        system.debug('check'+hoaResults);

        for(Integer i = 0; i < hoaResults.size(); i++) {
            if(hoaResults[i].isSuccess()) {
                if(hoaResults[i].isCreated()) {
                    createdHoaList.add(upsertHoa[i]);
                } else {
                    updatedHoaList.add(upsertHoa[i]);
                }
            }
        }
         
        if(!createdHoaList.isEmpty()){
            for (HOA__c hoa : createdHoaList) {
                hoaResponseList.add(new ResponseBody(hoa.HOA_Id__c, hoa.id,'Created'));
            }
        }
        if(!updatedHoaList.isEmpty()){
            for (HOA__c hoa : updatedHoaList) {
                hoaResponseList.add(new ResponseBody(hoa.HOA_Id__c, hoa.id,'Updated'));
            }
        }

        PostResponse resp = new PostResponse(hoaResponseList);
        return resp;
    }
}
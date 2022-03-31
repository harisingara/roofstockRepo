global class RESTCertificationHelper {
    global class certificationsWrap{
        global List<Certifications> certificationList;
    }
    global class Certifications{
        global String name;
        global String certificationId;
        //global String propertyRiid;
        global String propertyId;
       /* global String sellerContactId;
        global String inspectorContactId;
        global String sellerPmContactId;
        global String titleContactId;
        global String hoaContactId;
        global String rsListingAgentContactId;*/
        global String rsAccountExecutiveEmail;
        global String rsAccountManagerEmail;
        global String rsAccountCoordinatorEmail;
        global String certificationStatus;
        global String certificationStartDate;
        global String estPublishedDate;
        global String publishDate;
        global String listingSource;
        global String saleType;
        global String listingAddendumStatus;
        global String createdDate;
        global String completedDate;
        global Boolean isInspectionPass;
        global String reasonCertificationFail;
        global List<RESTContactHelper.Contacts> contactsList;
    }
    
    global class PostResponse {
        global ResponseWrapper responseBody;
        global PostResponse(List<ResponseBody> certificationResponse) {
            this.responseBody = new ResponseWrapper(certificationResponse);
        }
    }
    global class ResponseWrapper {  
        global List<ResponseBody> certificationResponse;  
        global ResponseWrapper(){
            certificationResponse = new List<ResponseBody>();
        }
        global ResponseWrapper(List<ResponseBody> certificationResponse) {
            this.certificationResponse = certificationResponse;
        }
    } 
    global class ResponseBody{
        global String certificationId;
        global String salesforceId;
        global ResponseBody(String certificationId, String salesforceId) {
            this.certificationId = certificationId;
            this.salesforceId = salesforceId;
        }
    }
    global static PostResponse UpdateCertification(List<Certifications> certificationList) {
        List<ResponseBody> certificationResponseList = new List<ResponseBody>();
        Set<String> userEmailSet = new Set<String>();
        Set<String> certificationIdSet = new Set<String>();  
        Set<String> propertyIdSet = new Set<String>();
        Set<String> contactIds = new Set<String>();
        
        Map<String,String> rsInstancePropertyMap = new Map<String,String>();
        Map<String,String> rsInstancePropertyNameMap = new Map<String,String>();
        Map<String,String> bpmContactIdMap = new Map<String,String>();
        
        Map<String, RESTContactHelper.Contacts> allContactListMap = new Map<String, RESTContactHelper.Contacts>();
        RESTContactHelper.PostResponse conResponse;
        List<RESTContactHelper.ResponseBody> conRespBody = new List<RESTContactHelper.ResponseBody>();
        
        for(Certifications cert :certificationList){
            //Get Emails from the input string for users
            userEmailSet.add(cert.rsAccountExecutiveEmail);
            userEmailSet.add(cert.rsAccountManagerEmail);
            userEmailSet.add(cert.rsAccountCoordinatorEmail);
            //Get Contact Ids from input string
           /* contactIds.add(cert.sellerContactId);
            contactIds.add(cert.inspectorContactId);
            contactIds.add(cert.sellerPmContactId);
            contactIds.add(cert.titleContactId);
            contactIds.add(cert.hoaContactId);
            contactIds.add(cert.rsListingAgentContactId);*/
            //Get Certification Id's
            certificationIdSet.add(cert.certificationId);
            //Get Property Id
            propertyIdSet.add(cert.propertyId);
            
            for(RESTContactHelper.Contacts conWrap : cert.contactsList){
                allContactListMap.put(conWrap.bpmContactId, conWrap);
            }
            
        }
        // remove blanks and nulls
        contactIds.remove('');
        contactIds.remove(null);
       
        if(allContactListMap.size() > 0 ){
            conResponse = RESTContactHelper.UpdateContact(allContactListMap.values());
            if(conResponse != null && conResponse.responseBody != null){
                RESTContactHelper.ResponseWrapper respWrap = conResponse.responseBody;
                conRespBody = respWrap.contactResponse;
                for(RESTContactHelper.ResponseBody res: conRespBody){
                  contactIds.add(res.bpmContactId);  
                }
            }
        }
        
         //Query for matching property and create a map of RoofstockInstanceId and Property
        List<Property2__c> matchingPropertyList = [select Id,Name,PropertyId__c from Property2__c where PropertyId__c IN:propertyIdSet];

        System.debug('=matchingPropertyList='+matchingPropertyList);
        for(Property2__c ppt :matchingPropertyList){
            rsInstancePropertyMap.put(ppt.PropertyId__c,ppt.Id);
            rsInstancePropertyNameMap.put(ppt.PropertyId__c,ppt.Name);
        }
        System.debug('=rsInstancePropertyMap='+rsInstancePropertyMap);
        System.debug('=rsInstancePropertyNameMap='+rsInstancePropertyNameMap);

        //Query for the matching Contacts and create a map BPM Contact Id and Contact Id.
       
        List<Contact> matchingContactList = [select Id,BPM_Contact_Id__c,Email,Phone from Contact where (BPM_Contact_Id__c IN:contactIds)];
        
        if(matchingContactList.size()>0){
            for(Contact con:matchingContactList){
                bpmContactIdMap.put(con.BPM_Contact_Id__c,con.Id);
            }
        }
        System.debug('=bpmContactIdMap='+bpmContactIdMap);
        //Query for the matching Users and create a map of email and UserId
        Map<String,String> emailUserMap = new Map<String,String>();
        List<User> matchingUserList = [select Id,Email from User where Email IN:userEmailSet];
        if(matchingUserList.size()>0){
            for(User usr:matchingUserList){
                emailUserMap.put(usr.Email,usr.Id);
            }
        }
        System.debug('=emailUserMap='+emailUserMap);
        //Query for existing transaction Id's and Create a map of transaction Id and Transactiion Record
        Map<String,Certification__c> certificationIdCertificationMap = new Map<String,Certification__c>();
        List<Certification__c> existingCertifications = [select Id,BPM_Certification_Id__c,Name,Certification_Start_Date__c,
                                                         Certification_Status__c,Est_Publish_Date__c,HOA_Contact__c,
                                                         Inspection_Company_Contact__c,List_Price__c,Listing_Addendum_Status__c,
                                                         Listing_Source__c,Listing_Status__c,Property__c,Publish_Date__c,
                                                         Roofstock_Account_Coordinator__c,Roofstock_Account_Executive__c,
                                                         Roofstock_Account_Manager__c,Roofstock_Listing_Agent_Contact__c,
                                                         SaleType__c,Seller_Contact__c,Seller_PM_Contact__c,Title_Company_Contact__c,
                                                         Seller_Contact_Id__c,Seller_PM_Contact_Id__c,Inspector_Company_Contact_Id__c,
                                                         Title_Company_Contact_Id__c,HOA_Contact_Id__c,Roofstock_Listing_Agent_Contact_Id__c,
                                                         Property_Id__c from Certification__c where BPM_Certification_Id__c IN:certificationIdSet];
        
        if(existingCertifications.size()>0){
            for(Certification__c existingCertificate:existingCertifications){
                certificationIdCertificationMap.put((existingCertificate.BPM_Certification_Id__c),existingCertificate);
            }
        }
        //Update Existing transaction/Create a new Transaction
        List<Certification__c> certificationToUpsert = new List<Certification__c>();
        Certification__c certif;
       // List<Certification__c> updateExistingCertification = new List<Certification__c>();
        for(Certifications inputCertification : certificationList){
            
            certif = certificationIdCertificationMap.containsKey(inputCertification.certificationId) ? certificationIdCertificationMap.get(inputCertification.certificationId) : new Certification__c();
            Certification__c updatedCertification = createUpdateCertification(certif,inputCertification,emailUserMap,bpmContactIdMap,rsInstancePropertyMap,rsInstancePropertyNameMap);
            certificationToUpsert.add(updatedCertification);   
            
           /* if(certificationIdCertificationMap.containsKey(inputCertification.certificationId)){
                Certification__c existingCertification = certificationIdCertificationMap.get(inputCertification.certificationId);
                 updateExistingCertification.add(updatedCertification);
            }
            else{
                Certification__c newCertification = new Certification__c();
                Certification__c newCreatedCertification = createUpdateCertification(newCertification,inputCertification,emailUserMap,bpmContactIdMap,rsInstancePropertyMap,rsInstancePropertyNameMap);
                createNewCertification.add(newCreatedCertification);
            }*/
            
        }
        
        if(certificationToUpsert.size()>0){
            upsert certificationToUpsert BPM_Certification_Id__c ;
        }
        /*if(createNewCertification.size()>0){
            insert createNewCertification;
        }
        //Logic to dedupe records
        updateExistingCertification.addAll(createNewCertification);
        set<Certification__c> dedupeCertificationSet = new set<Certification__c>();
        dedupeCertificationSet.addAll(updateExistingCertification);
        updateExistingCertification.clear();
        updateExistingCertification.addAll(dedupeCertificationSet);*/
        
        for(Certification__c cert:certificationToUpsert){
            certificationResponseList.add(new ResponseBody(cert.BPM_Certification_Id__c, cert.id));     
        }
        postResponse res = new postResponse(certificationResponseList);
        return res;
    }
    global static Certification__c createUpdateCertification(Certification__c contextCertification,Certifications inputCertification,Map<String,String> emailUserMap,Map<String,String> bpmContactIdMap,Map<String,String> rsInstancePropertyMap,Map<String,String> rsInstancePropertyNameMap){
        System.debug('=rsInstancePropertyNameMap='+rsInstancePropertyNameMap);
        //Assign Property and Name
        Boolean namePopulated = false;
        if(inputCertification.name!=null){
        	contextCertification.Name = inputCertification.name;   
            namePopulated = true;
        }
        
        if(inputCertification.propertyId!=null){
            contextCertification.Property_Id__c = inputCertification.propertyId;
            if(rsInstancePropertyMap.get(inputCertification.propertyId)!=null){
                contextCertification.Property__c = rsInstancePropertyMap.get(inputCertification.propertyId);
            }
            if(rsInstancePropertyNameMap.get(inputCertification.propertyId)!=null && namePopulated == false){
                System.debug('=propertyId='+inputCertification.propertyId);
                contextCertification.Name = rsInstancePropertyNameMap.get(inputCertification.propertyId);
            }
        }

        //Assign Contacts
        //
         for(RESTContactHelper.Contacts con : inputCertification.contactsList){
            if(con.type != null &&  con.type.equalsignoreCase('Seller')){
                contextCertification.Seller_Contact_Id__c = con.bpmContactId;
                contextCertification.Seller_Contact__c = bpmContactIdMap.get(con.bpmContactId);
            }
             
            if(con.type != null &&  con.type.equalsignoreCase('Inspector')){
                contextCertification.Inspector_Company_Contact_Id__c = con.bpmContactId;
                contextCertification.Inspection_Company_Contact__c = bpmContactIdMap.get(con.bpmContactId);
            }
             
            if(con.type != null &&  con.type.equalsignoreCase('PM Seller')){
                contextCertification.Seller_PM_Contact_Id__c = con.bpmContactId;
                contextCertification.Seller_PM_Contact__c = bpmContactIdMap.get(con.bpmContactId);
            }
             
            if(con.type != null &&  con.type.equalsignoreCase('Title')){
                contextCertification.Title_Company_Contact_Id__c = con.bpmContactId;
                contextCertification.Title_Company_Contact__c = bpmContactIdMap.get(con.bpmContactId);
            }
             
            if(con.type != null &&  con.type.equalsignoreCase('HOA')){
                contextCertification.HOA_Contact_Id__c = con.bpmContactId;
                contextCertification.HOA_Contact__c = bpmContactIdMap.get(con.bpmContactId);
            }
             
            if(con.type != null &&  con.type.equalsignoreCase('Broker')){
                contextCertification.Roofstock_Listing_Agent_Contact_Id__c = con.bpmContactId;
                contextCertification.Roofstock_Listing_Agent_Contact__c = bpmContactIdMap.get(con.bpmContactId);
            }
         }
        
        /*if(inputCertification.sellerContactId!=null){
            contextCertification.Seller_Contact_Id__c = inputCertification.sellerContactId;
            if(bpmContactIdMap.get(inputCertification.sellerContactId)!=null){
                contextCertification.Seller_Contact__c = bpmContactIdMap.get(inputCertification.sellerContactId);
            }   
        }
        if(inputCertification.inspectorContactId!=null){
            contextCertification.Inspector_Company_Contact_Id__c = inputCertification.inspectorContactId;
            if(bpmContactIdMap.get(inputCertification.inspectorContactId)!=null){
                contextCertification.Inspection_Company_Contact__c = bpmContactIdMap.get(inputCertification.inspectorContactId);
            }   
        }
        if(inputCertification.sellerPmContactId!=null){
            contextCertification.Seller_PM_Contact_Id__c = inputCertification.sellerPmContactId;
            if(bpmContactIdMap.get(inputCertification.sellerPmContactId)!=null){
                contextCertification.Seller_PM_Contact__c = bpmContactIdMap.get(inputCertification.sellerPmContactId);
            }   
        }
        if(inputCertification.titleContactId!=null){
            contextCertification.Title_Company_Contact_Id__c = inputCertification.titleContactId;
            if(bpmContactIdMap.get(inputCertification.titleContactId)!=null){
                contextCertification.Title_Company_Contact__c = bpmContactIdMap.get(inputCertification.titleContactId);
            }   
        }
        if(inputCertification.hoaContactId!=null){
            contextCertification.HOA_Contact_Id__c = inputCertification.hoaContactId;
            if(bpmContactIdMap.get(inputCertification.hoaContactId)!=null){
                contextCertification.HOA_Contact__c = bpmContactIdMap.get(inputCertification.hoaContactId);
            }   
        }
        if(inputCertification.rsListingAgentContactId!=null){
            contextCertification.Roofstock_Listing_Agent_Contact_Id__c = inputCertification.rsListingAgentContactId;
            if(bpmContactIdMap.get(inputCertification.rsListingAgentContactId)!=null){
                contextCertification.Roofstock_Listing_Agent_Contact__c = bpmContactIdMap.get(inputCertification.rsListingAgentContactId);
            }   
        }*/

        //Assign Users
        if(inputCertification.rsAccountExecutiveEmail!=null){
            contextCertification.Roofstock_Account_Executive_Email__c = inputCertification.rsAccountExecutiveEmail;
            if(emailUserMap.get(inputCertification.rsAccountExecutiveEmail)!=null){
                contextCertification.Roofstock_Account_Executive__c = emailUserMap.get(inputCertification.rsAccountExecutiveEmail);
            }   
        }
        if(inputCertification.rsAccountManagerEmail!=null){
            contextCertification.Roofstock_Account_Manager_Email__c = inputCertification.rsAccountManagerEmail;
            if(emailUserMap.get(inputCertification.rsAccountManagerEmail)!=null){
                contextCertification.Roofstock_Account_Manager__c = emailUserMap.get(inputCertification.rsAccountManagerEmail);
            }   
        }
        if(inputCertification.rsAccountCoordinatorEmail!=null){
            contextCertification.Roofstock_Account_Coordinator_Email__c = inputCertification.rsAccountCoordinatorEmail;
            if(emailUserMap.get(inputCertification.rsAccountCoordinatorEmail)!=null){
                contextCertification.Roofstock_Account_Coordinator__c = emailUserMap.get(inputCertification.rsAccountCoordinatorEmail);
            }   
        }
        //Assign Other Fields certificationId
        if(inputCertification.certificationId!=null){
            contextCertification.BPM_Certification_Id__c = inputCertification.certificationId; 
        }
        if(inputCertification.certificationStatus!=null){
            contextCertification.Certification_Status__c = inputCertification.certificationStatus; 
        }
        if(inputCertification.certificationStartDate!=null){
            contextCertification.Certification_Start_Date__c = Date.valueOf(inputCertification.certificationStartDate); 
        }
        if(inputCertification.estPublishedDate!=null){
            contextCertification.Est_Publish_Date__c = Date.valueOf(inputCertification.estPublishedDate); 
        }
        if(inputCertification.publishDate!=null){
            contextCertification.Publish_Date__c = Date.valueOf(inputCertification.publishDate); 
        }
        if(inputCertification.listingSource!=null){
            contextCertification.Listing_Source__c = inputCertification.listingSource; 
        }
        if(inputCertification.saleType!=null){
            contextCertification.SaleType__c = inputCertification.saleType; 
        }
        if(inputCertification.listingAddendumStatus!=null){
            contextCertification.Listing_Addendum_Status__c = inputCertification.listingAddendumStatus; 
        }
        // Added for cloudhouse project::
        if(inputCertification.createdDate!=null){
            contextCertification.Certification_Start_Date__c = Date.valueOf(inputCertification.createdDate); 
        }
        if(inputCertification.completedDate!=null){
            contextCertification.Certification_Complete_Date__c = Date.valueOf(inputCertification.completedDate); 
        }
        if(inputCertification.isInspectionPass!=null){
            contextCertification.Certification_Inspection__c = ((inputCertification.isInspectionPass == true) ? 'Pass' :'Fail'); 
        }
        if(inputCertification.reasonCertificationFail!=null){
            contextCertification.Reason_for_Certification_Fail__c = inputCertification.reasonCertificationFail; 
        }

        return contextCertification;
    }
}
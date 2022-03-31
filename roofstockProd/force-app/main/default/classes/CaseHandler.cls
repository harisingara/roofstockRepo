/*
	Modified By: Anh Phan
	Modified Date: 11/25/2021
	Purpose: Added new method populateCaseAgeHours to calculate case age in hours based on business hours.

*/

public class CaseHandler {


    public static void CaseRoundRobinValidate(List<Case> lstNewCase, List<Case> lstOldCase,Map<Id,Case> mapNew , map<Id,Case> mapOld, String sDml){
        List<Case> rrErrors = new List<Case>();
        rrErrors = CaseRoundRobin.roundRobin(lstNewCase, lstOldCase,mapNew, mapOld, sDml); 
        // Post-trigger errors and cleanup
        if(rrErrors.size() > 0) {
            for(Case cs : rrErrors)
                cs.addError('ERROR: Could not update Assignment Group records');
        }
    }
    
    public static void updateCaseOwnerEmail(List<Case> newCaseList){
        Set<String> ownerIdSet = new Set<String>();
        for(Case cse:newCaseList){
            if(cse.Case_Owner_As_Roofstock_TC_User__c == true){
            	ownerIdSet.add(cse.OwnerId);
            }
        }
        List<User> userList = [select Id,Email from User where Id IN:ownerIdSet];
        Map<String,String> userIdEmailMap = new Map<String,String>();
        if(userList.size()>0){
            for(User u : userList){
                userIdEmailMap.put(u.Id,u.Email);
            }
        }
        
        for(Case cs:newCaseList){
            if(userIdEmailMap.get(cs.OwnerId)!=null){
            	cs.Case_Owner_Email__c = userIdEmailMap.get(cs.OwnerId);
            }
        }
    }
    
    
    private static String filterPropertyName(String Subject){
        //String str='test 90 Alexandria Dr, Mountain House, CA 95391 more test string';
        System.debug('=Subject='+Subject);
        String regex='\\d+.+(?=AL|AK|AS|AZ|AR|CA|CO|CT|DE|DC|FM|FL|GA|GU|HI|ID|IL|IN|IA|KS|KY|LA|ME|MH|MD|MA|MI|MN|MS|MO|MT|NE|NV|NH|NJ|NM|NY|NC|ND|MP|OH|OK|OR|PW|PA|PR|RI|SC|SD|TN|TX|UT|VT|VI|VA|WA|WV|WI|WY)[A-Z]{2}[, ]+\\d{5}(?:-\\d{4})?';

        Matcher matcher=Pattern.compile(regex).matcher(Subject);
        Boolean result= matcher.find();
        
        System.debug(Logginglevel.ERROR, 'result is : '+result);
        
        if(result){
            System.debug('=Match='+matcher.group(0));
            //String Property = (matcher.group(0)).split(',')[0]; 
            return matcher.group(0);
            
        }
        else{
            return null;
        }
    }
    
    @TestVisible
    private static void assignCaseToTransCert(List<Case> filteredCaseList,String caseTransactionRecordTypeId,String caseCertificationRecordTypeId){
        // Id caseTransactionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        //Id caseCertificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Certification').getRecordTypeId();
        try{
            //List<Case> filteredCaseList = [select Id,Assigned_User__c,RecordTypeId,Certification__c,Origin,Transaction__c,ContactId,Subject from Case where Id IN:filteredCaseIds];
            List<Case> emailToCaseList = new List<Case>();
            Set<String> contactSet = new Set<String>();
            //Set<String> transactionPropertyAddressSet = new Set<String>();
            Map<String,String> mapCaseIdPropertyAddress = new Map<String,String>();
            Map<Id,String> mapCaseIdTrx = new Map<Id,String>(); 
            Map<Id,String> mapCaseIdCert = new Map<Id,String>(); 
            
            if(!filteredCaseList.isEmpty()){
                for(Case newCase :filteredCaseList){
                    if(newCase.Origin == 'Email'){
                        emailToCaseList.add(newCase);
                        contactSet.add(newCase.ContactId);
                        String transactionPropertyName = filterPropertyName(newCase.Subject);
                        System.debug('=transactionPropertyName='+transactionPropertyName);
                        if(newCase.Subject <> null && ( newCase.Subject.contains('[cer:') || newCase.Subject.contains('[txn:'))){
                            if(newCase.Subject.contains('[cer:')){
                                mapCaseIdCert.put(newCase.Id, newCase.Subject.substringBetween('[cer:',':cer]'));
                            }
                            else{
                                mapCaseIdTrx.put(newCase.Id, newCase.Subject.substringBetween('[txn:',':txn]'));
                            }
                        }
                        else if(transactionPropertyName!=null){                           
                            //transactionPropertyAddressSet.add(transactionPropertyName);
                            //mapCaseIdPropertyAddress.put(newCase.Subject,transactionPropertyName);
                            System.debug('=transactionPropertyName='+transactionPropertyName);
                        	mapCaseIdPropertyAddress.put(newCase.Id,transactionPropertyName);

                        }
                    }
                }
            }
            system.debug('checkmap'+ mapCaseIdTrx);
            map<String,Id> mapCertID = new map<String,Id>(); 
            map<String,Id> mapTransID = new map<String,Id>();
            map<String,Id> mapTransAssignedID = new map<String,Id>();
            // Fetch The Certification ID 
            if(!mapCaseIdCert.isEmpty()){
                
                List<Certification__c> lstCertification = [SELECT  ID,BPM_Certification_Id__c FROM Certification__c 
                                                        where BPM_Certification_Id__c IN:  mapCaseIdCert.values()];    
                for(Certification__c oCert :lstCertification ){
                    mapCertID.put(oCert.BPM_Certification_Id__c , oCert.Id); 
                }
            }
            // Fetch the Transaction ID 
            if(!mapCaseIdTrx.isEmpty()){
                 
                List<Transaction__c> lstTrans = [SELECT  ID,Transaction_Id__c,Roofstock_TC_User__c FROM Transaction__c 
                                                        where Transaction_Id__c IN:  mapCaseIdTrx.values()];    
                for(Transaction__c oTrans :lstTrans ){
                    mapTransID.put(oTrans.Transaction_Id__c , oTrans.Id); 
                    mapTransAssignedID.put(oTrans.Transaction_Id__c , oTrans.Roofstock_TC_User__c);
                }

            }
            Map<String,Contact> contactMap = new Map<String,Contact>();
            Map<String,String> bpmContactMap = new Map<String,String>();
            List<Contact> matchingContactList = [select Id,BPM_Contact_Id__c from Contact where Id IN:contactSet];
            if(!matchingContactList.isEmpty()){
                for(Contact matchingCon :matchingContactList){ 
                    contactMap.put(matchingCon.BPM_Contact_Id__c,matchingCon);
                    bpmContactMap.put(matchingCon.Id,matchingCon.BPM_Contact_Id__c);
                }
            }
            
            //Create Map for Transaction.
            Map<String,Set<Transaction__c>> contactTransactionMap = new Map<String,Set<Transaction__c>>();
            Set<String> transactionOpenStatus = new Set<String>{'New','Pending Escrow'};
                Set<String> certificationOpenStatus = new Set<String>{'Initial','Pending','Quality Control'};
                    system.debug('check the values'+ contactMap); 
            system.debug('check the values'+ contactMap.keyset()); 
            		system.debug('transactionOpenStatus???'+transactionOpenStatus);
                    for(Transaction__c trans : [select Id,Roofstock_TC_User__c,Buyer_Contact_Id_1__c,Buyer_Contact_Id_2__c,Seller_Contact_Id__c from Transaction__c where ((Buyer_Contact_Id_1__c IN:contactMap.keyset() OR Buyer_Contact_Id_2__c IN:contactMap.keyset() OR Seller_Contact_Id__c IN:contactMap.keyset()) AND (Transaction_Status__c IN:transactionOpenStatus))]) {
                        
                        //Buyer Contact 1
                        if(contactTransactionMap.containsKey(trans.Buyer_Contact_Id_1__c)) {
                            Set<Transaction__c> associatedTransactionSet = contactTransactionMap.get(trans.Buyer_Contact_Id_1__c);
                            associatedTransactionSet.add(trans);
                            contactTransactionMap.put(trans.Buyer_Contact_Id_1__c, associatedTransactionSet);
                        } else {
                            contactTransactionMap.put(trans.Buyer_Contact_Id_1__c, new Set<Transaction__c> { trans });
                        }
                        //Buyer Contact 2
                        if(contactTransactionMap.containsKey(trans.Buyer_Contact_Id_2__c)) {
                            Set<Transaction__c> associatedTransactionSet = contactTransactionMap.get(trans.Buyer_Contact_Id_2__c);
                            associatedTransactionSet.add(trans);
                            contactTransactionMap.put(trans.Buyer_Contact_Id_2__c, associatedTransactionSet);
                        } else {
                            contactTransactionMap.put(trans.Buyer_Contact_Id_2__c, new Set<Transaction__c> { trans });
                        }
                        //Seller Contact
                        if(contactTransactionMap.containsKey(trans.Seller_Contact_Id__c)) {
                            Set<Transaction__c> associatedTransactionSet = contactTransactionMap.get(trans.Seller_Contact_Id__c);
                            associatedTransactionSet.add(trans);
                            contactTransactionMap.put(trans.Seller_Contact_Id__c, associatedTransactionSet);
                        } else {
                            contactTransactionMap.put(trans.Seller_Contact_Id__c, new Set<Transaction__c> { trans });
                        }
                    }
            
            //Create Map for Certification
            Map<String,Set<Certification__c>> contactCertificationMap = new Map<String,Set<Certification__c>>();
            for(Certification__c cert : [select Id,Seller_Contact_Id__c,Certification_Status__c from Certification__c where (Seller_Contact_Id__c IN:contactMap.keyset()) AND (Certification_Status__c IN:certificationOpenStatus)]){
                //Seller Contact
                if(contactCertificationMap.containsKey(cert.Seller_Contact_Id__c)) {
                    Set<Certification__c> associatedCertificationSet = contactCertificationMap.get(cert.Seller_Contact_Id__c);
                    associatedCertificationSet.add(cert);
                    contactCertificationMap.put(cert.Seller_Contact_Id__c, associatedCertificationSet);
                } else {
                    contactCertificationMap.put(cert.Seller_Contact_Id__c, new Set<Certification__c> { cert });
                }       
            }
            System.debug('=contactTransactionMap='+contactTransactionMap);
            System.debug('=contactCertificationMap='+contactCertificationMap);
            System.debug('=bpmContactMap='+bpmContactMap);
            
            //Create Transaction Name and Id Map
            Map<String,String> transactionNameIdMap =new Map<String,String>();
            Map<String,String> transactionNameTCMap = new Map<String,String>();
            Map<String,String> certificationNameIdMap = new Map<String,String>();
            List<Transaction__c> matchingPropertyAddressTransactions = [select Id,Name,Roofstock_TC_User__c,Property_Instance__r.Name from Transaction__c where Property_Instance__r.Name IN:mapCaseIdPropertyAddress.values()];
            System.debug('=matchingPropertyAddressTransactions='+matchingPropertyAddressTransactions);
            for(Transaction__c matchingPropertyAddressTrans :matchingPropertyAddressTransactions){
                transactionNameIdMap.put(matchingPropertyAddressTrans.Property_Instance__r.Name,matchingPropertyAddressTrans.Id);
                transactionNameTCMap.put(matchingPropertyAddressTrans.Property_Instance__r.Name,matchingPropertyAddressTrans.Roofstock_TC_User__c);
            } 
            System.debug('=transactionNameIdMap='+transactionNameIdMap);
            System.debug('=transactionNameTCMap='+transactionNameTCMap);
            //Create Certification Name and Id Map
            List<Certification__c> matchingPropertyAddressCertifications = [select Id,Name,Property__r.Name from Certification__c where Property__r.Name IN:mapCaseIdPropertyAddress.values()];
            System.debug('=matchingPropertyAddressCertifications='+matchingPropertyAddressCertifications);
            for(Certification__c matchingPropertyAddressCert :matchingPropertyAddressCertifications){
                certificationNameIdMap.put(matchingPropertyAddressCert.Property__r.Name,matchingPropertyAddressCert.Id);    
            }
            System.debug('=certificationNameIdMap='+certificationNameIdMap);
            //Iterate Incoming Case
          //  List<Case> updateCaseList = new List<Case>();
            system.debug('check mapCertID'+ mapCertID);
                    system.debug('check mapCaseIdCert'+ mapCaseIdCert);
            for(Case emaiToCase : emailToCaseList){
                // Update Transaction ID / Certification ID on Case object
                if(emaiToCase.RecordTypeId == caseTransactionRecordTypeId){
                    system.debug('am here'+ mapCaseIdTrx);
                    system.debug('am here before if'+ mapTransID);
                    if(emaiToCase.Subject <> null && emaiToCase.Subject.contains('[txn:')){
                        system.debug('am here'+ mapTransID);
                        emaiToCase.Transaction__c = mapTransID.get(mapCaseIdTrx.get(emaiToCase.Id));
                        emaiToCase.Assigned_User__c = mapTransAssignedID.get(mapCaseIdTrx.get(emaiToCase.Id));
                     //   updateCaseList.add(emaiToCase);
                    }
                    else if(contactTransactionMap.containsKey(bpmContactMap.get(emaiToCase.ContactId))){
                        Set<Transaction__c> matchingTransSet = contactTransactionMap.get(bpmContactMap.get(emaiToCase.ContactId));
                        List<Transaction__c> matchingTransList = new List<Transaction__c>();
                        matchingTransList.addAll(matchingTransSet);
                        if(matchingTransList.size() == 1){
                            emaiToCase.Transaction__c = matchingTransList[0].Id; 
                            emaiToCase.Assigned_User__c = matchingTransList[0].Roofstock_TC_User__c;
                        //    updateCaseList.add(emaiToCase);
                        }
                    }
                    else{
                        emaiToCase.Transaction__c = transactionNameIdMap.get(mapCaseIdPropertyAddress.get(emaiToCase.Id)); 
                        emaiToCase.Assigned_User__c = transactionNameTCMap.get(mapCaseIdPropertyAddress.get(emaiToCase.Id));
                      //  updateCaseList.add(emaiToCase);
                    }
                }
                system.debug('check recordtype ID '+caseCertificationRecordTypeId );
                if(emaiToCase.RecordTypeId == caseCertificationRecordTypeId){
                    system.debug('check mapCertID'+ mapCertID);
                    system.debug('check mapCaseIdCert'+ mapCaseIdCert);
                    if(emaiToCase.Subject <> null && emaiToCase.Subject.contains('[cer:')){
                        system.debug('check cert inside'+ mapCertID);
                        emaiToCase.Certification__c = mapCertID.get(mapCaseIdCert.get(emaiToCase.Id));
                      //  updateCaseList.add(emaiToCase);
                    }
                    else if(contactCertificationMap.containsKey(bpmContactMap.get(emaiToCase.ContactId))){
                        Set<Certification__c> matchingCertSet = contactCertificationMap.get(bpmContactMap.get(emaiToCase.ContactId));
                        List<Certification__c> matchingCertsList = new List<Certification__c>();
                        matchingCertsList.addAll(matchingCertSet);
                        if(matchingCertsList.size() == 1){
                            emaiToCase.Certification__c = matchingCertsList[0].Id; 
                           // updateCaseList.add(emaiToCase);
                        }
                    }
                    else{
                        //certificationNameIdMap
                        System.debug('Elase');
                        emaiToCase.Certification__c = certificationNameIdMap.get(mapCaseIdPropertyAddress.get(emaiToCase.Id));
                       // updateCaseList.add(emaiToCase);
                    }
                }
            }
            /*if(!updateCaseList.isEmpty()){
                update updateCaseList;  
            }*/
        }
        catch(Exception EX){
            System.debug('=EX='+EX);    
        }
    }
    
    //beforeInsert
    public static void filterEmailToCaseRecords(List<Case> newCases){
        String caseTransactionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        String caseCertificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Certification').getRecordTypeId();
        
        Set<String> filteredCaseIds = new Set<String>();
        List<Case> filteredCaseList = new List<Case>(); 
        for(Case newCase : newCases){
            if(newCase.Origin == 'Email' && (newCase.RecordTypeId == caseTransactionRecordTypeId || newCase.RecordTypeId == caseCertificationRecordTypeId)){
                filteredCaseIds.add(newCase.Id);  
                filteredCaseList.add(newCase);
                System.debug('=filteredCaseIds='+filteredCaseIds);
            }
        }
        assignCaseToTransCert(filteredCaseList,caseTransactionRecordTypeId,caseCertificationRecordTypeId);
    }
    
    //entry point beforeUpdate
    public static void updateTransactionCase(List<Case> newCaseList,Map<Id,Case> oldCaseMap){
        String caseTransactionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        String caseCertificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Certification').getRecordTypeId();
        Set<String> recTypeSet = new Set<String>{caseTransactionRecordTypeId,caseCertificationRecordTypeId};
        Set<String> transactionIdSet = new Set<String>();
        for(Case cse:newCaseList)
        { 
            if((oldCaseMap.get(cse.Id).Transaction__c == null) && oldCaseMap.get(cse.Id).Transaction__c!=cse.Transaction__c && recTypeSet.Contains(cse.RecordTypeId) && cse.Origin =='Email' && cse.Assigned_User__c == null){
                transactionIdSet.add(cse.Transaction__c);	    
            }
        }
        
        List<Transaction__c> matchingTransactionList = [select Id,Roofstock_TC_User__c from Transaction__c where Id IN:transactionIdSet];
        //Create a Map of transaction Id and TC User
        Map<String,String> tansactionTCUserMap = new Map<String,String>();
        for(Transaction__c trans :matchingTransactionList){
            tansactionTCUserMap.put(trans.Id,trans.Roofstock_TC_User__c);	    
        }
        //Update TC User
        for(Case cse:newCaseList)
        {
            if(tansactionTCUserMap.containsKey(cse.Transaction__c)){
                if(tansactionTCUserMap.get(cse.Transaction__c)!=null){
            		cse.Assigned_User__c = 	tansactionTCUserMap.get(cse.Transaction__c);
                }
            }           
        }
        
    }
    //Process Builder - Update Communication Status
    public static void updateCommunicationStatus(List<Case> newCaseList){
        for(Case newCase : newCaseList){
            if(newCase.Last_Email_Sent_Date__c > newCase.Last_Email_Received_Date__c){
                newCase.Communication_Status__c = 'Awaiting Response';
            }
            else{
                newCase.Communication_Status__c = 'Received Response';
            }
        }
    }

    //Anh Phan: Added new method to calculate case age based on business hours
    public static void populateCaseAgeHours(List<Case> caseTriggerList) {
        
        List<Case> caseList = new List<Case>();
        
        List<BusinessHours> caseAgeBusinessHoursList = new List<BusinessHours>([select id from BusinessHours where Name='Case Agent Business Hour']);
        
        Long caseAgeMiliseconds;
        
        for(Case cse: caseTriggerList) {
            
            if(cse.IsClosed && !caseAgeBusinessHoursList.isEmpty()) {
                
                caseAgeMiliseconds = BusinessHours.diff(caseAgeBusinessHoursList[0].id, cse.CreatedDate, cse.ClosedDate);
                Case caseRec = new Case();
                caseRec.id = cse.id;
                caseRec.CaseAgeHours__c = caseAgeMiliseconds/3600000;
                caseList.add(caseRec);
                
            }//End of if(isClosed)
            
        }//End of for(caseTriggerList)
        
        if(caseList <> NULL && !caseList.isEmpty()) {
            
            system.debug('Case Age Hours : '+caseList);
            update caseList;
        }
        
    }//end of populateCaseAgeHours
    
}
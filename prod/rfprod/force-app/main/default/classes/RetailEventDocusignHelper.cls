public class RetailEventDocusignHelper {
    public static void docusignEvents(List<Retail_Event__e> docusignRetailEvents){
        System.debug('=docusignRetailEvents='+docusignRetailEvents);
        Set<String> bpmContactIdSet = new Set<String>();
        Set<String> transactionIdSet = new Set<String>();
        Set<String> certificationIdSet = new Set<String>();
        List<Retail_Event__e> transactionEventsList = new List<Retail_Event__e>();
        Set<String> transactionEventSet = new Set<String>{'SELLER_SIGNED_PSA','BUYER_SIGNED_PSA','AGENT_SIGNED_PSA','BUYER_RECEIVED_PSA',
            											  'SELLER_RECEIVED_DISCLOSURES','SELLER_SIGNED_DISCLOSURES'};
        Set<String> certificationEventSet = new Set<String>{'SELLER_SIGNED_LISTING_ADDENDUM','AGENT_SIGNED_LISTING_ADDENDUM'};                                                                          
        
        Set<String> completedTaskSet = new Set<String>{'BUYER_SIGNED_PSA','SELLER_SIGNED_PSA','AGENT_SIGNED_PSA',
                										'SELLER_SIGNED_LISTING_ADDENDUM','AGENT_SIGNED_LISTING_ADDENDUM',
                										'SELLER_RECEIVED_DISCLOSURES','SELLER_SIGNED_DISCLOSURES'};
            
            
       Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Docusign Task').getRecordTypeId();
        
        
        
        /**  Filter transaction Id / Certification Id / BPMContact Id  **/
        
        for(Retail_Event__e re : docusignRetailEvents){
            if(transactionEventSet.contains(re.Event_Name__c)){
                transactionEventsList.add(re);
            }
            
            if(!String.isBlank(re.AttributeValue2__c)){
                if((re.Attribute2__c).toLowerCase() == 'contactId'){
                    bpmContactIdSet.add(re.AttributeValue2__c);    
                }    
            }
            
            if(transactionEventSet.contains(re.Event_Name__c)){
                if(!String.isBlank(re.AttributeValue1__c)){
                    transactionIdSet.add(re.AttributeValue1__c);
                    
                }
            }
            //else if(re.Event_Name__c.contains('LISTING_ADDENDUM')){
            else if(certificationEventSet.contains(re.Event_Name__c)){
                if(!String.isBlank(re.AttributeValue1__c)){
                    certificationIdSet.add(re.AttributeValue1__c);
                }
            }
        }
        
        /** Create Map for Transaction,Certification and Contact Records   **/  
        System.debug('=transactionEventsList='+transactionEventsList);
        System.debug('=transactionIdSet='+transactionIdSet);
        System.debug('=certificationIdSet='+certificationIdSet);
        
        //Matching Transaction
        Map<String,Transaction__c> transactionIdMap = new Map<String,Transaction__c>();
        List<Transaction__c> transList = [select Id,Transaction_Id__c,Roofstock_TC_User__c,Property_Instance__r.Name from Transaction__c where Transaction_Id__c IN:transactionIdSet];
        for(Transaction__c trans : transList){
            transactionIdMap.put(trans.Transaction_Id__c,trans);
        }
        System.debug('=transactionIdMap='+transactionIdMap);
        
        //Matching Certification
        Map<String,Certification__c> certIdMap = new Map<String,Certification__c>();
        List<Certification__c> certList = [select Id,BPM_Certification_Id__c,Roofstock_Account_Coordinator__c,Property__r.Name from Certification__c where BPM_Certification_Id__c IN:certificationIdSet];
        for(Certification__c cert : certList){
            certIdMap.put(cert.BPM_Certification_Id__c,cert);
        }
        System.debug('=certIdMap='+certIdMap);
        
        //Matching Contact
        List<Contact> matchingContactList = [select Id,Name,FirstName,LastName,BPM_Contact_Id__c from Contact where BPM_Contact_Id__c IN:bpmContactIdSet];
        Map<String,Contact> bpmContactIdMap = new Map<String,Contact>();
        for(Contact con : matchingContactList){
            bpmContactIdMap.put(con.BPM_Contact_Id__c,con);
        }
        System.debug('=bpmContactIdMap='+bpmContactIdMap);
        
        List<Task> taskList = new List<Task>();
        List<FeedItem> feedItemList = new List<FeedItem>();
        DateTime signedDate =DateTime.Now();
        
        /** Iterate Docusign Events and create Task and Feed Item*/
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        for(Retail_Event__e re : docusignRetailEvents){
            String agreementType ='';
            String transCertId ='';
            String propertyName='';
            String dealerType='';
            String signedType='';
            if(re.Event_Name__c.contains('SELLER')){
                dealerType='Seller';
            }
            if(re.Event_Name__c.contains('BUYER')){
                dealerType='Buyer';
            }
            if(re.Event_Name__c.contains('AGENT')){
                dealerType='Agent';
            }
            if(re.Event_Name__c == 'BUYER_SIGNED_PSA'){
                signedType = 'Buyer Signed PSA Date';
            }
            if(re.Event_Name__c == 'SELLER_SIGNED_PSA'){
                signedType = 'Seller Signed PSA Date';
            }
            if(re.Event_Name__c == 'AGENT_SIGNED_PSA'){
                signedType = 'Agent Signed PSA Date';
            }
            if(re.Event_Name__c == 'BUYER_RECEIVED_PSA'){
                signedType = 'Purchase Agreement Sent to Buyer Date';
            }
            if(re.Event_Name__c == 'SELLER_RECEIVED_DISCLOSURES'){
                signedType = 'Seller Disclosure Sent Date';
            }
            if(re.Event_Name__c == 'SELLER_SIGNED_DISCLOSURES'){
                signedType = 'Seller Disclosure Signed Date';
            }
            
            Task newTask = new Task();
            FeedItem post = new FeedItem();
            
            newTask.Subject = (re.Event_Name__c).replace('_', ' ');
            newTask.RecordTypeId = taskRecordTypeId;
            if(completedTaskSet.contains(re.Event_Name__c)){
                newTask.Status = 'Completed';
            }
            if(bpmContactIdMap!=null){
                if(bpmContactIdMap.get(re.AttributeValue2__c)!=null){
                    if(bpmContactIdMap.get(re.AttributeValue2__c).Id !=null){
                        newTask.WhoId = bpmContactIdMap?.get(re.AttributeValue2__c)?.Id;
                    }
                }
            }
            if(!String.isBlank(re.AttributeValue1__c)){
                if(transactionIdMap.containsKey(re.AttributeValue1__c)){
                    newTask.WhatId = transactionIdMap.get(re.AttributeValue1__c).Id;
                    if(transactionIdMap.get(re.AttributeValue1__c).Roofstock_TC_User__c !=null){
                        newTask.OwnerId = transactionIdMap.get(re.AttributeValue1__c).Roofstock_TC_User__c;
                    }
                    post.ParentId =  transactionIdMap.get(re.AttributeValue1__c).Id;
                    agreementType = 'PSA';
                    transCertId = re.AttributeValue1__c;
                    propertyName = transactionIdMap.get(re.AttributeValue1__c).Property_Instance__r.Name;
                }
                else if(certIdMap.containsKey(re.AttributeValue1__c)){
                    newTask.WhatId = certIdMap.get(re.AttributeValue1__c).Id;
                    if(certIdMap.get(re.AttributeValue1__c).Roofstock_Account_Coordinator__c !=null){
                        newTask.OwnerId = certIdMap.get(re.AttributeValue1__c).Roofstock_Account_Coordinator__c;
                    }
                    post.ParentId =  certIdMap.get(re.AttributeValue1__c).Id;
                    
                    agreementType = 'LISTING ADDENDUM';
                    transCertId = re.AttributeValue1__c;
                    propertyName = certIdMap.get(re.AttributeValue1__c).Property__r.Name;
                    
                }
            }
            
            newTask.Description = 'Address:'+' '+propertyName+'\n'+dealerType+':'+' '+bpmContactIdMap?.get(re.AttributeValue2__c)?.Name+'\nDate Signed:'+' '+signedDate+'\nEvent:'+' '+(re.Event_Name__c).replace('_', ' ')+'\n'+signedType+':'+' '+re.AttributeValue3__c;
            post.Body = 'Address:'+' '+propertyName+'\nBuyer:'+' '+bpmContactIdMap?.get(re.AttributeValue2__c)?.Name+'\nDate Signed:'+' '+signedDate+'\nEvent:'+' '+(re.Event_Name__c).replace('_', ' ')+'\n'+signedType+':'+' '+re.AttributeValue3__c;
            taskList.add(newTask);
            if(post.ParentId!=null){
                feedItemList.add(post);
            }
        }
        System.debug('=taskList='+taskList);
        System.debug('=feedItemList='+feedItemList);
        
        if(!taskList.isEmpty()){
            insert taskList; 
        }
        if(!feedItemList.isEmpty()){
            insert feedItemList; 
        }
        
        updateSignedReceivedDate(docusignRetailEvents,transactionIdSet);
    }
    public static void updateSignedReceivedDate(List<Retail_Event__e> transactionEventsList,Set<String> transactionIdSet){
        List<Transaction__c> transList = [select Id,Transaction_Id__c,Buyer_Signed_PSA_Date__c,Seller_Signed_PSA_Date__c,
                                          Agent_Signed_PSA_Date__c,Purchase_Agreement_Sent_to_Buyer_Date__c,Seller_Disclosures_Sent__c, 
                                          Seller_Disclosure_Signed__c from Transaction__c where Transaction_Id__c IN:transactionIdSet];
        
        Map<String,Transaction__c> transIdMap = new Map<String,Transaction__c>();
        for(Transaction__c trans : transList){
            transIdMap.put(trans.Transaction_Id__c,trans);
        }  
        List<Transaction__c> transUpdateList = new List<Transaction__c>();
        Set<Transaction__c> transUpdateSet = new Set<Transaction__c>();
        for(Retail_Event__e re :transactionEventsList){
            
            if(transIdMap.containsKey(re.AttributeValue1__c)){
                Transaction__c trans = transIdMap.get(re.AttributeValue1__c);
                if(re.Event_Name__c == 'BUYER_SIGNED_PSA'){
                    trans.Buyer_Signed_PSA_Date__c = DateTime.parse(re.AttributeValue3__c);
                }
                else if(re.Event_Name__c == 'SELLER_SIGNED_PSA'){
                    trans.Seller_Signed_PSA_Date__c = DateTime.parse(re.AttributeValue3__c);
                }
                else if(re.Event_Name__c == 'AGENT_SIGNED_PSA'){
                    trans.Agent_Signed_PSA_Date__c = DateTime.parse(re.AttributeValue3__c);
                }
                else if(re.Event_Name__c == 'BUYER_RECEIVED_PSA'){
                    trans.Purchase_Agreement_Sent_to_Buyer_Date__c = DateTime.parse(re.AttributeValue3__c);
                }
                else if(re.Event_Name__c == 'SELLER_RECEIVED_DISCLOSURES'){
                    trans.Seller_Disclosures_Sent__c = DateTime.parse(re.AttributeValue3__c);
                }
                else if(re.Event_Name__c == 'SELLER_SIGNED_DISCLOSURES'){
                    trans.Seller_Disclosure_Signed__c = DateTime.parse(re.AttributeValue3__c);                    
                }
                transUpdateList.add(trans);
            }
            
        }
        transUpdateSet.addAll(transUpdateList);
        transUpdateList.clear();
        transUpdateList.addAll(transUpdateSet);
        System.debug('=transUpdateList='+transUpdateList);
        if(transUpdateList.size()>0){
            update transUpdateList;
        }
        
    }
}
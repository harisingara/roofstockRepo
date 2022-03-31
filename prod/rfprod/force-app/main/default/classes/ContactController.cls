public class ContactController {
    @AuraEnabled(cacheable=true) 
    public static List<sObject> fetchAllAssoictedRecords(String recordId,String objectType){
        System.debug('=objectType='+objectType);
        if(objectType == 'Transaction'){
            System.debug('=objectType='+objectType);
            List<Transaction__c> transList = [select Id,Name,Transaction_Status__c,Start_Date__c,Est_Close_Date__c,List_Price__c from Transaction__c where (Buyer_Contact1__c=:recordId OR 
                                                                                                                     Buyer_Contact2__c=:recordId OR 
                                                                                                                     Buyer_Broker_Contact__c=:recordId OR
                                                                                                                     PM_Buyer_Contact__c=:recordId OR
                                                                                                                     Seller_Contact__c=:recordId OR
                                                                                                                     Seller_Broker_Contact__c=:recordId OR
                                                                                                                     PM_Seller_Contact__c=:recordId OR
                                                                                                                     Inspector_Contact__c=:recordId OR
                                                                                                                     Escrow_Contact__c=:recordId OR
                                                                                                                     Title_Contact__c=:recordId OR
                                                                                                                     Lender_Contact__c=:recordId OR
                                                                                                                     Insurance_Contact__c=:recordId                                                                                                                 
                                                                                                                    )];                                                                                                                    
            Set<Transaction__c> transactionSet = new Set<Transaction__c>();
            transactionSet.addAll(transList);
            transList.clear();
            transList.addAll(transactionSet);
            return transList;
        }
        else if(objectType == 'Certification'){
            System.debug('=Certification='+objectType);
            List<Certification__c> certList = [Select Id,Name,Certification_Status__c,Certification_Start_Date__c,List_Price__c from Certification__c where (HOA_Contact__c =:recordId OR
                                                                                                                   Seller_Contact__c=:recordId OR
                                                                                                                   Seller_PM_Contact__c=:recordId OR
                                                                                                                   Title_Company_Contact__c=:recordId OR
                                                                                                                   Inspection_Company_Contact__c=:recordId OR
                                                                                                                   Roofstock_Listing_Agent_Contact__c=:recordId
            																										)];
            System.debug('=certList='+certList);
            Set<Certification__c> certificationSet = new Set<Certification__c>();
            certificationSet.addAll(certList);
            certList.clear();
            certList.addAll(certificationSet);
            return certList;
        }
        else{
            return null;
        }
    }
}
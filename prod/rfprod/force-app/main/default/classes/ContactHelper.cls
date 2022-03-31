/*
* Initial Version - Chidanand G.M.
* ContactTriggerHelper
* 
*/
public class ContactHelper {
    /*SF-88 - Function to update ORU*/ 
    
    Public static void updateORU(List<Contact> conList,Map<Id,Contact> OldMap){
        Set<String> contactIdSet = new Set<String>();
        Id oppRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
        for(Contact con : conList){
            if((con.HasOptedOutOfEmail!=oldMap.get(con.Id).HasOptedOutOfEmail) && (con.Email!=null) && (con.RecordTypeId == oppRecordTypeId)){
                contactIdSet.add(con.Id);
            }
        }
        List<OpportunityRentalUnit__c> oruList = [select Id,ParentLastUpdated__c from OpportunityRentalUnit__c where Primary_Leasing_Contact__c IN:contactIdSet];
        
        for(OpportunityRentalUnit__c oru :oruList){
            oru.ParentLastUpdated__c = System.now();
        }
        update oruList;
    }
    
    //Process Builder - Update Hubspot Score from contact
    //after update/after insert
    public static void updateHubspotScoreFromContact(List<Contact> newContactList,Map<Id,Contact> oldContactMap){
        Map<String,decimal> contactHubspotScoreMap = new Map<String,decimal>();
        for(Contact newContact: newContactList){
            System.debug('=oldContactMap='+oldContactMap);
            if(oldContactMap!=null){
                if(oldContactMap.get(newContact.Id).Hubspot_Score__c != newContact.Hubspot_Score__c){
                    contactHubspotScoreMap.put(newContact.AccountId,newContact.Hubspot_Score__c);
                }
            }
            else{
                contactHubspotScoreMap.put(newContact.AccountId,newContact.Hubspot_Score__c);
            }
            
        }
        List<Account> matchingAccountList = [select Id,Hubspot_Score__c from Account where Id IN:contactHubspotScoreMap.keyset()];
        List<Account> updateAccount = new List<Account>();
        for(Account acc:matchingAccountList){
            acc.Hubspot_Score__c = contactHubspotScoreMap.get(acc.Id);
            updateAccount.add(acc);
        }
        if(updateAccount.size()>0){
            update updateAccount;
        }
        
    }
    //Process Builder - Made an Offer Date
    public static void updateMadeAnOfferDate(List<Contact> newContactList){
        Map<String,datetime> contactMadeAnOfferDateMap = new Map<String,datetime>();
        for(Contact newContact :newContactList){
            if(newContact.Made_An_Offer_Date__c != null){
                contactMadeAnOfferDateMap.put(newContact.AccountId,newContact.Made_An_Offer_Date__c);
            }
        }
        List<Account> matchingAccountList = [select Id,Made_An_Offer_Date__c from Account where Id IN:contactMadeAnOfferDateMap.keySet()];
        List<Account> updateAccount = new List<Account>();
        for(Account acc : matchingAccountList){
            acc.Made_An_Offer_Date__c =contactMadeAnOfferDateMap.get(acc.Id);
            updateAccount.add(acc);
        }
        if(updateAccount.size()>0){
            update updateAccount; 
        }
    }
    //Process Builder - Velocify - Sync HS Contact fields to Account afterupdate,
    public static void syncHSContactFields(List<Contact> newContactList,Map<Id,Contact> oldContactMap){
        Map<String,datetime> accountEmailOpenDateMap = new Map<String,datetime>();
        Map<String,datetime> accountHSTimeOfLastVisitMap = new Map<String,datetime>();
        Map<String,String> accountTimeZoneMap = new Map<String,String>();
        Map<String,String> accountPhoneMap = new Map<String,String>();
        
        for(Contact newCon : newContactList){
            if(newCon.HS_Last_Email_Open_Date__c !=oldContactMap.get(newCon.Id).HS_Last_Email_Open_Date__c ){
                accountEmailOpenDateMap.put(newCon.AccountId,newCon.HS_Last_Email_Open_Date__c);    
            }
            if(newCon.HS_Time_of_Last_Visit__c !=oldContactMap.get(newCon.Id).HS_Time_of_Last_Visit__c ){
                accountHSTimeOfLastVisitMap.put(newCon.AccountId,newCon.HS_Time_of_Last_Visit__c);    
            }
            if((newCon.Phone !=oldContactMap.get(newCon.Id).Phone) || (newCon.IP_Timezone__c  !=oldContactMap.get(newCon.Id).IP_Timezone__c ) ){
                accountTimeZoneMap.put(newCon.AccountId,newCon.IP_Timezone__c);
                accountPhoneMap.put(newCon.AccountId,newCon.Phone);
            }
        }
        
        
        List<Account> updateAccountList = new List<Account>();
        List<Account> filteredAccountList = [select Id,HS_Last_Email_Opened_Date__c,HS_Time_of_Last_Visit__c,Phone,IP_Timezone__c from Account where (Id IN:accountEmailOpenDateMap.keyset() OR Id IN:accountHSTimeOfLastVisitMap.keyset() OR Id IN:accountPhoneMap.keyset())];
        for(Account ac:filteredAccountList){
            
            if(accountEmailOpenDateMap!=null){
                //if(accountEmailOpenDateMap.get(ac.Id)!=null){
                ac.HS_Last_Email_Opened_Date__c = Date.valueOf(accountEmailOpenDateMap.get(ac.Id));
                updateAccountList.add(ac);
                //}
                
            }
            if(accountHSTimeOfLastVisitMap!=null){
                // if(accountHSTimeOfLastVisitMap.get(ac.Id)!=null){
                ac.HS_Time_of_Last_Visit__c =  accountHSTimeOfLastVisitMap.get(ac.Id);
                updateAccountList.add(ac);
                // }
                
            }
            if(accountPhoneMap!=null){
                // if(accountPhoneMap.get(ac.Id)!=null){
                ac.Phone =  accountPhoneMap.get(ac.Id);
                updateAccountList.add(ac);
                // }
                
            }
            if(accountTimeZoneMap!=null){
                // if(accountTimeZoneMap.get(ac.Id)!=null){
                ac.IP_Timezone__c =  accountTimeZoneMap.get(ac.Id);
                updateAccountList.add(ac);
                //   }
                
            }
            
        }
        /*
Set<Account> updateAccountSet = new Set<Account>();

if(updateAccountList.size()>0){
updateAccountSet.addAll(updateAccountList);
updateAccountList.clear();
updateAccountList.addAll(updateAccountSet);
update updateAccountList;
}
*/
        map<id,Account> accountMap = new map<id,Account>();
        
        //put all the values from the list to map. 
        accountMap.putall(updateAccountList);
        if(accountMap.size()>0){
            update accountMap.values();
        }
    }
    
}
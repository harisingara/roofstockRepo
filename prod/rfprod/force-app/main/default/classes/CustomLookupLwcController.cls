public class CustomLookupLwcController {
    // Method to fetch lookup search result   
     @AuraEnabled(cacheable=true)
     public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName, String sFilterObjectFieldApiName, String sFilterObjectRecordId) {    
         List < sObject > returnList = new List < sObject > ();
 
         string sWildCardText = '%' + searchKey + '%';
         string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Name Like : sWildCardText order by createdDate DESC LIMIT 5';

        if (String.isNotBlank(sFilterObjectFieldApiName) && String.isNotBlank(sFilterObjectRecordId)){
            String sRecId = sFilterObjectRecordId;
            sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where '+ sFilterObjectFieldApiName + ' = : sRecId and Name Like : sWildCardText order by createdDate DESC LIMIT 5';
        }

         for (sObject obj: database.query(sQuery)) {
             returnList.add(obj);
         }
         return returnList;
     }
     
     // Method to fetch lookup default value 
     @AuraEnabled
     public static sObject fetchDefaultRecord(string recordId , string sObjectApiName, String sFilterObjectFieldApiName, String sFilterObjectRecordId) {
         string sRecId = recordId;    
         string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';

        if (String.isNotBlank(sFilterObjectFieldApiName) && String.isNotBlank(sFilterObjectRecordId)){
            String sFilterRecId = sFilterObjectRecordId;
            sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId and ' + sFilterObjectFieldApiName + ' = : sFilterRecId LIMIT 1';
        }

         for (sObject obj: database.query(sQuery)) {
             return obj;
         }
         return null;
     }
     
 }
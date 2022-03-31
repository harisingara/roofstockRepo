public Interface ITriggerHandler {
    
    void beforeInsert(List<sObject> newRecordsList);
    
    void afterInsert(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap);
    
    void beforeUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap);
    
    void afterUpdate(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap,List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap);
   
    void beforeDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap);
    
    void afterDelete(List<sObject> oldRecordsList,Map<Id,sObject> oldRecordsMap);
    
    void afterUndelete(List<sObject> newRecordsList,Map<Id,sObject> newRecordsMap);
    
    Boolean isDisabled();

}
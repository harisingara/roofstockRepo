trigger LLRUTrigger on Lead_Leasing_Rental_Unit__c (before insert, after insert, before update, after update, before delete, after delete) {
    TriggerDispatcher.run(new LLRUTriggerHandler(),'Lead_Leasing_Rental_Unit__c');
}
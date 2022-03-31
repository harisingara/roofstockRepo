global class BatchDeleteDebugLogs implements Database.Batchable<sObject> { // created to bulk delete records - use with care!
    
    // Fields
    global final String Query;
    
    // Constructor
    global BatchDeleteDebugLogs() {
        Query = 'Select Id from DebugLog__c where createddate<Last_N_Days:'+Label.N_Days_Older_Debug_Logs;
    }
    
    // Start
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
 
    // Execute
    global void execute(Database.BatchableContext bc , List<DebugLog__c> scope) {
        delete scope;
    }
    
    // Finish
    global void finish(Database.BatchableContext bc) {}

}
/*
 * Initial Version - Chidanand G.M.
 * Description - Batchbale and schedulable class to update the status of the Turn records to In Progress 
 * Logs - 
*/
global class UpdateTurnStatusSchedulable implements Schedulable, Database.Batchable<sObject> {

    global Database.QueryLocator start (Database.BatchableContext BC) {
		Date today = Date.today();
        String query = 'SELECT Id, Move_Out_Date__c, Status__c FROM Turn__c WHERE Status__c = \'Upcoming\' AND Move_Out_Date__c=today';
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext BC, List<Turn__c> scope) {
              
        for (Turn__c t: scope) {
			t.Status__c = 'In Progress';
        }
        
        try {
            update scope;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        
    }
    
    global void finish (Database.BatchableContext BC) {
        
    }
    
    global void execute (SchedulableContext SC) {
        Database.executeBatch(new UpdateTurnStatusSchedulable());
    }
    
}
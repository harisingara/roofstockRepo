global class PmCsatBuyers30DaysSurvey implements schedulable {
	global void execute(SchedulableContext ctx) {
        List<transaction__c> transList = [SELECT Id, Transaction_Status__c, Send_Survey__c,Buyer_Contact1_Email__c,Buyer_Contact1__r.Email 
                                            FROM Transaction__c 
                                           WHERE Transaction_Status__c ='Transaction Completed' and Transaction_type__c !='Acquisition Buy' and Close_of_Escrow_Date__c  = LAST_N_DAYS:37 and Close_of_Escrow_Date__c  < LAST_N_DAYS:30];
        for (transaction__c trans :transList){
            trans.Send_Survey__c = 'PmCsatBuyers30DaysSurvey';
            trans.Buyer_Contact1_Email__c = trans.Buyer_Contact1__r.Email;
        }
        update transList; 
    }
}
global class PmCsatBuyers90DaysSurvey implements schedulable{
	global void execute(SchedulableContext ctx) {
        List<transaction__c> transList = [SELECT Id, Transaction_Status__c, Send_Survey__c,Buyer_Contact1_Email__c,Buyer_Contact1__r.Email 
                                            FROM Transaction__c 
                                           WHERE Transaction_Status__c ='Transaction Completed' and transaction_type__c !='Acquisition Buy' and Close_of_Escrow_Date__c  = LAST_N_DAYS:97 and Close_of_Escrow_Date__c  < LAST_N_DAYS:90];
        for (transaction__c trans :transList){
            trans.Send_Survey__c = 'PmCsatBuyers90DaysSurvey';
            trans.Buyer_Contact1_Email__c = trans.Buyer_Contact1__r.Email;
        }
        update transList; 
    }
}
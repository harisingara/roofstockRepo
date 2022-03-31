global class RsNpsBuyerSellerSurvey implements schedulable {
    	global void execute(SchedulableContext ctx) {
        List<transaction__c> transList = [SELECT Id, Transaction_Status__c, Send_Survey__c,Buyer_Contact1_Email__c,Buyer_Contact1__r.Email, Seller_Contact_Email__c, Seller_Contact__r.email 
                                            FROM Transaction__c 
                                           WHERE Transaction_Status__c ='Transaction Completed' and transaction_type__c !='Acquisition Buy' and Close_of_Escrow_Date__c = LAST_N_DAYS:17 and Close_of_Escrow_Date__c < LAST_N_DAYS:10];
        for (transaction__c trans :transList){
            trans.Send_Survey__c = 'RsNpsBuyerSellerSurvey';
            trans.Buyer_Contact1_Email__c = trans.Buyer_Contact1__r.Email;
            trans.Seller_Contact_Email__c = trans.Seller_Contact__r.Email;
        }
        update transList;
    }
}
public with sharing class AnonymizeTransactionEmailsBatchable implements Database.Batchable<SObject>{
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT id, Buyer_BPM_Contact_Email__c,Buyer_Broker_Contact_Email__c,Buyer_Contact1_Email__c,Buyer_Contact2_Email__c,Buyer_PM_Contact_Email__c,Closing_Attorney_Contact_Email__c,Escrow_Company_Contact_Email__c,Insurance_Company_Contact_Email__c,Lender_Broker_Contact_Email__c,Roofstock_Accounting_Email__c,Roofstock_Account_Manager_Email__c,Roofstock_Advisor_Email__c,Roofstock_Customer_Service_Email__c,Roofstock_Inventory_Owner_Email__c,Roofstock_Project_Manager_Email__c,Roofstock_TC_User_Email__c,Seller_Contact_Email__c,Seller_Listing_Agent_Contact_Email__c,Seller_PM_Contact_Email__c,Title_Company_Contact_Email__c,Underwriting_Analyst_Email__c FROM Transaction__c');
    }
    public void execute(
        Database.BatchableContext context,
        List<Transaction__c> transactions
    ) {
        Boolean org = ([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox);
        if(org){
            for (Transaction__c trans : transactions) {
                System.debug('contact sandbox email: ' + trans.Buyer_BPM_Contact_Email__c);
                if (trans.Buyer_BPM_Contact_Email__c != null) {
                    trans.Buyer_BPM_Contact_Email__c  = trans.Buyer_BPM_Contact_Email__c  + '.invalid';
                }
                if (trans.Buyer_Broker_Contact_Email__c != null) {
                    trans.Buyer_Broker_Contact_Email__c  = trans.Buyer_Broker_Contact_Email__c  + '.invalid';
                }
                if (trans.Buyer_Contact1_Email__c != null) {
                    trans.Buyer_Contact1_Email__c  = trans.Buyer_Contact1_Email__c  + '.invalid';
                }
                if (trans.Buyer_Contact2_Email__c != null) {
                    trans.Buyer_Contact2_Email__c  = trans.Buyer_Contact2_Email__c  + '.invalid';
                }
                if (trans.Buyer_PM_Contact_Email__c != null) {
                    trans.Buyer_PM_Contact_Email__c  = trans.Buyer_PM_Contact_Email__c  + '.invalid';
                }
                if (trans.Closing_Attorney_Contact_Email__c != null) {
                    trans.Closing_Attorney_Contact_Email__c  = trans.Closing_Attorney_Contact_Email__c  + '.invalid';
                }
                if (trans.Escrow_Company_Contact_Email__c != null) {
                    trans.Escrow_Company_Contact_Email__c  = trans.Escrow_Company_Contact_Email__c  + '.invalid';
                }
                if (trans.Insurance_Company_Contact_Email__c != null) {
                    trans.Insurance_Company_Contact_Email__c  = trans.Insurance_Company_Contact_Email__c  + '.invalid';
                }
                if (trans.Lender_Broker_Contact_Email__c != null) {
                    trans.Lender_Broker_Contact_Email__c  = trans.Lender_Broker_Contact_Email__c  + '.invalid';
                }
                if (trans.Roofstock_Accounting_Email__c != null) {
                    trans.Roofstock_Accounting_Email__c  = trans.Roofstock_Accounting_Email__c  + '.invalid';
                }
                if (trans.Roofstock_Account_Manager_Email__c != null) {
                    trans.Roofstock_Account_Manager_Email__c  = trans.Roofstock_Account_Manager_Email__c  + '.invalid';
                }
                if (trans.Roofstock_Advisor_Email__c != null) {
                    trans.Roofstock_Advisor_Email__c  = trans.Roofstock_Advisor_Email__c  + '.invalid';
                }
                if (trans.Roofstock_Customer_Service_Email__c != null) {
                    trans.Roofstock_Customer_Service_Email__c  = trans.Roofstock_Customer_Service_Email__c  + '.invalid';
                }
                if (trans.Roofstock_Inventory_Owner_Email__c != null) {
                    trans.Roofstock_Inventory_Owner_Email__c  = trans.Roofstock_Inventory_Owner_Email__c  + '.invalid';
                }
                if (trans.Roofstock_Project_Manager_Email__c != null) {
                    trans.Roofstock_Project_Manager_Email__c  = trans.Roofstock_Project_Manager_Email__c  + '.invalid';
                }
                if (trans.Roofstock_TC_User_Email__c != null) {
                    trans.Roofstock_TC_User_Email__c  = trans.Roofstock_TC_User_Email__c  + '.invalid';
                }
                if (trans.Seller_Contact_Email__c != null) {
                    trans.Seller_Contact_Email__c  = trans.Seller_Contact_Email__c  + '.invalid';
                }
                if (trans.Seller_Listing_Agent_Contact_Email__c != null) {
                    trans.Seller_Listing_Agent_Contact_Email__c  = trans.Seller_Listing_Agent_Contact_Email__c  + '.invalid';
                }
                if (trans.Seller_PM_Contact_Email__c != null) {
                    trans.Seller_PM_Contact_Email__c  = trans.Seller_PM_Contact_Email__c  + '.invalid';
                }
                if (trans.Title_Company_Contact_Email__c != null) {
                    trans.Title_Company_Contact_Email__c  = trans.Title_Company_Contact_Email__c  + '.invalid';
                }
                if (trans.Underwriting_Analyst_Email__c != null) {
                    trans.Underwriting_Analyst_Email__c  = trans.Underwriting_Analyst_Email__c  + '.invalid';
                }
                
                System.debug('contact anonymized email: ' + trans.Underwriting_Analyst_Email__c);
            }
            update transactions;
        }
        
    }
    public void finish(Database.BatchableContext context) {
    }
}
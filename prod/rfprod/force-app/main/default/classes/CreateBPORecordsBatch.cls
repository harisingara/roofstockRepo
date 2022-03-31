/* Class Name - CreateBPORecordsBatch
 * Author - Naveen Mittapalli
 * Description - Batch class which creates BPO records in New Status based on the BPO Trigger Date on the Property
 * Test Class - BPOPropertyValuationTest1
 * ******************************************************************************************
 * 
 * Date			Name			Comments
 * 02-08-2022	Naveen			Created Batch for for BPO Records creation
 * 
 */
global with sharing class CreateBPORecordsBatch implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts{
    

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String Query='SELECT id, Name, Street_Address__c,City__c,State__c,County__c,Zip__c,Seller_Provided_List_Price__c,Property_Type__c ,Bathrooms_SUM__c,Bedrooms_SUM__c,Lot_Size__c,Square_Feet__c,Annual_BPO_Trigger_Date__c,BPO_Trigger_Date__c,Year_Built__c,Type_of_BPO_Trigger__c, PropertyId__c,Client__c FROM Property2__c WHERE BPO_Trigger_Date__c = YESTERDAY OR  (Annual_BPO_Trigger_Date__c = YESTERDAY AND Stop_Annual_BPO_Valuation__c = false)';
        return Database.getQueryLocator(Query);         
    }
    
    global void execute(Database.BatchableContext bc,List<Property2__c> propertyList)
    {
        BatchBPOServiceCalloutHelper.createBPORecords(propertyList,false);
    }

    global void finish(Database.BatchableContext bc){
		BPOServiceCalloutBatch b = new BPOServiceCalloutBatch();
		Database.executeBatch(b, 1);
    }
    
    global void execute (SchedulableContext SC) {
        Database.executeBatch(new CreateBPORecordsBatch(),50);
    }
}
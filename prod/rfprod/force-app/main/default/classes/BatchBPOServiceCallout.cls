/* Class Name - BatchBPOServiceCallout
 * Author - Kavitha
 * Description - Batch class which sends callout to BPO Valuation.
 * Test Class - BPOPropertyValuationTest
 * ******************************************************************************************
 * 
 * Date			Name			Comments
 * 11-22-2021	Kavitha			Created Batch for callout
 * 
 */

global with sharing class BatchBPOServiceCallout implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts{
    

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String Query='SELECT id, Name, Street_Address__c,City__c,State__c,County__c,Zip__c,Seller_Provided_List_Price__c,Property_Type__c ,Bathrooms_SUM__c,Bedrooms_SUM__c,Lot_Size__c,Square_Feet__c,Annual_BPO_Trigger_Date__c,BPO_Trigger_Date__c,Year_Built__c,Type_of_BPO_Trigger__c, PropertyId__c,Client__c FROM Property2__c WHERE BPO_Trigger_Date__c = YESTERDAY OR  (Annual_BPO_Trigger_Date__c = YESTERDAY AND Stop_Annual_BPO_Valuation__c = false)';
        return Database.getQueryLocator(Query);
          
    }

    global void execute(Database.BatchableContext bc,List<Property2__c> propertyList)
    {
        //BatchBPOServiceCalloutHelper.callBPOServiceCallout(propertyList,false);
    }

    global void finish(Database.BatchableContext bc){

    }
    
    global void execute (SchedulableContext SC) {
        Database.executeBatch(new BatchBPOServiceCallout());
    }
}
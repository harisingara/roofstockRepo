/* Class Name - BPOServiceCalloutBatch
 * Author - Naveen Mittapalli
 * Description - Batch class which sends callout to BPO Valuation.
 * Picks up the BPO records in Confirmed Status and sends out BPO orders for these records
 * Test Class - BPOPropertyValuationTest1
 * ******************************************************************************************
 * 
 * Date			Name			Comments
 * 02-08-2022	Naveen			Created Batch for callout
 * 
 */
global with sharing class BPOServiceCalloutBatch implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts{
    

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        //String Query='SELECT id, Name, Street_Address__c,City__c,State__c,County__c,Zip__c,Seller_Provided_List_Price__c,Property_Type__c ,Bathrooms_SUM__c,Bedrooms_SUM__c,Lot_Size__c,Square_Feet__c,Annual_BPO_Trigger_Date__c,BPO_Trigger_Date__c,Year_Built__c,Type_of_BPO_Trigger__c, PropertyId__c,Client__c FROM Property2__c WHERE BPO_Trigger_Date__c = YESTERDAY OR  (Annual_BPO_Trigger_Date__c = YESTERDAY AND Stop_Annual_BPO_Valuation__c = false)';
        String Query = 'SELECT Id, Property__c, Pool_Name__c, Product__c, Branch_Id__c, Status__c, Type_of_BPO_Trigger__c FROM Broker_Price_Opinion__c WHERE  Status__c = \'Confirmed\'';
        return Database.getQueryLocator(Query);
          
    }

    global void execute(Database.BatchableContext bc,List<Broker_Price_Opinion__c> bpoList)
    {
        Set <Id> propertyIdSet = new Set <Id> ();
        Map <String, Broker_Price_Opinion__c> propToBpoMap = new Map <String, Broker_Price_Opinion__c> ();
        Map <String, Property2__c> propMap = new Map <String, Property2__c> ();
        //Get the Property Details
        for(Broker_Price_Opinion__c bpoRec: bpoList){
            propertyIdSet.add(bpoRec.Property__c);
            propToBpoMap.put(bpoRec.Property__c, bpoRec);
            
        }
        List <Property2__c> propList = [SELECT  Id, Name, Street_Address__c,City__c,State__c,County__c,Zip__c,Seller_Provided_List_Price__c,Property_Type__c ,Bathrooms_SUM__c,Bedrooms_SUM__c,Lot_Size__c,Square_Feet__c,
                                        Annual_BPO_Trigger_Date__c,BPO_Trigger_Date__c,Year_Built__c,Type_of_BPO_Trigger__c, PropertyId__c,Client__c,PropertyCode__c 
                                        FROM Property2__c WHERE ID IN: propertyIdSet];
        if(propList != null && propList.size() >0){
            for(Property2__c prop: propList){
                propMap.put(prop.Id, prop);
            }
        }
        
        Boolean result = BatchBPOServiceCalloutHelper.callBPOServiceCallout(propToBpoMap, propMap, false);
    }

    global void finish(Database.BatchableContext bc){

    }
    
    global void execute (SchedulableContext SC) {
        Database.executeBatch(new BPOServiceCalloutBatch(),1);
    }
}
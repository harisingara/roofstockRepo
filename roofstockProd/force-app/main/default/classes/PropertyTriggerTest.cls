@isTest
public class PropertyTriggerTest {
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void syncBpmTransactionStatusPending(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator API'];
        
        User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo10@camfed.org');
        insert u1;
        Fund_Owner__c fo = new Fund_Owner__c();
        fo.Name = 'SFDC';
        insert fo;
        System.runAs(u1){
            Transaction__c trans = new Transaction__c();
            trans.Name = 'New Transaction';
            trans.Transaction_Id__c = '123458';
            insert trans;
            
            Property__c prop = new Property__c();
            prop.RS_Contingency_Status__c = 'NonContingent';
            prop.RS_Transaction_Status__c = 'New';
            prop.Status__c = 'In Contract';
            prop.Fund__c = fo.Id;
            prop.RS_TransactionId__c = '123458'; 
            prop.Estimated_Resale__c = 200;
            prop.List_Price__c = 500;
            prop.Neighborhood_Score__c = '3';
            insert prop;
        }
        
    }
    static testMethod void syncBpmTransactionStatusNew(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator API'];
        
        User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo100@camfed.org');
        insert u1;
        Fund_Owner__c fo = new Fund_Owner__c();
        fo.Name = 'SFDC';
        insert fo;
        System.runAs(u1){
            Property__c prop = new Property__c();
            prop.RS_Transaction_Status__c = 'New';
            prop.Status__c = 'In Contract';
            prop.Fund__c = fo.Id;
            prop.Estimated_Resale__c = 200;
            prop.List_Price__c = 500;
            prop.Neighborhood_Score__c = '3';
            insert prop;
        }
        
    }
    static testMethod void syncBpmTransactionStatusTransactionCompleted(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator API'];
        
        User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo1000@camfed.org');
        insert u1;
        Fund_Owner__c fo = new Fund_Owner__c();
        fo.Name = 'SFDC';
        insert fo;
        System.runAs(u1){
            Property__c prop = new Property__c();
            prop.RS_Transaction_Status__c = 'TransactionCompleted';
            prop.Status__c = 'In Contract';
            prop.Fund__c = fo.Id;
            prop.Estimated_Resale__c = 200;
            prop.List_Price__c = 500;
            prop.Neighborhood_Score__c = '3';
            insert prop;
        }
        
    }
    static testMethod void syncBpmTransactionStatusTransactionCancelled(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator API'];
        
        User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo100000@camfed.org');
        insert u1;
        Fund_Owner__c fo = new Fund_Owner__c();
        fo.Name = 'SFDC';
        insert fo;
        System.runAs(u1){
            Property__c prop = new Property__c();
            prop.RS_Transaction_Status__c = 'TransactionCancelled';
            prop.Status__c = 'In Contract';
            prop.Fund__c = fo.Id;
            prop.Estimated_Resale__c = 200;
            prop.List_Price__c = 500;
            prop.Neighborhood_Score__c = '3';
            insert prop;
        }
        
    }
    
    static testMethod void syncBpmTransactionStatusUpdate(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator API'];
        
        User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo1550@camfed.org');
        insert u1;
        Fund_Owner__c fo = new Fund_Owner__c();
        fo.Name = 'SFDC';
        insert fo;
        System.runAs(u1){
            Property__c prop = new Property__c();
            prop.RS_Contingency_Status__c = 'NonContingent';
            prop.RS_Transaction_Status__c = 'New';
            prop.Status__c = 'In Contract';
            prop.Fund__c = fo.Id;
            prop.Estimated_Resale__c = 200;
            prop.List_Price__c = 500;
            prop.Neighborhood_Score__c = '3';
            insert prop;
            
            Property__c propt = [select Id from Property__c where Id=:prop.Id];
            update propt;
        }
        
    }
    static testMethod void syncBpmTransactionStatusDelete(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator API'];
        
        User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='dprobertdemo1250@camfed.org');
        insert u1;
        Fund_Owner__c fo = new Fund_Owner__c();
        fo.Name = 'SFDC';
        insert fo;
        System.runAs(u1){
            Property__c prop = new Property__c();
            prop.RS_Contingency_Status__c = 'NonContingent';
            prop.RS_Transaction_Status__c = 'New';
            prop.Status__c = 'In Contract';
            prop.Fund__c = fo.Id;
            prop.Estimated_Resale__c = 200;
            prop.List_Price__c = 500;
            prop.Neighborhood_Score__c = '3';
            insert prop;
            
            Property__c propt = [select Id from Property__c where Id=:prop.Id];
            delete propt;
        }
        
    }
    static testMethod void propertyException() {

        TriggerDispatcher.forceException = true;
        try{
            
            Property__c pt = new Property__c();
            pt.Name = 'SFDC';
            insert pt;
        }
        catch(Exception ex){
            //System.debug('=='+evt.Id);
        }
    }
    
    static testMethod void populatePropertyUnitBasedOnUnitRiid(){
        
        Property2__c p = new Property2__c();
        p.name = '123 Main St Tracy CA 95391';
        insert p;
        
        Fund_Owner__c f=  new Fund_Owner__c();
        f.name = 'test fund';
        insert f;

        
        
        Property_Unit__c pu = new Property_Unit__c();
        pu.name = '123 Main St Tracy CA 95391';
        pu.Property__c = p.Id;
        pu.Bathrooms__c = 3;
        pu.Bedrooms__c = 2.5;
        pu.HomeCode__c = 'q2000';
        pu.Occupancy_Status__c = 'Vacant Unrented Not Ready';  
        pu.PropertyUnitId__c = 'test-uiid'; 
        insert pu;
        
        Property__c prop=  new Property__c();
        prop.name = 'test prop';
        prop.Property_Unit_Riid__c = 'test-uiid';
        prop.fund__c = f.id;
        prop.Neighborhood_Score__c = '3';
        insert prop;
        
    }
}
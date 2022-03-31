@isTest
public class TurnHelperTest {
    static{
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void turnHelperTest(){
        Id leasingPropertyRecordTypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByName()
            .get('Leasing')
            .getRecordTypeId();
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
        p.Year_Built__c = '1972';
        p.name = '123 Main St Tracy CA 95391';
        p.recordtypeid = leasingPropertyRecordTypeId;
        insert p;
        
        Property_Unit__c pu = new Property_Unit__c();
        pu.name = '123 Main St Tracy CA 95391';
        pu.Property__c = p.id;
        pu.Bathrooms__c = 3;
        pu.Bedrooms__c = 2.5;
        pu.HomeCode__c = 'q2000';
        
        insert pu;
        
        Leasing_Availability__c la = new Leasing_Availability__c();
        la.Property_Unit__c = pu.Id;
        insert la;
        
        Turn__c t = new Turn__c();
        t.Status__c = 'Upcoming';
        t.Move_Out_Date__c = Date.today();
        t.Property_Unit__c = pu.Id;
        insert t;
        
        Turn__c tr = [select Id from Turn__c where Id=:t.Id];
        update tr;
        
        Turn__c turnDelete = [select Id from Turn__c where Id=:tr.Id];
        delete turnDelete;
        
        
    }
    static testMethod void TurnControllerException() {
        TriggerDispatcher.forceException = true;
        try{
            Id leasingPropertyRecordTypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByName()
                .get('Leasing')
                .getRecordTypeId();
            Property2__c p = new Property2__c();
            p.Market__c = 'Atlanta';
            p.PropertyCode__c = 'q1000';
            p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
            p.Property_Type__c = 'Single Family';
            p.Year_Built__c = '1972';
            p.name = '123 Main St Tracy CA 95391';
            p.recordtypeid = leasingPropertyRecordTypeId;
            insert p;
            
            Property_Unit__c pu = new Property_Unit__c();
            pu.name = '123 Main St Tracy CA 95391';
            pu.Property__c = p.id;
            pu.Bathrooms__c = 3;
            pu.Bedrooms__c = 2.5;
            pu.HomeCode__c = 'q2000';
            insert pu;
            
            Leasing_Availability__c la = new Leasing_Availability__c();
            la.Property_Unit__c = pu.Id;
            insert la;
            
            Turn__c t = new Turn__c();
            t.Status__c = 'Upcoming';
            t.Move_Out_Date__c = Date.today();
            t.Property_Unit__c = pu.Id;
            insert t;
            
            Turn__c tr = [select Id from Turn__c where Id=:t.Id];
            update tr;
        }
        catch(Exception ex){
            
        }
    }
    
}
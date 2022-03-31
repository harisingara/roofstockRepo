@isTest
public class InspectionTest {
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void TaskControllerInsert() {
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
        //p.Year_Built__c = '1972';
        p.name = '123 Main St Tracy CA 95391';
        insert p;
        
        Property_Unit__c pu = new Property_Unit__c();
        pu.name = '123 Main St Tracy CA 95391';
        pu.Property__c = p.id;
        pu.Bathrooms__c = 3;
        pu.Bedrooms__c = 2.5;
        pu.HomeCode__c = 'q2000';
        insert pu;
        
        Job__c job = new Job__c();
        job.Name = 'SFDC';
        job.Property__c = p.Id;
        job.Property_Unit__c = pu.Id;
        insert job;
        
        Transaction__c t = new Transaction__C();
        t.name = '123 Main St Tracy CA 95391';
        t.Buyer_Property_Instance__c = p.Id;
        Insert t;
        
        Inspection__c dil = new Inspection__c();
        dil.Name = 'sfdc';
        dil.Property_Unit__c = pu.Id;
        dil.Job__c = job.Id;
        insert dil;

        InspectionHelper.inspection(dil.Id);
        InspectionHelper.associatedInspection(job.Id);
        InspectionHelper.associatedInspectionToJob(dil.Id,job.Id);
        InspectionHelper.associatedTransactionToInspection(dil.Id);

        dil.Inspection_status__c = 'Completed';
        dil.Buy_No_Buy__c  = 'Buy';
        Update dil;

        //InspectionHelper.sendStatusUpdateToBpm();

        List<Inspection__c> inspectionList = [select Id from Inspection__c];
        delete inspectionList;
		        
    }
    static testMethod void InspectionControllerException() {
        TriggerDispatcher.forceException = true;
        Inspection__c del;
        try{
            del = new Inspection__c();
            del.name = 'SFDC';

            insert del;
        }
        catch(Exception ex){
            System.debug('=='+del.Id);
        }
        
        
    }
    
    
}
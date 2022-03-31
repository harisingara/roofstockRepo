@IsTest
public class UpdatePropertyAttributesControllerTest {
	 static { 
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    @testsetup 
    static void testData() {
        Id transRecordtypeId = Schema.SObjectType.Transaction__C.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        Id propertyRecordtypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByName().get('Roofstock').getRecordTypeId();
        
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
        //p.Year_Built__c = '1972';
        p.name = '123 Main St Tracy CA 95391';
        p.Street_Address__c = '1234 USA';
        p.City__c = 'sdfsd';
        p.County__c = 'US';
        p.Zip__c ='00009';
        p.State__c = 'CO';
        p.Seller_Provided_List_Price__c = 500;
        p.Square_Feet__c = '456';
        insert p;
        
        Property_Unit__c pu = new Property_Unit__c();
        pu.name = '123 Main St Tracy CA 95391';
        pu.Property__c = p.id;
        pu.Bathrooms__c = 3;
        pu.Bedrooms__c = 2.5;
        pu.HomeCode__c = 'q2000';
        pu.Occupancy_Status__c = 'Vacant Unrented Ready';
        pu.Operating_Status__c = 'Leasable';
        insert pu;
        
        Transaction__c trans = new Transaction__c();
        trans.Name = 'Test Transaction';
        trans.Buyer_Property_Instance__c = p.id;
        trans.RecordtypeId = transRecordtypeId;
        insert trans;
        
        Inspection__c insp = new Inspection__C();
        insp.Name = 'Test Inspection';
        insp.Inspection_Type__c = 'Diligence';
        insp.Inspection_Status__c = 'Completed';
        insp.Property__c = p.id;
        insp.Property_Unit__c = pu.id;
        insp.Transaction__c = trans.id;
        insert insp; 
        
        HOA__c hoa = new HOA__c();
        hoa.name = 'Test HOA record';
        hoa.Property__c = p.id;
        hoa.Property_Unit__c = pu.id;
        insert hoa;
    }
    
     @isTest
    public static void getpropertyRecordIds() {
        Inspection__c insp = [select id, Name from Inspection__c LIMIT 1];
        String inspId = insp.id;
        UpdatePropertyAttributesController.propertyRecordIds(inspId);
    }
    @isTest
    public static void getpropertyUnitRecords() {
        Property_Unit__c propU = [select id, Name from Property_Unit__c LIMIT 1];
        String propid = propU.id;
        UpdatePropertyAttributesController.propertyRecordIds(propid);
    }
     @isTest
    public static void getHoaRecords() {
        hoa__c hoa = [select id, Name from hoa__c LIMIT 1];
        String hoaId = hoa.id;
        UpdatePropertyAttributesController.propertyRecordIds(hoaId);
    }
}
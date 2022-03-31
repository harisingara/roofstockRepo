@IsTest
public class PropertyAndPropertyUnitControllerTest {
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
        
    }
    
    @IsTest
    public static void testDataValue() {
        PropertyAndPropertyUnitController.poolTypeValues();
        PropertyAndPropertyUnitController.mailBoxTypeValues();
        PropertyAndPropertyUnitController.garbageDisposalBinTypeValues();
        PropertyAndPropertyUnitController.trashrResponsibilityValues();
        PropertyAndPropertyUnitController.trashBinAvailableValues();
        PropertyAndPropertyUnitController.recycleBinavailableValues();
        PropertyAndPropertyUnitController.hasPoolValues();
        Property2__c prop = [select id from Property2__c LIMIT 1];
        Property_Unit__c propU = [select id from property_unit__c LIMIT 1];
        PropertyAndPropertyUnitController.propertyPropertyUnitDetails(prop.id,propU.id);
        PropertyAndPropertyUnitController.propertyPropertyUnitDetails(prop.id,null);
        PropertyAndPropertyUnitController.propertyPropertyUnitDetails(null,propU.id);
        
        PropertyAndPropertyUnitController.savePropertyPropertyUnitDetails(prop.id,propU.id,null);
        
    }
}
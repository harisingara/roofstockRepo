@isTest
public class UpdateHOACompanyContactControllerTest {
    static { 
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    @testsetup 
    static void testData() {
        Property2__c p = new Property2__c(); 
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'qHOATST';
        p.PropertyId__c = '72bcf440-RESTHoaControllerTest';
        p.Property_Type__c = 'Single Family';
        p.name = '123 Main St Tracy CA 95391';
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
    
        Vendor__c ven = new Vendor__c();
        ven.Name= 'test vendor';
        ven.Remittance_Address__c='400 george st';
        ven.Email__c = 'test@gmail.com';
        ven.Phone__c= '9898989898';
        ven.Type__c = 'HOA Company Contact';   
        insert ven;
            
        Vendor__c ven1 = new Vendor__c();
        ven1.Name= 'test vendor1';
        ven1.Type__c = 'HOA Company';       
        insert ven1;
        
        HOA__c hoa = new HOA__c();
        hoa.name = 'Test HOA record';
        hoa.Property__c = p.id;
        hoa.Property_Unit__c = pu.id;
        hoa.HOA_Company_Contact1__c = ven.id;
        hoa.HOA_Company1__c = ven1.id;
        insert hoa;
    }
    
    @isTest
    public static void getVendorRecords() {
        HOA__c hoaId = [select id from HOA__C LIMIT 1];
        UpdateHOACompanyContactController.vendorRecords(hoaId.Id);
        String saverec = '{\"companyName\":\"test vendor1\",\"rsAccountId\":\"123123\",\"name\":\"test vendor\",\"phone\":\"1231231231\",\"email\":\"asdd@gmail.com\",\"remittanceAddress\":\"test add 1\"}';
        String saverec1 = '{\"companyName\":\"test vendor\",\"rsAccountId\":\"123123\",\"name\":\"test vendor\",\"phone\":\"1231231231\",\"email\":\"asdd@gmail.com\",\"remittanceAddress\":\"test add 1\"}';
        String saverec2 = '{\"companyName\":\"test vendor1\",\"rsAccountId\":\"123123\",\"name\":\"test vendor\",\"phone\":\"1231231231\",\"email\":\"asdd@gmail.com\",\"remittanceAddress\":\"test add 2\"}';
        String saverec3 = '{\"companyName\":\"test vendor 2\",\"rsAccountId\":\"123123\",\"name\":\"test vendor22\",\"phone\":\"1231231231\",\"email\":\"asdd@gmail.com\",\"remittanceAddress\":\"test add 2\"}';
        String recid = hoaId.Id;
        UpdateHOACompanyContactController.saveHOAVendorInfo(saverec, recid);
        UpdateHOACompanyContactController.saveHOAVendorInfo(saverec1, recid);
        UpdateHOACompanyContactController.saveHOAVendorInfo(saverec2, recid);
        UpdateHOACompanyContactController.saveHOAVendorInfo(saverec3, recid);
    }
    
}
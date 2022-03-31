@isTest
public class SellerFilesControllerTest {
    static { 
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void SellerFilesController() {
        Opportunity op = new Opportunity();
        op.Name = 'sfdc';
        op.CloseDate = Date.today();
        op.StageName = 'Closed Lost';
        insert op;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSellerFiles());
        SellerFilesController.sellerFiles(op.Id);
        Test.stopTest();
        
        
    }
    
}
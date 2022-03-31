@isTest
public class RentlyCommentsTest {
    
    static{
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void RentlyCommentsTest() {
        
        TestDataFactory.createTestRentalListingRecords(1);
        RentlyComments.retrieveFeedback('123');
    }
    
}
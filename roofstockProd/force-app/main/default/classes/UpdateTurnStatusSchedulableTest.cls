@isTest
public with sharing class UpdateTurnStatusSchedulableTest {
    static{
        TestDataFactory.insertHierarchyCustomSettingData();        
        TestDatafactory.createTestTurnListingRecords(1);
    }
    static testMethod void updateTurnStatusToInProgress(){
        
        Test.startTest();
        UpdateTurnStatusSchedulable turnSchedule = new UpdateTurnStatusSchedulable();
        DataBase.executeBatch(turnSchedule); 
        UpdateTurnStatusSchedulable sh1 = new UpdateTurnStatusSchedulable();      
        String sch = '0  00 1 3 * ?';
        system.schedule('Test', sch, sh1);
        Test.stopTest();
        
    }
    
}
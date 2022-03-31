@isTest
public class ContactTriggerTest {
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void ContactTriggerTest() {
        TriggerDispatcher.forceException = true;
        try{
        Contact con = new Contact();
        con.LastName = 'Salesforce';
        insert con;
        }
        catch(Exception ex){
            
        }
        
    }
    
}
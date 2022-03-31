@isTest
public class ContactControllerTest {
    
        static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    public static testMethod void certification(){
    	Account acc = new Account();
        acc.Name='Transaction';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='SFDC';
        insert con;
        
        ContactController.fetchAllAssoictedRecords(con.Id,'Transaction');
        ContactController.fetchAllAssoictedRecords(con.Id,'Certification');
    }

}
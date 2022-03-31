@isTest
public class RoofstockOneAdminToolTest {
	static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void RoofstockOneAdminToolTest() {
        Contact con = new Contact();
        con.LastName = 'sfdc';
        insert con;
        Investment_Account__c ia = new Investment_Account__c();
        ia.Primary_Contact__c = con.Id;
        insert ia;
        ATF_Work_Queue__c wq = new ATF_Work_Queue__c();
        wq.Contact__c = con.Id;
        wq.Investment_Account__c = ia.Id;
        insert wq;
        RoofstockOneAdminTool.adminToolUrl(wq.Id);
        
    }
}
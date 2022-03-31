@isTest
public class SendEmailLeadTest {
      static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    
    static testMethod void sendEmailLead() {
        Lead l = new Lead();
        l.LastName = 'sfdc';
        l.company = 'Salesforce';
        insert l;
        SendEmailLead.leadDetails(l.Id);
        
    }

}
@isTest
public class TriggerCampaignMemberTest {
    static {
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void RESTMCLeadTestException() {
        contact con = new contact();
        con.LastName = 'sfdc';
        insert con;
        Campaign Camp= new Campaign(Name='Test');
        insert Camp;
        
        CampaignMember newMember = 
            new CampaignMember(ContactId = con.id, status='Sent', campaignid = Camp.id);
        insert newMember;
    }
    
}
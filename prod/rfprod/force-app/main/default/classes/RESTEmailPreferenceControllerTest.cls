@isTest
public class RESTEmailPreferenceControllerTest {


  //static initialization code (load test data)
  static {
    //create test users
    TestDataFactory.insertHierarchyCustomSettingData();
    TestDataFactory.createTestRecords(1,1);
    

  }

  static testMethod void createEmailHelperTest() {
    User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
    System.debug('user' + u1);
    string email = 'test0@nowhere.com';
    System.runAs(u1) {
        Test.startTest();
      RESTEmailPreferenceHelper.EMailPreferenceResponse response = RESTEmailPreferenceHelper.UpdatePreference(
        email,'unsubscribe'
      );

    Test.stopTest();
    List<Contact> contacts = [
      SELECT id, email,HasOptedOutOfEmail
      FROM contact
      where email = :email
    ];
    system.assertEquals(contacts.size(), 1);    
    system.assertEquals(contacts[0].HasOptedOutOfEmail, true); 
    }
  }
  static testMethod void createEmailUnSubscribeRestAPITest() {
    User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
    string email = 'test0@nowhere.com';
  
    RESTEmailPreferenceHelper.EMailPreferenceRequest request = new RESTEmailPreferenceHelper.EMailPreferenceRequest();
    request.email   = email;
    request.action  = 'unsubscribe';
    RESTEmailPreferenceHelper.EmailRequest EmailRequest = new RESTEmailPreferenceHelper.EmailRequest();
	EmailRequest.preference = request; 
    String sReq = JSON.serialize(EmailRequest);

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/UpdateEmailPreference';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(sReq);
    RestContext.request = req;
    RestContext.response = res;

    System.runAs(u1) {
      Test.startTest();
      RESTEmailPreferenceController.updatePreference();
      Test.stopTest();
      List<Contact> contacts = [
        SELECT id, email,HasOptedOutOfEmail
        FROM contact
        where email = :email
      ];
      system.assertEquals(contacts.size(), 1);    
      system.assertEquals(contacts[0].HasOptedOutOfEmail, true);    

      system.assertEquals(res.statusCode, 200);

      
    }
  }
  
  static testMethod void createEmailSubscribeRestAPITest() {
    User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
    string email = 'test0@nowhere.com';
  
    RESTEmailPreferenceHelper.EMailPreferenceRequest request = new RESTEmailPreferenceHelper.EMailPreferenceRequest();
    request.email   = email;
    request.action  = 'subscribe';
	RESTEmailPreferenceHelper.EmailRequest EmailRequest = new RESTEmailPreferenceHelper.EmailRequest();
	EmailRequest.preference = request; 
    String sReq = JSON.serialize(EmailRequest);

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/UpdateEmailPreference';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(sReq);
    RestContext.request = req;
    RestContext.response = res;

    System.runAs(u1) {
      Test.startTest();
      RESTEmailPreferenceController.updatePreference();
      Test.stopTest();
      List<Contact> contacts = [
        SELECT id, email,HasOptedOutOfEmail
        FROM contact
        where email = :email
      ];
      system.assertEquals(contacts.size(), 1);    
      system.assertEquals(contacts[0].HasOptedOutOfEmail, false);    

      system.assertEquals(res.statusCode, 200);
      req.requestBody = Blob.valueOf('sReq');
      RESTEmailPreferenceController.updatePreference();
      
    }
  }
    static testMethod void UpdatePreference() {
        lead l = new lead();
        l.lastName='SFDC';
        l.Email = 'sfdc@gmail.com';
        l.Company = 'Salesforce';
        insert l;
        
        Database.LeadConvert lc = new database.LeadConvert();  
        lc.setLeadId( l.Id );  
        lc.setDoNotCreateOpportunity( true );  
        lc.setConvertedStatus( 'Closed - Converted' );  
        
        Database.LeadConvertResult lcr = Database.convertLead(lc, false); 
        
        RESTEmailPreferenceHelper.UpdatePreference('sfdc@gmail.com','New');
    }

}
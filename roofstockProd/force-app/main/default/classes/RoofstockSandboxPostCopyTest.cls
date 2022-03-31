@isTest
private class RoofstockSandboxPostCopyTest {
     static{
        TestDataFactory.insertHierarchyCustomSettingData();
    }
  @isTest
  static void test_post_copy() {
    Profile p = [SELECT id FROM Profile WHERE name = 'Standard User'];

    Lead user1;
    Contact user2;
    Account acc1;
    Opportunity opp1;
    Transaction__c trans;
    Certification__c cert;
    Property2__c property;
    Property_Unit__c propertyUnit;

    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_tools_runas.htm
    System.runAs(new User(id = UserInfo.getUserId())) {
      System.debug('user' + UserInfo.getUserId());

      user1 = newLead('User 1', 'last 1', 'lead@example.com','34we3ertrf');
      user2 = newContact('User 2', 'last 2', 'contact@example.com','34we3ertrf');
      acc1 = newAccount('Account1', 'account@example.com','123456');
      opp1 = newOpportunity(acc1, 'fake-opp@example.com');
	  trans = newTransaction();
      cert = newCertification(); 
      property = newProperty('Property1', 'retr3456df');
      propertyUnit = newPropertyUnit('PU1','587yy5875');
          
      insert new List<Lead>{ user1 };
      insert new List<Contact>{ user2 };
      insert new List<Account>{ acc1 };
      insert new List<Opportunity>{ opp1 };
      insert new List<Transaction__c>{ trans };
      insert new List<Certification__c>{ cert };
      insert new List<Property2__c>{property};
      insert new List<Property_Unit__c>{propertyUnit};
    }

    Test.startTest();

    Test.testSandboxPostCopyScript(
      new RoofstockSandboxPostCopy(), // apex class to run
      '00D1a000040BlpQ', // fake org id
      '00D90000000KY45', // fake sandbox id
      'My Sandbox' // fake sandbox name
    );

    Test.stopTest();

    user1 = [SELECT id, email FROM Lead WHERE id = :user1.id];
    //System.assertEquals('lead@example.com.invalid', user1.email);

    user2 = [SELECT id, email FROM Contact WHERE id = :user2.id];
    //System.assertEquals('contact@example.com.invalid', user2.email);

    acc1 = [SELECT id, Company_Email__c FROM Account WHERE id = :acc1.id];
    //System.assertEquals('account@example.com.invalid', acc1.Company_Email__c);

    opp1 = [SELECT id, HOA_Email__c FROM Opportunity WHERE id = :opp1.id];
    System.debug('user' + opp1);

    //System.assertEquals('fake-opp@example.com.invalid', opp1.HOA_Email__c);
  }
  private static Lead newLead(String firstName, String lastName, String email,String bpmContactId) {
    return new Lead(
      firstName = firstName,
      lastName = lastName,
      email = email,
      BPM_Contact_Id__c = bpmContactId,
      company = 'Fake Company'
    );
  }

  private static Contact newContact(
    String firstName,
    String lastName,
    String email,
    String bpmContactId
      
  ) {
    return new Contact(
      firstName = firstName,
      lastName = lastName,
      email = email,
      BPM_Contact_Id__c = bpmContactId
    );
  }

  private static Account newAccount(String name, String email,String rsAccountId) {
    return new Account(Company_Email__c = email, name = name,Roofstock_Account_ID__c = rsAccountId);
  }
  private static Opportunity newOpportunity(Account acc, String email) {
    Id leasingRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('Leasing')
      .getRecordTypeId();

    return new Opportunity(
      name = 'opp1',
      stageName = 'New',
      recordtypeid = leasingRTId,
      CloseDate = Date.Today().addDays(14),
      account = acc,
      HOA_Email__c = email
    );
  }
  
    private static Transaction__c newTransaction(){
        return new Transaction__c(
            Name = 'Trans',
            Buyer_BPM_Contact_Email__c = 'sfdc@gmail.com',
            Buyer_Broker_Contact_Email__c = 'sfdc@gmail.com',
            Buyer_Contact1_Email__c = 'sfdc@gmail.com',
            Buyer_Contact2_Email__c = 'sfdc@gmail.com',
            Buyer_PM_Contact_Email__c = 'sfdc@gmail.com',
            Closing_Attorney_Contact_Email__c = 'sfdc@gmail.com',
            Escrow_Company_Contact_Email__c = 'sfdc@gmail.com',
            Insurance_Company_Contact_Email__c = 'sfdc@gmail.com',
            Lender_Broker_Contact_Email__c = 'sfdc@gmail.com',
            Roofstock_Accounting_Email__c = 'sfdc@gmail.com',
            Roofstock_Account_Manager_Email__c = 'sfdc@gmail.com',
            Roofstock_Advisor_Email__c = 'sfdc@gmail.com',
            Roofstock_Customer_Service_Email__c = 'sfdc@gmail.com',
            Roofstock_Inventory_Owner_Email__c = 'sfdc@gmail.com',
            Roofstock_Project_Manager_Email__c = 'sfdc@gmail.com',
            Roofstock_TC_User_Email__c = 'sfdc@gmail.com',
            Seller_Contact_Email__c = 'sfdc@gmail.com',
            Seller_Listing_Agent_Contact_Email__c = 'sfdc@gmail.com',
            Seller_PM_Contact_Email__c = 'sfdc@gmail.com',
            Title_Company_Contact_Email__c = 'sfdc@gmail.com',
            Underwriting_Analyst_Email__c = 'sfdc@gmail.com'
        
        );
        
    }
     private static Certification__c newCertification(){
         return new Certification__c(
             Name = 'Certification',
             Roofstock_Account_Coordinator_Email__c = 'sfdc@gmail.com',
             Roofstock_Account_Executive_Email__c = 'sfdc@gmail.com',
             Roofstock_Account_Manager_Email__c = 'sfdc@gmail.com'
         );
             
             }
     private static Property2__c newProperty(String name, String propertyId){
         return new Property2__c(
             Name = name,
             PropertyId__c = propertyId
             
         );
             
             }
    private static Property_Unit__c newPropertyUnit(String name, String propertyUnitId){
         Property2__c property = new Property2__c();
         property.Name = 'property';
         property.PropertyId__c = '12345';
         insert property;
        
         return new Property_Unit__c(
             Name = name,
             PropertyUnitId__c = propertyUnitId,
             Property__c = property.Id
             
         );
             
             }
}
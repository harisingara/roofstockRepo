@isTest
private class EmailCaseContactRole_Test
{
              static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    @isTest
    public static void test() {
        // Create account
        Account a = new Account(Name = 'Test', BillingCountry = 'USA');
        insert a;

        // Create contact
        Contact co = new Contact(FirstName = 'Test', 
                                LastName = 'Test', 
                                Email = 'test@test.com', 
                                AccountId = a.Id);
        insert co;
        TestDataFactory.insertHierarchyCustomSettingData();
        // Case
        Case ca = new Case(Subject = 'test',
                          AccountId = a.Id,
                          Status = 'Open',
                          Type = 'Feature Request');
        insert ca;

        // Case contact roles
        CaseContactRole ccr = new CaseContactRole(ContactId = co.Id, 
                                                  Role = 'Property Manager', 
                                                  CasesId = ca.Id);
        insert ccr;
        
        ca.Type = 'Rent Guarantee Program Purchase';
        update ca;
 
        List<Id> cases = new List<Id>();
        cases.add(ca.Id);
        
        System.Test.startTest();
        EmailCaseContactRole.sendEmails(cases);
        System.Test.stopTest();
    }
}
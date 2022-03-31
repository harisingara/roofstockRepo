@isTEst
public class RestInvestmentAccountControllerTest {
    static { 
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void RestInvestmentAccountControllerTest1(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Roofstock_Contact').getRecordTypeId();        
        Contact con = new Contact();
        con.LastName = 'sfdc';
        con.email = 'daria@roofstock.com';
        con.AccountId = acc.Id;
        con.RecordTypeId = contactRecordTypeId;
        insert con;
        
        List<RESTInvestmentAccountHelper.InvestmentAccounts> investmentList = new List<RESTInvestmentAccountHelper.InvestmentAccounts>();
        RESTInvestmentAccountHelper.InvestmentAccounts ia = new RESTInvestmentAccountHelper.InvestmentAccounts();
        ia.investmentAccountId ='123';
        ia.investmentAccountName = 'iaName';
        ia.isRoofstockManaged = true;
        ia.primaryContactEmail = 'sf@gmail.com';
        ia.primaryContactFirstName = 'sfdc';
        ia.primaryContactLastName = 'sfdc';
        ia.primaryContactPhone = '8987655456';
        ia.roofstockAccountId = '1234';
        investmentList.add(ia);
        
        RESTInvestmentAccountHelper.InvAccWrap iaRequest = new RESTInvestmentAccountHelper.InvAccWrap();
        iaRequest.investmentAccountList = investmentList;
        String sReq = JSON.serialize(iaRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/investmentaccount';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RestInvestmentAccountController.upsertInvestmentAccount();
        Test.stopTest();
    }
    static testMethod void RestInvestmentAccountControllerTest2(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Roofstock_Contact').getRecordTypeId();        
        Contact con = new Contact();
        con.LastName = 'sfdc';
        con.email = 'daria@roofstock.com';
        con.AccountId = acc.Id;
        con.RecordTypeId = contactRecordTypeId;
        insert con;
        
        List<RESTInvestmentAccountHelper.InvestmentAccounts> investmentList = new List<RESTInvestmentAccountHelper.InvestmentAccounts>();
        RESTInvestmentAccountHelper.InvestmentAccounts ia = new RESTInvestmentAccountHelper.InvestmentAccounts();
        ia.investmentAccountId ='123';
        ia.investmentAccountName = 'iaName';
        ia.isRoofstockManaged = false;
        ia.primaryContactEmail = 'sf@gmail.com';
        ia.primaryContactFirstName = 'sfdc';
        ia.primaryContactLastName = 'sfdc';
        ia.primaryContactPhone = '8987655456';
        ia.roofstockAccountId = '1234';
        investmentList.add(ia);
        
        RESTInvestmentAccountHelper.InvAccWrap iaRequest = new RESTInvestmentAccountHelper.InvAccWrap();
        iaRequest.investmentAccountList = investmentList;
        String sReq = JSON.serialize(iaRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/investmentaccount';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RestInvestmentAccountController.upsertInvestmentAccount();
        Test.stopTest();
    }
    
}
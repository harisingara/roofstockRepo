@isTest(SeeAllData=false)
public class RESTBulkSellerOpportunityControllerTest {
    static { 
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void RESTBulkSellerOpportunityController() {
        Id Profile_id = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User u = [select Id from User where ProfileId =: Profile_id and isActive=true][0];
        List<RESTBulkSellerOpportunityHelper.SellerOpportunities> sellerOpportunityList = new List<RESTBulkSellerOpportunityHelper.SellerOpportunities>();
        RESTBulkSellerOpportunityHelper.SellerOpportunities sellerOpportunity = new RESTBulkSellerOpportunityHelper.SellerOpportunities();
        
        sellerOpportunity.propertyState = 'CA';
        sellerOpportunity.bulkSaleNumberOfProperties = 5;
        sellerOpportunity.sellerNotes = 'Roofstock Property';
        sellerOpportunity.sellerBpmOpportunityId = 1234567;
        sellerOpportunity.sellerContactEmail = 'seller@roofstock.com';
        sellerOpportunity.SellerContactphone = '9876544567';
        sellerOpportunity.SellerFirstName = 'Abraham ';
        sellerOpportunity.SellerLastName = 'Lincoln';
        sellerOpportunityList.add(sellerOpportunity);
        system.RunAs(u){
            
            Lead l = new Lead();
        l.firstName = 'Abraham';
        l.lastName='Lincoln';
        l.Company = 'sfdc';
        l.Email = 'seller@roofstock.com';
        l.Phone = '9876544567';
        insert l;
            
            RESTBulkSellerOpportunityHelper.SellerOpportunitiesWrap sellerRequest = new RESTBulkSellerOpportunityHelper.SellerOpportunitiesWrap();
            sellerRequest.sellerOpportunityList = sellerOpportunityList;
            String sReq = JSON.serialize(sellerRequest);
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/createBulkSellerOpportunities';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(sReq);
            
            RestContext.request = req;
            RestContext.response = res;
            
            Test.startTest();
            RESTBulkSellerOpportunityController.createOpportunities();
            Test.stopTest();
        }
    }
    
    static testMethod void RESTBulkSellerOpportunityController2() {
        Id Profile_id = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User u = [select Id from User where ProfileId =: Profile_id and isActive=true][0];
        List<RESTBulkSellerOpportunityHelper.SellerOpportunities> sellerOpportunityList = new List<RESTBulkSellerOpportunityHelper.SellerOpportunities>();
        RESTBulkSellerOpportunityHelper.SellerOpportunities sellerOpportunity = new RESTBulkSellerOpportunityHelper.SellerOpportunities();
        
        sellerOpportunity.propertyState = 'CA';
        sellerOpportunity.bulkSaleNumberOfProperties = 5;
        sellerOpportunity.sellerNotes = 'Roofstock Property';
        sellerOpportunity.sellerBpmOpportunityId = 1234567;
        sellerOpportunity.sellerContactEmail = 'seller@roofstock.com';
        sellerOpportunity.SellerContactphone = '9876544567';
        sellerOpportunity.SellerFirstName = 'Abraham ';
        sellerOpportunity.SellerLastName = 'Lincoln';
        sellerOpportunityList.add(sellerOpportunity);
        system.RunAs(u){
            
            RESTBulkSellerOpportunityHelper.SellerOpportunitiesWrap sellerRequest = new RESTBulkSellerOpportunityHelper.SellerOpportunitiesWrap();
            sellerRequest.sellerOpportunityList = sellerOpportunityList;
            String sReq = JSON.serialize(sellerRequest);
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/createBulkSellerOpportunities';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(sReq);
            
            RestContext.request = req;
            RestContext.response = res;
            
            Test.startTest();
            RESTBulkSellerOpportunityController.createOpportunities();
            Test.stopTest();
        }
    }
    
    static testMethod void RESTBulkSellerOpportunityController3() {
        Id Profile_id = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User u = [select Id from User where ProfileId =: Profile_id and isActive=true][0];
        List<RESTBulkSellerOpportunityHelper.SellerOpportunities> sellerOpportunityList = new List<RESTBulkSellerOpportunityHelper.SellerOpportunities>();
        RESTBulkSellerOpportunityHelper.SellerOpportunities sellerOpportunity = new RESTBulkSellerOpportunityHelper.SellerOpportunities();
        
        Account acc = new Account();
        acc.Name = 'sfdc';
        insert acc;
        
        Contact con =new Contact();
        con.LastName ='sfdc';
        con.FirstName = 'sfdc';
        con.Email = 'seller@roofstock.com';
        con.AccountId = acc.Id;
        insert con;
        
        sellerOpportunity.propertyState = 'CA';
        sellerOpportunity.bulkSaleNumberOfProperties = 5;
        sellerOpportunity.sellerNotes = 'Roofstock Property';
        sellerOpportunity.sellerBpmOpportunityId = 1234567;
        sellerOpportunity.sellerContactEmail = 'seller@roofstock.com';
        sellerOpportunity.SellerContactphone = '9876544567';
        sellerOpportunity.SellerFirstName = 'Abraham ';
        sellerOpportunity.SellerLastName = 'Lincoln';
        sellerOpportunityList.add(sellerOpportunity);
        system.RunAs(u){
            
            RESTBulkSellerOpportunityHelper.SellerOpportunitiesWrap sellerRequest = new RESTBulkSellerOpportunityHelper.SellerOpportunitiesWrap();
            sellerRequest.sellerOpportunityList = sellerOpportunityList;
            String sReq = JSON.serialize(sellerRequest);
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/createBulkSellerOpportunities';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(sReq);
            
            RestContext.request = req;
            RestContext.response = res;
            
            Test.startTest();
            //RESTBulkSellerOpportunityController.createOpportunities();
            Test.stopTest();
        }
    }
static testMethod void RESTBulkSellerOpportunityController4PhoneMatch() {
        Id Profile_id = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User u = [select Id from User where ProfileId =: Profile_id and isActive=true][0];
        List<RESTBulkSellerOpportunityHelper.SellerOpportunities> sellerOpportunityList = new List<RESTBulkSellerOpportunityHelper.SellerOpportunities>();
        RESTBulkSellerOpportunityHelper.SellerOpportunities sellerOpportunity = new RESTBulkSellerOpportunityHelper.SellerOpportunities();
        Account acc = new Account();
        acc.Name = 'sfdc';
        insert acc;
        Contact con =new Contact();
        con.LastName ='sfdc';
        con.FirstName = 'sfdc';
        con.Email = 'seller222@roofstock.com';
        con.phone=  '9876544567';
    	con.MobilePhone = '7654355456';
    	con.AccountId = acc.Id;
        insert con;
        
        sellerOpportunity.propertyState = 'CA';
        sellerOpportunity.bulkSaleNumberOfProperties = 5;
        sellerOpportunity.sellerNotes = 'Roofstock Property';
        sellerOpportunity.sellerBpmOpportunityId = 1234567;
        sellerOpportunity.sellerContactEmail = 'seller@roofstock.com';
        sellerOpportunity.SellerContactphone = '9876544567';
        sellerOpportunity.SellerFirstName = 'Abraham ';
        sellerOpportunity.SellerLastName = 'Lincoln';
        sellerOpportunityList.add(sellerOpportunity);
        system.RunAs(u){
            
            RESTBulkSellerOpportunityHelper.SellerOpportunitiesWrap sellerRequest = new RESTBulkSellerOpportunityHelper.SellerOpportunitiesWrap();
            sellerRequest.sellerOpportunityList = sellerOpportunityList;
            String sReq = JSON.serialize(sellerRequest);
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/createBulkSellerOpportunities';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(sReq);
            
            RestContext.request = req;
            RestContext.response = res;
            
            Test.startTest();
            RESTBulkSellerOpportunityController.createOpportunities();
            Test.stopTest();
        }
    }
    
    static testMethod void RESTBulkSellerOpportunityController5MobilePhoneMatch() {
        Id Profile_id = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User u = [select Id from User where ProfileId =: Profile_id and isActive=true][0];
        List<RESTBulkSellerOpportunityHelper.SellerOpportunities> sellerOpportunityList = new List<RESTBulkSellerOpportunityHelper.SellerOpportunities>();
        RESTBulkSellerOpportunityHelper.SellerOpportunities sellerOpportunity = new RESTBulkSellerOpportunityHelper.SellerOpportunities();
        Account acc = new Account();
        acc.Name = 'sfdc';
        insert acc;
        Contact con =new Contact();
        con.LastName ='sfdc';
        con.FirstName = 'sfdc';
        con.Email = 'seller222@roofstock.com';
        con.MobilePhone = '2323211234';
        con.accountId = acc.Id;
        insert con;
        
        sellerOpportunity.propertyState = 'CA';
        sellerOpportunity.bulkSaleNumberOfProperties = 5;
        sellerOpportunity.sellerNotes = 'Roofstock Property';
        sellerOpportunity.sellerBpmOpportunityId = 1234567;
        sellerOpportunity.sellerContactEmail = 'seller@roofstock.com';
        sellerOpportunity.SellerContactphone = '2323211234';
        sellerOpportunity.SellerFirstName = 'Abraham ';
        sellerOpportunity.SellerLastName = 'Lincoln';
        sellerOpportunityList.add(sellerOpportunity);
        system.RunAs(u){
            
            RESTBulkSellerOpportunityHelper.SellerOpportunitiesWrap sellerRequest = new RESTBulkSellerOpportunityHelper.SellerOpportunitiesWrap();
            sellerRequest.sellerOpportunityList = sellerOpportunityList;
            String sReq = JSON.serialize(sellerRequest);
            
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            
            req.requestURI = '/services/apexrest/createBulkSellerOpportunities';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf(sReq);
            
            RestContext.request = req;
            RestContext.response = res;
            
            Test.startTest();
            RESTBulkSellerOpportunityController.createOpportunities();
            Test.stopTest();
        }
    }
    
    
}
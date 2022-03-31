@isTest
public class RestPortfolioControllerTest {
	
    static testMethod void createPortfolioAPIPositiveTest() {
       
        
        Property2__c p = new Property2__c();
        p.Neighborhood_Score__c = '1';
        p.PropertyId__c = '123';
        insert p;
        
        
        String sReq = '{"portfolioList":[{"name":"Port1","portfolioId":"Port1","listingIds":["123"]},{"name":"Port2","portfolioId":"Port2", "listingIds":["as1245","iv1345"]}]}';
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/AddPortfolio';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
		RESTPortfolioController.addPortfolio();
        
		Test.stopTest();
        
    }
    
    static testMethod void createPortfolioRestAPITest() {
       
        
        Property2__c p = new Property2__c();
        p.Neighborhood_Score__c = '1';
        p.PropertyId__c = '123';
        insert p;
        
        list<RESTPortfolioHelper.PortfolioRequest> request = new list<RESTPortfolioHelper.PortfolioRequest>();
        RESTPortfolioHelper.PortfolioRequest req1 = new RESTPortfolioHelper.PortfolioRequest('Portfolio1', 'Port1');
        RESTPortfolioHelper.PortfolioRequest req2 = new RESTPortfolioHelper.PortfolioRequest('Portfolio2', 'Port2');
        request.add(req1);
        request.add(req2);
        String sReq = JSON.serialize(request);
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/AddPortfolio';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
		RESTPortfolioController.addPortfolio();
        
		Test.stopTest();
        
    }
    
}
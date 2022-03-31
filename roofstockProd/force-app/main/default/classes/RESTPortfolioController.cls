@RestResource(urlMapping='/AddPortfolio/*')
global with sharing class RESTPortfolioController {
    
  @HttpPost
  global static void addPortfolio() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response; 
    savepoint sp = Database.setSavepoint() ;   
      try{
        system.debug(req.requestBody.toString()); 
        system.debug('request'+ req.requestBody.toString());
        RESTPortfolioHelper.PortfolioRequestWrapper oPropertydata = RESTPortfolioHelper.PortfolioRequestWrapper.parse(req.requestBody.toString()); 
        
       
       RESTPortfolioHelper.PortfolioResponseWrapper createResponse = RESTPortfolioHelper.AddPortfolio(oPropertydata.portfolioList); 
        res.responseBody = Blob.valueOf(JSON.serialize(createResponse));
        res.statusCode = 200;
        DebugLogHandler.logInboundResponse('RESTPortfolioController','addPortfolio',req.requestBody.toString(),res.responseBody.toString()); 
    }catch(exception exe){
        Database.rollback(sp);
        res.responseBody = Blob.valueOf(
          JSON.serialize(exe.getMessage())
        );
        res.statusCode = 500;
        DebugLogHandler.logRestServiceException('RESTPortfolioController','addPortfolio',exe.getMessage(),
                                                  exe.getStackTraceString(),req.requestBody.toString()); 
    }
    return;
  }
    
}
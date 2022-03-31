@RestResource(urlMapping='/updatePortfolioTransaction/*')
global class RESTPortfolioTransactionController {
    @HttpPost
    global static void updateTransactionPortfolio() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        savepoint sp = Database.setSavepoint() ; 
        try{
            RESTPortfolioTransactionHelper.PortfolioTransactionsWrap portfolioTransactionData = (RESTPortfolioTransactionHelper.PortfolioTransactionsWrap) System.JSON.deserialize(req.requestBody.toString(),RESTPortfolioTransactionHelper.PortfolioTransactionsWrap.class); // RESTPropertyUnitHelper.parse(String.ValueOf(req.requestBody)); // (List<RESTPropertyUnitHelper.PropertyWrapper> )System.JSON.deserialize(String.ValueOf(req.requestBody),List<RESTPropertyUnitHelper.PropertyWrapper>.class);
        	RESTPortfolioTransactionHelper.PostResponse createResponse = RESTPortfolioTransactionHelper.UpdatePortfolioTransaction(portfolioTransactionData.portfolioTransactionList);
        
        res.responseBody = Blob.valueOf(
            JSON.serialize(createResponse.responseBody)
        );
        res.statusCode = 200;
        DebugLogHandler.logInboundResponse('RESTPortfolioTransactionController','UpdatePortfolioTransaction',req.requestBody.toString(),res.responseBody.toString());

        }catch(Exception exe){
            Database.rollback(sp); 
            res.responseBody = Blob.valueOf(
                JSON.serialize(exe.getMessage())
            );
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RESTPortfolioTransactionController','UpdatePortfolioTransaction',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        }
        return;
    }
}
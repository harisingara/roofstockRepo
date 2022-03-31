@RestResource(urlMapping='/updateTransaction/*')
global class RESTTransactionController {
    @HttpPost
    global static void updateTransaction() {
        savepoint sp = Database.setSavepoint() ; 
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try{
            
            System.debug('=req='+req.requestBody.toString());
           
            RESTTransactionHelper.TransactionsWrap transactionsData = (RESTTransactionHelper.TransactionsWrap) System.JSON.deserialize(req.requestBody.toString(),RESTTransactionHelper.TransactionsWrap.class); // RESTPropertyUnitHelper.parse(String.ValueOf(req.requestBody)); // (List<RESTPropertyUnitHelper.PropertyWrapper> )System.JSON.deserialize(String.ValueOf(req.requestBody),List<RESTPropertyUnitHelper.PropertyWrapper>.class);
            RESTTransactionHelper.PostResponse createResponse = RESTTransactionHelper.UpdateTransaction(transactionsData.transactionList);
 
            res.responseBody = Blob.valueOf(
                JSON.serialize(createResponse.responseBody)
            );
            res.statusCode = 200;
            DebugLogHandler.logInboundResponse('RESTTransactionController','UpdateTransaction',req.requestBody.toString(),res.responseBody.toString());
        }catch(Exception exe){
            Database.rollback(sp); 
            res.responseBody = Blob.valueOf(
                JSON.serialize(exe.getMessage())
            );
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RESTTransactionController','UpdateTransaction',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        }
        
        
        return;
    }
}
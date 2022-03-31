@RestResource(urlMapping='/investmentaccount/*')
global class RestInvestmentAccountController {
    @HttpPost
    global static void upsertInvestmentAccount() {
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        savepoint sp = Database.setSavepoint() ; 
        try{
            
            System.debug('=req='+req.requestBody.toString());
            
            RESTInvestmentAccountHelper.InvAccWrap oInvAccData = (RESTInvestmentAccountHelper.InvAccWrap) System.JSON.deserialize(req.requestBody.toString(),RESTInvestmentAccountHelper.InvAccWrap.class); // RESTPropertyUnitHelper.parse(String.ValueOf(req.requestBody)); // (List<RESTPropertyUnitHelper.PropertyWrapper> )System.JSON.deserialize(String.ValueOf(req.requestBody),List<RESTPropertyUnitHelper.PropertyWrapper>.class);
            System.debug('=oInvAccData='+oInvAccData);
            List<RESTInvestmentAccountHelper.InvAccResponse> oResponse = RESTInvestmentAccountHelper.upsertInvestmentAccount(oInvAccData.investmentAccountList); 
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(
                JSON.serialize(oResponse)
            );
             
            
            DebugLogHandler.logInboundResponse('RestInvestmentAccountController','upsertInvestmentAccount',req.requestBody.toString(),res.responseBody.toString());
        }catch(Exception exe){
            res.responseBody = Blob.valueOf(
                JSON.serialize(exe.getMessage())
            );
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RestInvestmentAccountController','updatemytask',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
        }

        return;
    }
    
}
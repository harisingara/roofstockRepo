@isTest
global class MockHttpResponseBPOGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"isSuccessful":true,"error":null,"data":{"orderRequest":{"responseDateTime":"2021-11-22T02:39:00","loginAccountIdentifier":"","loginAccountPassword":"","key":[{"name":"ReferenceId","value":"testrefid1"}],"status":{"condition":"Success","code":"1","name":"","description":"Order Created"},"order":{"orderId":"testorderid1"}}}}');
        res.setStatusCode(200);
        return res;
    }
}
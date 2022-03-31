@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.debug('endpoint' + req.getEndpoint() );
        System.assertEquals('https://qa.roofstock.com/api/marketAreas', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        res.setBody('{"marketAreas":[{"id":9999,"marketName":"Atlanta","displayName":"Atlanta","urlFriendlyName":"atlanta-georgia","logoUrl":"//roofstock-cdn.azureedge.net/markets/atlanta/profile.png","isActive":true,"lookupZip":"30301"}]}');
        res.setStatusCode(200);
        return res;
    }
}
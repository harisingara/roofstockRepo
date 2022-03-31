@isTest
global class MockInspectionUpdateToBMPCallout implements HttpCalloutMock {


    global HTTPResponse respond(HTTPRequest req)
    {   
        // Create a Mock response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"inspectionListResponse": [{"bpmId": "10200"}],"isSuccessful": true}');
        res.setStatusCode(400);
        
        return res;
    }
    
}
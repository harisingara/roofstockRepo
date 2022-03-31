/***************************************************************
 * 		Copyright 2018 Cloud Pathfinder Consulting, LLC 	   *
 * *************************************************************
 * 
 * 
 * 
 */

@isTest
global class MockDelightedResponse implements HttpCalloutMock {
    
    // This interface must be implemented
    global HTTPResponse respond(HTTPRequest req)
    {   
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"id":"1", "email":"josiah@cloudpathfinderconsulting.com", "phone":"4084696712", "name":null, "survey_scheduled_at":1539819328}');
        
        res.setStatusCode(200);
        
        return res;
    }
}
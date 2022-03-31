@isTest
global  class MockHttpResponseBPMRESOURCE implements HttpCalloutMock{
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"statusCode":"OK","isSuccess":true,"entity":[{"type":"TransactionWiringInstructions","fileName":"test.xlsx","uri":"https://dev-bpm.roofstock.com/resources/bpm/1b518548-26ce-4e6c-8680-092697255e54?useSas=true","sizeInByte":6193,"uploadedOnUtc":"2022-02-12T00:08:45Z","uploadedBy":"divvya.premkumar@roofstock.com! (From: BPM)"}],"hasEntity":true,"lineNumber":null,"message":"","errorCode":null,"exception":null,"url":null}');
        res.setStatusCode(200);
        return res;
    }
}
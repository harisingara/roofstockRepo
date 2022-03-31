@isTest
global class PlanomaticDataFeedMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"isSuccessStatusCode":true,"errorMessage":null,"orderId":205604,"tourUrl":"https://planotours.planomatic.com/tour/171643","updatedOnUtc":"2021-07-19T05:39:05Z","photos":[{"photoSequence":1,"photoUrl":"https://photoplan-cache.cdn.planomatic.com/tourFiles/171643/photocache/5228835.jpg","caption":"Exterior","uploadedOnUtc":"2021-07-19T05:39:05Z","modifiedOnUtc":"2021-07-19T05:39:05Z"}]}');
        response.setStatusCode(200);
        return response; 
    }

}
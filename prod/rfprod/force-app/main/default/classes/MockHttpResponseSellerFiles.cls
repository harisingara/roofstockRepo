@isTest
global class MockHttpResponseSellerFiles implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"resourceType":"OpportunitySSS","documentType":"Opportunity - Seller Self Serve","isFolder":false,"folderName":"1030/Opportunity SSS/","fileName":"1.jpg","url":"https://devrsdocuments.blob.core.windows.net/opportunity/1030/Opportunity%20SSS/1.jpg?sv=2018-03-28&sr=b&sig=iNzM1tWOPiDAN7Bt6iGHY0swIAVU1jS9tzAOvg8GpuE%3D&se=2021-04-29T14%3A02%3A57Z&sp=r","lastModified":"2021-04-28T05:45:35Z","uploadedByUserName":null,"uploadedFrom":null,"length":70114,"contentType":"image/jpeg","blobReference":"1030/Opportunity SSS/1.jpg","containerName":"opportunity"}]');
        res.setStatusCode(200);
        return res;
    }
}
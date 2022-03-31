@RestResource(urlMapping='/updateContact/*')
global class RESTContactController {
    @HttpPost
    global static void updateContact() {
        
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;
        savepoint sp = Database.setSavepoint() ; 
        try{
            RESTContactHelper.ContactsWrap contactsData = (RESTContactHelper.ContactsWrap) System.JSON.deserialize(req.requestBody.toString(),RESTContactHelper.ContactsWrap.class); // RESTPropertyUnitHelper.parse(String.ValueOf(req.requestBody)); // (List<RESTPropertyUnitHelper.PropertyWrapper> )System.JSON.deserialize(String.ValueOf(req.requestBody),List<RESTPropertyUnitHelper.PropertyWrapper>.class);            
            RESTContactHelper.PostResponse createResponse = RESTContactHelper.UpdateContact(contactsData.contactList);
            
            res.responseBody = Blob.valueOf(
                JSON.serialize(createResponse.responseBody)
            );
            res.statusCode = 200;
            DebugLogHandler.logInboundResponse('RESTContactController','updateContact',req.requestBody.toString(),res.responseBody.toString());
            
        }catch(Exception exe){
            Database.rollback(sp); 
            res.responseBody = Blob.valueOf(
                JSON.serialize(exe.getMessage())
            );
            res.statusCode = 500;
            DebugLogHandler.logRestServiceException('RESTContactController','updateContact',exe.getMessage(),
                                                    exe.getStackTraceString(),req.requestBody.toString()); 
            
        }
        
        return;
    }
}
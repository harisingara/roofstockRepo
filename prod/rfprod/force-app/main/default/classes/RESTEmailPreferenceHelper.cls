// May 4 10.00pm

global class RESTEmailPreferenceHelper {
  global class EmailRequest{
        global EMailPreferenceRequest preference;
    }
  global class EMailPreferenceRequest {
    global string email;
    global string action;
 
  }
  global class EMailPreferenceResponse {
    global string message;
  }
 

  global static EMailPreferenceResponse UpdatePreference(
    string email, string action
  ) {
   
    List<Lead> leads  = [select id,HasOptedOutOfEmail from lead where email=:email and isconverted=false]; 
    List<Contact> contacts  = [select id,HasOptedOutOfEmail from contact where email=:email];
    
    for(Lead lead : leads){
      if(action == 'unsubscribe'){
        lead.HasOptedOutOfEmail = true;
      } else {
        lead.HasOptedOutOfEmail = false;
      }
    }

    for(Contact contact : contacts){
      if(action == 'unsubscribe'){
        contact.HasOptedOutOfEmail = true;
      } else {
        contact.HasOptedOutOfEmail = false;
      }
    }

    if(leads.size() > 0){
      update leads;
    }
    if(contacts.size() > 0){
      update contacts;
    }

    EMailPreferenceResponse res = new EMailPreferenceResponse();
    res.message='success';
    return res;
  }
}
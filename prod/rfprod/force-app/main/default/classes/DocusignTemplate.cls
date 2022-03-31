public class DocusignTemplate{

public Id idCampaign { get; set; }
public string idTemplate { get; set; }
public Campaign camp { get; set; }

public DocusignTemplate(ApexPages.StandardController controller) {
    // get the campaign id from the record    
    camp =  (Campaign) controller.getRecord();
    idCampaign = camp.Id;    
    idTemplate = [SELECT Docusign_Template_Id__c FROM  Campaign  WHERE  Id =: idCampaign LIMIT 1].Docusign_Template_Id__c ;
}

@future(callout=true)
public static void sendEnvelopeMethod(Id idContact, string templateId, string templateName) {


    Id mySourceId = idContact; 
    dfsle.Recipient myRecipient ;
    dfsle.UUID myTemplateId = dfsle.UUID.parse(templateId);
    dfsle.Document myDocument;
    dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(mySourceId));
     
    Contact c= [SELECT Id, Name, Email FROM  Contact WHERE  Id =: idContact] ;
     myRecipient = dfsle.Recipient.fromSource(
            c.Name, // Recipient name
            c.Email, // Recipient email
            null, // Optional phone number
            'Signer 1', // Role Name. Specify the exact role name from template
            new dfsle.Entity(c.Id)); // Source object for the Recipient
     myEnvelope = myEnvelope.withRecipients(new List<dfsle.Recipient> { myRecipient });
     
     // myTemplateId contains the DocuSign ID of the DocuSign Template
     myDocument = dfsle.Document.fromTemplate(myTemplateId, templateName); 
            
     // Add document to the Envelope
     myEnvelope = myEnvelope.withDocuments(new List<dfsle.Document> { myDocument });      
                 
     // Send envelope               
     myEnvelope = dfsle.EnvelopeService.sendEnvelope(myEnvelope,true); // True : Send now       

}

public PageReference contactButton() {

    List<Contact> contacts = [SELECT Id, Name, Email FROM  Contact 
                              WHERE  Id IN ( SELECT  ContactId  FROM  CampaignMember  WHERE  Campaign.Id =: idCampaign AND ContactId != null )];


   
  
   
    for (Contact c: contacts)
    {
        sendEnvelopeMethod(c.Id, idTemplate , 'NDA_Template');
    }
    
   PageReference pageRef = new PageReference('/'+idCampaign);
   pageRef.setRedirect(true);
   return pageRef ;
}


/////

// get campaignMemberId and Name

public static string getCampaignId(string campaignMemberId ) {
    string myId= campaignMemberId ;
    myId = 'Id-' + myId;
    myId = myId + '-';
    List<string> myListTemplate= new List<string>();
    myListTemplate.add(myId);
    return myId;
}

public static string getCampaignName(string campaignMemberName) {
    string myName = campaignMemberName;
    myName = 'Name-' + myName ;
    myName = myName  + '-';
    List<string> myListEnvelope= new List<string>();
    myListEnvelope.add(myName );
    return myName ;
}





// get dfse Id

public static string getTemplateId(string TemplateId) {
    string myId= TemplateId;
    myId = 'Id-' + myId;
    myId = myId + '-';
    List<string> myListTemplate= new List<string>();
    myListTemplate.add(myId);
    return myId;
}

public static string getEnvelopeId(string EnvelopeId) {
    string myId= EnvelopeId;
    myId = 'Id-' + myId;
    myId = myId + '-';
    List<string> myListEnvelope= new List<string>();
    myListEnvelope.add(myId);
    return myId;
}

public static string getDocumentId(string DocumentId) {
    string myId= DocumentId;
    myId = 'Id-' + myId;
    myId = myId + '-';
    List<string> myListDocument= new List<string>();
    myListDocument.add(myId);
    return myId;
}


    // get dfse Name

public static string getTemplateName(string TemplateName) {
    string myName = TemplateName;
    myName = 'Name-' + myName ;
    myName = myName + '-';
    List<string> myListTemplate= new List<string>();
    myListTemplate.add(myName );
    return myName ;
}

public static string getEnvelopeName(string EnvelopeName) {
    string myName = EnvelopeName;
    myName  = 'Name-' + myName ;
    myName = myName + '-';
    List<string> myListEnvelope= new List<string>();
    myListEnvelope.add(myName );
    return myName ;
}

public static string getDocumentName(string DocumentName) {
    string myName = DocumentName;
    myName = 'Name-' + myName ;
    myName = myName + '-';
    List<string> myListDocument= new List<string>();
    myListDocument.add(myName );
    return myName ;
}

    
    
    // Date manipulation functions
    
         //method to handle potential checks against two dates
    public static Date CheckDates(Date date1, Date date2) {
        //if date2 is within the next 30 days of date1, use date2.  Otherwise use the end of the month
        if(DateWithin30Days(date1,date2)) {
            return date2;
        } else {
            return SetEndOfMonthDate(date1);
        }
    }
    
    //method to check if date2 is within the next 30 days of date1
    public static Boolean DateWithin30Days(Date date1, Date date2) {
        //check for date2 being in the past
            if( date2 < date1) { return false; }
        
        //check that date2 is within (>=) 30 days of date1
        Date date30Days = date1.addDays(30); //create a date 30 days away from date1
        if( date2 >= date30Days ) { return false; }
        else { return true; }
    }

    //method to return the end of the month of a given date
    private static Date SetEndOfMonthDate(Date date1) {
        Integer totalDays = Date.daysInMonth(date1.year(), date1.month());
        Date lastDay = Date.newInstance(date1.year(), date1.month(), totalDays);
        return lastDay;
    }
    
    
   
    // get the formatted id of dfse elements
    
 
      public static string NDA_template_id_formated(string idTemplate_prefix, string idTemplate ,string idTemplate_sufix) {
      
        string myId = '';
        myId = myId + idTemplate_prefix;
        myId = myId + '-';
        myId = myId + idTemplate;
        myId = myId + '-';
        myId = myId + idTemplate_sufix;
        myId = myId + '-';      
        return myId ;
    }
    
          public static string NDA_envelope_id_formated(string idEnvelope_prefix, string idEnvelope ,string idEnvelope_sufix) {
      
        string myId = '';
        myId = myId + idEnvelope_prefix;
        myId = myId + '-';
        myId = myId + idEnvelope ;
        myId = myId + '-';
        myId = myId + idEnvelope_sufix;
        myId = myId + '-';      
        return myId ;
    }
    
    public static string NDA_document_id_formated(string idDocument_prefix, string idDocument ,string idDocument_sufix) {
      
        string myId = '';
        myId = myId + idDocument_prefix;
        myId = myId + '-';
        myId = myId + idDocument ;
        myId = myId + '-';
        myId = myId + idDocument_sufix;
        myId = myId + '-';      
        return myId ;
    }

    public static string NDA_document_name_formated(string nameDocument_prefix, string nameDocument,string nameDocument_sufix) {
      
        string myId = '';
        myId = myId + nameDocument_prefix;
        myId = myId + '-';
        myId = myId + nameDocument;
        myId = myId + '-';
        myId = myId + nameDocument_sufix;
        myId = myId + '-';      
        return myId ;
    }
    

}
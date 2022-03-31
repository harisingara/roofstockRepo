/***************************************************************
 * 		Copyright 2018 Cloud Pathfinder Consulting, LLC 	   *
 * *************************************************************
 * 
 * 
 * 
 */

public class DelightedCallout {
    
	// Set the API token, sandbox:
    //public static final String DELIGHTED_API_KEY = 'XxRrGkdNyeYeMTYjpFbhYhyczM8A1XoU';
    // Set the API token, production:
	public static final String DELIGHTED_API_KEY = 'b2z0ZtDZrDOjUMYwGtHLiCUrd0at4hoq';
    
    // Set endpoint URL
    public static final String DELIGHTED_URL = 'https://api.delighted.com/v1/people.json';
    
    // We use this for test class purposes
    public static HTTPResponse global_res;
    
    // This prevents recursion
    public static Set<Id> alreadyProcessed = new Set<Id>();
    
/* **********************************************
 * 					createPerson()				*
 * *********************************************/
    @future(callout=true)
    public static void createPerson(Set<Id> newOpportunityIds) {	// @future return value must be 
        															// VOID + primitive arguments
        alreadyProcessed.addAll(newOpportunityIds);
        
        List<Opportunity> opps = [SELECT Id, AccountId
                                  FROM Opportunity
                                  WHERE Id IN :newOpportunityIds];
        
        Set<Id> accIdList = new Set<Id>();
        
        for(Opportunity opp : opps) {
            accIdList.add(opp.AccountId);
        }

        List<Contact> oppContacts = [SELECT Id,
                                     Phone,
                                     FirstName,
                                     LastName,
                                     Email
                                     FROM Contact
                                     WHERE AccountId = :accIdList];
        
        for(Contact con : oppContacts)
        {            
			// Initialize the HTTP request (API call)
			HttpRequest req = new HttpRequest();

			// Set API endpoint and method
            req.setEndpoint(DELIGHTED_URL);
			req.setMethod('POST');
            
            Blob headerValue = Blob.valueOf(DELIGHTED_API_KEY + ':' + '');
			String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
			req.setHeader('Authorization', authorizationHeader);

			// Set the body of the request
			req.setBody('&name=' + con.FirstName
						+ '%20' + con.LastName
						+ '&email=' + con.Email
						+ '&send=' + 'true'
			);

			// Create a new http object to send the request object
			Http http = new Http();

			// A response object is generated as a result of the request
			HTTPResponse res = http.send(req);
            
            System.debug(LoggingLevel.ERROR, 'createPerson() callout response: ' + res.getBody());

            // Store this to use for test class
        	if(res.getBody() != null)
            	global_res = res;
        	else
            	System.debug(LoggingLevel.ERROR, 'createPerson() error - failure: ' + res.getBody());
        }
    }
    /* // Not used unless phone numbers re-implemented
    public static String reformatPhone(String phone) {
            
		string nondigits = '[^0-9]';
  		string intlPhone;
  
  		// remove all non numeric
  		intlPhone = phone.replaceAll(nondigits,'');
  
		// if 10 digit: reformat plus US country code
		if (intlPhone.length() == 10) 
			intlPhone = '+1' + intlPhone;
        // else assume international number and add/re-add +
        else
            intlPhone = '+' + intlPhone;
        
		return intlPhone;
    } */
}
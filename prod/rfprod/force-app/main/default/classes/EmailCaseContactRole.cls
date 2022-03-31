global class EmailCaseContactRole implements Schedulable {
        
    private static List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
    
	@InvocableMethod(label = 'Send Email to Case Contact Role' description = 'Send email to Property Manager')
	global static void sendEmails(List<Id> theCases) {
        
        //Id templateId = '00Xq0000000N5vT';		// This is our EOM Case Property Manager template
		        
		EmailTemplate template = [SELECT Id
                                  FROM EmailTemplate
                                  WHERE DeveloperName = 'Email_Case_Property_Manager_at_EOM'];
		
		List<CaseContactRole> ccrs = [SELECT ContactId,
                                      Contact.FirstName,
                                      Contact.Email,
                                      Role,
                                      CasesId
                                      FROM CaseContactRole
                                      WHERE CasesId IN :theCases AND
                                      Role = 'Property Manager'];

        for(CaseContactRole ccr : ccrs) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			List<String> emailTo = new List<String>();
            emailTo.add(ccr.Contact.Email);
			email.setToAddresses(emailTo);
            email.setTargetObjectId(ccr.ContactId);
            email.setWhatId(ccr.CasesId);
            email.setTemplateId(template.Id);
            emailsToSend.add(email);
        }
        
        EmailCaseContactRole eccr = new EmailCaseContactRole();
        Date dt = Date.today();
        Integer month = dt.month();
        Integer day = Date.daysInMonth(dt.year(), dt.month());
        
		// Seconds Minutes Hours Day_of_month Month Day_of_week Optional_year
		String CRON_EXP = '00 00 07 ' + day + ' ' + month + ' ?';
		System.schedule('Email Case Contact Role at EOM', CRON_EXP, eccr);
	}
    
    global void execute(SchedulableContext SC) {
    	if(emailsToSend.size() > 0) {
        	Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend);
            System.debug(LoggingLevel.DEBUG, 'emailsToSend results: ' + results);
        }
    }
}
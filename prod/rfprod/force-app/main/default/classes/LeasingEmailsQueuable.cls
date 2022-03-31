global  with sharing class LeasingEmailsQueuable implements Queueable{
  static Integer LEASING_EMAIL_APPLICATION_FIRST_REMINDER = 1;
  //String emailReminder1Subject  = 'Leasing - First Reminder to finish Application';
  String emailDisplayName       = 'Streetlane Homes';
  String emailReplyTo           = 'noreply@streetlane.com';
  EmailTemplate emailTemplate;
  List<OpportunityRentalUnit__c> orus;

  public LeasingEmailsQueuable(List<OpportunityRentalUnit__c> orus, EmailTemplate emailTemplate){
        this.orus = orus;
        this.emailTemplate = emailTemplate;
  }

  global void execute(QueueableContext SC) {

    for(OpportunityRentalUnit__c oru : orus){    
        System.debug(LoggingLevel.ERROR, '# oru' + oru);
        sendEmailNotification(oru, this.emailTemplate);
               
    }
    
    System.debug(LoggingLevel.ERROR, '# emails sent for -' + orus.size()  );

 }

 public  void sendEmailNotification(OpportunityRentalUnit__c oru , EmailTemplate emailTemplate ) {

        if(oru == null || oru.Opportunity__r.Primary_Leasing_Contact__c == null){
           return;  //nothing to do here!
        }

        System.debug(LoggingLevel.ERROR, 'email' + oru.Opportunity__r.Primary_Leasing_Contact__r.email);
        Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();
        message.setTargetObjectId(oru.Opportunity__r.Primary_Leasing_Contact__c);   //contact
        message.setSenderDisplayName(emailDisplayName);
        message.setReplyTo(emailReplyTo);
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(true); 

        message.setTemplateID(emailTemplate.Id); 
        message.setWhatId(oru.id); //oru id This is important for the merge fields in template to work
        message.toAddresses = new String[] { oru.Opportunity__r.Primary_Leasing_Contact__r.email};  //to email
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

        if (results[0].success) {
            System.debug(LoggingLevel.ERROR,'The email was sent successfully.' + emailTemplate.DeveloperName);
            //update sent date so we dont send the same email more than once
            if(emailTemplate.DeveloperName == 'Leasing_Application_Started_First_Reminder')  {
                oru.Application_Complete_First_Email_Date__c =  datetime.now().date();
            }   
            else  if(emailTemplate.DeveloperName == 'Leasing_Application_Started_Second_Reminder')  {
                oru.Application_Complete_Second_Email_Date__c =  datetime.now().date();
            }  
            else  if(emailTemplate.DeveloperName == 'Leasing_Application_Started_Third_Reminder')  {
                oru.Application_Complete_Third_Email_Date__c = datetime.now().date();
            } 
            else  if(emailTemplate.DeveloperName == 'Leasing_Application_Started_And_Leased')  {
                oru.Application_Complete_Leased_Email_Date__c = datetime.now().date();
            }   
            
            update oru;
        } else {
            System.debug(LoggingLevel.ERROR, 'The email failed to send: ' +  results[0].errors[0].message);
        }

    }
}
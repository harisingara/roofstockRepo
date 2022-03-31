global class GL_create_list_email implements Database.Batchable<sObject>, database.stateful {

   /* 
    string OBSOLETE = '';

    public GL_create_list_email(){
        OBSOLETE = 'true';
    }  
*/

    
    //////////////////////////////////////////
    //                                      //
    //        Variable Declarations         //
    //                                      //
    //////////////////////////////////////////
    

    
    //////////////////////////////////////////
    //                                      //
    //             SOQL Queries             //
    //                                      //
    //////////////////////////////////////////
   
//    string myNameTemplate = [SELECT Email_Template_Name__c FROM  Campaign  WHERE  Id =:camp.Id LIMIT 1].Email_Template_Name__c;
 //   public EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name =: myNameTemplate ];
 //   String  CCEmail = [SELECT Email_Template_Carbon_Copy__c FROM  Campaign  WHERE  Id =:camp.Id LIMIT 1].Email_Template_Carbon_Copy__c;
  //  String replyName = [SELECT Owner.Name FROM  Campaign  WHERE  Id =:camp.Id LIMIT 1].Owner.Name;
  //  String replyEmail = [SELECT Owner.Email FROM  Campaign  WHERE  Id =:camp.Id LIMIT 1].Owner.Email;
   // String[] CCList = CCEmail.split(',');    
    
    
    //////////////////////////////////////////
    //                                      //
    //              GET & SET               //
    //                                      //
    //////////////////////////////////////////


    
    public List<CampaignMember> selectedContacts{get;set;}
    public List<Id> selectedCM_ids{get;set;}
    
    public string selected_contacts_msg {get;set;}
    
    public EmailTemplate idTemplate { get; set; }
    public string NameTemplate  { get; set; } 
    public string CCTemplate  { get; set; } 
    
    
    public string replyName  { get; set; } 
    public string replyEmail  { get; set; } 
    
    

   // public List<CampaignMember> getSelectedContacts()
 //   {
  //      if(selectedContacts.size()>0) return selectedContacts;
  //      else return null;
 //   }      
    
    
    
    //////////////////////////////////////////
    //                                      //
    //              CONSTRUCTOR             //
    //                                      //
    //////////////////////////////////////////  
    
    global   GL_create_list_email (String my_camp, List<String> myCM) 
    {   

        //selectedContacts = myCM;
        selectedContacts = [SELECT Contact.Id, Contact.Email, Name, Id, Email, Lead.Id, Lead.Email, Other_Account_Email__c FROM CampaignMember WHERE Id IN :myCM];
            
        NameTemplate = [SELECT Email_Template_Name__c FROM  Campaign  WHERE  Id =:my_camp LIMIT 1].Email_Template_Name__c;
        idTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name =: NameTemplate ];
        CCTemplate = [SELECT Email_Template_Carbon_Copy__c FROM  Campaign  WHERE  Id =:my_camp LIMIT 1].Email_Template_Carbon_Copy__c;
         
        // system.debug('constructor');
        // system.debug(selectedCM_ids);
        replyName = [SELECT Owner.Name FROM  Campaign  WHERE  Id =:my_camp LIMIT 1].Owner.Name;        
        replyEmail = [SELECT Owner.Email FROM  Campaign  WHERE  Id =:my_camp LIMIT 1].Owner.Email;

    }
    
    
    //////////////////////////////////////////
    //                                      //
    //          BATCH FUNCTIONS             //
    //                                      //
    ////////////////////////////////////////// 
        
   //START - SET UP LIST OF RECIPIENT
   
    global Database.QueryLocator start(Database.BatchableContext BC)
    {   
     
        Set<String> selectedCM_ids = new Set<String> ();
        
        for(CampaignMember CM : selectedContacts){
            selectedCM_ids.add(CM.Id);
        }
        
          
        
        // system.debug('batch');
        String query = 'select Contact.Id, Contact.Email, Name, Id, Email, Lead.Id, Lead.Email, Other_Account_Email__c from CampaignMember WHERE Id IN :selectedCM_ids'  ; 
        // system.debug(selectedContacts);
        //  system.debug(selectedCM_ids);
        // system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    //EXECUTE - SET UP EMAIL
    
    global void execute(Database.BatchableContext BC, List<CampaignMember> scope)
    {   
        system.debug('scope.size() : ' + scope.size());
    
      if(!scope.isEmpty()){
          
        for(CampaignMember c : scope)
        {   
                
            system.debug('EMAIL : ');
            //system.debug(c.Contact.Email);

            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] {c.Email};
            message.setSenderDisplayName(replyName); 
            message.setReplyTo(replyEmail );
            
            
            // check the type of the c
            // c.Contact or c.Lead
            if(c.Contact != null){
                message.setTargetObjectId(c.Contact.id);
            }
            else if(c.Lead != null){
                message.setTargetObjectId(c.Lead.id);
            }
            
            //Combine the CC list from Campaign and the otherEmail from CM
            String[] CCList;
            
            if (CCTemplate != null){                
                 CCList = CCTemplate.split(',');
            }
            if (c.Other_Account_Email__c != null ){   
                if (CCList != null){        
                    String[] CClist2 = c.Other_Account_Email__c.split(',');
                    CClist.addAll(CClist2);
                }
                else {
                    CCList = c.Other_Account_Email__c.split(',');
                }                
            }
            
            if (CCList!=null && !CCList.isEmpty()){                   
                message.setCcAddresses(CCList);
            }

            
            message.setTemplateID(idTemplate.Id);             
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};   
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);            
        }
          
      }
    }
      
    //FINISH - SEND EMAIL WITH THE BATCH STATUS
    
    global void finish(Database.BatchableContext BC)
    {
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email    from AsyncApexJob where Id =:BC.getJobId()];
      
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {replyEmail};
       // String toAddresses = 'replyEmail@gmail.com';
        mail.setToAddresses(toAddresses);
        mail.setSubject('Match Merge Batch ' + a.Status);        
        mail.setPlainTextBody('Records processed : ' + a.TotalJobItems +   ' (with '+ a.NumberOfErrors + ' failures).');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        //Messaging.sendEmail('mail@test.com' ); 
        System.abortJob(a.Id);
        
     
    }
    
    // Run Batch on Button
    global void runBatch(String camp,List<String> cm)
    { 
        Database.executeBatch(new GL_create_list_email(camp,cm),1);      
    }
   
    webservice static void WebService_run_batch(String Camp_param, List<String> CM_list_param)
  {
      GL_create_list_email n = new GL_create_list_email(Camp_param,CM_list_param);
      n.runBatch(Camp_param,CM_list_param);
        system.debug('EMAIL : ');
  }

   
    webservice static void WebService_send_email(String Camp_param, String Emails, String Email_to_cc, string ReplyToName, string ReplyToEmail)
  {
      
      EmailTemplate my_idTemplate; 
      string my_NameTemplate ; 
      Id my_replyId;
      
      my_NameTemplate = [SELECT Email_Template_Name__c FROM  Campaign  WHERE  Id =:Camp_param LIMIT 1].Email_Template_Name__c;
      my_idTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name =: my_NameTemplate ];
      
 
      my_replyId = [SELECT Id FROM  Contact  WHERE  Name =:ReplyToName LIMIT 1].Id;    
      
      String[] my_recipients = new String[]{};
          my_recipients = Emails.split(',');
      
      String[] my_cc = new String[]{};
          my_cc = Email_to_cc.split(',');
      
      
      //Set up the email
      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      
      message.toAddresses = my_recipients;
      
      if(Email_to_cc != ''){
          system.debug(Email_to_cc);
          message.setCcAddresses(Email_to_cc.split(','));
      }       
      
      
      message.setTargetObjectId(my_replyId); 
      message.setSenderDisplayName(ReplyToName); 
      message.setReplyTo(ReplyToEmail);
      
      message.setTemplateID(my_idTemplate.Id);             
      Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};   
          Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);  
      
  }
  
      
    
}
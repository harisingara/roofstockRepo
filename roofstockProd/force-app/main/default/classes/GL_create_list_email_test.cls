@isTest (SeeAllData=true)
private class GL_create_list_email_test {


  
public static testMethod void testCamp() {
    
    //	GL_create_list_email obsolete = new GL_create_list_email();
        
        test.startTest();
        
        Campaign c = new Campaign(Name='MyCampaign', ownerid='0054v00000DZuOV');  
        c.Email_Template_Name__c = 'TemplateDefault';
        c.Email_Template_Carbon_Copy__c = 'myemail@gmail.com';
        
        insert c;
        
        String c_id = c.Id;
    
        Account acct = new account (Name='MyAcct'); 
        insert acct;
    
         List<String> CM_list = new List<String>();
         List<Id> selectedCM_ids = new List<Id>();
        
        Contact con1 = new Contact(FirstName='Joe1', LastName='Smith1', Email='myMail1@gmail.com', AccountId =acct.id );
        insert con1;
    
        CampaignMember cm1= New CampaignMember(CampaignId=c.Id,ContactId=con1.Id,Status='Sent',NDA_Status__c = '' , Portfolio_Status__c = 'In', Other_Account_Email__c = 'test@gmail.com,test2@gmail.com' );
        insert cm1;  
        
        CM_list.add(cm1.id);
        selectedCM_ids.add(cm1.id);
    
        GL_create_list_email controller = new GL_create_list_email(c_id,CM_list);
    
    
       EmailTemplate myTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name =: c.Email_Template_Name__c ];
        
    
        // Test Get and Set
        
        controller.idTemplate = myTemplate;
        
        controller.NameTemplate = 'myEmailTemplate';
        system.assertEquals('myEmailTemplate', controller.NameTemplate);    
    
        controller.selectedCM_ids = selectedCM_ids;
        selectedCM_ids = controller.selectedCM_ids ;    
    
        controller.selected_contacts_msg = 'myEmailTemplate';
        string myMsg = controller.selected_contacts_msg;
        
        controller.selectedContacts= new List<CampaignMember>();
              
      
        // Test Methods   
        
        system.debug('c_id : ' + c_id);    
        system.debug('CM_list : ' + CM_list);
             
        GL_create_list_email.WebService_run_batch(c_id,CM_list);
    
        GL_create_list_email n = new GL_create_list_email(c_id,CM_list);
        Database.executeBatch(new GL_create_list_email(c_id,CM_list),1);  
        n.runBatch(c_id,CM_list);
    
        GL_create_list_email.WebService_send_email(c_id,'test.test@gmail.com','test.test@gmail.com', 'Guillaume Lafarge', 'test.test@gmail.com');
        
        // Test behaviors
            

        test.stopTest();

   }
    

 
  
   
}
public class SendErrorLogNotification {
    public void sendErrorNotification(){
        Datetime dtNow = system.now(); 
        Error_Notification_Last_Run_Time__c oRunTime = Error_Notification_Last_Run_Time__c.getOrgDefaults(); 
        List<DebugLog__c> lstLogs = [Select id , Class_Name__c , Stack_trace__c , Method_Name__c , Error_Description__c from DebugLog__c where Log_Type__c = 'Error' AND createdDate >: oRunTime.Last_Run_Time__c]; 
        if(lstLogs <> null && !lstLogs.IsEmpty() ){
            
            // Step 0: Create a master list to hold the emails we'll send
            List<Messaging.SingleEmailMessage> mails = 
                new List<Messaging.SingleEmailMessage>();
            // Step 1: Create a new Email
            Messaging.SingleEmailMessage mail = 
                new Messaging.SingleEmailMessage();
            
            // Step 2: Set list of people who should get the email
            List<String> sendTo = Label.ErrorLogNotificationSubscriber.split(',');
            /*sendTo.add('vivek.batham@roofstock.com');
            sendTo.add('vivek.visvanathan@roofstock.com');
            sendTo.add('sreekumar@roofstock.com');
            sendTo.add('chidanand.magadum@roofstock.com');
            sendTo.add('priyanka.kalyani@roofstock.com');*/
            
            mail.setToAddresses(sendTo);
            
            // Step 3: Set who the email is sent from
            mail.setSenderDisplayName('SFDC Error Log Notification');
            
            // Step 4. Set email contents - you can use variables!
            mail.setSubject('New Error Logged in SFDC');
            String body = lstLogs.size()+' New Error logs are found from '+oRunTime.Last_Run_Time__c+' to '+dtNow +'<br><br>'; 
            body += 'Debug Logs - Unassigned : '+'https://roofstock.lightning.force.com/lightning/r/Report/00O4v000009FkYnEAK/view?queryScope=userFolders'+ '<br><br>' ;
            body += 'Debug Logs - Assigned Open : '+'https://roofstock.lightning.force.com/lightning/r/Report/00O4v000009FWDvEAO/view?queryScope=userFolders' + '<br><br>' ;
            mail.setHtmlBody(body);
            
            // Step 5. Add your email to the master list
            mails.add(mail);
            // Step 6: Send all emails in the master list
            Messaging.sendEmail(mails); 
        }
        oRunTime.Last_Run_Time__c = dtNow;
        //  oRunTime.Id = [Select id from Error_Notification_Last_Run_Time__c where Name =: oRunTime.Name].Id ; 
        update oRunTime;
    }
}
public class EmailMessageHelper {
 //This method is responsible to track all the email messages 
    public static Boolean triggerRun = true;
    public static boolean runningFirstTime(){
        if(triggerRun){
            triggerRun=false;
            return true;
        }else{
            return triggerRun;
        }
    } 
    @future(callout=true)
    Public static void trackEmails(set<Id> newRecordsId, String eventType){
        for(String recordId : newRecordsId){
            sendcallout(recordId,eventType);
        }
            
    }
      
    //This method will be called from flow
    @InvocableMethod (label='Track Email')
    public static void sendcalloutFromFlow(List<Id> emailMessageIds){
        Set<Id> IdSet = New Set<Id>();
        IdSet.addAll(emailMessageIds);
        //trackEmails(IdSet,GlobalConstants.EMAIL_TRACKING_STATUS_EMAIL_DELIVERED);
         ID jobID = System.enqueueJob(new EmailMessageQueueable(IdSet));
       
    }
    
    //This method will get called from batch named "EmailTrackingBatch" 
    public static void sendcallout(String emailMessageId, String eventType){
        EmailMessage em = [SELECT ActivityId,EmailTemplateId,EmailTemplate.Name,BccAddress,CcAddress,CreatedById,ToAddress,ThreadIdentifier,FromAddress,Subject,ParentId,
        My_Task__c,Investment_Account__c,Hoa__c,Violation__c,Inspection__c,Job__c,Transaction__c,EmailServiceParentId__c FROM EmailMessage WHERE Id =:emailMessageId ]  ;  
        String recordId = em.ParentId;  
        String activityId = em.ActivityId;
        String Data;
        if(recordId == null && em.EmailServiceParentId__c != null){
            recordId = em.EmailServiceParentId__c;
        }
        else if(recordId == null && activityId != null){
            Task task = [Select id,WhatId from Task where id =:activityId ];
            recordId = task.WhatId;
        }
        if(recordId != null){
            String objectName = Utilities.findObjectNameFromRecordIdPrefix(recordId);
            EmailMessageMapping__mdt mc = EmailMessageMapping__mdt.getInstance(objectName);
           
            try{

                String QueryString;
                if(mc!= null)
                    QueryString ='Select id ,'+mc.FieldApi__c+ ' From '+objectName+' where id =:recordId';
                Sobject objData;
                objData = DataBase.query(QueryString);
                 if(objData != null){
                    if(TransactionHelper.ExtractFieldValues(objData,mc.FieldApi__c) != null)    
                        Data = TransactionHelper.ExtractFieldValues(objData,mc.FieldApi__c) ;
                    //Lead ld = [Select ruid__c from Lead where id =:em.ParentId];
                   
                }
                
            }
            catch(Exception ex){

               System.debug(ex.getMessage());

            }
            
        }
        //Send callout to track 
        try{
            HTTP auth = new HTTP();
            //Create a Json body 
            String emailTemplateId = '';
            String emailTemplateName = '';
            if(em.EmailTemplateId != null ){
                emailTemplateId = em.EmailTemplateId;
                emailTemplateName =em.EmailTemplate.Name; 
            }
            String body = '{'+
                '"user_id": "'+Data+'",'+
                '"action": "track",'+
                '"event": "'+eventType+'",'+
                '"context": {'+
                    '"traits": {'+
                    '"email": "'+ em.ToAddress +'",'+
                    '"sender": "'+em.FromAddress+'"'+
                    '}'+
                '},'+
                '"properties": {'+
                    '"email_id": "'+em.ToAddress+'",'+
                    '"email_subject":" Hi,'+em.Subject+'",'+
                    '"template_id": "'+ emailTemplateId +'",'+
                    '"template_name": "'+emailTemplateName +'",'+
                    '"templatename": "'+em.FromAddress+'",'+
                    '"sender": "'+em.FromAddress+'"'+
                '}'+
                '}';
            if(!Test.isRunningTest()){
                HTTPRequest r = new HTTPRequest();
                r.setHeader('Content-Type','application/json');
                r.setEndpoint(Label.Segment_Integration_Endpoint);
                r.setMethod('POST');
                r.setBody(Body);
                HTTPResponse authresp=new HttpResponse();
                authresp = auth.send(r);
                system.debug('Response : ' + authresp);
            }
        } 
        catch(Exception ex){

            System.debug(ex.getMessage());

         } 
        
           
    }

    // Method to reopen cases and set status upon new incoming emails
    public static void updateCaseStatus(List<EmailMessage> emlList) {
        if (System.Label.RUN_CASE_STATUS_UPDATE == 'Yes') {
            Map<Id, Boolean> parentIds = new Map<Id, Boolean>();
            //Set<Id> parentIds = new Set<Id>();
            List<Case> updateCase = new List<Case>();
            for (EmailMessage em : emlList) {
                if (em.ParentId <> null) {
                    parentIds.put(em.ParentId, em.Incoming);
                }
            }
    
            if (null <> parentIds && parentIds.size() > 0) {
                List<Group> grpQueueId = [SELECT Id 
                                            FROM GROUP 
                                           WHERE Developername = 'Roofstock_Support_Queue'];
                for (Case c : [SELECT Id, Status, IsClosed, ownerId, RecordType.DeveloperName, First_Outgoing_Email_Date_Stamp__c 
                                 FROM Case 
                                WHERE Id IN :parentIds.keySet() AND status <> 'New' AND 
                                      RecordType.Developername IN ('Post_Transaction','Transaction','General')]) {
                    if (parentIds.containskey(c.Id)) {
                        if (parentIds.get(c.Id)) {
                            updateCase.add(new Case (Id=c.Id, 
                                                     OwnerId=((c.RecordType.DeveloperName <> 'Transaction' && null <> grpQueueId && grpQueueId.size() > 0 && c.IsClosed)?grpQueueId[0].Id:c.ownerId), 
                                                     Status=(c.IsClosed?'Reopen':'Customer Response Received')));
                        }
                        else if (c.Status == 'Customer Response Received' || c.First_Outgoing_Email_Date_Stamp__c == null) {
                            updateCase.add(new Case (Id=c.Id, Status=(c.Status=='Customer Response Received'?'Open':c.Status), 
                                                     First_Outgoing_Email_Date_Stamp__c=(c.First_Outgoing_Email_Date_Stamp__c==null?System.now():c.First_Outgoing_Email_Date_Stamp__c)));
                        }
                    }
                }
            }
    
            if (null <> updateCase && updateCase.size() > 0) {
                Update updateCase;
            }
        }
    }

    public static void updateEmailMsgTransaction(List<EmailMessage> emlList) {
        List<Id> pIdList =  new List<Id>();
        List<EmailMessage> newEmailMsgList = new List<EmailMessage>();
        Map<String,String> caseIdTransMap =  new Map<String,String>();
        system.debug('we are in after updateEmailMsgTransaction method::');
        try{
            if(runningFirstTime()){
                for(EmailMessage em : emlList){
                    if(em.ParentId != null){
                    Id recId = Id.valueOf(em.ParentId);
                    String obj = String.valueOf(recId.getsobjecttype());
                    System.debug('-obj-'+obj);
                    if(obj == 'Case'){
                        pIdList.add(em.ParentId);
                    }
                    }
                }
            }
            
            if(pIdList.size() > 0){
            for(Case cs :[SELECT Id,Transaction__c FROM case WHERE id in :pIdList]){
                caseIdTransMap.put(cs.Id,cs.Transaction__c);
            }
            }

            // for(EmailMessage email : emlList) {
            //     if(caseIdTransMap.get(email.ParentId) <> null && caseIdTransMap.get(email.ParentId) <> '' && (String.valueOf(email.status) == '1' || String.valueOf(email.status) == '2' || String.valueOf(email.status) == '3') ){
            //         EmailMessage taskEmailMessage = new EmailMessage();
            //         taskEmailMessage.ToAddress =  email.ToAddress;
            //         taskEmailMessage.FromAddress = email.FromAddress;
            //         taskEmailMessage.FromName = email.FromName;
            //         taskEmailMessage.Subject = email.subject;
            //         taskEmailMessage.status = email.status;
            //         taskEmailMessage.HtmlBody = email.htmlBody;
            //         System.debug('htmlBody:>>>> ' + email.htmlBody );
            //         taskEmailMessage.Incoming= email.Incoming;
            //         taskEmailMessage.TextBody = email.TextBody;
            //         taskEmailMessage.Transaction__c = caseIdTransMap.get(email.ParentId);
            //         taskEmailMessage.parentId = email.parentId;
            //         taskEmailMessage.RelatedToId = email.parentId;
            //         newEmailMsgList.add(taskEmailMessage);
            //     }
            // }
            // if(!newEmailMsgList.isEmpty() ) {
            //     Upsert newEmailMsgList;
            // } 
            for(EmailMessage email : emlList) {
                    if(caseIdTransMap.get(email.ParentId) <> null && caseIdTransMap.get(email.ParentId) <> '' && String.valueOf(email.status) != '5' ){
                        EmailMessage createEmailMessage = new EmailMessage();
                        createEmailMessage.Transaction__c = caseIdTransMap.get(email.ParentId);
                        createEmailMessage.Id = email.Id;
                        newEmailMsgList.add(createEmailMessage);
                    }
                    if(!newEmailMsgList.isEmpty()){
                        Update newEmailMsgList;
                    }
            }
                      
        
        }
        catch(Exception e){
            system.debug('Error message' +e.getMessage());
            system.debug('Error trace' +e.getStackTraceString());
        }
    }
    
    //Anh Phan: This method check for closed case status and then send email
    public static void validateClosedCase(List<EmailMessage> newEmailMessagelList) {
        
        Map<Id, String> caseRecordTypeMap = new Map<Id, String>();
        
        Schema.DescribeSObjectResult caseObject = case.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> caseRecordTypes = caseObject.getRecordTypeInfos();
        
        for(Schema.RecordTypeInfo cRT: caseRecordTypes) {
            
            if(cRT.getName().containsIgnoreCase('Streetlane')){
                
                caseRecordTypeMap.put(cRT.getRecordTypeId(), cRT.getName());
                
            }//end of if(Streetlane)
        }//end of for(caseRecordTypes)
        
        if(caseRecordTypeMap <> NULL && !caseRecordTypeMap.isEmpty()){
            
            for(EmailMessage emg: [SELECT Id, ParentId, Parent.Status, Parent.RecordTypeId, Parent.CaseNumber, Parent.SuppliedEmail  
                                   FROM EmailMessage where ParentId!=NULL and Id IN :newEmailMessagelList]) {
                
                if(caseRecordTypeMap.containsKey(emg.Parent.RecordTypeId) && emg.Parent.Status.equalsIgnoreCase('Closed')) {
                    
                    sendEmailAlert(emg.Parent.CaseNumber, emg.Parent.SuppliedEmail, 'Streetlane Close');
                    
                }//end of if(Case closed status check)
                
            }//end of for(newEmailMessagelList)
            
        }//end of if(caseRecordTypeMap)
        
    }//end of validateClosedCase
    
    //Anh Phan: This method sends email
    public static void sendEmailAlert(String caseNum, String emailAddress, String eTemplate) {
        
        List<EmailTemplate> lstEmailTemplates = [SELECT Id, Body, Subject, HtmlValue from EmailTemplate where Name =:eTemplate];
        
        List<OrgWideEmailAddress> orgWideEmailList = [select id, Address, DisplayName from orgwideemailaddress limit 1];
        
        List<Messaging.SingleEmailMessage> mailList =  new List<Messaging.SingleEmailMessage>();
        
        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(lstEmailTemplates[0].Id);
        
        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
        sendTo.add(emailAddress);
        mail.setToAddresses(sendTo);
        
        // Step 3: Set who the email is sent from
        mail.setReplyTo('noreply@streetlane.com');
        mail.setSenderDisplayName('Streetlane No-reply');
        
        // Step 4. Set email contents - you can use variables!
        String subj = lstEmailTemplates[0].Subject;
        subj = subj.replace('{!Case.CaseNumber}', caseNum);
        mail.setSubject(subj);
        
        String textBody = lstEmailTemplates[0].Body;
        mail.setHtmlBody(textBody);
        
        // Step 5. Add your email to the master list
        mailList.add(mail);
        
        Messaging.sendEmail(mailList);
        
    }//end of sendEmailAlert
}
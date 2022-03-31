/**
 * @description       : Handle the incoming emails and create and link the EmailMessage to record
 * @author            : Guru Sandhu
 * @group             : 
 * @last modified on  : 03-30-2022
 * @last modified by  : Guru Sandhu
**/

global without sharing class RetailTransactionEmailServiceInbound implements Messaging.InboundEmailHandler{
    global static Email_Service_Setting__mdt emailServiceSetting = Email_Service_Setting__mdt.getInstance('Roofstock_One');
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String myPlainText= '';
        // Add the email plain text into the local variable 
        myPlainText = email.htmlBody;        
        system.debug('####unique message ID##'+email.messageId);
        System.debug('=myPlainText='+myPlainText);
        
        // For storing Relation Id
        string oppcid ='';
        
        String subject = String.valueOf(email.subject);
        System.debug('=subject='+subject);
        /*Integer index = subject.indexOf(':');
System.debug('=index='+index);
*/
        
        //String relatedId =  myPlainText.Substring(myPlainText.indexof('a1j'),myPlainText.indexof('a1j')+18);
        System.debug('ref check'+myPlainText.indexof('ref:'));
        System.debug('to address is::'+email.toAddresses);
        String strToAddress = (email.toAddresses != null) ? String.valueof(email.toAddresses) : '';
        System.debug('to address check::'+strToAddress);
        if(myPlainText.indexof('ref:') !=-1){
            String relatedId;
            String obj;
            if(myPlainText.Substring(myPlainText.indexof('ref:')+4,myPlainText.indexof('ref:')+10).contains('TRNS')){
                String transactionId = String.valueOf(myPlainText.Substring(myPlainText.indexof('ref:')+9,myPlainText.indexof('ref:')+20)).replaceAll('[^0-9]', '');
                System.debug('-transactionId--> '+transactionId);
                List<Transaction__c> lstMatchingTransaction= [select Id,Transaction_Id__c from Transaction__c where Transaction_Id__c=:transactionId];
                System.debug('lstMatchingTransaction --> '+lstMatchingTransaction);
                if(!lstMatchingTransaction.isEmpty()){
                    System.debug(' lstMatchingTransaction[0].Id --> '+lstMatchingTransaction[0].Id);
                    relatedId = lstMatchingTransaction[0].Id;
                }
            }            
            else{
                relatedId= myPlainText.Substring(myPlainText.indexof('ref:')+4,myPlainText.indexof('ref:')+22);
            }
            System.debug('=relatedId='+relatedId);
            
            if(relatedId != null && relatedId != ''){
            Id recId = Id.valueOf(relatedId);
            obj = String.valueOf(recId.getsobjecttype());
            System.debug('=relatedId='+relatedId);
            System.debug('=recId='+recId);
            System.debug('=obj='+obj);
            
            // If (relatedId.startsWith('a1j')){
            If ( obj == 'Transaction__c'){
                //Add Inbound Email Message for contact
                EmailMessage taskEmailMessage = new EmailMessage();
                taskEmailMessage.ToAddress =  email.toAddresses != null ? String.join(email.toAddresses, ',') : '';
                taskEmailMessage.FromAddress = email.FromAddress;
                taskEmailMessage.FromName = email.FromName;
                taskEmailMessage.Subject = email.subject;
                taskEmailMessage.status = '2';
                taskEmailMessage.HtmlBody = email.htmlBody;
                System.debug('htmlBody:>>>> ' + email.htmlBody );
                taskEmailMessage.Incoming= True;
                taskEmailMessage.TextBody = email.plainTextBody;
                System.debug('TextBody:>>>>> ' + email.plainTextBody);
                
                if(obj == 'Transaction__c'){
                    taskEmailMessage.Transaction__c = relatedId;
                    taskEmailMessage.EmailServiceParentId__c = relatedId;         
                }
                if(email.textAttachments!=null || email.binaryAttachments!=null){
                    taskEmailMessage.Has_Attachment__c = true;
                }
                insert taskEmailMessage;
                List<Attachment> attachmentList = new List<Attachment>();
                if(email.textAttachments != null)
                {
                    // Save attachments, if any
                    for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                        Attachment attachment = new Attachment();
                        
                        attachment.Name = tAttachment.fileName;
                        attachment.Body = Blob.valueOf(tAttachment.body);
                        attachment.ParentId = taskEmailMessage.Id;
                        attachmentList.add(attachment);
                        //insert attachment;
                    }
                }
                if(email.binaryAttachments != null)
                {
                    for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                        Attachment attachment = new Attachment();
                        
                        attachment.Name = bAttachment.fileName;
                        attachment.Body = bAttachment.body;
                        attachment.ParentId = taskEmailMessage.Id;
                        attachmentList.add(attachment);
                        //insert attachment;
                    }
                }
                
                if(!attachmentList.isEmpty()){
                    insert attachmentList;
                }            
                
                
                System.debug('Reply Email: ' + taskEmailMessage ); 
                
              }  
            }
        }
        else if(myPlainText.indexof('ref:') ==-1 && strToAddress.contains('transaction')){
            EmailMessage taskEmailMessage = new EmailMessage();
            taskEmailMessage.ToAddress =  String.join(email.toAddresses, ',');
            taskEmailMessage.FromAddress = email.FromAddress;
            taskEmailMessage.FromName = email.FromName;
            taskEmailMessage.Subject = email.subject;
            taskEmailMessage.status = '2';
            taskEmailMessage.HtmlBody = email.htmlBody;
            System.debug('htmlBody:>>>> ' + email.htmlBody );
            taskEmailMessage.Incoming= True;
            taskEmailMessage.TextBody = email.plainTextBody;
            insert taskEmailMessage;
            List<Attachment> attachmentList = new List<Attachment>();
                if(email.textAttachments != null)
                {
                    // Save attachments, if any
                    for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                        Attachment attachment = new Attachment();
                        
                        attachment.Name = tAttachment.fileName;
                        attachment.Body = Blob.valueOf(tAttachment.body);
                        attachment.ParentId = taskEmailMessage.Id;
                        attachmentList.add(attachment);
                        //insert attachment;
                    }
                }
                if(email.binaryAttachments != null)
                {
                    for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                        Attachment attachment = new Attachment();
                        
                        attachment.Name = bAttachment.fileName;
                        attachment.Body = bAttachment.body;
                        attachment.ParentId = taskEmailMessage.Id;
                        attachmentList.add(attachment);
                        //insert attachment;
                    }
                }
                
                if(!attachmentList.isEmpty()){
                    insert attachmentList;
                }    
        }
        else if(myPlainText.indexof('ref:') ==-1 && !strToAddress.contains('transaction')){
            forwardEmail(email, emailServiceSetting.RS1_Forward_Email__c);
        }
        
        return result;
    }
    
    public void forwardEmail(Messaging.InboundEmail email, String toAddress){
        try{
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {toAddress};
            
        mail.setToAddresses(toAddresses);
        //mail.setSenderDisplayName(email.fromName);
        mail.setSubject(email.subject);
        mail.setPlainTextBody(email.plainTextBody);
        mail.setHtmlBody(email.htmlBody);
        //mail.entityattachments = (Messaging.SingleEmailMessage) email.binaryAttachments;
        List<Messaging.EmailFileAttachment> attachmentList = new List<Messaging.EmailFileAttachment>();
        System.debug('-binary att-'+email);
        System.debug('-binary att-'+email.binaryAttachments);
        System.debug('-text att-'+email.textAttachments);
        if(email.binaryAttachments != null){
            for(Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments){
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(bAttachment.fileName);
                efa.setBody(bAttachment.body);
                attachmentList.add(efa);
            }
        }
        if(email.textAttachments != null){
            for(Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments){
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(tAttachment.fileName);
                efa.setBody(Blob.valueOf(tAttachment.body));
                attachmentList.add(efa);
            }
        }
        mail.setFileAttachments(attachmentList);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
            DebugLogHandler.logOutBoundResponse('TransactionEmailServiceInbound', 'EmailService', JSON.serialize(mail), JSON.serialize(mail));
        }
        catch(Exception e){
        
             DebugLogHandler.logAppException('TransactionEmailServiceInbound', 'execute', e.getMessage(), e.getStackTraceString(), 'EmailServiceInbound');
        }
        
        
        
    }
    

}
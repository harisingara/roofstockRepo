global class EmailServiceInboundLeadCreation implements Messaging.InboundEmailHandler {
    
    global static List<EmailMessage> emailMessageList = new List<EmailMessage>();
    global static Email_Service_Setting__mdt emailServiceSetting = Email_Service_Setting__mdt.getInstance('iBuy');

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        savepoint sp = Database.setSavepoint();
        Boolean existingLead=false;
        String parentId;
        String accountId;
        String contactId;
        String firstName;
        String lastName;
        String leadEmail;
        List<String> leadNameList;
        Set<String> excludeIbuyerEmailSet = new Set<String>();
        try{
			System.debug('----->'+emailServiceSetting);
            Map<String, IBuyer_Exclusion_Email__mdt> ibuyerEmailMap = IBuyer_Exclusion_Email__mdt.getAll();
            Id cloudHouseRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(emailServiceSetting.Lead_RecordType__c).getRecordTypeId();
            Id roofstockContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(emailServiceSetting.Contact_RecordType__c).getRecordTypeId();
            
            
            for(String iBuyEmail : ibuyerEmailMap.keySet()){
                
                excludeIbuyerEmailSet.add(ibuyerEmailMap.get(iBuyEmail).MasterLabel);
            }
            
            // Start - Fix for emai.fromName coming as single word
            /*leadNameList = email.fromName.split(' ');
firstName=leadNameList[0];
lastName=leadNameList[1];*/
            leadEmail=email.fromAddress;
            
            if (email.fromName.indexOf(' ') == -1) {
                lastName=email.fromName;
            }
            else {
                firstName=email.fromName.substringBefore(' ');
                lastName=email.fromName.substringAfter(' ');
            }
            // End - Fix for emai.fromName coming as single word
            
            if(excludeIbuyerEmailSet.contains(leadEmail)){
                
                return null;
            }
            
            List<Lead> matchingLeadList = [select Id from Lead where Email=:leadEmail and isConverted=false];
            List<Contact> matchingContactList = [select Id,AccountId from Contact where Email=:leadEmail and RecordTypeId=:roofstockContactRecordTypeId];
            System.debug('-matchingLeadList-'+matchingLeadList);
            
            if(!matchingContactList.isEmpty()){
                
                parentId = getOpportunity(matchingContactList[0].AccountId,firstName,lastName); 
                
            }
            else if(!matchingLeadList.isEmpty()){
                
                
                Map<Id,EmailMessage> leadEmailMessageMap = new Map<Id,EmailMessage>([select Id,Has_Attachment__c,ToAddress,MessageDate,FromAddress,FromName,Subject,HtmlBody,TextBody,ParentId,EmailServiceParentId__c from EmailMessage where EmailServiceParentId__c =:matchingLeadList[0].Id]);
                List<Attachment> attachmentList = [select Id,ParentId,ContentType,name,Body from Attachment where ParentId IN:leadEmailMessageMap.keySet()];
                Map<Id, List<Attachment>> emailAttachmentMap = new Map<Id, List<Attachment>>();
                for(Attachment att : attachmentList) {
                    if(emailAttachmentMap.containsKey(att.ParentId)) {
                        List<Attachment> attList = emailAttachmentMap.get(att.ParentId);
                        attList.add(att);
                        emailAttachmentMap.put(att.ParentId, attList);
                    } else {
                        emailAttachmentMap.put(att.ParentId, new List<Attachment> {att});
                    }
                }
                System.debug('-leadEmailMessageMap-'+leadEmailMessageMap);
                emailMessageList = leadEmailMessageMap.values();   
                System.debug('-emailMessageList Before Conversion-'+emailMessageList);
                Database.LeadConvertResult tempLC = convertLead(matchingLeadList[0].Id);
                parentId = tempLC.getOpportunityId();
                accountId = tempLC.getAccountId();
                contactId = tempLC.getContactId();
                updateOpportunityAccountAfterConversion(parentId,accountId,contactId);  
                System.debug('-emailMessageList After Conversion-'+emailMessageList);
                if(!emailMessageList.isEmpty()){
                    
                    createExistingLeadEmailMessage(emailMessageList,parentId,emailAttachmentMap);
                    
                }
            }
            else if(matchingLeadList.isEmpty()){
                
                Lead newLead = new Lead();
                newLead.FirstName = firstName;
                newLead.LastName = lastName;
                newLead.Email = leadEmail;
                newLead.Company = firstName+' '+lastName;
                newLead.LeadSource = emailServiceSetting.Lead_Source__c;
                newLead.RecordTypeId = cloudHouseRecordTypeId;
                insert newLead;
                Database.LeadConvertResult tempLC = convertLead(newLead.Id);
                parentId = tempLC.getOpportunityId(); 
                accountId = tempLC.getAccountId();
                contactId = tempLC.getContactId();
                updateOpportunityAccountAfterConversion(parentId,accountId,contactId);                
            }
            
            EmailMessage taskEmailMessage = new EmailMessage();
            try{
                
                taskEmailMessage = createEmailMessage(email,parentId);
                insert taskEmailMessage;
                List<Attachment> attachmentList = createAttachment(email,taskEmailMessage);
                if(!attachmentList.isEmpty()){
                    insert attachmentList;
                } 
            }
            catch(Exception exe){
                
                DebugLogHandler.logAppException('EmailServiceInboundLeadCreation','handleInboundEmail-EmailMessage',exe.getMessage(),
                                                exe.getStackTraceString(),'iBuyEmail');                
            }
            
            StessaResponse sr = new StessaResponse();
            sr.opportunityId = parentId;
            sr.emailId = taskEmailMessage.Id;
            String responseJson = JSON.serialize(sr);
            // String inputEmail = String.valueOf(email);
            String inputEmail = JSON.serialize(email);
            if(inputEmail.length()>131072){
                
                inputEmail = inputEmail.substring(0,131071);
            }
            
            DebugLogHandler.logInboundResponse('EmailServiceInboundLeadCreation','handleInboundEmail',inputEmail,responseJson);
        }
        catch(Exception exe){
            
            Database.rollback(sp);
            DebugLogHandler.logAppException('EmailServiceInboundLeadCreation','handleInboundEmail',exe.getMessage(),
                                            exe.getStackTraceString(),'iBuyEmail');
            
            throw exe;
            
            
        }
        
        return result;
    }
    
    /*** Logic to create Email Message Record ***/
    public static EmailMessage createEmailMessage(Messaging.InboundEmail email,String ParentId){
        
        EmailMessage taskEmailMessage = new EmailMessage();
        taskEmailMessage.ToAddress =  String.join(email.toAddresses, ',');
        taskEmailMessage.FromAddress = email.FromAddress;
        taskEmailMessage.FromName = email.FromName;
        if(email.subject.length()>4000){
            
            taskEmailMessage.Subject = (email.subject).substring(0,3999);
        }
        else{
            
            taskEmailMessage.Subject = email.subject;
        }
        taskEmailMessage.status = '2';
        
        String refId = '';
        if(email.htmlBody.indexof('ref:') !=-1){
            refId = '';
        }
        else{
            refId = '\nref:'+ParentId;
        }
        if(email.htmlBody.length()>32000){
            
            String limitedHtmlBody = (email.htmlBody).substring(0, 31900);
            taskEmailMessage.HtmlBody = limitedHtmlBody+refId;
        }
        else{
            
            taskEmailMessage.HtmlBody = email.htmlBody+refId;
        }
        
        if(email.plainTextBody.length()>32000){
            
            String limitedTextBody = email.plainTextBody;
            taskEmailMessage.TextBody = limitedTextBody.substring(0, 31900);
        }
        else{
            
            taskEmailMessage.TextBody = email.plainTextBody;
        }
        
        System.debug('htmlBody:>>>> ' + email.htmlBody );
        taskEmailMessage.Incoming= True;        
        taskEmailMessage.Opportunity__c = ParentId;
        taskEmailMessage.EmailServiceParentId__c = ParentId;
        if(email.textAttachments!=null || email.binaryAttachments!=null){
            
            taskEmailMessage.Has_Attachment__c = true;
        }
        return taskEmailMessage;
    }
    
    /*** Logic to create Email Message Attachment Records ***/
    public static List<Attachment> createAttachment(Messaging.InboundEmail email,EmailMessage taskEmailMessage){
        
        List<Attachment> attachmentList = new List<Attachment>();
        if(email.textAttachments != null){
            
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
        if(email.binaryAttachments != null){
            
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                
                Attachment attachment = new Attachment();                
                attachment.Name = bAttachment.fileName;
                attachment.Body = bAttachment.body;
                attachment.ParentId = taskEmailMessage.Id;
                attachmentList.add(attachment);
                //insert attachment;
            }
        }
        return attachmentList;
    }
    
    /*** Logic to Migrate Existing Lead Email Messages to Opportunity ***/
    public static void createExistingLeadEmailMessage(List<EmailMessage> emList,String parentId,Map<Id,List<Attachment>> emailAttachmentMap){
        List<EmailMessage> emailMessageList = new List<EmailMessage>();
        for(EmailMessage em:emList){
            EmailMessage newEmailMessage = new EmailMessage();
            newEmailMessage.ToAddress = em.ToAddress;
            newEmailMessage.FromAddress = em.FromAddress;
            newEmailMessage.FromName = em.FromName;
            newEmailMessage.Subject = em.Subject;
            newEmailMessage.HtmlBody = em.HtmlBody;
            newEmailMessage.TextBody = em.TextBody;
            newEmailMessage.Opportunity__c =parentId;
            newEmailMessage.MessageDate = em.MessageDate;
            newEmailMessage.EmailServiceParentId__c =  parentId;
            newEmailMessage.Has_Attachment__c = em.Has_Attachment__c;
            newEmailMessage.CloudHouseStessa_EmailSource__c = em.Id;
            emailMessageList.add(newEmailMessage);
        }
        if(!emailMessageList.isEmpty()){
            insert emailMessageList;    
        }
        
        
        if(!emailMessageList.isEmpty()){
            List<Attachment> newAttachmentList = new List<Attachment>();
            System.debug('-emailAttachmentMap-'+emailAttachmentMap.values());
            for(EmailMessage emailMsg:emailMessageList){
                if(emailAttachmentMap.containsKey(emailMsg.CloudHouseStessa_EmailSource__c)){
                    List<Attachment> sourceAttachmentList =  emailAttachmentMap.get(emailMsg.CloudHouseStessa_EmailSource__c);
                    System.debug('-sourceAttachmentList-'+sourceAttachmentList.size());
                    System.debug('-sourceAttachmentList-'+sourceAttachmentList);
                    
                    for(Attachment att : sourceAttachmentList){
                        Attachment newAtt = new Attachment();
                        newAtt.Body = att.Body;
                        newAtt.name = att.Name;
                        newAtt.ContentType = att.ContentType;                        
                        newAtt.ParentId = emailMsg.Id;
                        newAttachmentList.add(newAtt);
                    }
                }
            }
            System.debug('-newAttachmentList-'+newAttachmentList);
            if(!newAttachmentList.isEmpty()){
            	insert newAttachmentList;  
            }
        }
        
    }
    
    /*** Logic to create Opportunity for the existing contact ***/
    public static String getOpportunity(String accountId,String firstName,String lastName){
        
        Id cloudhouseOptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CloudHouse').getRecordTypeId();
        List<Opportunity> oppList = [SELECT Id FROM Opportunity Where accountId =:accountId and RecordTypeId =:cloudhouseOptyRecordTypeId and (stageName!='Closed Won' and stageName!='Closed Lost' and stageName!='Closed Won = Lease Signed')];
        if(!oppList.isEmpty()){
            return oppList[0].Id;   
        }
        else{
            
            Opportunity opp = new Opportunity();
            opp.LeadSource = emailServiceSetting.Lead_Source__c;
            opp.AccountId = accountId;
            opp.RecordTypeId = cloudhouseOptyRecordTypeId;
            opp.StageName = emailServiceSetting.Opportunty_Stage_Name__c;
            opp.CloseDate = System.today()+Integer.valueOf(emailServiceSetting.No_Of_Days_To_Close_Opportunity__c);
            opp.Name = firstName+' '+lastName+' '+System.today();
            opp.OwnerId = getUserId();
            insert opp;
            return opp.Id;
        }
        
    }
    
    /*** Logic to Convert the Lead to Contact/Opportunity/Account ***/
    public static Database.LeadConvertResult convertLead(String leadId){
        
        Database.LeadConvert tempLC = new Database.LeadConvert();
        tempLC.setLeadId(leadId);
        tempLC.setConvertedStatus('Appointment');
        Database.LeadConvertResult convertedLead= Database.convertLead(tempLC);
        return convertedLead;
    }
    
    
    public class StessaResponse{
        
        public String opportunityId;
        public string emailId;
    }
    
    /*** Logic to Update Account and Opportunity after Conversion ***/
    public static void updateOpportunityAccountAfterConversion(String parentId,String accountId,String contactId){
        
        Id roofstockOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(emailServiceSetting.Opportunity_RecordType__c).getRecordTypeId();
        Id roofstockAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(emailServiceSetting.Account_RecordType__c).getRecordTypeId();
        Id roofstockContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(emailServiceSetting.Contact_RecordType__c).getRecordTypeId();        
        Opportunity opp = [select Id,RecordTypeId,StageName,LeadSource,closeDate from opportunity where Id =:parentId];
        opp.RecordTypeId = roofstockOpportunityRecordTypeId;
        opp.StageName = emailServiceSetting.Opportunty_Stage_Name__c;
        opp.Lead_Source__c = emailServiceSetting.Lead_Source__c;
        opp.OwnerId = getUserId();
        opp.CloseDate = System.today()+Integer.valueOf(emailServiceSetting.No_Of_Days_To_Close_Opportunity__c);
        update opp;        
        Account acc = [select Id,RecordTypeId from Account where Id =:accountId];
        acc.RecordTypeId = roofstockAccountRecordTypeId;
        acc.OwnerId = getUserId();
        update acc;
        Contact con = [select Id,RecordTypeId from Contact where Id=:contactId];
        con.RecordTypeId = roofstockContactRecordTypeId;
        con.OwnerId = getUserId();
        update con;
    }
    
    /** Get USer Id  **/
    public static String getUserId(){
        User objUser = [select Id,Name from User where Name =: emailServiceSetting.Owner__c];
        return objUser.Id;
    }
    
    
}
public without sharing class EmailMessages {
    
    @AuraEnabled
    public static List<subJectEmailWrap> messages(String parentRecordId){
        
        Map<String,String> emailStatusMap = new Map<String,String>();
        emailStatusMap.put('0','New');
        emailStatusMap.put('1','Read');
        emailStatusMap.put('2','Replied');
        emailStatusMap.put('3','Sent');
        emailStatusMap.put('4','Forwarded');
        emailStatusMap.put('5','Draft');
        List<subJectEmailWrap> subjEmailWrapList = new List<subJectEmailWrap>();
        List<EmailMessage> emailMessageList = [select Id,Subject,EmailServiceParentId__c,Has_Attachment__c,HtmlBody,TextBody,MessageDate,IsOpened,status from EmailMessage where EmailServiceParentId__c=:parentRecordId order by MessageDate desc];
        
        Map<String,List<emailMessageWrap>> emWrapMap = new Map<String,List<emailMessageWrap>>();
        
        Integer maxSize = 200;
        for(EmailMessage em : emailMessageList){
            
            String subj = em.subject;
            if(subj!=null){
                if(subj.contains(':')){
                    subj = subj.substring(subj.lastIndexOf(':') + 1).trim();
                }
            }
            
            String baseURL = String.valueOf(system.URL.getSalesforceBaseUrl().toExternalForm());
            
            emailMessageWrap emw = new emailMessageWrap();
            //emw.emailRecId = baseURL+'/'+em.Id;
            emw.emailRecId = em.Id;
            emw.subject = em.Subject;
            //emw.embody = em.HtmlBody.stripHtmlTags();
            String eBody = em.HtmlBody.stripHtmlTags();
            if(eBody.length() > maxSize ){
                emw.embody =   eBody.substring(0, maxSize)+'...';  
            }
            else{
                emw.embody = em.HtmlBody.stripHtmlTags();
            }
            emw.status = emailStatusMap.get(em.Status);
            emw.messageDate = em.MessageDate.format('MM-dd-yyyy h:mm a');
            emw.hasAttachment = em.Has_Attachment__c;
            //emw.textBody = em.TextBody;
            if(!emWrapMap.containsKey(subj)){
                emWrapMap.put(subj,new List<emailMessageWrap>{emw});
            }
            else{
                List<emailMessageWrap> emailMessageWrapList = emWrapMap.get(subj);
                emailMessageWrapList.add(emw);
                emWrapMap.put(subj,emailMessageWrapList);
                
            }
        }
        
        //Iteration
        for(String subj : emWrapMap.keyset()){
            subJectEmailWrap sew = new subJectEmailWrap();
            sew.subject = subj;
            sew.emailMessageList = emWrapMap.get(subj);
            subjEmailWrapList.add(sew);
        }
        
        System.debug('-subjEmailWrapList-'+subjEmailWrapList);
        return subjEmailWrapList;
        
    }
    
    @AuraEnabled
    public static EmailBodyAttachment emailBodyAttachment(String emailRecId){
        EmailMessage em = [select Id,FromAddress,FromName,CcAddress,Status,Subject,ToAddress,HtmlBody,TextBody,messageDate,incoming from EmailMessage where Id=:emailRecId];
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :emailRecId];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
        
        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
        List<AttachmentWrap> AttachmentWrapList = new List<AttachmentWrap>();
        for(ContentVersion cv : docs){
            AttachmentWrap aw = new AttachmentWrap();
            aw.documentId = '/sfc/servlet.shepherd/document/download/'+cv.ContentDocumentId;
            aw.documentName = cv.Title;
            AttachmentWrapList.add(aw);
        }
        String docURL = System.Label.Attachment_URL;
        List<Attachment> atchList = [select Id,Name from Attachment where parentId=:emailRecId];
        for(Attachment att : atchList){
            AttachmentWrap aw = new AttachmentWrap();
            //aw.documentId = '/sfc/servlet.shepherd/document/download/'+att.Id;
            // aw.documentId = '/servlet/servlet.FileDownload?file='+att.Id;
            aw.documentId = docURL+att.Id;
            
            aw.documentName = att.Name;
            AttachmentWrapList.add(aw);
        }
        EmailBodyAttachment eba = new EmailBodyAttachment();
        eba.frm = em.FromAddress;
        eba.to = em.ToAddress;
        eba.subject = em.Subject;
        eba.status = em.Status;
        eba.fromName = em.FromName;
        eba.cc = em.CcAddress;
        eba.messageDate = String.valueOf(em.MessageDate);
        //eba.body=em.TextBody;
        eba.body = em.HtmlBody;
        if(em.Incoming == false){
        	eba.disable = true;
        }
        else{
            eba.disable = false;
        }
        //eba.body = em.HtmlBody.stripHtmlTags();
        eba.attachmentList = AttachmentWrapList;
        System.debug('-eba-'+eba);
        System.debug('-eba-'+em);
        System.debug('-from name-'+em.FromName);
        return eba; 
        
    }
    
    
    @AuraEnabled
    public static EmailMessage emailBody(String emailRecId){
        EmailMessage em = [select Id,FromAddress,ToAddress,HtmlBody,TextBody,messageDate from EmailMessage where Id=:emailRecId];
        return em;
        
    }
    
    @AuraEnabled
    public static String emailServiceAddress(String recordId){
        EmailServicesFunction emailFunction;
        Id recId = Id.valueOf(recordId);
        String obj = String.valueOf(recId.getsobjecttype());
        System.debug('-obj-'+obj);
        String emailServiceAddress = '';
        if(obj == 'Lead' || obj == 'Opportunity'){
            emailFunction = [SELECT Id FROM EmailServicesFunction WHERE FunctionName='iBuy'];
            System.debug('-emailFunction-'+emailFunction);
            
        }
        else if(obj == 'ATF_Work_Queue__c' || obj == 'Investment_Account__c'){
            emailFunction = [SELECT Id FROM EmailServicesFunction WHERE FunctionName='Roofstock One'];
            
        }
        else if(obj == 'Transaction__c'){
            emailFunction = [SELECT Id FROM EmailServicesFunction WHERE FunctionName='Transaction'];
        }
        
        System.debug('-emailFunction-'+emailFunction);
        List<EmailServicesAddress> emailServicesAddressList = new List<EmailServicesAddress>();
        if(emailFunction!=null){
        	emailServicesAddressList = [SELECT Id,DeveloperName,RunAsUserId,LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId = :emailFunction.Id];
        }
        System.debug('-emailServicesAddressList-'+emailServicesAddressList);
        if(emailServicesAddressList.size()>0){
        	emailServiceAddress =  emailServicesAddressList[0].LocalPart+ '@' + emailServicesAddressList[0].EmailDomainName;
        }
        System.debug('-emailServicesAddressList-'+emailServicesAddressList);
        if(obj == 'HOA__c' || obj == 'Violation__c'){
            List<OrgWideEmailAddress> oweaList = new List<OrgWideEmailAddress>();
            oweaList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName=:System.Label.HOA_Violation_Email_From_Name];
            emailServiceAddress = oweaList[0].Address;
        }
        return emailServiceAddress;
    }
    
    @AuraEnabled
    public static string fromAddress(String recordId){
        Id recId = Id.valueOf(recordId);
        String obj = String.valueOf(recId.getsobjecttype());
        System.debug('-obj-'+obj);
        String fromAddress = '';
        EmailServicesFunction emailFunction;
        String emailServiceAddress = '';
        
        if(obj == 'Lead' || obj == 'Opportunity'){
            
            emailFunction = [SELECT Id FROM EmailServicesFunction WHERE FunctionName='iBuy'];
            List<EmailServicesAddress> emailServicesAddress = [SELECT Id,DeveloperName,RunAsUserId,LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId = :emailFunction.Id];
            emailServiceAddress =  emailServicesAddress[0].LocalPart+ '@' + emailServicesAddress[0].EmailDomainName;
            return emailServiceAddress;
        }
        else if(obj == 'ATF_Work_Queue__c' || obj == 'Investment_Account__c'){
            
            List<OrgWideEmailAddress> oweaList = new List<OrgWideEmailAddress>();
            oweaList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address='one@roofstock.com'];
            return oweaList[0].Address;
        }
        else if(obj == 'HOA__c' || obj == 'Violation__c'){
            List<OrgWideEmailAddress> oweaList = new List<OrgWideEmailAddress>();
            oweaList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName=:System.Label.HOA_Violation_Email_From_Name];
            return oweaList[0].Address;
        }
        else if(obj == 'Inspection__c' || obj == 'Job__c'){
            List<OrgWideEmailAddress> oweaList = new List<OrgWideEmailAddress>();
            oweaList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName=:System.Label.Inspection_Job_Email_From_Name];
            return oweaList[0].Address;
        }
        else if(obj == 'Transaction__c'){
            List<OrgWideEmailAddress> oweaList = new List<OrgWideEmailAddress>();
            oweaList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName=:System.Label.Transaction_Email];
            return oweaList[0].Address;
        }
        else {
            return null;
        }
        
        
    }
    
    
    @AuraEnabled
    public static List<forwardFiles> forwardEmails(string recordId){
        Set<Id> cdIds = new Set<Id>();
        List<forwardFiles> filenameList = new List<forwardFiles>();
        for(ContentDocumentLink  cl : [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId]){
            cdIds.add(cl.ContentDocumentId);
        }
        System.debug('-cdIds-'+cdIds);
        list<ContentVersion> attachMent = new list<ContentVersion>([SELECT  id,ContentLocation,PathOnClient,Origin,Title,VersionData FROM ContentVersion Where ContentDocumentId In :cdIds]); 
        List<Attachment> attachments = [select Id,Name,body from Attachment where parentId=:recordId];
        System.debug('-recordId-'+recordId);
        
        system.debug('attachMent===='+attachMents);
        for(ContentVersion cv : attachMent){
            forwardFiles ff = new forwardFiles();
            ff.fileName = cv.Title;
            filenameList.add(ff);
        }
        for(Attachment att: attachments){
            forwardFiles ff = new forwardFiles();
            ff.fileName = att.Name;
            filenameList.add(ff);
        }
        System.debug('-filenameList-'+filenameList);
        return filenameList; 
    }
    
    
    
    public class taskSubjectWrap{
        @AuraEnabled public String task;
        @AuraEnabled public List<subJectEmailWrap> subjectEmailWrapList;
        
    }
    
    public class subJectEmailWrap{
        @AuraEnabled public String subject;
        @AuraEnabled public List<emailMessageWrap> emailMessageList;
    }
    
    public class emailMessageWrap{
        @AuraEnabled public String emailRecId;
        @AuraEnabled public String subject;
        @AuraEnabled Public String status;
        @AuraEnabled Public String embody;
        @AuraEnabled public String messageDate;
        @AuraEnabled Public boolean hasAttachment;
        
    }
    
    public class EmailBodyAttachment{
        @AuraEnabled public String frm;
        @AuraEnabled public string to;
        @auraEnabled public String messageDate;
        @AuraEnabled public string body;
        @AuraEnabled public string subject;
        @AuraEnabled public string status;
        @AuraEnabled public string fromName;
        @AuraEnabled public string cc;
        @AuraEnabled public boolean disable;
        @AuraEnabled public List<AttachmentWrap> attachmentList;
        
    }
    
    public class AttachmentWrap{
        @AuraEnabled public String documentId;
        @AuraEnabled public String documentName;
        
    }
    public class forwardFiles{
        @auraEnabled public string fileName;
    }
}
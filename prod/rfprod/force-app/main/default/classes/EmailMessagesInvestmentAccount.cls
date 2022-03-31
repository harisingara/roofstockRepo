public without sharing class EmailMessagesInvestmentAccount {
    
    @AuraEnabled(cacheable=true)
    public static List<taskSubjectWrap> taskEmails(String recordId){
        List<EmailMessage> emailMessageList = new List<EmailMessage>();
        Id recId = Id.valueOf(recordId);
        String obj = String.valueOf(recId.getsobjecttype());
        if(obj == 'Investment_Account__c'){
            emailMessageList = [select Id,Subject,My_Task__c,HtmlBody,Has_Attachment__c,TextBody,MessageDate,IsOpened,status from EmailMessage where My_Task__r.Investment_Account__c=:recordId order by MessageDate desc];
        }
        else if(obj == 'ATF_Work_Queue__c'){
            emailMessageList = [select Id,Subject,My_Task__c,HtmlBody,Has_Attachment__c,TextBody,MessageDate,IsOpened,status from EmailMessage where My_Task__c=:recordId order by MessageDate desc];
            
        }
        Map<String,List<emailMessageWrap>> emWrapMap = new Map<String,List<emailMessageWrap>>();
        Map<String,Set<String>> taskSubjectMap = new Map<String,Set<String>>();
        Set<String> taskSet = new Set<String>();
        for(EmailMessage em : emailMessageList){
            taskSet.add(em.My_Task__c);
        }
        Map<String,String> taskNameMap = new Map<String,String>();
        List<ATF_Work_Queue__c> matchingTaskList = [select Id,Name,RecordType.Name from ATF_Work_Queue__c where Id IN:taskSet];
        for(ATF_Work_Queue__c tsk : matchingTaskList){
            taskNameMap.put(tsk.Id,tsk.Name+'-'+tsk.RecordType.Name);	    
        }
        String baseURL = String.valueOf(system.URL.getSalesforceBaseUrl().toExternalForm());
       
        Map<String,String> emailStatusMap = new Map<String,String>();
        emailStatusMap.put('0','New');
        emailStatusMap.put('1','Read');
        emailStatusMap.put('2','Replied');
        emailStatusMap.put('3','Sent');
        emailStatusMap.put('4','Forwarded');
        emailStatusMap.put('5','Draft');
        
        Integer maxSize = 200;
        for(EmailMessage em : emailMessageList){
            System.debug('=em='+em.TextBody);
            taskSet.add(em.My_Task__c);
            String subj = em.subject;
            if(subj!=null){
                if(subj.contains(':')){
                    subj = subj.substring(subj.lastIndexOf(':') + 1).trim();
                }
            }
            
            
         
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
            if(!emWrapMap.containsKey(em.My_Task__c+'-'+subj)){
                emWrapMap.put(em.My_Task__c+'-'+subj,new List<emailMessageWrap>{emw});
            }
            else{
                List<emailMessageWrap> emailMessageWrapList = emWrapMap.get(em.My_Task__c+'-'+subj);
                emailMessageWrapList.add(emw);
                emWrapMap.put(em.My_Task__c+'-'+subj,emailMessageWrapList);
                
            }
            
         
            if(!taskSubjectMap.containsKey(em.My_Task__c)){
                taskSubjectMap.put(em.My_Task__c,new Set<String>{em.My_Task__c+'-'+subj});
            }
            else{
                Set<String> taskSubjectSet = taskSubjectMap.get(em.My_Task__c);
                taskSubjectSet.add(em.My_Task__c+'-'+subj);
                taskSubjectMap.put(em.My_Task__c,taskSubjectSet);
                
            }
            
            
        }
        System.debug('=taskSubjectMap='+taskSubjectMap);
        System.debug('=emWrapMap='+emWrapMap);
        
        
     
        System.debug('-tasks-'+taskSubjectMap.keySet());        
        List<taskSubjectWrap> taskSubjectWrapList = new List<taskSubjectWrap>();
        for(String task : taskSubjectMap.keySet()){
            
            List<subJectEmailWrap> subEmailWrapList = new List<subJectEmailWrap>();
            for(String sub : taskSubjectMap.get(task)){
                subJectEmailWrap sew = new subJectEmailWrap();
                sew.subject = sub.substringAfter('-');
                sew.emailMessageList = emWrapMap.get(sub);
                subEmailWrapList.add(sew);
            }
            taskSubjectWrap tsw = new taskSubjectWrap();
            tsw.task = taskNameMap.get(task);
            tsw.subjectEmailWrapList = subEmailWrapList;
            taskSubjectWrapList.add(tsw);
            
        }
        System.debug('=taskSubjectWrapList='+taskSubjectWrapList);
        return taskSubjectWrapList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<subJectEmailWrap> IAEmails(String recordId){
        
        Map<String,String> emailStatusMap = new Map<String,String>();
        emailStatusMap.put('0','New');
        emailStatusMap.put('1','Read');
        emailStatusMap.put('2','Replied');
        emailStatusMap.put('3','Sent');
        emailStatusMap.put('4','Forwarded');
        emailStatusMap.put('5','Draft');
        List<subJectEmailWrap> subjEmailWrapList = new List<subJectEmailWrap>();
        List<EmailMessage> emailMessageList = [select Id,Subject,My_Task__c,Has_Attachment__c,HtmlBody,TextBody,MessageDate,IsOpened,status from EmailMessage where Investment_Account__c=:recordId order by MessageDate desc];
        
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
        EmailMessage em = [select Id,FromAddress,ToAddress,HtmlBody,TextBody,messageDate from EmailMessage where Id=:emailRecId];
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
        
        List<Attachment> atchList = [select Id,Name from Attachment where parentId=:emailRecId];
        for(Attachment att : atchList){
        	AttachmentWrap aw = new AttachmentWrap();
            aw.documentId = '/sfc/servlet.shepherd/document/download/'+att.Id;
            aw.documentName = att.Name;
            AttachmentWrapList.add(aw);
        }
        EmailBodyAttachment eba = new EmailBodyAttachment();
        eba.frm = em.FromAddress;
        eba.to = em.ToAddress;
        eba.messageDate = String.valueOf(em.MessageDate);
        eba.body=em.TextBody;
        eba.attachmentList = AttachmentWrapList;
        
        return eba; 
        
    
    }
    
    @AuraEnabled
    public static EmailMessage emailBody(String emailRecId){
        EmailMessage em = [select Id,FromAddress,ToAddress,HtmlBody,TextBody,messageDate from EmailMessage where Id=:emailRecId];
        return em;
        
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
        @AuraEnabled public List<AttachmentWrap> attachmentList;
        
    }
    
    public class AttachmentWrap{
        @AuraEnabled public String documentId;
        @AuraEnabled public String documentName;
        
    }
    
}
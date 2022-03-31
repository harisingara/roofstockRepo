public without sharing class GenericEmailNotification {
    
    @AuraEnabled
    public static boolean sendEmails(String frm,String to,String cc,String bcc,String subject,string body,String forwardBody,String emailServiceAddress,String emailType,String recordId,List<String> files,String selectedEmailTemplateId,String emailParentId){
        System.debug('-recordId-'+recordId);
        System.debug('-subject-'+subject);
        String sObjName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        String currentRecord='';
        if(sObjName == 'EmailMessage'){
            currentRecord = emailParentId;
        }
        else{
            currentRecord = recordId;
        }
        String parentId;
        List<ContentDocument> listToDelete = new List<ContentDocument>();
        List<ContentVersion> uploadedFileList = new List<ContentVersion>();
        System.debug('-files-'+files);
        
        
        if(!files.isEmpty()){
            uploadedFileList = [SELECT  id,ContentLocation,FileExtension,ContentDocumentId,PathOnClient,Origin,Title,VersionData FROM ContentVersion Where ContentDocumentId IN:files];
            for(ContentVersion cv : uploadedFileList){
                listToDelete.add(new ContentDocument(Id = cv.ContentDocumentId));               
            }
        }
        System.debug('-listToDelete-'+listToDelete);
        
        
        if(body.indexof('ref:') !=-1 && !body.contains('TRNS')){
            parentId= body.Substring(body.indexof('ref:')+4,body.indexof('ref:')+22);
        }
        else if(body.indexof('ref:') !=-1 && body.contains('TRNS')){
            parentId = currentRecord;
        }
        else if(subject.indexof('ref:') !=-1){
            parentId= subject.Substring(subject.indexof('ref:')+4,subject.indexof('ref:')+22);
            body = body+'\n\n\n'+'ref:'+currentRecord;
        }
        else{
            parentId = currentRecord;
            body = body+'\n\n\n'+'ref:'+currentRecord;
            
        }
        System.debug('=parentId='+parentId);
        /*Get Org wide address*/
        Id recId = Id.valueOf(parentId);
        String obj = String.valueOf(recId.getsobjecttype());
        System.debug('-obj-'+obj);
        List<OrgWideEmailAddress> oweaList = new List<OrgWideEmailAddress>();
        if(obj == 'Investment_Account__c' || obj == 'ATF_Work_Queue__c'){
            oweaList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address='one@roofstock.com'];
        }
        if(obj == 'HOA__c' || obj == 'Violation__c'){
            oweaList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName=:System.Label.HOA_Violation_Email_From_Name];
        }
        if(obj == 'Inspection__c' || obj == 'Job__c'){
            oweaList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName=:System.Label.Inspection_Job_Email_From_Name];
        }
        if(obj == 'Transaction__c'){
            oweaList = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName=:System.Label.Transaction_Email];
        }
        List<String> toEmail = new List<String>();
        List<String> ccEmail = new List<String>();
        List<String> bccEmail = new List<String>();
        
        if(!String.isBlank(to)){
            toEmail = to.split(';');
        }
        if(!String.isBlank(cc)){
            ccEmail = cc.split(';');
        }
        if(!String.isBlank(bcc)){
            bccEmail = bcc.split(';');
        }
        //toEmail.add(to);
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        mail.setToAddresses(toEmail); 
        if(oweaList.size()>0){
            if(oweaList[0].Id!=null){
                mail.setOrgWideEmailAddressId(oweaList[0].Id); 
            }
        }
        //mail.setCCAddresses( new String[]{lstEmailAddress[0].Address});
        if(!ccEmail.isEmpty()){
            mail.setCCAddresses(ccEmail);
        }
        if(!bccEmail.isEmpty()){
            mail.setBccAddresses(bccEmail);
        }
        mail.setReplyTo(emailServiceAddress);
        mail.setSubject(subject);
        mail.setHtmlBody(body);        
        
        List<ContentVersion> relatedDocuments = new List<ContentVersion>();
        List<Attachment> attLst = new List<Attachment>();
        Set<Id> cdIds = new Set<Id>();
        //Forwarded Emails files
        if(emailType == 'forward'){
            //Get attachment from the content document
            List<ContentDocumentLink>  clList = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId=:recordId];
            system.debug('clList@@' +clList);
            for(ContentDocumentLink cdl:clList){
                cdIds.add(cdl.ContentDocumentId);
            }
            List<ContentVersion> conversionList = [SELECT  id,ContentLocation,FileExtension,PathOnClient,Origin,Title,VersionData FROM ContentVersion Where ContentDocumentId In :cdIds]; 
            
            for(ContentVersion cv : conversionList){
                ContentVersion contentVersionFile = new ContentVersion();
                contentVersionFile.PathOnClient = cv.PathOnClient;
                contentVersionFile.Title = cv.Title;
                contentVersionFile.VersionData = cv.VersionData;
                relatedDocuments.add(contentVersionFile);
            }
            
            //Get attachment from the attachment object
            System.debug('-recordId-'+recordId);
            attLst = [Select Name, Body From Attachment Where parentId=:recordId];
        }
        
        
        if(uploadedFileList.size()>0){ 
            for (ContentVersion cvf : uploadedFileList) {
                
                ContentVersion contentVersionFile = new ContentVersion();
                contentVersionFile.PathOnClient = cvf.PathOnClient;
                contentVersionFile.Title = cvf.Title;
                contentVersionFile.VersionData = cvf.VersionData;
                contentVersionFile.PathOnClient = cvf.Title + '.' + cvf.FileExtension;
                relatedDocuments.add(contentVersionFile);
            }
        }
        
        insert relatedDocuments;
        
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        for (ContentVersion file: relatedDocuments) {
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(file.pathOnClient);
            efa.setBody(file.VersionData);
            attachments.add(efa);
        }
        if(attLst.size()>0){
            for(Attachment att : attLst){
                Messaging.EmailFileAttachment emailFA = new Messaging.EmailFileAttachment();
                emailFA.setFileName(att.Name);
                emailFA.setBody(att.body);
                attachments.add(emailFA);
            }
        }
        mail.setFileAttachments(attachments);
        
        mails.add(mail);
        
        try {
            
            EmailMessage taskEmailMessage = new EmailMessage();
            taskEmailMessage.fromAddress= frm;
            taskEmailMessage.ToAddress = to;
            if(!string.isBlank(cc)){
                taskEmailMessage.CcAddress = cc;
            }
            if(!string.isBlank(bcc)){
                taskEmailMessage.BccAddress = bcc;
            }
            System.debug('-subject-'+subject);
            taskEmailMessage.FromName = UserInfo.getName();
            taskEmailMessage.Subject = subject;
            taskEmailMessage.HtmlBody = body;
            taskEmailMessage.Incoming= False;
            taskEmailMessage.TextBody = body;
            taskEmailMessage.status = '3';
            //Id recId = Id.valueOf(parentId);
            //String obj = String.valueOf(recId.getsobjecttype());
            //if(recordId.startsWith('a1j')){
            System.debug('-obj-'+obj);
            Boolean leadEmailMessage = false;
            if(obj == 'Lead'){
                leadEmailMessage = true;
                //taskEmailMessage.RelatedToId = parentId;
                String[] toIds = new String[]{parentId};   
                taskEmailMessage.toIds = toIds;  
                taskEmailMessage.Lead__c = parentId;
                taskEmailMessage.EmailServiceParentId__c = parentId;
            }
            if(obj == 'Opportunity'){
                taskEmailMessage.RelatedToId = parentId;
                taskEmailMessage.Opportunity__c = parentId;
                taskEmailMessage.EmailServiceParentId__c = parentId;
            }
            else if(obj == 'ATF_Work_Queue__c'){
                taskEmailMessage.RelatedToId = parentId;
                taskEmailMessage.My_Task__c = parentId;
                taskEmailMessage.EmailServiceParentId__c = parentId;
            }
            else if(obj == 'Investment_Account__c'){
                taskEmailMessage.RelatedToId = parentId; // Added by SF support
                taskEmailMessage.Investment_Account__c = parentId;
                taskEmailMessage.EmailServiceParentId__c = parentId;
            }
            else if(obj == 'HOA__c'){
                taskEmailMessage.RelatedToId = parentId;
                taskEmailMessage.Hoa__c = parentId;
                taskEmailMessage.EmailServiceParentId__c = parentId;
            }
            else if(obj == 'Violation__c'){
                taskEmailMessage.RelatedToId = parentId;
                taskEmailMessage.Violation__c = parentId;
                taskEmailMessage.EmailServiceParentId__c = parentId;
            }
            else if(obj == 'Inspection__c'){
                taskEmailMessage.RelatedToId = parentId;
                taskEmailMessage.Inspection__c = parentId;
                taskEmailMessage.EmailServiceParentId__c = parentId;
            }
            else if(obj == 'Job__c'){
                taskEmailMessage.RelatedToId = parentId;
                taskEmailMessage.Job__c = parentId;
                taskEmailMessage.EmailServiceParentId__c = parentId;
            }
            else if(obj == 'Transaction__c'){
                taskEmailMessage.RelatedToId = parentId;
                taskEmailMessage.Transaction__c = parentId;
                taskEmailMessage.EmailServiceParentId__c = parentId;               
            }
            
            if(attachments.size()>0){
                taskEmailMessage.Has_Attachment__c = true;
            }
            
            insert taskEmailMessage;
            // Add Email Message Relation for id of the sender 
            
            if(leadEmailMessage == true){
                EmailMessageRelation emr = new EmailMessageRelation();  
                emr.emailMessageId = taskEmailMessage.Id;  
                emr.relationId = parentId; // Lead Id  
                emr.relationType = 'OtherAddress';  
                insert emr; 
            }
            Set<String> contentDocumentSet = new Set<String>();
            List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
            List<ContentVersion> cvList = [SELECT ContentDocumentId,FileExtension FROM ContentVersion WHERE Id IN:relatedDocuments];
            for(ContentVersion cv : cvList){
                contentDocumentSet.add(cv.ContentDocumentId);       
            }
            for(String cd : contentDocumentSet){
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = taskEmailMessage.Id;              
                cdl.ContentDocumentId = cd;
                cdl.shareType = 'V';
                cdl.Visibility = 'AllUsers';
                contentDocumentLinkList.add(cdl);
                
                /*ContentDocumentLink cdl2 = New ContentDocumentLink();
                cdl2.LinkedEntityId = '0F98G00000000Sa';              
                cdl2.ContentDocumentId = cd;
                cdl2.shareType = 'V';
                cdl2.Visibility = 'AllUsers';
                contentDocumentLinkList.add(cdl2);*/
                
            }
            
            insert contentDocumentLinkList;
            system.debug('>>>>>=='+ contentDocumentLinkList ); 
            system.debug('>>>>>=='+ taskEmailMessage ); 
            system.debug('>>>>>=='+ taskEmailMessage.Id );
            // Send all emails in the master list
            Messaging.sendEmail(mails);
            //system.debug('>>>>>=='+ mails); 
            if(!listToDelete.isEmpty()){
                delete listToDelete;
            }
            return true;
        }
        catch(Exception ex){
            if(!listToDelete.isEmpty()){
                delete listToDelete;
            }
            return false;
        }
    }
    public class relatedFile {
        public String PathOnClient;
        public String Title;
        public Blob VersionData;
    }
    public class emailTemplateWrapper { 
        @AuraEnabled 
        public String folderName{get;set;}
        @AuraEnabled 
        public String folderId{get;set;}
        @AuraEnabled
        public list<emailTemplates> emailtemplatelist{get;set;}    
    }
    public class emailTemplates {
        @AuraEnabled 
        public String emailTemplateId{get;set;}        
        @AuraEnabled 
        public String emailbody{get;set;}        
        @AuraEnabled
        public String emailSubject {get;set;}        
        @AuraEnabled 
        public String emailTemplatename{get;set;}
    }  
    @AuraEnabled
    public static list<emailTemplateWrapper> getEmailTempaltes(String recordId){
        String objType = String.valueOf(Id.valueOf(recordId).getsobjecttype());
        list<emailTemplateWrapper> emailTemplateWrapperlist = new list<emailTemplateWrapper>();
        map<String,emailTemplateWrapper> folderIdVsTemplateMap = new map<String,emailTemplateWrapper>();
        Map<Id,EnhancedLetterhead> mapEnhancedLetterHead = new Map<Id,EnhancedLetterhead>();
        Set<String> setEnhancedLetterHeadId = new Set<String>();
        List<EmailTemplate> lstEmailTemplate = [SELECT Id,EnhancedLetterheadId,RelatedEntityType,FolderId, HtmlValue, FolderName, isActive, body,Name,subject FROM EmailTemplate where isActive= true and RelatedEntityType=:objType];
        for(EmailTemplate eTemplate : lstEmailTemplate){
            setEnhancedLetterHeadId.add(eTemplate.EnhancedLetterheadId);
        }
        List<EnhancedLetterhead> lstEnhancedLetterHead = [select Id,LetterheadHeader,LetterheadFooter from EnhancedLetterhead where Id IN :setEnhancedLetterHeadId];
        for(EnhancedLetterhead enhancedLtrhd : lstEnhancedLetterHead){
            mapEnhancedLetterHead.put(enhancedLtrhd.Id,enhancedLtrhd);
        }
        for(sobject emailtemp : lstEmailTemplate){
             String letterHeadHeader = '';
            String letterHeadFooter = '';
            if(emailtemp.get('EnhancedLetterheadId')!=null){
                String enhancedLetterheadId = String.valueOf(emailtemp.get('EnhancedLetterheadId'));
                //EnhancedLetterhead enhancedLetterhead = [select Id,LetterheadHeader from EnhancedLetterhead where Id = :enhancedLetterheadId];
                letterHeadHeader = mapEnhancedLetterHead.get(String.valueOf(emailtemp.get('EnhancedLetterheadId'))).LetterheadHeader;
                letterHeadFooter = mapEnhancedLetterHead.get(String.valueOf(emailtemp.get('EnhancedLetterheadId'))).LetterheadFooter;                
            }
            String emailTemplateBody = previewEmailTemplate(letterHeadHeader,letterHeadFooter,String.valueOf(emailtemp.get('HtmlValue')),recordId);
            if( folderIdVsTemplateMap.containskey( String.valueof(emailtemp.get('FolderId'))) ){
                
                EmailTemplates template = new EmailTemplates();
                template.emailTemplateId = String.valueOf(emailtemp.get('Id'));
                template.emailTemplatename = String.valueOf(emailtemp.get('Name'));
                template.emailbody = emailTemplateBody;
                //template.emailbody = (emailtemp.get('HtmlValue') != null ? String.valueOf(emailtemp.get('HtmlValue')) : '' );
                String psubject = previewEmailTemplate(null,null,String.valueOf(emailtemp.get('subject')),recordId);
                template.emailSubject = psubject;
                folderIdVsTemplateMap.get( String.valueof(emailtemp.get('FolderId')) ).emailtemplatelist.add( template );
                
            }else{
                emailTemplateWrapper tempWrap = new emailTemplateWrapper();
                tempWrap.folderId = String.valueOf(emailtemp.get('FolderId'));
                tempWrap.folderName = String.valueOf(emailtemp.get('FolderName'));
                
                emailTemplates template = new emailTemplates();
                template.emailTemplateId = String.valueOf(emailtemp.get('Id'));
                template.emailTemplatename = String.valueOf(emailtemp.get('Name'));
                //template.emailbody = (emailtemp.get('HtmlValue') != null ? String.valueOf(emailtemp.get('HtmlValue')) : '' );
                template.emailbody = emailTemplateBody;                
                //template.emailSubject = String.valueOf(emailtemp.get('subject'));
                String psubject = previewEmailTemplate(null,null,String.valueOf(emailtemp.get('subject')),recordId);
                template.emailSubject = psubject;
                tempWrap.emailtemplatelist = new list<emailTemplates>{ template };
                    folderIdVsTemplateMap.put( String.valueof(emailtemp.get('FolderId'))  , tempWrap );
                System.debug('-folderIdVsTemplateMap-'+folderIdVsTemplateMap);
            }   
        }
        
        if( !folderIdVsTemplateMap.isEmpty() ){
            emailTemplateWrapperlist.addAll( folderIdVsTemplateMap.values() );
            System.debug('-emailTemplateWrapperlist-'+emailTemplateWrapperlist);
            return emailTemplateWrapperlist;
        }
        return null;
    }
    public static String previewEmailTemplate(String letterHeadHeader,String letterHeadFooter,String emailbody,String currentRecord){
        System.debug('-emailbody-'+letterHeadHeader+' '+emailbody+ ''+letterHeadFooter);
        String sObjName = ID.valueOf(currentRecord).getSObjectType().getDescribe().getName();
        System.debug('-sObjName-'+sObjName);        
        String contextObjectRecordId='';
        Map<String,String> fieldApiVariableMap = new Map<String,String>();
        Map<String,String> mergeFieldVariableMap = new Map<String,String>();
        Map<String, List<String>> objectFieldApiMap = new Map<String, List<String>>();
        Map<String,List<sobject>> mapObjQueryRecords = new Map<String,List<sobject>>();
        Map<String,String> variableFieldValueMap = new Map<String,String>();
        String previewedEmailBody = '';
        List<String> lstmergeFields = new List<String>();
        //Pattern1 - Lightning Merge Field
        Pattern patternLightningTemplate = Pattern.compile('\\{.+?\\}}}');
        string templateContentLightning = letterHeadHeader+ '\n'+emailbody+'\n'+letterHeadFooter;
        Matcher matcherLightning = patternLightningTemplate.matcher(templateContentLightning);
        while(matcherLightning.find()) {
            System.debug(matcherLightning.group(0));
            lstmergeFields.add(matcherLightning.group(0));
        }
        //Pattern - Classic Merge Field
        Pattern patternClassicTemplate = Pattern.compile('\\{!.+?\\}');
        string templateContentClassic = letterHeadHeader+ '\n'+emailbody+'\n'+letterHeadFooter;
        Matcher matcherClassic = patternClassicTemplate.matcher(templateContentClassic);
        while(matcherClassic.find()) {
            System.debug(matcherClassic.group(0));
            lstmergeFields.add(matcherClassic.group(0));
        }
        
        System.debug('-lstmergeFields-'+lstmergeFields);
        //Iterate Merge Fields to create a map
        for(String mergeField : lstmergeFields) {
            String str1=mergeField.replace('{','');
            str1=str1.replace('!','');
            String str2=str1.replace('}','');
            List<String> lstMergeFieldAftrSplit = str2.split('\\.');
            System.debug(lstMergeFieldAftrSplit);            
            String obj = lstMergeFieldAftrSplit[0];
            String fld = lstMergeFieldAftrSplit[1];
            String var = fld.replace('_','');
            fieldApiVariableMap.put(fld,var);
            //mergeFieldVariableMap.put(mergeField,var);
            mergeFieldVariableMap.put(mergeField,obj+var);
            if(objectFieldApiMap.containsKey(obj)) {
                List<String> fields = objectFieldApiMap.get(obj);
                if(!fields.contains(fld)) {
                    fields.add(fld);
                }
                 
                objectFieldApiMap.put(obj, fields);
            } else {
                objectFieldApiMap.put(obj, new List<String> { fld});
            } 
        }
        System.debug('-objectFieldApiMap-'+objectFieldApiMap);
        if(!objectFieldApiMap.isEmpty()) {

            for(String obj : objectFieldApiMap.keySet()){
                if(obj == sObjName || obj == 'User'){
                
                if(obj == 'User'){
                    contextObjectRecordId = UserInfo.getUserId();
                }
                else{
                    contextObjectRecordId = currentRecord;
                }
                String fields ='';
                String query = 'SELECT Id';
                
                for(String fld:objectFieldApiMap.get(obj)){
                        fields = fields+','+fld;                    
                }
                String subQuery1 = query+' '+fields;
                String subQuery2 = subQuery1+' FROM '+obj+' WHERE Id = :contextObjectRecordId';
                query = subQuery2;
                System.debug('-query-'+query);
                sobject[] records = Database.query(query);
                mapObjQueryRecords.put(obj,records);  
            }
            }
            for(String objType : mapObjQueryRecords.keySet()){
                sobject[] records  = mapObjQueryRecords.get(objType);
                for(String flds:objectFieldApiMap.get(objType)){
                    System.debug('--'+records[0].get(flds));
                    variableFieldValueMap.put(objType+fieldApiVariableMap.get(flds),String.valueOf(records[0].get(flds)));             
                }
            }
            
            
            System.debug('-mergeFieldVariableMap-'+mergeFieldVariableMap);
            System.debug('-variableFieldValueMap-'+variableFieldValueMap);
            
        
        }
        string htmlReplace = '' ;
        if(emailbody != null && emailbody != ''){
            if(letterHeadHeader != null && letterHeadHeader != '' && letterHeadFooter != null && letterHeadFooter != '' ){
                htmlReplace = letterHeadHeader+ '\n\n<br/>'+emailbody+'\n\n<br/>'+letterHeadFooter;
            } else {
                htmlReplace = emailbody;
            }
            
        }
        for(String mergeField : mergeFieldVariableMap.keySet()){
            if(htmlReplace != null &&  htmlReplace.containsIgnoreCase(mergeField)){
                String replacedMergeField = variableFieldValueMap.get(mergeFieldVariableMap.get(mergeField));
                if(replacedMergeField == null){
                    replacedMergeField = '';
                }
                if(letterHeadHeader != null && letterHeadHeader != '' && letterHeadFooter != null && letterHeadFooter != '' ){
                    htmlReplace = htmlReplace.replace(mergeField,replacedMergeField)+'<br/>';
                } else {
                    htmlReplace = htmlReplace.replace(mergeField,replacedMergeField); 
                }
                
            }
            
        }
        emailbody = htmlReplace;
        previewedEmailBody = emailbody;
        return previewedEmailBody;
        
    }
    
}
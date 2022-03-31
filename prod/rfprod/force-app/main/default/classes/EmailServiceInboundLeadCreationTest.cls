@isTest
public class EmailServiceInboundLeadCreationTest {
     
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void EmailServiceInboundLeadCreation1(){
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'chidanand sfdc <chidanandsfdc@gmail.com>';
        email.fromName = 'Chidanand Magadum';
        email.fromAddress = 'someaddress@email.com';
        List<String> toAddressList = new List<String>();
        toAddressList.add('chidanandsfdc@gmail.com');
        email.toAddresses = toAddressList;
        email.plainTextBody = 'chidanand sfdc <chidanandsfdc@gmail.com>';
        email.htmlBody = 'Salesforce Roofstock';
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
            EmailServiceInboundLeadCreation Inbound=new EmailServiceInboundLeadCreation();
        
        Inbound.handleInboundEmail(email, env);
        
    }
    
    static testMethod void EmailServiceInboundLeadCreation2(){
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'chidanand sfdc <chidanandsfdc@gmail.com>';
        email.fromName = 'Chidanand Magadum';
        email.fromAddress = 'someaddress@email.com';
        List<String> toAddressList = new List<String>();
        toAddressList.add('chidanandsfdc@gmail.com');
        email.toAddresses = toAddressList;
        email.htmlBody = 'Salesforce Roofstock';
        email.plainTextBody = 'chidanand sfdc <chidanandsfdc@gmail.com>';
        Messaging.InboundEmail.TextAttachment attachment = new Messaging.InboundEmail.TextAttachment();
        attachment.body = 'my attachment text';
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachment };
            
            EmailServiceInboundLeadCreation Inbound=new EmailServiceInboundLeadCreation();
        Inbound.handleInboundEmail(email, env);
        
    }
    static testMethod void EmailServiceInboundMatchingLead(){
        Id istBuyerRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('CloudHouse').getRecordTypeId();
        
        Lead l = new Lead();
        l.Email = 'someaddress@email.com';
        l.LastName ='sfdc';
        l.Company ='SFDC';
        l.RecordTypeId = istBuyerRecordTypeId;
        insert l;
        
        EmailMessage newEmailMessage = new EmailMessage();
        newEmailMessage.ToAddress = 'a@gmail.com';
        newEmailMessage.FromAddress = 'someaddress@email.com';
        newEmailMessage.FromName = 'sfdc';
        newEmailMessage.Subject = 'sfdc';
        newEmailMessage.HtmlBody = 'sfdc';
        newEmailMessage.TextBody = 'sfdc';
        newEmailMessage.Lead__c =l.Id;
        newEmailMessage.EmailServiceParentId__c =  l.Id;
        insert newEmailMessage;
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'chidanand sfdc <chidanandsfdc@gmail.com>';
        email.fromName = 'Chidanand Magadum';
        email.fromAddress = 'someaddress@email.com';
        List<String> toAddressList = new List<String>();
        toAddressList.add('chidanandsfdc@gmail.com');
        email.toAddresses = toAddressList;
        email.plainTextBody = 'chidanand sfdc <chidanandsfdc@gmail.com>';
        email.htmlBody = 'Salesforce Roofstock';
        Messaging.InboundEmail.TextAttachment attachment = new Messaging.InboundEmail.TextAttachment();
        attachment.body = 'my attachment text';
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachment };
            
            EmailServiceInboundLeadCreation Inbound=new EmailServiceInboundLeadCreation();
        Inbound.handleInboundEmail(email, env);
        
    }
    
    static testMethod void EmailServiceInboundMatchingContact(){
        Id roofstockContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Roofstock Contact').getRecordTypeId();
        
        /*Lead l = new Lead();
l.Email = 'someaddress@email.com';
l.LastName ='sfdc';
l.Company ='SFDC';
l.RecordTypeId = istBuyerRecordTypeId;
insert l;*/
        Account acc = new Account();
        acc.Name='sfdc';
        insert acc;
        
        Contact con = new Contact();
        con.RecordTypeId = roofstockContactRecordTypeId;
        con.LastName = 'abc';
        con.AccountId = acc.Id;
        con.Email = 'someaddress@email.com';
        insert con;
        
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'chidanand sfdc <chidanandsfdc@gmail.com>';
        email.fromName = 'Chidanand Magadum';
        email.fromAddress = 'someaddress@email.com';
        List<String> toAddressList = new List<String>();
        toAddressList.add('chidanandsfdc@gmail.com');
        email.toAddresses = toAddressList;
        email.plainTextBody = 'chidanand sfdc <chidanandsfdc@gmail.com>';
        email.htmlBody = 'Salesforce Roofstock';
        Messaging.InboundEmail.TextAttachment attachment = new Messaging.InboundEmail.TextAttachment();
        attachment.body = 'my attachment text';
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { attachment };
            
        Opportunity opp = new Opportunity();
        opp.LeadSource = 'Stessa';
        opp.AccountId = acc.Id;
        opp.StageName = 'New';
        opp.CloseDate = System.today()+14;
        opp.Name = 'a'+' '+'a'+' '+System.today();
        insert opp;
            
        EmailMessage newEmailMessage = new EmailMessage();
        newEmailMessage.ToAddress = 'a@gmail.com';
        newEmailMessage.FromAddress = 'a@gmail.com';
        newEmailMessage.FromName = 'sfdc';
        newEmailMessage.Subject = 'sfdc';
        newEmailMessage.HtmlBody = 'sfdc';
        newEmailMessage.TextBody = 'sfdc';
        newEmailMessage.Opportunity__c =opp.Id;
        newEmailMessage.EmailServiceParentId__c =  opp.Id;
        insert newEmailMessage;
        List<EmailMessage> emailMessageList = new List<EmailMessage>();
        emailMessageList.add(newEmailMessage);
        Attachment att = new Attachment(name = 'hguhg', body = Blob.valueOf('ghghh'), parentid = newEmailMessage.id);
		insert att;
        List<Attachment> attachmentList = new List<Attachment>();
        attachmentList.add(att);
        Map<Id,List<Attachment>> emailAttachmentMap = new Map<Id,List<Attachment>>();
        emailAttachmentMap.put(newEmailMessage.Id,attachmentList);
        
        
        EmailServiceInboundLeadCreation Inbound=new EmailServiceInboundLeadCreation();
        Inbound.handleInboundEmail(email, env);
        EmailServiceInboundLeadCreation.createExistingLeadEmailMessage(emailMessageList,String.valueOf(opp.Id),emailAttachmentMap);
        
        
    }
    
}
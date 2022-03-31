@isTest
public class EmailServiceInboundTest {
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void TestinBoundEmail(){
        Account acc = new Account();
        acc.NAme='sfdc';
        insert acc;
        
        Investment_Account__c ia = new Investment_Account__c();
        ia.Name = 'sfdc';
        ia.Account__c = acc.Id;
        insert ia;
        
        Contact Con = new Contact();
        con.LastName = 'sample';
        con.Email = 'someaddress@email.com';
        Insert con;
        
        ATF_Work_Queue__c mtask = new ATF_Work_Queue__c();
        mtask.Subject__c = 'sfdc';
        mtask.Contact__c = con.Id;
        mtask.Investment_Account__c = ia.Id;
        insert mtask;
        
        
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Create Contact';
        email.fromAddress = 'someaddress@email.com';
        List<String> toAddressList = new List<String>();
        toAddressList.add('chidanandsfdc@gmail.com');
        email.toAddresses = toAddressList;
        email.plainTextBody = 'ref:'+mtask.Id;
        email.htmlBody = 'ref:'+mtask.Id;
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
        EmailServiceInbound Inbound=new EmailServiceInbound();
        Inbound.handleInboundEmail(email, env);
        Inbound.forwardEmail(email,'chidanandsfdc@gmail.com');
    }
    static testMethod void TestinBoundEmailIA(){
        Account acc = new Account();
        acc.NAme='sfdc';
        insert acc;
        
        Investment_Account__c ia = new Investment_Account__c();
        ia.Name = 'sfdc';
        ia.Account__c = acc.Id;
        insert ia;
        
        Contact Con = new Contact();
        con.LastName = 'sample';
        con.Email = 'someaddress@email.com';
        Insert con;
        
        ATF_Work_Queue__c mtask = new ATF_Work_Queue__c();
        mtask.Subject__c = 'sfdc';
        mtask.Contact__c = con.Id;
        mtask.Investment_Account__c = ia.Id;
        insert mtask;
        
        
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Create Contact';
        email.fromAddress = 'someaddress@email.com';
        List<String> toAddressList = new List<String>();
        toAddressList.add('chidanandsfdc@gmail.com');
        email.toAddresses = toAddressList;
        email.plainTextBody = 'ref:'+ia.Id;
        email.htmlBody = 'ref:'+ia.Id;
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
        EmailServiceInbound Inbound=new EmailServiceInbound();
        Inbound.handleInboundEmail(email, env);
        Inbound.forwardEmail(email,'chidanandsfdc@gmail.com');
    }
    static testMethod void TestinBoundEmailTransaction(){
        Account acc = new Account();
        acc.NAme='sfdc';
        insert acc;
        
        Investment_Account__c ia = new Investment_Account__c();
        ia.Name = 'sfdc';
        ia.Account__c = acc.Id;
        insert ia;
        
        Contact Con = new Contact();
        con.LastName = 'sample';
        con.Email = 'someaddress@email.com';
        Insert con;
        
        ATF_Work_Queue__c mtask = new ATF_Work_Queue__c();
        mtask.Subject__c = 'sfdc';
        mtask.Contact__c = con.Id;
        mtask.Investment_Account__c = ia.Id;
        insert mtask;
        
        Property2__C prop = new Property2__C();
        prop.Name = 'Test property';
        insert prop;
        
        Property_Unit__c propU1 = new Property_Unit__c();
        propU1.Name = 'Test Property Unit';
        propU1.Property__c = prop.Id;
        propU1.PropertyUnitId__c ='PU00001';
        insert propU1;
        
        Transaction__c trans = new Transaction__c();
        trans.Name = 'Test Transaction';
        trans.Buyer_Property_Instance__c = prop.id;
        trans.Stage__c = 'Pre-PSA';
        trans.Transaction_Id__c ='Test000000';
        insert trans;         
        
        Inspection__c insp = new Inspection__C();
        insp.Name = 'Test Inspection';
        insp.Inspection_Type__c = 'Diligence';
        insp.Inspection_Status__c = 'Completed';
        insp.Property__c = prop.id;
        insp.Property_Unit__c = propU1.id;
        insp.Transaction__c = trans.id;
        insp.Dilligence_Id__c = '1234';
        insert insp;   
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Create Contact';
        email.fromAddress = 'someaddress@email.com';
        List<String> toAddressList = new List<String>();
        toAddressList.add('chidanandsfdc@gmail.com');
        email.toAddresses = toAddressList;
        email.plainTextBody = 'ref:'+trans.Id;
        email.htmlBody = 'ref:'+trans.Id;
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
        EmailServiceInbound Inbound=new EmailServiceInbound();
        Inbound.handleInboundEmail(email, env);
        Inbound.forwardEmail(email,'chidanandsfdc@gmail.com');
    }
    static testMethod void TestinBoundEmailInspection(){
        Account acc = new Account();
        acc.NAme='sfdc';
        insert acc;
        
        Investment_Account__c ia = new Investment_Account__c();
        ia.Name = 'sfdc';
        ia.Account__c = acc.Id;
        insert ia;
        
        Contact Con = new Contact();
        con.LastName = 'sample';
        con.Email = 'someaddress@email.com';
        Insert con;
        
        ATF_Work_Queue__c mtask = new ATF_Work_Queue__c();
        mtask.Subject__c = 'sfdc';
        mtask.Contact__c = con.Id;
        mtask.Investment_Account__c = ia.Id;
        insert mtask;
        
        Property2__C prop = new Property2__C();
        prop.Name = 'Test property';
        insert prop;
        
        Property_Unit__c propU1 = new Property_Unit__c();
        propU1.Name = 'Test Property Unit';
        propU1.Property__c = prop.Id;
        propU1.PropertyUnitId__c ='PU00001';
        insert propU1;
        
        Transaction__c trans = new Transaction__c();
        trans.Name = 'Test Transaction';
        trans.Buyer_Property_Instance__c = prop.id;
        trans.Stage__c = 'Pre-PSA';
        trans.Transaction_Id__c ='Test000000';
        insert trans;         
        
        Inspection__c insp = new Inspection__C();
        insp.Name = 'Test Inspection';
        insp.Inspection_Type__c = 'Diligence';
        insp.Inspection_Status__c = 'Completed';
        insp.Property__c = prop.id;
        insp.Property_Unit__c = propU1.id;
        insp.Transaction__c = trans.id;
        insp.Dilligence_Id__c = '1234';
        insert insp;   
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Create Contact';
        email.fromAddress = 'someaddress@email.com';
        List<String> toAddressList = new List<String>();
        toAddressList.add('chidanandsfdc@gmail.com');
        email.toAddresses = toAddressList;
        email.plainTextBody = 'ref:'+insp.Id;
        email.htmlBody = 'ref:'+insp.Id;
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
        EmailServiceInbound Inbound=new EmailServiceInbound();
        Inbound.handleInboundEmail(email, env);
        Inbound.forwardEmail(email,'chidanandsfdc@gmail.com');
    }
    static testMethod void TestingEmailServiceInbound(){
        Account acc = new Account();
        acc.NAme='sfdc';
        insert acc;
        
        Investment_Account__c ia = new Investment_Account__c();
        ia.Name = 'sfdc';
        ia.Account__c = acc.Id;
        insert ia;
        
        Contact Con = new Contact();
        con.LastName = 'sample';
        con.Email = 'transaction@email.com';
        Insert con;
        
        ATF_Work_Queue__c mtask = new ATF_Work_Queue__c();
        mtask.Subject__c = 'sfdc';
        mtask.Contact__c = con.Id;
        mtask.Investment_Account__c = ia.Id;
        insert mtask;
        
        Property2__C prop = new Property2__C();
        prop.Name = 'Test property';
        insert prop;
        
        Property_Unit__c propU1 = new Property_Unit__c();
        propU1.Name = 'Test Property Unit';
        propU1.Property__c = prop.Id;
        propU1.PropertyUnitId__c ='PU00001';
        insert propU1;
        
        Transaction__c trans = new Transaction__c();
        trans.Name = 'Test Transaction';
        trans.Buyer_Property_Instance__c = prop.id;
        trans.Stage__c = 'Pre-PSA';
        trans.Transaction_Id__c ='Test000000';
        insert trans;         
        
        Inspection__c insp = new Inspection__C();
        insp.Name = 'Test Inspection';
        insp.Inspection_Type__c = 'Diligence';
        insp.Inspection_Status__c = 'Completed';
        insp.Property__c = prop.id;
        insp.Property_Unit__c = propU1.id;
        insp.Transaction__c = trans.id;
        insp.Dilligence_Id__c = '1234';
        insert insp;   
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'Create Contact';
        email.fromAddress = 'someaddress@email.com';
        List<String> toAddressList = new List<String>();
        toAddressList.add('transaction@gmail.com');
        email.toAddresses = toAddressList;
        email.plainTextBody = 'ref:'+trans.Id;
        email.htmlBody = 'ref:'+trans.Id;
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
        TransactionEmailServiceInbound Inbound=new TransactionEmailServiceInbound();
        Inbound.handleInboundEmail(email, env);
        Inbound.forwardEmail(email,'transaction@gmail.com');
        
        
        
        Messaging.InboundEmail email2 = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env2 = new Messaging.InboundEnvelope();
        
          Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
      attachmenttext.body = 'my attachment text';
      attachmenttext.fileName = 'textfiletwo3.txt';
      attachmenttext.mimeTypeSubType = 'texttwo/plain';
      email2.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
        
        email2.subject = 'Create Contact';
        email2.fromAddress = 'transaction@email.com';
        List<String> toAddressList2 = new List<String>();
        toAddressList2.add('transaction@gmail.com');
        email2.toAddresses = toAddressList;
        email2.plainTextBody = trans.Id;
        email2.htmlBody = trans.Id;
        Messaging.InboundEmail.BinaryAttachment attachment2 = new Messaging.InboundEmail.BinaryAttachment();
        attachment2.body = blob.valueOf('my attachment text');
        attachment2.fileName = 'textfileone.txt';
        attachment2.mimeTypeSubType = 'text/plain';
        email2.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
        TransactionEmailServiceInbound Inbound2=new TransactionEmailServiceInbound();
        Inbound2.handleInboundEmail(email2, env);
        Inbound2.forwardEmail(email2,'transaction@gmail.com');
    }
    
}
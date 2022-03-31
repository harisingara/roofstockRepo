@isTest (SeeAllData=true)
private class CreateContactList_CampaignControllerTest {


    public static testMethod void testgetPortfolioStatusNames() {
        List<selectOption> MylistOption = CreateContactList_CampaignController.getPortfolioStatusNames();   
    }
   
    public static testMethod void testgetStatusNames() {
        List<selectOption> MylistOption = CreateContactList_CampaignController.getStatusNames();   
    }
   

public static testMethod void testCamp() {
        
        test.startTest();
        
        Campaign c = new Campaign(Name='MyCampaign');        
        c.Docusign_Template_Id__c = 'myDocuSignTemplate';
        c.Email_Template_Name__c = 'TemplateDefault';
        c.Email_Template_Carbon_Copy__c = 'myemail@gmail.com';
        insert c;

    
        Account acct = new account (Name='MyAcct'); 
        insert acct;
    
         List<CampaignMember> CM_list = new List<CampaignMember>();
        
        Contact con1 = new Contact(FirstName='Joe1', LastName='Smith1', Email='myMail1@gmail.com', AccountId =acct.id );
        Contact con2 = new Contact(FirstName='Joe2', LastName='Smith2', Email='myMail2@gmail.com', AccountId =acct.id );
        
        insert con1;
        insert con2;
    
        CampaignMember cm1= New CampaignMember(CampaignId=c.Id,ContactId=con1.Id,Status='Sent',NDA_Status__c = '' , Portfolio_Status__c = 'In' );
        CampaignMember cm2= New CampaignMember(CampaignId=c.Id,ContactId=con2.Id,Status='Sent',NDA_Status__c = '' , Portfolio_Status__c = 'In');
        CM_list.add(cm1);
        CM_list.add(cm2);
        
        insert cm1;   
        insert cm2;
        
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        
        PageReference pageRef = Page.CreateContactList_Campaign;
        pageRef.getParameters().put('id', String.valueOf(c.Id));
        pageRef.getParameters().put('rowId', String.valueOf(cm1.Id));
        Test.setCurrentPage(pageRef);
        
        
        CreateContactList_CampaignController controller = new CreateContactList_CampaignController(sc);
        
        controller.idTemplate = 'myDocuSignTemplate';
        system.assertEquals('myDocuSignTemplate', controller.idTemplate);
        
        controller.NameTemplate = 'myEmailTemplate';
        system.assertEquals('myEmailTemplate', controller.NameTemplate);
              
         
       
        
        // Test Get and Set

        Pagereference p0 = controller.processSelected();
        
        controller.selectedContacts= new List<CampaignMember>();
        
        Pagereference p6 = controller.sendDocusignButton();
        
        List<CampaignMember> List_empty = controller.getSelectedContacts();
        
        CreateContactList_CampaignController.cContact cCon1 = new CreateContactList_CampaignController.cContact(cm1);
        CreateContactList_CampaignController.cContact cCon2 = new CreateContactList_CampaignController.cContact(cm2);  
        cCon2.selected = true;
        List<CreateContactList_CampaignController.cContact> contactList = new List<CreateContactList_CampaignController.cContact>();
        contactList = controller.getCampaignMembers();
        contactList.add(cCon1);
        contactList.add(cCon2);   
        controller.contactList = contactList;
        
        contactList = controller.getCampaignMembers();
        controller.selectedContacts=CM_list;
        List<CampaignMember> List_not_empty = controller.getSelectedContacts();
        List<CampaignMember> MySelectedContacts= controller.selectedContacts;
        
        
        System.assertEquals(c.Id,controller.selectedContacts[0].CampaignId);
        
        // Test get and set
        
        controller.selected_contacts_msg = 'myMsg';
        string myMsg = controller.selected_contacts_msg;   
        
        controller.value = 14;
        integer myValue = controller.value;
        
        controller.displayBtn_bool = true;
        Boolean myDisplayBtn_bool = controller.displayBtn_bool;
           
        controller.selectedStatus = 'Sent';
        string myStatus = controller.selectedStatus;          
        
        controller.Portfolio_selectedStatus = 'In';
        string My_Portfolio_selectedStatus = controller.Portfolio_selectedStatus;  
    

        controller.TemplateStatusPickvalue = 'Sent';
        string My_TemplateStatusPickvalues = controller.TemplateStatusPickvalue;  
            
        controller.AccountsPickvalue[0] = 'PIMCO';
        string[] My_AccountsPickvalue = controller.AccountsPickvalue;  
    
        controller.accountsPick = new list<selectoption>();
        list<selectoption> My_accountsPick = controller.accountsPick;  
            


    
        Pagereference page0 = controller.openDetailPopup();  
    
                
        CreateContactList_CampaignController.cContact wrapperCon= new CreateContactList_CampaignController.cContact(cm1);
        
        
        // get and set (Bid Part)
        
        controller.showPopup = false;
        boolean showPopup = controller.showPopup; 
        
        controller.showDetailPopup = false;
        boolean showDetailPopup = controller.showDetailPopup;          
        
        controller.ContactName = 'myContactName';
        string ContactName = controller.ContactName; 
        
        controller.BidStage = 'Indicative Bid';
        string BidStage = controller.BidStage;          
        
        controller.BidCapitalization = 'All-Cash';
        string BidCapitalization = controller.BidCapitalization; 
        
        controller.BidCapitalization_Notes = 'myBidCapitalization_Notes';
        string BidCapitalization_Notes = controller.BidCapitalization_Notes;  
        
        controller.BidNotes = 'myBidNotes';
        string BidNotes = controller.BidNotes;         
                   
        controller.BidAmount = 10000;
        Decimal BidAmount = controller.BidAmount; 
        
        controller.BidDeposit = 14;
        Decimal BidDeposit = controller.BidDeposit;  
        
        
        controller.BidDue_Diligence_Period = 3;
        Decimal BidDue_Diligence_Period = controller.BidDue_Diligence_Period; 
        
        controller.BidExterior_Homes_Inspected = 3;
        Decimal BidExterior_Homes_Inspected = controller.BidExterior_Homes_Inspected;  
        
        controller.BidInterior_Homes_Inspected = 2;
        Decimal BidInterior_Homes_Inspected = controller.BidInterior_Homes_Inspected;  
        
        controller.BidBid_Amount_Lower_Bound = 2;
        Integer BidBid_Amount_Lower_Bound = controller.BidBid_Amount_Lower_Bound;      
                
        controller.BidBid_Amount_Upper_Bound = 2;
        Integer BidBid_Amount_Upper_Bound = controller.BidBid_Amount_Upper_Bound;  
                
        controller.BidNum_Homes_Inspected_Unknown = 2;
        Integer BidNum_Homes_Inspected_Unknown = controller.BidNum_Homes_Inspected_Unknown;  
                
        controller.BidNum_Properties = 2;
        Integer BidNum_Properties = controller.BidNum_Properties;  
        
        controller.BidClosingPeriod = 2;
        Integer BidClosingPeriod= controller.BidClosingPeriod;  
        
        
        String getSortDirection = controller.getSortDirection();  
        controller.setSortDirection('ASC');
                
        controller.cmBid = cm1;
        CampaignMember cmBid = controller.cmBid; 
        
        controller.ContactId = con1.Id;
        Id ContactId = controller.ContactId; 
        
        
   
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=con1.id;
        insert attach;
        
        controller.myfile = attach;
        Attachment attachement = controller.getmyfile(); 
        
   
  //      PageReference testPage = Page.CampPage;        
  //      set current page reference
  //      Test.setCurrentPage(testPage);
        
  //      set query parameter
  //      ApexPages.currentPage().getParameters().put('rowId', a.Id);
        
        Test.setCurrentPage(pageRef);
 
        // Test Methods
        
        Pagereference p1 = controller.SaveCampaign();            
        Pagereference p2 = controller.SaveStatus();          
        Pagereference p3 = controller.SavePortfolioStatus();        
        Pagereference p4 = controller.processSelected();          
        Pagereference p5 = controller.sendTemplateButton();        
        //Pagereference p7 = controller.SaveNotes();           
        Pagereference p8 = controller.SaveBid();            
        Pagereference p9 = controller.CancelBid();          
        Pagereference p10 = controller.openDetailPopup();     
        Pagereference p11 = controller.CancelDetailBid();    
        Pagereference p12 = controller.openPopup();      
        Pagereference p13 = controller.openDetailPopup();    
        Pagereference p14 = controller.ViewData();    
        Pagereference p15 = controller.runBatch();    
        controller.ResetFilters(); 
        controller.CustomPopup();
        controller.RefreshPicklists();
            
        
        // Test behaviors
        System.assertEquals(c,controller.camp);
        System.assertEquals( 'myDocuSignTemplate',controller.idTemplate);
        System.assertEquals('TemplateDefault',controller.NameTemplate);
        

        

        test.stopTest();
   }
    
public static testMethod void testSendTemplate() {
    test.startTest();
 
        Campaign c = new Campaign(Name='MyCampaign');        
        c.Docusign_Template_Id__c = 'myDocuSignTemplate';
        c.Email_Template_Name__c = 'TemplateDefault';
        c.Email_Template_Carbon_Copy__c = 'myemail@gmail.com';
        insert c;

       
        Account acct = new account (Name='MyAcct'); 
        insert acct;

    

         List<CampaignMember> CM_list = new List<CampaignMember>();
        
        Contact con1 = new Contact(FirstName='Joe1', LastName='Smith1', Email='myMail1@gmail.com', AccountId =acct.id);
        
        insert con1;
        
        
        CampaignMember cm1= New CampaignMember(CampaignId=c.Id,ContactId=con1.Id,Status='Sent',NDA_Status__c = '' , Portfolio_Status__c = 'In', Template_Sent__c = true);
        CM_list.add(cm1);
        
        
        insert cm1;   
                
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        
        PageReference pageRef = Page.CreateContactList_Campaign;
        pageRef.getParameters().put('id', String.valueOf(c.Id));
        pageRef.getParameters().put('rowId', String.valueOf(cm1.Id));
        Test.setCurrentPage(pageRef);
        
        
        CreateContactList_CampaignController controller = new CreateContactList_CampaignController(sc);
        
        If(Test.isRunningTest()){
           Database.getQueryLocator(
            'SELECT ID FROM Contact LIMIT 190'
             );
          ID jobID = Database.executeBatch(controller, 200);
          System.abortJob(jobID);
        }else{
          Database.executeBatch(controller);
        }
        
    
    test.stopTest();
}

 
public static testMethod void TestsendTemplateEmail(){
    /*
        Id Folder_Id = [SELECT Id From Folder WHERE Type = 'Email' LIMIT 1].Id;
    
        EmailTemplate emailTemplate1 = new EmailTemplate (TemplateType= 'Text', FolderId = Folder_Id, Subject='MySubject',Description='MyDescription',HtmlValue='MyHtmlValuet',DeveloperName='MyDeveloperName',Body='MyBody', Name = 'templateName', IsActive = true);
        insert emailTemplate1;
    
        
        Id ContactId = [SELECT Id From Contact LIMIT 1].Id;    
        String ContactEmail = [SELECT Email From Contact LIMIT 1].Email;
        String ContactFirstName = [SELECT FirstName From Contact LIMIT 1].FirstName;    
        String ContactLastName = [SELECT LastName From Contact LIMIT 1].LastName;
        
        CreateContactList_CampaignController.sendTemplateEmail(ContactId, ContactEmail, 'templateName');
    
    
    
    
            // Generate random Template id
            dfsle.UUID myRandomTemplateId = dfsle.UUID.randomUUID();        
    
            // Create a test envelope with one document and one recipient
            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(ContactId))
                .withDocuments(new List<dfsle.Document> { 
                    dfsle.Document.fromTemplate(
                        myRandomTemplateId,
                        'test template')
                 })
                .withRecipients(new List<dfsle.Recipient> {
                    dfsle.Recipient.fromSource(
                        ContactFirstName + ' ' + ContactLastName,
                        ContactEmail,
                        null,
                        'Signer 1',
                        new dfsle.Entity(ContactId))
                });
    
            string myIdTemplateTest = ''+myRandomTemplateId;   
    
                        
            // Perform the test
            Test.startTest();            
                CreateContactList_CampaignController.sendEnvelopeMethod(ContactId, myIdTemplateTest, 'templateName');
            Test.stopTest();
    */
}

   
   
}
global class CreateContactList_CampaignController implements Database.Batchable<sObject>, database.stateful {


    //////////////////////////////////////////
    //                                      //
    //        Variable Declarations         //
    //                                      //
    //////////////////////////////////////////
    
    public Campaign camp {get;set;}
    private List<CampaignMember> campaignMembers;
    private String sortDirection = 'ASC';
    private String sortExp = 'name';
    Public Attachment myfile;
    
    public class cContact 
    {
        public CampaignMember con {get; set;}
        public Boolean selected {get; set;}
        public cContact(CampaignMember c) 
        {
            con = c;
            selected = false;
        }
    }   
    
    //////////////////////////////////////////
    //                                      //
    //             SOQL Queries             //
    //                                      //
    //////////////////////////////////////////
   
    string myNameTemplate = [SELECT Email_Template_Name__c FROM  Campaign  WHERE  Id =:ApexPages.currentPage().getParameters().get('id') LIMIT 1].Email_Template_Name__c;
    public EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name =: myNameTemplate ];
    String  CCEmail = [SELECT Email_Template_Carbon_Copy__c FROM  Campaign  WHERE  Id =:ApexPages.currentPage().getParameters().get('id') LIMIT 1].Email_Template_Carbon_Copy__c;
    String replyName = [SELECT Owner.Name FROM  Campaign  WHERE  Id =:ApexPages.currentPage().getParameters().get('id') LIMIT 1].Owner.Name;
    String replyEmail = [SELECT Owner.Email FROM  Campaign  WHERE  Id =:ApexPages.currentPage().getParameters().get('id') LIMIT 1].Owner.Email;
    String[] CCList = CCEmail.split(',');    
    
    
    //////////////////////////////////////////
    //                                      //
    //              GET & SET               //
    //                                      //
    //////////////////////////////////////////



    public string selectedStatus {get; set;} 
    public string Portfolio_selectedStatus {get; set;} 
    public boolean showPopup {get;set;}
    public boolean showDetailPopup {get;set;}
    public CampaignMember cmBid {get;set;}
    public Id ContactId {get;set;}
    public String ContactName {get;set;}
    public String CmAccount {get;set;}   
    public String  BidStage {get; set;}
    public Decimal BidAmount {get; set;}
    public Decimal BidDeposit {get; set;}
    public String BidCapitalization {get; set;}
    public String BidCapitalization_Notes {get; set;}
    public Decimal BidDue_Diligence_Period {get; set;}
    public Decimal BidExterior_Homes_Inspected {get; set;}
    public Decimal BidInterior_Homes_Inspected {get; set;}
    public String BidNotes {get; set;}
    public Integer BidClosingPeriod {get; set;}       
    public Integer BidBid_Amount_Lower_Bound {get; set;}
    public Integer BidBid_Amount_Upper_Bound {get; set;}
    public Integer BidNum_Homes_Inspected_Unknown {get; set;}
    public Integer BidNum_Properties {get; set;}        
    public List<cContact> contactList {get; set;}
    public List<CampaignMember> selectedContacts{get;set;}
    public List<Bid__c> relatedBids{get;set;}    
    public Integer value {get;set;}
    public string selected_contacts_msg {get;set;}
    public string bid_number_msg {get;set;}
    public Boolean displayBtn_bool { get; set; }
    public Boolean displayBidTable_bool { get; set; }    
    public string idTemplate { get; set; }
    public string NameTemplate  { get; set; } 
    public string CCTemplate  { get; set; } 
    public string TemplateStatusPickvalue{get; set;}
    public string[] TierPickvalue{get; set;}
    public String[] AccountsPickvalue{get; set;}   
    public string[] portfolioStatusPickvalue{get; set;}
    public string[] NDAStatusPickvalue{get; set;}   
    public string[] BidStatusPickvalue{get; set;}
    
    
    
    public list<selectoption> accountsPick{set;get;}
    public list<selectoption> templateStatusPick{set;get;}
    public list<selectoption> TierPick{set;get;}
    public list<selectoption> portfolioStatusPick{set;get;}
    public list<selectoption> NDAStatusPick{set;get;}
    public list<selectoption> BidStatusPick{set;get;}
    List<CampaignMember> Cm_filters;
    
    
    Public Attachment getmyfile()
    {
        myfile = new Attachment();
        return myfile;
    }
    public List<CampaignMember> getSelectedContacts()
    {
        if(selectedContacts.size()>0) return selectedContacts;
        else return null;
    }      
    
    public List<cContact> getCampaignMembers() 
    {
            if(contactList == null) 
            {
                contactList = new List<cContact>();
                string sortFullExp = sortExpression  + ' ' + sortDirection;    
                
                for(CampaignMember c : [select Id, Name, Email, NDA_Status__c, Portfolio_Status__c,Template_Status__c,Tier__c, CompanyOrAccount, Notes__c, Bid_Status__c, Contact.Id, Account__c from CampaignMember WHERE Campaign.Id = :ApexPages.currentPage().getParameters().get('id') ORDER BY Account__c ASC]) 
                {
                     contactList.add(new cContact(c));
                }
            }
        
        return contactList;
    }
    
    
    //////////////////////////////////////////
    //                                      //
    //              CONSTRUCTOR             //
    //                                      //
    //////////////////////////////////////////  
    
    public CreateContactList_CampaignController (ApexPages.StandardController controller) 
    {   
        camp =  (Campaign) controller.getRecord(); 
        idTemplate   = camp.Docusign_Template_Id__c;
        CCTemplate   = camp.Email_Template_Carbon_Copy__c;   
        NameTemplate = camp.Email_Template_Name__c;
        
        // get pickList values
        
        accountsPick        =   get_Account_picklist();
        templateStatusPick  =   get_Template_status_options();
        TierPick            =   get_Tier_options();
        portfolioStatusPick =   get_Portfolio_status_options();
        NDAStatusPick       =   get_NDA_status_options();
        BidStatusPick       =   get_Bid_status_options();  
        
        
    	AccountsPickvalue = new List<String>();
        AccountsPickvalue.add('All');
    	TierPickvalue = new List<String>();
        TierPickvalue.add('All');
    	portfolioStatusPickvalue = new List<String>();
        portfolioStatusPickvalue.add('All');
    	NDAStatusPickvalue = new List<String>();
        NDAStatusPickvalue.add('All');
    	BidStatusPickvalue = new List<String>();
        BidStatusPickvalue.add('All');
    
    }
    
    
    //////////////////////////////////////////
    //                                      //
    //           PICKLIST METHODS           //
    //                                      //
    ////////////////////////////////////////// 

    
 
        public List<SelectOption> get_Account_picklist()
        {           
            list<selectoption> accountsPickList =  new list<selectoption>();
            accountsPickList.add(new selectoption('All','All'));             
           
            Cm_filters= new List<campaignMember>([select id, Account__c  from CampaignMember WHERE Campaign.Id = :camp.id ORDER BY Account__c ASC]);
            for(campaignMember cm : Cm_filters){           
                accountsPickList.add(new selectoption(cm.Account__c,cm.Account__c));
            }
            Set<selectoption> myset = new Set<selectoption>();
            myset.addAll(accountsPickList);
            accountsPickList =  new list<selectoption>();
            accountsPickList.addAll(myset);
           
          
            return accountsPickList;
        }
    
        public List<SelectOption> get_Portfolio_status_options()
        {   
            // return the possible values of the field : Portfolio_Status__c    +    add 'All' to the list
            
            List<SelectOption> Portfolio_Status_TypeOptionsList = new List<SelectOption>{new SelectOption('All', 'All')};
                Schema.DescribeFieldResult Portfolio_Status_TypeDescription = CampaignMember.Portfolio_Status__c.getDescribe();
            List<Schema.PicklistEntry> Portfolio_Status_TypePicklistValuesList = Portfolio_Status_TypeDescription.getPicklistValues();
            for(Schema.PicklistEntry Portfolio_Status_TypePicklistValue : Portfolio_Status_TypePicklistValuesList){
                Portfolio_Status_TypeOptionsList.add(new SelectOption(Portfolio_Status_TypePicklistValue.getLabel(), Portfolio_Status_TypePicklistValue.getValue()));
            }
            return Portfolio_Status_TypeOptionsList;
        }
    
        public List<SelectOption> get_Template_status_options()
        {
            // return the possible values of the field : Template_Status__c +    add 'All' to the list
            
            List<SelectOption> Template_Status_TypeOptionsList = new List<SelectOption>{new SelectOption('All', 'All')};
                Schema.DescribeFieldResult Template_Status_TypeDescription = CampaignMember.Template_Status__c.getDescribe();
            List<Schema.PicklistEntry> Template_Status_TypePicklistValuesList = Template_Status_TypeDescription.getPicklistValues();
            for(Schema.PicklistEntry Template_Status_TypePicklistValue : Template_Status_TypePicklistValuesList){
                Template_Status_TypeOptionsList.add(new SelectOption(Template_Status_TypePicklistValue.getLabel(), Template_Status_TypePicklistValue.getValue()));
            }
            return Template_Status_TypeOptionsList;
        }
    
        
        public List<SelectOption> get_Tier_options()
        {
            // return the possible values of the field : Tier__c +    add 'All' to the list
            
            List<SelectOption> Tier_TypeOptionsList = new List<SelectOption>{new SelectOption('All', 'All')};
                Schema.DescribeFieldResult Tier_TypeDescription = CampaignMember.Tier__c.getDescribe();
            List<Schema.PicklistEntry> Tier_TypePicklistValuesList = Tier_TypeDescription.getPicklistValues();
            for(Schema.PicklistEntry Tier_TypePicklistValue : Tier_TypePicklistValuesList){
                Tier_TypeOptionsList.add(new SelectOption(Tier_TypePicklistValue.getLabel(), Tier_TypePicklistValue.getValue()));
            }
            return Tier_TypeOptionsList;
        }
    
        public List<SelectOption> get_NDA_status_options()
        {            
            // return the possible values of the field : NDA_Status__c  +    add 'All' to the list
            
            List<SelectOption> NDA_Status_TypeOptionsList = new List<SelectOption>{new SelectOption('All', 'All')};
                Schema.DescribeFieldResult NDA_Status_TypeDescription = CampaignMember.NDA_Status__c.getDescribe();
            List<Schema.PicklistEntry> NDA_Status_TypePicklistValuesList = NDA_Status_TypeDescription.getPicklistValues();
            for(Schema.PicklistEntry NDA_Status_TypePicklistValue : NDA_Status_TypePicklistValuesList){
                NDA_Status_TypeOptionsList.add(new SelectOption(NDA_Status_TypePicklistValue.getLabel(), NDA_Status_TypePicklistValue.getValue()));
            }
            return NDA_Status_TypeOptionsList;
        }

        public List<SelectOption> get_Bid_status_options()
        {            
            // return the possible values of the field : Bid_Status__c  +    add 'All' to the list
            
            List<SelectOption> Bid_Status_TypeOptionsList = new List<SelectOption>{new SelectOption('All', 'All')};
                Schema.DescribeFieldResult Bid_Status_TypeDescription = CampaignMember.Bid_Status__c.getDescribe();
            List<Schema.PicklistEntry> Bid_Status_TypePicklistValuesList = Bid_Status_TypeDescription.getPicklistValues();
            for(Schema.PicklistEntry Bid_Status_TypePicklistValue : Bid_Status_TypePicklistValuesList){
                Bid_Status_TypeOptionsList.add(new SelectOption(Bid_Status_TypePicklistValue.getLabel(), Bid_Status_TypePicklistValue.getValue()));
            }
            return Bid_Status_TypeOptionsList;
        }
        
                public void ResetFilters()
        {        
                   
            AccountsPickvalue = new List<String>();
            AccountsPickvalue.add('All');
            TierPickvalue = new List<String>();
            TierPickvalue.add('All');
            portfolioStatusPickvalue = new List<String>();
            portfolioStatusPickvalue.add('All');
            NDAStatusPickvalue = new List<String>();
            NDAStatusPickvalue.add('All');
            BidStatusPickvalue = new List<String>();
            BidStatusPickvalue.add('All');
           ViewData();
        }


    //////////////////////////////////////////
    //                                      //
    //      CAMPAIGNMEMBERS SELECTION       //
    //                                      //
    ////////////////////////////////////////// 

    public PageReference processSelected() {
        
        // select campaignMembers when the button "select contacts" is pressed
     
       selectedContacts = new List<CampaignMember>();
        
        for(cContact cCon : getCampaignMembers()) {
            if(cCon.selected == true) {
            selectedContacts.add(cCon.con);
            }
        }
        
        value = selectedContacts.size();
        if (value == 0)
        {
            displayBtn_bool = false;
            selected_contacts_msg = 'There is no selected contact';
        }
        else 
        {
            displayBtn_bool  = true;
            selected_contacts_msg = 'Number of selected contacts  :  '+ value ;
        }
        
    return null;
    }
       
     
    //////////////////////////////////////////
    //                                      //
    //          BATCH FUNCTIONS             //
    //                                      //
    ////////////////////////////////////////// 
        
   //START - SET UP LIST OF RECIPIENT
   
    global List<id> CMSuccess = new List<id>();
    global List<CampaignMember> CMFailure =new List<CampaignMember>();
   
    global Database.QueryLocator start(Database.BatchableContext BC)
    {   
        String query = 'select Id, Name, Email from Contact WHERE Id IN (SELECT  ContactId  FROM  CampaignMember WHERE Template_Sent__c =true)';     
        return Database.getQueryLocator(query);
    }
    
    //EXECUTE - SET UP EMAIL
    
    global void execute(Database.BatchableContext BC, List<Contact> scope)
    {   
      if(!scope.isEmpty()){
          
        for(Contact c : scope)
        {   
            CampaignMember currentCM = new CampaignMember();
            
            currentCM = [SELECT id,Template_Status__c FROM CampaignMember WHERE Contact.Id =: c.Id  AND  Campaign.Id = :camp.Id];            
            
            if (System.isBatch() == true) 
            {
                currentCM.Template_Status__c = 'Sent';    
                update currentCM; 
                CMSuccess.add(currentCM.Id);
            }
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { c.Email};
            message.setSenderDisplayName(replyName); 
            message.setReplyTo(replyEmail );
            message.setTargetObjectId(c.id);
            message.setCcAddresses(CCList);
            message.setTemplateID(emailTemplate.id);             
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};   
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);            
        }
          
      }
    }
      
    //FINISH - SEND EMAIL WITH THE BATCH STATUS
    
    global void finish(Database.BatchableContext BC)
    {
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email    from AsyncApexJob where Id =:BC.getJobId()];
      
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {replyEmail};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Match Merge Batch ' + a.Status);        
        mail.setPlainTextBody('Records processed : ' + a.TotalJobItems +   ' (with '+ a.NumberOfErrors + ' failures).');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        System.abortJob(a.Id);
        
     
    }
    
    // Run Batch on Button
    public PageReference runBatch()
    {
        ApexPages.StandardController sc = new ApexPages.StandardController(camp);
        
        List<CampaignMember> allCM = [select Id from CampaignMember WHERE Template_Sent__c =true];
        
        for(CampaignMember cm :  allCM) {
            cm.Template_Sent__c = false;    
        }
        
        for(CampaignMember cm : selectedContacts) 
        {
            cm.Template_Sent__c = true;
            cm.Template_Status__c = 'Sending';
        }
        
        update allCM;
        update selectedContacts;  
          
        Database.executeBatch(new CreateContactList_CampaignController(sc), 1); 
        
        CMFailure = [SELECT Id, Template_Status__c FROM  CampaignMember WHERE Template_Sent__c = true AND Campaign.Id = :camp.Id AND Id not IN : CMSuccess];
          
          for(CampaignMember cfail : CMFailure){
            cfail.Template_Status__c = 'Failed to Send';    
          }
        
        update CMFailure; 
        return null;
        
    }
    
    //////////////////////////////////////////
    //                                      //
    //          SORT FUNCTIONS              //
    //                                      //
    //////////////////////////////////////////
    
    
   public String sortExpression
   {
     get  { return sortExp; }
     set
     {
       //if the column is clicked on then switch between Ascending and Descending modes
       
       if (value == sortExp) sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';         
       else
         sortDirection = 'ASC';
         sortExp = value;
     }
   }

    public String getSortDirection()
     {
        //if not column is selected
        if (sortExpression == null || sortExpression == '')
          return 'ASC';
        else
         return sortDirection;
     }

     public void setSortDirection(String value)
     {  
       sortDirection = value;
     }
     public void RefreshPicklists() 
   {   
       if(is_All_in_tab(AccountsPickvalue)){
           AccountsPickvalue = getPicklistValues(accountsPick);
       }
       
   }

   public PageReference ViewData() 
   {    
       // Transforme each array into a string
              
      string sortFullExp = sortExpression  + ' ' + sortDirection;      

    string condition1 = '( Account__c IN : AccountsPickvalue ) AND ';
    string condition2 = '( Tier__c IN : TierPickvalue ) AND ';       
    string condition3 = '( Portfolio_Status__c IN : portfolioStatusPickvalue ) AND ';
    string condition4 = '( NDA_Status__c IN : NDAStatusPickvalue ) AND ';       
    string condition5 = '( Bid_Status__c IN : BidStatusPickvalue ) AND '; 

       
       
       if(is_All_in_tab(AccountsPickvalue)){condition1 = '';}
       if(is_All_in_tab(TierPickvalue)){condition2 = '';}
       if(is_All_in_tab(portfolioStatusPickvalue)){condition3 = '';}
       if(is_All_in_tab(NDAStatusPickvalue)){condition4 = '';}
       if(is_All_in_tab(BidStatusPickvalue)){condition5 = '';}

        
    campaignMembers = Database.query('select Id, Name, Email, NDA_Status__c, Portfolio_Status__c,Template_Status__c,Tier__c, CompanyOrAccount, Notes__c, Bid_Status__c, Contact.Id, Account__c from CampaignMember WHERE '+ condition1 + condition2 + condition3 + condition4 + condition5 + '(Campaign.Id =\'' + camp.id + '\') ORDER BY ' + sortFullExp + ' limit 1000');
       

        contactList = new List<cContact>();

        for(CampaignMember c : campaignMembers ) 
        {
            contactList.add(new cContact(c));
        }
       
       return null;
   }

    //////////////////////////////////////////
    //                                      //
    //        POP UP - BID CREATION         //
    //                                      //
    //////////////////////////////////////////

    public void CustomPopup ()
    {
        showPopup = false;
    }

    public PageReference openPopup()
    {        
        String myId = System.currentPageReference().getParameters().get('rowId');    
        
        cmBid        = [SELECT Id,Account__c    FROM CampaignMember WHERE Id = :myId];
        ContactId    = [SELECT Id, Contact.Id   FROM CampaignMember WHERE Id = :myId].Contact.Id;
        ContactName  = [SELECT Id, Contact.Name FROM CampaignMember WHERE Id = :myId].Contact.Name; 
        
        showPopup = true;
        return null;
    }
    

    public PageReference SaveBid()

    {   
        // variable declarations
    
        Bid__c NewBid = New Bid__c();
        NewBid.Campaign__c                    = camp.Id;
        NewBid.Contact__c                     = ContactId;
        NewBid.Stage__c                       = BidStage;
        NewBid.Amount__c                      = BidAmount;
        NewBid.Deposit__c                     = BidDeposit;
        NewBid.Capitalization__c              = BidCapitalization;
        NewBid.Capitalization_Notes__c        = BidCapitalization_Notes;
        NewBid.Due_Diligence_Period__c        = BidDue_Diligence_Period;
        NewBid.Exterior_Homes_Inspected__c    = BidExterior_Homes_Inspected;
        NewBid.Interior_Homes_Inspected__c    = BidInterior_Homes_Inspected;
        NewBid.Notes__c                       = BidNotes;
        NewBid.Closing_Period_Days__c         = BidClosingPeriod;    
        NewBid.Bid_Amount_Lower_Bound__c      = BidBid_Amount_Lower_Bound;
        NewBid.Bid_Amount_Upper_Bound__c      = BidBid_Amount_Upper_Bound;
        NewBid.Num_Homes_Inspected_Unknown__c = BidNum_Homes_Inspected_Unknown;    
        NewBid.Num_Properties__c              = BidNum_Properties;    
        
        // formatting variables
        
        if (BidDeposit==0){NewBid.Deposit__c= null; }
        if (BidDue_Diligence_Period==0){NewBid.Due_Diligence_Period__c = null; }
        if (BidBid_Amount_Lower_Bound==0){NewBid.Bid_Amount_Lower_Bound__c = null;}
        if (BidBid_Amount_Upper_Bound==0){NewBid.Bid_Amount_Upper_Bound__c  = null;}
        if (BidNum_Properties==0){NewBid.Num_Properties__c= null;}
        if (BidClosingPeriod==0){NewBid.Closing_Period_Days__c = null;}    
        if (BidExterior_Homes_Inspected==0){NewBid.Exterior_Homes_Inspected__c  = null;}
        if (BidInterior_Homes_Inspected==0){NewBid.Interior_Homes_Inspected__c  = null;}
        if (BidNum_Homes_Inspected_Unknown==0){NewBid.Num_Homes_Inspected_Unknown__c = null;}    
        
        insert NewBid;
        
        try
        {
            Attachment a = new Attachment(parentId = NewBid.Id, name=myfile.name, body = myfile.body);
            insert a;
        }
        catch (Exception e){}
        
        //update cm bid status   
        
        cmBid.Bid_Status__c = BidStage + ' Submitted';  
        update cmBid;                  
       
        for(CampaignMember c : [select Id, Bid_Status__c, Contact.Id, Account__c from CampaignMember WHERE Account__c  =: cmBid.Account__c AND Campaign.Id = :ApexPages.currentPage().getParameters().get('id')]) 
        {
           c.Bid_Status__c = BidStage + ' Submitted';
           update c;  
        }        
        
        showPopup = false;
        PageReference tempPage = ApexPages.currentPage();            
        tempPage.setRedirect(true);
        
        return tempPage;
    }

    public PageReference CancelBid()
    {
        showPopup = false;
        return null;
    }

    //////////////////////////////////////////
    //                                      //
    //      POP UP - BID CONSULTATION       //
    //                                      //
    //////////////////////////////////////////


    public PageReference openDetailPopup()
    {        
        String myId = System.currentPageReference().getParameters().get('rowId');
        relatedBids = new List<Bid__c>();  
        ContactId    = [SELECT Id, Contact.Id FROM CampaignMember WHERE Id = :myId].Contact.Id;    
        ContactName  = [SELECT Id, Contact.Name FROM CampaignMember WHERE Id = :myId].Contact.Name; 
        CmAccount    = [SELECT Id, Account__c FROM CampaignMember WHERE Id = :myId].Account__c ;          
        relatedBids  = [select Id, Name, Amount__c, Deposit__c,Capitalization__c, Stage__c, Contact__r.Name, CreatedDate from Bid__c WHERE (Campaign__r.Id = :camp.Id)  AND (Account_Asher_Formula__c = :CmAccount ) ORDER BY CreatedDate DESC ];
        
        if(relatedBids.size()==0)
        { 
            displayBidTable_bool  = false;
            bid_number_msg  = 'There is no bid recorded on this contact';
        }
        else 
        {
            displayBidTable_bool = true;
            bid_number_msg = 'Number of Bids  :  '+ relatedBids.size();
        }
        
        showDetailPopup = true;   
        return null;
    }
        
    public PageReference CancelDetailBid()
    {
        showDetailPopup = false;
        return null;
    }    


    public  Pagereference SaveCampaign()
    {
      update camp ;
      return null;
    }
   

    //////////////////////////////////////////
    //                                      //
    //          SAVE STATUS & NOTES         //
    //                                      //
    //////////////////////////////////////////

    public static List<selectOption> getStatusNames() 
    {    
        List<selectOption> options = new List<selectOption>();
        List<String> pickListValuesList= new List<String>();
    
        Schema.DescribeFieldResult fieldResult = CampaignMember.NDA_Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple)
        {
            pickListValuesList.add(pickListVal.getLabel());
            options.add(new selectOption(pickListVal.getLabel(),pickListVal.getLabel()));
        }              
        return options;        
    }
    
    public Pagereference SaveStatus()
    {
        if (selectedContacts.size() != 0)
        {
            for(CampaignMember cm : selectedContacts)
            {
                cm.NDA_Status__c = selectedStatus;
            }
        
            update selectedContacts;
        }        
        return null;
    }
    
    public Pagereference SaveNotes()
    {   
        List<CampaignMember> allContacts = new List<CampaignMember>();
        for(cContact cCon : getCampaignMembers()) {
            allContacts.add(cCon.con);
            //update cCon.con;
        }
      update allContacts;
      return null;
    }
    
    public static List<selectOption> getPortfolioStatusNames() 
    {
        List<selectOption> Portfolio_options = new List<selectOption>();
        List<String> pickListValuesList= new List<String>();
    
        Schema.DescribeFieldResult fieldResult = CampaignMember.Portfolio_Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple)
        {
            pickListValuesList.add(pickListVal.getLabel());
            Portfolio_options.add(new selectOption(pickListVal.getLabel(),pickListVal.getLabel()));
        }    
        return Portfolio_options;
    }
    
    public Pagereference SavePortfolioStatus()
    {
        for(CampaignMember cm : selectedContacts)
        {
            cm.Portfolio_Status__c = Portfolio_selectedStatus;
        }    
      update selectedContacts;
      return null;
    }
    
        
    
    //////////////////////////////////////////
    //                                      //
    //          Utility FUNCTIONS          //
    //                                      //
    //////////////////////////////////////////  
       
    public boolean is_All_in_tab(string[] str_tab){
        boolean result = false;
        if(str_tab.size() != 0){
             for (string s: str_tab ){
                if(s == 'All'){
                    result=true;
             	}
        	}            
    	} 
     return result;   
    }
    
    
    public static List<String> getPicklistValues(List<SelectOption> selectOptions){ 
        List<String> stringValues = new List<String>();
        for(SelectOption so: selectOptions){
            stringValues.add(so.getValue());
        }    
      return stringValues;
    } 
    
    
    
    
 
    
    
    
    //////////////////////////////////////////
    //                                      //
    //          OBSOLETE CODE               //
    //                                      //
    //////////////////////////////////////////
    
    
    //////////////////////////////////////////
    //                                      //
    //      TEMPLATE EMAIL FUNCTIONS        //
    //                                      //
    //////////////////////////////////////////  

    public List<Messaging.Email> getTemplateEmail(Id idContact, string email, string templateCC, string replyName, string replyEmail, EmailTemplate emailTemplate, Messaging.Email[] messages   ){
        
       Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();
       message.setTargetObjectId(idContact); 
       message.setSenderDisplayName(replyName ); 
       message.setReplyTo(replyEmail );
       message.setUseSignature(false); 
       message.setBccSender(false); 
       String[] CCEmails = templateCC.split(',');
       message.setCcAddresses(CCEmails);
       message.setSaveAsActivity(true);
       message.setTemplateID(emailTemplate.Id); 
       message.toAddresses = new String[] {email};   
       messages.add(message);       
       return messages;
    
    }

    public PageReference sendTemplateButton() 
    {
        List<Contact> contacts = [select Id, Name, Email from Contact WHERE Id IN (SELECT  ContactId  FROM  CampaignMember WHERE Id IN: selectedContacts)];
        NameTemplate = [SELECT Email_Template_Name__c FROM  Campaign  WHERE  Id =:ApexPages.currentPage().getParameters().get('id') LIMIT 1].Email_Template_Name__c;
        CCTemplate = [SELECT Email_Template_Carbon_Copy__c FROM  Campaign  WHERE  Id =:ApexPages.currentPage().getParameters().get('id') LIMIT 1].Email_Template_Carbon_Copy__c ;
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name =: NameTemplate ];        
        String replyName = [SELECT Owner.Name FROM  Campaign  WHERE  Id =:ApexPages.currentPage().getParameters().get('id') LIMIT 1].Owner.Name;
        String replyEmail = [SELECT Owner.Email FROM  Campaign  WHERE  Id =:ApexPages.currentPage().getParameters().get('id') LIMIT 1].Owner.Email;
        
        Messaging.Email[] messages = new Messaging.Email[0];        
        
        for (Contact c: contacts )
        {   
             try 
              {
                  messages = getTemplateEmail(c.Id, c.email, CCTemplate, replyName, replyEmail, emailTemplate, messages  ); 
              }
             catch (Exception e)
              {
                  system.debug(e);
              }        
        }        
        
            try 
             {
                  Messaging.SendEmailResult[] results = Messaging.sendEmail(messages, false);             
             }
            catch (Exception e)
             {
                  system.debug(e);
             }       
        
        for(CampaignMember cm : selectedContacts)
        {
            cm.Template_Status__c = 'Sent';
        }
    
       update selectedContacts;       
       return null;
    }

    //////////////////////////////////////////
    //                                      //
    //          DOCUSIGN FUNCTIONS          //
    //                                      //
    //////////////////////////////////////////  
       
    @future(callout=true)
    public static void sendEnvelopeMethod(Id idContact, string templateId, string templateName) 
    {
        Id mySourceId = idContact; 
        dfsle.Recipient myRecipient ;
        dfsle.UUID myTemplateId = dfsle.UUID.parse(templateId);
        dfsle.Document myDocument;
        dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(mySourceId));
         
        Contact c= [SELECT Id, Name, Email FROM  Contact WHERE  Id =: idContact] ;
         myRecipient = dfsle.Recipient.fromSource(
                c.Name,                     // Recipient name
                c.Email,                    // Recipient email
                null,                       // Optional phone number
                'Signer 1',                 // Role Name. Specify the exact role name from template
                new dfsle.Entity(c.Id));    // Source object for the Recipient
        
        // create Enveloppe and Document 
         
         myEnvelope = myEnvelope.withRecipients(new List<dfsle.Recipient> { myRecipient });
         myDocument = dfsle.Document.fromTemplate(myTemplateId, templateName); 
         myEnvelope = myEnvelope.withDocuments(new List<dfsle.Document> { myDocument });      
                     
         // Send envelope   
          
        try 
        {         
            myEnvelope = dfsle.EnvelopeService.sendEnvelope(myEnvelope,true); // True : Send now       
        }  
        catch (Exception e) {}
    }
    
    public PageReference sendDocusignButton() 
    {    
        List<Contact> contacts = [select Id, Name, Email from Contact WHERE Id IN (SELECT  ContactId  FROM  CampaignMember WHERE Id IN: selectedContacts)];
        idTemplate = [SELECT Docusign_Template_Id__c FROM  Campaign  WHERE  Id =:ApexPages.currentPage().getParameters().get('id') LIMIT 1].Docusign_Template_Id__c;
    
        for (Contact c: contacts )
        {
            try {sendEnvelopeMethod(c.Id, idTemplate, 'NDA_Template');}
            catch (Exception e) {}
        }
        
        for(CampaignMember cm : selectedContacts)
        {
            cm.NDA_Status__c = 'Sent';
        }
    
        update selectedContacts;
        
       PageReference pageRef = new PageReference('/'+ ApexPages.currentPage().getParameters().get('id'));
       pageRef.setRedirect(true);
       return pageRef ;
    }
    

    
    
    

    
}
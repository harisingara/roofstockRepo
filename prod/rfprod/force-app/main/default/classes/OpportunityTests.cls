@isTest
public class OpportunityTests {
    
    private static Id retailBuyerLeadRTId ;
    private static Id retailSellerLeadRTId;
    private static Id instSellerLeadRTId;
    private static Id instBuyerLeadRTId;
    
    private static final string userAlias = 'RSUSER1';  
    private static final string RB_RT ='Retail Buyer';
    private statIC final string RS_RT='Retail Seller'; 
    private statIC final string IB_RT='Institutional Buyer'; 
    private statIC final string IS_RT='Institutional Seller'; 
    
    //static initialization code (load test data) 
    static {
        //create test users
        TestDataFactory.createTestUserRecords(2);
        //load record type info
        retailBuyerLeadRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(RB_RT).getRecordTypeId();
        retailSellerLeadRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(RS_RT).getRecordTypeId();
        instSellerLeadRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(IS_RT).getRecordTypeId();
        instBuyerLeadRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(IB_RT).getRecordTypeId();
        TestDataFactory.insertHierarchyCustomSettingData();
        TestDataFactory.createTestRetailBuyerOpportunityRecords(10);
        TestDataFactory.createTestRentalListingRecords(10);
        TestDataFactory.createTestLeasingOpportunityRecords(10);
        
        
    }
    
    static testMethod void processLeasingOpps(){
        Test.startTest();
        TestDataFactory.insertHierarchyCustomSettingData();
        
        Id leasingPropertyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
        
        
        Account acc = new Account();
        acc.Name ='SFDC';
        insert acc;
        
        Opportunity oppt = new Opportunity();
        oppt.Name = 'Opty';
        oppt.AccountId = acc.Id;  //attach opp to above test account
        oppt.StageName = 'Qualified Listing';
        oppt.Property_Street__c = 'Fake Street Address';  //opp name is generate from adress for retail seller!
        oppt.CloseDate = Date.today();
        oppt.Application_Status__c = 'Prospect';
        //opp.CampaignId = camp.Id;
        oppt.RecordTypeId = leasingPropertyRecordTypeId;
        insert oppt;
        
        List <Opportunity> oppList = [Select Id, RecordType.Name from Opportunity where RecordType.Name =: 'Leasing'];
        System.debug('NDEBUG Opp Size' + oppList.size());
        System.debug('NDEBUG Record Type Name' + oppList[0].RecordType.Name);
        oppList[0].Application_Status__c = 'Applied';
        update oppList[0];
        oppList[0].App_Decision__c = 'Pending';
        oppList[0].Application_Status__c = 'Applied';
        update oppList[0];
        
        OpportunityHelper.getStageValue('', 'Prospect','');
        OpportunityHelper.getStageValue('', 'Applied','');
        OpportunityHelper.getStageValue('Pending', 'Applied','');
        OpportunityHelper.getStageValue('Conditional', 'Applied','');
        OpportunityHelper.getStageValue('Accepted', 'Applied','');
        OpportunityHelper.getStageValue('Denied', 'Applied','');
        OpportunityHelper.getStageValue('', 'Approved','');
        OpportunityHelper.getStageValue('','Denied','');
        OpportunityHelper.getStageValue('','Cancelled','');
        OpportunityHelper.getStageValue('','Resident','Future');
        OpportunityHelper.getStageValue('','Resident','Current');
        
        OpportunityHelper.getSubStageValue('Pending', 'Applied','');
        OpportunityHelper.getSubStageValue('Conditional', 'Applied','');
        OpportunityHelper.getSubStageValue('Accepted', 'Applied','');
        
        OpportunityHelper.getSubStageValue('Denied', 'Applied','');
        OpportunityHelper.getSubStageValue('', 'Approved','');
        OpportunityHelper.getSubStageValue('','Denied','');
        OpportunityHelper.getSubStageValue('','Cancelled','');
        
        Test.stopTest();
        
    }
    
    static testMethod void roundRobinTest() {
        User u1 = [SELECT Id, profile.name, ProfileId  FROM User WHERE Profile.Name = 'System Administrator' and isActive = true LIMIT 1];
        
        
        u1.Assignment_Group_Active__c = true;
        update u1;
        
        User u = new User(LastName = 'User');
        	u.FirstName = 'Integration';
            u.ProfileId = u1.ProfileId;
            u.Alias = 'integ' + '1';
            u.Username = 'integ' + '@roofstock.com';
            u.email = 'integ' + '@roofstock.com';
            u.CommunityNickname = 'integ';
            u.TimeZoneSidKey = 'America/New_York';
            u.LocaleSidKey = 'en_US';
            u.EmailEncodingKey = 'UTF-8';
            u.LanguageLocaleKey = 'en_US';
        Insert u;
            
            
        
        Property2__c properties = new Property2__c(
            Leasing_Market__c = 'Atlanta',
            PropertyCode__c = 'q1000',
            PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead',
            Property_Type__c = 'Single Family',
            Year_Built__c = '1972',
            name = '123 Main St Tracy CA 95391'
        );
        insert properties;
        
        Property_Unit__c units = new Property_Unit__c(
            name = '123 Main St Tracy CA 95391',
            Property__c = properties.id,
            Bathrooms__c = 3,
            Bedrooms__c = 2.5,
            HomeCode__c = 'q20000'
        );
        insert units;
        
        Rental_Listing__c rl = new Rental_Listing__c(
            name = '123 Main St Tracy CA 95391',
            Property_Unit__c = units.id,
            Rental_Listing_Id__c = '21978',
            Current_Rent__c = 1200,
            Status__c = 'Unspecified'
        );
        insert rl;
        
        List<Account> accts = new List<Account>();
        Account a = new Account(Name = 'Primary Applicant');
        accts.add(a);
        a = new Account(Name = 'Secondary Applicant');
        accts.add(a);
        insert accts;
        
        List <Contact> cons = new List <Contact> ();
        
        cons.add(new Contact(
                firstname = 'Primary',
                lastname = 'Applicant',
                email= 'pri@nowhere.com',                        
                AccountId = accts[0].Id));
        cons.add(new Contact(
                firstname = 'Secondary',
                lastname = 'Applicant',
                email= 'sec@nowhere.com',                        
                AccountId = accts[1].Id));
        insert cons;
        
        Opportunity o = new Opportunity();
        o.Name = 'Primary App Opp';
        o.StageName = 'New';
        o.closeDate= System.today();
        o.Relationship__c = 'Self';
        o.RecordTypeId = RecordTypes.leasingOpportunityRecordTypeId;
        o.AccountId=accts[0].Id;
        o.Yardi_Primary_Prospect_Id__c = '0';
        o.Yardi_Prospect_Id__c = '174406';
        o.Rental_Listing__c = rl.Id;
        o.Application_Status__c = '';
        o.Primary_Leasing_Contact__c = cons[0].Id;
        Insert o;
        
        Opportunity o1 = new Opportunity();
        o1.Name = 'Secondary App Opp';
        o1.StageName = 'New';
        o1.closeDate= System.today();
        o1.Relationship__c = 'Spuse';
        o1.RecordTypeId = RecordTypes.leasingSecApplOppRecordTypeId;
        o1.AccountId=accts[1].Id;
        o1.Yardi_Primary_Prospect_Id__c = '174406';
        o1.Yardi_Prospect_Id__c = '174407';
        o1.Rental_Listing__c = rl.Id;
        o1.Application_Status__c = '';
        o1.Primary_Leasing_Contact__c = cons[0].Id;
        Insert o1;
        
        Group testGroup = new Group ();
        testGroup.Name = 'LC Team';
        testGroup.Type = 'Queue';
        insert testGroup;
        
        //Create Assignment Group
        Assignment_Group_Name__c ag1 = new Assignment_Group_Name__c (Name = 'LC_Team',
                                                                     Type__c = 'Opportunity');
        insert ag1;  
        
        //Add Good Queue to Assignment Group
        Assignment_Group_Queues__c agq1 = new Assignment_Group_Queues__c(Name = testGroup.Name,
                                                                         Assignment_Group_Name__c = ag1.id );
        insert agq1;
        
        //Add User to Assignment Groups Users
        Assignment_Groups__c agu1 = new Assignment_Groups__c (User__c = u1.id,
                                                              Active__c = 'True',
                                                              Group_Name__c = ag1.id,
                                                              Last_Assignment__c = datetime.valueOf('2009-01-01 21:13:24') );
        insert agu1;
        
        
        System.runAs(u) {
            Test.startTest();
            
            List<Opportunity> OppList = [SELECT Id FROM Opportunity WHERE Relationship__c = 'Self' LIMIT 1];
            OpportunityRoundRobin.roundRobin(OppList);
            Test.stopTest();
            
        }
    }
    
    static testMethod void ValidatePropertyColumnsArefilledInContractStageForRetailSellers() {
        
        User u1 = [SELECT Id FROM User WHERE Alias=:userAlias];
        
        System.RunAs(u1){
            Opportunity opp = InitOpportunity(retailSellerLeadRTId);
            opp.StageName = 'Published';
            try{
                Test.startTest();
                Insert opp;
                Test.stopTest(); 
            }
            catch(Exception e)
            {
                System.debug('err' + e.getMessage());
                Boolean expectedExceptionThrown =  e.getMessage().contains('Missing values') ? true : false;
                //System.AssertEquals(expectedExceptionThrown, true);
            } 
            
        }
    }
    static testMethod void updateCampaignOnOpportunityTests() {
        Opportunity opp1 = InitOpportunity(retailSellerLeadRTId) ;
        Campaign oCampaign = new Campaign(Name = 'test');
        insert oCampaign; 
        opp1.CampaignId = oCampaign.Id; 
        Test.startTest();
        insert opp1; 
        Opportunity opp2 = InitOpportunity(retailSellerLeadRTId) ; 
        opp2.AccountId = opp1.AccountId; 
        Test.stopTest();
        insert opp2;
    }
    static Opportunity InitOpportunity(Id recordTypeId) {
        //create account and contact  
        TestDataFactory.createTestRecords(1,1);
        
        //pull one account from above test data
        Account acc = [select id from account limit 1];  
        // String leasingRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;  //attach opp to above test account
        opp.StageName = 'Qualified Listing';
        opp.Property_Street__c = 'Fake Street Address';  //opp name is generate from adress for retail seller!
        opp.CloseDate = Date.today();
        
        opp.RecordTypeId = recordTypeId;
        
        return opp;
        
    }
    /* static testMethod void runTest() {
OpportunityHelper.inflateTest();
}
*/
    /*  
static testMethod void UpdateRetailBuyerClosedWon() { 
Id retailBuyerRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
Opportunity opp = [select Id from Opportunity where RecordTypeId =:retailBuyerRecTypeId limit 1];
//opp.stageName='Closed Won';
//update Opp;
List<Opportunity> opList =new List<Opportunity>();
opList.add(Opp);
// OpportunityHelper.RetailBuyerClosedWonOptyCallout(opList);

}
*/
    /*  static testMethod void updateORU() { 
Opportunity opp = [select Id from Opportunity limit 1];
opp.stageName='Closed Lost';    
update Opp;
}
*/
    static testMethod void ListingMarketAndYieldFuture() { 
        Id leasingPropertyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
        Leasing_Markets__c lm = new Leasing_Markets__c();
        lm.Agent_Email__c ='TestUser1@roofstock.com';
        lm.Manager_Email__c = 'TestUser1@roofstock.com';
        lm.Name='LeaseMarkets';
        insert lm;
        
        Account acc = new Account();
        acc.Name ='SFDC';
        insert acc;
        
        Opportunity oppt = new Opportunity();
        oppt.Name = 'Opty';
        oppt.AccountId = acc.Id;  //attach opp to above test account
        oppt.StageName = 'Qualified Listing';
        oppt.Property_Street__c = 'Fake Street Address';  //opp name is generate from adress for retail seller!
        oppt.CloseDate = Date.today();
        //opp.CampaignId = camp.Id;
        oppt.RecordTypeId = leasingPropertyRecordTypeId;
        insert oppt;
        
        Opportunity opp = [select Id from Opportunity where Id=:oppt.Id];
        //opp.stageName='Closed Lost';
        //opp.Listing_Market__c = 'marketzipInfo';
        update Opp;
        
        Set<Id> oppIdSet = new Set<Id>();
        oppIdSet.add(opp.Id);
        Test.startTest();
        OpportunityHelper.UpdateListingMarketAndYieldFuture(oppIdSet);
        Test.stopTest();
    }
    
    static testMethod void updateCampaignOnOpportunity() {
        Account acc = new Account();
        acc.name = 'SFDC';
        insert acc;
        
        String retailSellerRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        Campaign camp = new Campaign(Name = 'Test Campaign 1', IsActive = True);
        insert camp;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;  //attach opp to above test account
        opp.StageName = 'Qualified Listing';
        opp.Property_Street__c = 'Fake Street Address';  //opp name is generate from adress for retail seller!
        opp.CloseDate = Date.today();
        //opp.CampaignId = camp.Id;
        opp.RecordTypeId = retailSellerRecordType;
        insert opp;
        
        List<Opportunity> opList = new List<Opportunity>();
        opList.add(opp);
        OpportunityHelper.updateCampaignOnOpportunity(opList);
    }
    
    static testMethod void UpdateLeasingOpportunityOwnerByMarket(){
        Id leasingPropertyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
        Leasing_Markets__c lm = new Leasing_Markets__c();
        lm.Agent_Email__c ='TestUser1@roofstock.com';
        lm.Manager_Email__c = 'TestUser1@roofstock.com';
        lm.Name='LeaseMarkets';
        insert lm;
        
        Account acc = new Account();
        acc.Name ='SFDC';
        insert acc;
        
        Opportunity oppt = new Opportunity();
        oppt.Name = 'Opty';
        oppt.AccountId = acc.Id;  //attach opp to above test account
        oppt.StageName = 'Qualified Listing';
        oppt.Property_Street__c = 'Fake Street Address';  //opp name is generate from adress for retail seller!
        oppt.CloseDate = Date.today();
        //opp.CampaignId = camp.Id;
        oppt.RecordTypeId = leasingPropertyRecordTypeId;
        insert oppt;
        
        Opportunity opp = [select Id,RecordTypeId,AccountId,StageName,Primary_Leasing_Contact__c from Opportunity where Id=:oppt.Id];
        //opp.stageName='Closed Lost';
        //opp.Listing_Market__c = 'marketzipInfo';
        update Opp;
        List<Opportunity> opList = new List<Opportunity>();
        Map<Id,Opportunity> opMap = new Map<Id,Opportunity>();
        opMap.put(Opp.Id,Opp);
        opList.add(opp);
        Set<Id> oppIdSet = new Set<Id>();
        oppIdSet.add(opp.Id);
        Test.startTest();
        //OpportunityHelper.UpdateLeasingOpportunityOwnerByMarket(opMap,opList);
        Test.stopTest();
    }
    static testMethod void UpdateListingMarketAndYield(){
        Id reatilSellerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        
        insert new API_Endpoints__c(Name='Roofstock_api', Url__c = 'https://qa.roofstock.com');
        
        Account acc = new Account();
        acc.Name = 'SFDC';
        insert acc;
        MarketYield__c MY= new MarketYield__c();
        MY.Name = 'SFDC';
        MY.Minimum_Gross_Yield__c = 1000;
        insert MY;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Opportunity opp = new Opportunity();
        opp.Name = 'SFDC';
        opp.Property_Zip_Code__c = '30301';
        opp.StageName = 'Qualified Listing';
        opp.CloseDate = Date.today();
        opp.Listing_Market__c = 'SFDC';
        opp.Current_Rent__c = 1000;
        opp.RecordTypeId = reatilSellerRecordTypeId;
        insert opp;
        
        Set<Id> opSet = new Set<Id>();
        opSet.add(opp.Id);
        // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        OpportunityHelper.UpdateListingMarketAndYield(opSet);
        
    }
    static testMethod void retailSellerOpportunities(){
        Account acc = new Account();
        acc.Name = 'NextStepAccount';
        acc.Next_Step_Date__c = System.today();
        acc.Appointment_Date__c = System.today();
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'SFDC';
        opp.StageName = 'Qualified Listing';
        opp.CloseDate = Date.today();
        opp.Listing_Market__c = 'SFDC';
        opp.Current_Rent__c = 1000;
        opp.AccountId = acc.Id;
        insert opp;
        
        Map<String,Date> accIdNextStepDateMap = new Map<String,Date>();
        Map<String,Date> accIdAppointmentDateMap = new Map<String,Date>();
        
        accIdNextStepDateMap.put(acc.Id,acc.Next_Step_Date__c);
        accIdAppointmentDateMap.put(acc.Id,acc.Appointment_Date__c);
        OpportunityHelper.retailSellerOpportunities(accIdNextStepDateMap,accIdAppointmentDateMap);
    }
    
    static testMethod void leasingOpportunityUpdateORU(){
        Id oppLeasingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'NextStepAccount';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'SFDC';
        opp.StageName = 'Closed Lost';
        opp.CloseDate = Date.today();
        opp.Listing_Market__c = 'SFDC';
        opp.Current_Rent__c = 1000;
        opp.AccountId = acc.Id;
        opp.RecordTypeId = oppLeasingRecordTypeId;
        opp.Reason_for_Close__c = 'Approved- No Lease Sign';
        insert opp;
        
        OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c();
        oru.Opportunity__c = opp.Id;
        oru.Status__c = 'Approved';
        insert oru;
        
        List<Opportunity> opList = new List<Opportunity>();
        opList.add(opp);
        OpportunityHelper.leasingOpportunityUpdateORU(opList);
    }
    
    static testMethod void updateRetailBuyerOpportunityStages(){
        //String retailBuyerRecTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        RecordType rt = [select id,Name from RecordType where SobjectType='Opportunity' and Name='Retail Buyer' Limit 1];
        System.debug('=rt='+rt);
        Account acc = new Account();
        acc.Name = 'NextStepAccount';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'SFDC';
        opp.StageName = 'Qualified Listing';
        opp.CloseDate = Date.today();
        opp.Listing_Market__c = 'SFDC';
        opp.Current_Rent__c = 1000;
        opp.AccountId = acc.Id;
        opp.Buy_Box_Complete_Date__c = null;
        opp.RecordTypeId = rt.Id;
        insert opp;
        
        Opportunity updateOp = [select Id,Buy_Box_Complete_Date__c,RecordTypeId from Opportunity where Id=:opp.Id];
        updateOp.Buy_Box_Complete_Date__c = System.today();
        updateOp.RecordTypeId = rt.Id;
        update updateOp;
        
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        List<Opportunity> opList = new List<Opportunity>();
        oppMap.put(updateOp.Id,updateOp);
        opList.add(updateOp);
        oppMap.put(opp.Id,opp);
        OpportunityHelper.updateRetailBuyerOpportunityStages(opList,oppMap);
    }
    
    static testMethod void updateRetailBuyerOpportunityStagespreApproved(){
        //String retailBuyerRecTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        RecordType rt = [select id,Name from RecordType where SobjectType='Opportunity' and Name='Retail Buyer' Limit 1];
        System.debug('=rt='+rt);
        Account acc = new Account();
        acc.Name = 'NextStepAccount';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'SFDC';
        opp.StageName = 'Qualified Listing';
        opp.CloseDate = Date.today();
        opp.Listing_Market__c = 'SFDC';
        opp.Current_Rent__c = 1000;
        opp.AccountId = acc.Id;
        opp.Buy_Box_Complete_Date__c = System.today();
        opp.Pre_Approved_Complete_Date__c = null;
        opp.RecordTypeId = rt.Id;
        insert opp;
        
        Opportunity updateOp = [select Id,Buy_Box_Complete_Date__c,Pre_Approved_Complete_Date__c,RecordTypeId from Opportunity where Id=:opp.Id];
        updateOp.Pre_Approved_Complete_Date__c = System.today();
        updateOp.RecordTypeId = rt.Id;
        update updateOp;
        
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        List<Opportunity> opList = new List<Opportunity>();
        oppMap.put(updateOp.Id,updateOp);
        opList.add(updateOp);
        oppMap.put(opp.Id,opp);
        OpportunityHelper.updateRetailBuyerOpportunityStages(opList,oppMap);
    }
    
    static testMethod void updateRetailBuyerOpportunityStagesOfferSubmitted(){
        //String retailBuyerRecTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        RecordType rt = [select id,Name from RecordType where SobjectType='Opportunity' and Name='Retail Buyer' Limit 1];
        System.debug('=rt='+rt);
        Account acc = new Account();
        acc.Name = 'NextStepAccount';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'SFDC';
        opp.StageName = 'Qualified Listing';
        opp.CloseDate = Date.today();
        opp.Listing_Market__c = 'SFDC';
        opp.Current_Rent__c = 1000;
        opp.AccountId = acc.Id;
        opp.Buy_Box_Complete_Date__c = System.today();
        opp.Pre_Approved_Complete_Date__c = System.today();
        opp.Offer_Submitted_Date__c = null;
        opp.RecordTypeId = rt.Id;
        insert opp;
        
        Opportunity updateOp = [select Id,Buy_Box_Complete_Date__c,Pre_Approved_Complete_Date__c,Offer_Submitted_Date__c,RecordTypeId from Opportunity where Id=:opp.Id];
        updateOp.Offer_Submitted_Date__c = System.today();
        updateOp.RecordTypeId = rt.Id;
        update updateOp;
        
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        List<Opportunity> opList = new List<Opportunity>();
        oppMap.put(updateOp.Id,updateOp);
        opList.add(updateOp);
        oppMap.put(opp.Id,opp);
        OpportunityHelper.updateRetailBuyerOpportunityStages(opList,oppMap);
    }
    
    static testMethod void updateRetailBuyerOpportunityStagesPublished(){
        //String retailBuyerRecTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        RecordType rt = [select id,Name from RecordType where SobjectType='Opportunity' and Name='Retail Buyer' Limit 1];
        System.debug('=rt='+rt);
        Account acc = new Account();
        acc.Name = 'NextStepAccount';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'SFDC';
        opp.StageName = 'Qualified Listing';
        opp.CloseDate = Date.today();
        opp.Listing_Market__c = 'SFDC';
        opp.Current_Rent__c = 1000;
        opp.AccountId = acc.Id;
        opp.Buy_Box_Complete_Date__c = System.today();
        opp.Pre_Approved_Complete_Date__c = System.today();
        opp.Offer_Submitted_Date__c = System.today();
        opp.Published_Date__c = null;
        opp.RecordTypeId = rt.Id;
        insert opp;
        
        Opportunity updateOp = [select Id,Buy_Box_Complete_Date__c,Published_Date__c,Pre_Approved_Complete_Date__c,Offer_Submitted_Date__c,RecordTypeId from Opportunity where Id=:opp.Id];
        updateOp.Published_Date__c = System.today();
        updateOp.RecordTypeId = rt.Id;
        update updateOp;
        
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        List<Opportunity> opList = new List<Opportunity>();
        oppMap.put(updateOp.Id,updateOp);
        opList.add(updateOp);
        oppMap.put(opp.Id,opp);
        OpportunityHelper.updateRetailBuyerOpportunityStages(opList,oppMap);
    }
    
    static testMethod void updateRetailBuyerOpportunityStagesInContract(){
        //String retailBuyerRecTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        RecordType rt = [select id,Name from RecordType where SobjectType='Opportunity' and Name='Retail Buyer' Limit 1];
        System.debug('=rt='+rt);
        Account acc = new Account();
        acc.Name = 'NextStepAccount';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'SFDC';
        opp.StageName = 'Qualified Listing';
        opp.CloseDate = Date.today();
        opp.Listing_Market__c = 'SFDC';
        opp.Current_Rent__c = 1000;
        opp.AccountId = acc.Id;
        opp.Buy_Box_Complete_Date__c = System.today();
        opp.Pre_Approved_Complete_Date__c = System.today();
        opp.Offer_Submitted_Date__c = System.today();
        opp.Published_Date__c = System.today();
        opp.In_Contract_Date__c =null;
        opp.RecordTypeId = rt.Id;
        insert opp;
        
        Opportunity updateOp = [select Id,Buy_Box_Complete_Date__c,In_Contract_Date__c,Published_Date__c,Pre_Approved_Complete_Date__c,Offer_Submitted_Date__c,RecordTypeId from Opportunity where Id=:opp.Id];
        updateOp.In_Contract_Date__c = System.today();
        updateOp.RecordTypeId = rt.Id;
        update updateOp;
        
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        List<Opportunity> opList = new List<Opportunity>();
        oppMap.put(updateOp.Id,updateOp);
        opList.add(updateOp);
        oppMap.put(opp.Id,opp);
        OpportunityHelper.updateRetailBuyerOpportunityStages(opList,oppMap);
    }
    
    static testMethod void updateRetailBuyerOpportunityStagesProposalDelivered(){
        //String retailBuyerRecTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        RecordType rt = [select id,Name from RecordType where SobjectType='Opportunity' and Name='Retail Buyer' Limit 1];
        System.debug('=rt='+rt);
        Account acc = new Account();
        acc.Name = 'NextStepAccount';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'SFDC';
        opp.StageName = 'Qualified Listing';
        opp.CloseDate = Date.today();
        opp.Listing_Market__c = 'SFDC';
        opp.Current_Rent__c = 1000;
        opp.AccountId = acc.Id;
        opp.Buy_Box_Complete_Date__c = System.today();
        opp.Pre_Approved_Complete_Date__c = System.today();
        opp.Offer_Submitted_Date__c = System.today();
        opp.In_Contract_Date__c = System.today();
        opp.Published_Date__c = System.today();
        opp.Proposal_Delivered_Date__c = null;
        opp.RecordTypeId = rt.Id;
        insert opp;
        
        Opportunity updateOp = [select Id,Buy_Box_Complete_Date__c,Proposal_Delivered_Date__c,In_Contract_Date__c,Published_Date__c,Pre_Approved_Complete_Date__c,Offer_Submitted_Date__c,RecordTypeId from Opportunity where Id=:opp.Id];
        updateOp.Proposal_Delivered_Date__c = System.today();
        updateOp.RecordTypeId = rt.Id;
        update updateOp;
        
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        List<Opportunity> opList = new List<Opportunity>();
        oppMap.put(updateOp.Id,updateOp);
        opList.add(updateOp);
        oppMap.put(opp.Id,opp);
        OpportunityHelper.updateRetailBuyerOpportunityStages(opList,oppMap);
    }
    
    /*
    static testMethod void updateOpportunityTeamMember(){
        Id oppLeasingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'NextStepAccount';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'SFDC';
        opp.StageName = 'Closed Won';
        opp.CloseDate = Date.today();
        opp.Listing_Market__c = 'SFDC';
        opp.Current_Rent__c = 1000;
        opp.AccountId = acc.Id;
        opp.RecordTypeId = oppLeasingRecordTypeId;
        //opp.Reason_for_Close__c = 'Approved- No Lease Sign';
        insert opp;
        
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.OpportunityId = opp.Id;
        otm.OpportunityAccessLevel = 'Read';
        otm.TeamMemberRole = 'CSR';
        otm.UserId = UserInfo.getUserId();
        insert otm;
        
        List<Opportunity> opList = new List<Opportunity>();
        opList.add(opp);
        Test.startTest();
            OpportunityHelper.updateOpportunityTeamMember(opList);
        Test.stoptest();
    }
    
    static testMethod void closeOpenTaskOnOpportunity(){
        Id oppLeasingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Leasing').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'NextStepAccount';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'SFDC';
        opp.StageName = 'Closed Lost';
        opp.CloseDate = Date.today();
        opp.Listing_Market__c = 'SFDC';
        opp.Current_Rent__c = 1000;
        opp.AccountId = acc.Id;
        opp.RecordTypeId = oppLeasingRecordTypeId;
        opp.Reason_for_Close__c = 'Approved- No Lease Sign';
        insert opp;
        
        Task tsk = new Task();
        tsk.Subject = 'Follow up with Lead';
        tsk.WhatId = opp.Id;
        tsk.OwnerId = UserInfo.getUserId();
        tsk.Status = 'Open';
        tsk.Type = 'Call';
        insert tsk;
        
        List<Opportunity> opList = new List<Opportunity>();
        opList.add(opp);
        OpportunityHelper.closeOpenTaskOnOpportunity(opList);
        
        
    }
	*/
    /*
    static testMethod void updateOpportunityNameAndRoofstockRevenueOnInsert(){
        //String retailBuyerRecTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        RecordType rt = [select id,Name from RecordType where SobjectType='Opportunity' and Name='Retail Buyer' Limit 1];
        System.debug('=rt='+rt);
        Account acc = new Account();
        acc.Name = 'NextStepAccount';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'SFDC';
        opp.StageName = 'Qualified Listing';
        opp.CloseDate = Date.today();
        opp.Listing_Market__c = 'SFDC';
        opp.Current_Rent__c = 1000;
        opp.AccountId = acc.Id;
        opp.Buy_Box_Complete_Date__c = System.today();
        opp.Pre_Approved_Complete_Date__c = System.today();
        opp.Offer_Submitted_Date__c = System.today();
        opp.In_Contract_Date__c = System.today();
        opp.Published_Date__c = System.today();
        opp.Proposal_Delivered_Date__c = null;
        opp.RecordTypeId = rt.Id;
        insert opp;
        List<Opportunity> opList = new List<Opportunity>();
        opList.add(opp);
        OpportunityHelper.updateOpportunityNameAndRoofstockRevenueOnInsert(opList);
    }
    */
    static testMethod void OpportunityTestsException() {
        TriggerDispatcher.forceException = true;
        try{
            Opportunity opp1 = InitOpportunity(retailSellerLeadRTId) ; 
            Test.startTest();
            insert opp1; 
        }
        Catch(Exception exe){
            
        }
    }
    
    
}
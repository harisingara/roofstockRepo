@isTest
public class RetailEventTest {
    
    static{
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    Static testMethod void madeanOfferContactmailEvent(){
        Lead l = new Lead();
        l.LastName='Roofstock';
        l.Email = 'aamaya1004@gmail.com.invalid';
        l.Phone = '';
        l.LeadSource = 'Advertisement';
        l.Company ='Roofstock';
        l.Roofstock_User_Id__c = '1234';
        //l.BPM_Contact_Id__c = '98765';
        insert l;
        
        Contact c = new Contact();
        c.LastName='Roofstock';
        c.Phone = '';
        c.Roofstock_User_Id__c = '1234';
        c.BPM_Contact_Id__c = '98765';
        Id contactBuyerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Roofstock Contact').getRecordTypeId();
        c.recordtypeID =contactBuyerRecordTypeId ;         
        insert c;
        
        // with email id 
        Retail_Event__e ol1 = new Retail_Event__e(); 
        ol1.Event_Name__c = 'BUYER_MADE_AN_OFFER';
        ol1.Email__c = 'testermao1@gmail.com';
        ol1.Attribute1__c = 'contactId';
        ol1.AttributeValue1__c = '98765';
        ol1.Attribute2__c = 'offerDate';
        ol1.AttributeValue2__c = '2020-10-22';
        //Events.add(ol1); 

        
      
        
        //insert re;
        List<Retail_Event__e> retailEventList = new List<Retail_Event__e>();
        retailEventList.add(ol1);
        Test.StartTest();
        // Publish test event
        List<Database.SaveResult> results = EventBus.publish(retailEventList);
        // RetailEventHelper.retailEventSubscriber(retailEventList);
        Test.StopTest();
    }
    Static testMethod void madeanOfferLEadEmailCase(){
        Lead l = new Lead();
        l.LastName='Roofstock';
        l.Email = 'testermao2@gmail.com';
        l.LeadSource = 'Advertisement';
        l.Company ='Roofstock';
        Id leadBuyerRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
       	l.recordtypeID = leadBuyerRecordTypeId; 
        insert l;
        
        Contact c = new Contact();
        c.LastName='Roofstock';
        c.Phone = '9765455654';
        //c.Email = 'aamaya1004@gmail.com.invalid';
        insert c;
        // test made an offer
        List<Retail_Event__e> Events = new List<Retail_Event__e>();
        Retail_Event__e ol = new Retail_Event__e(); 
        ol.Event_Name__c = 'BUYER_MADE_AN_OFFER';
        ol.Email__c = 'testermao2@gmail.com';
        ol.Attribute1__c = 'contactId';
        ol.AttributeValue1__c = '19902021';
        ol.Attribute2__c = 'offerDate';
        ol.AttributeValue2__c = '2023-10-22';
       // Events.add(ol); 
        
        //insert re;
        List<Retail_Event__e> retailEventList = new List<Retail_Event__e>();
        retailEventList.add(ol);
        Test.StartTest();
        // Publish test event
        List<Database.SaveResult>  sr = EventBus.publish(retailEventList);
        // RetailEventHelper.retailEventSubscriber(retailEventList);
        Test.StopTest();
    }
    Static testMethod void buyButtonClickedEvent(){
        Lead l = new Lead();
        l.LastName='Roofstock';
        l.Email = 'aamaya1004@gmail.com.invalid';
        l.LeadSource = 'Advertisement';
        l.Company ='Roofstock';
        insert l;
        
        Contact c = new Contact();
        c.LastName='Roofstock';
        c.Phone = '9765455654';
        //c.Email = 'aamaya1004@gmail.com.invalid';
        insert c;
        // test made an offer
        List<Retail_Event__e> Events = new List<Retail_Event__e>();
        Retail_Event__e ol = new Retail_Event__e(); 
        ol.Event_Name__c = 'BUYER_MADE_AN_OFFER';
        ol.Email__c = 'testermao2@gmail.com';
        ol.Attribute1__c = 'contactId';
        ol.AttributeValue1__c = '19902021';
        ol.Attribute2__c = 'offerDate';
        ol.AttributeValue2__c = '2023-10-22';
        Events.add(ol); 
        Retail_Event__e re = new Retail_Event__e();
        re.Account_Id__c = '12345';
        re.Event_Name__c = 'BUY_BUTTON_CLICKED';
        re.Email__c = 'aamaya1004@gmail.com.invalid';
        re.Phone__c = '9765455654';
        re.Attribute1__c = 'propertyid';
        re.AttributeValue1__c = '1234';
        re.Attribute2__c = 'address';
        re.AttributeValue2__c = '123 main st';
        re.Attribute3__c = 'offer amount';
        re.AttributeValue3__c = '1234500';
        //insert re;
        List<Retail_Event__e> retailEventList = new List<Retail_Event__e>();
        retailEventList.add(re);
        Test.StartTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(re);
        // RetailEventHelper.retailEventSubscriber(retailEventList);
        Test.StopTest();
    }
    Static testMethod void contactUpdateEvent(){
        Lead l = new Lead();
        l.LastName='Roofstock';
        l.Email = 'aamaya1004@gmail.com.invalid';
        l.Phone = '';
        l.LeadSource = 'Advertisement';
        l.Company ='Roofstock';
        l.Roofstock_User_Id__c = '1234';
        l.BPM_Contact_Id__c = '98765';
        insert l;
        
        Contact c = new Contact();
        c.LastName='Roofstock';
        c.Phone = '';
        c.Roofstock_User_Id__c = '1234';
        c.BPM_Contact_Id__c = '98765';
        insert c;
        
        
        
        Retail_Event__e re = new Retail_Event__e();
        re.Account_Id__c = '12345';
        re.Event_Name__c = 'CONTACT_UPDATED';
        re.Email__c = 'aamaya1004@gmail.com.invalid';
        re.Phone__c = '9765455654';
        re.Attribute1__c = 'rsuserid';
        re.AttributeValue1__c = '1234';
        re.Attribute2__c = 'bpmcontactid';
        re.AttributeValue2__c = '98765';
        
        //insert re;
        List<Retail_Event__e> retailEventList = new List<Retail_Event__e>();
        retailEventList.add(re);
        Test.StartTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(re);
        // RetailEventHelper.retailEventSubscriber(retailEventList);
        Test.StopTest();
    }
    
    Static testMethod void sellerPropertyNotInMarket(){
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
       // p.Year_Built__c = 1972;
        p.name = '123 Main St Tracy CA 95391';	   
        insert p;
        
        Id oppRetailSellerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        
        Opportunity o  = new Opportunity();
        o.Name = 'test';
        o.RecordTypeId = oppRetailSellerRecordTypeId;
        o.StageName = 'Submission Started';
        o.closeDate= System.today();
        insert o;
        
        Retail_Event__e re = new Retail_Event__e();
        re.Event_Name__c = 'SELLER_PROPERTY_NOT_IN_MARKET';
        re.Email__c = 'aamaya1004@gmail.com.invalid';
        re.Phone__c = '9765455654';
        re.Attribute1__c = 'opportunityid';
        re.AttributeValue1__c = o.Id;
        //insert re;
        List<Retail_Event__e> retailEventList = new List<Retail_Event__e>();
        retailEventList.add(re);
        Test.StartTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(re);
        // RetailEventHelper.retailEventSubscriber(retailEventList);
        Test.StopTest();
    }
    Static testMethod void sellerPropertyActive(){
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
        //p.Year_Built__c = 1972;
        p.name = '123 Main St Tracy CA 95391';	   
        insert p;
        
        Id oppRetailSellerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        
        Opportunity o  = new Opportunity();
        o.Name = 'test';
        o.RecordTypeId = oppRetailSellerRecordTypeId;
        o.StageName = 'Submission Started';
        o.closeDate= System.today();
        insert o;
        
        Retail_Event__e re = new Retail_Event__e();
        re.Event_Name__c = 'SELLER_PROPERTY_ACTIVE';
        re.Email__c = 'aamaya1004@gmail.com.invalid';
        re.Phone__c = '9765455654';
        re.Attribute1__c = 'opportunityid';
        re.AttributeValue1__c = o.Id;
        re.Attribute2__c = 'submiteddate';
        re.AttributeValue2__c = '2222-11-11';
        //insert re;
        List<Retail_Event__e> retailEventList = new List<Retail_Event__e>();
        retailEventList.add(re);
        Test.StartTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(re);
        // RetailEventHelper.retailEventSubscriber(retailEventList);
        Test.StopTest();
    }
    Static testMethod void sellerClosedLost(){
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
        //p.Year_Built__c = 1972;
        p.name = '123 Main St Tracy CA 95391';	   
        insert p;
        
        Id oppRetailSellerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        
        Opportunity o  = new Opportunity();
        o.Name = 'test';
        o.RecordTypeId = oppRetailSellerRecordTypeId;
        o.StageName = 'Submission Started';
        o.closeDate= System.today();
        insert o;
        
        Retail_Event__e re = new Retail_Event__e();
        re.Event_Name__c = 'SELLER_CLOSED_LOST';
        re.Email__c = 'aamaya1004@gmail.com.invalid';
        re.Phone__c = '9765455654';
        re.Attribute1__c = 'opportunityid';
        re.AttributeValue1__c = o.Id;
        re.Attribute2__c = 'reason';
        re.AttributeValue2__c = 'Price Discrepancy';
        //insert re;
        List<Retail_Event__e> retailEventList = new List<Retail_Event__e>();
        retailEventList.add(re);
        Test.StartTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(re);
        // RetailEventHelper.retailEventSubscriber(retailEventList);
        Test.StopTest();
    }
    Static testMethod void sellerProposalDelivered(){
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
       // p.Year_Built__c = 1972;
        p.name = '123 Main St Tracy CA 95391';	   
        insert p;
        
        Id oppRetailSellerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        
        Opportunity o  = new Opportunity();
        o.Name = 'test';
        o.RecordTypeId = oppRetailSellerRecordTypeId;
        o.StageName = 'Submission Started';
        o.closeDate= System.today();
        insert o;
        
        Retail_Event__e re = new Retail_Event__e();
        re.Event_Name__c = 'SELLER_PROPOSAL_DELIVERED';
        re.Email__c = 'aamaya1004@gmail.com.invalid';
        re.Phone__c = '9765455654';
        re.Attribute1__c = 'opportunityid';
        re.AttributeValue1__c = o.Id;
        re.Attribute2__c = 'proposaldate';
        re.AttributeValue2__c = '2222-11-11';
        //insert re;
        List<Retail_Event__e> retailEventList = new List<Retail_Event__e>();
        retailEventList.add(re);
        Test.StartTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(re);
        // RetailEventHelper.retailEventSubscriber(retailEventList);
        Test.StopTest();
    }
    Static testMethod void sellerPendingCertification(){
        Certification__c cert = new Certification__c();
        cert.BPM_Certification_Id__c = '1234';
        insert cert;
        
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
       // p.Year_Built__c = 1972;
        p.name = '123 Main St Tracy CA 95391';	   
        insert p;
        
        Id oppRetailSellerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        
        Opportunity o  = new Opportunity();
        o.Name = 'test';
        o.RecordTypeId = oppRetailSellerRecordTypeId;
        o.StageName = 'Submission Started';
        o.closeDate= System.today();
        insert o;
        
        Retail_Event__e re = new Retail_Event__e();
        re.Event_Name__c = 'SELLER_PENDING_CERTIFICATION';
        re.Email__c = 'aamaya1004@gmail.com.invalid';
        re.Phone__c = '9765455654';
        re.Attribute1__c = 'opportunityid';
        re.AttributeValue1__c = o.Id;
        re.Attribute2__c = 'certificationid';
        re.AttributeValue2__c = '1234';

        //insert re;
        List<Retail_Event__e> retailEventList = new List<Retail_Event__e>();
        retailEventList.add(re);
        Test.StartTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(re);
        // RetailEventHelper.retailEventSubscriber(retailEventList);
        Test.StopTest();
    }
    Static testMethod void sellerSignedListing(){
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
        //p.Year_Built__c = 1972;
        p.name = '123 Main St Tracy CA 95391';	   
        insert p;
        
        Id oppRetailSellerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        
        Opportunity o  = new Opportunity();
        o.Name = 'test';
        o.RecordTypeId = oppRetailSellerRecordTypeId;
        o.StageName = 'Submission Started';
        o.closeDate= System.today();
        insert o;
        
        Retail_Event__e re = new Retail_Event__e();
        re.Event_Name__c = 'SELLER_SIGNED_LISTING';
        re.Email__c = 'aamaya1004@gmail.com.invalid';
        re.Phone__c = '9765455654';
        re.Attribute1__c = 'opportunityid';
        re.AttributeValue1__c = o.Id;
        re.Attribute2__c = 'signedlistingdate';
        re.AttributeValue2__c = '2222-11-11';

        //insert re;
        List<Retail_Event__e> retailEventList = new List<Retail_Event__e>();
        retailEventList.add(re);
        Test.StartTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(re);
        // RetailEventHelper.retailEventSubscriber(retailEventList);
        Test.StopTest();
    }
    Static testMethod void sellerEscalated(){
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
       // p.Year_Built__c = 1972;
        p.name = '123 Main St Tracy CA 95391';	   
        insert p;
        
        Id oppRetailSellerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        
        Opportunity o  = new Opportunity();
        o.Name = 'test';
        o.RecordTypeId = oppRetailSellerRecordTypeId;
        o.StageName = 'Submission Started';
        o.closeDate= System.today();
        insert o;
        
        Retail_Event__e re = new Retail_Event__e();
        re.Event_Name__c = 'SELLER_ESCALATED';
        re.Email__c = 'aamaya1004@gmail.com.invalid';
        re.Phone__c = '9765455654';
        re.Attribute1__c = 'opportunityid';
        re.AttributeValue1__c = o.Id;
        re.Attribute2__c = 'escalateddate';
        re.AttributeValue2__c = '2222-11-11';

        //insert re;
        List<Retail_Event__e> retailEventList = new List<Retail_Event__e>();
        retailEventList.add(re);
        Test.StartTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(re);
        // RetailEventHelper.retailEventSubscriber(retailEventList);
        Test.StopTest();
    }
    Static testMethod void sellerListingPublished(){
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
        //p.Year_Built__c = 1972;
        p.name = '123 Main St Tracy CA 95391';	   
        insert p;
        
        Listing__c listing = new Listing__c();
        listing.Allow_Offer__c = true;
        listing.Property__c = p.Id;
        listing.Listing_Id__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        insert listing;
        
        Id oppRetailSellerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        
        Opportunity o  = new Opportunity();
        o.Name = 'test';
        o.RecordTypeId = oppRetailSellerRecordTypeId;
        o.StageName = 'Submission Started';
        o.closeDate= System.today();
        insert o;
        
        Retail_Event__e re = new Retail_Event__e();
        re.Event_Name__c = 'SELLER_LISTING_PUBLISHED';
        re.Email__c = 'aamaya1004@gmail.com.invalid';
        re.Phone__c = '9765455654';
        re.Attribute1__c = 'opportunityid';
        re.AttributeValue1__c = o.Id;
        re.Attribute2__c = 'publisheddate';
        re.AttributeValue2__c = '2222-11-11';
        re.Attribute3__c = 'listingid';
        re.AttributeValue3__c = '72bcf440-899b-4fe4-b79f-9a14366fead';

        //insert re;
        List<Retail_Event__e> retailEventList = new List<Retail_Event__e>();
        retailEventList.add(re);
        Test.StartTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(re);
        // RetailEventHelper.retailEventSubscriber(retailEventList);
        Test.StopTest();
    }
    Static testMethod void sellerInContract(){
        Transaction__c trans = new Transaction__c();
        trans.Transaction_Id__c = '1234';
        insert trans;
        
        Id oppRetailSellerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        
        Opportunity o  = new Opportunity();
        o.Name = 'test';
        o.RecordTypeId = oppRetailSellerRecordTypeId;
        o.StageName = 'Submission Started';
        o.closeDate= System.today();
        insert o;
        
        Retail_Event__e re = new Retail_Event__e();
        re.Event_Name__c = 'SELLER_IN_CONTRACT';
        re.Email__c = 'aamaya1004@gmail.com.invalid';
        re.Phone__c = '9765455654';
        re.Attribute1__c = 'opportunityid';
        re.AttributeValue1__c = o.Id;
        re.Attribute2__c = 'transactionid';
        re.AttributeValue2__c = '1234';


        //insert re;
        List<Retail_Event__e> retailEventList = new List<Retail_Event__e>();
        retailEventList.add(re);
        Test.StartTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(re);
        // RetailEventHelper.retailEventSubscriber(retailEventList);
        Test.StopTest();
    }
    Static testMethod void sellerClosedWon(){

        Id oppRetailSellerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
        
        Opportunity o  = new Opportunity();
        o.Name = 'test';
        o.RecordTypeId = oppRetailSellerRecordTypeId;
        o.StageName = 'Submission Started';
        o.closeDate= System.today();
        insert o;
        
        Retail_Event__e re = new Retail_Event__e();
        re.Event_Name__c = 'SELLER_CLOSED_WON';
        re.Email__c = 'aamaya1004@gmail.com.invalid';
        re.Phone__c = '9765455654';
        re.Attribute1__c = 'opportunityid';
        re.AttributeValue1__c = o.Id;
        re.Attribute2__c = 'closeddate';
        re.AttributeValue2__c = '2222-11-11';


        //insert re;
        List<Retail_Event__e> retailEventList = new List<Retail_Event__e>();
        retailEventList.add(re);
        Test.StartTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(re);
        // RetailEventHelper.retailEventSubscriber(retailEventList);
        Test.StopTest();
    }
    
    Static testMethod void docusignCertification(){
        
        Transaction__c trans = new Transaction__c();
        trans.Name = 'Trans';
        trans.Transaction_Id__c = '1234';
        insert trans;
        
        Certification__c cert = new Certification__c();
        cert.Name = 'Cert';
        cert.BPM_Certification_Id__c = '1234';
        insert cert;
        
        Contact con = new Contact();
        con.LastName = 'sfdc';
        con.BPM_Contact_Id__c = '1234';
        insert con;
        
        Retail_Event__e re = new Retail_Event__e();
        re.Event_Name__c = 'Listing_Addendum_Seller_Signed';
        re.Email__c = 'aamaya1004@gmail.com.invalid';
        re.Phone__c = '9765455654';
        re.AttributeValue1__c = '1234';
        re.Attribute2__c = 'contactId';
        re.AttributeValue2__c = '1234';


        //insert re;
        List<Retail_Event__e> retailEventList = new List<Retail_Event__e>();
        retailEventList.add(re);
        Test.StartTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(re);
        // RetailEventHelper.retailEventSubscriber(retailEventList);
        Test.StopTest();
    }
    Static testMethod void docusignTransaction(){
        
        Transaction__c trans = new Transaction__c();
        trans.Name = 'Trans';
        trans.Transaction_Id__c = '1234';
        insert trans;
        
        Certification__c cert = new Certification__c();
        cert.Name = 'Cert';
        cert.BPM_Certification_Id__c = '1234';
        insert cert;
        
        Contact con = new Contact();
        con.LastName = 'sfdc';
        con.BPM_Contact_Id__c = '1234';
        insert con;
        
        Retail_Event__e re = new Retail_Event__e();
        re.Event_Name__c = 'BUYER_SIGNED_PSA';
        re.Email__c = 'aamaya1004@gmail.com.invalid';
        re.Phone__c = '9765455654';
        re.AttributeValue1__c = '1234';
        re.Attribute2__c = 'contactId';
        re.AttributeValue2__c = '1234';


        //insert re;
        List<Retail_Event__e> retailEventList = new List<Retail_Event__e>();
        retailEventList.add(re);
        Test.StartTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(re);
        // RetailEventHelper.retailEventSubscriber(retailEventList);
        Test.StopTest();
    }
    Static testMethod void docusignTransactionException(){
        try{
        Transaction__c trans = new Transaction__c();
        trans.Name = 'Trans';
        trans.Transaction_Id__c = '1234';
        insert trans;
        
        Certification__c cert = new Certification__c();
        cert.Name = 'Cert';
        cert.BPM_Certification_Id__c = '1234';
        insert cert;
        
        Contact con = new Contact();
        con.LastName = 'sfdc';
        con.BPM_Contact_Id__c = '1234';
        insert con;
        
        Retail_Event__e re = new Retail_Event__e();
        re.Event_Name__c = 'BUYER_SIGNED_PSA';
        re.Email__c = 'aamaya1004@gmail.com.invalid';
        re.Phone__c = '9765455654';
        re.AttributeValue1__c = '1234';
        re.Attribute2__c = 'contactId';
        re.AttributeValue2__c = '1234';


        //insert re;
        List<Retail_Event__e> retailEventList = new List<Retail_Event__e>();
        retailEventList.add(re);
        
        Test.StartTest();
        // Publish test event
        Retail_Event__e rr = null;
        Database.SaveResult sr = EventBus.publish(rr);
        // RetailEventHelper.retailEventSubscriber(retailEventList);
        Test.StopTest();
        }
        catch(Exception ex){
            
        }
    }
}
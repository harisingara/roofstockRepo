@isTest
public class RESTLeasingActivityControllerYardiTest {
    
    static {
        //create test users
        
        TestDataFactory.insertHierarchyCustomSettingData(); 
        TestDataFactory.createTestLeasingUserRecords(1);
        TestDataFactory.createTestLeasingListingRecords(5); 
    }
    
    
    static testMethod void processPrimaryApplicant() {
        User u1 = [SELECT Id, profile.name FROM User WHERE Profile.Name = 'System Administrator' and isActive = true LIMIT 1];
        u1.Assignment_Group_Active__c = true;
        update u1;
        
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
        
        
        String activityReq = '{'+
		'	\"leasingActivityList\": ['+
		'		{'+
		'			\"email\": \"cpetri0452@gmail.com\",'+
		'			\"firstName\": \"Ronald\",'+
		'			\"lastName\": \"petri\",'+
		'			\"phone\": \"8177235477\",'+
		'			\"activityType\": \"application_started\",'+
		'			\"activityId\": \"217700\",'+
		'			\"timeStamp\": \"2022-01-02T15:01:14.35Z\",'+
		'			\"timeZone\": \"Central Time (US & Canada)\",'+
		'			\"source\": \"Property Website\",'+
		'			\"feedback\": \"\",'+
		'			\"isViewing\": false,'+
		'			\"listingId\": \"21978\",'+
		'			\"prospectId\": \"174406\",'+
		'			\"primaryProspectId\": \"0\",'+
		'			\"relationship\": \"Self\",'+
		'			\"code\": \"p0167220\",'+
		'			\"backgroundRun\": false,'+
		'			\"moveInDate\": \"2022-01-14\",'+
		'			\"leaseStart\": \"2022-01-14\",'+
		'			\"leaseEnd\": \"2023-07-13\",'+
		'			\"numPets\": 1,'+
		'			\"prospectNotes\": \"Interested In:\"'+
		'		}'+
		'        ]'+
		'}';
        
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/AddLeasingActivityYardi';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(activityReq);
        
        RestContext.request = req;
        RestContext.response = res;
		RESTLeasingActivityControllerYardi.addLeasingActivityRecord();
        
        System.runAs(u1) {
            Test.startTest();
            
            
            activityReq = '{'+
		'	\"leasingActivityList\": ['+
		'        {'+
		'            \"email\": \"cpetrimom0452@gmail.com\",'+
		'			\"firstName\": \"Ronaldmom\",'+
		'			\"lastName\": \"petrimom\",'+
		'			\"phone\": \"8177235476\",'+
		'			\"activityType\": \"application_started\",'+
		'			\"activityId\": \"22223\",'+
		'			\"timeStamp\": \"2022-01-02T15:01:14.35Z\",'+
		'			\"timeZone\": \"Central Time (US & Canada)\",'+
		'			\"source\": \"Property Website\",'+
		'			\"feedback\": \"\",'+
		'			\"isViewing\": false,'+
		'			\"listingId\": \"21978\",'+
		'			\"prospectId\": \"174489\",'+
		'			\"primaryProspectId\": \"174406\",'+
		'			\"relationship\": \"Mom\",'+
		'			\"code\": \"p0167300\",'+
		'			\"backgroundRun\": false,'+
		'			\"moveInDate\": \"2022-01-14\",'+
		'			\"leaseStart\": \"2022-01-14\",'+
		'			\"leaseEnd\": \"2023-07-13\",'+
		'			\"numPets\": 1,'+
		'			\"prospectNotes\": \"Interested In: Condo1\"'+
		'		},'+
		'        {'+
		'            \"email\": \"cpetri0452@gmail.com\",'+
		'			\"firstName\": \"Christine\",'+
		'			\"lastName\": \"petri\",'+
		'			\"phone\": \"8177235477\",'+
		'			\"activityType\": \"application_started\",'+
		'			\"activityId\": \"22224\",'+
		'			\"timeStamp\": \"2022-01-02T15:01:14.35Z\",'+
		'			\"timeZone\": \"Central Time (US & Canada)\",'+
		'			\"source\": \"Property Website\",'+
		'			\"feedback\": \"\",'+
		'			\"isViewing\": false,'+
		'			\"listingId\": \"21978\",'+
		'			\"prospectId\": \"174486\",'+
		'			\"primaryProspectId\": \"174406\",'+
		'			\"relationship\": \"Spouse\",'+
		'			\"code\": \"p0167300\",'+
		'			\"backgroundRun\": false,'+
		'			\"moveInDate\": \"2022-01-14\",'+
		'			\"leaseStart\": \"2022-01-14\",'+
		'			\"leaseEnd\": \"2023-07-13\",'+
		'			\"numPets\": 1,'+
		'			\"prospectNotes\": \"Interested In: Condo1\"'+
		'		},'+
		'        {'+
		'			\"email\": \"\",'+
		'			\"firstName\": \"Ronaldson\",'+
		'			\"lastName\": \"petrison\",'+
		'			\"phone\": \"\",'+
		'			\"activityType\": \"application_started\",'+
		'			\"activityId\": \"217702\",'+
		'			\"timeStamp\": \"2022-01-02T15:01:14.35Z\",'+
		'			\"timeZone\": \"Central Time (US & Canada)\",'+
		'			\"source\": \"Property Website\",'+
		'			\"feedback\": \"\",'+
		'			\"isViewing\": false,'+
		'			\"listingId\": \"21978\",'+
		'			\"prospectId\": \"174487\",'+
		'			\"primaryProspectId\": \"174406\",'+
		'			\"relationship\": \"Son\",'+
		'			\"code\": \"p0167220\",'+
		'			\"backgroundRun\": false,'+
		'			\"moveInDate\": \"2022-01-14\",'+
		'			\"leaseStart\": \"2022-01-14\",'+
		'			\"leaseEnd\": \"2023-07-13\",'+
		'			\"numPets\": 1,'+
		'			\"prospectNotes\": \"Interested In:\"'+
		'		},'+
		'		{'+
		'			\"email\": \"\",'+
		'			\"firstName\": \"Ronalddaughter\",'+
		'			\"lastName\": \"petridaugther\",'+
		'			\"phone\": \"\",'+
		'			\"activityType\": \"application_started\",'+
		'			\"activityId\": \"217703\",'+
		'			\"timeStamp\": \"2022-01-02T15:01:14.35Z\",'+
		'			\"timeZone\": \"Central Time (US & Canada)\",'+
		'			\"source\": \"Property Website\",'+
		'			\"feedback\": \"\",'+
		'			\"isViewing\": false,'+
		'			\"listingId\": \"21978\",'+
		'			\"prospectId\": \"174488\",'+
		'			\"primaryProspectId\": \"174406\",'+
		'			\"relationship\": \"Daughter\",'+
		'			\"code\": \"p0167220\",'+
		'			\"backgroundRun\": false,'+
		'			\"moveInDate\": \"2022-01-14\",'+
		'			\"leaseStart\": \"2022-01-14\",'+
		'			\"leaseEnd\": \"2023-07-13\",'+
		'			\"numPets\": 1,'+
		'			\"prospectNotes\": \"Interested In:\"'+
		'		}'+
		'        ]'+
		'}';
            RESTLeasingActivityHelper.LeasingActivityData oReq = (RESTLeasingActivityHelper.LeasingActivityData) System.JSON.deserialize(activityReq,RESTLeasingActivityHelper.LeasingActivityData.class); 
            //System.debug('NDEBUG After Conv Req :::' + req.requestBody.toString());
            List<RESTLeasingActivityHelper.LeasingActivityResponse>  response = RESTLeasingActivityHelperYardi.AddLeasingActivity(oReq.leasingActivityList);
            //req.requestBody = Blob.valueOf(activityReq);
            //RESTLeasingActivityControllerYardi.addLeasingActivityRecord();
            
            Test.stopTest();
            // 2 Accounts, 1 Primary Applicant Opps, 2 Secondary Applicants Opps, 3 ORUs and 3 ORUAs have to be created
            // Perform the checks here
            List <Account> acctsInserted = [Select Id, Name from Account];
            System.debug('NDEBUG Number of Accounts inserted::' + acctsInserted.size());
            System.assertEquals(acctsInserted.size(), 2);
            List <Contact> cntsInserted = [Select Id, FirstName from Contact];
            System.assertEquals(cntsInserted.size(), 3);
            System.debug('NDEBUG Number of Contacts inserted::' + cntsInserted.size());
            List <Opportunity> oppsInserted = [Select Id, Name, Yardi_Prospect_Id__c, Yardi_Primary_Prospect_Id__c, Minor_Applicants__c   from Opportunity];
            System.assertEquals(oppsInserted.size(), 3);
            System.debug('NDEBUG Number of Opportunities inserted::' + oppsInserted.size());
            System.debug('NDEBUG Opps inserted:::' + oppsInserted);
            List <OpportunityRentalUnit__c> orusInserted = [Select Id, Name from OpportunityRentalUnit__c];
            System.assertEquals(orusInserted.size(), 3);
            System.debug('NDEBUG Number of ORUs inserted::' + orusInserted.size());
            //Get the Opportunity of the Primary Applicant
            oppsInserted =  [Select Id, Name, Yardi_Prospect_Id__c, Minor_Applicants__c   from Opportunity where Yardi_Primary_Prospect_Id__c =: ''];
            
            System.assert(String.isNotBlank(oppsInserted[0].Minor_Applicants__c));
            System.assertEquals(oppsInserted.size(), 1);
            String primaryProspectId = oppsInserted[0].Yardi_Prospect_Id__c;
            String primaryApplOppId = oppsInserted[0].Id;
            oppsInserted =  [Select Id, Name, Yardi_Prospect_Id__c, Minor_Applicants__c   from Opportunity where Primary_Applicant_Opp__c  =: primaryApplOppId];
            System.assertEquals(oppsInserted.size(), 2);
            List <Opportunity_Rental_Unit_Activity__c> oruasInserted = [Select Id from Opportunity_Rental_Unit_Activity__c];
            System.assertEquals(oruasInserted.size(), 3);
        }
    }

    static testMethod void processPrimaryApplicant1() {
        User u1 = [SELECT Id, profile.name FROM User WHERE Profile.Name = 'System Administrator' and isActive = true LIMIT 1];
        u1.Assignment_Group_Active__c = true;
        update u1;
        
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
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/AddLeasingActivityYardi';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('');
        
        RestContext.request = req;
        RestContext.response = res;
		RESTLeasingActivityControllerYardi.addLeasingActivityRecord();
    }
    
    static testMethod void processPrimaryApplicant2() {
        User u1 = [SELECT Id, profile.name FROM User WHERE Profile.Name = 'System Administrator' and isActive = true LIMIT 1];
        u1.Assignment_Group_Active__c = true;
        update u1;
        
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
        
        
        String activityReq = '{'+
		'	\"leasingActivityList\": ['+
		'		{'+
		'			\"email\": \"cpetri0452@gmail.com\",'+
		'			\"firstName\": \"Ronald\",'+
		'			\"lastName\": \"Petri\",'+
		'			\"phone\": \"\",'+
		'			\"activityType\": \"application_started\",'+
		'			\"activityId\": \"217700\",'+
		'			\"timeStamp\": \"2022-01-02T15:01:14.35Z\",'+
		'			\"timeZone\": \"Central Time (US & Canada)\",'+
		'			\"source\": \"Property Website\",'+
		'			\"feedback\": \"\",'+
		'			\"isViewing\": false,'+
		'			\"listingId\": \"21978\",'+
		'			\"prospectId\": \"174406\",'+
		'			\"primaryProspectId\": \"0\",'+
		'			\"relationship\": \"Self\",'+
		'			\"code\": \"p0167220\",'+
		'			\"backgroundRun\": false,'+
		'			\"moveInDate\": \"2022-01-14\",'+
		'			\"leaseStart\": \"2022-01-14\",'+
		'			\"leaseEnd\": \"2023-07-13\",'+
		'			\"numPets\": 1,'+
        '			\"appStatus\": \"Prospect\",'+
		'			\"prospectNotes\": \"Interested In:\"'+
		'		}'+
		'        ]'+
		'}';
        
        /*
        RESTLeasingActivityHelper.LeasingActivityData oReq = (RESTLeasingActivityHelper.LeasingActivityData) System.JSON.deserialize(activityReq,RESTLeasingActivityHelper.LeasingActivityData.class); 
            System.debug('NDEBUG After Conv Req :::' + activityReq);
            List<RESTLeasingActivityHelper.LeasingActivityResponse> response = RESTLeasingActivityHelperYardi.AddLeasingActivity(oReq.leasingActivityList);
        */
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/AddLeasingActivityYardi';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(activityReq);
        
        RestContext.request = req;
        RestContext.response = res;
		RESTLeasingActivityControllerYardi.addLeasingActivityRecord();
        
        
        
        System.runAs(u1) {
            Test.startTest();
            
            
            activityReq = '{'+
		'	\"leasingActivityList\": ['+
		'        {'+
		'            \"email\": \"cpetrimom0452@gmail.com\",'+
		'			\"firstName\": \"Ronaldmom\",'+
		'			\"lastName\": \"Petrimom\",'+
		'			\"phone\": \"\",'+
		'			\"activityType\": \"application_started\",'+
		'			\"activityId\": \"22223\",'+
		'			\"timeStamp\": \"2022-01-02T15:01:14.35Z\",'+
		'			\"timeZone\": \"Central Time (US & Canada)\",'+
		'			\"source\": \"Property Website\",'+
		'			\"feedback\": \"\",'+
		'			\"isViewing\": false,'+
		'			\"listingId\": \"21978\",'+
		'			\"prospectId\": \"174489\",'+
		'			\"primaryProspectId\": \"174406\",'+
		'			\"relationship\": \"Mom\",'+
		'			\"code\": \"p0167300\",'+
		'			\"backgroundRun\": false,'+
		'			\"moveInDate\": \"2022-01-14\",'+
		'			\"leaseStart\": \"2022-01-14\",'+
		'			\"leaseEnd\": \"2023-07-13\",'+
		'			\"numPets\": 1,'+
		'			\"prospectNotes\": \"Interested In: Condo1\"'+
		'		},'+
		'        {'+
		'            \"email\": \"cpetri0452@gmail.com\",'+
		'			\"firstName\": \"Christine\",'+
		'			\"lastName\": \"Petri\",'+
		'			\"phone\": \"\",'+
		'			\"activityType\": \"application_started\",'+
		'			\"activityId\": \"22224\",'+
		'			\"timeStamp\": \"2022-01-02T15:01:14.35Z\",'+
		'			\"timeZone\": \"Central Time (US & Canada)\",'+
		'			\"source\": \"Property Website\",'+
		'			\"feedback\": \"\",'+
		'			\"isViewing\": false,'+
		'			\"listingId\": \"21978\",'+
		'			\"prospectId\": \"174486\",'+
		'			\"primaryProspectId\": \"174406\",'+
		'			\"relationship\": \"Spouse\",'+
		'			\"code\": \"p0167300\",'+
		'			\"backgroundRun\": false,'+
		'			\"moveInDate\": \"2022-01-14\",'+
		'			\"leaseStart\": \"2022-01-14\",'+
		'			\"leaseEnd\": \"2023-07-13\",'+
		'			\"numPets\": 1,'+
		'			\"prospectNotes\": \"Interested In: Condo1\"'+
		'		},'+
		'        {'+
		'			\"email\": \"\",'+
		'			\"firstName\": \"Ronaldson\",'+
		'			\"lastName\": \"petrison\",'+
		'			\"phone\": \"\",'+
		'			\"activityType\": \"application_started\",'+
		'			\"activityId\": \"217702\",'+
		'			\"timeStamp\": \"2022-01-02T15:01:14.35Z\",'+
		'			\"timeZone\": \"Central Time (US & Canada)\",'+
		'			\"source\": \"Property Website\",'+
		'			\"feedback\": \"\",'+
		'			\"isViewing\": false,'+
		'			\"listingId\": \"21978\",'+
		'			\"prospectId\": \"174487\",'+
		'			\"primaryProspectId\": \"174406\",'+
		'			\"relationship\": \"Son\",'+
		'			\"code\": \"p0167220\",'+
		'			\"backgroundRun\": false,'+
		'			\"moveInDate\": \"2022-01-14\",'+
		'			\"leaseStart\": \"2022-01-14\",'+
		'			\"leaseEnd\": \"2023-07-13\",'+
		'			\"numPets\": 1,'+
		'			\"prospectNotes\": \"Interested In:\"'+
		'		},'+
		'		{'+
		'			\"email\": \"\",'+
		'			\"firstName\": \"Ronalddaughter\",'+
		'			\"lastName\": \"petridaugther\",'+
		'			\"phone\": \"\",'+
		'			\"activityType\": \"application_started\",'+
		'			\"activityId\": \"217703\",'+
		'			\"timeStamp\": \"2022-01-02T15:01:14.35Z\",'+
		'			\"timeZone\": \"Central Time (US & Canada)\",'+
		'			\"source\": \"Property Website\",'+
		'			\"feedback\": \"\",'+
		'			\"isViewing\": false,'+
		'			\"listingId\": \"21978\",'+
		'			\"prospectId\": \"174488\",'+
		'			\"primaryProspectId\": \"174406\",'+
		'			\"relationship\": \"Daughter\",'+
		'			\"code\": \"p0167220\",'+
		'			\"backgroundRun\": false,'+
		'			\"moveInDate\": \"2022-01-14\",'+
		'			\"leaseStart\": \"2022-01-14\",'+
		'			\"leaseEnd\": \"2023-07-13\",'+
		'			\"numPets\": 1,'+
		'			\"prospectNotes\": \"Interested In:\"'+
		'		}'+
		'        ]'+
		'}';
            RESTLeasingActivityHelper.LeasingActivityData oReq = (RESTLeasingActivityHelper.LeasingActivityData) System.JSON.deserialize(activityReq,RESTLeasingActivityHelper.LeasingActivityData.class); 
            //System.debug('NDEBUG After Conv Req :::' + req.requestBody.toString());
            List<RESTLeasingActivityHelper.LeasingActivityResponse>  response = RESTLeasingActivityHelperYardi.AddLeasingActivity(oReq.leasingActivityList);
            //req.requestBody = Blob.valueOf(activityReq);
            //RESTLeasingActivityControllerYardi.addLeasingActivityRecord();
            //
            Opportunity Opp = [SELECT Id FROM Opportunity WHERE Relationship__c = 'Self' LIMIT 1];
            Opp.App_Decision__c = '';
            opp.Application_Status__c = 'Applied';
            Update Opp;
            
            Test.stopTest();
            // 2 Accounts, 1 Primary Applicant Opps, 2 Secondary Applicants Opps, 3 ORUs and 3 ORUAs have to be created
            // Perform the checks here
            List <Account> acctsInserted = [Select Id, Name from Account];
            System.debug('NDEBUG Number of Accounts inserted::' + acctsInserted.size());
            System.assertEquals(acctsInserted.size(), 2);
            List <Contact> cntsInserted = [Select Id, FirstName from Contact];
            System.debug('NDEBUG Contacts Inserted :::' + cntsInserted);
            System.assertEquals(cntsInserted.size(), 3);
            System.debug('NDEBUG Number of Contacts inserted::' + cntsInserted.size());
            List <Opportunity> oppsInserted = [Select Id, Name, Yardi_Prospect_Id__c, Yardi_Primary_Prospect_Id__c, Minor_Applicants__c   from Opportunity];
            System.assertEquals(oppsInserted.size(), 3);
            System.debug('NDEBUG Number of Opportunities inserted::' + oppsInserted.size());
            System.debug('NDEBUG Opps inserted:::' + oppsInserted);
            List <OpportunityRentalUnit__c> orusInserted = [Select Id, Name from OpportunityRentalUnit__c];
            System.assertEquals(orusInserted.size(), 3);
            System.debug('NDEBUG Number of ORUs inserted::' + orusInserted.size());
            //Get the Opportunity of the Primary Applicant
            oppsInserted =  [Select Id, Name, Yardi_Prospect_Id__c, Minor_Applicants__c   from Opportunity where Yardi_Primary_Prospect_Id__c =: ''];
            
            System.assert(String.isNotBlank(oppsInserted[0].Minor_Applicants__c));
            System.assertEquals(oppsInserted.size(), 1);
            String primaryProspectId = oppsInserted[0].Yardi_Prospect_Id__c;
            String primaryApplOppId = oppsInserted[0].Id;
            oppsInserted =  [Select Id, Name, Yardi_Prospect_Id__c, Minor_Applicants__c   from Opportunity where Primary_Applicant_Opp__c  =: primaryApplOppId];
            System.assertEquals(oppsInserted.size(), 2);
            List <Opportunity_Rental_Unit_Activity__c> oruasInserted = [Select Id from Opportunity_Rental_Unit_Activity__c];
            System.assertEquals(oruasInserted.size(), 3);
        }
    }
    
}
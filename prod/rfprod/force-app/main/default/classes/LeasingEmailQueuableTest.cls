@isTest
public class LeasingEmailQueuableTest {
       static{
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void SchedulableTest() {        
        test.starttest();
        LeasingEmailsSchedulable myClass = new LeasingEmailsSchedulable ();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stopTest();
    }
    
    static testmethod void QueueableTest() {
        // 24 hours reminder    
        date oneDayAgo      = system.today().addDays(-1);
        date twoDaysAgo     = system.today().addDays(-2);
        date sevenDaysAgo   = system.today().addDays(-7);

        TestDataFactory.createTestLeasingUserRecords(1);
        TestDataFactory.createTestLeasingListingRecords(5);
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        System.debug('user' + u1);
    
        List<RESTLeasingActivityHelper.LeasingActivityWrapper> leasingActivityList = new List<RESTLeasingActivityHelper.LeasingActivityWrapper>();
        RESTLeasingActivityHelper.LeasingActivityWrapper activity = new RESTLeasingActivityHelper.LeasingActivityWrapper();
        activity.email = 'nouser@nowhere.com';
        activity.firstName = 'Test';
        activity.lastName = 'User';
        activity.phone = '5103448876';
        activity.activityType = 'application_started';
        activity.activityId = '17047';
        activity.timeStamp = oneDayAgo;
        activity.timeZone = 'Central Time (US & Canada)';
        activity.source = 'RENTCafe.com ILS';
        activity.feedback = null;
        activity.listingId = '139221';
        leasingActivityList.add(activity);
    
        List<RESTLeasingActivityHelper.LeasingActivityResponse> response =
                            RESTLeasingActivityHelper.AddLeasingActivity(
                            leasingActivityList
                            );

        // startTest/stopTest block to force async processes 
        //   to run in the test.
        Test.startTest();  
        
       

        //------leasing application started first reminder  Application Complete First Reminder Date
        //Application Complete Third Email Date Application_Complete_Third_Email_Date
        List<OpportunityRentalUnit__c> orus1 =  [
                    SELECT  
                        id , Status__c, Leasing__c, Application_Start_Date__c,
                        Opportunity__r.ownerid,
                        Opportunity__r.StageName, Opportunity__r.Primary_Leasing_Contact__r.email ,
                        Application_Complete_First_Email_Date__c
                    FROM 
                        OpportunityRentalUnit__c 
                    WHERE 
                    (  Opportunity__r.Primary_Leasing_Contact__c != null 
                        and Opportunity__r.Primary_Leasing_Contact__r.Email != null 
                        and Primary_Leasing_Contact__r.HasOptedOutOfEmail = false 
                        and Opportunity__r.StageName = 'Application Started'
                        and Status__c = 'Application Started' 
                        and Leasing__r.Status__c <> 'Inactive'
                        and Leasing__r.Status__c <> 'Leased'
                        and Application_Complete_First_Email_Date__c = null 
                        and DAY_ONLY(Application_Start_Date__c) = :oneDayAgo
                    ) 
            ];

            EmailTemplate emailTemplate1 = [Select name,Id,Subject,Description,HtmlValue,DeveloperName,Body 
                            from EmailTemplate where developername = 'Leasing_Application_Started_First_Reminder'];

            if(orus1.size() > 0) {
                System.enqueueJob(new LeasingEmailsQueuable(orus1, emailTemplate1));
            }

            //------ leasing application started second reminder 
            List<OpportunityRentalUnit__c> orus2 =  [
            SELECT  
                id , Status__c, Leasing__c, Application_Start_Date__c,
                Opportunity__r.ownerid,
                Opportunity__r.StageName, Opportunity__r.Primary_Leasing_Contact__r.email ,
                Application_Complete_Second_Email_Date__c
            FROM 
                OpportunityRentalUnit__c 
            WHERE 
            (  Opportunity__r.Primary_Leasing_Contact__c != null 
                and Opportunity__r.Primary_Leasing_Contact__r.Email != null 
                and Primary_Leasing_Contact__r.HasOptedOutOfEmail = false 
                and Opportunity__r.StageName = 'Application Started'
                and Status__c = 'Application Started' 
                and Leasing__r.Status__c <> 'Inactive'
                and Leasing__r.Status__c <> 'Leased'
                and Application_Complete_Second_Email_Date__c = null 
                and DAY_ONLY(Application_Start_Date__c) = :twoDaysAgo
            ) 
        ];

        EmailTemplate emailTemplate2 = [Select name,Id,Subject,Description,HtmlValue,DeveloperName,Body 
                        from EmailTemplate where developername = 'Leasing_Application_Started_Second_Reminder'];
        // and Application_Reminder_First_Email_Date__c = null   
        //Application_Reminder_First_Email_Date__c
        if(orus2.size() > 0) {
            System.enqueueJob(new LeasingEmailsQueuable(orus2, emailTemplate2));
        }    
    //------ leasing application started third reminder 
    List<OpportunityRentalUnit__c> orus3 =  [
        SELECT  
            id , Status__c, Leasing__c, Application_Start_Date__c,
            Opportunity__r.ownerid,
            Opportunity__r.StageName, Opportunity__r.Primary_Leasing_Contact__r.email ,
            Application_Complete_Third_Email_Date__c
        FROM 
            OpportunityRentalUnit__c 
        WHERE 
        (  Opportunity__r.Primary_Leasing_Contact__c != null 
            and Opportunity__r.Primary_Leasing_Contact__r.Email != null 
            and Primary_Leasing_Contact__r.HasOptedOutOfEmail = false 
            and Opportunity__r.StageName = 'Application Started'
            and Status__c = 'Application Started' 
            and Leasing__r.Status__c <> 'Inactive'
            and Leasing__r.Status__c <> 'Leased'
            and Application_Complete_Third_Email_Date__c = null 
            and DAY_ONLY(Application_Start_Date__c) = :sevenDaysAgo
        ) 
    ];

        EmailTemplate emailTemplate3 = [Select name,Id,Subject,Description,HtmlValue,DeveloperName,Body 
                        from EmailTemplate where developername = 'Leasing_Application_Started_Third_Reminder'];
        // and Application_Reminder_First_Email_Date__c = null   
        //Application_Reminder_First_Email_Date__c
        if(orus3.size() > 0) {
            System.enqueueJob(new LeasingEmailsQueuable(orus3, emailTemplate3));
        }   
            
        Test.stopTest();
        
        // Validate that the job has run
        // by verifying that the record was created.
        // This query returns only the account created in test context by the 
        // Queueable class method.

    }
    public static testMethod void leasingEmailSchedulable(){
        Account a = new Account(Name = 'TestAccount');
        insert a;
        
        Contact con = new Contact();
        con.firstname = 'Test';
        con.lastname = 'Test';
        con.email= 'Test'+'@nowhere.com';
        con.HasOptedOutOfEmail =false;
        con.AccountId = a.Id;
        
        Opportunity o = new Opportunity();
        o.Name = 'test';
        o.StageName = 'Viewed';
        o.closeDate= System.today();
        insert o;
        
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
        p.Year_Built__c = '1972';
        p.name = '123 Main St Tracy CA 95391';
        insert p;
        
        Property_Unit__c pu = new Property_Unit__c();
        pu.name = '123 Main St Tracy CA 95391';
        pu.Property__c = p.id;
        pu.Bathrooms__c = 3;
        pu.Bedrooms__c = 2.5;
        pu.HomeCode__c = '1234';
        insert pu;
        
        Rental_Listing__c rl = new Rental_Listing__c();
        rl.Name='test';
        rl.Property_Unit__c = pu.Id;
        rl.Status__c ='Unspecified';
        insert rl;
        
        OpportunityRentalUnit__c ru = new OpportunityRentalUnit__c();
        ru.Opportunity__c = o.Id;
        ru.Name = 'Rental Unit';
        ru.Leasing__c = rl.Id;
        //ru.Primary_Leasing_Contact__c = cons[i].Id;
        insert ru;
       /* Opportunity_Rental_Unit_Activity__c orua = new Opportunity_Rental_Unit_Activity__c();
        orua.Activity_Name__c = 'SFDC';
        orua.Activity_Code__c = 'controlled_showing';
        orua.Opportunity_Rental_Unit__c = ru.Id;
        insert orua;*/
        
        List<OpportunityRentalUnit__c> oruList = new List<OpportunityRentalUnit__c>();
        oruList.add(ru);
        LeasingEmailsSchedulable les = new LeasingEmailsSchedulable();
        les.BatchRecordsForQueuing(oruList,null,1);
    }
}
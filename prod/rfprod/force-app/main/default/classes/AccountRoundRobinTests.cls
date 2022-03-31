@isTest()
public class AccountRoundRobinTests {

    static testMethod void myTest2() {
        
        // This code runs as the system user
        
        User u1;
        User u2;
        
        try{
            u1 = [select Id from User WHERE IsActive=True AND Profile.Name = 'System Administrator'  LIMIT 1];
            u2 = [select Id from User WHERE IsActive=True AND Profile.Name = 'System Administrator' and Id != : u1.Id LIMIT 1];
        } catch (QueryException qe){
            List<User> users = [SELECT Id, Profile.PermissionsModifyAllData FROM User WHERE IsActive = true LIMIT 1000];
            for(User u : users){
                if(u.Profile.PermissionsModifyAllData = true){
                    u1 = u;
                    break;
                }
            }
        }
        
        System.debug(u1);
        
        //*****Create Queue 
        
        Group testGroup = new Group ();
        testGroup.Name = 'Sales Team';
        testGroup.Type = 'Queue';
        insert testGroup;
        
        QueueSObject testQueue = new QueueSObject();
        testQueue.QueueId = testGroup.id;
        testQueue.SObjectType = 'Case';
        insert testQueue;
        
        
        
        System.runAs (u1) {
            test.starttest();
            
            u1.Assignment_Group_Active__c = true;
            update u1;
            
            //Run test
            
            //Create Assignment Group
            Assignment_Group_Name__c ag1 = new Assignment_Group_Name__c (Name='Sales Team', Type__c = 'Case');
            insert ag1;        
            
            //Add Good Queue to Assignment Group
            Assignment_Group_Queues__c agq1 = new Assignment_Group_Queues__c(name=testGroup.Name ,Assignment_Group_Name__c = ag1.id );
            insert agq1;
            
            //Add User to Assignment Groups Users
            Assignment_Groups__c agu1 = new Assignment_Groups__c (User__c = u1.id, Active__c='True', Group_Name__c = ag1.id, Last_Assignment__c = datetime.valueOf('2009-01-01 21:13:24') );
            insert agu1;
             TestDataFactory.insertHierarchyCustomSettingData();
            
            Account a1 = new Account(Name = 'TestAccount1' ,Bluebird__c = true, OwnerID=u2.id);
            Insert a1;
            
            
            Account a2 = new Account(Name = 'TestAccount2', OwnerID=u2.id);
            Insert a2;
            a2.Made_An_Offer_Date__c = System.now() - 1;
            Update a2;
            
            // Create a Lead and Convert to a Bluebird Account
            Lead ld = new Lead();
             ld.LastName = 'Test';
             ld.Status = 'No Appointment';
             ld.X1_Ideally_when_would_you_buy_your_first__c = system.today()+30;
             ld.Company = 'Test Company';
             ld.Lead_Interest__c = 'Buying Properties';
             ld.LeadSource = 'Roofstock Registered';
             ld.How_did_you_hear_about_Roofstock__c = 'Podcast';  
     		 ld.No_Convert_Reason__c = 'No Appointment';
        	 ld.How_much_are_you_looking_to_invest__c  ='100,000+';
             ld.OwnerId = u2.Id;
             insert ld; 
            
            // Update the Made an Offer Date field
            ld.Made_An_Offer_Date__c = System.now() - 1;
            update ld;
            
            // Convert the Lead
            //reset recursive flags here ,otherwise lead triggers won't fire again!
             checkRecursive.resetFlags();
     
       		 // Convert Lead record just created
             Database.LeadConvert lc = new database.LeadConvert();
             lc.setLeadId(ld.Id);
             lc.setOwnerId(u2.Id);
             //LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
             //lc.setConvertedStatus(convertStatus.MasterLabel);
             lc.setConvertedStatus('Appointment');
             Database.LeadConvertResult lcrList = Database.convertLead(lc);
          
       		// Make sure lead conversion was successful
             System.assert(lcrList.isSuccess());
       
       		// Fetch ID's from converted Lead record
            Lead ao = [Select convertedaccountid,convertedopportunityid from Lead Where id = :ld.id];  
                   
       		
            
            test.stoptest();
            
            // Checks
            Account a3 = [Select Id, Name, Bluebird__c, OwnerID from Account where Name =: 'TestAccount1'];
            System.debug('Account a1::::' +a3);
            System.debug('U1 User Id::::' +U1.Id);
            System.assertEquals(a3.OwnerId, u1.Id, 'Account Not getting assigned to User U1');
            
            a3 = [Select Id, Name, Bluebird__c, OwnerID from Account where Name =: 'TestAccount2'];
            System.debug('Account a2::::' +a3);
            System.debug('U1 User Id::::' +U1.Id);
            System.assertEquals(a3.OwnerId, u1.Id, 'Account Not getting assigned to User U1');
            System.assertEquals(a3.Bluebird__c, true, 'Bluebird Field on Account not set to true');
            
            // Check the Account created from Bluebird Lead
            a3 = [Select Id, Bluebird__c, OwnerID from Account Where Id = :ao.convertedaccountid];
            System.debug('Bluebird Lead Account :::' +a3);
            System.debug('U1 User Id::::' +U1.Id);
            System.assertEquals(a3.OwnerId, u1.Id, 'Account Not getting assigned to User U1');
            System.assertEquals(a3.Bluebird__c, true, 'Bluebird Field on Account not set to true');
        }
    }

}
@isTest
public class ContactTests {
    
    static{
        TestDataFactory.insertHierarchyCustomSettingData();
        TestDataFactory.createTestRentalListingRecords(1);
        
    }
    static testMethod void updateORU(){
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
      
            Contact c = [select Id,HasOptedOutOfEmail from Contact limit 1];
            c.HasOptedOutOfEmail = true;
            c.Made_An_Offer_Date__c = System.today();
            c.HS_Last_Email_Open_Date__c = System.today();
            c.HS_Time_of_Last_Visit__c = System.today();
            c.Phone = '9878766456';
            update c;
        }
    }
    static testMethod void ContactTriggerTestException() {
        TriggerDispatcher.forceException = true;
        try{
        Contact con = new Contact();
        con.LastName = 'Salesforce';
        insert con;
        }
        catch(Exception ex){
            
        }
        
    }
    
    
}
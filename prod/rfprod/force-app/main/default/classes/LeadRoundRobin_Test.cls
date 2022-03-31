@isTest()
public class LeadRoundRobin_Test {

    static testMethod void myTest2() {
        
        // This code runs as the system user
        
        User u1;
        
        try{
            u1 = [select Id from User WHERE IsActive=True AND Profile.Name = 'System Administrator'  LIMIT 1];
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
        testGroup.Name = 'TestQueue';
        testGroup.Type = 'Queue';
        insert testGroup;
        
        QueueSObject testQueue = new QueueSObject();
        testQueue.QueueId = testGroup.id;
        testQueue.SObjectType = 'Lead';
        insert testQueue;
        
        // Second Queue       
        Group testGroup2 = new Group ();
        testGroup2.Name = 'TestQueue2';
        testGroup2.Type = 'Queue';
        insert testGroup2;
        
        QueueSObject testQueue2 = new QueueSObject();
        testQueue2.QueueId = testGroup2.id;
        testQueue2.SObjectType = 'Lead';
        insert testQueue2;
        
        System.runAs ( u1 ) {
            test.starttest();
            
            u1.Assignment_Group_Active__c = true;
            update u1;
            
            //Run test
            
            //Create Assignment Group
            Assignment_Group_Name__c ag1 = new Assignment_Group_Name__c (Name='TestAG', Type__c = 'Lead');
            insert ag1;        
            
            //Add Good Queue to Assignment Group
            Assignment_Group_Queues__c agq1 = new Assignment_Group_Queues__c(name=testGroup.Name ,Assignment_Group_Name__c = ag1.id );
            insert agq1;
            
            //Add User to Assignment Groups Users
            Assignment_Groups__c agu1 = new Assignment_Groups__c (User__c = u1.id, Active__c='True', Group_Name__c = ag1.id, Last_Assignment__c = datetime.valueOf('2009-01-01 21:13:24') );
            insert agu1;
             TestDataFactory.insertHierarchyCustomSettingData();
            Lead c2 = new Lead (lastName='testLead1', company='self', tempOwnerID__c=testGroup2.id , OwnerID=testGroup.id); //Set owner ID to Queue
            insert c2;
            update c2;        
            
            Lead c3 = new Lead (lastName='testLead2', company='self', tempOwnerID__c=testGroup2.id , OwnerID=testGroup.id); //Set owner ID to Queue
            insert c3;
            update c3;        

            test.stoptest();
        }
    }

}
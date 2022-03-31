@isTest
public class JobTriggerTest {
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    
    @testSetup
    static void testData() {
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '72bcf440-899b-4fe4-b79f-9a14366fead';
        p.Property_Type__c = 'Single Family';
        p.name = '123 Main St Tracy CA 95391';
        p.City__c = 'CA';
        p.Street_Address__c ='CA';
        p.County__c ='US';
        p.Zip__c = '89876';
        p.State__c = 'CA';
        p.Square_Feet__c = '123';
        p.property_management_company__c = 'Streetlane Property Management';
        p.Client__c = System.Label.BPO_Starwood_property;
        p.Has_Pools__c = 'No';
        p.Gate_Code__c = '123';
        p.MailBox_Type__c = 'Community';
        insert p;
        
        Property_Unit__c pu = new Property_Unit__c();
        pu.name = '123 Main St Tracy CA 95391';
        pu.Property__c = p.Id;
        pu.Bathrooms__c = 3;
        pu.Bedrooms__c = 2.5;
        pu.HomeCode__c = 'q2000';
        pu.Occupancy_Status__c = 'Vacant Unrented Not Ready';
        pu.operating_reason__c = 'Leasable';
        pu.Operating_Status__c =  'Occupied No Notice'; 
        pu.Lockbox_Location__c = 'TEST';
        pu.Lockbox_Code__c = '2234';
        pu.Self_Showing_Lockbox__c = 'TEST';
        pu.Garbage_Disposal_Bin_Type__c = 'Community';
        pu.Is_Trash_Bin_available__c = 'Yes';
        pu.Trash_responsibility__c = 'City';
        pu.Is_Recycle_Bin_available__c = 'Yes';
        insert pu;
        
        ID turnRecordtypeId  = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Turn').getRecordTypeId();
        Id renovationRecordTypeId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Renovation').getRecordTypeId();
        List<Job__c> jobList = new List<Job__c>();
        
        Job__c jt = new Job__c();
        jt.Property_Unit__c = pu.Id;
        jt.Job_Status__c = 'Waiting for Move Out';
        jt.Property__c = p.Id;
        jt.recordtypeid = turnRecordtypeId;
        jt.name = '123 Main St Tracy CA 95391';
        jt.Job_Type__c = 'Turn';
        jobList.add(jt);
        
        jt = new Job__c();
        jt.Property_Unit__c = pu.Id;
        jt.Job_Status__c = 'Waiting for Move Out';
        jt.Property__c = p.Id;
        jt.recordtypeid = renovationRecordTypeId;
        jt.QC_Link__c = 'test';
        jobList.add(jt);
        
        insert jobList;

        Inspection__c dil = new Inspection__c();
        dil.Name = 'sfdc';
        dil.Property_Unit__c = pu.Id;
        dil.Job__c = jt.Id;
        insert dil;
		
        ContentVersion contentVersion = new ContentVersion(
          Title          = 'a picture',
          PathOnClient   = 'Pic.jpg',
          VersionData    = Blob.valueOf('Test Content'),
          IsMajorVersion = true);
        insert contentVersion; 
        
		List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink newcdl =  new ContentDocumentLink();
        newcdl.LinkedEntityId = dil.id;
        newcdl.ContentDocumentId = documents[0].Id;
        newcdl.shareType = 'V';
        insert newcdl;
        
    }
    
    Static testMethod void copyAttchmentFromInspectionTest() {
        
        test.startTest();
        Inspection__c dil2 = [Select id,name,Job__c from Inspection__c limit 1];
        List<Job__c> jtList = [Select id,name from Job__c where Id =:dil2.Job__c];
        JobHelper.copyNotesAndAttachments(jtList);
        test.stopTest();
       
    }
    
    Static testMethod void deleteJobTest() {
        test.startTest();
        Job__c jt1 = [Select id,name from Job__c Limit 1];
        delete jt1;
        test.stopTest();
        
    }

	Static testMethod void updateBPOPropertyTest() {
        test.startTest();
        Job__c jt1 = [Select id,name,Job_Status__c,Property__c from Job__c where recordtype.name = 'Renovation' and Job_Status__c = 'Waiting for Move Out' Limit 1];
        jt1.Job_Status__c = 'Job Completed';
        update jt1;
        test.stopTest();
        
    }
    
}
@isTest
public class TestingUtils {
    public static User ADMIN_USER {
        get {
            if(ADMIN_USER == null) {
                ADMIN_USER = [ SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1 ];
            }
            return ADMIN_USER;
        }
        private set;
    }

    public static Integer counter {
        get {
            if(counter == null) {
                counter = 0;
            }
            return counter++;
        }
        private set;
    }

    public static List<Property__c> createProperties(Integer size,Boolean doInsert) {
        List<Property__c> properties = new List<Property__c>();
        for(Integer i=0;i<size;i++) {
            Property__c property = new Property__c();
            properties.add(property);
        }
        if(doInsert) {
            insert properties;
        }
        return properties;
    }
    

    public static Property__c createProperty(Id geoCodeId, Boolean doInsert) {
        Fund_Owner__c fo = new Fund_Owner__c(Name = 'Test');
        insert fo;
        Property__c property = new Property__c();
        property.Name = String.valueOf(counter);
        //property.Fund__c= 'a006A00000Alcwg';
        property.Fund__c = fo.Id;
        property.Estimated_Resale__c = 100.00;
		property.Estimated_Rent__c = 100.00;
		property.Buyer__c = 'RS1 Trust'; // picklist
		property.List_Price__c = 100.00;
		property.Neighborhood_Score__c = '5'; // picklist
        if(doInsert) insert property;
        return property;
    }
    
    public static Attachment createAttachment(Id parentId, Boolean doInsert) {
        Attachment attachment = new Attachment();
        attachment.Name = 'test';
        attachment.ParentId = parentId;
        attachment.Body = Blob.valueOf('test');
        if(doInsert) {
            insert attachment;
        }
        return attachment;
    }
}
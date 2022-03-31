@isTest
public class RESTPropertyUnitControllerTest {
    private static Id leasingAccountRecordTypeId;
    private static Id leasingContactRecordTypeId;
    private static Id leasingOpportunityRecordTypeId;
    private static Id leasingLeadRecordTypeId;
    private static Id roofstockPropertyRecordTypeId;
    
    private static final string userAlias = 'SLUSER1';
    private static final string RB_LEASING = 'Leasing';
    
    //static initialization code (load test data)
    static {
        //create test users
        TestDataFactory.insertHierarchyCustomSettingData();
        TestDataFactory.createTestLeasingUserRecords(1);
        
        //load record type info
        leasingAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(RB_LEASING)
            .getRecordTypeId();
        leasingContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
            .get(RB_LEASING)
            .getRecordTypeId();
        leasingOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
            .get(RB_LEASING)
            .getRecordTypeId();
        leasingLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
            .get(RB_LEASING)
            .getRecordTypeId();
        roofstockPropertyRecordTypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByDeveloperName()
            .get('Roofstock')
            .getRecordTypeId();
    }
    
    static testMethod void createPropertyUnitRestAPITest() {
        Id objectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fund').getRecordTypeId();
        Account acc = new Account();
        acc.Name='sfdc';
        acc.Fund_ID__c = double.valueOf(1234.0);
        acc.RecordTypeId = objectRecordTypeId;
        insert acc;
        
        Fund_Owner__c fo = new Fund_Owner__c();
        fo.Name = 'sfdc';
        insert fo;
        
        Property__c p = new Property__c();
        p.RS_TransactionId__c = '1234';
        p.Yardi_Unit_Status__c = 'Down';
        p.Fund__c = fo.Id;
        p.Estimated_Resale__c = 100;
        p.List_Price__c = 100;
        p.Neighborhood_Score__c = '1';
        insert p;
        
        
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        System.debug('user' + u1);
        // String sReq = '{ "leasingActivityList": [ { "email": "dupe200@gmail.com", "firstName": "Dupe1", "lastName": "Dupe1", "phone": "2002002000", "activityType": "email", "activityId": "17047", "timeStamp": "2020-02-06T21:53:16.403Z", "timeZone": "Central Time (US & Canada)", "source": "RENTCafe.com ILS", "feedback":"Anamika is awesome developer!", "listingId": "13922" } ] }';
        List<RESTPropertyUnitHelper.PropertyWrapper> requestList = new List<RESTPropertyUnitHelper.PropertyWrapper>();
        RESTPropertyUnitHelper.PropertyWrapper property = new RESTPropertyUnitHelper.PropertyWrapper();
        RESTPropertyUnitHelper.PropertyUnitWrapper unit = new RESTPropertyUnitHelper.PropertyUnitWrapper();
        List<RESTPropertyUnitHelper.PropertyUnitWrapper> units = new List<RESTPropertyUnitHelper.PropertyUnitWrapper>();
        RESTPropertyUnitHelper.PropertyWrap oWrap = new RESTPropertyUnitHelper.PropertyWrap();
        unit.address = '123 main st';
        unit.unitNumber = '123';
        unit.unitId = '0000-00001-1979';
        unit.bathrooms = 1.5;
        unit.bedrooms = 3;
        unit.homeCode = 'q-19791';
        unit.rsTransactionid = '1234';
        units.add(unit);
        
        property.units = units;
        property.address = '123 main st';
        property.propertyCode = 'p-1979';
        property.propertyId = '0000-00000-1979';
        property.type = 'Single Family';
        //property.yearBuilt = 1972;
        property.listingChannel = 'Roofstock';
        
        property.sfrRegion = 'CA';
        property.city = 'CA';
        property.state = 'CA';
        property.client = 'CA';
        property.streetAddress = 'streetAddress';
        property.squareFeet = '10';
        property.fundId = 1234;
        property.inspectedSquareFeet ='10';
		property.bpmPropertyUrl='https:www.google.com';
		property.bpmOfferStatus = 'closed';
		property.bpmListingSource='sfdc';
		property.uwRehabCostOffer=10;
		property.uwRehabCostClose=10;
		property.oversightFee=10;
		property.propertyRecordType = 'Asset Management';
        property.IsHoa = true;
        property.IsBuildToRent  = true;
        property.bpmBuyer='sfdc';
        requestList.add(property);
        oWrap.propertyList = requestList; 
        String sReq = JSON.serialize(oWrap);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/AddLeasingPropertyUnit';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        
        System.runAs(u1) {
            Test.startTest();
            
            RESTPropertyUnitController.addPropertyUnit();
            Test.stopTest();
            req.requestBody = Blob.valueOf('');
            RESTPropertyUnitController.addPropertyUnit();
            
           // system.assertEquals(res.statusCode, 200); 
        }
    }
    static testMethod void createPropertyUnitRestAPITestWithoutFund() {
        Id objectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fund').getRecordTypeId();
        Account acc = new Account();
        acc.Name='sfdc';
        acc.Owner_Entity_ID__c = double.valueOf(120.0);
        acc.RecordTypeId = objectRecordTypeId;
        insert acc;
        
        
        
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        System.debug('user' + u1);
        // String sReq = '{ "leasingActivityList": [ { "email": "dupe200@gmail.com", "firstName": "Dupe1", "lastName": "Dupe1", "phone": "2002002000", "activityType": "email", "activityId": "17047", "timeStamp": "2020-02-06T21:53:16.403Z", "timeZone": "Central Time (US & Canada)", "source": "RENTCafe.com ILS", "feedback":"Anamika is awesome developer!", "listingId": "13922" } ] }';
        List<RESTPropertyUnitHelper.PropertyWrapper> requestList = new List<RESTPropertyUnitHelper.PropertyWrapper>();
        RESTPropertyUnitHelper.PropertyWrapper property = new RESTPropertyUnitHelper.PropertyWrapper();
        RESTPropertyUnitHelper.PropertyUnitWrapper unit = new RESTPropertyUnitHelper.PropertyUnitWrapper();
        List<RESTPropertyUnitHelper.PropertyUnitWrapper> units = new List<RESTPropertyUnitHelper.PropertyUnitWrapper>();
        RESTPropertyUnitHelper.PropertyWrap oWrap = new RESTPropertyUnitHelper.PropertyWrap();
        unit.address = '123 main st';
        unit.unitNumber = '123';
        unit.unitId = '0000-00001-1979';
        unit.bathrooms = 1.5;
        unit.bedrooms = 3;
        unit.homeCode = 'q-19791';
        unit.rsTransactionid = '1234';
        units.add(unit);
        
        property.units = units;
        property.address = '123 main st';
        property.propertyCode = 'p-1979';
        property.propertyId = '0000-00000-1979';
        property.type = 'Single Family';
        //property.yearBuilt = 1972;
        property.listingChannel = 'Roofstock';
        property.ownerEntityId = 120;
        property.sfrRegion = 'CA';
        property.city = 'CA';
        property.state = 'CA';
        property.client = 'CA';
        property.streetAddress = 'streetAddress';
        property.squareFeet = '10';
        property.inspectedSquareFeet ='10';
		property.bpmPropertyUrl='https:www.google.com';
		property.bpmOfferStatus = 'closed';
		property.bpmListingSource='sfdc';
		property.uwRehabCostOffer=10;
		property.uwRehabCostClose=10;
		property.oversightFee=10;
		property.propertyRecordType = 'Roofstock';
        property.IsHoa = true;
        property.IsBuildToRent  = true;
        property.bpmBuyer='sfdc';
        
        requestList.add(property);
        oWrap.propertyList = requestList; 
        String sReq = JSON.serialize(oWrap);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/AddLeasingPropertyUnit';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        
        System.runAs(u1) {
            Test.startTest();
            
            RESTPropertyUnitController.addPropertyUnit();
            Test.stopTest();
            req.requestBody = Blob.valueOf('');
            RESTPropertyUnitController.addPropertyUnit();
            
           // system.assertEquals(res.statusCode, 200); 
        }
    }
}
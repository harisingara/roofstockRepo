@isTest
public class RestPropertyUnitLimitedControllerTest {
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
        List<RestPropertyUnitLimitedHelper.PropertyWrapper> requestList = new List<RestPropertyUnitLimitedHelper.PropertyWrapper>();
        RestPropertyUnitLimitedHelper.PropertyWrapper property = new RestPropertyUnitLimitedHelper.PropertyWrapper();
        RestPropertyUnitLimitedHelper.PropertyUnitWrapper unit = new RestPropertyUnitLimitedHelper.PropertyUnitWrapper();
        List<RestPropertyUnitLimitedHelper.PropertyUnitWrapper> units = new List<RestPropertyUnitLimitedHelper.PropertyUnitWrapper>();
        RestPropertyUnitLimitedHelper.PropertyWrap oWrap = new RestPropertyUnitLimitedHelper.PropertyWrap();
        unit.address = '123 main st';
        unit.unitNumber = '123';
        unit.unitId = '0000-00001-1979';
        unit.bathrooms = 1.5;
        unit.bedrooms = 3;
        unit.homeCode = 'q-19791';
        //unit.rsTransactionid = '1234';
        unit.estRehabCost = 1345.23;
        unit.inspectedBedrooms = 3;
        unit.inspectedBathrooms = 1.5;
        unit.inspectedSquareFeet = '2000';
        unit.squareFeet = '2005';
        unit.estimatedCapexManual = 72;
        unit.estimatedRentUW = 1200;
        unit.isSection8 = true;
        unit.occupancy = 'Month to Month';
        unit.leaseStart = Date.today();
        unit.leaseEnd = Date.today().addYears(1);
        unit.securityDeposit = 500;
        unit.unitNumber = '11';
        unit.monthlyRent = 1200;
        unit.leasingBalance = 100;
        unit.leasingBalanceZeroTo30Days= 100;
        unit.leasingBalance30To60Days = 100;
        unit.leasingBalance60To90Days = 100;
        unit.leasingBalanceOver90Days = 100;
        unit.leasingBalanceDate = Date.today();
        unit.marketRent = 1100;
        
        unit.propertyAccessNotes = 'Test Notes';
        unit.propertyAccessMethodType = 'Test Access Method';
        
        units.add(unit);
        
        property.units = units;
        property.address = '123 main st';
        property.propertyCode = 'p-1979';
        property.propertyId = '0000-00000-1979';
        property.type = 'Single Family';
        //property.yearBuilt = 1972;
       
        property.city = 'CA';
        property.state = 'CA';
        property.streetAddress = 'streetAddress';
        property.squareFeet = '10';
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
        
        property.lotSize = '1500';
        property.hasPool = false;
        property.neighborhoodScore = '4';
        property.elementarySchoolScore = '4';
        property.middleSchoolScore= '4';
        property.highSchoolScore='4';
        property.inFloodZone = false;
        property.monthlyHOAFee =50;
        property.listPrice = 300000;
        property.yearlyInsurance = 1000;
        property.yearlyPropertyTaxes =1000;
        property.monthlyRent = 1200;
        property.marketRent= 1100;
        property.collateralAnalyticsLowValue =1200;
        property.collateralAnalyticsMidValue = 1300;
        property.collateralAnalyticsHighValue = 1400;
        property.collateralAnalyticsAvmRunDate = Date.today();
        property.zillowLowValue = 250000;
        property.zillowMidValue =280000;
        property.zillowHighValue =320000;
        property.zillowRentLowValue = 1100;
        property.zillowRentMidValue=1200;
        property.zillowRentHighValue=1300;
        property.zillowAvmRunDate = Date.today();
        
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
            
            RestPropertyUnitLimitedController.addPropertyUnit();
            Test.stopTest();
            req.requestBody = Blob.valueOf('');
            RestPropertyUnitLimitedController.addPropertyUnit();
            
           // system.assertEquals(res.statusCode, 200); 
        }
    }
    static testMethod void createPropertyUnitRestAPITestWithoutValues() {
        Id objectRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fund').getRecordTypeId();
        Account acc = new Account();
        acc.Name='sfdc';
        acc.Owner_Entity_ID__c = double.valueOf(120.0);
        acc.RecordTypeId = objectRecordTypeId;
        insert acc;
        
        
        
        User u1 = [SELECT Id, profile.name FROM User LIMIT 1];
        System.debug('user' + u1);
        // String sReq = '{ "leasingActivityList": [ { "email": "dupe200@gmail.com", "firstName": "Dupe1", "lastName": "Dupe1", "phone": "2002002000", "activityType": "email", "activityId": "17047", "timeStamp": "2020-02-06T21:53:16.403Z", "timeZone": "Central Time (US & Canada)", "source": "RENTCafe.com ILS", "feedback":"Anamika is awesome developer!", "listingId": "13922" } ] }';
        List<RestPropertyUnitLimitedHelper.PropertyWrapper> requestList = new List<RestPropertyUnitLimitedHelper.PropertyWrapper>();
        RestPropertyUnitLimitedHelper.PropertyWrapper property = new RestPropertyUnitLimitedHelper.PropertyWrapper();
        RestPropertyUnitLimitedHelper.PropertyUnitWrapper unit = new RestPropertyUnitLimitedHelper.PropertyUnitWrapper();
        List<RestPropertyUnitLimitedHelper.PropertyUnitWrapper> units = new List<RestPropertyUnitLimitedHelper.PropertyUnitWrapper>();
        RestPropertyUnitLimitedHelper.PropertyWrap oWrap = new RestPropertyUnitLimitedHelper.PropertyWrap();
        unit.address = '123 main st';
        unit.unitNumber = '123';
        unit.unitId = '0000-00001-1979';
        unit.bathrooms = Decimal.valueof(Label.Blank_Decimal_Value);
        unit.bedrooms = Decimal.valueof(Label.Blank_Decimal_Value);
        unit.homeCode = 'q-19791';
        unit.estRehabCost = Decimal.valueof(Label.Blank_Decimal_Value);
        unit.inspectedBedrooms = 3;
        unit.inspectedBathrooms = Decimal.valueof(Label.Blank_Decimal_Value);
        unit.inspectedSquareFeet = Label.Blank_String_Value;
        unit.squareFeet = Label.Blank_String_Value;
        unit.estimatedCapexManual = Decimal.valueof(Label.Blank_Decimal_Value);
        unit.estimatedRentUW = Decimal.valueof(Label.Blank_Decimal_Value);
        unit.isSection8 = true;
        unit.occupancy = Label.Blank_String_Value;
        unit.leaseStart = Date.parse(Label.Blank_Date_Value);
        unit.leaseEnd = Date.parse(Label.Blank_Date_Value);
        unit.securityDeposit = Decimal.valueof(Label.Blank_Decimal_Value);
        unit.unitNumber = '11';
        unit.monthlyRent = Decimal.valueof(Label.Blank_Decimal_Value);
        unit.leasingBalance = Decimal.valueof(Label.Blank_Decimal_Value);
        unit.leasingBalanceZeroTo30Days= Decimal.valueof(Label.Blank_Decimal_Value);
        unit.leasingBalance30To60Days = Decimal.valueof(Label.Blank_Decimal_Value);
        unit.leasingBalance60To90Days = Decimal.valueof(Label.Blank_Decimal_Value);
        unit.leasingBalanceOver90Days = Decimal.valueof(Label.Blank_Decimal_Value);
        unit.leasingBalanceDate = Date.parse(Label.Blank_Date_Value);
        unit.marketRent = Decimal.valueof(Label.Blank_Decimal_Value);
        
        units.add(unit);
        
        property.units = units;
        property.address = '123 main st';
        property.propertyCode = 'p-1979';
        property.propertyId = '0000-00000-1979';
        property.type = 'Single Family';
        //property.yearBuilt = 1972;
        property.city = Label.Blank_String_Value;
        property.state = Label.Blank_String_Value;
        property.streetAddress = 'streetAddress';
        property.squareFeet = Label.Blank_String_Value;
        property.inspectedSquareFeet =Label.Blank_String_Value;
        property.bpmPropertyUrl='https:www.google.com';
        property.bpmOfferStatus = Label.Blank_String_Value;
        property.bpmListingSource= Label.Blank_String_Value;
        property.uwRehabCostOffer=Decimal.valueof(Label.Blank_Decimal_Value);
        property.uwRehabCostClose=Decimal.valueof(Label.Blank_Decimal_Value);
        property.oversightFee=Decimal.valueof(Label.Blank_Decimal_Value);
        property.propertyRecordType = 'Roofstock';
        property.IsHoa = true;
        property.IsBuildToRent  = true;
        
        property.lotSize = '1500';
        property.hasPool = false;
        property.neighborhoodScore = Label.Blank_String_Value;
        property.elementarySchoolScore = Label.Blank_String_Value;
        property.middleSchoolScore= Label.Blank_String_Value;
        property.highSchoolScore= Label.Blank_String_Value;
        property.inFloodZone = false;
        property.monthlyHOAFee =Decimal.valueof(Label.Blank_Decimal_Value);
        property.listPrice = Decimal.valueof(Label.Blank_Decimal_Value);
        property.yearlyInsurance = Decimal.valueof(Label.Blank_Decimal_Value);
        property.yearlyPropertyTaxes =Decimal.valueof(Label.Blank_Decimal_Value);
        property.monthlyRent = Decimal.valueof(Label.Blank_Decimal_Value);
        property.marketRent= Decimal.valueof(Label.Blank_Decimal_Value);
        property.collateralAnalyticsLowValue =Decimal.valueof(Label.Blank_Decimal_Value);
        property.collateralAnalyticsMidValue = Decimal.valueof(Label.Blank_Decimal_Value);
        property.collateralAnalyticsHighValue = Decimal.valueof(Label.Blank_Decimal_Value);
        property.collateralAnalyticsAvmRunDate = Date.today();
        property.zillowLowValue = Decimal.valueof(Label.Blank_Decimal_Value);
        property.zillowMidValue =Decimal.valueof(Label.Blank_Decimal_Value);
        property.zillowHighValue =Decimal.valueof(Label.Blank_Decimal_Value);
        property.zillowRentLowValue = Decimal.valueof(Label.Blank_Decimal_Value);
        property.zillowRentMidValue=Decimal.valueof(Label.Blank_Decimal_Value);
        property.zillowRentHighValue=Decimal.valueof(Label.Blank_Decimal_Value);
        property.zillowAvmRunDate = Date.today();
        property.offerPrice= -2147483648.0;
        property.sellerEntity ='^';
        property.zip='^';
        property.county ='^';
        property.market='^';
        property.ZillowValueEstimate= -2147483648.0;
        property.zillowRentEstimate= -2147483648.0;
        property.zillowRentAVMRunDate=date.parse('01/01/1800');
        property.FloodZone='^';
        property.rentRangeLow= -2147483648.0;
        property.RentRangeRentEstimate= -2147483648.0;
        property.RentRangeHigh= -2147483648.0;
        property.rentRangeRunDate =date.parse('01/01/1800');
        property.bedrooms=-2147483648.0;
        property.bathrooms =-2147483648.0;
        property.bpoValuationDate=date.parse('01/01/1800');
        property.leaseStartDate=date.parse('01/01/1800');
        property.leaseEndDate=date.parse('01/01/1800');
        property.bpoValuation=-2147483648.0;
        property.previousYearTaxes=-2147483648.0;
        property.insuranceEstimate=-2147483648.0;
        property.counterOffer=-2147483648.0; 
        property.legalDescription='^';
        property.occupancy='^';
        property.apn='^';
        property.sellerProvidedSecurityDeposit=-2147483648.0;
        
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
            
            RestPropertyUnitLimitedController.addPropertyUnit();
            Test.stopTest();
            req.requestBody = Blob.valueOf('');
            RestPropertyUnitLimitedController.addPropertyUnit();
            
           // system.assertEquals(res.statusCode, 200); 
        }
    }
}
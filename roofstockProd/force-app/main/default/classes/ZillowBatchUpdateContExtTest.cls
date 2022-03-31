@isTest
private class ZillowBatchUpdateContExtTest {
    static Property__c property;
    static ZillowBatchUpdateContExt contExt;
    static{
                TestDataFactory.insertHierarchyCustomSettingData();  

    }
    static void setup() {
        property = TestingUtils.createProperty(null, false);
        property.Name = ZillowHttpCalloutMock.PROPERTY_NAME;
        property.Zipcode__c = ZillowHttpCalloutMock.ZIP;
        insert property;
        contExt = new ZillowBatchUpdateContExt(new ApexPages.StandardController(property));
    }

    static testMethod void constructUrl() {
        setup();

        Map<String, String> urlParamsMap = new Map<String, String>{
            ZillowUpdateContExt.ADDRESS_PARAM => property.Name,
            ZillowUpdateContExt.CITY_STATE_ZIP_PARAM => property.Zipcode__c
        };

        Test.startTest();
            String actualUrl = contExt.constructUrl(ZillowUpdateContExt.GET_DEEP_SEARCH_RESULTS_URL, urlParamsMap);
        Test.stopTest();

        Set<String> expectedParamsAndValues = new Set<String>{
            ZillowUpdateContExt.ADDRESS_PARAM + EncodingUtil.urlEncode(property.Name, 'UTF-8'),
            ZillowUpdateContExt.CITY_STATE_ZIP_PARAM + EncodingUtil.urlEncode(property.Zipcode__c, 'UTF-8'),
            ZillowHttpCalloutMock.ZWS_ID_PARAM + EncodingUtil.urlEncode(ZillowUpdateContExt.ZWS_ID, 'UTF-8')
        };

        List<String> expectedBaseUrlAndParams = ZillowUpdateContExt.GET_DEEP_SEARCH_RESULTS_URL.split('\\?');
        List<String> actualBaseUrlAndParams = actualUrl.split('\\?');
        Set<String> actualParamsAndValues = new Set<String>(actualBaseUrlAndParams[1].split('&'));

        System.assertEquals(expectedBaseUrlAndParams[0], actualBaseUrlAndParams[0], 'the endpoint should have the correct base url');
        System.assertEquals(expectedParamsAndValues, actualParamsAndValues, 'The endpoint should have the correct params and values');
    }

    static testMethod void setFieldsOnProperty() {
        setup();
        Test.setMock(HttpCalloutMock.class, new ZillowHttpCalloutMock());

        Test.startTest();
        
            List<Property__c> props = new List <Property__c>();
            props.add(property);

            contExt.setFieldsOnProperty(property, props);
        Test.stopTest();

        System.assert(!ApexPages.hasMessages(), 'There should be no messages on the page');
        System.assertEquals(ZillowHttpCalloutMock.ZESTIMATE, contExt.property.Zestimate__c, 'The zestimate should be set correctly');
        System.assertEquals(ZillowHttpCalloutMock.ZILLOW_PROPERTY_URL, contExt.property.Zillow_Property_URL__c, 'The zillow property url should be set correctly');
        System.assertEquals(ZillowHttpCalloutMock.RENT_ZESTIMATE, contExt.property.Rent_Zestimate__c, 'The rent zestimate should be set correctly');
        System.assertEquals(ZillowHttpCalloutMock.ZPID, contExt.zpid, 'The zpid should be set correctly');
        System.assertEquals(ZillowHttpCalloutMock.SUCCESS_MESSAGE, contExt.errorMessage, 'The error message should be set correctly');
        System.assertEquals(ZillowHttpCalloutMock.SUCCESS_CODE, contExt.errorCode, 'The error code should be set correctly');
    }

    static testMethod void setFieldsOnProperty_MissingNode() {
        setup();
        Test.setMock(HttpCalloutMock.class, new ZillowHttpCalloutMock.MissingNode_GetDeepSearchResults());

        Test.startTest();
            
        
            List<Property__c> props = new List <Property__c>();
            props.add(property);
        
            contExt.setFieldsOnProperty(property, props);
        Test.stopTest();

        System.assert(!ApexPages.hasMessages(), 'There should be no messages on the page');
        System.assertEquals(ZillowHttpCalloutMock.ZESTIMATE, contExt.property.Zestimate__c, 'The zestimate should be set correctly');
        System.assertEquals(ZillowHttpCalloutMock.ZILLOW_PROPERTY_URL, contExt.property.Zillow_Property_URL__c, 'The zillow property url should be set correctly');
        System.assertEquals(null, contExt.property.Rent_Zestimate__c, 'The rent zestimate should be set correctly');
        System.assertEquals(ZillowHttpCalloutMock.ZPID, contExt.zpid, 'The zpid should be set correctly');
        System.assertEquals(ZillowHttpCalloutMock.SUCCESS_MESSAGE, contExt.errorMessage, 'The error message should be set correctly');
        System.assertEquals(ZillowHttpCalloutMock.SUCCESS_CODE, contExt.errorCode, 'The error code should be set correctly');
    }

    static testMethod void setFieldsOnProperty_Error() {
        setup();
        Test.setMock(HttpCalloutMock.class, new ZillowHttpCalloutMock.ErrorPropertyNotFound_GetDeepSearchResults());

        Test.startTest();
        
            List<Property__c> props = new List <Property__c>();
            props.add(property);
        
            contExt.setFieldsOnProperty(property, props);
        Test.stopTest();

        System.assertEquals(null, contExt.property.Zestimate__c, 'The zestimate should be set correctly');
        System.assertEquals(null, contExt.property.Zillow_Property_URL__c, 'The zillow property url should be set correctly');
        System.assertEquals(null, contExt.property.Rent_Zestimate__c, 'The rent zestimate should be set correctly');
        System.assertEquals(null, contExt.zpid, 'The zpid should be set correctly');
        System.assertEquals(ZillowHttpCalloutMock.ERROR_MESSAGE_GET_DEEP_SEARCH_RESULTS, contExt.errorMessage, 'The error message should be set correctly');
        System.assertEquals(ZillowHttpCalloutMock.ERROR_CODE_GET_DEEP_SEARCH_RESULTS, contExt.errorCode, 'The error code should be set correctly');
        System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR), 'There should be an error message on the page');
        System.assertEquals(ZillowHttpCalloutMock.ERROR_MESSAGE_GET_DEEP_SEARCH_RESULTS, ApexPages.getMessages()[0].getSummary(), 'The message should match the label');
    }

    static testMethod void setFieldsOnProperty_ErrorCodeGreaterThan399() {
        setup();
        Test.setMock(HttpCalloutMock.class, new ZillowHttpCalloutMock.ErrorCodeGreaterThan399());

        Test.startTest();
        
            List<Property__c> props = new List <Property__c>();
            props.add(property);
        
            contExt.setFieldsOnProperty(property, props);
        Test.stopTest();

        String expectedErrorMessage = ZillowUpdateContExt.ERROR_ZILLOW_OFFLINE + ' ' + ZillowHttpCalloutMock.BAD_REQUEST + ' ' + ZillowHttpCalloutMock.ERROR_CODE_RESPONSE;

        System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR), 'There should be an error message on the page');
        System.assertEquals(expectedErrorMessage, ApexPages.getMessages()[0].getSummary(), 'The message should match the label');
        System.assertEquals(null, contExt.property.Zestimate__c, 'The zestimate should be set correctly');
        System.assertEquals(null, contExt.property.Zillow_Property_URL__c, 'The zillow property url should be set correctly');
        System.assertEquals(null, contExt.property.Rent_Zestimate__c, 'The rent zestimate should be set correctly');
        System.assertEquals(null, contExt.zpid, 'The zpid should be set correctly');
    }

    static testMethod void getImages() {
        setup();
        contExt.zpid = ZillowHttpCalloutMock.ZPID;
        Test.setMock(HttpCalloutMock.class, new ZillowHttpCalloutMock.GetUpdatedPropertyDetails());

        Test.startTest();
        
            List<Property__c> props = new List <Property__c>();
            props.add(property);
        
            contExt.getImages(property, props);
        Test.stopTest();

        System.assert(!ApexPages.hasMessages(), 'There should be no messages on the page');
        System.assertEquals(ZillowHttpCalloutMock.imageUrls.split(',')[0], contExt.property.Photo_Small_URL__c, 'The image urls should be set correctly');
        System.assertEquals(ZillowHttpCalloutMock.SUCCESS_MESSAGE, contExt.errorMessage, 'The error message should be set correctly');
        System.assertEquals(ZillowHttpCalloutMock.SUCCESS_CODE, contExt.errorCode, 'The error code should be set correctly');
    }

    static testMethod void getImages_MissingNode() {
        setup();
        contExt.zpid = ZillowHttpCalloutMock.ZPID;
        Test.setMock(HttpCalloutMock.class, new ZillowHttpCalloutMock.MissingNode_GetUpdatedPropertyDetails());

        Test.startTest();
        
            List<Property__c> props = new List <Property__c>();
            props.add(property);
        
            contExt.getImages(property, props);
        Test.stopTest();

        System.assert(!ApexPages.hasMessages(), 'There should be no messages on the page');
        System.assertEquals(null, contExt.property.Photo_Small_URL__c, 'The image urls should be set correctly');
        System.assertEquals(ZillowHttpCalloutMock.SUCCESS_MESSAGE, contExt.errorMessage, 'The error message should be set correctly');
        System.assertEquals(ZillowHttpCalloutMock.SUCCESS_CODE, contExt.errorCode, 'The error code should be set correctly');
    }

    static testMethod void getImages_Error() {
        setup();
        contExt.zpid = ZillowHttpCalloutMock.ZPID;
        Test.setMock(HttpCalloutMock.class, new ZillowHttpCalloutMock.ErrorPropertyNotFound_GetUpdatedPropertyDetails());

        Test.startTest();
        
            List<Property__c> props = new List <Property__c>();
            props.add(property);
        
            contExt.getImages(property, props);
        Test.stopTest();

        System.assertEquals(null, contExt.property.Photo_Small_URL__c, 'The image urls should be set correctly');
        System.assertEquals(ZillowHttpCalloutMock.ERROR_MESSAGE_GET_UPDATED_PROPERTY_DETAILS, contExt.errorMessage, 'The error message should be set correctly');
        System.assertEquals(ZillowHttpCalloutMock.ERROR_CODE_GET_UPDATED_PROPERTY_DETAILS, contExt.errorCode, 'The error code should be set correctly');
        System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR), 'There should be an error message on the page');
        System.assertEquals(ZillowHttpCalloutMock.ERROR_MESSAGE_GET_UPDATED_PROPERTY_DETAILS, ApexPages.getMessages()[0].getSummary(), 'The message should match the label');
    }

    static testMethod void getImages_ErrorCodeGreaterThan399() {
        setup();
        contExt.zpid = ZillowHttpCalloutMock.ZPID;
        Test.setMock(HttpCalloutMock.class, new ZillowHttpCalloutMock.ErrorCodeGreaterThan399());

        Test.startTest();
        
            List<Property__c> props = new List <Property__c>();
            props.add(property);
        
            contExt.getImages(property, props);
        Test.stopTest();

        String expectedErrorMessage = ZillowUpdateContExt.ERROR_ZILLOW_OFFLINE + ' ' + ZillowHttpCalloutMock.BAD_REQUEST + ' ' + ZillowHttpCalloutMock.ERROR_CODE_RESPONSE;

        System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR), 'There should be an error message on the page');
        System.assertEquals(expectedErrorMessage, ApexPages.getMessages()[0].getSummary(), 'The message should match the label');
        System.assertEquals(null, contExt.property.Photo_Small_URL__c, 'The image urls should be set correctly');
    }

    
    /*static testMethod void updatePropertybutton() {
           
            Fund_Owner__c f = new Fund_Owner__c (Name='MyFund');
            insert f;
            
            Property__c p = new Property__c (Name='MyProperty'); 
            p.Fund__c = f.Id;
            p.Neighborhood_Score__c = '2';
            p.Buyer__c = 'Starwood';
            p.List_Price__c = 12345;
            p.Estimated_Rent__c = 1234;
            p.Estimated_Resale__c = 1234;
            p.City__c = 'San Francisco';
            p.State__c = 'CA';
            p.Zipcode__c = '94109';
            p.Zestimate__c = 1234;
            p.Rent_Zestimate__c = 1234;
            p.Zillow_Assess_Value__c = 12345;
            p.Photo_Small_URL__c = 'www.google.com';
            p.Zillow_Property_URL__c = 'www.google.com';
            insert p;
        
            List<Property__c> props = new List <Property__c>();
            props.add(p);
            
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(p);
            sc.setSelected();
            ZillowBatchUpdateContExt controller = new ZillowBatchUpdateContExt(sc);
           
            Pagereference p1 = controller.updateProperty();   
            Test.stopTest();

        
        
    }
    
    
    
    static testMethod void updateProperty_setFieldsOnProperty() {
        setup();
        Test.setMock(HttpCalloutMock.class, new ZillowHttpCalloutMock.GetDeepSearchResults_NoEndpointAssertions());

        Test.startTest();
            PageReference actualPageRef = contExt.updateProperty();
        Test.stopTest();

        PageReference expectedPageRef = new PageReference('/' + property.Id);

        System.assert(!ApexPages.hasMessages(), 'There should be no messages on the page');
        System.assertEquals(expectedPageRef.getUrl(), actualPageRef.getUrl(), 'The page should go to the correct page');
        Property__c actualProperty = [SELECT Zestimate__c, Zillow_Property_URL__c, Rent_Zestimate__c, Photo_Small_URL__c FROM Property__c WHERE Id = :property.Id];
        System.assertEquals(ZillowHttpCalloutMock.ZESTIMATE, actualProperty.Zestimate__c, 'The zestimate should be set correctly');
        System.assertEquals(ZillowHttpCalloutMock.RENT_ZESTIMATE, actualProperty.Rent_Zestimate__c, 'The rent zestimate should be set correctly');
        System.assertEquals(ZillowHttpCalloutMock.ZILLOW_PROPERTY_URL, actualProperty.Zillow_Property_URL__c, 'The zillow property url should be set correctly');
        System.assertEquals(null, actualProperty.Photo_Small_URL__c, 'The image urls should be set correctly');
    }

    static testMethod void updateProperty_getImages() {
        setup();
        contExt.zpid = ZillowHttpCalloutMock.ZPID;
        Test.setMock(HttpCalloutMock.class, new ZillowHttpCalloutMock.GetUpdatedPropertyDetails_NoEndpointAssertions());

        Test.startTest();
            PageReference actualPageRef = contExt.updateProperty();
        Test.stopTest();

        PageReference expectedPageRef = new PageReference('/' + property.Id);

        System.assert(!ApexPages.hasMessages(), 'There should be no messages on the page');
        System.assertEquals(expectedPageRef.getUrl(), actualPageRef.getUrl(), 'The page should go to the correct page');
        Property__c actualProperty = [SELECT Zestimate__c, Zillow_Property_URL__c, Rent_Zestimate__c, Photo_Small_URL__c FROM Property__c WHERE Id = :property.Id];
        System.assertEquals(null, actualProperty.Zestimate__c, 'The zestimate should be set correctly');
        System.assertEquals(null, actualProperty.Rent_Zestimate__c, 'The rent zestimate should be set correctly');
        System.assertEquals(null, actualProperty.Zillow_Property_URL__c, 'The zillow property url should be set correctly');
        System.assertEquals(ZillowHttpCalloutMock.imageUrls, actualProperty.Photo_Small_URL__c, 'The image urls should be set correctly');
    }

    static testMethod void updateProperty_ErrorPropertyNotFound() {
        setup();
        Test.setMock(HttpCalloutMock.class, new ZillowHttpCalloutMock.ErrorPropertyNotFound_GetDeepSearchResults());

        Test.startTest();
            PageReference actualPageRef = contExt.updateProperty();
        Test.stopTest();

        System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR), 'There should be an error message on the page');
        System.assertEquals(ZillowHttpCalloutMock.ERROR_MESSAGE_GET_DEEP_SEARCH_RESULTS, ApexPages.getMessages()[0].getSummary(), 'The message should match the label');
        System.assertEquals(null, actualPageRef, 'The page should not redirect');
        Property__c actualProperty = [SELECT Zestimate__c, Zillow_Property_URL__c, Rent_Zestimate__c, Photo_Small_URL__c FROM Property__c WHERE Id = :property.Id];
        System.assertEquals(null, actualProperty.Zestimate__c, 'The zestimate should be set correctly');
        System.assertEquals(null, actualProperty.Rent_Zestimate__c, 'The rent zestimate should be set correctly');
        System.assertEquals(null, actualProperty.Zillow_Property_URL__c, 'The zillow property url should be set correctly');
        System.assertEquals(null, actualProperty.Photo_Small_URL__c, 'The image urls should be set correctly');
    }

    static testMethod void updateProperty_ErrorCodeGreaterThan399() {
        setup();
        Test.setMock(HttpCalloutMock.class, new ZillowHttpCalloutMock.ErrorCodeGreaterThan399());

        Test.startTest();
            PageReference actualPageRef = contExt.updateProperty();
        Test.stopTest();

        String expectedErrorMessage = ZillowUpdateContExt.ERROR_ZILLOW_OFFLINE + ' ' + ZillowHttpCalloutMock.BAD_REQUEST + ' ' + ZillowHttpCalloutMock.ERROR_CODE_RESPONSE;

        System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR), 'There should be an error message on the page');
        System.assertEquals(expectedErrorMessage, ApexPages.getMessages()[0].getSummary(), 'The message should match the label');
        System.assertEquals(null, actualPageRef, 'The page should not redirect');
        Property__c actualProperty = [SELECT Zestimate__c, Zillow_Property_URL__c, Rent_Zestimate__c, Photo_Small_URL__c FROM Property__c WHERE Id = :property.Id];
        System.assertEquals(null, actualProperty.Zestimate__c, 'The zestimate should be set correctly');
        System.assertEquals(null, actualProperty.Rent_Zestimate__c, 'The rent zestimate should be set correctly');
        System.assertEquals(null, actualProperty.Zillow_Property_URL__c, 'The zillow property url should be set correctly');
        System.assertEquals(null, actualProperty.Photo_Small_URL__c, 'The image urls should be set correctly');
    }

    static testMethod void updateProperty_DmlException() {
        setup();
        Test.setMock(HttpCalloutMock.class, new ZillowHttpCalloutMock.GetDeepSearchResults_NoEndpointAssertions());

        Test.startTest();
            contExt.property.Id = null;
            PageReference actualPageRef = contExt.updateProperty();
        Test.stopTest();

        System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR), 'There should be an error message on the page');
        System.assertEquals('Id not specified in an update call', ApexPages.getMessages()[0].getSummary(), 'The message should be the correct error');
        System.assertEquals(null, actualPageRef, 'The page should not redirect');
        Property__c actualProperty = [SELECT Zestimate__c, Zillow_Property_URL__c, Rent_Zestimate__c, Photo_Small_URL__c FROM Property__c WHERE Id = :property.Id];
        System.assertEquals(null, actualProperty.Zestimate__c, 'The zestimate should be set correctly');
        System.assertEquals(null, actualProperty.Rent_Zestimate__c, 'The rent zestimate should be set correctly');
        System.assertEquals(null, actualProperty.Zillow_Property_URL__c, 'The zillow property url should be set correctly');
        System.assertEquals(null, actualProperty.Photo_Small_URL__c, 'The image urls should be set correctly');
    }*/
}
public with sharing class ZillowBatchUpdateContExt {
    public static final String ZWS_ID = 'X1-ZWz1aaskikdki3_9vdv4';
    public static final String GET_DEEP_SEARCH_RESULTS_URL = 'http://www.zillow.com/webservice/GetDeepSearchResults.htm?zws-id=' + ZWS_ID + '&';
    public static final String GET_UPDATED_PROPERTY_DETAILS_URL = 'http://www.zillow.com/webservice/GetUpdatedPropertyDetails.htm?zws-id=' + ZWS_ID + '&';
    public static final String ERROR_ZILLOW_OFFLINE = 'Zillow offline';
    public static final String ADDRESS_PARAM = 'address=';
    public static final String CITY_STATE_ZIP_PARAM = 'citystatezip=';
    public static final String ZPID_PARAM = 'zpid=';
    public static final String RENT_ZESTIMATE_PARAM = 'rentzestimate=';

    @TestVisible
    public Property__c property {
        get; private set;
    }

    @TestVisible private String zpid;
    @TestVisible private String errorCode;
    @TestVisible private String errorMessage;

    public ZillowBatchUpdateContExt(ApexPages.StandardController stdCont) {
        property = [SELECT Name, City__c, State__c, Zipcode__c, Zestimate__c, Rent_Zestimate__c, Zillow_Assess_Value__c, Photo_Small_URL__c , Zillow_Property_URL__c FROM Property__c WHERE Id = :stdCont.getId()];
    }

    @TestVisible
    private String constructUrl(String baseUrl, Map<String, String> urlParamsMap) {
        List<String> paramsAndValues = new List<String>();
        for(String urlParam : urlParamsMap.keySet()) {
            paramsAndValues.add(urlParam + EncodingUtil.urlEncode(urlParamsMap.get(urlParam), 'UTF-8'));
        }

        return baseUrl + String.join(paramsAndValues, '&');
    }

    private HttpResponse getResponseFromZillow(String baseUrl, Map<String, String> urlParamsMap) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(constructUrl(baseUrl, urlParamsMap));
        req.setMethod('GET');
        Http http = new Http();
        return http.send(req);
    }

    private void processErrors() {
        if(Integer.valueOf(errorCode) > 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        }
    }
    
    private ApexPages.StandardSetController standardController;

    public ZillowBatchUpdateContExt(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
    }

    public PageReference updateProperty() {
    
        List<Property__c> selectedProperties = (List<Property__c>) standardController.getSelected();
        List<Property__c> soqlprop = new List<Property__c>();
        List<Property__c> props    = new List <Property__c>();
        List<Property__c> images   = new List <Property__c>();
        
        Set<Id> records = new Set<Id>{};
        
        for(Property__c ppt : selectedProperties ){
            records.add(ppt.Id);
        }
        
        soqlprop = [SELECT Name, City__c, State__c, Zipcode__c, Zestimate__c, Rent_Zestimate__c, Zillow_Assess_Value__c, Photo_Small_URL__c , Zillow_Property_URL__c FROM Property__c WHERE Id IN: records];
       
        for(Property__c selectedProperty : soqlprop)
        { 
            props  = setFieldsOnProperty(selectedProperty, props);
            images = getImages(selectedProperty, images);
            //getImages();
            
            system.debug('WIN');
            
        }
        update props;
        update images;
        
        //return null;
        PageReference pageRef = new PageReference('https://roofstock.lightning.force.com/lightning/o/Property__c/list?filterName=00B4v00000ANB5P'); 
        pageRef.setRedirect(true);
        return  pageRef;
    }

    @TestVisible
    private list<Property__c> setFieldsOnProperty(Property__c p, list<Property__c> props) {
        
        property = p;
        
        Map<String, String> urlParams = new Map<String, String>{
            ADDRESS_PARAM => property.Name,
            CITY_STATE_ZIP_PARAM => property.Zipcode__c,
            RENT_ZESTIMATE_PARAM => 'true'
        };
        HttpResponse res = getResponseFromZillow(GET_DEEP_SEARCH_RESULTS_URL, urlParams);
        if(res.getStatusCode() > 399) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERROR_ZILLOW_OFFLINE + ' ' + res.getStatus() + ' ' + res.getStatusCode()));
            return null;
        }
        Dom.Document xmlBody = res.getBodyDocument();
        Dom.XMLNode root = xmlBody.getRootElement();
        Dom.XMLNode resultNode;
        Dom.XMLNode messageNode;
        if(root != null) {
            messageNode = root.getChildElement('message', null);
            Dom.XMLNode responseNode = root.getChildElement('response', null);
            if(responseNode != null) {
                Dom.XMLNode resultsNode = responseNode.getChildElement('results', null);
                if(resultsNode != null) {
                    resultNode = resultsNode.getChildElement('result', null);
                }
            }
        }
        getErrorMessages(messageNode);
        processErrors();

        if(resultNode != null) {
            for(Dom.XMLNode childNode : resultNode.getChildElements()) {
                if(childNode.getName() == 'zpid') {
                    zpid = childNode.getText();
                }
                if(childNode.getName() == 'links') {
                    Dom.XMLNode homedetailsNode = childNode.getChildElement('homedetails', null);
                    if(homedetailsNode != null) {
                        property.Zillow_Property_URL__c = homedetailsNode.getText();
                    }
                }
                if(childNode.getName() == 'zestimate') {
                    Dom.XMLNode amountNode = childNode.getChildElement('amount', null);
                    if(amountNode != null && amountNode.getText() != '') {
                        System.debug('TEST:' + amountNode.getText());
                        property.Zestimate__c = Decimal.valueOf(amountNode.getText());
                    }
                }
                if(childNode.getName() == 'rentzestimate') {
                    Dom.XMLNode amountNode = childNode.getChildElement('amount', null);
                    if(amountNode != null) {
                        property.Rent_Zestimate__c = Decimal.valueOf(amountNode.getText());
                        
                    }
                }    
                if(childNode.getName() == 'taxAssessment') {
                        property.Zillow_Assess_Value__c = Decimal.valueOf(childNode.getText());
        
                }
            }
        }
        props.add(property);
        return props;
        
    }

    @TestVisible
    private list<Property__c> getImages(Property__c p, list<Property__c> props) {
    
        property = p;
        
        Map<String, String> urlParams = new Map<String, String>{
            ZPID_PARAM => zpid
        };
        HttpResponse res = getResponseFromZillow(GET_UPDATED_PROPERTY_DETAILS_URL, urlParams);
        if(res.getStatusCode() > 399) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERROR_ZILLOW_OFFLINE + ' ' + res.getStatus() + ' ' + res.getStatusCode()));
            return null;
        }
        Dom.Document xmlBody = res.getBodyDocument();
        Dom.XMLNode root = xmlBody.getRootElement();
        Dom.XMLNode responseNode;
        Dom.XMLNode messageNode;
        if(root != null) {
            messageNode = root.getChildElement('message', null);
            responseNode = root.getChildElement('response', null);
        }
        getErrorMessages(messageNode);
        processErrors();

        if(responseNode != null) {
            for(Dom.XMLNode childNode : responseNode.getChildElements()) {
                if(childNode.getName() == 'images') {
                    Dom.XMLNode imageNode = childNode.getChildElement('image', null);
                    if(imageNode != null) {
                        String imageUrl;
                        imageUrl = imageNode.getChildElements()[0].getText();
                        property.Photo_Small_URL__c = imageUrl;
                    }
                }
            }
        }
        props.add(property);
        return props;
    }

    private void getErrorMessages(Dom.XMLNode messageNode) {
        if(messageNode != null) {
            Dom.XMLNode textNode = messageNode.getChildElement('text', null);
            Dom.XMLNode codeNode = messageNode.getChildElement('code', null);
            if(textNode != null) {
                errorMessage = textNode.getText();
            }
            if(codeNode != null) {
                errorCode = codeNode.getText();
            }
        }
    }
}
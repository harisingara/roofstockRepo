public with sharing class ZillowUpdateContExt {
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

    public ZillowUpdateContExt(ApexPages.StandardController stdCont) {
        property = [SELECT Name, City__c, State__c, Zipcode__c, Zestimate__c, Rent_Zestimate__c, Zillow_Assess_Value__c, Image_URLs__c, Zillow_Property_URL__c FROM Property__c WHERE Id = :stdCont.getId()];
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

    public PageReference updateProperty() {
        setFieldsOnProperty();
        if(ApexPages.hasMessages()) {
            return null;
        }
        getImages();
        if(ApexPages.hasMessages()) {
            return null;
        }
        try {
            update property;
        }
        catch(DMLException dmx) {
            ApexPages.addMessages(dmx);
            return null;
        }
        return new PageReference('/' + property.Id);
    }

    @TestVisible
    private void setFieldsOnProperty() {
        Map<String, String> urlParams = new Map<String, String>{
            ADDRESS_PARAM => property.Name,
            CITY_STATE_ZIP_PARAM => property.Zipcode__c,
            RENT_ZESTIMATE_PARAM => 'true'
        };
        HttpResponse res = getResponseFromZillow(GET_DEEP_SEARCH_RESULTS_URL, urlParams);
        if(res.getStatusCode() > 399) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERROR_ZILLOW_OFFLINE + ' ' + res.getStatus() + ' ' + res.getStatusCode()));
            return;
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
    }

    @TestVisible
    private void getImages() {
        Map<String, String> urlParams = new Map<String, String>{
            ZPID_PARAM => zpid
        };
        HttpResponse res = getResponseFromZillow(GET_UPDATED_PROPERTY_DETAILS_URL, urlParams);
        if(res.getStatusCode() > 399) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERROR_ZILLOW_OFFLINE + ' ' + res.getStatus() + ' ' + res.getStatusCode()));
            return;
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
                        List<String> imageUrls = new List<String>();
                        for(Dom.XMLNode urlNode : imageNode.getChildElements()) {
                            imageUrls.add(urlNode.getText());
                        }
                        property.Image_URLs__c = String.join(imageUrls, ',');
                    }
                }
            }
        }
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
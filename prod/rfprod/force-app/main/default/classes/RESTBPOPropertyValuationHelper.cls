/* Class Name - RESTBPOPropertyValuationHelper
 * Author - Kavitha
 * Description - Helper class to process for RESTBPOPropertyValuation.
 * ******************************************************************************************
 * 
 * Date			Name			Comments
 * 11-22-2021	Kavitha			Created helper for REST BPO Valuation class
 * 
 */
global class RESTBPOPropertyValuationHelper {

    //BPO Valuation Request Wrapper 
    global class BPOValuationRequest {
       global respondingParty respondingParty;
       global respondToParty respondToParty;
       global response response;
    }
    
    global class respondingParty {
        global String identifier;
    }
    
    global class respondToParty {
        global String identifier;
    }
    
    global class response {
        global Datetime responseDateTime;
        global String loginAccountIdentifier;
        global String loginAccountPassword;
        global key[] key;
        global status status;
        global responseData responseData;
    }
    
    global class responseData {
        global appraisalResponse appraisalResponse;
    }
    
    global class appraisalResponse {
        global String mismoVersionId;
        global embeddedFile embeddedFile;
        global loanInformation loanInformation;
        global product product;
        global productFulfillmentExtension productFulfillmentExtension;
        global valuation valuation;
    }
    
    global class loanInformation {
        global string loanId;
    }
    
    global class product {
        global productName productName;
    }
    
    global class productFulfillmentExtension {
        global Datetime completionDate;
        global Datetime inspectionDate;
        global String priceAmountString;
        global String priceAmount;
        global String orderIdentifier;
    }
    
    global class valuation {
        global String valueAmount;
    }
    
    global class embeddedFile {
        global String encodingType;
        global string name;
        global String document;
    }
    
    global class productName {
        global String identifier;
        global string description;
    }
    
    global class BPOValuationResponse {
        global string referenceId;
        global string orderID;
        global string propertysalesforceId;
        global string bposalesforceId;
  	}
    
    global class key {
        global String name;
		global String value;
    }
    
    global class status {
        global String condition;
		global String code;
		global String name;
		global String description;
    }
    
    global static BPOValuationResponse updateBPOwithValuation(BPOValuationRequest bporeq) {
        
        String referenceID ='';
        String rentValue ='';
        String FinalProductPrice ='';
        for(RESTBPOPropertyValuationHelper.key key: bporeq.response.key) {
            if (key.name == 'ReferenceId' && key.value != null) {
                referenceID = key.value;
            }
            if (key.name == 'MarketRentMonthly' && key.value != null) {
                rentValue = key.value;
            }
            if (key.name == 'FinalProductPrice' && key.value != null) {
                FinalProductPrice = key.value;
            }
        }
        
        Broker_Price_Opinion__c bpo = [SELECT id,name,property__c,Reference_ID__c,Order_ID__c,Status__c,Request__c,Completion_date__c,
                                       		  Inspection_Date__c,Price_Amount__c,Valuation_Amount__c,Final_Product_Price__c,Market_Rent_Monthly__c 
                                        FROM  Broker_Price_Opinion__c 
                                        WHERE Reference_ID__c =:referenceID];
        
        Property2__c prop = [SELECT ID, Name, Latest_BPO_Valuation_Amount__c,Latest_BPO_Valuation_Date__c,Annual_BPO_Trigger_Date__c,
                                 		BPO_Trigger_Date__c, PropertyId__c,Latest_BPO_Final_Product_Price__c,Latest_BPO_Valuation_Rent__c 
                                  FROM  Property2__c 
                                  WHERE ID =:bpo.Property__c];
        
        if(bpo != null) {
            bpo.Market_Rent_Monthly__c = decimal.valueOf(rentValue);
            bpo.Final_Product_Price__c = decimal.valueOf(FinalProductPrice);
            if(bporeq.response.responseData.appraisalResponse.valuation != null) {
                if(bporeq.response.responseData.appraisalResponse.valuation.valueAmount != null) {
                    bpo.Valuation_Amount__c = Decimal.valueOf(bporeq.response.responseData.appraisalResponse.valuation.valueAmount);
                }
                else {
                    bpo.Valuation_Amount__c = null;
                }
            }
            bpo.Status__c = bpo.Status__c;
            if(bporeq.response.responseData.appraisalResponse.productFulfillmentExtension != null) {
                bpo.Completion_date__c = bporeq.response.responseData.appraisalResponse.productFulfillmentExtension.completionDate;
                bpo.Inspection_Date__c = bporeq.response.responseData.appraisalResponse.productFulfillmentExtension.inspectionDate;
                if(bporeq.response.responseData.appraisalResponse.productFulfillmentExtension.priceAmount != null) {
                	bpo.Price_Amount__c = decimal.valueOf(bporeq.response.responseData.appraisalResponse.productFulfillmentExtension.priceAmount);
            	}
            }
            
            Integer maxSize = 131068;
            if(bporeq.toString().length() > maxSize) {
                bpo.Request__c = bporeq.toString().substring(0, maxSize)+'....'; //jsonreq is more char than max size. so, truncating.
            }
            
            update bpo;
            
            if(bporeq.response.responseData.appraisalResponse.embeddedFile != null) {
                String jsonStrattachment =bporeq.response.responseData.appraisalResponse.embeddedFile.document;
                Attachment attach = new Attachment();
                attach.contentType = 'application/pdf';
                attach.name = bporeq.response.responseData.appraisalResponse.embeddedFile.name + '_' +'.pdf';
                attach.parentId = bpo.id;
                attach.body = EncodingUtil.base64Decode(jsonStrattachment);
                insert attach;
            }
            
        	prop.Latest_BPO_Valuation_Amount__c = bpo.Valuation_Amount__c;
            prop.Latest_BPO_Valuation_Rent__c = decimal.valueOf(rentValue);
            prop.Latest_BPO_Final_Product_Price__c = decimal.valueOf(FinalProductPrice);
            
            if(bpo.Completion_date__c != null) {
                prop.Annual_BPO_Trigger_Date__c = bpo.Completion_date__c.date().addDays(integer.valueOf(System.Label.BPO_Annual_Trigger_Interval));
           		prop.Latest_BPO_Valuation_Date__c = bpo.Completion_date__c.date();
            }
            
            update prop;
        }
        
        BPOValuationResponse bpovr = new BPOValuationResponse();
        bpovr.bposalesforceId = bpo.id;
        bpovr.propertysalesforceId = bpo.Property__c;
        bpovr.referenceId = bpo.Reference_ID__c;
        bpovr.orderID = bpo.Order_ID__c;
        
        return bpovr;
    }
}
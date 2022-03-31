/* Class Name - BatchBPOServiceCalloutHelper
 * Author - Kavitha
 * Description - Helper class to process for BatchBPOServiceCallout.
 * ******************************************************************************************
 * 
 * Date			Name			Comments
 * 11-22-2021	Kavitha			Created helper for callout
 * 
 */
global class BatchBPOServiceCalloutHelper {
	//global static BPO_Product__mdt bpoProduct = new BPO_Product__mdt();
    global static Map<String,String> bpoProductsMap = new Map<String,String>();
    global static Map<Id,String> renovationPropMap = new Map<Id,String>();
    global static Map<Id,String> transactionPropMap = new Map<Id,String>();
    global static String dateString = Datetime.newInstance(Date.today().year(), Date.today().month(),Date.today().day()).format('yyyy-MM-dd'); 
    
    /*
    @AuraEnabled
    global static Boolean callBPOServiceButton(Property2__c propRecord, String product, String pool, String branchId) {
        
        try{
            
            Boolean success = false;
            List<Property2__c> propList = new List<Property2__c>{propRecord};
            
            // Insert a BPO Record
            Broker_Price_Opinion__c bpoReq = new Broker_Price_Opinion__c ();
            bpoReq.Property__c = propRecord.Id;
            bpoReq.Pool_Name__c = pool;
            bpoReq.Product__c = product;
            bpoReq.Branch_Id__c = branchId;
            bpoReq.Status__c = 'Confirmed';
            Insert bpoReq;
            
            Map <Id, Broker_Price_Opinion__c> bpoReqMap = new Map <Id, Broker_Price_Opinion__c> ();
            for(Broker_Price_Opinion__c bpo : [SELECT Id, Property__c, Pool_Name__c, Product__c, Branch_Id__c, Status__c 
                                               FROM Broker_Price_Opinion__c WHERE ID =: bpoReq.Id]){
                                                   
                                               }
                
                
            if(propList.size() > 0) {
                success = BatchBPOServiceCalloutHelper.callBPOServiceCallout(propList,true);
            }
            
            return success;
            
        }
        catch(Exception ex) {
            return false;
        }
    }
    */
   
    @AuraEnabled
    global static Boolean callBPOServiceButton(Property2__c propRecord, String product, String pool, String branchId) {
        
        try{
            System.debug('NDEBUG ::: Property Record' + propRecord);
            System.debug('NDEBUG ::: Product' + product);
            System.debug('NDEBUG ::: Pool' + pool);
            System.debug('NDEBUG ::: Branch Id' + branchId);
            
            Boolean success = false;
            Map <String, Property2__c> propMap = new Map<String, Property2__c> ();
            propMap.put(propRecord.Id, propRecord);
            //{propRecord};
            
            // Insert a BPO Record
            Broker_Price_Opinion__c bpoReq = new Broker_Price_Opinion__c ();
            bpoReq.Property__c = propRecord.Id;
            bpoReq.Pool_Name__c = pool;
            bpoReq.Product__c = product;
            bpoReq.Branch_Id__c = branchId;
            bpoReq.Status__c = 'Confirmed';
            bpoReq.Type_of_BPO_Trigger__c = 'Manual';
            
            //Insert bpoReq;
            Map <String, Broker_Price_Opinion__c> propToBpoMap = new Map <String, Broker_Price_Opinion__c> ();
            propToBpoMap.put(bpoReq.Property__c, bpoReq); 
            /*
            
            for(Broker_Price_Opinion__c bpo : [SELECT Id, Property__c, Pool_Name__c, Product__c, Branch_Id__c, Status__c 
                                               FROM Broker_Price_Opinion__c WHERE ID =: bpoReq.Id]){
            	 propToBpoMap.put(bpo.Property__c, bpo);                                      
            }
			*/
                
                
            if(!propToBpoMap.isEmpty()) {
                success = callBPOServiceCallout(propToBpoMap,propMap, true);
            }
            
            return success;
            
        }
        catch(Exception ex) {
            return false;
        }
    }
    
    @AuraEnabled(cacheable=true)
     public static List <customValueWrapper> pickListValueDynamically(sObject customObjInfo, string selectPicklistApi) {
        Schema.DescribeSObjectResult objDescribe = customObjInfo.getSObjectType().getDescribe();     
        map < String, Schema.SObjectField > customFieldMap = objDescribe.fields.getMap();      
        list < Schema.PicklistEntry > custPickValues = customFieldMap.get(selectPicklistApi).getDescribe().getPickListValues();
        list < customValueWrapper > customObjWrapper = new list < customValueWrapper > ();
        for (Schema.PicklistEntry myCustPick: custPickValues) {
          customValueWrapper selectOptionValueWrapper = new customValueWrapper();
             selectOptionValueWrapper.custFldlabel = myCustPick.getLabel();
             selectOptionValueWrapper.custFldvalue = myCustPick.getValue();
            customObjWrapper.add(selectOptionValueWrapper);
        }
        
        return customObjWrapper;
  
      }
      // wrapper class 
        public with sharing class customValueWrapper {
          @auraEnabled public string custFldlabel {get;set;}
          @auraEnabled public string custFldvalue {get;set;}
        }
    
    
     @AuraEnabled
    global static Property2__c fetchPropertyData(Id recordId) {
        
        List<Property2__c> propList =[SELECT id, Name, owner_Entity__c, Owner_Entity__r.name,Street_Address__c,City__c,State__c,County__c,Zip__c,
                                      		 Seller_Provided_List_Price__c,Property_Type__c ,Bathrooms_SUM__c,Bedrooms_SUM__c,Lot_Size__c,
                                      		 Square_Feet__c,Annual_BPO_Trigger_Date__c,BPO_Trigger_Date__c,Year_Built__c,Type_of_BPO_Trigger__c, 
                                      		 PropertyId__c,Latest_BPO_Valuation_Amount__c,Latest_BPO_Valuation_Date__c,Client__c 
                                       FROM  Property2__c 
                                       WHERE id =:recordId];
        if(propList.size() > 0)	{
            return propList[0];
        } 
        else {
           return null; 
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    global static List<Broker_Price_Opinion__c> getBPORequestList(Id recordId) {
        return [SELECT Id, Name,Order_ID__c,Reference_ID__c,Price_Amount__c,Type_of_BPO_Trigger__c,Valuation_Amount__c,Property__c,
                	   Property__r.name,Completion_date__c,Inspection_Date__c,Internal_Status__c,createddate 
                  FROM Broker_Price_Opinion__c 
                 WHERE Property__c =:recordId 
                	   ORDER BY createddate DESC LIMIT 10 ];
    }
    
    /*
    global static Boolean callBPOServiceCallout(List<Property2__c> propertyList, Boolean manual) {
        Set<Id> PropIDSet = new Set<Id>();
        Id renovationRecordTypeId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Renovation').getRecordTypeId();
        Id transactionRecordTypeId = Schema.SObjectType.Transaction__c.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        
        for(Property2__c prop:propertyList) {
            if(prop.Type_of_BPO_Trigger__c == 'Renovation Job Completed'){
                PropIDSet.add(prop.id);
            }
        }
        
        List<job__c> renovationJobList = [SELECT id,name,total_job_cost__c,Property__c 
                                            FROM job__c 
                                           WHERE Job_Status__c = 'Job Complete' AND 
                                          		 Property__c IN: PropIDSet AND 
                                          		 RecordTypeId =: renovationRecordTypeId];
        List<Transaction__c> transactionList = [SELECT id,name,Buyer_Property_Instance__c,Transaction_Id__c,Transaction_Status__c 
                                                  FROM Transaction__c 
                                                 WHERE Transaction_Status__c = 'Transaction Completed' AND 
                                                	   Buyer_Property_Instance__c IN: PropIDSet AND 
                                                	   RecordTypeId =: transactionRecordTypeId];

        for(job__c job:renovationJobList) {
            renovationPropMap.put(job.Property__c,String.valueOf(job.total_job_cost__c));
        }
        
        for(Transaction__c tran:transactionList) {
            transactionPropMap.put(tran.Buyer_Property_Instance__c,String.valueOf(tran.Transaction_Id__c));
        }
        
        // Initialize the HTTP request (API call)
		HttpRequest req = new HttpRequest();

		// Create a new http object to send the request object
		Http http = new Http();

		// A response object is generated as a result of the request
		HTTPResponse res;

        List<Broker_Price_Opinion__c> insertNewBPOReq = new List<Broker_Price_Opinion__c>();
        List<Property2__c> updateProperties = new List<Property2__c>();
        List<Outbound_Message_Request__c> omrList = new List<Outbound_Message_Request__c>();
        
        Boolean successfull = false;
        try {
            
            if(propertyList!=null) {
                
                bpoProduct = [SELECT ID,Label,MasterLabel,DeveloperName FROM BPO_Product__mdt];
                
                for(Property2__c prop:propertyList) {
                    
                    String jsonData = jsonRequestGenerator(prop); // Build JSON Request
                    System.debug('@@@---jsonData Print--'+jsonData);
                    
                    // Set API endpoint and method
                    req.setMethod('POST'); 
                    req.setHeader('Content-Type', 'application/json');
                    req.setEndpoint('callout:BPOPROPERTYVALUATION');
                    req.setHeader('Api-Key', '{!$Credential.Password}');
                    req.setTimeout(120000);
                    
                    // Set the body of the request
                    req.setBody(jsonData);
                    
                    res = http.send(req); 
                    System.debug( '@@@--callout response:-- ' + res.getBody());
                                        
                    BatchBPOServiceCalloutHelper.JSONResponse jsonResponse =   (BatchBPOServiceCalloutHelper.JSONResponse) System.JSON.deserialize(res.getBody(), BatchBPOServiceCalloutHelper.JSONResponse.class);
      				System.debug('@@@--jsonResponse wrapper--'+jsonResponse);
                    
                    if(jsonResponse.isSuccessful == true) {
                        successfull = jsonResponse.isSuccessful;
                        Broker_Price_Opinion__c bpo = new Broker_Price_Opinion__c();
                        bpo.Property__c = prop.Id;
                        
                        if(jsonResponse.data.orderRequest.key[0].value != '') {
                            bpo.Reference_ID__c = jsonResponse.data.orderRequest.key[0].value;
                        }
                        
                        if(jsonResponse.data.orderRequest.order.orderId != '' && jsonResponse.data.orderRequest.order.orderId != null) {
                            bpo.Order_ID__c = jsonResponse.data.orderRequest.order.orderId;
                        }
                        
                        bpo.Type_of_BPO_Trigger__c = (manual) ? 'Manual' : (prop.Annual_BPO_Trigger_Date__c == system.today()) ? 'Annual BPO Valuation' : prop.Type_of_BPO_Trigger__c;
                        bpo.Status__c = 'Request Submitted';
                        bpo.name =  bpo.Reference_ID__c + '_'+ bpo.Order_ID__c+ '_' +bpo.Type_of_BPO_Trigger__c;
                        
                        Integer maxSize = 131068;
                        if(jsonData.length() > maxSize) {
                            bpo.Request__c = jsonData.substring(0, maxSize)+'....'; //jsonreq is more char than max size. so, truncating.
                        } 
                        else {
                            bpo.Request__c = jsonData;
                        }
                        
                        bpo.Pool_Name__c = prop.Client__c+' - ORDERS - '+dateString+' BPO RUSH3';
                        
                        if(transactionPropMap.containsKey(prop.id)) {
                            bpo.Transaction_ID__c = transactionPropMap.get(prop.id);
                        }
						
                        insertNewBPOReq.add(bpo);
                        
                        if(!manual) {
                            prop.Type_of_BPO_Trigger__c = null;
                            prop.BPO_Trigger_Date__c = null;
							updateProperties.add(prop);
                        }
                        
                    }
                    
                    if(res.getStatusCode() != 200) {
                        Outbound_Message_Request__c omr = OutboundMessageRequestHelper.logOutboundRetryRequest(req,'Property BPO Callout');
                        omr.Status__c = 'Retry - Pending';
                        omr.Generate_New_Auth_Token__c = false;
                        omr.HTTP_Status_Code__c = res.getStatusCode();
                        omr.Named_Credential__c = 'BPOPROPERTYVALUATION';
                        omr.NC_PassLabel__c = 'Api-Key';
                        omrList.add(omr);
                    }
                
                }
                
                if(!insertNewBPOReq.isEmpty() &&  insertNewBPOReq.size()>0) {
                    INSERT insertNewBPOReq;
                    System.debug('@@@---Response inserted into BPO Response object'+insertNewBPOReq);
                }
                
                if(!updateProperties.isEmpty() && updateProperties.size()>0) {
                    UPDATE updateProperties;
                }
                
                if(!omrList.isEmpty()) {
                    INSERT omrList;
                }
            }
            return successfull;
            
        } catch(Exception exe) {
            
            DebugLogHandler.logRestServiceException('PropertyBPOServiceCallout','BPOServiceCallout',exe.getMessage(),
                                                exe.getStackTraceString(),req.getBody());
            
            return false;
        }
    }
    */
    
    global static Boolean callBPOServiceCallout(Map <String, Broker_Price_Opinion__c> propToBpoMap, Map <String, Property2__c> propMap, Boolean manual) {
        Set<Id> PropIDSet = new Set<Id>();
        Id renovationRecordTypeId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Renovation').getRecordTypeId();
        Id transactionRecordTypeId = Schema.SObjectType.Transaction__c.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        
        
        for(Property2__c prop:propMap.values()) {
            if(prop.Type_of_BPO_Trigger__c == 'Renovation Job Completed'){
                PropIDSet.add(prop.id);
            }
        }
        
        List<job__c> renovationJobList = [SELECT id,name,total_job_cost__c,Property__c 
                                            FROM job__c 
                                           WHERE Job_Status__c = 'Job Complete' AND 
                                          		 Property__c IN: PropIDSet AND 
                                          		 RecordTypeId =: renovationRecordTypeId];
        List<Transaction__c> transactionList = [SELECT id,name,Buyer_Property_Instance__c,Transaction_Id__c,Transaction_Status__c 
                                                  FROM Transaction__c 
                                                 WHERE Transaction_Status__c = 'In Contract' AND 
                                                	   Buyer_Property_Instance__c IN: PropIDSet AND 
                                                	   RecordTypeId =: transactionRecordTypeId];

        for(job__c job:renovationJobList) {
            renovationPropMap.put(job.Property__c,String.valueOf(job.total_job_cost__c));
        }
        
        for(Transaction__c tran:transactionList) {
            transactionPropMap.put(tran.Buyer_Property_Instance__c,String.valueOf(tran.Transaction_Id__c));
        }

		
        
        // Initialize the HTTP request (API call)
		HttpRequest req = new HttpRequest();

		// Create a new http object to send the request object
		Http http = new Http();

		// A response object is generated as a result of the request
		HTTPResponse res;

        List<Broker_Price_Opinion__c> BPOReqsToBeUpd = new List<Broker_Price_Opinion__c>();
        List<Property2__c> updateProperties = new List<Property2__c>();
        List<Outbound_Message_Request__c> omrList = new List<Outbound_Message_Request__c>();
        
        Boolean successfull = false;
        try {
            
            if(!propToBpoMap.isEmpty()) {
                for(String key : propToBpoMap.keySet()) {
                    if(propMap.containsKey(key)){
                        List<BPO_Product__mdt> bpoProductList = [SELECT ID,Label,MasterLabel,DeveloperName FROM BPO_Product__mdt];
                        if(bpoProductList.size() >0) {
                            for(BPO_Product__mdt bpop:bpoProductList) {
                                bpoProductsMap.put(bpop.MasterLabel,bpop.DeveloperName);
                            }
                        }
                        
                        String jsonData = jsonRequestGenerator(propMap.get(key), propToBpoMap.get(key)); // Build JSON Request
                        System.debug('@@@---jsonData Print--'+jsonData);
                        
                        // Set API endpoint and method
                        req.setMethod('POST'); 
                        req.setHeader('Content-Type', 'application/json');
                        req.setEndpoint('callout:BPOPROPERTYVALUATION');
                        req.setHeader('Api-Key', '{!$Credential.Password}');
                        req.setTimeout(120000);
                        
                        // Set the body of the request
                        req.setBody(jsonData);                      
                                                 
                        if(Test.isRunningTest()){
                            res = new HttpResponse();
                            res.setHeader('Content-Type', 'application/json');
                            res.setBody('{"isSuccessful":true,"error":null,"data":{"orderRequest":{"responseDateTime":"2021-11-22T02:39:00","loginAccountIdentifier":"","loginAccountPassword":"","key":[{"name":"ReferenceId","value":"testrefid1"}],"status":{"condition":"Success","code":"1","name":"","description":"Order Created"},"order":{"orderId":"testorderid1"}}}}');
                            res.setStatusCode(200);
                        }
                        else{
                            res = http.send(req);
                        }
                        System.debug( '@@@--callout response:-- ' + res.getBody());
                                            
                        BatchBPOServiceCalloutHelper.JSONResponse jsonResponse =   (BatchBPOServiceCalloutHelper.JSONResponse) System.JSON.deserialize(res.getBody(), BatchBPOServiceCalloutHelper.JSONResponse.class);
                        System.debug('@@@--jsonResponse wrapper--'+jsonResponse);
                        
                        if(jsonResponse.isSuccessful == true) {
                            successfull = jsonResponse.isSuccessful;
                            Broker_Price_Opinion__c bpo = new Broker_Price_Opinion__c();
                            bpo = propToBpoMap.get(key);
                            
                            
                            if(jsonResponse.data.orderRequest.key[0].value != '') {
                                bpo.Reference_ID__c = jsonResponse.data.orderRequest.key[0].value;
                            }
                            
                            if(jsonResponse.data.orderRequest.order.orderId != '' && jsonResponse.data.orderRequest.order.orderId != null) {
                                bpo.Order_ID__c = jsonResponse.data.orderRequest.order.orderId;
                            }
                            
                            //bpo.Type_of_BPO_Trigger__c = (manual) ? 'Manual' : (prop.Annual_BPO_Trigger_Date__c == system.today()) ? 'Annual BPO Valuation' : prop.Type_of_BPO_Trigger__c;
                            bpo.Status__c = 'Processed';
                            bpo.name =  bpo.Reference_ID__c + '_'+ bpo.Order_ID__c+ '_' + bpo.Type_of_BPO_Trigger__c;
                            
                            Integer maxSize = 131068;
                            if(jsonData.length() > maxSize) {
                                bpo.Request__c = jsonData.substring(0, maxSize)+'....'; //jsonreq is more char than max size. so, truncating.
                            } 
                            else {
                                bpo.Request__c = jsonData;
                            }
                            
                            System.debug('NDEBUG manual value:::' + manual);
                            if(!manual) {
                                Property2__c prop = new Property2__c ();
                                prop.Id = key;
                                prop.Type_of_BPO_Trigger__c = null;
                                prop.BPO_Trigger_Date__c = null;
                                updateProperties.add(prop);
                            }
							
                            BPOReqsToBeUpd.add(bpo);
                            
                        }
                        
                        if(res.getStatusCode() != 200) {
                            Outbound_Message_Request__c omr = OutboundMessageRequestHelper.logOutboundRetryRequest(req,'Property BPO Callout');
                            omr.Status__c = 'Retry - Pending';
                            omr.Generate_New_Auth_Token__c = false;
                            omr.HTTP_Status_Code__c = res.getStatusCode();
                            omr.Named_Credential__c = 'BPOPROPERTYVALUATION';
                            omr.NC_PassLabel__c = 'Api-Key';
                            omrList.add(omr);
                        }
                    }
                
                }
                
                if(!BPOReqsToBeUpd.isEmpty() &&  BPOReqsToBeUpd.size()>0) {
                    UPSERT BPOReqsToBeUpd;
                    System.debug('@@@---Response inserted into BPO Records'+BPOReqsToBeUpd);
                }
                
                if(!updateProperties.isEmpty() && updateProperties.size()>0) {
                    UPDATE updateProperties;
                }
                
                if(!omrList.isEmpty()) {
                    INSERT omrList;
                }
            }
            return successfull;
            
        } catch(Exception exe) {
            
            DebugLogHandler.logRestServiceException('PropertyBPOServiceCallout','BPOServiceCallout',exe.getMessage(),
                                                exe.getStackTraceString(),req.getBody());
            
            return false;
        }
    }
    
    global static Boolean createBPORecords(List<Property2__c> propertyList, Boolean manual) {
        Set<Id> PropIDSet = new Set<Id>();
        Id renovationRecordTypeId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Renovation').getRecordTypeId();
        Id transactionRecordTypeId = Schema.SObjectType.Transaction__c.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        
        for(Property2__c prop:propertyList) {
            if(prop.Type_of_BPO_Trigger__c == 'Renovation Job Completed'){
                PropIDSet.add(prop.id);
            }
        }
        
        List<job__c> renovationJobList = [SELECT id,name,total_job_cost__c,Property__c 
                                            FROM job__c 
                                           WHERE Job_Status__c = 'Job Complete' AND 
                                          		 Property__c IN: PropIDSet AND 
                                          		 RecordTypeId =: renovationRecordTypeId];
        List<Transaction__c> transactionList = [SELECT id,name,Buyer_Property_Instance__c,Transaction_Id__c,Transaction_Status__c 
                                                  FROM Transaction__c 
                                                 WHERE Transaction_Status__c = 'Transaction Completed' AND 
                                                	   Buyer_Property_Instance__c IN: PropIDSet AND 
                                                	   RecordTypeId =: transactionRecordTypeId];

        for(job__c job:renovationJobList) {
            renovationPropMap.put(job.Property__c,String.valueOf(job.total_job_cost__c));
        }
        
        for(Transaction__c tran:transactionList) {
            transactionPropMap.put(tran.Buyer_Property_Instance__c,String.valueOf(tran.Transaction_Id__c));
        }
        
        List<Broker_Price_Opinion__c> insertNewBPOReq = new List<Broker_Price_Opinion__c>();
        List<Property2__c> updateProperties = new List<Property2__c>();
        List<Outbound_Message_Request__c> omrList = new List<Outbound_Message_Request__c>();
        
        Boolean successfull = false;
        try {
            
            if(propertyList!=null) {
                
                //bpoProduct = [SELECT ID,Label,MasterLabel,DeveloperName FROM BPO_Product__mdt];                
                for(Property2__c prop:propertyList) {                 
                    Broker_Price_Opinion__c bpo = new Broker_Price_Opinion__c();
                    bpo.Property__c = prop.Id;                   
                    bpo.Type_of_BPO_Trigger__c = (manual) ? 'Manual' : (prop.Annual_BPO_Trigger_Date__c == system.today()) ? 'Annual BPO Valuation' : prop.Type_of_BPO_Trigger__c;
                    bpo.Status__c = 'New';
                    bpo.name =  prop.Name + '_'+bpo.Type_of_BPO_Trigger__c + '_' + bpo.Status__c;                    
                    if(transactionPropMap.containsKey(prop.id)) {
                        bpo.Transaction_ID__c = transactionPropMap.get(prop.id);
                    }                    
                    insertNewBPOReq.add(bpo);
                }
                
                if(!insertNewBPOReq.isEmpty() &&  insertNewBPOReq.size()>0) {
                    INSERT insertNewBPOReq;
                    System.debug('@@@---BPO Records being Inserted'+insertNewBPOReq);
                }
            }
            return successfull;
            
        } catch(Exception exe) {           
            DebugLogHandler.logRestServiceException('CreateBPORecordsBatch','createBPORecords',exe.getMessage(),
                                                exe.getStackTraceString(),String.valueOf(insertNewBPOReq));            
            return false;
        }
    }
    
    global static String jsonRequestGenerator(Property2__c prop, Broker_Price_Opinion__c bpo) {
        
        Datetime dt = datetime.newInstance(System.Today().year(), System.Today().month(),System.Today().day());
		String propCode = (prop.PropertyCode__c != '' && prop.PropertyCode__c.startsWith('q')) ? prop.PropertyCode__c.replaceFirst('q', '') : prop.PropertyCode__c;
		String bpoProdCode = (!bpoProductsMap.isEmpty()) ? bpoProductsMap.get(bpo.Product__c) : '';
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('Request');
        gen.writeStartObject();
        
        //gen.writeStringField('RequestingPartyBranchIdentifier ', bpo.Branch_Id__c);
        gen.writeStringField('RequestingPartyBranchIdentifier', 'ROOF');
        
        gen.writeFieldName('RequestData');
        gen.writeStartObject(); // start object in requestdata
        
        gen.writeFieldName('PropertyInformationRequest');
        gen.writeStartObject(); // start object for PropertyInformationRequest
        //gen.writeStringField('RequestingPartyBranchIdentifier', 'ROOF2');
        gen.writeStringField('ActionType', 'Submit');
        
        if(prop.Type_of_BPO_Trigger__c == 'Renovation Job Completed' && renovationPropMap.containsKey(prop.id)){
        	gen.writeStringField('SpecialInstructionsDescription', 'Total renovation Cost - $'+renovationPropMap.get(prop.id)); 
        }
        else {
            gen.writeStringField('SpecialInstructionsDescription', 'Order Instructions');
        }
        
        gen.writeStringField('QCReviewInstructions', 'Instructions');
        gen.writeStringField('PoolName', +prop.Client__c+' - ORDERS - '+dateString+' ' + bpo.Pool_Name__c);
        gen.writeStringField('OrderBy', userinfo.getUserEmail());
        
        // start of Product Section
        gen.writeFieldName('Product');
        gen.writeStartObject();
        //gen.writeStringField('CategoryType',bpoProduct.DeveloperName);//start of Borrower
        gen.writeStringField('CategoryType',bpo.Product__c);
        gen.writeFieldName('Name');
        gen.writeStartObject();
        //gen.writeStringField('Identifier', bpoProduct.DeveloperName);
        //gen.writeStringField('Description', bpoProduct.MasterLabel);
        gen.writeStringField('Identifier', bpoProdCode);
        gen.writeStringField('Description', bpo.Product__c);
        gen.writeEndObject(); //Address end
        gen.writeEndObject();
        //End Product section
        
        gen.writeFieldName('Property');
        gen.writeStartObject();
        gen.writeStringField('PropertyRiid', ''+prop.PropertyId__c);
        gen.writeStringField('StreetAddress', ''+prop.Street_Address__c);
        gen.writeStringField('StreetAddress2', '');
        gen.writeStringField('City', ''+prop.City__c);
        gen.writeStringField('State', ''+prop.State__c); 
        gen.writeStringField('County', ''+prop.County__c);
        gen.writeStringField('PostalCode', ''+prop.Zip__c);
        if(prop.Seller_Provided_List_Price__c != null) {
        	gen.writeStringField('LastSalePriceAmount', +String.valueOf(prop.Seller_Provided_List_Price__c)); //Mand. where to find info - check - check with Radian if we can default.
        }
        else{
            gen.writeStringField('LastSalePriceAmount', +'0'); 
        }
        gen.writeStringField('LastSaleDate', ''); 
        gen.writeStringField('AsofDate', ''); 
        gen.writeStringField('PriorDate', ''); 
        gen.writeStringField('CompType', ''); 
        gen.writeStringField('CompsGoingBack', ''); 
        if(prop.Property_Type__c != null) {
        	gen.writeStringField('CompPropertyType', +prop.Property_Type__c); 
        } 
        else {
            gen.writeStringField('CompPropertyType', +''); 
        }
        gen.writeStringField('PriorPrice', '0'); //Mand. where to find info - check with Radian if we can default. -m check if we can send last bpo valuation amount
        if(prop.Bedrooms_SUM__c != null) {
            gen.writeStringField('Bed', +String.valueOf(prop.Bedrooms_SUM__c));
        }
        else {
            gen.writeStringField('Bed', '0');
        }
        
        if(prop.Bathrooms_SUM__c != null) {
            gen.writeStringField('Bath', +String.valueOf(prop.Bathrooms_SUM__c));
        }
        else { 
            gen.writeStringField('Bath', '0');
        }
        
        gen.writeStringField('Garage', '1'); //Mand. where to find info - check with Radian if we can default.
        
        if(prop.Lot_Size__c != null) {
            gen.writeStringField('LotSize', +prop.Lot_Size__c);
        } 
        else {
            gen.writeStringField('LotSize', +'0');
        }
        
        if(prop.Square_Feet__c != null) {
            gen.writeStringField('SquareFeet', +prop.Square_Feet__c);
        }
        else {
            gen.writeStringField('SquareFeet', +'0');
        }
        
        if(prop.Year_Built__c != null) {
            gen.writeStringField('YearBuilt', +prop.Year_Built__c);
        }
        else {
            gen.writeStringField('YearBuilt', +'0');
        }
        gen.writeStringField('LockBox', ''); 
        gen.writeEndObject();
        gen.writeEndObject();
        
        // start of borrower information
        gen.writeFieldName('BorrowerInformation');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeFieldName('Borrower');//start of Borrower
        gen.writeStartObject();
        gen.writeStringField('FirstName','');
        gen.writeStringField('MiddleName','');
        gen.writeStringField('LastName','Not Applicable');
        gen.writeStringField('Type','');
        gen.writeFieldName('Address');
        gen.writeStartObject();
        gen.writeStringField('StreetAddress', '');
        gen.writeStringField('StreetAddress2', '');
        gen.writeStringField('City', '');
        gen.writeStringField('State', '');
        gen.writeStringField('County', '');
        gen.writeStringField('PostalCode', '');
        gen.writeEndObject(); //Address end
        gen.writeEndObject();
        gen.writeEndObject();//End of one object from borrower array
        
        gen.writeEndArray(); //End Borrow information section Array
        
        //Start Loan Information Section
        gen.writeFieldName('LoanInformation');
        gen.writeStartObject();
        gen.writeStringField('LoanId', ''+propCode);
        gen.writeEndObject();
        //End Loan Information Section
        
        gen.writeEndObject();
        gen.writeEndObject();//till property section.
        
        
        String jsonData = gen.getAsString();
        
        return jsonData;
    }
    
    global class JSONResponse {
        global boolean isSuccessful;
        global String error;
        global data data;
    }
    
	global class data {
        global orderRequest orderRequest;
    }
    
    global class orderRequest {
        global Datetime responseDateTime;
        global String loginAccountIdentifier;
        global String loginAccountPassword;
        global key[] key;
        global status status;
		global order order;
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
    
    global class order {
        global String orderId;
    }
	
    
}
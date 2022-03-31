public class PlanomaticCreateOrderHelper {
    public static List<String> Planomatic3dClientList =  new list<String>();
    public class planomaticRequest{
        public string specialInstructions; 
        public string source;
        public String externalId;
        public Client client;
        public primaryService primaryService;
        public List<addOnServices> addOnServices;
        public PropertyInfo PropertyInfo;
        public PropertyAccess propertyAccess;
    }
    
    public class Address { 
        public String address1;
        public String city;
        public String country;
        public String postalCode;
        public String stateOrProvince;
    }
    
    public class primaryService {
        public String serviceName;
        public Integer quantity;
    }

    public class addOnServices {
        public String serviceName;
        public Integer quantity;
    }
    
    public class Client {
        public String postalCode;
        public String email;
        public String firstName;
        public String lastName;
        public String phoneMobile;
    }
    
    public class PropertyInfo {
        public Address address;
        public Integer bedrooms;
        public Double bathrooms;
        public double listPrice;
        public String rsPropertyType;
        public Integer squareFeet;
        public String unitCode;
    }
    public class PropertyAccess{
        public String accessType;
        public String accessCode;
        public boolean propertyVacant;        
    }
    
    //public static boolean postOrder(String recordId,Map<String,Job__c> puJobMap,Map<String,Turn__c> puTurnMap){
    public static boolean postOrder(String recordId,Map<String,sobject> accessDetailsMap, String notes){
        
        //Query Leasing Availability
        //try{
            Rental_Listing__c rentalList = [SELECT Id,Name,Property_Unit__r.Property__r.Street_Address__c,
                                                     Property_Unit__r.Property__r.City__c,
                                                     Property_Unit__r.Property__r.County__c,
                                                     Property_Unit__r.Property__r.Zip__c,
                                                     Property_Unit__r.Property__r.State__c,
                                                     Property_Unit__r.Property__r.Property_Type__c,
                                                     Property_Unit__r.Property__r.Seller_Provided_List_Price__c,
                                                     Property_Unit__r.Property__r.Square_Feet__c,
                                                     Property_Unit__r.Property__r.PropertyId__c,
                                                     Property_Unit__r.HomeCode__c,
                                                     Property_Unit__r.Bathrooms__c,
                                                     Property_Unit__r.Bedrooms__c,
                                                     Property_Unit__r.Lockbox_Code__c,
                                                     Property_Unit__r.Client__c
                                                     FROM Rental_Listing__c where Id=:recordId];
        
        List<Rental_Listing__c> matchingRlList = new List<Rental_Listing__c>();  
        matchingRlList.add(rentalList);
        String strRentalListing = JSON.serialize(matchingRlList);
        //Boolean orderStatus = orderDetails(strLeasingAvailability,puJobMap,puTurnMap);
        Boolean orderStatus = orderDetails(strRentalListing,accessDetailsMap,notes);
        
        System.debug('-orderStatus-'+orderStatus);
        if(orderStatus==true){
            return true;
        }
        else{
            return false;
        }
        
        
        
        //}
        //catch(Exception ex){
        
        //    return false;
        //}
        
    }
    
    public static boolean orderDetails(String rentalListing,Map<String,sobject> accessDetailsMap,String notes){
        String rawRequest = '';
        String rawAuthenticationResponse = '';
        String rawAuthorizationResponse ='';
        String rawResponse ='';
        String authenticationToken;
        try{
            Map<String,Rental_Listing__c> leasingAvailabilityMap = new Map<String,Rental_Listing__c>();
            Map<String,Planomatic_Order__c> planomaticMap = new Map<String,Planomatic_Order__c>();
            Map<String,String> reqIdPlanomaticRecIdMap = new Map<String,String>();
            List<Planomatic_Order__c> planomaticOrderList = new List<Planomatic_Order__c>();
            // Planomatic 3D client list
            List<Planomatic_3D_Client__mdt> Planomatic3dClients = [SELECT Label FROM Planomatic_3D_Client__mdt];
            for( Planomatic_3D_Client__mdt client : Planomatic3dClients) {
                Planomatic3dClientList.add(client.Label);
            }
            //Roofstock__mdt[] roofstockHostDetails = [SELECT MasterLabel, DeveloperName,User_Name__c,Password__c,CFS_URL__c,MicroService_URL__c FROM Roofstock__mdt];               
            Roofstock__mdt roofstockHostDetails = Roofstock__mdt.getInstance('Roofstock');       
            // String username = roofstockHostDetails.User_Name__c;
            // String password = roofstockHostDetails.Password__c;
            // String cfsURL = roofstockHostDetails.CFS_URL__c;
            String microServiceURL = roofstockHostDetails.MicroService_URL__c;
            
            List<Rental_Listing__c> rentalListingList = (List<Rental_Listing__c>) JSON.deserialize(rentalListing, List<Rental_Listing__c>.class);
            
            for(Rental_Listing__c rentalListingData: rentalListingList){
                
                
                System.debug('-pu id-'+rentalListingData.Property_Unit__c);
                
                map<String, Object> mapJsonData = new map<String, Object>();
                String isSuccess;
                String reqId;
                String jsonBody;
                planomaticRequest planoReq;
                if(accessDetailsMap!=null){
                    if(accessDetailsMap.containskey(rentalListingData.Property_Unit__c)){
                        planoReq =  planomaticOrderDataPreparation(rentalListingData,accessDetailsMap,notes);
                    }
                }
                else{
                    planoReq =  planomaticOrderDataPreparation(rentalListingData,null,notes);
                }
                String lockboxCode = (planoReq.specialInstructions.split('\\. ')[0]).split(':')[1];
                String ContactDetails = planoReq.specialInstructions.split('\\. ')[1];
                planoReq.specialInstructions = LABEL.Planomatic_Instruction+' '+planoReq.specialInstructions;
                jsonBody = json.serialize(planoReq); 
                jsonBody = jsonBody.remove('Lockbox Code:'+lockboxCode+'.');
                System.debug('-jsonBody-'+jsonBody.split('}'));
                List<String> jsonBodyList = jsonBody.split('}');
                
                for(String s:jsonBodyList){
                    System.debug('-s-'+s);
                }
                requestWrapper reqWrap = new requestWrapper();
                reqWrap.recordId = rentalListingData.Id;
                reqWrap.jsonBody = jsonBody;
                String strReqWrap = JSON.serialize(reqWrap);
                rawRequest = strReqWrap.replaceAll('\\\\', '');
                /*
                map<String, Object> mapJsonDataAuthentication = new map<String, Object>();
                String authenticationToken;
                // Generating the Access Token
                HttpRequest reqAccess = new HttpRequest();
                reqAccess.setMethod('POST');
                reqAccess.setEndpoint(cfsURL+'/api/auth/login');
                //reqAccess.setEndpoint('https://dev.roofstock.com/api/auth/login');
                reqAccess.setBody('grant_type=credential&username='+username+'&password='+password);
                reqAccess.setTimeout(120000);
                Http httpAccess = new Http();
                
                if(!Test.isRunningTest()){
                    HTTPResponse res = httpAccess.send(reqaccess);
                    
                    requestWrapper reqWrap = new requestWrapper();
                    reqWrap.recordId = rentalListingData.Id;
                    reqWrap.jsonBody = jsonBody;
                    String strReqWrap = JSON.serialize(reqWrap);
                    rawRequest = strReqWrap.replaceAll('\\\\', '');
                    
                    rawAuthenticationResponse = res.getBody();
                    
                    mapJsonDataAuthentication = (map<String, Object>)JSON.deserializeUntyped(res.getBody());
                    System.debug('=mapJsonDataAuthentication='+mapJsonDataAuthentication);
                    Object authResponse = mapJsonDataAuthentication.get('authResult');
                    map<String,Object> responseElement = (map<String,Object>) authResponse;
                    authenticationToken = (String) responseElement.get('jwtToken');
                    System.debug('=authenticationToken='+authenticationToken);
                }
                */
                Roofstock__mdt rsdata = [SELECT id, RoofstockAuthToken_RS1__c, MicroService_URL__c FROM Roofstock__mdt WHERE developername = 'Roofstock'];
                System.debug('rs authtoken:: '+rsdata.RoofstockAuthToken_RS1__c);
                authenticationToken = rsdata.RoofstockAuthToken_RS1__c;

                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(microServiceURL+'/-api/inspection-server/rest/photo/createOrder');
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                request.setHeader('Authorization', 'Bearer '+authenticationToken);
                request.setBody(jsonBody);
                request.setTimeout(120000);
                system.debug('request to planomatic::'+jsonBody);
                HttpResponse res = http.send(request);
                system.debug('DEBUGGING RESPOSE: ' + res.getStatusCode() + ' > ' + res.getStatus() + '  >  ' + res.getBody());
                
                //Response
                //map<String, Object> mapJsonData = new map<String, Object>();
                rawAuthorizationResponse = res.getBody();
                mapJsonData = (map<String, Object>)JSON.deserializeUntyped(res.getBody());
                System.debug('=mapJsonData='+mapJsonData);
                
                isSuccess = String.valueOf(mapJsonData.get('isSuccessStatusCode'));
                
                if(isSuccess == 'true'){
                    reqId = String.valueOf(mapJsonData.get('requestId'));
                    Planomatic_Order__c planomatic = new Planomatic_Order__c();
                    planomatic.Rental_Listing__c = rentalListingData.Id;
                    planomatic.Request_Id__c = reqId;
                    planomatic.External_Id__c = planoReq.externalId;
                    planomatic.Contact_Details__c = ContactDetails;
                    //planomatic.Preferred_Dates__c = PreferredDates;
                    planomatic.Lockbox_Code__c = lockboxCode;
                    planomatic.Planomatic_Order_Request__c = jsonBody;
                    planomatic.Notes_To_Planomatic__c = notes;
                    planomaticOrderList.add(planomatic);
                }
                
                
                orderResponse orderRes = new orderResponse();
                orderRes.isSuccessStatusCode = isSuccess;
                orderRes.requestId = String.valueOf(mapJsonData.get('requestId'));
                orderRes.errorMessage = String.valueOf(mapJsonData.get('errorMessage'));
                String orderResSerialize= JSON.serialize(orderRes);
                
                responseWrapper resWrap = new responseWrapper();
                resWrap.authenticationResponse = rawAuthenticationResponse;
                resWrap.authorizationResponse = rawAuthenticationResponse;
                String strResponse = JSON.serialize(resWrap);
                rawResponse = strResponse.replaceAll('\\\\', '');
                System.debug('-rawRequest2-'+rawRequest);
                //DebugLogHandler.logOutBoundResponse('PlanomaticCreateOrderController','planomaticOrder','',rawRequest,rawResponse);
            }
            
            if(planomaticOrderList.size()>0){
                insert planomaticOrderList;
                
                return true;
            }
            else{
                return false;
            }
            
        }
        catch(Exception exe){
            System.debug('-rawRequest-'+rawRequest);
            DebugLogHandler.logOutBoundException('PlanomaticCreateOrderController','planomaticOrder',exe.getStackTraceString(),exe.getMessage(),rawRequest,rawAuthenticationResponse,rawAuthorizationResponse);
            return false;
        }
    }
    
    @future(callout=true)
    public static void orderDetailsAutomation(String rentalListing,String accessDetailsSerialized){
        String rawRequest = '';
        String rawAuthenticationResponse = '';
        String rawAuthorizationResponse ='';
        String rawResponse ='';
        try{
            Map<String,sobject> accessDetailsMap = new Map<String,sobject>();
            if(accessDetailsSerialized!=null){
                accessDetailsMap = (Map<String, sobject>) JSON.deserialize(accessDetailsSerialized, Map<String, SObject>.class);
            }
            System.debug('-accessDetailsMap-'+accessDetailsMap);
            Map<String,Rental_Listing__c> leasingAvailabilityMap = new Map<String,Rental_Listing__c>();
            Map<String,Planomatic_Order__c> planomaticMap = new Map<String,Planomatic_Order__c>();
            Map<String,String> reqIdPlanomaticRecIdMap = new Map<String,String>();
            List<Planomatic_Order__c> planomaticOrderList = new List<Planomatic_Order__c>();
            List<Rental_Listing__c> rentalList =  new List<Rental_Listing__c>();
            Roofstock__mdt[] roofstockHostDetails = [SELECT MasterLabel, DeveloperName,User_Name__c,Password__c,CFS_URL__c,MicroService_URL__c FROM Roofstock__mdt];               
            // String username = roofstockHostDetails[0].User_Name__c;
            // String password = roofstockHostDetails[0].Password__c;
            // String cfsURL = roofstockHostDetails[0].CFS_URL__c;
            String microServiceURL = roofstockHostDetails[0].MicroService_URL__c;
            
            List<Rental_Listing__c> rentalListingList = (List<Rental_Listing__c>) JSON.deserialize(rentalListing, List<Rental_Listing__c>.class);
            // Planomatic 3D client list
            List<Planomatic_3D_Client__mdt> Planomatic3dClients = [SELECT Label FROM Planomatic_3D_Client__mdt];
            for( Planomatic_3D_Client__mdt client : Planomatic3dClients) {
                Planomatic3dClientList.add(client.Label);
            }
            for(Rental_Listing__c rentalListingData: rentalListingList){
                  
                System.debug('-pu id-'+rentalListingData.Property_Unit__c);
                map<String, Object> mapJsonData = new map<String, Object>();
                String isSuccess;
                String reqId;
                String jsonBody;
                planomaticRequest planoReq;
                String authenticationToken;
                if(!accessDetailsMap.isEmpty()){
                    if(accessDetailsMap.containskey(rentalListingData.Property_Unit__c)){
                        System.debug('-planoReq2-'+planoReq);
                        planoReq =  planomaticOrderDataPreparation(rentalListingData,accessDetailsMap,null);
                        System.debug('-planoReq2-'+planoReq);
                    }
                    else{
                        System.debug('no access code');
                        planoReq =  planomaticOrderDataPreparation(rentalListingData,null,null);
                    }
                }else{
                    planoReq =  planomaticOrderDataPreparation(rentalListingData,null,null);
                }
                
                /**** Planomatic Data start    ****/
                
                
                /**** Planomatic Data End   ***/
                
                
                System.debug('-planoReq-'+planoReq);
                //String PreferredDates;
                
                String lockboxCode = (planoReq.specialInstructions.split('\\. ')[0]).split(':')[1];                
                String ContactDetails = planoReq.specialInstructions.split('\\. ')[1];
                planoReq.specialInstructions = LABEL.Planomatic_Instruction+' '+planoReq.specialInstructions;                
                jsonBody = json.serialize(planoReq);
                jsonBody = jsonBody.remove('Lockbox Code:'+lockboxCode+'.');
                System.debug('-jsonBody-'+jsonBody.split('}'));
                List<String> jsonBodyList = jsonBody.split('}');
                
                for(String s:jsonBodyList){
                    System.debug('-s-'+s);
                }
                requestWrapper reqWrap = new requestWrapper();
                    reqWrap.recordId = rentalListingData.Id;
                    reqWrap.jsonBody = jsonBody;
                    String strReqWrap = JSON.serialize(reqWrap);
                    rawRequest = strReqWrap.replaceAll('\\\\', '');
                /*
                map<String, Object> mapJsonDataAuthentication = new map<String, Object>();
                String authenticationToken;
                // Generating the Access Token
                HttpRequest reqAccess = new HttpRequest();
                reqAccess.setMethod('POST');
                reqAccess.setEndpoint(cfsURL+'/api/auth/login');
                //reqAccess.setEndpoint('https://dev.roofstock.com/api/auth/login');
                reqAccess.setBody('grant_type=credential&username='+username+'&password='+password);
                reqAccess.setTimeout(120000);
                Http httpAccess = new Http();
                
                if(!Test.isRunningTest()){
                    HTTPResponse res = httpAccess.send(reqaccess);
                    requestWrapper reqWrap = new requestWrapper();
                    reqWrap.recordId = rentalListingData.Id;
                    reqWrap.jsonBody = jsonBody;
                    String strReqWrap = JSON.serialize(reqWrap);
                    rawRequest = strReqWrap.replaceAll('\\\\', '');
                    
                    rawAuthenticationResponse = res.getBody();
                    mapJsonDataAuthentication = (map<String, Object>)JSON.deserializeUntyped(res.getBody());
                    System.debug('=mapJsonDataAuthentication='+mapJsonDataAuthentication);
                    Object authResponse = mapJsonDataAuthentication.get('authResult');
                    map<String,Object> responseElement = (map<String,Object>) authResponse;
                    authenticationToken = (String) responseElement.get('jwtToken');
                    System.debug('=authenticationToken='+authenticationToken);
                }
                */
                roofstock__mdt rsdata = [SELECT id, RoofstockAuthToken_RS1__c, MicroService_URL__c FROM Roofstock__mdt WHERE developername = 'Roofstock'];
                System.debug('rs authtoken:: '+rsdata.RoofstockAuthToken_RS1__c);
                authenticationToken = rsdata.RoofstockAuthToken_RS1__c;
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(microServiceURL+'/-api/inspection-server/rest/photo/createOrder');
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                request.setHeader('Authorization', 'Bearer '+authenticationToken);
                request.setBody(jsonBody);
                request.setTimeout(120000);
                HttpResponse res = http.send(request);
                system.debug('DEBUGGING RESPOSE: ' + res.getStatusCode() + ' > ' + res.getStatus() + '  >  ' + res.getBody());
                
                //Response
                rawAuthorizationResponse = res.getBody();
                mapJsonData = (map<String, Object>)JSON.deserializeUntyped(res.getBody());
                System.debug('=mapJsonData='+mapJsonData);
                
                isSuccess = String.valueOf(mapJsonData.get('isSuccessStatusCode'));
                
                if(isSuccess == 'true'){
                    reqId = String.valueOf(mapJsonData.get('requestId'));
                    Planomatic_Order__c planomatic = new Planomatic_Order__c();
                    planomatic.Rental_Listing__c = rentalListingData.Id;
                    planomatic.Request_Id__c = reqId;
                    planomatic.External_Id__c = planoReq.externalId;
                    planomatic.Contact_Details__c = ContactDetails;
                    //planomatic.Preferred_Dates__c = PreferredDates;
                    planomatic.Lockbox_Code__c = lockboxCode;
                    planomatic.Planomatic_Order_Request__c = jsonBody;                    
                    planomaticOrderList.add(planomatic);
                    
                    Rental_Listing__c rental =  new Rental_Listing__c();
                    rental.Planomatic_Order_created__c = true;
                    rental.Id = rentalListingData.Id;
                    rentalList.add(rental);
                }
                
                
                orderResponse orderRes = new orderResponse();
                orderRes.isSuccessStatusCode = isSuccess;
                orderRes.requestId = String.valueOf(mapJsonData.get('requestId'));
                orderRes.errorMessage = String.valueOf(mapJsonData.get('errorMessage'));
                String orderResSerialize= JSON.serialize(orderRes);
                
                responseWrapper resWrap = new responseWrapper();
                resWrap.authenticationResponse = rawAuthenticationResponse;
                resWrap.authorizationResponse = rawAuthenticationResponse;
                String strResponse = JSON.serialize(resWrap);
                rawResponse = strResponse.replaceAll('\\\\', '');
                //DebugLogHandler.logOutBoundResponse('PlanomaticCreateOrderController','planomaticOrder','',rawRequest,rawResponse);                
            }
            
            if(planomaticOrderList.size()>0){
                insert planomaticOrderList;
                update rentalList;
            }
            
        }
        catch(Exception exe){
            DebugLogHandler.logOutBoundException('PlanomaticCreateOrderController','planomaticOrder',exe.getStackTraceString(),exe.getMessage(),rawRequest,rawAuthenticationResponse,rawAuthorizationResponse);
            
        }
        
    }
    public static planomaticRequest planomaticOrderDataPreparation(Rental_Listing__c rentalListingData,Map<String,sobject> accessDetailsMap, String notes){
        String lockboxCode='';
        String selfShowingLockboxNumber='';
        String accessDetailObj;
        String sObjectType;
        Boolean isBLVDproperty = false;
        String poNotes ='';
        if(accessDetailsMap!=null){
            accessDetailObj = JSON.serialize(accessDetailsMap);
            sObjectType= String.valueOf(accessDetailObj.substringAfter('type":').split(',')[0].substringBetween('"'));
        }
        System.debug('-accessDetailObj-'+accessDetailObj);
        System.debug('-sObjectType-'+sObjectType);
        /** Contact Information **/
        Map<String,List<Planomatic_Contact_Information__mdt>> planomaticCityContactMap = new Map<String,List<Planomatic_Contact_Information__mdt>>();
        Map<String, Planomatic_Contact_Information__mdt> planomaticContactMap = Planomatic_Contact_Information__mdt.getAll();
        //System.debug('-planomaticContactMap-'+planomaticContactMap);
        for(String planomaticCon : planomaticContactMap.keySet()){
            // System.debug('-planomaticCon-'+planomaticCon);
            // System.debug('-planomaticCon-'+planomaticContactMap.get(planomaticCon));
            Planomatic_Contact_Information__mdt pc = planomaticContactMap.get(planomaticCon);
            //System.debug('-pc-'+pc);
            if(planomaticCityContactMap.containsKey((pc.City__c).toLowerCase())) {
                
                //System.debug('-pc-'+pc.City__c);
                List<Planomatic_Contact_Information__mdt> planomaticContactList = planomaticCityContactMap.get((pc.City__c).toLowerCase());
                planomaticContactList.add(pc);
                planomaticCityContactMap.put((pc.City__c).toLowerCase(), planomaticContactList);
                //System.debug('-planomaticCityContactMap-'+planomaticCityContactMap);
            } else {
                
                planomaticCityContactMap.put((pc.City__c).toLowerCase(), new List<Planomatic_Contact_Information__mdt> {pc });
                //System.debug('-planomaticCityContactMap-'+planomaticCityContactMap);
            }
            
            
        }
        List<Planomatic_Contact_Information__mdt> planomaticContactDetailsList;
        if(planomaticCityContactMap.containsKey((rentalListingData.Property_Unit__r.Property__r.City__c).toLowerCase())){
            planomaticContactDetailsList = planomaticCityContactMap.get((rentalListingData.Property_Unit__r.Property__r.City__c).toLowerCase());
        }
        else{
            planomaticContactDetailsList = planomaticCityContactMap.get('default');
            
        }
        System.debug('-planomaticContactDetailsList-'+planomaticContactDetailsList);
        String contactInfo = '';
        for(Planomatic_Contact_Information__mdt pci : planomaticContactDetailsList){
            contactInfo = contactInfo+'Name:'+pci.MasterLabel+',Phone:'+pci.Phone__c+',Email:'+pci.Email__c+';';
        }
        System.debug('-planomaticCityContactMap-'+planomaticCityContactMap);
        System.debug('-contactInfo-'+contactInfo);
        /**   Preferred date/time**/
        //String PreferredDatetime = PreferredDatetime();
        System.debug('-rentalListingData-'+rentalListingData);
        System.debug('-name-'+rentalListingData.Name);
        //System.debug('-rentalListingData-'+rentalListingData);
        
        if(rentalListingData!=null){
            if(Planomatic3dClientList.contains(rentalListingData.Property_Unit__r.Client__c)) {
                isBLVDproperty = true;
            }
            if(rentalListingData.name!=null && rentalListingData.Property_Unit__r.Lockbox_Code__c == null) {
                if(rentalListingData.Property_Unit__r.HomeCode__c!=null){
                    if(isBLVDproperty){
                        lockboxCode = '21'+(rentalListingData.name).split(' ')[0].left(2);
                        //isBLVDproperty = true;
                    }
                    else{
                        lockboxCode = '20'+(rentalListingData.name).split(' ')[0].right(2);
                    }
                }
                else{
                        lockboxCode = '20'+(rentalListingData.name).split(' ')[0].right(2);

                }
                
            } else if (rentalListingData.name != null && rentalListingData.Property_Unit__r.Lockbox_Code__c != null) {
                lockboxCode = rentalListingData.Property_Unit__r.Lockbox_Code__c;
            }
        }
        System.debug('-lockboxCode-'+lockboxCode);
        
        if(sObjectType == 'Job__c'){
            Job__c obj =   (Job__c) accessDetailsMap.values()[0]; 
            System.debug('--'+obj.Lockbox_Code__c);
            // lockboxCode = obj.Lockbox_Code__c;
            selfShowingLockboxNumber = obj.Self_Showing_Lockbox__c;
        }
        else if(sObjectType == 'Turn__c'){
            Turn__c obj =   (Turn__c) accessDetailsMap.values()[0]; 
            System.debug('--'+obj.Lockbox_Code__c);
            // lockboxCode = obj.Lockbox_Code__c;
            selfShowingLockboxNumber = obj.Self_Showing_Lockbox__c;
        }
        planomaticRequest planoReq = new planomaticRequest();
        planoReq.source = 'SalesForce';
        planoReq.externalId = getUUID();
        if(notes != null && notes != '') {
            poNotes = ' Notes:'+notes+'. ';
        }
        
        //planoReq.specialInstructions = 'Lockbox Code:'+lockboxCode+'. '+'Self Showing Lockbox #:'+selfShowingLockboxNumber+'. '+
        //  'Contact Info:'+contactInfo+'. '+PreferredDatetime;
        planoReq.specialInstructions = 'Lockbox Code:'+lockboxCode+'. '+
                                       'Contact Info:'+contactInfo+'.'+poNotes;
                                       
        System.debug('-Special Instructions-'+JSON.serialize(planoReq.specialInstructions));
        Client clnt = new Client();
        clnt.postalCode = '75201';
        clnt.email = 'marketing@streetlane.com';
        clnt.firstName = 'Streetlane';
        clnt.lastName = 'Homes';
        clnt.phoneMobile = '888-402-6913';
        
        planoReq.client = clnt;
        
        primaryService ps = new primaryService();
        ps.serviceName = 'photopack';
        ps.quantity = 15;

        addOnServices addon = new addOnServices();  
        List<addOnServices> addOnList = new List<addOnServices>();  
        if (isBLVDproperty) {
            addon.serviceName = 'matterport_corp_add_on';
            addon.quantity = 1;
            addOnList.add(addOn);
        }
        
        planoReq.addOnServices = addOnList;
        planoReq.primaryService = ps;
        
        //All fields available in Property Object
        Address adrs = new Address();
        adrs.address1 = rentalListingData.Property_Unit__r.Property__r.Street_Address__c;
        adrs.city = rentalListingData.Property_Unit__r.Property__r.City__c;
        adrs.country = 'US';
        adrs.postalCode =rentalListingData.Property_Unit__r.Property__r.Zip__c;
        adrs.stateOrProvince = rentalListingData.Property_Unit__r.Property__r.State__c;
        
        PropertyInfo pi = new PropertyInfo();
        pi.address = adrs;
        pi.bathrooms = Integer.valueOf(rentalListingData.Property_Unit__r.Bathrooms__c);
        pi.bedrooms=Integer.valueOf(rentalListingData.Property_Unit__r.Bedrooms__c);
        if(!String.isEmpty(String.valueOf(rentalListingData.Property_Unit__r.Property__r.Seller_Provided_List_Price__c))){
            pi.listPrice=rentalListingData.Property_Unit__r.Property__r.Seller_Provided_List_Price__c;
        }
        else{
            pi.listPrice = 0.0;
        }
        pi.rsPropertyType='House';
        pi.squareFeet =Integer.valueOf(rentalListingData.Property_Unit__r.Property__r.Square_Feet__c);
        pi.unitCode = rentalListingData.Property_Unit__r.HomeCode__c;
        planoReq.PropertyInfo = pi;
        
        PropertyAccess pa = new PropertyAccess();
        pa.accessType = 'lockbox_code';
        pa.accessCode = lockboxCode;
        pa.propertyVacant = true;
        planoReq.PropertyAccess = pa;
        
        System.debug('-planoReq-'+planoReq);
        return planoReq;
        
    }
    public static String getUUID()
    {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        system.debug(guid);
        return guid;
    }

    
    public class orderResponse{
        public String isSuccessStatusCode;
        public String errorMessage;
        public string requestId;
    }
    public class requestWrapper{
        public string recordId;
        public string jsonBody;
    }
    public class responseWrapper{
        public string authenticationResponse;
        public string authorizationResponse;
    }
}
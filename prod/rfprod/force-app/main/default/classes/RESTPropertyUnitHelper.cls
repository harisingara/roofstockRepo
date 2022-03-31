// May 2 4:10pm

global class RESTPropertyUnitHelper {
    global class PropertyWrap{
        global List<PropertyWrapper> propertyList;
    }
    public static PropertyWrap parse(String json) {
        return (PropertyWrap) System.JSON.deserialize(json, PropertyWrap.class);
    }
    global class PropertyWrapper {
        //property address (101-105 main street)
        global string address;
        //RS property id
        global string propertyId;
        //Yardi property code
        global string propertyCode;
        //property type
        global string type;
        //building year built
        global String yearBuilt;
        //name of the market
        global string leasingMarket;
        global String propertyStatus;
        global String yardiNotes;

        global integer fundId;
        global integer ownerEntityId;
        global String listingChannel;
        
        //RC-11544
        global String sfrRegion;
        global String city;
        global String state;
        global String county;
        global String zip;
        global String client;
        global String streetAddress;
        global String squareFeet;
        //PMC2022-87
        global Boolean hasPool;
        
        //RC-13708
        global String inspectedSquareFeet;

        //RC-RC-12296
        global Boolean isHoa;
        global Boolean isBuildToRent;
        
        // Added as part of Rehab Migration 
        global String bpmPropertyUrl; 
        global String bpmOfferStatus; 
        global String bpmListingSource; 
        global String bpmBuyer;
        global String sellerAgentEmail; 
        global date purchaseDate; 
        global decimal uwRehabCostOffer; 
        global decimal uwRehabCostClose; 
        global decimal oversightFee;
        
        //RC-13708
        global String propertyRecordType;
        
        //PMC-349
        global String propertyMgmtCompany;
	
	// PMC-372
        global String bpmTransactionId;
        
        //PMC2022-183
        global String wasteSystem;
        global String filterDelivery;
        
        //property instance id
        //global string propertyRiid;   
        //units for this property
        global List<PropertyUnitWrapper> units;
        global boolean hasPhotos;
        global decimal previousYearTaxes;
        global decimal insuranceEstimate;
        global decimal counterOffer;
        global String apn;
        global String legalDescription;
        
    }
    
    global class PropertyUnitWrapper {
        //unit address (101 main st, 102 main st..)
        global string address;
        //unit number in the address 101
        global string unitNumber;
        //RS unit instance id
        global string unitId;
        //yardi id, used as product code
        global string homeCode;
        //bed/bath
        global double bedrooms;
        global double bathrooms;
        // RS transaction id
        global string rsTransactionid;
        //yardi unit status
        global string yardiUnitStatus;
        //yardi unit id
        global string yardiUnitId;
        //yardi market rent
        global decimal yardiMarketRent;
        //yardi dates
        global date yardiAvailableDate;
        global date yardiDateReady;
        global date yardiLeaseEnd;
        global date yardiLeaseStart;
        global date yardiLeaseSigned;
        global date yardiMoveIn;
        global date yardiMoveOut;
        global string operatingReason;
        global string operatingStatus;
        global string occupancyStatus;
        //yardi uwrent rent
        global decimal uwrent;
        // added as part of Rehab migration 
        global decimal estRehabCost;
        
        //RC-13708
        global decimal inspectedBedrooms;
        global decimal inspectedBathrooms;
        global String inspectedSquareFeet;
        global String squareFeet;

        // PMC-349
        global String tenantStatus;

        //PMC2022-87
        global String utilityResponsibility;
        global String latchelIntegrationType;
        
    }
    global class PostResponse {
        global ResponseWrapper responseBody;
        global PostResponse(
            List<ResponseBody> propertiesResponse,
            List<ResponseBody> unitsResponse
        ) {
            this.responseBody = new ResponseWrapper(
                propertiesResponse,
                unitsResponse
            );
        }
    }
    
    global class ResponseWrapper {
        global List<ResponseBody> propertiesResponse;
        global List<ResponseBody> unitsResponse;
        global ResponseWrapper() {
            propertiesResponse = new List<ResponseBody>();
            unitsResponse = new List<ResponseBody>();
        }
        global ResponseWrapper(
            List<ResponseBody> propertiesResponse,
            List<ResponseBody> unitsResponse
        ) {
            this.propertiesResponse = propertiesResponse;
            this.unitsResponse = unitsResponse;
        }
    }
    
    global class ResponseBody {
        global String rsId;
        global String salesforceId;
        global ResponseBody(String rsId, String salesforceId) {
            this.rsId = rsId;
            this.salesforceId = salesforceId;
        }
    }
    
    global static PostResponse AddPropertyUnit(
        list<PropertyWrapper> propertyList
    ) {
        system.debug('execute*******');
        Id leasingPropertyRecordTypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByDeveloperName()
            .get('Leasing')
            .getRecordTypeId();
        
        Id fundAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Fund')
            .getRecordTypeId();
        
        Id ownerEntityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Owner_Entity')
            .getRecordTypeId();
        
        //RC-13708
        Id roofstockPropertyRecordTypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByDeveloperName()
            .get('Roofstock')
            .getRecordTypeId();
        
        Id assetManagementPropertyRecordTypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByDeveloperName()
            .get('Asset_Management')
            .getRecordTypeId();
        
        
        List<Account> fundOwners =  [select id, Fund_ID__c, Owner_Entity_ID__c from Account where 
                                     recordtypeid in (:fundAccountRecordTypeId, :ownerEntityAccountRecordTypeId) ]  ;
        Map<String,String> propertyRecTypeMap = new Map<String,String>();
        List<RecordType> propertyRecTypeList =  [select Name,Id from RecordType where sObjectType='Property2__c'];
        for(RecordType rt :propertyRecTypeList){
            propertyRecTypeMap.put(rt.Name,rt.Id);      
        }
        System.debug('=propertyRecTypeMap='+propertyRecTypeMap);
        Map<Decimal, id> fundsMap= new Map<Decimal,id>();
        Map<Decimal, id> ownerEntitiesMap= new Map<Decimal,id>();
        
        for(Account fundOwner : fundOwners){
            if(fundOwner.Fund_ID__c != null){
                fundsMap.put(fundOwner.Fund_ID__c, fundOwner.id);
            } else if(fundOwner.Owner_Entity_ID__c != null){
                ownerEntitiesMap.put(fundOwner.Owner_Entity_ID__c, fundOwner.id);
            } 
            // else {
            //   //control should not reach here, it should be either fund or owner entity
            // }
        }
        
        
        List<ResponseBody> unitsResponseList = new List<ResponseBody>();
        List<ResponseBody> propertiesResponseList = new List<ResponseBody>();
        
        //create  property if does not exist
        
        Map<String, PropertyUnitWrapper> unitLookup = new Map<String, PropertyUnitWrapper>();
        List<string> rsTransactionIds = new List<string>();
        List<Property2__c> updatedPropertiesList = new List<Property2__c>();
        List<Property_Unit__c> propertyUnitsList = new List<Property_Unit__c>();
        List<Property_Unit__c> propertyUnitsAssetMgmtList = new List<Property_Unit__c>();
        List<Inspection__c> inspectionsList = new List<Inspection__c>();
        Map<String,Property2__c> propertyMap = new Map<String,Property2__C>();
        Set<String> setConEmailIds = new Set<String>(); 
        map<String,Id> mapSellerConId = new map<String,Id>(); 
        List<String> transactionIdList = new List<String>(); // PMC-372
        Map<String, Id> transIdsMap = new Map<String, Id>(); // PMC-372
        List<String> propertyClientList = new List<String>();
        // Iterate to find all the seller agent based on email
        List<String> listOfacw =  new list<String>();
        List<Acceptance_Walk_client__mdt> acWalk = [SELECT Label FROM Acceptance_Walk_client__mdt];
        for( Acceptance_Walk_client__mdt acw : acWalk) {
            listOfacw.add(acw.Label);
        }
        for (PropertyWrapper property : propertyList) {
            system.debug('property.sellerAgentEmail ???'+ property.sellerAgentEmail ); 
            if(property.sellerAgentEmail <>null && property.sellerAgentEmail <> '' )
                setConEmailIds.add(property.sellerAgentEmail); 
            if(listOfacw.contains(property.client) && property.propertyRecordType == 'Asset Management') {
                propertyClientList.add(property.propertyId);
            }
        }
        if(!setConEmailIds.IsEmpty())
            // fetch all the contacts based on email ID 
            for(Contact oCn: [Select id,email from Contact where email IN:setConEmailIds]){
                mapSellerConId.put(oCn.email , oCn.Id);          
            }
        system.debug('testing mapSellerConId '+ mapSellerConId);
        //create a list to insert and list to update
        //
        for (PropertyWrapper property : propertyList) {
            //add more fields here
            
            Property2__c prop =   new Property2__c(
                PropertyId__c = property.propertyId,
                name = property.address,
                PropertyCode__c = property.propertyCode,
                Year_Built__c = property.yearBuilt,
                Leasing_Market__c  = property.leasingMarket,
                Yardi_Notes__c = property.yardiNotes,
                Property_Status__c = property.propertyStatus,
                // PMC2022-183
                Filter_Delivery__c  = property.filterDelivery,
                Waste_System__c  = property.wasteSystem,
                // RecordTypeId = propertyRecTypeMap.get(property.listingChannel),
                
                Property_Type__c = (String.IsEmpty(property.type) ||
                                    (String.IsNotEmpty(property.type) &&
                                     property.type.toLowercase() == 'unspecified')
                                    ? null
                                    : property.type),
                //recordtypeid = leasingPropertyRecordTypeId
                recordtypeid = propertyRecTypeMap.get(property.listingChannel)
            );
            if(property.IsHoa <> null){
                prop.HOA__c = property.IsHoa;
            }
            if(property.IsBuildToRent <> null){
                prop.Build_to_rent__c = property.IsBuildToRent;
            }
            if(property.fundId != null){
                prop.Fund_Name__c = fundsMap.get(property.fundId);
            }
            
            if(property.ownerEntityId != null){
                prop.Owner_Entity__c =  ownerEntitiesMap.get(property.ownerEntityId);
            }
            /*if(property.propertyRiid!=null){
                prop.Property_Riid__c = property.propertyRiid;
            }*/
            
            // PMC-349
            if(property.propertyMgmtCompany != null){
                prop.Property_Management_Company__c = property.propertyMgmtCompany;
            }

            //RC-11544
            if(property.sfrRegion!=null){
                prop.SFR_Region__c =  property.sfrRegion;   
            }
            if(property.city!=null){
                prop.City__c =  property.city;   
            }
            if(property.state!=null){
                prop.State__c =  property.state;   
            }
            if(property.county!=null){
                prop.County__c =  property.county;   
            }
            if(property.zip!=null){
                prop.Zip__c =  property.zip;   
            }
            if(property.client!=null){
                prop.Client__c =  property.client;   
            }
            if(property.streetAddress!=null){
                prop.Street_Address__c =  property.streetAddress;   
            }

            if(property.squareFeet!=null){
                prop.Square_Feet__c =  property.squareFeet;   
            }
            //RC-13708
            if(property.inspectedSquareFeet!=null){
                prop.Inspected_Square_Feet__c =  property.inspectedSquareFeet;   
            }
            
            // added as part of Rehab migration 
            if(property.bpmPropertyUrl!=null){
                prop.BPM_Property_URL__c =  property.bpmPropertyUrl;   
            }
            if(property.bpmOfferStatus!=null){
                prop.BPM_Status__c =  property.bpmOfferStatus;   
            }
            if(property.bpmListingSource!=null){
                prop.BPM_Source__c =  property.bpmListingSource;   
            }
            if(property.sellerAgentEmail!=null && mapSellerConId.containsKey(property.sellerAgentEmail)){
                prop.Seller_Agent__c =  mapSellerConId.get(property.sellerAgentEmail);      
            }
            if(property.purchaseDate!=null){
                prop.Purchase_Date__c =  property.purchaseDate;   
            }
            if(property.uwRehabCostOffer!=null){
                prop.UW_Rehab_Cost_Offer__c =  property.uwRehabCostOffer;   
            }
            if(property.uwRehabCostClose!=null){
                prop.UW_Rehab_Cost_Close__c  =  property.uwRehabCostClose;   
            }
            if(property.oversightFee!=null){
                prop.Oversight_Fee__c =  property.oversightFee;   
            }
            if(property.bpmBuyer!=null){
                prop.BPM_Buyer__c =  property.bpmBuyer;   
            } 
            
            if(property.apn != null){
                prop.APN__c = property.apn;
                if(property.apn.contains(Label.Blank_String_Value )){
                    prop.APN__c = '';
                }
            }
            if(property.legalDescription != null){
                prop.Legal_Description__c = property.legalDescription;
                if(property.legalDescription.contains(Label.Blank_String_Value )){
                    prop.Legal_Description__c = '';
                }
            }
            
            // PMC2022-87
            if(property.hasPool != null){
                prop.Has_Pool__c =  property.hasPool; 
            }
            //RC-13708
            if(property.propertyRecordType == 'Roofstock'){
                prop.RecordTypeId = roofstockPropertyRecordTypeId;
            }
            if(property.propertyRecordType == 'Asset Management'){
                prop.RecordTypeId = assetManagementPropertyRecordTypeId;
            }
            
            
            propertyMap.put(prop.PropertyId__c,prop);
            //updatedPropertiesList.add(prop);

            // PMC-372 check for BPM transection id
            If(property.bpmTransactionId != null && property.bpmTransactionId != ''){
                transactionIdList.add(property.bpmTransactionId);
            }
        }
        
        // PMC-372
        if (transactionIdList.size() > 0){
            for (Transaction__c trans : [SELECT id, name, Transaction_Id__c FROM Transaction__c where Transaction_Id__c IN :transactionIdList]) {
                transIdsMap.put(trans.Transaction_Id__c, trans.id);
            }

        }
        
        upsert propertyMap.values() PropertyId__c;
        //upsert updatedPropertiesList PropertyId__c;
        // Create Property Unit and its map 
        map<String,Property_Unit__c> mapPropertyUnitIds = new map<String,Property_Unit__c> ();
        Map<String,String> mapPropIdAndbpmTranId = new Map<String,String>();  // PMC-372
        Set<String> setassetmgmnt = new set<string>(); 
        Map<String,String> mapBPMpropIdAndId  = new Map<String,String>();
        for (Property2__c property : propertyMap.values()) {
            //for (Property2__c property : updatedPropertiesList) {
            mapBPMpropIdAndId.put(property.Id, property.PropertyId__c);
            PropertyWrapper originalProperty;
            //get units from passed properties!
            //seperate this into seperate function
            for (PropertyWrapper requestProperty : propertyList) {
                if (property.PropertyId__c == requestProperty.propertyId) {
                    originalProperty = requestProperty;
                    break;
                }
            }
            
            for (PropertyUnitWrapper propertyUnit : originalProperty.units) {
                System.debug('=propertyUnit='+propertyUnit);
                System.debug('=inspectedSquareFeet='+propertyUnit.inspectedSquareFeet);
                propertyUnitsList.add(
                    new Property_Unit__c(
                        name = propertyUnit.address,
                        Property__c = property.id,
                        BedRooms__c = propertyUnit.bedRooms,
                        Bathrooms__c = propertyUnit.bathrooms,
                        HomeCode__c = propertyUnit.homeCode,
                        PropertyUnitId__c = propertyUnit.unitId,
                        Yardi_Unit_Id__c  = propertyUnit.yardiUnitId,
                        Occupancy_Status__c = propertyUnit.occupancyStatus,
                        Operating_Status__c = propertyUnit.operatingStatus,
                        Operating_Reason__c = propertyUnit.operatingReason,
                        UW_Rent__c = propertyUnit.uwrent,
                        Move_In_Date__c = propertyUnit.yardiMoveIn,
                        Move_Out_Date__c = propertyUnit.yardiMoveOut, 
                        
                        //PMC-372
                        Unit_Status__c = propertyUnit.yardiUnitStatus,
                        Ready_Date__c = propertyUnit.yardiDateReady,
                        Lease_End__c = propertyUnit.yardiLeaseEnd,
                        Lease_Start__c = propertyUnit.yardiLeaseStart,
                        Lease_Signed__c = propertyUnit.yardiLeaseSigned,
                        Market_Rent__c = propertyUnit.yardiMarketRent,
                        Available_Date__c = propertyUnit.yardiAvailableDate,

                        // PMC2022-87
                        Utility_Responsibility__c = propertyUnit.utilityResponsibility,
                        Latchel_Integration_Type__c = propertyUnit.latchelIntegrationType,

                        Estimated_Rehab_Cost_Diligence__c = propertyUnit.estRehabCost,
                        //RC-13708
                        Inspected_Bathrooms__c = propertyUnit.inspectedBathrooms,
                        Inspected_Bedrooms__c = propertyUnit.inspectedBedrooms,
                        //Inspected_Square_Feet__c = Decimal.valueOf(propertyUnit.inspectedSquareFeet),
                        Inspected_Square_Feet__c = propertyUnit.inspectedSquareFeet!=null?Decimal.valueOf(propertyUnit.inspectedSquareFeet):0,
                        Square_Feet__c = propertyUnit.squareFeet!=null?Decimal.valueOf(propertyUnit.squareFeet):0,
                        // PMC-349
                        Tenant_Status__c = propertyUnit.tenantStatus
                    )
                );
                
                mapPropIdAndbpmTranId.put(property.id,originalProperty.bpmTransactionId);// PMC-372
        
                if(originalProperty.propertyRecordType == 'Asset Management'){
                              setassetmgmnt.add(propertyUnit.unitId);     
                }
                if( propertyUnit.rsTransactionid != null && propertyUnit.rsTransactionid != '')
                    rsTransactionIds.add(propertyUnit.rsTransactionid);
                
                if(!unitLookup.containsKey(propertyUnit.rsTransactionid))
                {
                    unitLookup.put(propertyUnit.rsTransactionid, propertyUnit);
                }
            }
        }
        
        upsert propertyUnitsList PropertyUnitId__c;
        List<Utilities__c> lstUtilities = new List<Utilities__c>(); 
        List<Id> propUnit =  new List<Id>();
        for(Property_Unit__c oUnit:propertyUnitsList) {
            propUnit.add(oUnit.Id);
               //PMC-372
               inspectionsList.add( new Inspection__c ( Property_Unit__c = oUnit.Id, Dilligence_Id__c = oUnit.PropertyUnitId__c, Inspection_type__C='Diligence', 
                                                       Transaction__c = (
                                                                           (mapPropIdAndbpmTranId.containskey(oUnit.Property__c) && transIdsMap.containskey(mapPropIdAndbpmTranId.get(oUnit.Property__c)))?
                                                                                transIdsMap.get(mapPropIdAndbpmTranId.get(oUnit.Property__c)):
                                                                                null
                                                                        )
                                                      ) 
                                  );
            if(setassetmgmnt.contains(oUnit.PropertyUnitId__c))
               lstUtilities.add(new Utilities__c( Property_Unit__c= oUnit.Id, Utility_ID__c = oUnit.PropertyUnitId__c));
            
        }
        
        upsert inspectionsList Dilligence_Id__c; 
        List<Job__c> jobList = [SELECT id, Property__c, Property_Unit__c FROM Job__c WHERE RecordType.Name = 'Acceptance Walk' and Property_unit__c in :propUnit ];
        List<Id> jobExistWithUnitId = new List<Id>();
        for(Job__c j : jobList) {
            jobExistWithUnitId.add(j.Property_unit__c);
        }
        List<Job__c> newAWJob = new List<Job__c>();
        Id acWalkRecTypeId = Schema.SObjectType.Job__c.getRecordTypeInfosByName().get('Acceptance Walk').getRecordTypeId();
        for(Property_Unit__c oUnit : propertyUnitsList) {
            
            if(!jobExistWithUnitId.contains(oUnit.Id) && propertyClientList.contains(mapBPMpropIdAndId.get(oUnit.Property__c))) {
                system.debug('oUnit.Operating_Reason__c::'+oUnit.Operating_Reason__c);
                if(oUnit.Operating_Reason__c == 'Tenant In Place' || oUnit.Operating_Reason__c == 'Temporary Occupancy Agreement' || oUnit.Operating_Reason__c == 'Leaseback') {
                    // create acceptance walk- waiting for move
                    newAWJob.add( new Job__c( Job_Status__c = 'Waiting for Move Out', RecordTypeId = acWalkRecTypeId,
                                              Property__c= oUnit.Property__c, Property_unit__c=oUnit.ID ));
                } else {
                    newAWJob.add( new Job__c( Job_Status__c = 'Awaiting Approval', RecordTypeId = acWalkRecTypeId,
                                              Property__c= oUnit.Property__c, Property_unit__c=oUnit.ID ));
                }
            }        
        }

        insert newAWJob;

        if(!lstUtilities.isEmpty()){
            Schema.SObjectField ftoken = Utilities__c.Fields.Utility_ID__c;
            Database.UpsertResult[] srList = Database.upsert(lstUtilities,ftoken,false);
            }
        
        if(rsTransactionIds <> null && rsTransactionIds.size() > 0){
            //update Property__c fields, lookup using rsTransactionId
            List<Property__c> pList = [SELECT Id, RS_TransactionId__c, Yardi_Unit_Status__c FROM Property__c WHERE RS_TransactionId__c IN :rsTransactionIds];
            
            for(Property__c p :pList){
                if(unitLookup.containsKey(p.RS_TransactionId__c))
                {
                    PropertyUnitWrapper unit = unitLookup.get(p.RS_TransactionId__c);
                    p.Yardi_Unit_Status__c = unit.yardiUnitStatus;
                    p.Yardi_Date_Ready__c = unit.yardiDateReady;
                    p.Yardi_Lease_End__c = unit.yardiLeaseEnd;
                    p.Yardi_Lease_Start__c = unit.yardiLeaseStart;
                    p.Yardi_Move_In__c = unit.yardiMoveIn;
                    p.Yardi_Move_Out__c = unit.yardiMoveOut;
                    p.Yardi_Market_Rent__c = unit.yardiMarketRent;
                }
            }
            
            update pList;
        }
        
        for (Property2__c property : propertyMap.values()) {
        //for (Property2__c property : updatedPropertiesList) {
            propertiesResponseList.add(
                new ResponseBody(property.PropertyId__c, property.id)
            );
        }
        
        for (Property_Unit__c unit : propertyUnitsList) {
            unitsResponseList.add(new ResponseBody(unit.PropertyUnitId__c, unit.id));
        }
        
        postResponse res = new postResponse(
            propertiesResponseList,
            unitsResponseList
        );
        
        return res;
    }
}
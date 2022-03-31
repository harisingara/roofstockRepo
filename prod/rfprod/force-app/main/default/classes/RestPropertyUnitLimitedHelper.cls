global class RestPropertyUnitLimitedHelper {
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
        global string yearBuilt;
        
        global string sellerEntity;
        global string streetAddress;
        global string city;
        global string state;
        global string zip;
        global string county;
        global string market;
        global string lotSize;
        global boolean hasPool;
        global string neighborhoodScore;
        global string elementarySchoolScore;
        global string middleSchoolScore;
        global string highSchoolScore;
        global boolean inFloodZone;
        global Decimal monthlyHOAFee;
        global Decimal listPrice;
        global Decimal yearlyInsurance;
        global Decimal yearlyPropertyTaxes;
        global Decimal monthlyRent;
        global Decimal marketRent;
        global decimal collateralAnalyticsLowValue;
        global decimal collateralAnalyticsMidValue;
        global decimal collateralAnalyticsHighValue;
        global date collateralAnalyticsAvmRunDate;
        global decimal zillowLowValue;
        global decimal zillowMidValue;
        global decimal zillowHighValue;
        global decimal zillowRentLowValue;
        global decimal zillowRentMidValue;
        global decimal zillowRentHighValue;
        global date zillowAvmRunDate;
        global decimal zillowValueEstimate;
        global decimal zillowRentEstimate;
        global date zillowRentAVMRunDate;
        global string floodZone;
        global decimal rentRangeLow;
        global decimal rentRangeRentEstimate;
        global decimal rentRangeHigh;
        global date rentRangeRunDate;
        
        //units for this property
       // global List<String> portfolioIds;
        //global string portfolioId;

        global String squareFeet;
        
        //RC-13708
        global String inspectedSquareFeet;

        //RC-RC-12296
        global Boolean isHoa;
        global Boolean isBuildToRent;
        
        // Added as part of Rehab Migration 
        global String bpmPropertyUrl; 
        global String bpmOfferStatus; 
        global String bpmListingSource; 
        global String sellerAgentEmail; 
        global date purchaseDate; 
        global decimal uwRehabCostOffer; 
        global decimal uwRehabCostClose; 
        global decimal oversightFee;
        
        //PMC-37
        global decimal offerPrice;

        //RC-13708
        global String propertyRecordType;
        
        //PE-579
        global decimal bedrooms;
        global decimal bathrooms;
        global date bpoValuationDate;
        global date leaseStartDate;
        global date leaseEndDate;
        global decimal bpoValuation;
        global decimal sellerProvidedSecurityDeposit;
        global String occupancy;
        global boolean section8;
        global decimal salePrice;
        global boolean hasPhotos;
        global decimal previousYearTaxes;
        global decimal insuranceEstimate;
        global decimal counterOffer;
        global String apn;
        global String legalDescription;
         
        //units for this property
        global List<PropertyUnitWrapper> units;
        
         
        
    }
    
    global class PropertyUnitWrapper {
        //unit address (101 main st, 102 main st..)
        global string address;
        //RS unit instance id
        global string unitId;
        //yardi id, used as product code
        global string homeCode;
        //bed/bath
        global decimal bedrooms;
        global decimal bathrooms;
        // added as part of Rehab migration 
        global decimal estRehabCost;
        
        //RC-13708
        global decimal inspectedBedrooms;
        global decimal inspectedBathrooms;
        global String inspectedSquareFeet;
        global String squareFeet;

        //PMC-38 add Diligent object values
        global Decimal estimatedCapexManual;
        global Decimal estimatedRentUW;
        
        global boolean isSection8;
        global String occupancy;
        global Date leaseStart;
        global Date leaseEnd;
        global Decimal securityDeposit;
        
        //PE-579
        global String unitNumber;
        global decimal monthlyRent;
        global decimal leasingBalance;
        global decimal leasingBalanceZeroTo30Days;
        global decimal leasingBalance30To60Days;
        global decimal leasingBalance60To90Days;
        global decimal leasingBalanceOver90Days;
        global Date leasingBalanceDate;
        global Decimal marketRent;
        
        //TRN-415
        global String propertyAccessNotes;
        global String propertyAccessMethodType;
    }
    
    /*global class PropertyIdWrapper{
        global string portfolioId;
        global PropertyIdWrapper(string id){
            this.portfolioId = id;
        }
    }*/
    
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
    
    global static PostResponse AddPropertyUnit( list<PropertyWrapper> propertyList) {
        system.debug('execute*******');
        Map<String,String> propertyRecTypeMap = new Map<String,String>();
        Map<Decimal, id> fundsMap= new Map<Decimal,id>();
        Map<Decimal, id> ownerEntitiesMap= new Map<Decimal,id>();
        List<ResponseBody> unitsResponseList = new List<ResponseBody>();
        List<ResponseBody> propertiesResponseList = new List<ResponseBody>();
        List<Portfolio__c> portfoliosToCreate = new List<Portfolio__c>();
        
        Map<String, PropertyUnitWrapper> unitLookup = new Map<String, PropertyUnitWrapper>();
        List<string> rsTransactionIds = new List<string>();
        List<Property2__c> updatedPropertiesList = new List<Property2__c>();
        List<Property_Unit__c> propertyUnitsList = new List<Property_Unit__c>();
        List<Property_Unit__c> propertyUnitsAssetMgmtList = new List<Property_Unit__c>();
        // Commented default Diligence creation for each property unit and syncing the Inspection records directly from BPM
        //List<Diligence__c> diligencesList = new List<Diligence__c>();
        Map<String,Property2__c> propertyMap = new Map<String,Property2__C>();
        Set<String> setConEmailIds = new Set<String>(); 
        map<String,Id> mapSellerConId = new map<String,Id>();
        
        Set<String> portfolioIdSet = new Set<String>();
        Set<String> existportfolioIdSet = new Set<String>();
        
        Id leasingPropertyRecordTypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByDeveloperName().get('Leasing').getRecordTypeId();
        Id fundAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Fund').getRecordTypeId();
        Id ownerEntityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Owner_Entity').getRecordTypeId();
        
        //RC-13708
        Id roofstockPropertyRecordTypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByDeveloperName().get('Roofstock').getRecordTypeId();
        Id assetManagementPropertyRecordTypeId = Schema.SObjectType.Property2__c.getRecordTypeInfosByDeveloperName().get('Asset_Management').getRecordTypeId();
       
        List<Account> fundOwners =  [select id, Fund_ID__c, Owner_Entity_ID__c from Account where 
                                     recordtypeid in (:fundAccountRecordTypeId, :ownerEntityAccountRecordTypeId) ]  ;
        
        List<RecordType> propertyRecTypeList =  [select Name,Id from RecordType where sObjectType='Property2__c'];
        for(RecordType rt :propertyRecTypeList){
            propertyRecTypeMap.put(rt.Name,rt.Id);      
        }
        System.debug('=propertyRecTypeMap='+propertyRecTypeMap);
        
        
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
        
        
      
        
        // Iterate to find all the seller agent based on email
        for (PropertyWrapper property : propertyList) {
            system.debug('property.sellerAgentEmail ???'+ property.sellerAgentEmail ); 
            if(property.sellerAgentEmail <>null && property.sellerAgentEmail <> '' ){
                setConEmailIds.add(property.sellerAgentEmail); 
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
            system.debug('check'+ property.propertyId);
            Property2__c prop =   new Property2__c(
                PropertyId__c = property.propertyId,
                name = property.address,
                PropertyCode__c = property.propertyCode,
                //Year_Built__c = property.yearBuilt,
               // Leasing_Market__c  = property.leasingMarket,
                // RecordTypeId = propertyRecTypeMap.get(property.listingChannel),
                
                Property_Type__c = (String.IsEmpty(property.type) ||
                                    (String.IsNotEmpty(property.type) &&
                                     property.type.toLowercase() == 'unspecified')
                                    ? null
                                    : property.type)
                //recordtypeid = leasingPropertyRecordTypeId
              //  recordtypeid = propertyRecTypeMap.get(property.listingChannel)
            );
            if(property.IsHoa <> null){
                prop.HOA__c = property.isHoa;
            }
            if(property.IsBuildToRent <> null){
                prop.Build_to_rent__c = property.isBuildToRent;
            }
            
            if(property.yearBuilt !=null){
                prop.Year_Built__c =  property.yearBuilt;   
                if(property.yearBuilt.contains(Label.Blank_String_Value )){
                    prop.Year_Built__c = '';
                }
            }
          
            if(property.squareFeet!=null){
                prop.Square_Feet__c =  property.squareFeet;   
                if(property.squareFeet.contains(Label.Blank_String_Value )){
                    prop.Square_Feet__c = '';
                }
            }
            //RC-13708
            if(property.inspectedSquareFeet!=null){
                prop.Inspected_Square_Feet__c =  property.inspectedSquareFeet; 
                if(property.inspectedSquareFeet.contains(Label.Blank_String_Value )){
                    prop.Inspected_Square_Feet__c = '';
                }
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
                if(property.purchaseDate == Date.parse(Label.Blank_Date_Value)){
                    prop.Purchase_Date__c = null;
                }
            }
            if(property.uwRehabCostOffer!=null){
                prop.UW_Rehab_Cost_Offer__c =  property.uwRehabCostOffer;   
                if(property.uwRehabCostOffer == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.UW_Rehab_Cost_Offer__c = null; 
                }
            }
            if(property.uwRehabCostClose!=null){
                prop.UW_Rehab_Cost_Close__c  =  property.uwRehabCostClose;   
                if(property.uwRehabCostClose == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.UW_Rehab_Cost_Close__c = null; 
                }
            }
            if(property.oversightFee!=null){
                prop.Oversight_Fee__c =  property.oversightFee;   
                if(property.oversightFee == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Oversight_Fee__c = null;   
                }
            }

            if(property.offerPrice!=null){
                prop.Offer_Price__c =  property.offerPrice;  
                if(property.offerPrice == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Offer_Price__c = null; 
                }
            }
            
            if(property.propertyRecordType == 'Roofstock'){
                prop.RecordTypeId = roofstockPropertyRecordTypeId;
            }
            if(property.propertyRecordType == 'Asset Management'){
                prop.RecordTypeId = assetManagementPropertyRecordTypeId;
            }
            
            if(property.sellerEntity != null){
                prop.Seller_Entity__c = property.sellerEntity;
                if(property.sellerEntity.contains(Label.Blank_String_Value )){
                    prop.Seller_Entity__c = '';
                }
            }
            if(property.streetAddress != null){
                prop.Street_Address__c = property.streetAddress;
                if(property.streetAddress.contains(Label.Blank_String_Value )){
                    prop.Street_Address__c = '';
                }
            }
            if(property.city != null){
                prop.City__c =  property.city;   
                if(property.city.contains(Label.Blank_String_Value )){
                    prop.City__c = '';
                }
            }
            if(property.state != null){
                prop.State__c =  property.state; 
                if(property.state.contains(Label.Blank_String_Value )){
                    prop.State__c = '';
                }
            }
            if(property.zip != null){
                prop.Zip__c =  property.zip;  
                if(property.zip.contains(Label.Blank_String_Value )){
                    prop.Zip__c = '';
                }
            }
             
            
            if( property.county != null ){
                prop.County__c =  property.county;   
                if(property.county.contains(Label.Blank_String_Value )){
                    prop.County__c = '';
                }
            }
            if(property.market != null){
                prop.Market__c =  property.market; 
                 if(property.market.contains(Label.Blank_String_Value )){
                    prop.Market__c = '';
                }
            }
            if(property.lotSize != null){
                prop.Lot_Size__c = property.lotSize;
                 if(property.lotSize.contains(Label.Blank_String_Value)){
                    prop.Lot_Size__c = '';
                }
            }
            if(property.hasPool !=null){
                prop.Has_Pool__c =  property.hasPool;   
            }
            if(property.neighborhoodScore!=null){
                prop.Neighborhood_Score__c =  property.neighborhoodScore;
                if(property.neighborhoodScore.contains(Label.Blank_String_Value )){
                    prop.Neighborhood_Score__c = '';
                }
            }
            if(property.elementarySchoolScore!=null){
                prop.Elementary_School_Score__c =  property.elementarySchoolScore;  
                if(property.elementarySchoolScore.contains(Label.Blank_String_Value )){
                    prop.Elementary_School_Score__c = '';
                }
            }
            if(property.middleSchoolScore!=null){
                prop.Middle_School_Score__c =  property.middleSchoolScore;   
                if(property.middleSchoolScore.contains(Label.Blank_String_Value )){
                    prop.Middle_School_Score__c = '';
                }
            }
            if(property.highSchoolScore !=null){
                prop.High_School_Score__c =  property.highSchoolScore;  
                if(property.highSchoolScore.contains(Label.Blank_String_Value )){
                    prop.High_School_Score__c = '';
                }
            }
            if(property.inFloodZone!=null){
                prop.In_Flood_Zone__c =  property.inFloodZone;   
            }
            if(property.monthlyHOAFee != null){
                prop.Seller_Provided_Monthly_HOA_Fee__c = property.monthlyHOAFee;
                if(property.monthlyHOAFee == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Seller_Provided_Monthly_HOA_Fee__c = null; 
                }
            }
            if(property.listPrice != null){
               prop.Seller_Provided_List_Price__c = property.listPrice;
                if(property.listPrice == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Seller_Provided_List_Price__c = null;  
                }
            }
            if(property.yearlyInsurance != null){
               prop.Seller_Provided_Yearly_Insurance__c = property.yearlyInsurance;
                if(property.yearlyInsurance == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Seller_Provided_Yearly_Insurance__c = null;    
                }
            }          
            if(property.yearlyPropertyTaxes != null){         
               prop.Seller_Provided_Yearly_Property_Taxes__c = property.yearlyPropertyTaxes;
               if(property.yearlyPropertyTaxes == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Seller_Provided_Yearly_Property_Taxes__c = null;   
               }
            }
            
            if(property.monthlyRent != null ){
              prop.Seller_Provided_Monthly_Rent__c = property.monthlyRent;
               if(property.monthlyRent == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Seller_Provided_Monthly_Rent__c = null;    
               }
            }
            if(property.marketRent != null){
               prop.Seller_Provided_Market_Rent__c = property.marketRent;
               if(property.marketRent == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Seller_Provided_Market_Rent__c = null; 
               }
            }
                        
            System.debug('prop.Seller_Provided_Yearly_Property_Taxes__c::'+prop.Seller_Provided_Yearly_Property_Taxes__c +'--property.yearlyPropertyTaxes::'+property.yearlyPropertyTaxes);
            if(property.collateralAnalyticsLowValue !=null){
                prop.Collateral_Analytics_Low_Value__c =  property.collateralAnalyticsLowValue; 
                if(property.collateralAnalyticsLowValue == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Collateral_Analytics_Low_Value__c = null;  
                }
            }
            if(property.collateralAnalyticsMidValue!=null){
                prop.Collateral_Analytics_Mid_Value__c =  property.collateralAnalyticsMidValue; 
                if(property.collateralAnalyticsMidValue == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Collateral_Analytics_Mid_Value__c = null;  
                }
            }
            if(property.collateralAnalyticsHighValue !=null){
                prop.Collateral_Analytics_High_Value__c =  property.collateralAnalyticsHighValue;   
                if(property.collateralAnalyticsHighValue == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Collateral_Analytics_High_Value__c = null; 
                }
            }
            if(property.zillowLowValue!=null){
                prop.Zillow_Low_Value__c =  property.zillowLowValue;   
                if(property.zillowLowValue == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Zillow_Low_Value__c = null;    
                }
            }
            if(property.zillowMidValue != null){
                prop.Zillow_Mid_Value__c =  property.zillowMidValue;
                if(property.zillowMidValue == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Zillow_Mid_Value__c = null;    
                }
            }
            if(property.zillowHighValue != null){
                prop.Zillow_High_Value__c =  property.zillowHighValue; 
                if(property.zillowHighValue == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Zillow_High_Value__c = null;   
                }
            }
            if(property.zillowRentLowValue != null){
                prop.Zillow_Rent_Low_Value__c =  property.zillowRentLowValue;  
                if(property.zillowRentLowValue == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Zillow_Rent_Low_Value__c = null;   
                }
            }
            if(property.zillowRentMidValue != null){
                prop.Zillow_Rent_Mid_Value__c =  property.zillowRentMidValue; 
                if(property.zillowRentMidValue == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Zillow_Rent_Mid_Value__c = null;   
                }
            }
            if(property.zillowRentHighValue!=null){
                prop.Zillow_Rent_High_Value__c =  property.zillowRentHighValue;   
                if(property.zillowRentHighValue == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Zillow_Rent_High_Value__c = null;  
                }
            }
            if(property.zillowAvmRunDate != null){
                prop.Zillow_AVM_Run_Date__c = property.zillowAvmRunDate;
                if(property.zillowAvmRunDate == Date.parse(Label.Blank_Date_Value)){
                    prop.Zillow_AVM_Run_Date__c = null;
                }
            }
            
            if(property.ZillowValueEstimate != null){
                prop.Zillow_Value_Estimate__c= property.ZillowValueEstimate;
                if(property.ZillowValueEstimate == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Zillow_Value_Estimate__c= null;
                }
            }
            if(property.zillowRentEstimate != null){
                prop.Zillow_Rent_Estimate__c = property.zillowRentEstimate;
                if(property.zillowRentEstimate == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Zillow_Rent_Estimate__c = null;
                }
            }
            if(property.zillowRentAVMRunDate != null){
                prop.Zillow_Rent_AVM_Run_Date__c = property.zillowRentAVMRunDate;
                if(property.zillowRentAVMRunDate == Date.parse(Label.Blank_Date_Value)){
                    prop.Zillow_Rent_AVM_Run_Date__c = null;
                }
            }
            if(property.FloodZone != null){
                prop.Flood_Zone__c = property.FloodZone;
                if(property.FloodZone == (Label.Blank_String_Value)){
                    prop.Flood_Zone__c = null;
                }
            }
            if(property.rentRangeLow != null){
                prop.Rent_Range_Low__c = property.rentRangeLow;
                if(property.rentRangeLow== Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Rent_Range_Low__c = null;
                }
            }
            if(property.RentRangeRentEstimate!= null){
                prop.Rent_Range_Rent_Estimate__c = property.RentRangeRentEstimate;
                if(property.RentRangeRentEstimate== Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Rent_Range_Rent_Estimate__c = null;
                }
            }
            if(property.RentRangeHigh != null){
                prop.Rent_Range_High__c = property.RentRangeHigh ;
                if(property.RentRangeHigh == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Rent_Range_High__c = null;
                }
            }
            if(property.rentRangeRunDate!= null){
                prop.Rent_Range_Run_Date__c = property.rentRangeRunDate;
                if(property.rentRangeRunDate== Date.parse(Label.Blank_Date_Value)){
                    prop.Rent_Range_Run_Date__c = null;
                }
            }
           
            
            if(property.collateralAnalyticsAvmRunDate != null){
                prop.Collateral_Analytics_AvmRunDate__c  = property.collateralAnalyticsAvmRunDate;
                if(property.collateralAnalyticsAvmRunDate == Date.parse(Label.Blank_Date_Value)){
                    prop.Collateral_Analytics_AvmRunDate__c = null;
                }
            }
            //PE-579
            if(property.bedrooms != null){
                prop.Bedrooms__c = property.bedrooms;
                if(property.bedrooms == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Bedrooms__c = null;    
                }
            }
            if(property.bathrooms != null){
                prop.Bathrooms__c = property.bathrooms;
                if(property.bathrooms == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Bathrooms__c = null;   
                }
            }
            if(property.bpoValuationDate != null){
                prop.Bpo_Valuation_Date__c = property.bpoValuationDate;
                if(property.bpoValuationDate == Date.parse(Label.Blank_Date_Value)){
                    prop.Bpo_Valuation_Date__c = null;
                }
            }
            if(property.leaseStartDate != null){
                prop.Lease_Start_Date__c = property.leaseStartDate;
                if(property.leaseStartDate == Date.parse(Label.Blank_Date_Value)){
                    prop.Lease_Start_Date__c = null;
                }
            }
            if(property.leaseEndDate != null){
                prop.Lease_End_Date__c = property.leaseEndDate;
                if(property.leaseEndDate == Date.parse(Label.Blank_Date_Value)){
                    prop.Lease_End_Date__c = null;
                }
            }
            if(property.bpoValuation != null){
                prop.Bpo_Valuation__c = property.bpoValuation;
                if(property.bpoValuation == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Bpo_Valuation__c = null;   
                }
            }
            if(property.sellerProvidedSecurityDeposit != null){
                prop.Seller_Provided_Security_Deposit__c = property.sellerProvidedSecurityDeposit;
                if(property.sellerProvidedSecurityDeposit == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Seller_Provided_Security_Deposit__c = null;    
                }
            }
            if(property.occupancy != null){
                prop.Occupancy__c = property.occupancy;
                if(property.occupancy.contains(Label.Blank_String_Value)){
                    prop.Occupancy__c = null;   
                }
            }
            if(property.section8 != null){
                prop.Section_8__c = property.section8;
            }
            //added for cloudhouse mapping
            if(property.hasPhotos != null){
                prop.Photos__c = property.hasPhotos;
            }
            if(property.previousYearTaxes != null){
                prop.Previous_Year_Taxes__c = property.previousYearTaxes;
                if(property.previousYearTaxes == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Previous_Year_Taxes__c = null; 
                }
            }
            if(property.insuranceEstimate != null){
                prop.Insurance_Estimate__c = property.insuranceEstimate;
                if(property.insuranceEstimate == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Insurance_Estimate__c = null;  
                }
            }
            if(property.counterOffer != null){
                prop.Counter_Offer__c = property.counterOffer;
                if(property.counterOffer == Decimal.valueOf(Label.Blank_Decimal_Value)){
                    prop.Counter_Offer__c = null;   
                }
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
            
            if(property.salePrice != null && property.monthlyRent != null ){
                prop.Gross_yield_in_place_rents__c = ((property.monthlyRent * 12) / property.salePrice);
            }
            if(property.salePrice != null && property.marketRent != null){
                prop.Gross_yield_market_rents__c = ((property.marketRent * 12) / property.salePrice);
            }

            propertyMap.put(prop.PropertyId__c,prop);
            //updatedPropertiesList.add(prop);
        }
        
        
        
        upsert propertyMap.values() PropertyId__c;
        
        
        //upsert updatedPropertiesList PropertyId__c;
        // Create Property Unit and its map 
        map<String,Property_Unit__c> mapPropertyUnitIds = new map<String,Property_Unit__c> ();
        Set<String> setassetmgmnt = new set<string>(); 
        for (Property2__c property : propertyMap.values()) {
            
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
                System.debug('=squareFeet='+propertyUnit.squareFeet);
                System.debug('=inspectedSquareFeet='+propertyUnit.inspectedSquareFeet);
                unitLookup.put(propertyUnit.unitId, propertyUnit);
                Property_Unit__c pu = new Property_Unit__c(
                        name = propertyUnit.address,
                        Property__c = property.id,
                       // BedRooms__c = propertyUnit.bedRooms,
                       // Bathrooms__c = propertyUnit.bathrooms,
                        HomeCode__c = propertyUnit.homeCode,
                        PropertyUnitId__c = propertyUnit.unitId
                       // Estimated_Rehab_Cost_Diligence__c = propertyUnit.estRehabCost
                        //RC-13708
                       // Inspected_Bathrooms__c = propertyUnit.inspectedBathrooms,
                       // Inspected_Bedrooms__c = propertyUnit.inspectedBedrooms
                        //Inspected_Square_Feet__c = Decimal.valueOf(propertyUnit.inspectedSquareFeet),
                       // Inspected_Square_Feet__c = propertyUnit.inspectedSquareFeet!=null?Decimal.valueOf(propertyUnit.inspectedSquareFeet):0,
                        //Square_Feet__c = propertyUnit.squareFeet!=null?Decimal.valueOf(propertyUnit.squareFeet):0,
                      //  Occupancy_at_Closing__c = propertyUnit.occupancy,
                        //Seller_Provided_Lease_Start_Date__c = propertyUnit.leaseStart,
                        //Seller_Provided_Lease_End_Date__c = propertyUnit.leaseEnd,
                        //Seller_Provided_Security_Deposit__c = propertyUnit.securityDeposit
                        
                    );
                   
                    if(propertyUnit.estRehabCost != null){
                        pu.Estimated_Rehab_Cost_Diligence__c = propertyUnit.estRehabCost;
                        if(propertyUnit.estRehabCost == Decimal.valueOf(Label.Blank_Decimal_Value)){
                            pu.Estimated_Rehab_Cost_Diligence__c = null;
                        }
                    }
                
                   if(propertyUnit.bedRooms != null){
                        pu.BedRooms__c = propertyUnit.bedRooms;
                        if(propertyUnit.bedRooms == Decimal.valueOf(Label.Blank_Decimal_Value)){
                            pu.BedRooms__c = null;
                        }
                    }
                    
                    if(propertyUnit.bathrooms != null){
                        pu.Bathrooms__c = propertyUnit.bathrooms;
                        if(propertyUnit.bathrooms == Decimal.valueOf(Label.Blank_Decimal_Value)){
                            pu.Bathrooms__c = null;
                        }
                    }
                    
                    if(propertyUnit.inspectedBedrooms != null){
                        pu.Inspected_Bedrooms__c = propertyUnit.inspectedBedrooms;
                        if(propertyUnit.bedRooms == Decimal.valueOf(Label.Blank_Decimal_Value)){
                            pu.Inspected_Bedrooms__c = null;
                        }
                    }
                    
                    if(propertyUnit.inspectedBathrooms != null){
                        pu.Inspected_Bathrooms__c = propertyUnit.inspectedBathrooms;
                        if(propertyUnit.inspectedBathrooms == Decimal.valueOf(Label.Blank_Decimal_Value)){
                            pu.Inspected_Bathrooms__c = null;
                        }
                    }
                
                    if(propertyUnit.squareFeet != null){
                        pu.Square_Feet__c = Decimal.valueOf(propertyUnit.squareFeet);
                        if(propertyUnit.squareFeet.contains(Label.Blank_String_Value)){
                            pu.Square_Feet__c = null;
                        }
                    }
                
                    if(propertyUnit.inspectedSquareFeet != null){
                        pu.Inspected_Square_Feet__c = Decimal.valueOf(propertyUnit.inspectedSquareFeet);
                        if(propertyUnit.inspectedSquareFeet.contains(Label.Blank_String_Value)){
                            pu.Inspected_Square_Feet__c = null;
                        }
                    }
                
                    if(propertyUnit.leaseStart != null){
                        pu.Seller_Provided_Lease_Start_Date__c = propertyUnit.leaseStart;
                        if(propertyUnit.leaseStart == Date.parse(Label.Blank_Date_Value)){
                            pu.Seller_Provided_Lease_Start_Date__c = null;
                        }
                    }
                    
                    if(propertyUnit.leaseEnd != null){
                        pu.Seller_Provided_Lease_End_Date__c = propertyUnit.leaseEnd;
                        if(propertyUnit.leaseEnd == Date.parse(Label.Blank_Date_Value)){
                            pu.Seller_Provided_Lease_End_Date__c = null;
                        }
                    }
                
                     if(propertyUnit.securityDeposit != null){
                        pu.Seller_Provided_Security_Deposit__c = propertyUnit.securityDeposit;
                        if(propertyUnit.securityDeposit == Decimal.valueOf(Label.Blank_Decimal_Value)){
                            pu.Seller_Provided_Security_Deposit__c = null;
                        }
                    }
                
                    if(propertyUnit.occupancy != null){
                        pu.Occupancy_at_Closing__c = propertyUnit.occupancy;
                        if(propertyUnit.occupancy.contains(Label.Blank_String_Value)){
                            pu.Occupancy_at_Closing__c = null;  
                        }
                    }
                
                    if(propertyUnit.isSection8 != null ){
                        if(propertyUnit.isSection8 == true){
                            pu.Seller_Provided_Section_8__c = 'Y';
                        }
                        else if(propertyUnit.isSection8 == false){
                            pu.Seller_Provided_Section_8__c = 'N';
                        }
                    }
                    //PE-579
                    if(propertyUnit.unitNumber != null){
                        pu.Unit_Number__c = propertyUnit.unitNumber;     
                    }
                    if(propertyUnit.monthlyRent != null){
                        pu.Monthly_Rent__c = propertyUnit.monthlyRent;  
                        if(propertyUnit.monthlyRent == Decimal.valueOf(Label.Blank_Decimal_Value)){
                            pu.Monthly_Rent__c = null;  
                        }
                    }
                    //pu.Monthly_Rent__c = propertyUnit.monthlyRent;
                    if(propertyUnit.leasingBalance != null){
                        pu.Leasing_Balance__c = propertyUnit.leasingBalance;     
                        if(propertyUnit.leasingBalance == Decimal.valueOf(Label.Blank_Decimal_Value)){
                            pu.Leasing_Balance__c = null;   
                        }
                    }
                    if(propertyUnit.leasingBalanceZeroTo30Days != null){
                        pu.Leasing_Balance_Zero_To_30_Days__c = propertyUnit.leasingBalanceZeroTo30Days;   
                        if(propertyUnit.leasingBalanceZeroTo30Days == Decimal.valueOf(Label.Blank_Decimal_Value)){
                            pu.Leasing_Balance_Zero_To_30_Days__c = null;   
                        }
                    }
                    if(propertyUnit.leasingBalance30To60Days != null){
                        pu.Leasing_Balance_30_To_60_Days__c = propertyUnit.leasingBalance30To60Days;    
                        if(propertyUnit.leasingBalance30To60Days == Decimal.valueOf(Label.Blank_Decimal_Value)){
                            pu.Leasing_Balance_30_To_60_Days__c = null; 
                        }
                    }
                    if(propertyUnit.leasingBalance60To90Days != null){
                        pu.Leasing_Balance_60_To_90_Days__c = propertyUnit.leasingBalance60To90Days;  
                        if(propertyUnit.leasingBalance60To90Days == Decimal.valueOf(Label.Blank_Decimal_Value)){
                            pu.Leasing_Balance_60_To_90_Days__c = null; 
                        }
                    }
                    if(propertyUnit.leasingBalanceOver90Days != null){
                        pu.Leasing_Balance_Over_90_Days__c = propertyUnit.leasingBalanceOver90Days;  
                        if(propertyUnit.leasingBalanceOver90Days == Decimal.valueOf(Label.Blank_Decimal_Value)){
                            pu.Leasing_Balance_Over_90_Days__c = null;  
                        }
                    }
                    if(propertyUnit.leasingBalanceDate != null){
                        pu.Leasing_Balance_Date__c = propertyUnit.leasingBalanceDate; 
                         if(propertyUnit.leasingBalanceDate == Date.parse(Label.Blank_Date_Value)){
                            pu.Leasing_Balance_Date__c = null;
                        }
                       
                    }
                    if(propertyUnit.marketRent != null){
                       pu.Market_Rent__c =  propertyUnit.marketRent;
                       pu.Underwritten_Rent__c =  propertyUnit.marketRent;
                       if(propertyUnit.marketRent == Decimal.valueOf(Label.Blank_Decimal_Value)){
                            pu.Market_Rent__c = null;   
                            pu.Underwritten_Rent__c =  null;
                       }
                        
                    }
                
                    if(propertyUnit.propertyAccessNotes != null){
                        pu.Property_Access_Notes__c = propertyUnit.propertyAccessNotes;
                        if(propertyUnit.propertyAccessNotes.contains(Label.Blank_String_Value)){
                            pu.Property_Access_Notes__c = null; 
                        }
                    }
                    if(propertyUnit.propertyAccessMethodType != null){
                        pu.Property_Access_Method_Type__c = propertyUnit.propertyAccessMethodType;
                        if(propertyUnit.propertyAccessMethodType.contains(Label.Blank_String_Value)){
                            pu.Property_Access_Method_Type__c = null;   
                        }
                    }
                    
                    propertyUnitsList.add(pu);
                
                if(originalProperty.propertyRecordType == 'Asset Management'){
                              setassetmgmnt.add(propertyUnit.unitId);     
                }
                
            }
        }
        
        upsert propertyUnitsList PropertyUnitId__c;
        List<Utilities__c> lstUtilities = new List<Utilities__c>(); 
        for(Property_Unit__c oUnit:propertyUnitsList){
               /*diligencesList.add( new Diligence__c( Property_Unit__c = oUnit.Id, Dilligence_Id__c = oUnit.PropertyUnitId__c, 
                                                     Estimated_Capex_Manual__c = unitLookup.get(oUnit.PropertyUnitId__c).estimatedCapexManual,
                                                     Estimated_Rent_UW__c = unitLookup.get(oUnit.PropertyUnitId__c).estimatedRentUW ) );*/
            if(setassetmgmnt.contains(oUnit.PropertyUnitId__c))
               lstUtilities.add(new Utilities__c( Property_Unit__c= oUnit.Id, Utility_ID__c = oUnit.PropertyUnitId__c));
            
        }
        
        //upsert diligencesList Dilligence_Id__c; 
        if(!lstUtilities.isEmpty()){
            Schema.SObjectField ftoken = Utilities__c.Fields.Utility_ID__c;
            Database.UpsertResult[] srList = Database.upsert(lstUtilities,ftoken,false);
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
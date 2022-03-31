@isTest
public class BPOPropertyValuationTest1 {
    static void setupPropData() {
        
    	Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.PropertyId__c = '4009e0f5-6947-44b8-9389-986f58e913ac';
        p.Property_Type__c = 'Single Family';
        p.name = '123 Main St Tracy CA 95391';
        p.City__c = 'Imperial';
        p.Street_Address__c ='100 Main St';
        p.County__c ='Allegheny';
        p.Zip__c = '77077';
        p.State__c = 'PA';
        p.Square_Feet__c = '123';
        p.Seller_Provided_List_Price__c = 20.0;
        p.BPO_Trigger_Date__c = System.today()-1;
        p.Type_of_BPO_Trigger__c = 'In Contract';
        p.Lot_Size__c = '123';
        p.Year_Built__c = '2002';
        p.Stop_Annual_BPO_Valuation__c = false;
        insert p;
        
        /*
        Broker_Price_Opinion__c bpo = new Broker_Price_Opinion__c();
        bpo.Property__c = p.Id;
        bpo.Reference_ID__c = 'testrefid1';
        bpo.Order_ID__c = 'testorderid1';
        bpo.Type_of_BPO_Trigger__c = 'Transaction Completed';
        bpo.Status__c = 'success';
        bpo.name =  bpo.Reference_ID__c + '_'+ bpo.Order_ID__c+ '_' +bpo.Type_of_BPO_Trigger__c;
        insert bpo;
		*/
        
    }
    static testMethod void BPOServiceCalloutBatchTest(){
        setupPropData();
        Property2__c prop = [Select Id, Name from Property2__c limit 1];
        Broker_Price_Opinion__c bpo = new Broker_Price_Opinion__c();
        bpo.Property__c = prop.Id;                   
        bpo.Type_of_BPO_Trigger__c = 'manual';
        bpo.Status__c = 'Confirmed';
        bpo.Product__c = '3 Day Exterior BPO';
        bpo.Pool_Name__c = 'Test Pool';
        bpo.Branch_Id__c = 'Test Branch Id';
        bpo.name =  prop.Name + '_'+bpo.Type_of_BPO_Trigger__c + '_' + bpo.Status__c;      
        Insert bpo;
        
        test.startTest();
        Database.executeBatch(new BPOServiceCalloutBatch(),1);
        test.stopTest();
        
    }
    
    
    static testMethod void bpoPropValbuttonTest(){
        setupPropData();
        
        List<Property2__c> propList = [SELECT id, Name, Street_Address__c,City__c,State__c,County__c,Zip__c,Seller_Provided_List_Price__c,Property_Type__c ,Bathrooms_SUM__c,Bedrooms_SUM__c,Lot_Size__c,Square_Feet__c,Annual_BPO_Trigger_Date__c,BPO_Trigger_Date__c,Year_Built__c,Type_of_BPO_Trigger__c, PropertyId__c,Client__c FROM Property2__c Limit 1];
        String product = '';
        String pool = 'Test Pool';
        String branchId = 'Test BranchId';
        
        //List<Property2__c> propList = [select id, Name, Street_Address__c,City__c,State__c,County__c,Zip__c,Seller_Provided_List_Price__c,Property_Type__c ,Bathrooms_SUM__c,Bedrooms_SUM__c,Lot_Size__c,Square_Feet__c,Annual_BPO_Trigger_Date__c,BPO_Trigger_Date__c,Year_Built__c,Type_of_BPO_Trigger__c, PropertyId__c from Property2__c where Annual_BPO_Trigger_Date__c = TODAY Limit 1];
        test.startTest();
        //BatchBPOServiceCalloutHelper.callBPOServiceCallout(propList,false);
        BatchBPOServiceCalloutHelper.callBPOServiceButton(propList[0], product, pool, branchId);
        BatchBPOServiceCalloutHelper.fetchPropertyData(propList[0].id);
        BatchBPOServiceCalloutHelper.getBPORequestList(propList[0].id);
        //BatchBPOServiceCalloutHelper.callBPOServiceButton(null);
        BatchBPOServiceCalloutHelper.fetchPropertyData(null);
        test.stopTest();
        
    }
	static testMethod void CreateBPORecordsBatchTest1(){
        setupPropData();
        test.startTest();
        Database.executeBatch(new CreateBPORecordsBatch(),1);
        Type t = Type.forName('Broker_Price_Opinion__c'); //object name
		Sobject  customObjInfo =  (Sobject)t.newInstance();
        String selectPicklistApi = 'Product__c';
        BatchBPOServiceCalloutHelper.pickListValueDynamically( customObjInfo, selectPicklistApi);
        test.stopTest();
        
    }
    static testMethod void CreateBPORecordsBatchTest2(){
        setupPropData();
        Property2__c p = [Select Id from Property2__c limit 1];
        p.Annual_BPO_Trigger_Date__c = System.today()-1;
        p.BPO_Trigger_Date__c = System.today();
        update p;
        test.startTest();
        Database.executeBatch(new CreateBPORecordsBatch(),1);
        test.stopTest();
        
    }
    static testMethod void CreateBPORecordsBatchSchTest(){
        setupPropData();
        test.startTest();
        CreateBPORecordsBatch sh1 = new CreateBPORecordsBatch();      
        String sch = '0  00 1 3 * ?';
        system.schedule('Test', sch, sh1);
        test.stopTest();       
    }
	static testMethod void bpoPropValResponseTest(){
        setupPropData();
        
        Property2__c p1 = [SELECT id, Name, Street_Address__c,City__c,State__c,County__c,Zip__c,Seller_Provided_List_Price__c,Property_Type__c ,Bathrooms_SUM__c,Bedrooms_SUM__c,Lot_Size__c,Square_Feet__c,Annual_BPO_Trigger_Date__c,BPO_Trigger_Date__c,Year_Built__c,Type_of_BPO_Trigger__c, PropertyId__c,Client__c FROM Property2__c Limit 1];
        p1.BPO_Trigger_Date__c = System.today()-2;
        p1.Annual_BPO_Trigger_Date__c = system.today();
        update p1;
        
        
        List<Property2__c> propList = [SELECT id, Name, Street_Address__c,City__c,State__c,County__c,Zip__c,Seller_Provided_List_Price__c,Property_Type__c ,Bathrooms_SUM__c,Bedrooms_SUM__c,Lot_Size__c,Square_Feet__c,Annual_BPO_Trigger_Date__c,BPO_Trigger_Date__c,Year_Built__c,Type_of_BPO_Trigger__c, PropertyId__c,Client__c FROM Property2__c where Annual_BPO_Trigger_Date__c = TODAY Limit 1];
        test.startTest();
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseBPOGenerator());
        Database.executeBatch(new CreateBPORecordsBatch(),1);
        test.stopTest();
        
    }
    
    static testMethod void BPOServiceCalloutBatchSchTest(){
        setupPropData();
        Property2__c prop = [Select Id, Name from Property2__c limit 1];
        Broker_Price_Opinion__c bpo = new Broker_Price_Opinion__c();
        bpo.Property__c = prop.Id;                   
        bpo.Type_of_BPO_Trigger__c = 'manual';
        bpo.Status__c = 'New';
        bpo.name =  prop.Name + '_'+bpo.Type_of_BPO_Trigger__c + '_' + bpo.Status__c;      
        
        Insert bpo;
        
        List<Id> idlist = new List<Id>();
        idlist.add(bpo.id);
        
        BpoListViewController.Request req = new BpoListViewController.Request();
        req.idList = idList;
        req.product = '3 Day Exterior BPO';
        req.pool = 'test pool';
        req.branchId = 'test branch';
        
        BpoListViewController.updateBpoRecs(new List<BpoListViewController.Request>{req});
        
        test.startTest();
        BPOServiceCalloutBatch sh1 = new BPOServiceCalloutBatch();      
        String sch = '0  00 1 3 * ?';
        system.schedule('Test', sch, sh1);
        test.stopTest();
        
    }
    static testMethod void bpoPropValRestTest(){
        setupPropData();      
        String jsondata = '{"respondingParty":{"identifier":"VIBE"},"respondToParty":{"identifier":"1038ABC111"},"response":{"responseDateTime":"0001-01-01T00:00:00","responseDateTimeString":"2021-16-11T11:27:22.457","loginAccountIdentifier":"TBD","loginAccountPassword":"TBD","key":[{"name":"ReferenceId","value":"testrefid1"},{"name":"FinalProductPrice","value":"123.00"},{"name":"MarketRentMonthly","value":"1234"}],"status":{"condition":"SUCCESS","code":"S001","name":"Report","description":"Product Delivery"},"responseData":{"appraisalResponse":{"mismoVersionId":"2.1","embeddedFile":{"encodingType":"base64","name":"PDFReport","document":"JVBERi0xLjMKJbrfrOAKMyAwIG9iago8PC9UeXBlIC9"},"loanInformation":{"loanId":"123456789"},"product":{"productName":{"identifier":"1004","description":"1004: Single Family Appraisal"}},"productFulfillmentExtension":{"completionDate":"2021-11-11T11:27:22.457","completionDateString":"2021-11-11T11:27:22.457","inspectionDate":"2021-11-11T11:27:22.457","inspectionDateString":"2021-11-11T11:27:22.457","priceAmountString":"","priceAmount":0,"orderIdentifier":"testorderid1"},"valuation":{"valueAmount":300000}}}}}';
        Test.startTest();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/BPOPropertyValuation';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonData);
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response= res;
        RESTBPOPropertyValuation.bpoPropertyValuation();
        Test.stopTest();        
    }
    static testMethod void bpoPropValRestErrorTest(){
        setupPropData();      
        String jsondata = '{"respondingParty":{"identifier":"VIBE"},"respondToParty":{"identifier":"1038ABC111"},"response":{"responseDateTime":"0001-01-01T00:00:00","responseDateTimeString":"2021-16-11T11:27:22.457","loginAccountIdentifier":"TBD","loginAccountPassword":"TBD","key":[{"name":"FinalProductPrice","value":"123.00"},{"name":"MarketRentMonthly","value":"1234"}],"status":{"condition":"SUCCESS","code":"S001","name":"Report","description":"Product Delivery"},"responseData":{"appraisalResponse":{"mismoVersionId":"2.1","embeddedFile":{"encodingType":"base64","name":"PDFReport","document":"JVBERi0xLjMKJbrfrOAKMyAwIG9iago8PC9UeXBlIC9"},"loanInformation":{"loanId":"123456789"},"product":{"productName":{"identifier":"1004","description":"1004: Single Family Appraisal"}},"productFulfillmentExtension":{"completionDate":"2021-11-11T11:27:22.457","completionDateString":"2021-11-11T11:27:22.457","inspectionDate":"2021-11-11T11:27:22.457","inspectionDateString":"2021-11-11T11:27:22.457","priceAmountString":"","priceAmount":0,"orderIdentifier":"testorderid1"},"valuation":{"valueAmount":300000}}}}}';
        Test.startTest();

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/BPOPropertyValuation';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonData);
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response= res;
        RESTBPOPropertyValuation.bpoPropertyValuation();
        Test.stopTest();        
    }
    
	
}
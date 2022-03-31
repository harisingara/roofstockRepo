@isTest(seealldata=true)
public with sharing class RESTHoaControllerTest {
    static testMethod void RESTHoaControllerTest() {
        Property2__c p = new Property2__c(); 
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'qHOATST';
        p.PropertyId__c = '72bcf440-RESTHoaControllerTest';
        p.Property_Type__c = 'Single Family';
        //p.Year_Built__c = '1972';
        p.name = '123 Main St Tracy CA 95391';
        insert p;
        
        Vendor__c ven = new Vendor__c();
        ven.Name= 'test vendor';
        ven.Remittance_Address__c='400 george st';
        ven.Email__c = 'test@gmail.com';
        ven.Phone__c= '9898989898';
        ven.Type__c = 'HOA Company Contact';   
        insert ven;
            
        Vendor__c ven1 = new Vendor__c();
        ven1.Name= 'test vendor1';
        ven1.Type__c = 'HOA Company';       
        insert ven1;
        
        HOA__c hoa1 = new HOA__c();
        hoa1.name = 'Test HOA record';
        hoa1.Property__c = p.id;
        hoa1.HOA_Company_Contact1__c = ven.id;
        hoa1.HOA_Company1__c = ven1.id;
        insert hoa1;

        List<RESTHOAHelper.HOA> hoaList = new List<RESTHOAHelper.HOA>();
        RESTHOAHelper.HOA hoa= new RESTHOAHelper.HOA();
        hoa.contact = new RESTHOAHelper.HOAContact();
        hoa.certificationId='123456';
        hoa.propertyId='72bcf440-RESTHoaControllerTest';
        hoa.contact.rsAccountId='RESTHoa';
        hoa.contact.bpmContactId='RESTHoa';
        hoa.contact.companyName = 'test vendor1';
        hoa.contact.firstName = 'test';
        hoa.contact.lastName = 'vendor';
        hoa.hasRentalRestriction=true;
        hoa.rentalRestrictionNotes='Acute Data';
        hoa.hoaAmount='1234.00';
        hoa.hoaPaymentTerm='Annually';
        hoa.hasHoa = true;
        hoa.hoaBalance='234.00';
        hoa.isHoaFeePaid=true;
        hoa.hasTitleTransferFee=true;
        hoa.titleTransferAmount='111.00';
        hoa.isHoaLimitOnInvestorOwnedUnits=true;
        hoa.numberOfInvestorOwnedUnitsInHoa='5';
        hoa.hasAnyViolations=true;
        hoa.violationNotes='Violation Notes';
        hoa.hasAnyCapitalContributions=true;
        hoa.capitalContributionAmount='1111.00';
        hoa.diligenceReviewUrl='www.roofstock.com';
        hoaList.add(hoa);

        RESTHOAHelper.HOAWrap oReqData = new RESTHOAHelper.HOAWrap(); 
        oReqData.hoaList =  hoaList;        
        String sReq = JSON.serialize(oReqData);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/UpsertHOA';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
            RESTHoaController.upsertHOA();
            req.requestBody = Blob.valueOf('');
            RestContext.request = req;
            RestContext.response = res;
      
            RESTHoaController.upsertHOA();
        Test.stopTest();
    }
}
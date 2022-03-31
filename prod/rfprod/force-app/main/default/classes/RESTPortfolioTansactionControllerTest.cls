@isTest
public class RESTPortfolioTansactionControllerTest {
                         static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void RESTPortfolioTansactionControllerTest() {
        Account a = new Account(Name = 'TestAccount');
        insert a;
        Contact c = new Contact(
            firstname = 'Test',
            lastname = 'Test',
            email= 'Test@nowhere.com',
            BPM_Contact_Id__c = '1234',
            HasOptedOutOfEmail =false,
            AccountId = a.Id
        );
        insert c;
        Property2__c p = new Property2__c();
        p.Market__c = 'Atlanta';
        p.PropertyCode__c = 'q1000';
        p.Property_Type__c = 'Single Family';
        p.Year_Built__c = '1972';
        p.name = '123 Main St Tracy CA 95391';
        p.PropertyId__c = '123458';
        p.Roofstock_Instance_Id__c = '123458';
        insert p;
        
        List<RESTPortfolioTransactionHelper.PortfolioTransactions> transactionList = new List<RESTPortfolioTransactionHelper.PortfolioTransactions>();
        RESTPortfolioTransactionHelper.PortfolioTransactions contextTransaction = new RESTPortfolioTransactionHelper.PortfolioTransactions();
        contextTransaction.name = 'TRN-20205 | 6825 Brittany Pl, Pinson, AL';
        contextTransaction.portfolioTransactionId = '1234';
        contextTransaction.portfolioCreationDate =String.valueOf(System.Today());
        contextTransaction.effectiveDate =String.valueOf(System.Today());
        contextTransaction.estimatedCloseDate =String.valueOf(System.Today());
        contextTransaction.closeDate = String.valueOf(System.Today());
        contextTransaction.salesPrice = '1234';
        contextTransaction.emdAmount = '1234';
        contextTransaction.rsCommission = '1234';
        contextTransaction.rsTransCoordinatorEmail = 'chidanand.Magadum@roofstock.com';
        contextTransaction.rsCustomerServiceEmail = 'chidanand.Magadum@roofstock.com';
        contextTransaction.rsAdvisorEmail = 'chidanand.Magadum@roofstock.com';
        contextTransaction.buyerContactId = '1234';
        contextTransaction.buyerSignerContactId = '1234';
        contextTransaction.sellerContactId = '1234';
        contextTransaction.sellerSignerContactId = '1234';
        contextTransaction.titleCompanyContactId = '1234';
        contextTransaction.buyerPMContactId = '1234';
        transactionList.add(contextTransaction);
        
        RESTPortfolioTransactionHelper.PortfolioTransactionsWrap portfoliRequest = new RESTPortfolioTransactionHelper.PortfolioTransactionsWrap();
        portfoliRequest.PortfolioTransactionList = transactionList;
        String sReq = JSON.serialize(portfoliRequest);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/updatePortfolioTransaction';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTPortfolioTransactionController.updateTransactionPortfolio();
        Test.stopTest();
    }
    static testMethod void RESTPortfolioTansactionControllerExceptionTest() {
        try{
        List<RESTPortfolioTransactionHelper.PortfolioTransactions> transactionList = new List<RESTPortfolioTransactionHelper.PortfolioTransactions>();
        RESTPortfolioTransactionHelper.PortfolioTransactions contextTransaction = new RESTPortfolioTransactionHelper.PortfolioTransactions();
        contextTransaction.name = 'TRN-20205 | 6825 Brittany Pl, Pinson, AL';
        contextTransaction.portfolioTransactionId = '1234';
        contextTransaction.portfolioCreationDate =String.valueOf(System.Today());
        contextTransaction.effectiveDate =String.valueOf(System.Today());
        contextTransaction.estimatedCloseDate =String.valueOf(System.Today());
        contextTransaction.closeDate = String.valueOf(System.Today());
        contextTransaction.salesPrice = '1234';
        contextTransaction.emdAmount = '1234';
        contextTransaction.rsCommission = '1234';
        contextTransaction.rsTransCoordinatorEmail = 'chidanand.Magadum@roofstock.com';
        contextTransaction.rsCustomerServiceEmail = 'chidanand.Magadum@roofstock.com';
        contextTransaction.rsAdvisorEmail = 'chidanand.Magadum@roofstock.com';
        contextTransaction.buyerContactId = '1234';
        contextTransaction.buyerSignerContactId = '1234';
        contextTransaction.sellerContactId = '1234';
        contextTransaction.sellerSignerContactId = '1234';
        contextTransaction.titleCompanyContactId = '1234';
        contextTransaction.buyerPMContactId = '1234';
        transactionList.add(contextTransaction);
        
        RESTPortfolioTransactionHelper.PortfolioTransactionsWrap portfoliRequest = new RESTPortfolioTransactionHelper.PortfolioTransactionsWrap();
        portfoliRequest.PortfolioTransactionList = transactionList;
        String sReq = JSON.serialize(transactionList);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/updatePortfolioTransaction';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(sReq);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        RESTPortfolioTransactionController.updateTransactionPortfolio();
        Test.stopTest();
        }
        catch(Exception ex){
            
        }
    }
}
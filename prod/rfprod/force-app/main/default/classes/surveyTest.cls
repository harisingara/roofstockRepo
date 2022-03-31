@istest
public class surveyTest {
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
	@testsetup
    public static void testdataCreate(){
        Id transRecordtypeId = Schema.SObjectType.Transaction__C.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        contact c = new contact();
        c.firstname= 'anupam';
        c.LastName='kumar';
        c.Email='anupam.kumar@roofstock.com';
        insert c;
        
        transaction__c tc = new transaction__c();
    	tc.name = 'test trans';
        tc.RecordtypeId = transRecordtypeId;
        tc.Transaction_Status__c = 'Transaction Completed';
        tc.Transaction_Completed_Date__c = system.today()-11;
        tc.Buyer_Contact1__c = c.id;
        insert tc;
        
        transaction__c tc1 = new transaction__c();
    	tc1.name = 'test trans';
        tc1.RecordtypeId = transRecordtypeId;
        tc1.Transaction_Status__c = 'Transaction Completed';
        tc1.Transaction_Completed_Date__c = system.today()-35;
        tc1.Buyer_Contact1__c = c.id;
        insert tc1;
        
        transaction__c tc2 = new transaction__c();
    	tc2.name = 'test trans';
        tc2.RecordtypeId = transRecordtypeId;
        tc2.Transaction_Status__c = 'Transaction Completed';
        tc2.Transaction_Completed_Date__c = system.today()-92;
        tc2.Buyer_Contact1__c = c.id;
        insert tc2;
        
        transaction__c tc3 = new transaction__c();
    	tc3.name = 'test trans';
        tc3.RecordtypeId = transRecordtypeId;
        tc3.Transaction_Status__c = 'Transaction Completed';
        tc3.Transaction_Completed_Date__c = system.today()-183;
        tc3.Buyer_Contact1__c = c.id;
        insert tc3;
    }
    @istest
    public static void testSurvey() {

        Test.StartTest();

        RsNpsBuyerSellerSurvey RsNps = new RsNpsBuyerSellerSurvey();
        String sch = '0 0 23 * * ?'; 
        System.schedule('Schedule Batch Lead Survey', sch, RsNps);
        Test.stopTest(); 
    }
    @istest
    public static void testSurvey1() {

        Test.StartTest();

        PmCsatBuyers30DaysSurvey RsNps = new PmCsatBuyers30DaysSurvey();
        String sch = '0 0 23 * * ?'; 
        System.schedule('Schedule Batch Lead Survey', sch, RsNps);
        Test.stopTest(); 
    }
    @istest
    public static void testSurvey2() {

        Test.StartTest();

        PmCsatBuyers90DaysSurvey RsNps = new PmCsatBuyers90DaysSurvey();
        String sch = '0 0 23 * * ?'; 
        System.schedule('Schedule Batch Lead Survey', sch, RsNps);
        Test.stopTest(); 
    }
    @istest
    public static void testSurvey3() {

        Test.StartTest();

        PmCsatBuyers180DaysSurvey RsNps = new PmCsatBuyers180DaysSurvey();
        String sch = '0 0 23 * * ?'; 
        System.schedule('Schedule Batch Lead Survey', sch, RsNps);
        Test.stopTest(); 
    }
}
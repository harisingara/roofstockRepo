@isTest
public class ReOpenTurnTest {
    static{
        TestDataFactory.insertHierarchyCustomSettingData();
        TestDataFactory.createTestTurnListingRecords(1);
    }
    static testMethod void turnAPICompleted() {
        Turn__c turn= [select Id from Turn__c limit 1];
        turn.Status__c = 'Completed';
        update turn;
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        Test.startTest();
        ReOpenTurn.findTurns(turn.Id);
        Test.stopTest();
    }
    static testMethod void turnAPIInProgress() {
        Turn__c turn= [select Id from Turn__c limit 1];
        turn.Status__c = 'In Progress';
        update turn;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        Test.startTest();
        ReOpenTurn.findTurns(turn.Id);
        Test.stopTest();
    }
    static testMethod void turnAPI() {
        Turn__c turn= [select Id from Turn__c limit 1];
        //turn.Status__c = 'Completed';
        //update turn;
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        Test.startTest();
        ReOpenTurn.findTurns(turn.Id);
        Test.stopTest();
    }
    private class RestMock1 implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson =' {"address1":"749 Eagle Drive","bathrooms":2,"bedrooms":3,"city":"Saginaw","country":"United States","state":"TX","zip":"76131","rent":1525,"unitCode":"749EAG  ","occupancy":{"status":"Occupied No Notice","readyDate":"2019-01-23T00:00:00","rentReady":true},"tenant":{"moveIn":"2019-03-29T00:00:00","moveOut":null,"firstName":"Erica","lastName":"Moody","rent":1575,"status":"Current","noticeDate":null},"vacantDate":null,"terminationDate":null,"availableDate":null}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    private class RestMock2 implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson =' {"address1":"749 Eagle Drive","bathrooms":2,"bedrooms":3,"city":"Saginaw","country":"United States","state":"TX","zip":"76131","rent":1525,"unitCode":"749EAG  ","occupancy":{"status":"Occupied No Notice","readyDate":"2019-01-23T00:00:00","rentReady":false},"tenant":{"moveIn":"2019-03-29T00:00:00","moveOut":null,"firstName":"Erica","lastName":"Moody","rent":1575,"status":"Current","noticeDate":null},"vacantDate":null,"terminationDate":null,"availableDate":null}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
}
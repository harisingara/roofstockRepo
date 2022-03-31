@isTest
public class SendEmailHOATest {
    static { 
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    
    static testMethod void sendEmailHOA() {
        Property2__c p = new Property2__c();
        p.name = 'test prop';
        insert p;
        
        Property_Unit__c pu = new Property_Unit__c();
        pu.name= 'tets pu';
        pu.Property__c = p.id;
        insert pu;
        
        Hoa__C h = new Hoa__c();
        h.Name = 'TestSendEmailHoa';
        h.Property__c = p.id;
        Insert h;
        
        Violation__c v = new Violation__c();
        v.Hoa__C = h.Id;
        //v.name = 'TestSendEmailHoaViolation';
        Insert v;
        
        lease__c l =  new lease__c();
        l.name = 'test lease';
        l.Lease_Start_Date__c = Date.today() -1;
        l.Lease_End_Date__c = Date.today() + 1;
        l.Property_Unit__c = pu.id;
        insert l;
        
        Tenant__c t =  new Tenant__c();
        t.Name = 'test user';
        t.Email__c = 'testMail@mail.com';
        t.Lease__c = l.id;
        t.Primary__c = true;
        insert t;
        
        //2nd case
        Hoa__C h1 = new Hoa__c();
        h1.Name = 'TestSendEmailHoa';
        Insert h1;
        Violation__c v1 = new Violation__c();
        v1.Hoa__C = h1.Id;
        //v.name = 'TestSendEmailHoaViolation';
        Insert v1;
        
        Transaction__c trans = new Transaction__c();
        trans.Transaction_Id__c = '12345';
        trans.Name = 'test transaction';
        insert trans;

        SendEmailHoa.hoaDetails(h.Id);
        SendEmailHoa.violationHoaDetails(v.Id);
        SendEmailHoa.toAddress(v.Id);
        SendEmailHoa.toAddress(v1.Id);
        SendEmailHoa.getTransactionId(trans.id);
    }
}
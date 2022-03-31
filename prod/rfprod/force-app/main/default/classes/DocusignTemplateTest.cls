@isTest
public class DocusignTemplateTest {
    
          static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    @isTest static void testsendEnvelopeMethod() {
    
         Campaign camp=new Campaign(Name='Test Campaign',IsActive=True);
         Insert camp;
     
         Contact c = new contact(Firstname='Test',LastName='Contact',Email= 'test@gmail.com');
         Insert c;
         
         Contact myContact = [SELECT Id, Name, Email FROM Contact Limit 1];
     
          CampaignMember cm= New CampaignMember(CampaignId=Camp.Id,ContactId=c.Id,Status='Sent');
          Insert cm;

        //dsfs.dsfs__DocuSign_Envelope_ID__c = '1001A123-1234-5678-1D84-F8D44652A382';
    
    
    
        Test.startTest();
       // DocusignTemplate = new DocusignTemplate();
       
       // DocusignTemplate.sendEnvelopeMethod(myContact.Id ,'bffa6311-242e-47c7-baa5-dce1e506cd6c' , 'Test_Template');
        Test.stopTest();
        
    }
    
        @isTest static void testDocusignTemplate () {
        // code_block
    }
       @isTest static void testcontactButton() {
        // code_block
    }
    
    
    
    
    


    
      @isTest static void testD2_before_D1() {
        Test.startTest();
        Date D1 = Date.newInstance(1989, 3, 7);
        Date D2 = Date.newInstance(1988, 3, 7);
        Date D3 = Date.newInstance(1989, 3, 31);
        System.assertEquals(D3,  DocusignTemplate.CheckDates(D1,D2));
        Test.stopTest();
    }
    
        @isTest static void testD2_within_30days() {
        
        Date D1 = Date.newInstance(1989, 3, 7);
        Date D2 = Date.newInstance(1989, 3, 14);
        Date D3 = Date.newInstance(1990, 3, 14);
        
        System.assertEquals(D2,  DocusignTemplate.CheckDates(D1,D2));
        System.assertEquals(false,  DocusignTemplate.DateWithin30Days(D2,D1));
        System.assertEquals(true,  DocusignTemplate.DateWithin30Days(D1,D2));
        System.assertEquals(false,  DocusignTemplate.DateWithin30Days(D1,D3));
    }
    
        @isTest static void testND2_after_30days() {
        
        Date D1 = Date.newInstance(1989, 3, 7);
        Date D2 = Date.newInstance(1994, 3, 7);
        Date D3 = Date.newInstance(1989, 3, 31);
        System.assertEquals(D3,  DocusignTemplate.CheckDates(D1,D2));
    }
    
    @isTest static void testNDA_template_id_formated() {
        
        String id1 = 'test';
        String id2 = '123456789';
        String id3 = 'test';
        System.assertEquals('test-123456789-test-',  DocusignTemplate.NDA_template_id_formated(id1,id2,id3));
    }
    
    @isTest static void testNDA_envelope_id_formated() {
        
        String id1 = 'test';
        String id2 = '123456789';
        String id3 = 'test';
        System.assertEquals('test-123456789-test-',  DocusignTemplate.NDA_envelope_id_formated(id1,id2,id3));
    }
    
    @isTest static void testNDA_document_id_formated() {
        
        String id1 = 'test';
        String id2 = '123456789';
        String id3 = 'test';
        System.assertEquals('test-123456789-test-',  DocusignTemplate.NDA_document_id_formated(id1,id2,id3));
    } 
    
        
    @isTest static void test_get_campaign_member_id() {
        
        System.assertEquals('Id-CampaignMember-',  DocusignTemplate.getCampaignId('CampaignMember'));
    }
    
    @isTest static void test_get_campaign_member_name() {
        
        System.assertEquals('Name-CampaignMember-',  DocusignTemplate.getCampaignName('CampaignMember'));
    }
    
    
    
    
    @isTest static void test_get_template_id() {
        
        System.assertEquals('Id-Template-',  DocusignTemplate.getTemplateId('Template'));
    }
    
    @isTest static void test_get_envelope_id() {
        
        System.assertEquals('Id-Envelope-',  DocusignTemplate.getEnvelopeId('Envelope'));
    }
    
    @isTest static void test_get_document_id() {

        System.assertEquals('Id-Document-',  DocusignTemplate.getDocumentId('Document'));
    }
    
    
    
        @isTest static void test_get_template_name() {
        
        System.assertEquals('Name-Template-',  DocusignTemplate.getTemplateName('Template'));
    }
    
    @isTest static void test_get_envelope_name() {
        
        System.assertEquals('Name-Envelope-',  DocusignTemplate.getEnvelopeName('Envelope'));
    }
    
    @isTest static void test_get_document_name() {

        System.assertEquals('Name-Document-',  DocusignTemplate.getDocumentName('Document'));
    }
      
}
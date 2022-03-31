@isTest
public class LIATest {
  private static final string userAlias = 'RSUSER1'; 
 
  private static Id retailBuyerLeadRTId ;
  private static Id retailSellerLeadRTId;
  
  private static final string RB_RT ='Retail Buyer';
  private statIC final string RS_RT='Retail Seller';    

  //static initialization code (load test data) 
  static {
        //create test users
        TestDataFactory.createTestUserRecords(2);
        //load record type info
        retailBuyerLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RB_RT).getRecordTypeId();
   		retailSellerLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RS_RT).getRecordTypeId();
             TestDataFactory.insertHierarchyCustomSettingData();
  }
    

 static testMethod void TestLeadInfoSellerAcct() {
        	
    User u1 = [SELECT Id FROM User WHERE Alias= :userAlias];

  
    System.RunAs(u1) {
        // Insert Test Data (Lead record)
             Lead ld = new Lead();
             ld.LastName = 'Test';
             ld.Status = 'No Appointment';
             ld.X1_Ideally_when_would_you_buy_your_first__c = system.today()+30;
             ld.Company = 'Test Company';
             ld.Lead_Interest__c = 'Selling Properties';
             ld.LeadSource = 'Roofstock Registered';
        	 ld.Property_Street__c = 'fake address';
        	 ld.Listing_Price__c = 120000;
             ld.How_did_you_hear_about_Roofstock__c = 'Podcast'; 
     		 
        	 test.startTest();
             insert ld;
        
             //reset recursive flags here ,otherwise lead triggers won't fire again!
             checkRecursive.resetFlags();	
			 System.debug('***** foo'+ ld.RecordTypeId);

        	 // Convert Lead record just created
             //Database.LeadConvert lc = new database.LeadConvert();
             //lc.setLeadId(ld.Id);
             //LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
             //lc.setConvertedStatus(convertStatus.MasterLabel);
             //lc.setConvertedStatus('Appointment');
             //Database.LeadConvertResult lcrList = Database.convertLead(lc);
          
       		// Make sure lead conversion was successful
             //System.assert(lcrList.isSuccess());
   
       			// Fetch ID's from converted Lead record
        //      Lead ao = [Select convertedaccountid, convertedopportunityid from Lead Where id = :ld.id];  
               // Update Account Record to Active Status
          //    Opportunity opp = [Select id, name from Opportunity Where id = :ao.convertedopportunityid];
           //    System.assertEquals(ld.Property_Street__c, opp.name);
        
        
       // Update Account Record to Active Status
            //  Account acct = [Select id, Status__c from Account Where id = :ao.convertedaccountid];
            //  acct.Status__c = 'Active';
            //  update acct;
             
       // Apex page reference which contains custom VF component
         //     PageReference acctPage = new pagereference('/apex/LeadInfoAcct');
                            
       // Reference Page ID's from converted lead record
          //    ApexPages.currentPage().getParameters().put( 'id', ao.convertedaccountid );          
              
       // Invoke Custom Controller & query Lead record related to Account
         //     LeadInfoAcct a = new LeadInfoAcct();              
         //     LeadInfoAcct.getacct();
                                        
       test.stopTest();
    }
    }
}
@isTest
public class LIOTest {

// This is the test class (buyer) to provide coverage for APEX controller (classname): LeadInfoOppty
static{
        TestDataFactory.insertHierarchyCustomSettingData();
    }    
 static testMethod void TestLeadInfoBuyerOppty() {

  
        test.startTest();
     
        
        // Insert Test Data (Lead record)
             Lead ld = new Lead();
             ld.LastName = 'Test';
             ld.Status = 'No Appointment';
             ld.X1_Ideally_when_would_you_buy_your_first__c = system.today()+30;
             ld.Company = 'Test Company';
             ld.Lead_Interest__c = 'Buying Properties';
             ld.LeadSource = 'Roofstock Registered';
             ld.How_did_you_hear_about_Roofstock__c = 'Podcast';  
     		 ld.No_Convert_Reason__c = 'No Appointment';
     		 
	 		
        	 ld.How_much_are_you_looking_to_invest__c  ='100,000+';
             insert ld; 
     		System.debug('------RT'+ ld.RecordTypeId);
			 
     		 //reset recursive flags here ,otherwise lead triggers won't fire again!
             checkRecursive.resetFlags();
     
       		 // Convert Lead record just created
             Database.LeadConvert lc = new database.LeadConvert();
             lc.setLeadId(ld.Id);
             //LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
             //lc.setConvertedStatus(convertStatus.MasterLabel);
             lc.setConvertedStatus('Appointment');
             Database.LeadConvertResult lcrList = Database.convertLead(lc);
          
       // Make sure lead conversion was successful
             System.assert(lcrList.isSuccess());
       
       // Fetch ID's from converted Lead record
              Lead ao = [Select convertedaccountid,convertedopportunityid from Lead Where id = :ld.id];  
                   Opportunity opp = [Select id, name from Opportunity Where id = :ao.convertedopportunityid];
               System.assertEquals('Purchase1-Test Company', opp.name);
       // Update Account Record to Active Status
              Account acct = [Select id, Status__c from Account Where id = :ao.convertedaccountid];
              acct.Status__c = 'Active';
              update acct;
             
       // Apex page reference which contains custom VF component
              PageReference acctPage = new pagereference('/apex/LeadInfoOppty');
                            
       // Reference Page ID's from converted lead record
              ApexPages.currentPage().getParameters().put( 'id', ao.convertedaccountid );          
              
       // Invoke Custom Controller & query Lead record related to Account
              LeadInfoOppty o = new LeadInfoOppty();              
              LeadInfoOppty.getoppty();
                                        
       test.stopTest();
    }
}
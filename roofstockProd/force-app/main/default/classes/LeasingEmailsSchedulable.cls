global  with sharing class LeasingEmailsSchedulable implements Schedulable {

    global void execute(SchedulableContext sc) {
 
            date oneDayAgo      = system.today().addDays(-1);
            date twoDaysAgo     = system.today().addDays(-2);
            date sevenDaysAgo   = system.today().addDays(-7);

            Integer batchSize = 10;    

            List<OpportunityRentalUnit__c> orus1 =  [
                        SELECT  
                            id , Status__c, Leasing__c, Application_Start_Date__c,
                            Opportunity__r.ownerid,
                            Opportunity__r.StageName, Opportunity__r.Primary_Leasing_Contact__r.email ,
                            Application_Complete_First_Email_Date__c
                        FROM 
                            OpportunityRentalUnit__c 
                        WHERE 
                        (  Opportunity__r.Primary_Leasing_Contact__c != null 
                            and Opportunity__r.Primary_Leasing_Contact__r.Email != null 
                            and Primary_Leasing_Contact__r.HasOptedOutOfEmail = false 
                            and Opportunity__r.StageName = 'Application Started'
                            and Status__c = 'Application Started' 
                            and Leasing__r.Status__c <> 'Inactive'
                            and Leasing__r.Status__c <> 'Leased'
                            and Application_Complete_First_Email_Date__c = null 
                            and DAY_ONLY(Application_Start_Date__c) = :oneDayAgo
                        ) 
                ];

                EmailTemplate emailTemplate1 = [Select name,Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                from EmailTemplate where developername = 'Leasing_Application_Started_First_Reminder'];
                System.debug(LoggingLevel.ERROR, oneDayAgo  );
                System.debug(LoggingLevel.ERROR, orus1.size() );

                BatchRecordsForQueuing(orus1, emailTemplate1, batchSize);
        
                //------ leasing application started second reminder 
                List<OpportunityRentalUnit__c> orus2 =  [
                SELECT  
                    id , Status__c, Leasing__c, Application_Start_Date__c,
                    Opportunity__r.ownerid,
                    Opportunity__r.StageName, Opportunity__r.Primary_Leasing_Contact__r.email ,
                    Application_Complete_Second_Email_Date__c
                FROM 
                    OpportunityRentalUnit__c 
                WHERE 
                (  Opportunity__r.Primary_Leasing_Contact__c != null 
                    and Opportunity__r.Primary_Leasing_Contact__r.Email != null 
                    and Primary_Leasing_Contact__r.HasOptedOutOfEmail = false 
                    and Opportunity__r.StageName = 'Application Started'
                    and Status__c = 'Application Started' 
                    and Leasing__r.Status__c <> 'Inactive'
                    and Leasing__r.Status__c <> 'Leased'
                    and Application_Complete_Second_Email_Date__c = null 
                    and DAY_ONLY(Application_Start_Date__c) = :twoDaysAgo
                ) 
            ];

            EmailTemplate emailTemplate2 = [Select name,Id,Subject,Description,HtmlValue,DeveloperName,Body 
                            from EmailTemplate where developername = 'Leasing_Application_Started_Second_Reminder'];
            // and Application_Reminder_First_Email_Date__c = null   
            //Application_Reminder_First_Email_Date__c
            System.debug(LoggingLevel.ERROR, twoDaysAgo  );
            System.debug(LoggingLevel.ERROR, orus2.size() );

            BatchRecordsForQueuing(orus2, emailTemplate2, batchSize);
                
        //------ leasing application started third reminder 
        List<OpportunityRentalUnit__c> orus3 =  [
            SELECT  
                id , Status__c, Leasing__c, Application_Start_Date__c,
                Opportunity__r.ownerid,
                Opportunity__r.StageName, Opportunity__r.Primary_Leasing_Contact__r.email ,
                Application_Complete_Third_Email_Date__c
            FROM 
                OpportunityRentalUnit__c 
            WHERE 
            (  Opportunity__r.Primary_Leasing_Contact__c != null 
                and Opportunity__r.Primary_Leasing_Contact__r.Email != null 
                and Primary_Leasing_Contact__r.HasOptedOutOfEmail = false 
                and Opportunity__r.StageName = 'Application Started'
                and Status__c = 'Application Started' 
                and Leasing__r.Status__c <> 'Inactive'
                and Leasing__r.Status__c <> 'Leased'
                and Application_Complete_Third_Email_Date__c = null 
                and DAY_ONLY(Application_Start_Date__c) = :sevenDaysAgo
            ) 
        ];

            EmailTemplate emailTemplate3 = [Select name,Id,Subject,Description,HtmlValue,DeveloperName,Body 
                            from EmailTemplate where developername = 'Leasing_Application_Started_Third_Reminder'];
            // and Application_Reminder_First_Email_Date__c = null   
            //Application_Reminder_First_Email_Date__c

            System.debug(LoggingLevel.ERROR, sevenDaysAgo  );
            System.debug(LoggingLevel.ERROR, orus3.size() );

            BatchRecordsForQueuing(orus3, emailTemplate3, batchSize);
        
        //------ listing status is inactive/down and leasing application started !
        List<OpportunityRentalUnit__c> orus4 =  [
            SELECT  
                id , Status__c, Leasing__c, Application_Start_Date__c,
                Opportunity__r.ownerid,
                Opportunity__r.StageName, Opportunity__r.Primary_Leasing_Contact__r.email ,
                Application_Complete_Leased_Email_Date__c
            FROM 
                OpportunityRentalUnit__c 
            WHERE 
            (  Opportunity__r.Primary_Leasing_Contact__c != null 
                and Opportunity__r.Primary_Leasing_Contact__r.Email != null 
                and Primary_Leasing_Contact__r.HasOptedOutOfEmail = false 
                and Opportunity__r.StageName = 'Application Started'
                and Status__c = 'Application Started' 
                and (Leasing__r.Status__c = 'Inactive' or Leasing__r.Status__c = 'Leased')
                and Application_Complete_Leased_Email_Date__c = null 
                and Application_Start_Date__c = LAST_N_DAYS:30
            ) 
        ];

            EmailTemplate emailTemplate4 = [Select name,Id,Subject,Description,HtmlValue,DeveloperName,Body 
                            from EmailTemplate where developername = 'Leasing_Application_Started_And_Leased'];


            System.debug(LoggingLevel.ERROR, orus4.size() );

            BatchRecordsForQueuing(orus4, emailTemplate4, batchSize);

            
        }  //method
		
    	@TestVisible
        private void BatchRecordsForQueuing(List<OpportunityRentalUnit__c> orus, EmailTemplate emailTemplate, integer batchSize ) {
            Integer oruCount= 0;
            List<OpportunityRentalUnit__c> batchedOrus = new List<OpportunityRentalUnit__c>();
            for(OpportunityRentalUnit__c oru : orus) {
                batchedOrus.add(oru);
                oruCount = oruCount + 1 ;
                if(math.mod(oruCount, batchSize) == 0 || oruCount >= orus.size()) {
                    String orusss; 
                    for(OpportunityRentalUnit__c oru1 : batchedOrus) {
                            orusss = orusss + oru1.id + ', ' ;
                    }
                    System.debug(LoggingLevel.ERROR, orusss);
                    System.enqueueJob(new LeasingEmailsQueuable(batchedOrus, emailTemplate));
                    batchedOrus.clear();
                } //if
            } //for
    
  } //method
}  //class
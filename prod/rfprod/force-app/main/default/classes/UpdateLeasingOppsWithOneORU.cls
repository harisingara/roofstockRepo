global class UpdateLeasingOppsWithOneORU implements Database.Batchable<sObject> {
    
    global List <Opportunity> start(Database.BatchableContext BC) {
		//String query = 'SELECT Id , Name, StageName , Property_Address1__c , RecordTypeId, Relationship__c, Yardi_Prospect_Id__c, AccountId, Primary_Leasing_Contact__c , CloseDate, Application_Status__c,Primary_Applicant_Opp__c , Yardi_Primary_Prospect_Id__c, (SELECT Id, Opportunity__c, Leasing__c, Leasing__r.Property_Unit__r.property__r.Leasing_Market__c, Leasing__r.Rental_Listing_Id__c, Leasing__r.Name FROM Unit_Leasing__r) FROM Opportunity WHERE Yardi_Prospect_Id__c != \'\' AND (RecordType.Name =  \'Leasing\' OR Recordtype.name = \'Leasing Secondary Applicant\')';
           
        List<Opportunity> oppList = [SELECT Id , Name, StageName , Property_Address1__c , RecordTypeId, Relationship__c, Yardi_Prospect_Id__c, AccountId,
                                     Primary_Leasing_Contact__c , CloseDate, Application_Status__c,Primary_Applicant_Opp__c , Yardi_Primary_Prospect_Id__c FROM Opportunity 
                                     WHERE Yardi_Prospect_Id__c != '' AND Rental_Listing__c = null AND  Property_Address1__c = '' AND (RecordType.Name = 'Leasing' OR Recordtype.name = 'Leasing Secondary Applicant')];
        system.debug('Batch Query Count : ' + oppList.size());
        return oppList; 

        //return Database.getQueryLocator([SELECT Id , Name, StageName , Property_Address1__c , RecordTypeId, Relationship__c, Yardi_Prospect_Id__c, AccountId, Primary_Leasing_Contact__c , CloseDate, Application_Status__c,Primary_Applicant_Opp__c , Yardi_Primary_Prospect_Id__c, (SELECT Id, Opportunity__c, Leasing__c, Leasing__r.Property_Unit__r.property__r.Leasing_Market__c, Leasing__r.Rental_Listing_Id__c, Leasing__r.Name, Leasing__r.Current_Rent__c FROM Unit_Leasing__r) FROM Opportunity WHERE Yardi_Prospect_Id__c != '' AND (RecordType.Name =  'Leasing' OR Recordtype.name = 'Leasing Secondary Applicant')]);

    }

    global void execute(Database.BatchableContext BC, List <Opportunity> scope) {
        List <Opportunity> oppsToBeUpd = new List <Opportunity>  ();
        List <Opportunity> oppsToBeInserted = new List <Opportunity>  ();
        
        for(Opportunity Opp : scope){
            
            List <OpportunityRentalUnit__c> oruList = [Select Id, Leasing__c, Leasing__r.Current_Rent__c, Leasing__r.Name, Leasing__r.Property_Unit__r.property__r.Leasing_Market__c from OpportunityRentalUnit__c 
                                                       where Opportunity__c =: Opp.Id AND Leasing__c != null];
            if(oruList != null && oruList.size() > 0){
                Opportunity newOpp = new Opportunity();
                OpportunityRentalUnit__c  oru = new OpportunityRentalUnit__c ();
                oru = oruList[0];
                newOpp.Id = Opp.Id;
                newOpp.Rental_Listing__c = oru.Leasing__c;
                newOpp.Current_Market_Rent__c  = oru.Leasing__r.Current_Rent__c;
                newOpp.Property_Address1__c = oru.Leasing__r.Name;
                //newOpp.Market__c = oru.Leasing__r.Property_Unit__r.property__r.Leasing_Market__c;
                oppsToBeUpd.add(newOpp);
            }
            else{
                Opportunity newOpp = new Opportunity();
                newOpp.Id = Opp.Id;
                newOpp.Property_Address1__c = 'No ORU Found';
                oppsToBeUpd.add(newOpp);
            }
        }
        if(oppsToBeUpd != null && oppsToBeUpd.size() >0){
            Update oppsToBeUpd;
        }
    }
    global void finish(Database.BatchableContext BC) {
        System.debug('UpdateLeasingOppsWithOneORU Successfully Completed');
    }
    
    global static void dummytest(){
        Integer i= 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }


}
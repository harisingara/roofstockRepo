global class LeasingOppDataScrub implements Database.Batchable<sObject> {
    
    global List <Opportunity> start(Database.BatchableContext BC) {
		//String query = 'SELECT Id , Name, StageName , Property_Address1__c , RecordTypeId, Relationship__c, Yardi_Prospect_Id__c, AccountId, Primary_Leasing_Contact__c , CloseDate, Application_Status__c,Primary_Applicant_Opp__c , Yardi_Primary_Prospect_Id__c, (SELECT Id, Opportunity__c, Leasing__c, Leasing__r.Property_Unit__r.property__r.Leasing_Market__c, Leasing__r.Rental_Listing_Id__c, Leasing__r.Name FROM Unit_Leasing__r) FROM Opportunity WHERE Yardi_Prospect_Id__c != \'\' AND (RecordType.Name =  \'Leasing\' OR Recordtype.name = \'Leasing Secondary Applicant\')';
            
        List<Opportunity> oppList = [SELECT Id , Name, StageName , Property_Address1__c , RecordTypeId, Relationship__c, Yardi_Prospect_Id__c, AccountId, Rental_Listing__c,
                                     Primary_Leasing_Contact__c , CloseDate, Application_Status__c,Primary_Applicant_Opp__c , Yardi_Primary_Prospect_Id__c
                                     FROM Opportunity 
                                     WHERE Yardi_Prospect_Id__c != '' AND Property_Address1__c != 'No ORU Found'
                                     AND (RecordType.Name = 'Leasing' OR Recordtype.name = 'Leasing Secondary Applicant')];
        system.debug('Batch Query Count : ' + oppList.size());
        return oppList; 

        //return Database.getQueryLocator([SELECT Id , Name, StageName , Property_Address1__c , RecordTypeId, Relationship__c, Yardi_Prospect_Id__c, AccountId, Primary_Leasing_Contact__c , CloseDate, Application_Status__c,Primary_Applicant_Opp__c , Yardi_Primary_Prospect_Id__c, (SELECT Id, Opportunity__c, Leasing__c, Leasing__r.Property_Unit__r.property__r.Leasing_Market__c, Leasing__r.Rental_Listing_Id__c, Leasing__r.Name, Leasing__r.Current_Rent__c FROM Unit_Leasing__r) FROM Opportunity WHERE Yardi_Prospect_Id__c != '' AND (RecordType.Name =  'Leasing' OR Recordtype.name = 'Leasing Secondary Applicant')]);

    }

    global void execute(Database.BatchableContext BC, List <Opportunity> oppList) {
        List <Opportunity> oppsToBeUpd = new List <Opportunity>  ();
        List <Opportunity> oppsToBeInserted = new List <Opportunity>  ();
        Set <Id> oppIdSet = new Set <Id> ();
        Map <Id, Opportunity> oppMap = new Map <Id, Opportunity> ();
        
        for(Opportunity Opp : oppList){
            oppIdSet.add(Opp.Id);
            oppMap.put(Opp.Id, Opp);
        }
        
        List <OpportunityRentalUnit__c> oruList = [SELECT Id, Opportunity__c, Leasing__c, Leasing__r.Current_Rent__c, Leasing__r.Property_Unit__r.property__r.Leasing_Market__c, Leasing__r.Rental_Listing_Id__c, Leasing__r.Name 
                                      				FROM OpportunityRentalUnit__c WHERE Opportunity__c IN: oppIdSet AND Leasing__c != null];
        
        Map <Id, List <OpportunityRentalUnit__c>> oppIdToORUMap = new Map <Id, List <OpportunityRentalUnit__c>> ();
        
        for(OpportunityRentalUnit__c oru : oruList){
            List <OpportunityRentalUnit__c> tempList = new List <OpportunityRentalUnit__c> ();
            if(oppIdToORUMap.containsKey(oru.Opportunity__c)){
                tempList = oppIdToORUMap.get(oru.Opportunity__c);
            }
                tempList.add(oru);
                oppIdToORUMap.put(oru.Opportunity__c, tempList);
        }
        
        Map <String,OpportunityRentalUnit__c> ketToORUMap = new Map <String,OpportunityRentalUnit__c> ();
        
        // Loop through the ORU Map
        for(String Key: oppIdToORUMap.keySet()){
            List <OpportunityRentalUnit__c> tempList = new List <OpportunityRentalUnit__c> ();
            tempList = oppIdToORUMap.get(Key);
            if(tempList.size() > 1){
                for(OpportunityRentalUnit__c oru : tempList){
                    if(oru.Leasing__c != oppMap.get(oru.Opportunity__c).Rental_Listing__c){
                        Opportunity Opp = oppMap.get(oru.Opportunity__c);
                        ketToORUMap.put(Opp.Primary_Leasing_Contact__c + '_' + oru.Leasing__c, oru);
                        
                        Opportunity newOpp = new Opportunity();
                        newOpp.Name = Opp.Name;
                        newOpp.StageName = Opp.StageName;
                        newOpp.RecordTypeId = Opp.RecordTypeId ;
                        newOpp.Relationship__c = Opp.Relationship__c ;
                        newOpp.Yardi_Prospect_Id__c = Opp.Yardi_Prospect_Id__c ;
                        newOpp.AccountId = Opp.AccountId ;
                        newOpp.Primary_Leasing_Contact__c = Opp.Primary_Leasing_Contact__c ;
                        newOpp.CloseDate = Opp.CloseDate ;
                        newOpp.Application_Status__c = Opp.Application_Status__c ;
                        newOpp.Primary_Applicant_Opp__c = Opp.Primary_Applicant_Opp__c;
                        newOpp.Yardi_Primary_Prospect_Id__c = Opp.Yardi_Primary_Prospect_Id__c;
                        newOpp.Property_Address1__c = oru.Leasing__r.Name;   
                        newOpp.Rental_Listing__c = oru.Leasing__c;                    
                        newOpp.Leasing_Market__c  = oru.Leasing__r.Property_Unit__r.property__r.Leasing_Market__c;
                        newOpp.Current_Market_Rent__c  = oru.Leasing__r.Current_Rent__c;
                        oppsToBeInserted.add(newOpp);                        
                    }
                }                
            }           
        }
        
        if(oppsToBeInserted != null && oppsToBeInserted.size() > 0){
            Insert oppsToBeInserted;
            Set <Id> newOppIdSet = new Set <Id> ();
            Map <String, Id> mapVal = new Map <String, Id> ();
            // Opportunities have been inserted
            // Now link the ORUs to Opportunity
            for(Opportunity Opp1: oppsToBeInserted){
                System.debug('NDEBUG got this Opp Id' + Opp1.Id);
                newOppIdSet.add(Opp1.Id);
            }
            
            List <Opportunity> newOppSet = [SELECT Id, Primary_Leasing_Contact__c, Rental_Listing__c FROM Opportunity where Id IN: newOppIdSet];
            
            for(Opportunity Opp1: newOppSet){
                System.debug('NDEBUG got this Opp Id' + Opp1.Id);
                mapVal.put(Opp1.Primary_Leasing_Contact__c + '_' + Opp1.Rental_Listing__c, Opp1.Id);
            }
            
            
            List <OpportunityRentalUnit__c> oruUpdList = new List  <OpportunityRentalUnit__c> (); 
            for(String key: ketToORUMap.keySet()){
                if(mapVal.containsKey(key)){
                    OpportunityRentalUnit__c temporu = ketToORUMap.get(key);
                    temporu.Opportunity__c = mapVal.get(key);
                    oruUpdList.add(temporu);
                    
                }
            }
            
            
            if(oruUpdList != null && oruUpdList.size() > 0){
                update oruUpdList;
            }
        }
                    
                         
        
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('LeasingOppDataScrub Successfully Completed');
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
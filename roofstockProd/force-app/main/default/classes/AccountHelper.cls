public with sharing class AccountHelper {

//Process Builder - Account Automation
public static void accountAutomation(List<Account> newAccountList,Map<Id,Account> oldAccountMap){
for(Account newAcc :newAccountList ){
   /* if(newAcc.Id!=null){
        if((oldAccountMap.get(newAcc.Id).US_Resident__c!=newAcc.US_Resident__c) &&
            (oldAccountMap.get(newAcc.Id).Domestic_or_International__c!=newAcc.Domestic_or_International__c) &&
            (newAcc.US_Resident__c == 'Yes' && newAcc.Domestic_or_International__c == null)){
            newAcc.Domestic_or_International__c = 'Domestic';
            }

        }*/
        if(newAcc.US_Resident__c == 'Yes' && newAcc.Domestic_or_International__c == null){
            newAcc.Domestic_or_International__c = 'Domestic';
        }
    }
}
    


//Process Builder - Account - Field Update on Associated Opportunities of Same Account
public static void updateAssociatedOpportunities(List<Account> newAccountList,Map<Id,Account> oldAccountMap){
    Id retailSellerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Retail Seller').getRecordTypeId();
   List<Opportunity> updateOpportunitiesList = new List<Opportunity>();
   Set<Opportunity> updateOpportunitiesSet = new Set<Opportunity>();
   Map<String,date> accountIdLastCallDateMap = new Map<String,date>();
   Map<String,String> accountIdPhoneMap = new Map<String,String>();

    for(Account newAcc :newAccountList ){
        if((newAcc.Last_Call_Date__c!=null) &&
          (oldAccountMap.get(newAcc.Id).Last_Call_Date__c!=newAcc.Last_Call_Date__c)
        ){
           accountIdLastCallDateMap.put(newAcc.Id,newAcc.Last_Call_Date__c);
        }
        if(!String.isBlank(newAcc.Phone) &&
        (oldAccountMap.get(newAcc.Id).Phone !=newAcc.Phone )){
          accountIdPhoneMap.put(newAcc.Id,newAcc.Phone);
        }
    }

    if(accountIdLastCallDateMap.keyset().size()>0){
        List<Opportunity> callDateOpportunityList = [select Id,Last_Call_Date__c,AccountId from Opportunity where AccountId IN:accountIdLastCallDateMap.keyset()];
        for(Opportunity callDateOpp :callDateOpportunityList){
            callDateOpp.Last_Call_Date__c = accountIdLastCallDateMap.get(callDateOpp.AccountId);
            updateOpportunitiesList.add(callDateOpp);
        }
    }
    if(accountIdPhoneMap.keyset().size()>0){
        List<Opportunity> phoneOpportunityList = [select Id,Phone__c,AccountId from Opportunity where AccountId IN:accountIdPhoneMap.keyset() and RecordTypeId=:retailSellerRecordTypeId];
        for(Opportunity phoneOpp :phoneOpportunityList){
            phoneOpp.Phone__c = accountIdPhoneMap.get(phoneOpp.AccountId);
            updateOpportunitiesList.add(phoneOpp);
        }
    }
    
    System.debug('=updateOpportunitiesList='+updateOpportunitiesList);
	//create a map that will hold the values of the list 
	map<id,Opportunity> opportunityMap = new map<id,Opportunity>();

	//put all the values from the list to map. 
	opportunityMap.putall(updateOpportunitiesList);
    System.debug('=opportunityMap='+opportunityMap);

	if(opportunityMap.size()>0){
         System.debug('=values='+opportunityMap.values());
		update opportunityMap.values();
	}
   
}
    
// Owner Assignment for BlueBird Accounts
public static void processBlueBirdAccs(List<Account> newAccountList, Map<Id,Account> oldAccountMap){
    List <Account> accsToBeProcessed = new List <Account>  ();
    // Get the Roofstock Customer Account Record Type
    Id rsCustAccRecTypeId = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Account' and DeveloperName = 'Retail_Customer' limit 1].Id;
     
    // Get the Sales Team Queue Info
    Group salesTeamqueue= [SELECT Id, Name, DeveloperName, Type FROM Group where Type = 'Queue' and DeveloperName = 'Sales_Team' limit 1];
    List <GroupMember> userGrp = [Select Id, UserOrGroupId From GroupMember where GroupId =: salesTeamqueue.Id order by Id];
    List <Id> userGrpIds = new List <Id> ();
    String context;
    for(GroupMember grpmem: userGrp){
        userGrpIds.add(grpmem.UserOrGroupId);
    }
    
    if(oldAccountMap == null){
        context = 'Insert';
        // Handling new Accounts
        for(Account newAcc :newAccountList ){
            if(newAcc.BlueBird__c && !userGrpIds.contains(newAcc.ownerId) && newAcc.RecordTypeId == rsCustAccRecTypeId){
                accsToBeProcessed.add(newAcc);
            }
        }
    }
    else {
        context = 'Update';
        for(Account updAcc : newAccountList){
            if(!oldAccountMap.get(updAcc.Id).BlueBird__c && (oldAccountMap.get(updAcc.Id).Made_An_Offer_Date__c != updAcc.Made_An_Offer_Date__c) 
               && oldAccountMap.get(updAcc.Id).Made_An_Offer_Date__c == null && !userGrpIds.contains(updAcc.ownerId)
              && updAcc.RecordTypeId == rsCustAccRecTypeId){
                 accsToBeProcessed.add(updAcc);  
               }
        }
    }
    
    if(accsToBeProcessed != null && accsToBeProcessed.size() >0){
        AccountRoundRobin.roundRobin(accsToBeProcessed,context);
    }
}



}
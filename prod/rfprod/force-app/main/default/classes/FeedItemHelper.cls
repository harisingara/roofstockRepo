public class FeedItemHelper{
    //Process Builder - Last Activity Date
    public static void updateLastActivityDateOnCase(List<FeedItem> feedItemList){
        Set<String> caseIdSet = new Set<String>();
        for(FeedItem fi :feedItemList){
            String ParentId = fi.ParentId;
            if((ParentId).startsWith('500')){
                caseIdSet.add(fi.ParentId);
            }
            
        }
        if(caseIdSet.Size()>0){
            List<Case> updateCaseList = new List<Case>();
            List<Case> matchingCaseList = [select Id,Last_Activity_Date__c from Case where Id IN:caseIdSet];
            if(!matchingCaseList.isEmpty()){
                for(Case cse :matchingCaseList){
                    cse.Last_Activity_Date__c = Datetime.now();
                    updateCaseList.add(cse);
                }	    
            }
            if(!updateCaseList.isEmpty()){
                update updateCaseList;
            }
        }
    }
    //Process Builder - Update First Comment Date Stamp FEED
    public static void updateCase(List<FeedItem> feedItemList){
        Set<String> caseIdSet = new Set<String>();
        for(FeedItem fi :feedItemList){
            if(fi.ParentId!=null){
                String ParentId = fi.ParentId;
                if(ParentId.startsWith('500') && fi.Body!=null){
                    caseIdSet.add(fi.ParentId);
                }
            }
            
        }
        if(caseIdSet.Size()>0){
            List<Case> updateCaseList = new List<Case>();
            List<Case> matchingCaseList = [select Id,First_Comment_Date_Stamp__c from Case where Id IN:caseIdSet];
            if(!matchingCaseList.isEmpty()){
                for(Case cse :matchingCaseList){
                    if(cse.First_Comment_Date_Stamp__c == null){
                        cse.First_Comment_Date_Stamp__c = Datetime.now();
                        updateCaseList.add(cse);
                    }
                }	    
            }
            if(!updateCaseList.isEmpty()){
                update updateCaseList;
            }
        }
    }
}
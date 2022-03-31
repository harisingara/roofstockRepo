@isTest
public class FeedItemTriggerTest {
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void updateLastActivityDateOnCase(){
        Case cs = new Case();
        cs.Subject = 'Salesforce is the best';
        insert cs;
        
        FeedItem fi = new FeedItem();
        fi.ParentId = cs.Id;
        fi.Body = 'Feed Item';
        insert fi;
    }
    static testMethod void updateLastActivityDateOnCaseUpdate(){
        Case cs = new Case();
        cs.Subject = 'Salesforce is the best';
        insert cs;
        
        FeedItem fi = new FeedItem();
        fi.ParentId = cs.Id;
        fi.Body = 'Feed Item';
        insert fi;
        
        FeedItem fitem = [select Id from FeedItem where Id=:fi.Id];
        update fitem;
    }
    
    static testMethod void updateLastActivityDateOnCaseDelete(){
        Case cs = new Case();
        cs.Subject = 'Salesforce is the best';
        insert cs;
        
        FeedItem fi = new FeedItem();
        fi.ParentId = cs.Id;
        fi.Body = 'Feed Item';
        insert fi;
        
        FeedItem fitem = [select Id from FeedItem where Id=:fi.Id];
        delete fitem;
    }
    
    static testMethod void FeedItemControllerException() {

        TriggerDispatcher.forceException = true;
        try{
            
            FeedItem fi = new FeedItem();
            fi.Body = 'Feed Item';
            insert fi;
        }
        catch(Exception ex){
            //System.debug('=='+evt.Id);
        }
    }
}
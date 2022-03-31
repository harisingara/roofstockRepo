public with sharing class BpoListViewController {

    /*
    public List < Broker_Price_Opinion__c > LstSelectedBPOs {
        get;
        set;
    }
    
    public BpoListViewController(ApexPages.StandardSetController BpoListViewController) {
      
        Set < Id > bpoSelectedIds = new set < Id > ();
        LstSelectedBPOs = new List <Broker_Price_Opinion__c >();
            
        for (Broker_Price_Opinion__c  bpo: (Broker_Price_Opinion__c []) BpoListViewController.getSelected()) {
            bpoSelectedIds.add(bpo.id);
        }
        
        Querying on the Selected records and fetching fields which are required in Flow 
        LstSelectedBPOs = [select Id , Status__c from Broker_Price_Opinion__c where id in: bpoSelectedIds];
    }
	*/
    
    @InvocableMethod(label='Update BPO Records' description='Update BPO Records')
   	public static List <Response> updateBpoRecs (List<Request> req){
        List <Broker_Price_Opinion__c> bpoRecsToBeUpdated = new List <Broker_Price_Opinion__c> ();
        List <Response> outputResponse = new List<Response>();
 
        System.debug('NDEBUG got these inputs' + req[0].idList);
        
        for(String id: req[0].idList){
            Broker_Price_Opinion__c bpoRec = new Broker_Price_Opinion__c ();
            bpoRec.Id = id;
            bpoRec.Product__c = req[0].product;
            bpoRec.Pool_Name__c = req[0].pool;
            bpoRec.Branch_Id__c = req[0].branchId;
            bpoRec.Status__c = 'Confirmed';
            bpoRecsToBeUpdated.add(bpoRec);
            
        }
        
        if(bpoRecsToBeUpdated != null && bpoRecsToBeUpdated.size() >0){
            update bpoRecsToBeUpdated;
        }
        
        Response response = new Response();
        response.result = 'Success';
        outputResponse.add(response);
        return outputResponse;
        
    }
    
    
    public class Request {
        @InvocableVariable(required=true)
         public List <Id> idList;
        @InvocableVariable(required=true)
         public String product;
        @InvocableVariable(required=true)
         public String pool;
        @InvocableVariable(required=true)
         public String branchId;
   	}
    
    public class Response {
      @InvocableVariable
       public String result;
   }
    
    
    
    
}
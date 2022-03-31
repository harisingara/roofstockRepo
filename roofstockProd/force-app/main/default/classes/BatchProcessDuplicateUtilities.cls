public class BatchProcessDuplicateUtilities implements Database.Batchable<sObject>, Database.Stateful {
    
    public List<AggregateResult> start(Database.BatchableContext BC)
    {
        List<AggregateResult> lst = [Select Property_Unit__c,count(Property_Unit__r.Total_No_Of_Utilites__c)  
                                     from Utilities__c   
                                     where Property_Unit__r.Total_No_Of_Utilites__c >1  
                                     Group By Property_Unit__c 
                                     Order by count(Property_Unit__r.Total_No_Of_Utilites__c) DESC];
        return lst; 
    }
    public void execute(Database.BatchableContext BC, List<AggregateResult> lstAggreResult)
    {
        savepoint sp = Database.setSavepoint() ; 
        try{
            if(lstAggreResult == null || (lstAggreResult <> null && lstAggreResult.size() > 1)){
            	system.debug('Exiting the code assuming one record to be processed per batch '+lstAggreResult );  
                return; 
            }
        id propertyUnitId = (Id)lstAggreResult[0].get('Property_Unit__c'); 
        String query ='';
        String SobjectApiName = 'Utilities__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        
        String strFields = '';
        List<String> lstFields = new List<String>(); 
        for(String fieldName : fieldMap.keyset() )
        {
           // system.debug( 'is calculated field' + fieldMap.get(fieldName).getdescribe().isCalculated()) ; 
            if(!fieldMap.get(fieldName).getdescribe().isCalculated()){
            	lstFields.add(fieldName);   
            if(strFields == null || strFields == '')
            {
                strFields = fieldName;
            }else{
                strFields = strFields + ' , ' + fieldName;
            }
            }
        }
        
        query = 'select ' + strFields + ' from ' + SobjectApiName + ' where Property_Unit__c=:propertyUnitId';
        
        List <Utilities__c> lstutilities = Database.query(query);  
        id isMaster ; 
        Integer maxCounter = 0; 
        Integer tempCounter = 0 ; 
        for(Utilities__c oUtility:lstutilities){	  
            tempCounter = 0 ;
            for(String sField:lstFields){
                if(oUtility.get(sField) <> null ){
                	system.debug(sField+' sField check values'+oUtility.get(sField));   
                    tempCounter++; 
                }    
            }
            system.debug(' propertyUnitId  '+ propertyUnitId+ ' oUtility Id: '+ oUtility.Id + ' no of fields populated' + tempCounter );
            if(tempCounter > maxCounter ){
            	isMaster = oUtility.Id;	  
                maxCounter = tempCounter ; 
            }
            
        }
            system.debug('for Property Unit****MASTER'+isMaster );
            //Delete all the duplicate records:: 
            List<Utilities__c> deleteDuplicateUtilites = new List<Utilities__c>(); 
            for(Utilities__c oUtility:lstutilities){
                if(oUtility.Id != isMaster){
                	deleteDuplicateUtilites.add(oUtility); 
                }    
            }
            if(!deleteDuplicateUtilites.isEmpty()){
            	delete deleteDuplicateUtilites;	    
            }
        }catch(exception exe){
            Database.rollback(sp); 
            Debugloghandler.logAppException('BatchProcessDuplicateUtilities' , 'Execute',
                                            exe.getMessage(),exe.getStackTraceString(),'Apex Batch');  
        }
    }
    public void finish(Database.BatchableContext BC)
    {
    } 
    
}
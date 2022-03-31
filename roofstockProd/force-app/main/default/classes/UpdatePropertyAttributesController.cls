public class UpdatePropertyAttributesController {
    
    @AuraEnabled
    public static recordIdWrap propertyRecordIds(String recordId) {
        System.debug('-recordId-'+recordId);
        recordIdWrap wrap = new recordIdWrap();
        String obj = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        if(obj == 'Property_Unit__c') {
            Property_Unit__c propertyUnit = [select Id,Property__c from Property_Unit__c where Id=:recordId];
            if(propertyUnit != null) {
                wrap.propertyUnitId = propertyUnit.Id;
                if(propertyUnit.Property__c!=null){
                	wrap.propertyId = propertyUnit.Property__c;   
                }
                else{
                    wrap.propertyId = '';
                }
            }
            
        }
        else if(obj == 'HOA__c'){
            HOA__c hoa = [select Id,Property__c,Property_Unit__c,Property_Unit__r.Property__c from HOA__c where Id=:recordId];
            if(hoa.Property_Unit__c!=null){
                 wrap.propertyUnitId = hoa.Property_Unit__c;
            }
            else{
                wrap.propertyUnitId ='';
            }
            if(hoa.Property_Unit__r.Property__c!=null){
                wrap.propertyId = hoa.Property_Unit__r.Property__c;
            }
            else if(hoa.Property__c!=null){
                wrap.propertyId = hoa.Property__c;
            }
            else{
                wrap.propertyId = '';
            }
            
        }
        else{
            String query = 'Select Id,Property_Unit__c,Property_Unit__r.Property__c FROM '+obj+' WHERE Id = :recordId';
            System.debug('-query-'+query);
            sobject record = Database.query(query);
            Sobject relChildRecord = record.getSObject('Property_Unit__r');
            System.debug('-records-'+record);
            if(String.valueOf(relChildRecord.get('Property__c')) != null){
                wrap.propertyId = String.valueOf(relChildRecord.get('Property__c'));
            }
            else {
                wrap.propertyId = '';
            }
            if(String.valueOf(record.get('Property_Unit__c')) !=null){
                wrap.propertyUnitId = String.valueOf(record.get('Property_Unit__c'));
            }
            else{
                wrap.propertyUnitId = '';
            }
        }
        
        System.debug('-wrap-'+wrap);
        return wrap;
        
    } 
    
    public class recordIdWrap{
        @auraEnabled public string propertyId;
        @auraEnabled public string propertyUnitId;
    }
    
}
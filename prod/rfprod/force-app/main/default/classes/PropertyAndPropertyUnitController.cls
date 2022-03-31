public class PropertyAndPropertyUnitController {
    
    @AuraEnabled
    public static List<String> poolTypeValues(){
       List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Property2__c.Pool_Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            System.debug('-pickListVal-'+pickListVal);
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }
    @AuraEnabled
    public static List<String> mailBoxTypeValues(){
       List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Property2__c.MailBox_Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            System.debug('-pickListVal-'+pickListVal);
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }
    @AuraEnabled
    public static List<String> garbageDisposalBinTypeValues(){
       List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Property_Unit__c.Garbage_Disposal_Bin_Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            System.debug('-pickListVal-'+pickListVal);
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }
    @AuraEnabled
    public static List<String> trashrResponsibilityValues(){
       List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Property_Unit__c.Trash_responsibility__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            System.debug('-pickListVal-'+pickListVal);
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }
    @AuraEnabled
    public static List<String> trashBinAvailableValues(){
       List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Property_Unit__c.Is_Trash_Bin_available__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            System.debug('-pickListVal-'+pickListVal);
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }
    @AuraEnabled
    public static List<String> recycleBinavailableValues(){
       List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Property_Unit__c.Is_Recycle_Bin_available__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            System.debug('-pickListVal-'+pickListVal);
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }
    @AuraEnabled
    public static List<String> hasPoolValues(){
       List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Property2__c.Has_Pools__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            System.debug('-pickListVal-'+pickListVal);
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }
    //MailBox_Type__c
    @AuraEnabled
    public Static PropertyPropertyUnitwrapper propertyPropertyUnitDetails(String propertyId,String propertyUnitId){
        PropertyPropertyUnitwrapper wrap = new PropertyPropertyUnitwrapper();
        if(!String.isEmpty(propertyId)) {
            Property2__c property= [Select Id,Has_Pools__c,Pool_Type__c,Gate_Code__c,MailBox_Type__c from Property2__c where Id =:propertyId];            
            wrap.hasPool =property.Has_Pools__c;
            wrap.poolType = property.Pool_Type__c;
            wrap.gateCode = property.Gate_Code__c;
            wrap.mailBoxType = property.MailBox_Type__c;
        }
        else{
            wrap.hasPool = '';
            wrap.poolType = '';
            wrap.gateCode = '';
            wrap.mailBoxType = '';
        }
        if(!String.isEmpty(propertyUnitId)){
            Property_Unit__c propertyUnit = [Select Id,Lockbox_Location__c,Lockbox_Code__c,Self_Showing_Lockbox__c,Garbage_Disposal_Bin_Type__c,
                                                Is_Trash_Bin_available__c,Trash_responsibility__c,Is_Recycle_Bin_available__c from Property_Unit__c where Id =: propertyUnitId];
            
            wrap.lockboxLocation = propertyUnit.Lockbox_Location__c;
            wrap.lockboxCode = propertyUnit.Lockbox_Code__c;
            wrap.selfShowingLockboxSerialNumber = propertyUnit.Self_Showing_Lockbox__c;
            wrap.garbageDisposalBinType = propertyUnit.Garbage_Disposal_Bin_Type__c;
            wrap.isRecycleBinAvailable = propertyUnit.Is_Recycle_Bin_available__c;
            wrap.isTrashBinAvailable = propertyUnit.Is_Trash_Bin_available__c;
            wrap.trashrResponsibility = propertyUnit.Trash_responsibility__c;
        }
        else{
            wrap.lockboxLocation = '';
            wrap.lockboxCode = '';
            wrap.selfShowingLockboxSerialNumber = '';
            wrap.garbageDisposalBinType = '';
            wrap.isRecycleBinAvailable = '';
            wrap.isTrashBinAvailable = '';
            wrap.trashrResponsibility = '';
        }

        return wrap;
        
    }
    
    @AuraEnabled
    public Static boolean savePropertyPropertyUnitDetails(String propertyId,String propertyUnitId, String propertyDetails){
        Map<String,String> objectMap = new Map<String,String>();
        Map<String,List<String>> filedMap = new Map<String,List<String>>();
        PropertyPropertyUnitwrapper deserializeResults;
        try{
            Type resultType = Type.forName('PropertyAndPropertyUnitController.PropertyPropertyUnitwrapper');
            deserializeResults =       (PropertyPropertyUnitwrapper)JSON.deserialize(propertyDetails, resultType);
            System.debug('==========> deserialize() results = ' + deserializeResults);
            
            if(!String.isEmpty(propertyId)){
                Property2__c property = [Select Id,Has_Pools__c,Pool_Type__c,Gate_Code__c,MailBox_Type__c from Property2__c where Id =:propertyId];
                property.Has_Pools__c = deserializeResults.hasPool;
                property.Pool_Type__c = deserializeResults.poolType;
                property.Gate_Code__c = deserializeResults.gateCode;
                property.MailBox_Type__c = deserializeResults.mailBoxType;
                update property;
            }
            if(!String.isEmpty(propertyUnitId)){
                Property_Unit__c propertyUnit = [Select Id,Lockbox_Location__c,Lockbox_Code__c,Self_Showing_Lockbox__c,Garbage_Disposal_Bin_Type__c,
                                                Is_Trash_Bin_available__c,Trash_responsibility__c,Is_Recycle_Bin_available__c from Property_Unit__c where Id =: propertyUnitId];
                propertyUnit.Lockbox_Location__c = deserializeResults.lockboxLocation;
                propertyUnit.Lockbox_Code__c = deserializeResults.lockboxCode;
                propertyUnit.Self_Showing_Lockbox__c = deserializeResults.selfShowingLockboxSerialNumber;
                propertyUnit.Garbage_Disposal_Bin_Type__c = deserializeResults.garbageDisposalBinType;
                propertyUnit.Is_Trash_Bin_available__c = deserializeResults.isTrashBinAvailable;
                propertyUnit.Trash_responsibility__c = deserializeResults.trashrResponsibility;
                propertyUnit.Is_Recycle_Bin_available__c = deserializeResults.isRecycleBinAvailable;
                update propertyUnit;
                
            }
            return true;
        }
        catch(Exception exe){
            System.debug('-ex-'+exe);
            DebugLogHandler.logAppException('PropertyAndPropertyUnitController','savePropertyPropertyUnitDetails',exe.getMessage(),exe.getStackTraceString(),'LWC - updatePropertyAttributes');
            return false;
        }
        
        
    }
    
    public class PropertyPropertyUnitwrapper{
        @auraEnabled public String hasPool;
        @auraEnabled public String poolType;
        @auraEnabled public String gateCode;
        @auraEnabled public String mailBoxType;
        @auraEnabled public String lockboxLocation;
        @auraEnabled public String lockboxCode;
        @auraEnabled public String selfShowingLockboxSerialNumber;
        @auraEnabled public String garbageDisposalBinType;
        @auraEnabled public String isRecycleBinAvailable;
        @auraEnabled public String isTrashBinAvailable;
        @auraEnabled public String  trashrResponsibility;
        
    }
}
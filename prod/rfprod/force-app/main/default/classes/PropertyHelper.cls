public class PropertyHelper {
    //Process Builder - Property: Sync BPM Transaction Status
    public static void syncBpmTransactionStatus(List<Property__c> newPropertyList){
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String profileName = PROFILE[0].Name;
        if(profileName == 'System Administrator API'){
            for(Property__c pt :newPropertyList){
                
                if(pt.RS_Contingency_Status__c == 'NonContingent' && (pt.RS_Transaction_Status__c == 'New' || pt.RS_Transaction_Status__c == 'PendingEscrow') && (pt.Status__c.containsIgnoreCase('In Contract') || pt.Status__c.containsIgnoreCase('In Contract Non-Contingent') || pt.Status__c.containsIgnoreCase('Acquisition Complete') || pt.Status__c.containsIgnoreCase('Cancelled') || pt.Status__c.containsIgnoreCase('Underwriting'))){
                      pt.Status__c = 'In Contract Non-Contingent';
                  }
                else if((pt.RS_Transaction_Status__c == 'New' || pt.RS_Transaction_Status__c == 'PendingEscrow') && (pt.Status__c.containsIgnoreCase('In Contract') || pt.Status__c.containsIgnoreCase('In Contract Non-Contingent') || pt.Status__c.containsIgnoreCase('Acquisition Complete') || pt.Status__c.containsIgnoreCase('Cancelled') || pt.Status__c.containsIgnoreCase('Underwriting'))){
                           pt.Status__c = 'In Contract';
                       }
                else if(pt.RS_Transaction_Status__c == 'TransactionCompleted' && (pt.Status__c.containsIgnoreCase('In Contract') || pt.Status__c.containsIgnoreCase('In Contract Non-Contingent') || pt.Status__c.containsIgnoreCase('Acquisition Complete') || pt.Status__c.containsIgnoreCase('Cancelled') || pt.Status__c.containsIgnoreCase('Underwriting')) ){
                            pt.Purchased__c = true;
                            pt.Status__c = 'Acquisition Complete';
                        }
                else if(pt.RS_Transaction_Status__c == 'TransactionCancelled' && (pt.Status__c.containsIgnoreCase('In Contract') || pt.Status__c.containsIgnoreCase('In Contract Non-Contingent') || pt.Status__c.containsIgnoreCase('Acquisition Complete') || pt.Status__c.containsIgnoreCase('Cancelled') || pt.Status__c.containsIgnoreCase('Underwriting')) ){
                            pt.Status__c = 'Cancelled';
                            
                }
            }
        }
    }
    public static void populateTransactionLookup(List<Property__c> newPropertyList,map<Id,Property__c> mapOldRecords){
        //List<Property__c> lstProperty = new List<Property__c>(); 
        List<Transaction__c> trnsLst = new List<Transaction__c>();
        Map<String, Property__c> mapTransactionProp = new map<String, Property__c>();
        for(Property__c oProperty:newPropertyList){
            if(( mapOldRecords == null && oProperty.Transaction__c == null && oProperty.RS_TransactionId__c <> null ) || 
                ( mapOldRecords <> null && ((oProperty.Transaction__c == null && oProperty.RS_TransactionId__c <> null) || (oProperty.RS_TransactionId__c <> mapOldRecords.get(oProperty.Id).RS_TransactionId__c  )))){
                string pTranId = oProperty.RS_TransactionId__c.replaceAll('a','').replaceAll('b','').replaceAll('c','').replaceAll('d','').replaceAll('e','');
                    
                 mapTransactionProp.put(pTranId, oProperty);
                //lstProperty.add(oProperty);
            }    
        }
      
        
        if(!mapTransactionProp.IsEmpty()){
            map<String,Id> mapTranxRec = new map<String,Id>();
            set<String> tempTranSet = new set<String>();
            tempTranSet.addAll(mapTransactionProp.keySet());
              
            for(Transaction__c oTrxRec: [Select Id,Transaction_Id__c from Transaction__c where Transaction_Id__c IN:mapTransactionProp.keySet()]){
                mapTranxRec.put(oTrxRec.Transaction_Id__c,oTrxRec.Id);    
                tempTranSet.remove(oTrxRec.Transaction_Id__c);
            }
            
            if(tempTranSet.size() > 0){
                for(String strId : tempTranSet){
                    if(mapTransactionProp.get(strId) != null){
                    Property__c prop = mapTransactionProp.get(strId);    
                    Transaction__c tran = new Transaction__c(Transaction_Id__c = prop.RS_TransactionId__c, Name = 'DRAFT TRNS-'+prop.RS_TransactionId__c +' | '+prop.Name +','+prop.City__c);
                    trnsLst.add(tran);
                    }
                } 
                if(trnsLst.size() > 0){
                    Database.insert(trnsLst, false);
                    for(Transaction__c trn : trnsLst){
                        mapTranxRec.put(trn.Transaction_Id__c, trn.Id);
                    }
                }
            }
            
            if(!mapTranxRec.isEmpty()){
                for(Property__c oProperty : mapTransactionProp.values()){
                    string pTranId = oProperty.RS_TransactionId__c.replaceAll('a','').replaceAll('b','').replaceAll('c','').replaceAll('d','').replaceAll('e','');
                    
                    if(mapTranxRec.get(pTranId) != null){
                        oProperty.Transaction__c = mapTranxRec.get(pTranId);
                    }
                }
               }
                
        }
    }   
    
    
    /* This method is to update the property unit lookup value in Acquisition object */
    Public static void populatePropertyUnitBasedOnUnitRiid(List<Property__c> newPropertyList) {
        List<Property__c> propList = new List<Property__c>();
        List<Property_Unit__c> propUnitList = new List<Property_Unit__c>();
        List<String> unitRiidList = new List<String>();
        Map<String,Id> mapAcqAndUnit = new Map<String,Id>();        
        for( Property__c prop : newPropertyList) {
            if (null <> prop.Property_Unit_Riid__c) {
                system.debug('Fetch unit riid from input::'+prop.Property_Unit_Riid__c);
                unitRiidList.add(prop.Property_Unit_Riid__c);
            }
        }
        system.debug('::listUnitRiid::'+unitRiidList);
        propUnitList = [SELECT Id,PropertyUnitId__c 
                          FROM Property_Unit__c 
                         WHERE PropertyUnitId__c IN: unitRiidList];
        system.debug('propUnitList: value-->'+propUnitList);
        if(propUnitList != null && propUnitList.size() > 0){
            for(Property_Unit__c propUnit : propUnitList){
                mapAcqAndUnit.put(propUnit.PropertyUnitId__c,propUnit.Id);
            }
    
            for( Property__c props : newPropertyList) {
                if (null <> props.Property_Unit_Riid__c && mapAcqAndUnit.containskey(props.Property_Unit_Riid__c)) {
                    props.Property_Unit__c = mapAcqAndUnit.get(props.Property_Unit_Riid__c);
                    system.debug('updating property value::'+props);
                }
            }
        }             
    }
}
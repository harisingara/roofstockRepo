public class TurnHelper {
    public static void updatePriorMoveInDate(List<Turn__c> updatedTurns){
        map<Id,Date> mapPropertyTurn = new map<Id,Date>();
        Set<Id> setUnitIds = new Set<Id>(); 
        for(Turn__c oTurn:updatedTurns){
            if(oTurn.Property_Unit__c <> null)
        		setUnitIds.add(oTurn.Property_Unit__c) ;    
        }
        if(!setUnitIds.IsEmpty()){
        	map<Id,Property_Unit__c> mapProperty = new map<Id,Property_Unit__c>([Select Id,Move_In_Date__c from Property_Unit__c where ID IN: setUnitIds AND Move_In_Date__c != null]); 
            for(Turn__c oTurn:updatedTurns){
        		if(oTurn.Property_Unit__c <> null && mapProperty.containsKey(oTurn.Property_Unit__c))
        			oTurn.Prior_Move_In_Date__c = mapProperty.get(oTurn.Property_Unit__c).Move_In_Date__c;      
        	}
        }
    }
    public static void updateLeasingAvailability(List<Turn__c> updatedTurns){
        map<Id,Leasing_Availability__c> mapUpdateLeasingAvail = new map<Id,Leasing_Availability__c>();
        for(Turn__c updatedTurn : updatedTurns){
            if(updatedTurn.Property_Unit__c!=null){
				mapUpdateLeasingAvail.put(updatedTurn.Property_Unit__c, 
                                              new Leasing_Availability__c(Vacate_Date__c = updatedTurn.Move_Out_Date__c, Ready_Date__c = updatedTurn.Yardi_Ready_Date__c)); 

                
            }
        }
        if(!mapUpdateLeasingAvail.IsEmpty()){
            List<Leasing_Availability__c> lstUpdateLeasing = [ Select Property_Unit__c, Vacate_Date__c , ID , Ready_Date__c 
                                                              from Leasing_Availability__c where Property_Unit__c IN:mapUpdateLeasingAvail.keyset()];     
            for(Leasing_Availability__c oLeasingAvail:lstUpdateLeasing){
                oLeasingAvail.Vacate_Date__c = mapUpdateLeasingAvail.get(oLeasingAvail.Property_Unit__c).Vacate_Date__c;
                oLeasingAvail.Ready_Date__c = mapUpdateLeasingAvail.get(oLeasingAvail.Property_Unit__c).Ready_Date__c;
            }
            update lstUpdateLeasing;
        }
        
    }

}
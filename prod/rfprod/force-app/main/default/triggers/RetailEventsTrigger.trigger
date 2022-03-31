trigger RetailEventsTrigger on Retail_Event__e (after insert) {
    try{
        if(trigger.isAfter){
            if(trigger.isInsert){
                List<Retail_Event__e> retailEventList = new List<Retail_Event__e>();
               // System.debug('=size='+trigger.new.size());
                for(Retail_Event__e re : trigger.new){
                    if(re!=null){
                        retailEventList.add(re);
                    }
                	
                }
                if(!retailEventList.isEmpty()){
                    DebugLogHandler.logInboundResponse('RetailEventsTrigger','RetailEventController',JSON.serialize(retailEventList),null);
                	RetailEventController.retailEventSubscriber(retailEventList);
                }
            }
            
        }
    }
    catch(Exception exe){
        //DebugLogHandler.logAppException('RetailEventsTrigger','RetailEventController',exe.getMessage(),exe.getStackTraceString(),'Trigger');throw exe;
    }
}
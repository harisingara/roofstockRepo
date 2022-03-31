trigger TransactionEventTrigger on Transaction_Event__e (after insert) {
 try{
        if(trigger.isAfter) {
            if(trigger.isInsert) {
                    DebugLogHandler.logInboundResponse('TransactionEventTrigger','',JSON.serialize(trigger.new),'Platform Events Published'); 
                    System.debug('Events::'+Trigger.new);           
            }
            
         }
            
    }
    catch(Exception exe){
        System.debug('-Exception -'+ exe);    
    }

}
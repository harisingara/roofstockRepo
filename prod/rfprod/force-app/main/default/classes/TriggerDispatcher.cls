public class TriggerDispatcher {
    // static map of handlername, times run() was invoked
    private static Map < String, LoopCount > loopCountMap;
    @testVisible
    private static boolean forceException = false;
    public class TriggerDispatcherException extends Exception{
        
    }
    
    static{
        loopCountMap = new Map < String, LoopCount > ();
    }
    Public static void run(ITriggerHandler handler, String ObjectName) {
        system.debug('check handler names' + String.valueOf(handler).substring(0, String.valueOf(handler).indexOf(':')));
        if(forceException){
            throw new TriggerDispatcherException('Forced exception');
        }
        if (handler.isDisabled()) {
            return;
        }
        Boolean maxRunExecuted = addToLoopCount(handler, Trigger.operationType);
        system.debug('check loopCountMap??' + TriggerDispatcher.loopCountMap);
        system.debug('maxRunExecuted??' + maxRunExecuted);
        Bypass_Rules_And_Triggers__c bypassTrigger = Bypass_Rules_And_Triggers__c.getInstance(UserInfo.getUserId());
        /*
* This will first check access at profile/User level, 
* if there are no profile/user defined then only it will consider OWD Settings
*/
        System.debug('=ObjectName=' + ObjectName);
        System.debug('=bypassTrigger=' + bypassTrigger);
        
        if (maxRunExecuted || (bypassTrigger.Trigger_Objects__c.contains(ObjectName) && bypassTrigger.Disable_Triggers__c == true)) {
            return;
        } else {
            /* Check Trigger context from trigger operation type.
*/
            switch on Trigger.operationType {
                
                When BEFORE_INSERT {
                    handler.beforeInsert(trigger.new);
                }
                When AFTER_INSERT {
                    handler.afterInsert(trigger.new, trigger.newMap);
                }
                When BEFORE_UPDATE {
                    handler.beforeUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
                }
                When AFTER_UPDATE {
                    handler.afterUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
                }
                when BEFORE_DELETE{
                    handler.beforeDelete(trigger.old, trigger.oldMap);
                }
                When AFTER_DELETE{
                    handler.afterDelete(trigger.old, trigger.oldMap);
                }
                When AFTER_UNDELETE{
                    handler.afterUndelete(trigger.new, trigger.newMap);
                }
            }
        }
    }
    
    // increment the loop count System.TriggerOperation 
    private static Boolean addToLoopCount(ITriggerHandler handler, System.TriggerOperation sOperationType) {
        String handlerName = getHandlerName(handler) + sOperationType;
        Boolean exceeded = false;
        system.debug('inside addtoLOOp??' + handlerName);
        if (!TriggerDispatcher.loopCountMap.containsKey(handlerName)) {
            TriggerDispatcher.setMaxLoopCount(3, handler, sOperationType);
        }
        exceeded = TriggerDispatcher.loopCountMap.get(handlerName).increment();
        System.debug('=exceeded='+exceeded);
        if (exceeded) {
            Integer max = TriggerDispatcher.loopCountMap.get(handlerName).max;
            Boolean bIsErrorLogInserted = TriggerDispatcher.loopCountMap.get(handlerName).errorlogged;
            if (!bIsErrorLogInserted) {
                string errMsg = 'Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName;
                //DebugLogHandler.logAppException(getHandlerName(handler), handlerName, errMsg, '','Trigger');
                LoopCount lCnt = TriggerDispatcher.loopCountMap.get(handlerName);
                lCnt.errorlogged = true;
                TriggerDispatcher.loopCountMap.put(handlerName, lCnt);
            }
            // return true; 
            // throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
        }
        return exceeded;
    }
    
    // inner class for managing the loop count per handler
    private class LoopCount {
        private Integer max;
        private Integer count;
        private Boolean errorlogged;
        public LoopCount() {
            this.max = 3;
            this.count = 0;
            this.errorlogged = false;
        }
        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
            this.errorlogged = false;
        }
        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }
        public Boolean exceeded() {
            return this.max >= 0 && this.count > this.max;
        }
        public Integer getMax() {
            return this.max;
        }
        public Integer getCount() {
            return this.count;
        }
        public void setMax(Integer max) {
            this.max = max;
        }
    }
    public static void setMaxLoopCount(Integer max, ITriggerHandler handler, System.TriggerOperation sOperationType) {
        String handlerName = getHandlerName(handler) + sOperationType;
        if (!TriggerDispatcher.loopCountMap.containsKey(handlerName)) {
            TriggerDispatcher.loopCountMap.put(handlerName, new LoopCount(max));
        } else {
            TriggerDispatcher.loopCountMap.get(handlerName).setMax(max);
        }
    }
    public static void clearMaxLoopCount(ITriggerHandler handler, System.TriggerOperation sOperationType) {
        setMaxLoopCount(-1, handler, sOperationType);
    }
    @TestVisible
    private static String getHandlerName(ITriggerHandler handler) {
        return String.valueOf(handler).substring(0, String.valueOf(handler).indexOf(':'));
    }
    
}
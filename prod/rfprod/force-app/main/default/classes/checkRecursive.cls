public Class checkRecursive{
    private static Map<String, Boolean> runMap= new Map<String, Boolean>();
    
    public enum RecurType {
    	LEAD,OPPORTUNITY,ACCOUNT,CONTACT,TASK
    }
    
    public void checkRecursive(){
        
    }
    public static boolean runBeforeOnce(RecurType type) {
       
        String key = type.name() + '-before';  //account-before, lead-after..
       // System.debug('+++++runBeforeOnce' + key);
       // System.debug('++++' + runMap.get(key) );
        return retrieve(key);
    }

    public static boolean runAfterOnce(RecurType type){
    
        String key = type.name() + '-after';
       //System.debug('+++++runAfterOnce' + key);

       return retrieve(key);
         
    }
    //sometimes in test methods, we need to start over eg-after lead conversion
    //this is not for use in regular code, mostly for test classes only!
    public static void resetFlags(){
         printFlags();
        System.debug('reset');
        for(String key : runMap.keySet()){
            runMap.put(key,true);
        }
        printFlags();
    }
    
     private static void printFlags(){
                 System.debug('print after reset');

        for(String key : runMap.keySet()){
           System.debug('*key:'+ key + '*value:' + runMap.get(key)) ;
        }
        
    }
    
    private static boolean retrieve(String key) {
        if(runMap.get(key) == null){
             runMap.put(key, false);
             return true; 
        }
        else{
            return runMap.get(key);
        }
    }

}
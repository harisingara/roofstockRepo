//june 5
trigger RentalListingTrigger on Rental_Listing__c(before insert,after insert,after update) {
    try{
        TriggerDispatcher.run(new RentalListingTriggerHandler(),'Rental_Listing__c');
    }catch(Exception exe){
        DebugLogHandler.logAppException('RentalListingTrigger','RentalListingTriggerHandler',exe.getMessage(),
                                                  exe.getStackTraceString(),'Trigger'); 
        throw exe;
    }
}
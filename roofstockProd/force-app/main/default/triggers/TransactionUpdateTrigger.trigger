trigger TransactionUpdateTrigger on Transaction_Update__e (after insert) {
        TriggerDispatcher.run(new TransactionUpdateTriggerHandler(),'Transaction_Update__e'); 
}
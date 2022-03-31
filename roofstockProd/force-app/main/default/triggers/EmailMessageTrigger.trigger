trigger EmailMessageTrigger on EmailMessage (after insert, before update, after update) {
    try {
        // Test exception in test class
        if (EmailMessageTest.TestException) {
            Integer x = 5/0;
        } 
        else {
            TriggerDispatcher.run(new EmailMessageTriggerHandler(),'EmailMessage');
        }
    }
    catch(Exception exe){
        DebugLogHandler.logAppException('EmailMessageTrigger','EmailMessageTriggerHandler',exe.getMessage(),
                                                  exe.getStackTraceString(),'Trigger'); 
    }
}
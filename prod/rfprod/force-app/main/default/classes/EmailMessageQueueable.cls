public with sharing class EmailMessageQueueable implements Queueable,Database.AllowsCallouts{
    public Set<ID> emsgSet ; 
    public EmailMessageQueueable(Set<Id> emIds){
        this.emsgSet = emIds ;  
    }
    public void execute(QueueableContext context) {
        for(Id msgid: emsgSet){
                    
           
                EmailMessageHelper.sendcallout(String.valueOf(msgid),GlobalConstants.EMAIL_TRACKING_STATUS_EMAIL_DELIVERED);
            
                      
        }
    }
}
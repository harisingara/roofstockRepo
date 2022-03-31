public class EscalateToBuyerBrokerController {
    
    @AuraEnabled
    public static boolean escalateToBuyerBroker(String recordId) {
        try{
            String Recordlink = URL.getSalesforceBaseUrl().toExternalForm()+'/'+recordId;

            List<Case> lstCases = [select Id,status,Additional_Notes__c,Description from Case where Id = :recordId];
            String toEmail = '';
            if(!String.isEmpty(lstCases[0].Additional_Notes__c)){
                String caseComments = lstCases[0].Additional_Notes__c;
                String stringAfterBuyerBrokerEmailLabel = caseComments.substringAfter('Buyer Broker Email:');
                String buyerBrokerEmail = stringAfterBuyerBrokerEmailLabel.substringBefore('\n');
                if(buyerBrokerEmail !=null && !String.isEmpty(buyerBrokerEmail)){
                    toEmail = buyerBrokerEmail;
                }
                System.debug('-toEmail-'+toEmail);
                if(!String.isEmpty(toEmail) && toEmail!=null){
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses = new String[] {toEmail};
                    message.subject = 'Ask a question - Escalated';
                    message.plainTextBody = 'The Case is Escalated'+'\n\n'+Recordlink+'\n\n'+caseComments+'\n\n\n'+'Thanks,'+'\n'+'Roofstock Support';
                    Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    
                    if (results[0].success) {
                        System.debug('The email was sent successfully.');
                        lstCases[0].status = 'Closed';
                        update lstCases[0];
                        
                        EmailMessage emailMessage = new EmailMessage();
                        emailMessage.fromAddress= UserInfo.getUserEmail();
                        emailMessage.ToAddress = toEmail;
                        emailMessage.FromName = UserInfo.getName();
                        emailMessage.Subject = message.subject;
                        //emailMessage.HtmlBody = taskComments+'\n\n\n'+'Thanks,'+'\n'+'Roofstock Support';
                        //emailMessage.HtmlBody = lstCases[0].Description+'\n\n\n'+'Thanks,'+'\n'+'Roofstock Support';
                        emailMessage.Incoming= False;
                        emailMessage.TextBody = lstCases[0].Additional_Notes__c+'\n\n\n'+'Thanks,'+'\n'+'Roofstock Support';
                        emailMessage.status = '3';
                        emailMessage.parentId = recordId;
                        emailMessage.EmailServiceParentId__c = recordId; 
                        
                        insert emailMessage;
                        
                        return true;
                    } else {
                        System.debug('The email failed to send: ' + results[0].errors[0].message);
                        return false;
                    }
                }
                else{
                    return false;
                }
            }
            else{
                return false;
            }
        }
        catch(Exception exe){
            System.debug('-exe-'+exe);
            DebugLogHandler.logAppException('EscalateToBuyerBrokerController','escalateToBuyerBroker',exe.getMessage(),
                                            exe.getStackTraceString(),'Escalate To Buyer Broker');
            return false;
        }
    }
    
    
}
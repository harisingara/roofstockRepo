global class EmailPublisherForTransactionCases implements QuickAction.QuickActionDefaultsHandler {
    // Empty constructor
    global EmailPublisherForTransactionCases() {
    }
    
    // The main interface method
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
        System.debug(Logginglevel.ERROR, 'oninit');	
        
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = (QuickAction.SendEmailQuickActionDefaults)defaults.get(0);
        EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject(); 
        
        Case c = [SELECT CaseNumber, Recordtype.Name,Contact.Email,Transaction__r.Roofstock_TC_User__r.Email, 
                  Transaction__r.Roofstock_Account_Manager__r.Email FROM Case WHERE Id=:sendEmailDefaults.getContextId()];
        System.debug(Logginglevel.ERROR, 'record type'+ c.Recordtype.Name + emailMessage.FromAddress);	
        System.debug('-cc Address-'+c.Transaction__r.Roofstock_TC_User__r.Email);
        // If case type is transaction, default from to transaction email address
        String ccAddress ='';
        if(String.isNotBlank(c.Transaction__r.Roofstock_TC_User__r.Email) && String.isNotBlank(c.Transaction__r.Roofstock_Account_Manager__r.Email)){
            ccAddress = c.Transaction__r.Roofstock_TC_User__r.Email+' '+c.Transaction__r.Roofstock_Account_Manager__r.Email;
        }
        else if(String.isNotBlank(c.Transaction__r.Roofstock_TC_User__r.Email) && String.isBlank(c.Transaction__r.Roofstock_Account_Manager__r.Email)){
            ccAddress = c.Transaction__r.Roofstock_TC_User__r.Email;
        }
        else if(String.isBlank(c.Transaction__r.Roofstock_TC_User__r.Email) && String.isNotBlank(c.Transaction__r.Roofstock_Account_Manager__r.Email)){
            ccAddress = c.Transaction__r.Roofstock_Account_Manager__r.Email;
        }
        if (c.Recordtype.Name != null && (c.Recordtype.Name  == 'Transaction')) { // transction buyer or seller
            emailMessage.FromName = 'Roofstock Transactions';
            emailMessage.ValidatedFromAddress = 'transaction@roofstock.com';
            emailMessage.ToAddress = c.Contact.Email;
            if(String.isNotBlank(ccAddress)){
            	emailMessage.CcAddress = ccAddress;
            }
            //emailMessage.CcAddress = c.Transaction__r.Roofstock_Account_Manager__r.Email;
            System.debug(Logginglevel.ERROR, 'setting from ' + emailMessage.FromAddress);	
            
        }
        if (c.Recordtype.Name != null && (c.Recordtype.Name  == 'Certification')) { // transction buyer or seller
            emailMessage.FromName = 'Roofstock Certifications';
            emailMessage.ValidatedFromAddress = 'certification@roofstock.com';
            emailMessage.ToAddress = c.Contact.Email;
            System.debug(Logginglevel.ERROR, 'setting from ' + emailMessage.FromAddress);	
            
        }
    } 
}
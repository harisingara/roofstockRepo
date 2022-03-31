global class RESTPortfolioTransactionHelper {
    global class PortfolioTransactionsWrap{
        global List<PortfolioTransactions> PortfolioTransactionList;
    }
    global class PortfolioTransactions{
        global String   name;
        global String   portfolioTransactionId;
        global String   status;
        global String   portfolioCreationDate;
        global String   effectiveDate;
        global String   estimatedCloseDate;
        global String   closeDate;
        global String  salesPrice;
        global String  emdAmount;
        global String  rsCommission;
        global String   rsTransCoordinatorEmail;
        global String   rsCustomerServiceEmail;
        global String   rsAdvisorEmail;
        global String   buyerContactId;
        global String   buyerSignerContactId;
        global String   sellerContactId;
        global String   sellerSignerContactId;
        global String   titleCompanyContactId;
        global String   buyerPMContactId;
        
    }
    global class PostResponse {
        global ResponseWrapper responseBody;
        global PostResponse(List<ResponseBody> portfolioTransactionResponse) {
            this.responseBody = new ResponseWrapper(portfolioTransactionResponse);
        }
    }
    global class ResponseWrapper {  
        global List<ResponseBody> portfolioTransactionResponse;  
        global ResponseWrapper(){
            portfolioTransactionResponse = new List<ResponseBody>();
        }
        global ResponseWrapper(List<ResponseBody> portfolioTransactionResponse) {
            this.portfolioTransactionResponse = portfolioTransactionResponse;
        }
    } 
    global class ResponseBody{
        global String portfolioTransactionId;
        global String salesforceId;
        global ResponseBody(String portfolioTransactionId, String salesforceId) {
            this.portfolioTransactionId = portfolioTransactionId;
            this.salesforceId = salesforceId;
        }
    }
    global static PostResponse UpdatePortfolioTransaction(List<PortfolioTransactions> transactionList) {
        List<ResponseBody> responseList = new List<ResponseBody>();
        
        
        List<ResponseBody> transactionResponseList = new List<ResponseBody>();
        Set<String> userInputEmailSet = new Set<String>();
        Set<String> transactionIdSet = new Set<String>();  
        Set<String> contactIds = new Set<String>(); 
        Set<String> propertyInstanceIdSet = new Set<String>();
        Set<String> portfolioTransactionIdSet = new Set<String>();  

        for(PortfolioTransactions trans : transactionList){
            
            //Get Emails from the input string for users
            userInputEmailSet.add(trans.rsTransCoordinatorEmail);
            userInputEmailSet.add(trans.rsCustomerServiceEmail);
            userInputEmailSet.add(trans.rsAdvisorEmail);
       
            
            contactIds.add(trans.buyerContactId);
            contactIds.add(trans.buyerSignerContactId );
            contactIds.add(trans.sellerContactId);
            contactIds.add(trans.sellerSignerContactId );
            contactIds.add(trans.titleCompanyContactId );
            contactIds.add(trans.buyerPMContactId );
            
            portfolioTransactionIdSet.add(trans.portfolioTransactionId);
          
        }
        // remove blanks and nulls
        contactIds.remove('');
        contactIds.remove(null);
        
        //get record types 
        Map<String,String> transactionRecordTypesMap = new Map<String,String>();
        List<RecordType> recTypeList = [select Id,developername,sObjectType from Recordtype where sObjectType='Transaction__c'];
        
        for(RecordType recordtype :recTypeList){
            transactionRecordTypesMap.put(recordtype.developername,recordtype.Id);
        }
        
        //Query for the matching Contacts and create a map BPM Contact Id and Contact Id.
        Map<String,String> bpmContactIdMap = new Map<String,String>();
        List<Contact> matchingContactList = [select Id,BPM_Contact_Id__c,Email,Phone from Contact where (BPM_Contact_Id__c IN:contactIds)];
        
        if(matchingContactList.size()>0){
            for(Contact con:matchingContactList){
                bpmContactIdMap.put(con.BPM_Contact_Id__c,con.Id);
            }
        }
        
          System.debug('=bpmContactIdMap='+bpmContactIdMap);
        //Query for the matching Users and create a map of email and UserId
        Map<String,String> emailUserMap = new Map<String,String>();
        List<User> matchingUserList = [select Id,Email from User where Email IN:userInputEmailSet];
        if(matchingUserList.size()>0){
            for(User usr:matchingUserList){
                emailUserMap.put((usr.Email).toLowerCase(),usr.Id);
            }
        }
        System.debug('=emailUserMap='+emailUserMap);
        //Query for existing transaction Id's and Create a map of transaction Id and Transactiion Record
        Map<String,Transaction__c> transactionIdTransactionMap = new Map<String,Transaction__c>();
        List<Transaction__c> existingTransactionList = [select Id,Name,Portfolio_Transaction_Id__c,RecordTypeId,
                                                        Portfolio_Creation_Date__c,Effective_Date__c,Est_Close_Date__c,
                                                        Close_Date__c,Sale_Price__c,EMD_Amount__c,RS_Commission__c,
                                                        Roofstock_TC_User_Email__c,Roofstock_TC_User__c,Transaction_Status__c,
                                                        Roofstock_Customer_Service_Email__c,Roofstock_Customer_Service__c,
                                                        Roofstock_Advisor_Email__c,Roofstock_Advisor__c,Buyer_Contact_Id_1__c,
                                                        Buyer_Contact1__c,Buyer_Signer_Contact_Id__c,Buyer_Signer_Contact__c,
                                                        Seller_Contact_Id__c,Seller_Contact__c,Seller_Signer_Contact_Id__c,
                                                        Seller_Signer_Contact__c,Title_Contact_Id__c,Title_Company_Contact__c,
                                                        PM_Buyer_Contact__c,PM_Buyer_Contact_Id__c                                            
                                                        from Transaction__c where Portfolio_Transaction_Id__c IN:portfolioTransactionIdSet];
        
        if(existingTransactionList.size()>0){
            for(Transaction__c existingtransact:existingTransactionList){
                transactionIdTransactionMap.put((existingtransact.Portfolio_Transaction_Id__c),existingtransact);
            }
        }
         //Update Existing transaction/Create a new Transaction
        List<Transaction__c> createNewTransaction = new List<Transaction__c>();
        List<Transaction__c> updateExistingTransaction = new List<Transaction__c>();
        
        for(PortfolioTransactions inputtransaction : transactionList){
            
            if(transactionIdTransactionMap.containsKey(inputtransaction.portfolioTransactionId)){
                Transaction__c existingTransaction = transactionIdTransactionMap.get(inputtransaction.portfolioTransactionId);
                Transaction__c updatedTransaction = createUpdateTransaction(existingTransaction,inputtransaction,emailUserMap,bpmContactIdMap,transactionRecordTypesMap );
                updateExistingTransaction.add(updatedTransaction);
            }
            else{
                Transaction__c newTransaction = new Transaction__c();
                Transaction__c newCreatedTransaction = createUpdateTransaction(newTransaction,inputtransaction,emailUserMap,bpmContactIdMap, transactionRecordTypesMap);
                createNewTransaction.add(newCreatedTransaction);
            }
            
        }
        if(updateExistingTransaction.size()>0){
            update updateExistingTransaction;
        }
        if(createNewTransaction.size()>0){
            insert createNewTransaction;
        }
        //Logic to dedupe records
        updateExistingTransaction.addAll(createNewTransaction);
        set<Transaction__c> dedupeTransactionset = new set<Transaction__c>();
        dedupeTransactionset.addAll(updateExistingTransaction);
        updateExistingTransaction.clear();
        updateExistingTransaction.addAll(dedupeTransactionset);
        
        for(Transaction__c trans:updateExistingTransaction){
            transactionResponseList.add(new ResponseBody(trans.Portfolio_Transaction_Id__c, trans.id));     
        }
        postResponse res = new postResponse(transactionResponseList);
        return res;
       
    }
    
     global static Transaction__c createUpdateTransaction(Transaction__c contextTransaction,PortfolioTransactions inputtransaction,Map<String,String> emailUserMap,Map<String,String> bpmContactIdMap, Map<String,String> transactionRecordTypesMap){
        
        if(inputtransaction.name!=null){
            contextTransaction.Name = inputtransaction.name;
        }
        if(inputtransaction.portfolioTransactionId!=null)
            contextTransaction.Portfolio_Transaction_Id__c = inputtransaction.portfolioTransactionId;
         
        //assign record type
        if(transactionRecordTypesMap!=null){
            contextTransaction.RecordTypeId = transactionRecordTypesMap.get('Portfolio_Transaction');    
        }
        if(inputtransaction.portfolioCreationDate!=null)
            contextTransaction.Portfolio_Creation_Date__c = Date.valueOf(inputtransaction.portfolioCreationDate);
         
         if(inputtransaction.effectiveDate!=null)
            contextTransaction.Effective_Date__c = Date.valueOf(inputtransaction.effectiveDate);
         
         if(inputtransaction.estimatedCloseDate!=null)
            contextTransaction.Est_Close_Date__c = Date.valueOf(inputtransaction.estimatedCloseDate);
         
         if(inputtransaction.closeDate!=null)
            contextTransaction.Close_Date__c = Date.valueOf(inputtransaction.closeDate);
         
         if(inputtransaction.status!=null)
            contextTransaction.Transaction_Status__c = inputtransaction.status;         
         
         if(inputtransaction.salesPrice!=null)
            contextTransaction.Sale_Price__c = Decimal.valueOf(inputtransaction.salesPrice);
         
         if(inputtransaction.emdAmount!=null)
            contextTransaction.EMD_Amount__c = Decimal.valueOf(inputtransaction.emdAmount);
         
         if(inputtransaction.rsCommission!=null)
            contextTransaction.RS_Commission__c = Decimal.valueOf(inputtransaction.rsCommission);
         
         if(inputtransaction.rsTransCoordinatorEmail!=null){
            contextTransaction.Roofstock_TC_User_Email__c = inputtransaction.rsTransCoordinatorEmail;
            if(emailUserMap.containsKey((inputtransaction.rsTransCoordinatorEmail).toLowerCase())){
                contextTransaction.Roofstock_TC_User__c = emailUserMap.get((inputtransaction.rsTransCoordinatorEmail).toLowerCase());        
            }
         }
         if(inputtransaction.rsCustomerServiceEmail!=null){
            contextTransaction.Roofstock_Customer_Service_Email__c = inputtransaction.rsCustomerServiceEmail;
             System.debug('=rsCustomerServiceEmail='+inputtransaction.rsCustomerServiceEmail);
             System.debug('=emailUserMap='+emailUserMap);
            if(emailUserMap.containsKey((inputtransaction.rsCustomerServiceEmail).toLowerCase())){
                contextTransaction.Roofstock_Customer_Service__c = emailUserMap.get((inputtransaction.rsCustomerServiceEmail).toLowerCase());        
            }
         }
         if(inputtransaction.rsAdvisorEmail!=null){
            contextTransaction.Roofstock_Advisor_Email__c = inputtransaction.rsAdvisorEmail;
            if(emailUserMap.containsKey((inputtransaction.rsAdvisorEmail).toLowerCase())){
                contextTransaction.Roofstock_Advisor__c = emailUserMap.get((inputtransaction.rsAdvisorEmail).toLowerCase());         
            }
        }
        if(inputtransaction.buyerContactId!=null){
           contextTransaction.Buyer_Contact_Id_1__c = inputtransaction.buyerContactId;
           if(bpmContactIdMap.containsKey(inputtransaction.buyerContactId)){
            contextTransaction.Buyer_Contact1__c = bpmContactIdMap.get(inputtransaction.buyerContactId);         
           }
        }
        if(inputtransaction.buyerSignerContactId!=null){
           contextTransaction.Buyer_Signer_Contact_Id__c = inputtransaction.buyerSignerContactId;
           if(bpmContactIdMap.containsKey(inputtransaction.buyerSignerContactId)){
            contextTransaction.Buyer_Signer_Contact__c = bpmContactIdMap.get(inputtransaction.buyerSignerContactId);         
           }
        }
        if(inputtransaction.sellerContactId!=null){
           contextTransaction.Seller_Contact_Id__c = inputtransaction.sellerContactId;
           if(bpmContactIdMap.containsKey(inputtransaction.sellerContactId)){
            contextTransaction.Seller_Contact__c = bpmContactIdMap.get(inputtransaction.sellerContactId);        
           }
        }
        if(inputtransaction.sellerSignerContactId!=null){
           contextTransaction.Seller_Signer_Contact_Id__c = inputtransaction.sellerSignerContactId;
           if(bpmContactIdMap.containsKey(inputtransaction.sellerSignerContactId)){
            contextTransaction.Seller_Signer_Contact__c = bpmContactIdMap.get(inputtransaction.sellerSignerContactId);       
           }
        }
        if(inputtransaction.titleCompanyContactId!=null){
           contextTransaction.Title_Contact_Id__c = inputtransaction.titleCompanyContactId;
           if(bpmContactIdMap.containsKey(inputtransaction.titleCompanyContactId)){
            contextTransaction.Title_Company_Contact__c = bpmContactIdMap.get(inputtransaction.titleCompanyContactId);       
           }
        }
         
        if(inputtransaction.buyerPMContactId!=null){
           contextTransaction.PM_Buyer_Contact_Id__c = inputtransaction.buyerPMContactId;
           if(bpmContactIdMap.containsKey(inputtransaction.buyerPMContactId)){
            contextTransaction.PM_Buyer_Contact__c = bpmContactIdMap.get(inputtransaction.buyerPMContactId);       
           }
        } 
         return contextTransaction;
     }
}
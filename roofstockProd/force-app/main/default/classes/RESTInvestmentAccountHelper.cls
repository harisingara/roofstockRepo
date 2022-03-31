global class RESTInvestmentAccountHelper {
    global class InvAccWrap{
        global List<InvestmentAccounts> investmentAccountList;
    }
    global class InvestmentAccounts{
        global string investmentAccountId;
        global string investmentAccountName;
        global string roofstockAccountId;
        global Boolean isRoofstockManaged;
        global string primaryContactPhone;
        global string primaryContactEmail;
        global string primaryContactFirstName;
        global String primaryContactLastName;
    } 
    global class InvAccResponse {
        global string id;
        global string investmentAccountId;
        global string errorMessage;
        global InvAccResponse(string Id,string externalId, string errorMessage){
            this.id = Id; 
            this.investmentAccountId = externalId; 
            this.errorMessage = errorMessage;
        }
    }
    global static List<InvAccResponse>  upsertInvestmentAccount(List<InvestmentAccounts> investmentAccountList){ 
        set<String> setRSAccIds = new set<String>();
        map<String,Id> mapRSAccIds = new map<String,Id>();
        set<String> setConEmailsIds = new set<String>();
        map<String,Id> mapConEmailsIds = new map<String,Id>();
        map<String,Id> mapConEmailAccIds = new map<String,Id>();
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Roofstock_Contact').getRecordTypeId();
        List<InvAccResponse> oResponse = new List<InvAccResponse>();
        List<Investment_Account_Contact_Role__c> lstInvAccCon = new List<Investment_Account_Contact_Role__c>();
        
        for(InvestmentAccounts oInvAcc: investmentAccountList){
            setRSAccIds.add(oInvAcc.roofstockAccountId); 
            if(!String.isEmpty(oInvAcc.primaryContactEmail)){
            	setConEmailsIds.add((oInvAcc.primaryContactEmail).toLowercase());
            }
        }
        if(!setRSAccIds.IsEmpty()){
            List<Account> lstAcc = [Select Id,Roofstock_Account_ID__c from Account where Roofstock_Account_ID__c IN:setRSAccIds];	
            for(Account oAcc:lstAcc){
                mapRSAccIds.put(oAcc.Roofstock_Account_ID__c, oAcc.Id);  
            }
        } 
        if(!setConEmailsIds.IsEmpty()){
            List<Contact> lstCon = [Select Id,Email,AccountId from Contact where (Email IN:setConEmailsIds Or Email = 'daria@roofstock.com') AND RecordTypeId =: contactRecordTypeId];	
            for(Contact oCon:lstCon){
                mapConEmailsIds.put(oCon.Email, oCon.Id);  
                mapConEmailAccIds.put(oCon.Email, oCon.AccountId); 
            }
        }
        List<Investment_Account__c> lstInvAccUpsert = new List<Investment_Account__c>(); 
        Investment_Account__c oTempInvAcc; 
        Investment_Account_Contact_Role__c oTempInvAccCon; 
        for(InvestmentAccounts oInvAcc: investmentAccountList){
           
            oTempInvAcc = new Investment_Account__c();
            if(oInvAcc.investmentAccountName != null && oInvAcc.investmentAccountName.length() > 80){
            	oTempInvAcc.Name = oInvAcc.investmentAccountName.substring(0, 79);    
            }
            else{
            	oTempInvAcc.Name = oInvAcc.investmentAccountName;
            }
            oTempInvAcc.Investment_Account_Title__c = oInvAcc.investmentAccountName;
            oTempInvAcc.Investment_Account_Id__c = oInvAcc.investmentAccountId; 
            oTempInvAcc.Is_Roofstock_Managed__c = oInvAcc.isRoofstockManaged;
            if(oTempInvAcc.Is_Roofstock_Managed__c){
                oTempInvAcc.Primary_Contact__c = mapConEmailsIds.get('daria@roofstock.com');	
                oTempInvAcc.Account__c = mapConEmailAccIds.get('daria@roofstock.com');
                oTempInvAcc.Primary_Contact_Email__c  = (oInvAcc.primaryContactEmail).toLowercase();
                oTempInvAcc.Primary_Contact_First_Name__c = oInvAcc.primaryContactFirstName;
                oTempInvAcc.Primary_Contact_Last_Name__c = oInvAcc.primaryContactLastName;
                oTempInvAcc.Primary_Contact_Phone__c = oInvAcc.primaryContactPhone;  
                lstInvAccUpsert.add(oTempInvAcc); 
            }
            else{
                if(oInvAcc.primaryContactEmail != null){
                 if(mapConEmailsIds.get((oInvAcc.primaryContactEmail).toLowercase()) != null){
                    oTempInvAcc.Account__c = mapRSAccIds.get(oInvAcc.roofstockAccountId);
                    oTempInvAcc.Primary_Contact__c = mapConEmailsIds.get((oInvAcc.primaryContactEmail).toLowercase()); 
                    lstInvAccUpsert.add(oTempInvAcc); 
                     
                    oTempInvAccCon = new Investment_Account_Contact_Role__c();    
                    oTempInvAccCon.Investment_Account__r =  new Investment_Account__c(Investment_Account_Id__c = oInvAcc.investmentAccountId); //mapInvAccId.get(oInvAcc.investmentAccountId); 
                    oTempInvAccCon.Contact__c = mapConEmailsIds.get((oInvAcc.primaryContactEmail).toLowercase());
                    oTempInvAccCon.Role__c = 'Primary';
                    oTempInvAccCon.Investment_Account_Contact_Unique_Id__c = String.valueOF(oInvAcc.investmentAccountId) + String.ValueOf(oTempInvAccCon.Contact__c);
                    lstInvAccCon.add(oTempInvAccCon);   
                }else{
               		oResponse.add(new InvAccResponse('', oInvAcc.investmentAccountId, 'No Contact found with email '+ (oInvAcc.primaryContactEmail).toLowercase())); 
            	}
                }
                else{
               		oResponse.add(new InvAccResponse('', oInvAcc.investmentAccountId, 'No Contact found with email '+ oInvAcc.primaryContactEmail)); 
                    
                }
            }
            
            
        }
        if(!lstInvAccUpsert.IsEmpty()){
            upsert lstInvAccUpsert Investment_Account_Id__c;
            System.debug('-lstInvAccUpsert-'+lstInvAccUpsert);
            /*map<String,Id> mapInvAccId = new map<String,Id>(); 
            for(Investment_Account__c oInvAcc:lstInvAccUpsert){
                mapInvAccId.put(oInvAcc.Investment_Account_Id__c , oInvAcc.Id); 	    
            }
            
            
            for(InvestmentAccounts oInvAcc: investmentAccountList){
                if(!oInvAcc.isRoofstockManaged){
                    
                }   
            }*/
            System.debug('-lstInvAccCon-'+lstInvAccCon);
            if(!lstInvAccCon.IsEmpty()){
                 upsert lstInvAccCon Investment_Account_Contact_Unique_Id__c;  
            }
           
            for(Investment_Account__c oInvAcc:lstInvAccUpsert){
                oResponse.add(new InvAccResponse(oInvAcc.Id , oInvAcc.Investment_Account_Id__c ,'') );     
            }
             
        }
        return oResponse;
    }
}
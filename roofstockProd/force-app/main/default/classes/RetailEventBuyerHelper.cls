public class RetailEventBuyerHelper {
    /*1.Logic to Handle Made An Offer Events
* 
*/
    @future
    public static void futuremethod(String inp){
        List<Retail_Event__e> RetailEventRecords = (List<Retail_Event__e>) JSON.deserialize(inp,List<Retail_Event__e>.class); // this is not correct. I am trying to figure out a way where I could use something like this. 
         //  List<Account> acc = (List<Account>) JSON.deserialize(inp, List<Account>.class);
		map<String,Retail_Event__e> mapConIdsEmailOfferDate = new  map<String,Retail_Event__e>(); 
       // map<String,String> mapEmailOfferDate = new  map<String,Date>(); 
        List<Retail_Event__e> lstRetailEvents = new List<Retail_Event__e>(); 
        boolean bUpdateMadeAnOffer;
        Set<String> requestEmailSet = new Set<String>();
        Set<String> requestBpmContactIdSet = new Set<String>();
        for(Retail_Event__e event :RetailEventRecords) {
            if(event.Event_Name__c == 'BUYER_MADE_AN_OFFER'){
                bUpdateMadeAnOffer = false;
                if( event.Attribute1__c == 'contactId' && !String.isBlank(event.AttributeValue2__c) && !String.isBlank(event.AttributeValue1__c)){
                    mapConIdsEmailOfferDate.put(event.AttributeValue1__c , event); // date.valueOf(event.AttributeValue2__c
                    bUpdateMadeAnOffer = true;
                    requestBpmContactIdSet.add(event.AttributeValue1__c); 
                } 
                if(event.Attribute2__c == 'offerDate' && !String.isBlank(event.AttributeValue2__c) && !String.isBlank(event.Email__c)){
                    mapConIdsEmailOfferDate.put((event.Email__c).toLowerCase(), event); 
                    requestEmailSet.add(event.Email__c); 
                    bUpdateMadeAnOffer = true; 
                }	 
                if(bUpdateMadeAnOffer){
                    lstRetailEvents.add(event); 
                }
            }  
        }
        if(!mapConIdsEmailOfferDate.IsEmpty()){
            Set<String> sKeyIds = mapConIdsEmailOfferDate.keySet(); 
            system.debug('test'+ sKeyIds);
            system.debug('requestEmailSet'+ requestEmailSet);
            system.debug('requestBpmContactIdSet'+ requestBpmContactIdSet);
            Id leadBuyerRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        
            //List<Lead> matchingLead = [select Id,RecordTypeId,BPM_Contact_Id__c,Email,Phone,MobilePhone from Lead where ((RecordTypeId=:leadBuyerRecordTypeId) AND (BPM_Contact_Id__c IN:sKeyIds OR Email IN:sKeyIds OR Phone IN:sKeyIds OR mobilePhone IN:sKeyIds) AND isConverted=false)];
 
            // Fetch all the matching lead Ids 
            List<Lead> lstLead = [Select id,Email,BPM_Contact_Id__c from Lead where ( (RecordTypeId=:leadBuyerRecordTypeId) AND ( BPM_Contact_Id__c IN:sKeyIds OR Email IN:sKeyIds   )  AND isConverted = false )]; 
            if(!lstLead.IsEmpty()){
                List<Lead> lstUpdateLead = new List<Lead>(); 
                Retail_Event__e oUpdateEvent;
                for(Lead oLead:lstLead){
                    oUpdateEvent = null; 
                    if(mapConIdsEmailOfferDate.containskey(oLead.BPM_Contact_Id__c)){
                    	oUpdateEvent = mapConIdsEmailOfferDate.get(oLead.BPM_Contact_Id__c); 
                        oLead.Made_An_Offer_Date__c = date.valueOf(oUpdateEvent.AttributeValue2__c);
                        lstUpdateLead.add(oLead); 
                    }
                    else if(mapConIdsEmailOfferDate.containskey((oLead.Email).toLowerCase())){
                        oUpdateEvent = mapConIdsEmailOfferDate.get((oLead.Email).toLowerCase());
                        oLead.Made_An_Offer_Date__c = date.valueOf(oUpdateEvent.AttributeValue2__c);
                        lstUpdateLead.add(oLead); 
                        
                    }
                    if(oUpdateEvent <> null){
                    	mapConIdsEmailOfferDate.remove(oUpdateEvent.AttributeValue1__c);
                        mapConIdsEmailOfferDate.remove((oUpdateEvent.Email__c).toLowerCase());	
                    }
                }
                if(!lstUpdateLead.IsEmpty())
                    update lstUpdateLead; 
            }
            if(!mapConIdsEmailOfferDate.IsEmpty()){
                // Fetch all the matching lead Ids 
                sKeyIds = mapConIdsEmailOfferDate.keySet();
                Id contactBuyerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Roofstock Contact').getRecordTypeId();
                List<Contact> lstContacts = [Select id,Email,BPM_Contact_Id__c from Contact where (Email IN:sKeyIds OR BPM_Contact_Id__c IN:sKeyIds) AND RecordtypeId =:contactBuyerRecordTypeId]; 
                if(!lstContacts.IsEmpty()){
                    List<Contact> lstUpdateCon = new List<Contact>(); 
                    Retail_Event__e oUpdateEvent;
                    for(Contact oCon:lstContacts){
                        oUpdateEvent = null; 
                    if(mapConIdsEmailOfferDate.containskey(oCon.BPM_Contact_Id__c)){
                    	oUpdateEvent = mapConIdsEmailOfferDate.get(oCon.BPM_Contact_Id__c); 
                        oCon.Made_An_Offer_Date__c = date.valueOf(oUpdateEvent.AttributeValue2__c);
                        lstUpdateCon.add(oCon); 
                    }
                    else if(mapConIdsEmailOfferDate.containskey((oCon.Email).toLowerCase())){
                        oUpdateEvent = mapConIdsEmailOfferDate.get((oCon.Email).toLowerCase());
                        oCon.Made_An_Offer_Date__c = date.valueOf(oUpdateEvent.AttributeValue2__c);
                        lstUpdateCon.add(oCon); 
                        
                    }
                    }
                    if(!lstUpdateCon.IsEmpty())
                        update lstUpdateCon; 
                }	    
            }
        }
    }
    Public static void updateMadeAnOfferEvents(List<Retail_Event__e> RetailEventRecords) {
        map<String,Retail_Event__e> mapConIdsEmailOfferDate = new  map<String,Retail_Event__e>(); 
       // map<String,String> mapEmailOfferDate = new  map<String,Date>(); 
        List<Retail_Event__e> lstRetailEvents = new List<Retail_Event__e>(); 
        boolean bUpdateMadeAnOffer;
        Set<String> requestEmailSet = new Set<String>();
        Set<String> requestBpmContactIdSet = new Set<String>();
        for(Retail_Event__e event :RetailEventRecords) {
            if(event.Event_Name__c == 'BUYER_MADE_AN_OFFER'){
                System.debug('-event-'+event.Event_Name__c);
                bUpdateMadeAnOffer = false;
                if( event.Attribute1__c == 'contactId' && !String.isBlank(event.AttributeValue2__c) && !String.isBlank(event.AttributeValue1__c)){
                    mapConIdsEmailOfferDate.put(event.AttributeValue1__c , event); // date.valueOf(event.AttributeValue2__c
                    bUpdateMadeAnOffer = true;
                    requestBpmContactIdSet.add(event.AttributeValue1__c); 
                } 
                if(event.Attribute2__c == 'offerDate' && !String.isBlank(event.AttributeValue2__c) && !String.isBlank(event.Email__c)){
                    mapConIdsEmailOfferDate.put((event.Email__c).toLowerCase() , event); 
                    requestEmailSet.add((event.Email__c).toLowerCase()); 
                    bUpdateMadeAnOffer = true; 
                }	 
                if(bUpdateMadeAnOffer){
                    lstRetailEvents.add(event); 
                }
            }  
        }
        if(!lstRetailEvents.IsEmpty()){
        	RetailEventBuyerHelper.futuremethod(JSON.serialize(lstRetailEvents));     
        }/*
        if(!mapConIdsEmailOfferDate.IsEmpty()){
            Set<String> sKeyIds = mapConIdsEmailOfferDate.keySet(); 
            system.debug('test'+ sKeyIds);
            system.debug('requestEmailSet'+ requestEmailSet);
            system.debug('requestBpmContactIdSet'+ requestBpmContactIdSet);
            Id leadBuyerRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Retail Buyer').getRecordTypeId();
        
            //List<Lead> matchingLead = [select Id,RecordTypeId,BPM_Contact_Id__c,Email,Phone,MobilePhone from Lead where ((RecordTypeId=:leadBuyerRecordTypeId) AND (BPM_Contact_Id__c IN:sKeyIds OR Email IN:sKeyIds OR Phone IN:sKeyIds OR mobilePhone IN:sKeyIds) AND isConverted=false)];
 
            // Fetch all the matching lead Ids 
            List<Lead> lstLead = [Select id,Email,BPM_Contact_Id__c from Lead where ( (RecordTypeId=:leadBuyerRecordTypeId) AND ( BPM_Contact_Id__c IN:requestBpmContactIdSet OR Email IN:requestEmailSet   )  AND isConverted = false )]; 
            if(!lstLead.IsEmpty()){
                List<Lead> lstUpdateLead = new List<Lead>(); 
                Retail_Event__e oUpdateEvent;
                for(Lead oLead:lstLead){
                    oUpdateEvent = null; 
                    if(mapConIdsEmailOfferDate.containskey(oLead.BPM_Contact_Id__c)){
                    	oUpdateEvent = mapConIdsEmailOfferDate.get(oLead.BPM_Contact_Id__c); 
                        oLead.Made_An_Offer_Date__c = date.valueOf(oUpdateEvent.AttributeValue2__c);
                        lstUpdateLead.add(oLead); 
                    }
                    else if(mapConIdsEmailOfferDate.containskey(oLead.Email)){
                        oUpdateEvent = mapConIdsEmailOfferDate.get(oLead.Email);
                        oLead.Made_An_Offer_Date__c = date.valueOf(oUpdateEvent.AttributeValue2__c);
                        lstUpdateLead.add(oLead); 
                        
                    }
                    if(oUpdateEvent <> null){
                    	mapConIdsEmailOfferDate.remove(oUpdateEvent.AttributeValue1__c);
                        mapConIdsEmailOfferDate.remove(oUpdateEvent.Email__c);	
                    }
                }
                if(!lstUpdateLead.IsEmpty())
                    update lstUpdateLead; 
            }
            if(!mapConIdsEmailOfferDate.IsEmpty()){
                // Fetch all the matching lead Ids 
                sKeyIds = mapConIdsEmailOfferDate.keySet();
                Id contactBuyerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Roofstock Contact').getRecordTypeId();
                List<Contact> lstContacts = [Select id,Email,BPM_Contact_Id__c from Contact where (Email IN:sKeyIds OR BPM_Contact_Id__c IN:sKeyIds) AND RecordtypeId =:contactBuyerRecordTypeId]; 
                if(!lstContacts.IsEmpty()){
                    List<Contact> lstUpdateCon = new List<Contact>(); 
                    Retail_Event__e oUpdateEvent;
                    for(Contact oCon:lstContacts){
                        oUpdateEvent = null; 
                    if(mapConIdsEmailOfferDate.containskey(oCon.BPM_Contact_Id__c)){
                    	oUpdateEvent = mapConIdsEmailOfferDate.get(oCon.BPM_Contact_Id__c); 
                        oCon.Made_An_Offer_Date__c = date.valueOf(oUpdateEvent.AttributeValue2__c);
                        lstUpdateCon.add(oCon); 
                    }
                    else if(mapConIdsEmailOfferDate.containskey(oCon.Email)){
                        oUpdateEvent = mapConIdsEmailOfferDate.get(oCon.Email);
                        oCon.Made_An_Offer_Date__c = date.valueOf(oUpdateEvent.AttributeValue2__c);
                        lstUpdateCon.add(oCon); 
                        
                    }
                    }
                    if(!lstUpdateCon.IsEmpty())
                        update lstUpdateCon; 
                }	    
            }
        }*/
    }
    /*1.Logic to Handle Buyer Events
* 
*/
    Public static void updateBuyerEventsDetails(List<Retail_Event__e> buyerRetailEvents) {
        Map<String,Retail_Event__e> emailRetailMap = new Map<String,Retail_Event__e>();
        Map<String,Retail_Event__e> phoneRetailMap = new Map<String,Retail_Event__e>();
        Map<String,Retail_Event__e> BPMContactRoofStockUserRetailMap = new Map<String,Retail_Event__e>();
        
        //Check for Event Type
        for(Retail_Event__e event :buyerRetailEvents) {
            if(event.Event_Name__c == 'BUY_BUTTON_CLICKED'){
                emailRetailMap.put(event.Email__c, event);
                phoneRetailMap.put(event.Phone__c, event);
                //phoneRetailMap.put('(' + event.Phone__c.substring(0, 3) + ') ' + event.Phone__c.substring(3, 6) + '-' + event.Phone__c.substring(6),event);
            }
            if(event.Event_Name__c == 'CONTACT_UPDATED'){
                if(event.Attribute1__c =='rsuserid'){
                    BPMContactRoofStockUserRetailMap.put(event.AttributeValue1__c,event);    
                }
                if(event.Attribute2__c =='bpmcontactid'){
                    BPMContactRoofStockUserRetailMap.put(event.AttributeValue2__c,event);    
                }    
            }
        }
        System.debug('=phoneRetailMap='+phoneRetailMap.keySet());
        System.debug('=BPMContactRoofStockUserRetailMap='+BPMContactRoofStockUserRetailMap.keySet());
        
        //Logic for Buy Button Clicked Event
        if(emailRetailMap.keyset().size()>0 || phoneRetailMap.keyset().size()>0){
            List<Lead> leadList = [select Id,Email,Roofstock_User_Id__c,BPM_Contact_Id__c,Phone,ownerid from Lead where (Email IN :emailRetailMap.keyset() OR Phone IN:phoneRetailMap.keyset())];
            List<Contact> contactList = [select Id,Email,Roofstock_User_Id__c,BPM_Contact_Id__c,Phone,ownerid from Contact where (Email IN :emailRetailMap.keyset() OR Phone IN :phoneRetailMap.keyset())];
            
            Map<String,Retail_Event__e> emailmatchingSFRecords = new Map<String,Retail_Event__e>();
            Map<String,Retail_Event__e> phonematchingSFRecords = new Map<String,Retail_Event__e>();
            
            List<Task> tasksToCreate = new List<Task>();
            
            //scan for matching leads
            for(Lead lead :leadList){ 
                if(emailRetailMap.containsKey(lead.Email) || phoneRetailMap.containskey(lead.Phone)){
                    System.debug(LoggingLevel.ERROR, 'leads: found!');
                    
                    Retail_Event__e retailEvent = emailRetailMap.containsKey(lead.Email) ? emailRetailMap.get(lead.Email) : phoneRetailMap.get(lead.Phone);
                    emailmatchingSFRecords.put(retailEvent.Email__c, retailEvent);
                    phonematchingSFRecords.put(retailEvent.Phone__c, retailEvent);
                    //phonematchingSFRecords.put('(' + retailEvent.Phone__c.substring(0, 3) + ') ' + retailEvent.Phone__c.substring(3, 6) + '-' + retailEvent.Phone__c.substring(6),retailEvent);
                    
                    //logic to create task
                    tasksToCreate.add(RetailEventBuyerHelper.CreateTask(retailEvent, lead.ownerid, lead.id));                   
                }
                
            }
            //scan for matching contacts
            for(Contact contact:contactList) {
                System.debug(LoggingLevel.ERROR, 'contacts: found!');
                
                if(emailRetailMap.containsKey(contact.Email) || phoneRetailMap.containskey(contact.Phone)){
                    
                    Retail_Event__e retailEvent = emailRetailMap.containsKey(contact.Email) ? emailRetailMap.get(contact.Email) : phoneRetailMap.get(contact.Phone);
                    emailmatchingSFRecords.put(retailEvent.Email__c, retailEvent);
                    phonematchingSFRecords.put(retailEvent.Phone__c, retailEvent);
                    //phonematchingSFRecords.put('(' + retailEvent.Phone__c.substring(0, 3) + ') ' + retailEvent.Phone__c.substring(3, 6) + '-' + retailEvent.Phone__c.substring(6),retailEvent);
                    
                    tasksToCreate.add(RetailEventBuyerHelper.CreateTask(retailEvent, contact.ownerid, contact.id));
                }    
            }
            
            System.debug(LoggingLevel.ERROR, 'tasks: ' + tasksToCreate);
            
            //create tasks
            insert tasksToCreate;
            
            List<Retail_Event__e> recordsNotFound = new List<Retail_Event__e>();
            for(Retail_Event__e revents :buyerRetailEvents){
                if((!emailmatchingSFRecords.containskey(revents.Email__c)) && (!phonematchingSFRecords.containskey(revents.Phone__c))){
                    //Function to add Email
                    if(revents.Email__c!=null || revents.Email__c!=''){
                        recordsNotFound.add(emailRetailMap.get(revents.Email__c)); 
                    }
                    else if(revents.Phone__c!=null || revents.Phone__c!=''){
                        recordsNotFound.add(emailRetailMap.get(revents.Phone__c)); 
                    }
                }
            }
            EmailMismatchedRecords(recordsNotFound);
        }
        
        //Logic for contact update event
        if(BPMContactRoofStockUserRetailMap.keyset().size()>0){
            List<Lead> leadList = [select Id,Email,Roofstock_User_Id__c,BPM_Contact_Id__c,Phone,ownerid from Lead where (Roofstock_User_Id__c IN :BPMContactRoofStockUserRetailMap.keyset() OR BPM_Contact_Id__c IN:BPMContactRoofStockUserRetailMap.keyset())];
            List<Contact> contactList = [select Id,Email,Roofstock_User_Id__c,BPM_Contact_Id__c,Phone,ownerid from Contact where (Roofstock_User_Id__c IN :BPMContactRoofStockUserRetailMap.keyset() OR BPM_Contact_Id__c IN :BPMContactRoofStockUserRetailMap.keyset())];
            //Logic to update Lead Phone
            List<Lead> updateLeadPhoneList = new List<Lead>();
            if(leadList.size()>0){
                for(Lead l :leadList){
                    if(String.isBlank(l.Phone)){
                        Retail_Event__e retEvent = BPMContactRoofStockUserRetailMap.containsKey(l.Roofstock_User_Id__c)?BPMContactRoofStockUserRetailMap.get(l.Roofstock_User_Id__c):BPMContactRoofStockUserRetailMap.get(l.BPM_Contact_Id__c);
                        l.phone = retEvent.Phone__c;
                        updateLeadPhoneList.add(l);
                    }
                } 
            }
            //Logic to update Contact Phone
            List<Contact> updateContactPhoneList = new List<Contact>();
            if(contactList.size()>0){
                for(Contact c :contactList){
                    if(String.isBlank(c.Phone)){
                        Retail_Event__e retEvent = BPMContactRoofStockUserRetailMap.containsKey(c.Roofstock_User_Id__c)?BPMContactRoofStockUserRetailMap.get(c.Roofstock_User_Id__c):BPMContactRoofStockUserRetailMap.get(c.BPM_Contact_Id__c);
                        c.phone = retEvent.Phone__c;
                        updateContactPhoneList.add(c);
                    }
                } 
            }
            
            if(updateLeadPhoneList.size()>0){
                update updateLeadPhoneList;
            }
            if(updateContactPhoneList.size()>0){
                update updateContactPhoneList;   
            }
        }
    } //method
    
    /*1.Logic to Create Tasks
* 
*/
    Public static Task CreateTask(Retail_Event__e retailEvent, Id ownerId , Id objectId) {
        
        //logic to create task
        Task task = new Task();
        task.Subject = retailEvent.Event_Name__c;
        task.Priority ='Medium';
        task.Status = 'New';
        task.OwnerId = ownerId;
        task.WhoId = objectId;
        task.Description = 'AccountId: '+' '+retailEvent.Account_Id__c+'\nEvent Name: '+' '+retailEvent.Event_Name__c
            +'\nEmail: ' +' '+retailEvent.Email__c+'\nPhone: '+' '+retailEvent.Phone__c
            +'\n'+retailEvent.Attribute1__c+' : '+retailEvent.AttributeValue1__c
            +'\n'+retailEvent.Attribute2__c+' : '+retailEvent.AttributeValue2__c
            +'\n'+retailEvent.Attribute3__c+' : '+retailEvent.AttributeValue3__c;
        
        System.debug(LoggingLevel.ERROR, 'creattask: ' + task);
        
        return task;
    }  //method
    
    /*1.Logic to send Email
* 
*/
    
    Public static void EmailMismatchedRecords(List<Retail_Event__e> misMatchEventsList){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add('sreekumar@roofstock.com');
        mail.setToAddresses(sendTo);
        mail.setSubject('MisMatch in Lead/Contact');
        String body = '';
        for(Retail_Event__e re :misMatchEventsList){
            body = body+re+'\n';
        }
        mail.setHtmlBody(body);
        mails.add(mail);
        Messaging.sendEmail(mails);
    }
    
}
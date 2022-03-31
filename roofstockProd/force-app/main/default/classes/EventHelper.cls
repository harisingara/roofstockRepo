public class EventHelper {
    //Process Builder - Appointment Created
    public static void appointmentCreated(List<Event> eventList){
        Set<String> matchEventSet = new Set<String>();
        for(Event evt :eventList){
            if(evt.Subject.containsIgnoreCase('Calendly')){
                if(evt.whoId!=null){
                    matchEventSet.add(evt.whoId);
                }
            } 
        }
        System.debug('=matchEventSet='+matchEventSet);
        List<Lead> updateLeadList = new List<Lead>();
        List<Lead> matchingLead = [select Id,Appointment__c from Lead where Id IN:matchEventSet];
        System.debug('=matchingLead='+matchingLead);
        if(!matchingLead.isEmpty()){
            for(Lead ld :matchingLead){
                ld.Appointment__c = true;
                updateLeadList.add(ld);
            }
        }
        if(!updateLeadList.isEmpty()){
            update updateLeadList; 
        }
    }
    
    //Process Builder - Event lookup Opp
    public static void updateEventOpportunity(List<Event> newEventList){
        for(Event newEvent : newEventList){
            if(newEvent.WhatId!=null){
                String whatId = newEvent.WhatId;
                if(whatId.startsWith('006')){
                    newEvent.RelatedOpp__c = newEvent.WhatId;
                }
            }
        }
    }
    //Process Builder - Meeting Booked
    public static void meetingBooked(List<Event> newEventList){
        Set<String> accountIdSet = new Set<String>();
        Set<String> leadIdSet = new Set<String>();
        Set<String> contactIdSet = new Set<String>();
        
        List<Account> accountList = new List<Account>();
        List<Lead> leadList = new List<Lead>();
        
        for(Event newEvent : newEventList){
            System.debug('newEvent::'+newEvent);
            if(newEvent.WhatId!=null){
                String whatId = newEvent.WhatId;
                if(newEvent.Subject.containsIgnoreCase('Calendly') && whatId.startsWith('001')){
                    accountIdSet.add(newEvent.WhatId);
                }
                
                
            }
            if(newEvent.whoId!=null){
                String whoId = newEvent.whoId;
                /*if(newEvent.Subject.containsIgnoreCase('Calendly') && whoId.startsWith('00Q')){
                    leadIdSet.add(newEvent.whoId);
                }*/ // Calendly is no longer used hence commenting
                if(newEvent.Subject.containsIgnoreCase(Label.Property_Submission_Event)){
                    if(whoId.startsWith('00Q')){
                    leadIdSet.add(newEvent.whoId);
                    }
                    if(whoId.startsWith('003')){
                    contactIdSet.add(newEvent.whoId);
                    }
                }
            }
        }
       
        if(accountIdSet.size()>0){
            List<Account> matchingAccountList = [select Id,Meeting_Booked__c from Account where Id IN:accountIdSet];
            if(!matchingAccountList.isEmpty()){
                for(Account acc : matchingAccountList){
                    acc.Meeting_Booked__c = true;
                    accountList.add(acc);
                }
            }
            if(!accountList.isEmpty()){
                update accountList;
            }
        }
        if(leadIdSet.size()>0){
            List<Lead> matchingLeadList = [select Id,Meeting_Booked__c, SSS_Appointment_Booked__c from Lead where Id IN:leadIdSet];
            if(!matchingLeadList.isEmpty()){
                for(Lead ld : matchingLeadList){
                    //ld.Meeting_Booked__c = true;  // Commenting for Calendly
                    ld.SSS_Appointment_Booked__c = true;
                    leadList.add(ld);
                }
                
            }
            if(!leadList.isEmpty()){
                update leadList;
            }
        }
        System.debug('contactIdSet::'+contactIdSet);
        if(contactIdSet.size() > 0){
            for(Contact con : [Select Id, AccountId, Account.SSS_Appointment_Booked__c from Contact where Id IN : contactIdSet]){
                Account acc = new Account(Id = con.AccountId,SSS_Appointment_Booked__c = true);
                accountList.add(acc);
            
            }
            System.debug('accountList::'+accountList);
            if(accountList.size() > 0){
                update accountList;
            }
        }
    }
}
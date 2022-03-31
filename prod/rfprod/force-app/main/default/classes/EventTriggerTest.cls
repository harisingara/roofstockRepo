@isTest
public class EventTriggerTest {
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void appointmentCreated() {
        Lead newLead = new Lead();
        newLead.lastName = 'Salesforce';
        newLead.Company = 'Salesforce';
        insert newLead;
        
        Event evt = new Event();
        evt.subject = 'Roofstock Calendly' + Label.Property_Submission_Event;
        evt.DurationInMinutes = 100;
        evt.ActivityDateTime =datetime.now();
        evt.whoId = newLead.Id;
        insert evt;
        
    }
    static testMethod void meetingBooked() {
        Account acc = new Account();
        acc.Name = 'Salesforce';
        insert acc;
        
        Lead newLead = new Lead();
        newLead.lastName = 'Salesforce';
        newLead.Company = 'Salesforce';
        insert newLead;
        
        Event evt = new Event();
        evt.subject = 'Roofstock Calendly' +Label.Property_Submission_Event;
        evt.DurationInMinutes = 100;
        evt.ActivityDateTime =datetime.now();
        //evt.whoId = newLead.Id;
        evt.WhatId = acc.Id;
        insert evt;
    }
    static testMethod void meetingBookedUpdate() {
        Account acc = new Account();
        acc.Name = 'Salesforce';
        insert acc;
        
        Lead newLead = new Lead();
        newLead.lastName = 'Salesforce';
        newLead.Company = 'Salesforce';
        insert newLead;
        
        Event evt = new Event();
        evt.subject = Label.Property_Submission_Event ; //'Roofstock Calendly';
        evt.DurationInMinutes = 100;
        evt.ActivityDateTime =datetime.now();
        //evt.whoId = newLead.Id;
        evt.WhatId = acc.Id;
        insert evt;
        
        Event evnt = [select Id from Event where Id=:evt.Id];
        update evnt;
    }
    static testMethod void meetingBookedDelete() {
        Account acc = new Account();
        acc.Name = 'Salesforce';
        insert acc;
        
        Lead newLead = new Lead();
        newLead.lastName = 'Salesforce';
        newLead.Company = 'Salesforce';
        insert newLead;
        
        Event evt = new Event();
        evt.subject = 'Roofstock Calendly';
        evt.DurationInMinutes = 100;
        evt.ActivityDateTime =datetime.now();
        //evt.whoId = newLead.Id;
        evt.WhatId = acc.Id;
        insert evt;
        
        Event evnt = [select Id from Event where Id=:evt.Id];
        delete evnt;
    }
    
    static testMethod void EventControllerException() {
        TriggerDispatcher.forceException = true;
        try{

            Event evt = new Event();
            evt.subject = 'Roofstock Calendly' +Label.Property_Submission_Event;
            evt.DurationInMinutes = 100;
            evt.ActivityDateTime =datetime.now();
            insert evt;
        }
        catch(Exception ex){
            //System.debug('=='+evt.Id);
        }
        
        
    }
}
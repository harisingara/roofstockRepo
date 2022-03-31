// may 27 1am

public class ORUActivityHelper {
   // private static boolean run = true;
    //Check for Recursive
  /*  public static boolean runOnce() {
        if (run) {
            run = false;
            return true;
        } else {
            return run;
        }
    }
*/
    public static void processLeasingActivities(List < Opportunity_Rental_Unit_Activity__c > activities) {
        //activity code priorities in case there is a conflict
        Map < String, Integer > conflictActivityPriority = new Map < String, Integer > {
            'self_registered_scheduling' => 1, //scheduled for viewing
            'self_registered_viewing' => 5,  //viewed!
            'prospect_canceled' => 10,
            'application_started' => 20,
            'application_applied' => 30,
            'application_approved' => 40,
            'application_canceled' => 50,
            'application_denied' => 60,
            'application_transfer' => 70,
            'lease_signed' => 80
        };

        // List<Opportunity_Rental_Unit_Activity__c> activities = Trigger.New;

        //if (Trigger.isAfter) {

            //After Update
            //if (Trigger.isUpdate || Trigger.isInsert) {
                //if (ORUActivityHelper.runOnce()) {
                    Map < id, Opportunity_Rental_Unit_Activity__c > timestamps = new Map < id, Opportunity_Rental_Unit_Activity__c > ();
                    Set < Id > oruids = new Set < Id > ();
                    System.debug(LoggingLevel.ERROR, '****// ORUA activities ** ' + activities);

                    for (Opportunity_Rental_Unit_Activity__c activity: activities) {
                        oruids.add(activity.Opportunity_Rental_Unit__c);
                    }
                    System.debug(LoggingLevel.ERROR, '****// ORUA ids ** ' + oruids);

                    //get the recent activity froexisting activities
                    List < Opportunity_Rental_Unit_Activity__c > existingActivities = [
                        SELECT
                        id,
                        Activity_Code__c,
                        Activity_Name__c,
                        Opportunity_Rental_Unit__c,
                        Timestamp__c
                        FROM Opportunity_Rental_Unit_Activity__c
                        WHERE
                        Opportunity_Rental_Unit__r.id IN: oruids
                        AND Activity_Code__c NOT IN('controlled_showing', 'agent_assign')
                    ];
                    System.debug(LoggingLevel.ERROR, '****// ORUA processing ** ' + existingActivities.size() + existingActivities);

                    for (Opportunity_Rental_Unit_Activity__c activity: existingActivities) {
                        
                        if (!timestamps.containsKey(activity.Opportunity_Rental_Unit__c)) {
                            timestamps.put(activity.Opportunity_Rental_Unit__c, activity);
                        } 
                        else {
                            String lastActivityCode = timestamps.get(activity.Opportunity_Rental_Unit__c).Activity_Code__c;
                            Integer currentActivityPriority = conflictActivityPriority.containsKey(activity.Activity_Code__c) ? conflictActivityPriority.get(activity.Activity_Code__c) : 0;
                            Integer lastActivityPriority = conflictActivityPriority.containsKey(lastActivityCode) ? conflictActivityPriority.get(lastActivityCode) : 0;
                            if (currentActivityPriority > lastActivityPriority) {
                                timestamps.put(activity.Opportunity_Rental_Unit__c, activity);
                            }
                        }
                    } //for


                    //controlled_showing et agent_assign happens after lease_signing
                    //get the recent activity from incoming
                    for (Opportunity_Rental_Unit_Activity__c activity: activities) {
                        if (
                            activity.Activity_Code__c != 'controlled_showing' &&
                            activity.Activity_Code__c != 'agent_assign'
                        ) {
                            if (!timestamps.containsKey(activity.Opportunity_Rental_Unit__c)) {
                                timestamps.put(activity.Opportunity_Rental_Unit__c, activity);
                            } else {
                                String lastActivityCode = timestamps.get(activity.Opportunity_Rental_Unit__c).Activity_Code__c;    
                                Integer currentActivityPriority = conflictActivityPriority.containsKey(activity.Activity_Code__c) ? conflictActivityPriority.get(activity.Activity_Code__c) : 0;
                                Integer lastActivityPriority = conflictActivityPriority.containsKey(lastActivityCode) ? conflictActivityPriority.get(lastActivityCode) : 0;

                                    //handle edge case of recieving 2 activities with exact same timestamp, decide bsed on activity code!
                                    if (currentActivityPriority > lastActivityPriority) {
                                        timestamps.put(activity.Opportunity_Rental_Unit__c, activity);
                                    // }
                                    } else { //lower timestamp, dont update ORU
                                        System.debug(LoggingLevel.ERROR, '****// ORUA skipping lower date ' + activity.Timestamp__c);
                                } //if
                            } //if
                        }
                    } //for

                    List < OpportunityRentalUnit__c > orusToUpdate = [
                        SELECT id, status__c, Primary_Leasing_Contact__c, opportunity__r.Primary_Leasing_Contact__c
                        FROM OpportunityRentalUnit__c
                        WHERE id IN: oruids
                    ];

                    Map<id,string> existingORUStatusMap = new Map<id,string>();
                    Map<id,OpportunityRentalUnit__c> existingORUMap = new Map<id,OpportunityRentalUnit__c>();

                    for (OpportunityRentalUnit__c oru: orusToUpdate) {
                        existingORUStatusMap.put(oru.id, oru.status__c);
                        existingORUMap.put(oru.id, oru);

                    }

                    System.debug(LoggingLevel.ERROR, '****// ORU to update ** ' + orusToUpdate.size() + orusToUpdate);

                    //update ORU from the recent list!
                    List < Opportunity_Rental_Unit_Activity__c > updateList = timestamps.values();
                    List < OpportunityRentalUnit__c > updateORUList = new List < OpportunityRentalUnit__c > ();
                    for (Opportunity_Rental_Unit_Activity__c activity: updateList) {
                        string newStatus;
                        string transferredTo;
                        switch on activity.Activity_Code__c {
                            when 'self_registered_scheduling' {
                                newStatus = 'Scheduled Viewing';
                            }
                            when 'self_registered_viewing' {
                                newStatus = 'Viewed';
                            }
                            when 'application_started' {
                                newStatus = 'Application Started';
                            }
                            when 'application_applied' {
                                newStatus = 'Applied';
                            }
                            when 'application_approved' {
                                newStatus = 'Approved';
                            }
                            when 'application_canceled' {
                                newStatus = 'Cancelled';
                            }
                            when 'prospect_canceled' {
                                newStatus = 'Cancelled';
                            }
                            when 'application_denied' {
                                newStatus = 'Denied';
                            }
                            when 'application_transfer' {
                                newStatus = 'Transferred';
                            }
                            when 'lease_signed' {
                                newStatus = 'Lease Signed';
                            }
                            when
                            else {
                                newStatus = 'Unknown';
                            }
                        }
                        System.debug(LoggingLevel.ERROR, '****// ORUA processing item ' + activity + newStatus);

                        if (newStatus != 'Unknown') {
                            string existingORUStatus = existingORUStatusMap.get(activity.Opportunity_Rental_Unit__c);
                            //check if the new status can override  the existing oru status
                            if(ORUActivityHelper.getORUStatusPriority(newStatus) >= ORUActivityHelper.getORUStatusPriority(existingORUStatus)) {
                                OpportunityRentalUnit__c oru = new OpportunityRentalUnit__c();
                                oru.id = activity.Opportunity_Rental_Unit__c;
                                oru.status__c = newStatus;
                                //populate primary contact if it is empty! this is required for emails 
                                //new oru;s will have it populated on creation, this is to handle existing orus that may not have primary contact
                                OpportunityRentalUnit__c existingORU = existingORUMap.get(activity.Opportunity_Rental_Unit__c);
                                if(String.isBlank(existingORU.Primary_Leasing_Contact__c)){
                                    oru.Primary_Leasing_Contact__c = existingORU.opportunity__r.Primary_Leasing_Contact__c;
                                }

                                updateORUList.add(oru);
                            } 
                          
                        }
                    } //loop
                    System.debug(LoggingLevel.ERROR, '****// ORUA updates ' + updateORUList);

                    if (updateORUList.size() > 0) {
                        update updateORUList;
                    }
                //}
           // }
       // }
    } //func

    private static Integer getORUStatusPriority(string status) {
        Map < String, Integer > oruStatusPriority = new Map < String, Integer > {
            'Scheduled Viewing' => 1, //viewed!
            'Viewed' => 10, 
            'Application Started' => 20,
            'Applied' => 30,
            'Approved' => 40,
            'Cancelled' => 50,
            'Denied' => 60,
            'Transferred' => 70,
            'Lease Signed' => 80
        };
        integer priority = 0;  //defualt priority for non critical activites
    
        if (oruStatusPriority.containsKey(status)) {
                priority = oruStatusPriority.get(status);
        }
        return priority;
    }
/*
    public static void createTask(List<Opportunity_Rental_Unit_Activity__c> newORUActivities){
        Map<String,String> oruaMap = new Map<String,String>(); 
        Map<String,String> oruNameMap = new Map<String,String>();
        for(Opportunity_Rental_Unit_Activity__c orua : newORUActivities){
            if(orua.Activity_Code__c == 'controlled_showing' || orua.Activity_Code__c == 'self_registered_viewing'){
                oruaMap.put(orua.Id,orua.Opportunity_Rental_Unit__c);
            }
        }
        Map<String,String> oruIdNameMap = new Map<String,String>();
        Map<String,String> oruIdOpportunityMap = new Map<String,String>();
        Map<String,String> oruIdOpportunityPrimaryLeasingContactMap = new Map<String,String>();
        List<OpportunityRentalUnit__c> oruList = [select Id,Name,Opportunity__c,Opportunity__r.Primary_Leasing_Contact__c from OpportunityRentalUnit__c where Id IN:oruaMap.values()];
        for(OpportunityRentalUnit__c oru : oruList){
            oruIdNameMap.put(oru.Id,oru.Name);
            oruIdOpportunityMap.put(oru.Id,oru.Opportunity__c);
            oruIdOpportunityPrimaryLeasingContactMap.put(oru.Id,oru.Opportunity__r.Primary_Leasing_Contact__c);
        }
        
        List<Task> createTaskList = new List<Task>();
        for(Opportunity_Rental_Unit_Activity__c orua : newORUActivities){
            if(orua.Activity_Code__c == 'controlled_showing' || orua.Activity_Code__c == 'self_registered_viewing'){
                Task t = new Task();
                String feedback='';
                if(orua.Feedback__c!=null){
                	feedback = orua.Feedback__c;
                }
                t.Description = oruIdNameMap.get(oruaMap.get(orua.Id))+':'+feedback;
                t.IsReminderSet = false;
                t.OwnerId = '0051C000009jRig';
                t.Priority = 'Select One';
                t.ReminderDateTime = datetime.now();
                t.Status = 'New';
                t.Subject = 'Viewing';
                t.whatId =  oruIdOpportunityMap.get(oruaMap.get(orua.Id));
                t.WhoId = oruIdOpportunityPrimaryLeasingContactMap.get(oruaMap.get(orua.Id));
                createTaskList.add(t);
                System.debug('=tid='+t);
            }
        }
        if(createTaskList.size()>0){
            insert createTaskList;
            System.debug('=createTaskList='+createTaskList);
        }
    }*/
    
}
public class OpportunityRoundRobin {
    
    public static List<Opportunity> roundRobin(List<Opportunity> newList)
    {
        //Find active Assignment Group for Queue    	
    	Map<Integer,Id> asgnGroupNameIds = new Map<Integer,Id>();   //Trigger index --> Assignment_Group_Name ID
    	Map<Id,Assignment_Group_Queues__c> asgnGroupQueues = new Map<Id,Assignment_Group_Queues__c>(); //Queue ID --> Assignment Group Queues
    	
        List<Opportunity> errorList = new List<Opportunity>();
    	Integer j = 0;
        //Map --> List/Array for DML update
        Map<Id,Assignment_Groups__c[]> asgnGroups = new Map<Id,Assignment_Groups__c[]>(); // Assignment Group Name ID --> User ID
    	
        Map<Id,Assignment_Groups__c> updateAssignmentGroups = new Map<Id,Assignment_Groups__c>();
        
    	
    	Map<Id, datetime> latestAGDateTime = new Map<Id,datetime>();
    	integer idx = 0; 
        List<Assignment_Groups__c> updateAG = new List<Assignment_Groups__c>();
        
        Assignment_Group_Queues__c agq = [SELECT Assignment_Group_Name__c, QueueId__c FROM Assignment_Group_Queues__c WHERE Name =: 'LC Team'AND Active__c = 'True' limit 1];
        if(agq == null){
            return errorList;    
        }
        else{
           asgnGroupQueues.put(agq.QueueId__c, agq); 
           asgnGroupNameIds.put(j, agq.Assignment_Group_Name__c);
        }
    	
    	System.debug('>>>>>asgnGroupNameIds: '+asgnGroupNameIds);
    	if (asgnGroupNameIds.isEmpty()) return errorList;
    

        //Determine next valid user in Queue/Assignment Group for round robin
    	//User with earliest last assignment date wins.
    	
        Assignment_Groups__c[] ags = [SELECT Group_Name__c, User__c, Last_Assignment__c, Millisecond__c 
                                   		FROM Assignment_Groups__c 
                                   		WHERE Group_Name__c in :asgnGroupNameIds.values() 
                                   		AND Active__c = 'True' AND User_Active__c = 'True'
                                   		ORDER BY Last_Assignment__c, Millisecond__c];   
            
    	System.debug('>>>>>asgnGroups: '+ags);   
    	if (ags.isEmpty()) return errorList;

    	   
    	
        for(Integer i =0; i < newList.size(); i++)
    	{       	
        	if (ags != null && ags.size()>0)
        	{   
            	//Choose next user in line if user ID has already been used but not committed in this trigger batch 
            	Assignment_Groups__c ag = ags[math.mod(idx, ags.size())];
                
            	//Assign User to Account as the new owner
            	newList[i].OwnerId = ag.User__c;                
            	datetime now = datetime.now();
            	ag.Last_Assignment__c = now;
            	ag.Millisecond__c = now.millisecondGMT();
            
            	//update only latest Assignment Groups per ID
            	if (latestAGDateTime.containsKey(ag.id)) {
                	if(latestAGDateTime.get(ag.id) < now) {
                    	updateAssignmentGroups.put(ag.id, ag);
                    	latestAGDateTime.put(ag.id, now);
                	}
            	} else {
                	updateAssignmentGroups.put(ag.id, ag);
                	latestAGDateTime.put(ag.id,now);
            	}
            
            	idx++;
        	}
    	}
    	
    	for (Id agId : updateAssignmentGroups.keySet()) {
        	updateAG.add(updateAssignmentGroups.get(agId));
    	}
    	System.debug('>>>>>Update Assignment Groups: '+updateAG);   
    
    	//
    	//Update last assignment for Assignment Group in batch
    	//
    	if (updateAG.size()>0) {
        	try {
            	update updateAG;
        	} catch (Exception e) {
            	for (Integer i =0; i < newList.size() -1 ; i++)
            	{
                	//Trigger.new[i].addError('ERROR: Could not update Assignment Group records ' + ' DETAIL: '+e.getMessage());  
                	errorList.add(newList[i]);
            	}
        	}
    	}
        return errorList;
    }
}
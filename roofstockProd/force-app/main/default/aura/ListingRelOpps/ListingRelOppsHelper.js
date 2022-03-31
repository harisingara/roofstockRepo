({
	fetchRelatedOpps : function(component, event, helper) {
        
        component.set("v.relRecsExist", false);
        var action = component.get("c.fetchRelatedOppsApex");
        var oppId = component.get("v.recordId");
        var baseUrl = 'https://' + location.host + '/';
        action.setParams({oppId : oppId});
        //alert(oppId);
        
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                //alert('Success');
                var oppRecords = response.getReturnValue();
                //alert(oppRecords.length);
                if(oppRecords.length >0){
                    oppRecords.forEach(function(record){
                        record.OppLink = baseUrl + record.Id;
                        record.approval = record.Ready_for_Approval__c;
                        //alert(record.Ready_for_Approval__c);
                        
                    });  
                    component.set("v.OppList", oppRecords);
                	component.set("v.relRecsExist", true);
                }
                
                //alert(component.get("v.OppList"));
            }
        });
        $A.enqueueAction(action);	
	}
})
({
	updateRead : function(cmp) {
        var action = cmp.get("c.updateRead");
        action.setParams({ emailId : cmp.get("v.dispemail.Id") });
        action.setCallback(this, function(response) {   
        });

        $A.enqueueAction(action);
	}
})
({
    init: function(cmp){
        var action = cmp.get("c.getTasks");
        action.setParams({
            "taskId": cmp.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.tasks", response.getReturnValue());
            }
        });
	 $A.enqueueAction(action);
    }
})
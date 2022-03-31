({
	doInit : function(component, event, helper) {

	},
    setSuccessMessage : function(component,event,helper){
        //alert('success');
        component.set("v.ApiCallSuccess",true);
    },
    closeModal : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        if(component.get("v.ApiCallSuccess")){
        location.reload(true);
        }
	/*		
        window.setTimeout(
        $A.getCallback(function() {
            if(component.isValid()){
                $A.get("e.force:closeQuickAction").fire();
            }
            else{
                console.log('Component is Invalid');
            }
        }), 3000
    );*/
		
	}
})
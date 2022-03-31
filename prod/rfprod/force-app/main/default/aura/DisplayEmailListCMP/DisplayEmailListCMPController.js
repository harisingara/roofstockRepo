({
	dispEmailDetails : function(component, event, helper) {
        var dispemail = component.get('v.dispemail');
		component.set('v.email',dispemail);
        component.set('v.isRead',true);
        // Read - Email Status
        if(dispemail.ortoo_e2a__Status__c === 'New' || dispemail.ortoo_e2a__Status__c === 'Unread'){
        	dispemail.ortoo_e2a__Status__c = 'Read';    
            component.set('v.dispemail',dispemail);
            var selectedSubject = component.get('v.selectedSubject'); 
            selectedSubject.unReadCnt = selectedSubject.unReadCnt-1; 
            component.set('v.selectedSubject',selectedSubject);  
            // call server method 
            helper.updateRead(component);
        }
        
        
	}
})
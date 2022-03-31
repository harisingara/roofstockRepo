({
	fetchRelatedOpps : function(component, event, helper) {
        component.set('v.mycolumns', [
            
            {label: 'Opportunity', fieldName: 'OppLink', type: "url", 
             typeAttributes: {
                 label: {
                     fieldName: 'Name'
                 },
                 target: '_blank'
             }},
            {label: 'Stage', fieldName: 'StageName', type: 'text'},
            {label: 'Sub-Stage', fieldName: 'Sub_Stage__c', type: 'text'},
            {label: 'Ready For Approval', fieldName: 'Ready_for_Approval__c', type: 'boolean'},
            //{label: 'Ready For Approval', fieldName: 'approval', type: 'boolean'},
            {label: 'Ready For Approval Checked Date', fieldName: 'Ready_For_Approval_Checked_Date1__c', type: 'datetime'}
        ]);
		helper.fetchRelatedOpps(component, event, helper);
		
	}
})
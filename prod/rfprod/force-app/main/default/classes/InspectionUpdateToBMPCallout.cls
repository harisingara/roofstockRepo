public with sharing class InspectionUpdateToBMPCallout {

    public class InspectionBPMWrapper {
        public String bpmInspectionId;
        public String status;
        public String dueDiligenceNotes;
        public Decimal estimatedFoundationCost;
        public Decimal estimatedGcCost;
        public Decimal estimatedHvacCost;
        public Decimal estimatedPlumbingCost;
        public Decimal estimatedPoolCost;
        public Decimal estimatedRoofingCost;
        public Decimal totalEstimatedRenovationCost;
        public Decimal totalRenovationFee;
        public String inspectionCompletedDate;
        public String inspectionType;
    }
    
    // Set the API token, production:
	public static final String DELIGHTED_API_KEY = System.Label.BPMUPDATEINSPECTION_KEY;
    
    // Set endpoint URL
    public static final String BPMUPDATEINSPECTION_ENDPOINT = System.Label.BPMUPDATEINSPECTION_ENDPOINT;
    
    // We use this for test class purposes
    public static HTTPResponse global_res;
    
    // This prevents recursion
    public static Set<Id> alreadyProcessed = new Set<Id>();
    
    @future(callout=true)
    public static void updateBMPCallout(Set<Id> inspectionsIds) {	
        
        // Initialize the HTTP request (API call)
		HttpRequest req = new HttpRequest();

		// Create a new http object to send the request object
		Http http = new Http();

		// A response object is generated as a result of the request
		HTTPResponse res;

        try {
            List<inspectionBPMWrapper> inspectionList = new List<inspectionBPMWrapper>();
            InspectionBPMWrapper insbmpw;
            for(Inspection__c inspections : [SELECT Id, Dilligence_Id__c, Inspection_Status__c, Due_Diligence_Notes__c, Estimated_Foundation_Cost__c, 
                                                    Estimated_GC_Cost__c, Estimated_HVAC_Cost__c, Estimated_Plumbing_Cost__c, Estimated_Pool_Cost__c, 
                                                    Estimated_Roofing_Cost__c, Total_Job_Fee__c, Total_Job_Cost_with_Fee__c, Total_Estimated_Renovation_Cost__c,
                                                    Inspection_Type__c, Inspection_Completed_Date__c
                                            FROM Inspection__c 
                                            WHERE Id IN :inspectionsIds]) {
                insbmpw = new InspectionBPMWrapper();
                insbmpw.bpmInspectionId = inspections.Dilligence_Id__c;
                insbmpw.status = inspections.Inspection_Status__c;
                insbmpw.dueDiligenceNotes = inspections.Due_Diligence_Notes__c;
                insbmpw.estimatedFoundationCost = inspections.Estimated_Foundation_Cost__c;
                insbmpw.estimatedGCCost = inspections.Estimated_GC_Cost__c;
                insbmpw.estimatedHVACCost = inspections.Estimated_HVAC_Cost__c;
                insbmpw.estimatedPlumbingCost = inspections.Estimated_Plumbing_Cost__c;
                insbmpw.estimatedPoolCost = inspections.Estimated_Pool_Cost__c;
                insbmpw.estimatedRoofingCost = inspections.Estimated_Roofing_Cost__c;
                insbmpw.totalEstimatedRenovationCost = inspections.Total_Estimated_Renovation_Cost__c;
                insbmpw.totalRenovationFee = inspections.Total_Job_Fee__c;
                insbmpw.inspectionCompletedDate = String.ValueOf(inspections.Inspection_Completed_Date__c);
                insbmpw.inspectionType = inspections.Inspection_Type__c;
                inspectionList.add(insbmpw);
            }
            
            if (inspectionList.size() > 0) {           
                // Set API endpoint and method
                req.setMethod('POST'); 
                req.setHeader('Content-Type', 'application/json');

                req.setEndpoint('callout:BPMUPDATEINSPECTION');
                req.setHeader('Api-Key', '{!$Credential.Password}');
                //req.setHeader('Api-Key', 'kjfdbndfkjbfdkjb');
                req.setTimeout(120000);
                // Set the body of the request
                System.debug(LoggingLevel.ERROR, 'updateBMPCallout() callout response: ' + '{"inspectionList":' + JSON.serialize(inspectionList) + '}');
                req.setBody('{"inspectionList":' + JSON.serialize(inspectionList) + '}');

                res = http.send(req); 
                
                System.debug(LoggingLevel.ERROR, 'updateBMPCallout() callout response: ' + res.getBody());
                DebugLogHandler.logOutBoundResponse('InspectionUpdateToBMPCallout', 'updateBMPCallout', '', req.getBody(), res.getBody());
                // Store this to use for test class
                /*if(res.getStatusCode() <> 200) {
                    System.debug(LoggingLevel.ERROR, 'updateBMPCallout() error - failure: ' + res.getBody());
                    
                    DebugLog__c dl = new DebugLog__c(Class_Name__c='InspectionUpdateToBMPCallout', Error_Description__c=res.getBody(), Retry_Status__c='Retry - Pending',
                                                    HTTP_Endpoint__c='callout:BPMUPDATEINSPECTION', ApiKeyLabel__c='Api-Key', ApiKeyValue__c='{!$Credential.Password}',
                                                    Named_Credentials__c='BPMUPDATEINSPECTION', Origin__c='Http Callout', Method_Name__c='updateBMPCallout',
                                                    HTTP_Method__c='POST', HTTP_Status_Code__c=res.getStatusCode(), Request__c=req.getBody(), Log_Type__c='Retry'
                                                    );
                    Insert dl;
                } */   
                if(res.getStatusCode() != 200) {
                    Outbound_Message_Request__c omr = OutboundMessageRequestHelper.logOutboundRetryRequest(req,'Inspection Update');
                    omr.Status__c = 'Retry - Pending';
                    omr.Generate_New_Auth_Token__c = false;
                    omr.HTTP_Status_Code__c = res.getStatusCode();
                    omr.Named_Credential__c = 'BPMUPDATEINSPECTION';
                    omr.NC_PassLabel__c = 'Api-Key';
                    omr.Class_Name__c = 'RESTInspectionController';
                    omr.Method_Name__c = 'UpsertInspection';
                    insert omr;
                }
            }
        } catch(Exception exe){
            // DebugLogHandler.logRestServiceException('RESTInspectionController','UpsertInspection',exe.getMessage(),
            //                                     exe.getStackTraceString(),req.getBody());
            Outbound_Message_Request__c omr = OutboundMessageRequestHelper.logOutboundRetryRequest(req,'Inspection Update');
            omr.Status__c = 'Retry - Pending';
            omr.Generate_New_Auth_Token__c = false;
            omr.Named_Credential__c = 'BPMUPDATEINSPECTION';
            omr.NC_PassLabel__c = 'Api-Key';
            omr.Error_Description__c = exe.getMessage();
            omr.Class_Name__c = 'RESTInspectionController';
            omr.Method_Name__c = 'UpsertInspection';
            insert omr;
        }
    }
}
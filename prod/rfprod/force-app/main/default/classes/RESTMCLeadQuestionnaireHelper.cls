global class RESTMCLeadQuestionnaireHelper {
    global class LeadsWrap{
        global List<Questionnaire> QuestionnaireList;
    }
    global class Questionnaire{
        global String Email;
        global String investingExperience;
        global boolean isAccreditedInvestor;
        global String investmentGoal;
        global String targetInvestmentDeployment;
        global String timeframe;      
        global Integer numberOfPropertiesOwned;
        global boolean okayWithAPoorNeighborhoodScore;
        global boolean okayWithANonInspectedProperty;
        global boolean okayWithMinorRepairWork;
        global boolean okayWithMajorRepairWork;
        //RC-11494
        global String preferredRegion;
        global String riskTolerance;
        global String investmentObjective;
    }
	global class ResponseBody{
        global String salesforceId;
        global ResponseBody(String salesforceId){
            this.salesforceId = salesforceId;
            
        }
    }
    global class ResponseWrapper {  
        global List<ResponseBody> QuestionnaireResponse;  
        global ResponseWrapper(){
            QuestionnaireResponse = new List<ResponseBody>();
        }
        global ResponseWrapper(List<ResponseBody> QuestionnaireResponse) {
            this.QuestionnaireResponse = QuestionnaireResponse;
        }
    } 
    global class PostResponse{
        global ResponseWrapper responseBody;
        global PostResponse(List<ResponseBody> QuestionnaireResponse){
            this.responseBody = new ResponseWrapper(QuestionnaireResponse);
        }
    }
    global static PostResponse updateQuestionnaire(List<Questionnaire> QuestionnaireList) {
        System.debug('=QuestionnaireList='+QuestionnaireList);
        List<ResponseBody> leadResponseList = new List<ResponseBody>();
        /*Read the input string to check existing lead*/
        Set<String> emailSet = new Set<String>();
        Map<String,Lead> emailLeadMap = new Map<String,Lead>();
        for(Questionnaire quest : QuestionnaireList){
        	emailSet.add(quest.Email);    
        }
       
        List<Lead> existingLeads = [select Id,Email,Investing_Experience__c,Accredited_Investor__c,Investment_Goal__c,
                                    How_much_are_you_looking_to_invest__c,
                                    Buyer_Timeframe__c,
                                    Number_of_Properties_Owned__c,Okay_With_A_Poor_Neighborhood_Score__c,
                                    Okay_With_A_Non_Inspected_Property__c,Okay_With_Major_Repair_Work__c,Okay_With_Minor_Repair_Work__c,
									Risk_Tolerance__c,investment_Objectives__c,Preferred_Region__c                                   
                                    from Lead where Email IN:emailSet];
        System.debug('=existingLeads='+existingLeads);
        for(Lead existingLead :existingLeads){
        	emailLeadMap.put(existingLead.Email.toLowercase(),existingLead);	    
        }
        System.debug('=emailLeadMap='+emailLeadMap);
        /*Read the input string to update existing lead*/
        List<Lead> updateLeadList = new List<Lead>();
        Lead ExistingLead;
        for(Questionnaire inputQuest : QuestionnaireList){
            if(emailLeadMap.containskey(inputQuest.Email.toLowercase())){
                ExistingLead = emailLeadMap.get(inputQuest.Email.toLowercase());
                System.debug('-ExistingLead-'+ExistingLead);
                if(inputQuest.investingExperience != null){
                   ExistingLead.Investing_Experience__c = inputQuest.investingExperience; 
                }
                if(inputQuest.isAccreditedInvestor != null){
                   ExistingLead.Accredited_Investor__c = inputQuest.isAccreditedInvestor; 
                }
                if(inputQuest.investmentGoal != null){
                   ExistingLead.Investment_Goal__c = inputQuest.investmentGoal; 
                }
                if(inputQuest.targetInvestmentDeployment != null){
                   ExistingLead.How_much_are_you_looking_to_invest__c = inputQuest.targetInvestmentDeployment; 
                }
                
                if(inputQuest.timeframe != null){
                   ExistingLead.Buyer_Timeframe__c = inputQuest.timeframe; 
                }
                
                if(inputQuest.numberOfPropertiesOwned != null){
                   ExistingLead.Number_of_Properties_Owned__c = inputQuest.numberOfPropertiesOwned; 
                }
                if(inputQuest.okayWithMajorRepairWork != null){
                    if(inputQuest.okayWithMajorRepairWork == true){
						ExistingLead.Okay_With_Major_Repair_Work__c = 'Yes';                    
                    }
                    else{
                        ExistingLead.Okay_With_Major_Repair_Work__c = 'No';
                    }
                }
                if(inputQuest.okayWithMinorRepairWork != null){
                    if(inputQuest.okayWithMinorRepairWork == true){
						ExistingLead.Okay_With_Minor_Repair_Work__c = 'Yes';                    
                    }
                    else{
                        ExistingLead.Okay_With_Minor_Repair_Work__c = 'No';
                    }
                }
                if(inputQuest.okayWithAPoorNeighborhoodScore != null){
                    if(inputQuest.okayWithAPoorNeighborhoodScore == true){
						ExistingLead.Okay_With_A_Poor_Neighborhood_Score__c = 'Yes';                    
                    }
                    else{
                        ExistingLead.Okay_With_A_Poor_Neighborhood_Score__c = 'No';
                    }
                }
                if(inputQuest.okayWithANonInspectedProperty != null){
                    if(inputQuest.okayWithANonInspectedProperty == true){
						ExistingLead.Okay_With_A_Non_Inspected_Property__c = 'Yes';                    
                    }
                    else{
                        ExistingLead.Okay_With_A_Non_Inspected_Property__c = 'No';
                    }
                }
                if(inputQuest.preferredRegion != null){
                   ExistingLead.Preferred_Region__c = inputQuest.preferredRegion; 
                }
                if(inputQuest.riskTolerance != null){
                   ExistingLead.Risk_Tolerance__c = inputQuest.riskTolerance; 
                }
                if(inputQuest.investmentObjective != null){
                   ExistingLead.investment_Objectives__c = inputQuest.investmentObjective; 
                }
                
                
				updateLeadList.add(ExistingLead);
            } 
            
        }
        
        System.debug('=updateLeadList1='+updateLeadList);
        if(updateLeadList.size()>0){
            update updateLeadList;
        }
        
        System.debug('=updateLeadList2='+updateLeadList);
        for(Lead matchingLead:updateLeadList){
            System.debug('=matchingLead='+matchingLead.Id);
            leadResponseList.add(new ResponseBody(matchingLead.Id));     
        }
        System.debug('=leadResponseList='+leadResponseList);
        postResponse res = new postResponse(leadResponseList);
        return res;
    }

}
Public Class RecordTypes {
    // Get the Record Type Ids of various Sobject Record Types
    Public Static Id leasingAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Leasing').getRecordTypeId();
    Public Static Id leasingContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Leasing').getRecordTypeId();
    Public Static Id leasingOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Leasing').getRecordTypeId();
    Public Static Id leasingSecApplOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Leasing_Secondary_Applicant').getRecordTypeId();
    Public Static Id leasingLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Leasing').getRecordTypeId();

}
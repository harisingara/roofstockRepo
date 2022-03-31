@isTest
private class EmailPublisherForTransactionCasesTest {
    static Case myCase {get;set;}
    static EmailMessage myMsg {get;set;}
    
    static testmethod void EmailPublisherLoader_NoReplyToId_Transaction() {
        
        
        Exception failureDuringExecution = null;
        init_Transaction();
        
        //create QuickActionDefaults
        List<Map<String, Object>> defaultSettingAsObject = new List<Map<String, Object>>
        {
            new Map<String, Object>
            {
                'targetSObject' => new EmailMessage(),
                    'contextId' => myCase.Id,
                    'ToAddress' => myMsg.ToAddress,
                    'CCAddress' => myMsg.CcAddress,
                    'actionType' => 'Email',
                    'actionName' => 'Case.CC_Send_Email',
                    'fromAddressList' => new List<String> { 'salesforce@test.com' }
            }
        };
            
            List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = 
            (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsObject), List<QuickAction.SendEmailQuickActionDefaults>.class);
        
        Test.startTest();
        (new EmailPublisherForTransactionCases()).onInitDefaults(defaultsSettings);
        System.debug('defaultsSettings after: ' + defaultsSettings);
        Test.stopTest();
        //System.assertEquals(null, defaultsSettings.QuickActionDefaults.targetSObject.ToAddress);  
    }
    
    static void init_Transaction(){
        Id RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        TestDataFactory.insertHierarchyCustomSettingData();
        myCase = 
            new Case(
                Status='Unassigned',
                Priority = 'Medium',
                Origin = 'Email',
                RecordTypeId = RecordTypeId
            );
        insert myCase;
        
        myMsg = 
            new EmailMessage(
                ToAddress = 'ToAddress@test.com',
                CCAddress = 'CCAddress@test.com',
                ParentId = myCase.Id
            );
        insert myMsg;
    }
    
    static testmethod void EmailPublisherLoader_NoReplyToId_Certification() {
        
        
        Exception failureDuringExecution = null;
        init_Certification();
        
        //create QuickActionDefaults
        List<Map<String, Object>> defaultSettingAsObject = new List<Map<String, Object>>
        {
            new Map<String, Object>
            {
                'targetSObject' => new EmailMessage(),
                    'contextId' => myCase.Id,
                    'ToAddress' => myMsg.ToAddress,
                    'CCAddress' => myMsg.CcAddress,
                    'actionType' => 'Email',
                    'actionName' => 'Case.CC_Send_Email',
                    'fromAddressList' => new List<String> { 'salesforce@test.com' }
            }
        };
            
            List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = 
            (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsObject), List<QuickAction.SendEmailQuickActionDefaults>.class);
        
        Test.startTest();
        (new EmailPublisherForTransactionCases()).onInitDefaults(defaultsSettings);
        System.debug('defaultsSettings after: ' + defaultsSettings);
        Test.stopTest();
        //System.assertEquals(null, defaultsSettings.QuickActionDefaults.targetSObject.ToAddress);  
    }
    
    static void init_Certification(){
        Id RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Certification').getRecordTypeId();
        TestDataFactory.insertHierarchyCustomSettingData();
        myCase = 
            new Case(
                Status='Unassigned',
                Priority = 'Medium',
                Origin = 'Email',
                RecordTypeId = RecordTypeId
            );
        insert myCase;
        
        myMsg = 
            new EmailMessage(
                ToAddress = 'ToAddress@test.com',
                CCAddress = 'CCAddress@test.com',
                ParentId = myCase.Id
            );
        insert myMsg;
    }
}
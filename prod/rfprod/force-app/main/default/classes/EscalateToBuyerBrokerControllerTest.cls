@isTest
public class EscalateToBuyerBrokerControllerTest {
    
    static{
        
        TestDataFactory.insertHierarchyCustomSettingData();
    }
    static testMethod void EscalateToBuyerBrokerController() {
        task tsk = new task();
        tsk.Subject = 'Ask a question';
        tsk.Status = 'Open';
        tsk.Description = 'Buyer Broker Email:chidanandsfdc@gmail.com';
        insert tsk;
        EscalateToBuyerBrokerController.escalateToBuyerBroker(tsk.Id);
        
    }
    static testMethod void EscalateToBuyerBrokerController2() {
        task tsk = new task();
        tsk.Subject = 'Ask a question';
        tsk.Status = 'Open';
        tsk.Description = 'Buyer Broker Email:';
        insert tsk;
        EscalateToBuyerBrokerController.escalateToBuyerBroker(tsk.Id);
        
    }
}
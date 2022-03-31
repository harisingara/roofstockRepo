@isTest
public class DebugLogHandlerTest {
	static testMethod void DebugLogHandlerlogTest() {
        
    	DebugLogHandler.logRestServiceException('sClassName', 'sMethodName',
     'sErrMsg','String sStackTrace', 'String sRequest' ); 
        DebugLogHandler.logInboundResponse('sClassName', 'sMethodName',
     'sErrMsg','String sStackTrace' ); 
        DebugLogHandler.logOutBoundResponse('String sClassName', 'String sMethodName',
     'String sStackTrace', 'String sRequest', 'String sResponse' );
        DebugLogHandler.logAppException('String sClassName', 'String sMethodName',
     'String sStackTrace',  'String sResponse' ,'Trigger ');
        List<Case> lstCase = new list<Case>();  
        lstCase.add(new case());  
        List<Database.SaveResult> saveResultList = Database.insert(lstCase, false);
        DebugLogHandler.logSaveResult('String sClassName', 'String sMethodName', 
                                       saveResultList );
    }
    
    static testMethod void DebugLogHandlerlogExceptionTest(){
        DebugLogHandler.platformEventException('sClassName', 'sMethodName', 'sStackTrace', 'sRequest', 'sResponse');
        DebugLogHandler.logOutBoundException('sClassName', 'sMethodName', 'sStackTrace', 'sErrMsg', 'sRequest', 'authenticationResponse', 'authorizationResponse');
    }
}
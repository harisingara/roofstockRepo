@isTest
public class CheckRecursiveTest {
    
    static testMethod void CaseHandlerTransactionTest() {
       /* checkRecursive cr = new checkRecursive();
        cr.RecurType obj = cr.RecurType.LEAD;
	*/
        test.starttest();
        checkRecursive.RecurType rt = checkRecursive.RecurType.LEAD;
        checkRecursive.runBeforeOnce(rt);
        checkRecursive.runAfterOnce(rt);
        checkRecursive.resetFlags();
        test.stoptest();
        
    }
}
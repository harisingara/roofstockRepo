@IsTest
private class CustomLookupLwcControllerTest{
    public CustomLookupLwcControllerTest(){
    }

    @IsTest
    static void testFetchLookupData(){
        List < sObject > returnList  = CustomLookupLwcController.fetchLookupData('', 'User', null, null);
        System.assertEquals(5, returnList.size());

        returnList  = CustomLookupLwcController.fetchLookupData('', 'User', 'Name', 'XYYZZ123');
        System.assertEquals(0, returnList.size());

    }

    @IsTest
    static void testFetchDefaultRecord(){
        sObject sObj  = CustomLookupLwcController.fetchDefaultRecord('1', 'Account', '', '');
        System.assertEquals(null, sObj);
    }

}
@IsTest
private class BusinessDaysTest{
    static DateTime today;
    static string bh; 

    static{
        today = DateTime.newInstance(2022, 3, 21, 00, 00, 00);
        bh = 'Default';
    }
  

    @IsTest
    static void testAddDays(){

        BusinessDays businessDays = new BusinessDays(bh);
        DateTime nextDay = DateTime.newInstance(2022, 3, 22, 00, 00, 00);
        System.assertEquals(nextDay, businessDays.addDays(today, 1));
    }

    @IsTest
    static void testSubstractDays(){
        BusinessDays businessDays = new BusinessDays();
        DateTime previousDay = DateTime.newInstance(2022, 3, 20, 00, 00, 00);
        System.assertEquals(previousDay, businessDays.subtractDays(today, 1));
    }
    @IsTest
    static void testSubstractDaysP(){
        BusinessDays businessDays = new BusinessDays(bh);
        DateTime previousDay = DateTime.newInstance(2022, 3, 20, 00, 00, 00);
        System.assertEquals(previousDay, businessDays.subtractDays(today, 1));
    }

    @IsTest
    static void testPreviousWorkingDay(){
        BusinessDays businessDays = new BusinessDays();
        System.assertEquals(today, businessDays.getPreviousWorkingDay(today));
    }

    @IsTest
    static void testNextWorkingDay(){

        BusinessDays businessDays = new BusinessDays();        
        System.assertEquals(today, businessDays.getNextWorkingDay(today));
    }

    @IsTest
    static void testIsWorkingDay(){
        BusinessDays businessDays = new BusinessDays();
        System.assertEquals(true, businessDays.isWorkingDay(today));
    }

    @IsTest
    static void testNoOfBusinessDaysBetweenDates(){
        BusinessDays businessDays = new BusinessDays();
        DateTime nextDay = DateTime.newInstance(2022, 3, 22, 00, 00, 00);
        System.assertEquals(2, businessDays.getNoOfBusinessDaysBetweenDates(today,nextDay));
    }
}
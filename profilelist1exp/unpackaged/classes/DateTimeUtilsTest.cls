@isTest
private class DateTimeUtilsTest {

    static testMethod void testConvertToDateTime() {
    	        
        Date dateValue = Date.newInstance(1947, 8, 15);
        Datetime resultDatetime = DateTimeUtils.convertToDateTime(dateValue);
    	System.assertEquals(Datetime.newInstance(1947, 8, 15, 0, 0, 0), resultDatetime);
    }
}
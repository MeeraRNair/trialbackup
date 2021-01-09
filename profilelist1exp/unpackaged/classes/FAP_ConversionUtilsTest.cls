@IsTest
private class FAP_ConversionUtilsTest {

    private static testmethod void testNullsParams(){
        System.assertEquals(0,FAP_ConversionUtils.convert(null,null,null));  
    }
    
    private static testmethod void testConvert(){
        assertEqualsRounded(100,FAP_ConversionUtils.convert(100,FAP_UnitOfLength.KILOMETERS,FAP_UnitOfLength.KILOMETERS),5);  
        assertEqualsRounded(100,FAP_ConversionUtils.convert(100,FAP_UnitOfLength.MILES,FAP_UnitOfLength.MILES),5);  
        assertEqualsRounded(100/FAP_ConversionUtils.KILOMETERS_IN_ONE_MILE,
            FAP_ConversionUtils.convert(100,FAP_UnitOfLength.KILOMETERS,FAP_UnitOfLength.MILES),5);  
        assertEqualsRounded(100*FAP_ConversionUtils.KILOMETERS_IN_ONE_MILE,
            FAP_ConversionUtils.convert(100,FAP_UnitOfLength.MILES,FAP_UnitOfLength.KILOMETERS),5);  
        System.assertEquals(160.9344,FAP_ConversionUtils.convert(100,FAP_UnitOfLength.MILES,FAP_UnitOfLength.KILOMETERS),5);  
    }
    
    private static void assertEqualsRounded(Double expected, Double actual, Integer decimalPlaces){
        System.assertEquals(round(expected,decimalPlaces),round(actual,decimalPlaces));
    }
    
    private static Double round(Double d, Integer decimalPlaces){
        if(decimalPlaces >= 0){
            d = Decimal.valueOf(d).setScale(decimalPlaces).doubleValue();
        }
        System.assertNotEquals(null, decimalPlaces);
        return d;
    }
    
}
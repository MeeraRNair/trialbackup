@IsTest
private class FAP_GeoSearchCriteriaTest {
    
    private static testmethod void testConversionsMilesToKilometers(){
        final FAP_GeoSearchCriteria criteria = new FAP_GeoSearchCriteria(new FAP_GeoPoint(0,0),100,FAP_UnitOfLength.MILES);
        System.assertNotEquals(null, criteria);
        criteria.toStr();
        assertEqualsRounded(100,criteria.distanceInMiles,5);  
        assertEqualsRounded(FAP_ConversionUtils.convert(100,FAP_UnitOfLength.MILES,FAP_UnitOfLength.KILOMETERS),criteria.distanceInKilometers,5);  
    }

    private static testmethod void testConversionsKilometersToMiles(){
        final FAP_GeoSearchCriteria criteria = new FAP_GeoSearchCriteria(new FAP_GeoPoint(0,0),100,FAP_UnitOfLength.KILOMETERS);
        System.assertNotEquals(null, criteria);
        assertEqualsRounded(100,criteria.distanceInKilometers,5);  
        assertEqualsRounded(FAP_ConversionUtils.convert(100,FAP_UnitOfLength.KILOMETERS,FAP_UnitOfLength.MILES),criteria.distanceInMiles,5);  
    }

    private static testmethod void testConstructorIllegalArgumentpoint(){
        Boolean exceptionCaught = false;
        try{
           new FAP_GeoSearchCriteria(null,1,FAP_UnitOfLength.MILES);  
        }catch(FAP_IllegalArgumentException e){
           exceptionCaught = true;
        }
        System.assert(exceptionCaught == true, 'IllegalArgumentException not thrown');
    }

    private static testmethod void testConstructorIllegalArgumentdistance1(){
        Boolean exceptionCaught = false;
        try{
           new FAP_GeoSearchCriteria(new FAP_GeoPoint(0,0),null,FAP_UnitOfLength.MILES);  
        }catch(FAP_IllegalArgumentException e){
           exceptionCaught = true;
        }
        System.assert(exceptionCaught == true, 'IllegalArgumentException not thrown');
    }

    private static testmethod void testConstructorIllegalArgumentdistance2(){
        Boolean exceptionCaught = false;
        try{
           new FAP_GeoSearchCriteria(new FAP_GeoPoint(0,0),0,FAP_UnitOfLength.MILES);  
        }catch(FAP_IllegalArgumentException e){
           exceptionCaught = true;
        }
        System.assert(exceptionCaught == true, 'IllegalArgumentException not thrown');
    }

    private static testmethod void testConstructorIllegalArgumentdistance3(){
        Boolean exceptionCaught = false;
        try{
           new FAP_GeoSearchCriteria(new FAP_GeoPoint(0,0),FAP_GeoSearchCriteria.MAX_DISTANCE_IN_MILES+1,FAP_UnitOfLength.MILES);  
        }catch(FAP_IllegalArgumentException e){
           exceptionCaught = true;
        }
        System.assert(exceptionCaught == true, 'IllegalArgumentException not thrown');
    }

    private static testmethod void testConstructorIllegalArgumentunitOfLength(){
        Boolean exceptionCaught = false;
        try{
           new FAP_GeoSearchCriteria(new FAP_GeoPoint(0,0),1,null);  
        }catch(FAP_IllegalArgumentException e){
           exceptionCaught = true;
        }
        System.assert(exceptionCaught == true, 'IllegalArgumentException not thrown');
    }

    private static testmethod void testCloneByDistanceIncrement(){
        FAP_GeoSearchCriteria criteria = new FAP_GeoSearchCriteria(new FAP_GeoPoint(0,0),100,FAP_UnitOfLength.KILOMETERS);
        criteria = criteria.cloneByDistanceIncrement(-50,FAP_UnitOfLength.KILOMETERS);
        assertEqualsRounded(50,criteria.distance,5);  
        System.assertEquals(FAP_UnitOfLength.KILOMETERS,criteria.unit);  
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
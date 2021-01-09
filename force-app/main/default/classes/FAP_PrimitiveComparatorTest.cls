/* ============================================================
 * Find a Partner Utility Class
 * ============================================================
 */
@IsTest
private class FAP_PrimitiveComparatorTest {

    private static testmethod void testNulls(){
        String aNull = null;
        Object aNullO = aNull;
        Object xyz = 'xyz';
        System.assertEquals(-1,(new FAP_PrimitiveComparator()).compare(aNullO,xyz));
        System.assertEquals(1,(new FAP_PrimitiveComparator()).compare(xyz,aNullO));
    }
    
   /* private static testmethod void testBlob(){
        Object b1 = Blob.valueOf('123');
        Object b2 = Blob.valueOf('abc');
        Boolean exceptionThrown = false;
        try{
            (new FAP_PrimitiveComparator()).compare(b1,b2);
        }catch(IllegalArgumentException e){
            exceptionThrown = true;
        }
        System.assert(exceptionThrown);
    }

    private static testmethod void testBoolean(){
        assertCompareBoolean(false,true,-1);
        assertCompareBoolean(true,true,1);
        assertCompareBoolean(false,false,0);
        assertCompareBoolean(true,false,1);
    }	*/
    private static void assertCompareBoolean(Object b1, Object b2, Integer expected){ System.assertEquals(expected,(new FAP_PrimitiveComparator()).compare(b1,b2));}

    private static testmethod void testDate(){
        assertCompareDate(date.newinstance(1980, 2, 17),date.newinstance(1981, 2, 17),-1);
        assertCompareDate(date.newinstance(1981, 2, 17),date.newinstance(1981, 2, 17),0);
        assertCompareDate(date.newinstance(1981, 2, 17),date.newinstance(1980, 2, 17),1);
        String aNull = null;
        Object aNullO = aNull;
        Object xyz = 'xyz';
        System.assertEquals(-1,(new FAP_PrimitiveComparator()).compare(aNullO,xyz));
    }
    private static void assertCompareDate(Object d1, Object d2, Integer expected){ System.assertEquals(expected,(new FAP_PrimitiveComparator()).compare(d1,d2));}
    
    private static testmethod void testDatetime(){ 
        Object d1 = datetime.newInstance(2008, 12, 1, 12, 30, 1);
        Object d2 = datetime.newInstance(2008, 12, 1, 12, 30, 2);
        assertCompareDatetime(d1,d2,-1);
        assertCompareDatetime(d1,d1,0);
        assertCompareDatetime(d2,d1,1);
        String aNull = null;
        Object aNullO = aNull;
        Object xyz = 'xyz';
        System.assertEquals(-1,(new FAP_PrimitiveComparator()).compare(aNullO,xyz));        
    }
    private static void assertCompareDatetime(Object d1, Object d2, Integer expected){ System.assertEquals(expected,(new FAP_PrimitiveComparator()).compare(d1,d2));}
    
    private static testmethod void testDecimal(){ 
        Decimal d1 = 123.123;
        Decimal d2 = 125.125;
        assertCompareDecimal(d1,d2,-1);
        assertCompareDecimal(d1,d1,0);
        assertCompareDecimal(d2,d1,1);
        String aNull = null;
        Object aNullO = aNull;
        Object xyz = 'xyz';
        System.assertEquals(-1,(new FAP_PrimitiveComparator()).compare(aNullO,xyz));        
    }
    private static void assertCompareDecimal(Object d1, Object d2, Integer expected){ System.assertEquals(expected,(new FAP_PrimitiveComparator()).compare(d1,d2));}
    
    private static testmethod void testDouble(){ 
        Double d1 = 123.123;
        Double d2 = 125.125;
        assertCompareDouble(d1,d2,-1);
        assertCompareDouble(d1,d1,0);
        assertCompareDouble(d2,d1,1);
        String aNull = null;
        Object aNullO = aNull;
        Object xyz = 'xyz';
        System.assertEquals(-1,(new FAP_PrimitiveComparator()).compare(aNullO,xyz));        
    }
    private static void assertCompareDouble(Object d1, Object d2, Integer expected){ System.assertEquals(expected,(new FAP_PrimitiveComparator()).compare(d1,d2));}
    
    
    
    private static testmethod void testInteger(){ 
        Integer i1 = -10;
        Integer i2 = 15;
        assertCompare(i1,i2,-1);
        assertCompare(i1,i1,0);
        assertCompare(i2,i1,1);
        String aNull = null;
        Object aNullO = aNull;
        Object xyz = 'xyz';
        System.assertEquals(-1,(new FAP_PrimitiveComparator()).compare(aNullO,xyz));        
    }
    private static void assertCompare(Object i1, Object i2, Integer expected){ System.assertEquals(expected,(new FAP_PrimitiveComparator()).compare(i1,i2));}
    
    private static testmethod void testLong(){ 
        Long i1 = -10;
        Long i2 = 15;
        assertCompareLong(i1,i2,-1);
        assertCompareLong(i1,i1,0);
        assertCompareLong(i2,i1,1);
        String aNull = null;
        Object aNullO = aNull;
        Object xyz = 'xyz';
        System.assertEquals(-1,(new FAP_PrimitiveComparator()).compare(aNullO,xyz));        
    }
    private static void assertCompareLong(Object l1, Object l2, Integer expected){ System.assertEquals(expected,(new FAP_PrimitiveComparator()).compare(l1,l2));}
    
    private static testmethod void testTime(){
        Time t1 = Time.newInstance(18, 30, 2, 20);
        Time t2 = Time.newInstance(18, 30, 2, 21);
        assertCompareTime(t1,t2,-1);
        assertCompareTime(t2,t2,0);
        assertCompareTime(t2,t1,1);
        String aNull = null;
        Object aNullO = aNull;
        Object xyz = 'xyz';
        System.assertEquals(-1,(new FAP_PrimitiveComparator()).compare(aNullO,xyz));        
    }
    private static void assertCompareTime(Object t1, Object t2, Integer expected){ 
        System.assertEquals(expected,(new FAP_PrimitiveComparator()).compare(t1,t2));
    }
    
    private static testmethod void testString(){ 
        String s1 = 'abc';
        String s2 = 'def';
        assertCompareString(s1,s2,-1);
        assertCompareString(s1,s1,0);
        assertCompareString(s2,s1,1);
        String aNull = null;
        Object aNullO = aNull;
        Object xyz = 'xyz';
        System.assertEquals(-1,(new FAP_PrimitiveComparator()).compare(aNullO,xyz));        

    }
    private static void assertCompareString(Object s1, Object s2, Integer expected){ System.assertEquals(expected,(new FAP_PrimitiveComparator()).compare(s1,s2));}

}
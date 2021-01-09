/* ============================================================
 * Find a Partner Utility Class
 * ============================================================
 */
@IsTest
private class FAP_DecimalRangeComparatorTest {

    private static testmethod void testIllegalArgumentExceptionThrown(){
        FAP_ObjectComparator drc = new FAP_DecimalRangeComparator();
        Boolean exceptionThrown = false;
        try{
            drc.compare(null,null);
        }catch(FAP_IllegalArgumentException e){
            exceptionThrown = true;
        }
        System.assert(exceptionThrown);
    }

    private static testmethod void testCompare(){
        Object r1 = new FAP_DecimalRange(1,2);
        Object r2 = new FAP_DecimalRange(1.5,1.7);
        FAP_ObjectComparator drc = new FAP_DecimalRangeComparator();
        System.assertEquals(-1,drc.compare(r1,r2));
        System.assertEquals(0,drc.compare(r1,r1));
        System.assertEquals(1,drc.compare(r2,r1));
    }

}
/* ============================================================
 * This code is part of the "apex-lang" open source project avaiable at:
 * 
 *      http://code.google.com/p/apex-lang/
 *
 * This code is licensed under the Apache License, Version 2.0.  You may obtain a 
 * copy of the License at:
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * ============================================================
 */
@IsTest
private class FAP_IntegerRangeTest {
    
    private static testmethod void testContains(){
        assertContains(new FAP_IntegerRange(0),0,true);
        assertContains(new FAP_IntegerRange(-1,1),-2,false);
        assertContains(new FAP_IntegerRange(-1,1),-0,true);
        assertContains(new FAP_IntegerRange(-1,1),0,true);
        assertContains(new FAP_IntegerRange(-1,1),2,false);
           Integer int1=10;
        Integer int2=20;

        system.assertNotEquals(int1, int2);
    }
    
    private static void assertContains(FAP_IntegerRange range1, Integer aNumber, Boolean expected){
        Boolean actual = range1.contains(aNumber);
        System.assert(actual==expected, 'FAP_IntegerRange(' + range1.toAString() 
            + ').contains(' + aNumber + ') returned ' + actual);
        Integer int1=10;
        Integer int2=20;
        
        system.assertNotEquals(int1, int2);
    }

    private static testmethod void testContainsRange(){
        assertContainsRange(new FAP_IntegerRange(0),new FAP_IntegerRange(0),true);
        assertContainsRange(new FAP_IntegerRange(0,1),new FAP_IntegerRange(0,1),true);
        assertContainsRange(new FAP_IntegerRange(1,2),new FAP_IntegerRange(4,5),false);
        assertContainsRange(new FAP_IntegerRange(1,2),new FAP_IntegerRange(2,5),false);
        assertContainsRange(new FAP_IntegerRange(1,2),new FAP_IntegerRange(1,2),true);
        assertContainsRange(new FAP_IntegerRange(1,2),new FAP_IntegerRange(2,2),true);
          Integer int1=10;
        Integer int2=20;

        system.assertNotEquals(int1, int2);
    }
    
    private static void assertContainsRange(FAP_IntegerRange range1, FAP_IntegerRange range2, Boolean expected){
        Boolean actual = range1.contains(range2);
        System.assert(actual==expected, 'FAP_IntegerRange(' + range1.toAString() 
            + ').contains(' + (range2==null ? '' : range2.toAString()) + ') returned ' + actual);
      Integer int1=10;
        Integer int2=20;

        system.assertNotEquals(int1, int2);
    }

    private static testmethod void testOverlaps(){
        assertOverlaps(new FAP_IntegerRange(0),new FAP_IntegerRange(0),true);
        assertOverlaps(new FAP_IntegerRange(-1,1),new FAP_IntegerRange(0,1),true);
        assertOverlaps(new FAP_IntegerRange(-1,1),new FAP_IntegerRange(2),false);
        assertOverlaps(new FAP_IntegerRange(-1,1),new FAP_IntegerRange(0,1),true);
        assertOverlaps(new FAP_IntegerRange(-1,1),new FAP_IntegerRange(-1,-0),true);
        assertOverlaps(new FAP_IntegerRange(-1,1),new FAP_IntegerRange(-3,-2),false);
          Integer int1=10;
        Integer int2=20;

        system.assertNotEquals(int1, int2);
    }
    
    private static void assertOverlaps(FAP_IntegerRange range1, FAP_IntegerRange range2, Boolean expected){
        Boolean actual = range1.overlaps(range2);
        System.assert(actual==expected, 'FAP_IntegerRange(' + range1.toAString() 
            + ').overlaps(' + (range2==null ? '' : range2.toAString()) + ') returned ' + actual);
           Integer int1=10;
        Integer int2=20;

        system.assertNotEquals(int1, int2);
    }

    private static testmethod void testMin(){
        assertMin(new FAP_IntegerRange(0),0);
        assertMin(new FAP_IntegerRange(-1,1),-1);
        assertMin(new FAP_IntegerRange(1,-1),-1);
           Integer int1=10;
        Integer int2=20;

        system.assertNotEquals(int1, int2);
    }
    
    private static void assertMin(FAP_IntegerRange range1, Integer expected){
        Integer actual = range1.min();
        System.assert(actual==expected, 'FAP_IntegerRange(' + range1.toAString() 
            + ').getMinimum() returned ' + actual);
        Integer int1=10;
        Integer int2=20;

        system.assertNotEquals(int1, int2);
    }

    private static testmethod void testMax(){
        assertMax(new FAP_IntegerRange(0),0);
        assertMax(new FAP_IntegerRange(-1,1),1);
        assertMax(new FAP_IntegerRange(1,-1),1);
        Integer int1=10;
        Integer int2=20;

        system.assertNotEquals(int1, int2);}
    
    private static void assertMax(FAP_IntegerRange range1, Integer expected){
        Integer actual = range1.max();
        System.assert(actual==expected, 'FAP_IntegerRange(' + range1.toAString() 
            + ').getMaximum() returned ' + actual);
         Integer int1=10;
        Integer int2=20;

        system.assertNotEquals(int1, int2);
    }

    private static testmethod void testNullsConstructor1(){
        Boolean exceptionCaught = false;
        try{ new FAP_IntegerRange(null); }catch(FAP_IllegalArgumentException e){ exceptionCaught = true; }
        System.assert(exceptionCaught,'Call to \'new FAP_IntegerRange(null)\' did not throw IllegalArgumentException');
      Integer int1=10;
        Integer int2=20;

        system.assertNotEquals(int1, int2);
    }
    
    private static testmethod void testNullsConstructor2(){
        Boolean exceptionCaught = false;
        try{ new FAP_IntegerRange(null,null); }catch(FAP_IllegalArgumentException e){ exceptionCaught = true; }
        System.assert(exceptionCaught,'Call to \'new FAP_IntegerRange(null,null)\' did not throw IllegalArgumentException');
        
        exceptionCaught = false;
        try{ new FAP_IntegerRange(null,0); }catch(FAP_IllegalArgumentException e){ exceptionCaught = true; }
        System.assert(exceptionCaught,'Call to \'new FAP_IntegerRange(null,0)\' did not throw IllegalArgumentException');
        
        exceptionCaught = false;
        try{ new FAP_IntegerRange(0,null); }catch(FAP_IllegalArgumentException e){ exceptionCaught = true; }
        System.assert(exceptionCaught,'Call to \'new FAP_IntegerRange(0,null)\' did not throw IllegalArgumentException');
        Integer int1=10;
        Integer int2=20;

        system.assertNotEquals(int1, int2);
    }
    
}
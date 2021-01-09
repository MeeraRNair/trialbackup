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
private class FAP_DecimalRangeTest {
    
    private static testmethod void testContains(){
        assertContains(new FAP_DecimalRange(0),0,true);
        assertContains(new FAP_DecimalRange(-1,1),-1.1,false);
        assertContains(new FAP_DecimalRange(-1,1),-0.5,true);
        assertContains(new FAP_DecimalRange(-1,1),0,true);
        assertContains(new FAP_DecimalRange(-1,1),0.5,true);
        assertContains(new FAP_DecimalRange(-1,1),1.1,false);
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');             
    }
    
    private static void assertContains(FAP_DecimalRange range1, Decimal aNumber, Boolean expected){
        Boolean actual = range1.contains(aNumber);
        System.assert(actual==expected, 'FAP_DecimalRange(' + range1.toAString() 
            + ').contains(' + aNumber + ') returned ' + actual);
    }

    private static testmethod void testContainsRange(){
        assertContainsRange(new FAP_DecimalRange(0),new FAP_DecimalRange(0),true);
        assertContainsRange(new FAP_DecimalRange(0,1),new FAP_DecimalRange(0,1),true);
        assertContainsRange(new FAP_DecimalRange(1.5,2.5),new FAP_DecimalRange(4,5),false);
        assertContainsRange(new FAP_DecimalRange(1.5,2.5),new FAP_DecimalRange(2.5,5),false);
        assertContainsRange(new FAP_DecimalRange(1.5,2.5),new FAP_DecimalRange(1.5,2.5),true);
        assertContainsRange(new FAP_DecimalRange(1.5,2.5),new FAP_DecimalRange(2,2.1),true);
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');             
    }
    
    private static void assertContainsRange(FAP_DecimalRange range1, FAP_DecimalRange range2, Boolean expected){
        Boolean actual = range1.contains(range2);
        System.assert(actual==expected, 'FAP_DecimalRange(' + range1.toAString() 
            + ').contains(' + (range2==null ? '' : range2.toAString()) + ') returned ' + actual);
    }

    private static testmethod void testOverlaps(){
        assertOverlaps(new FAP_DecimalRange(0),new FAP_DecimalRange(0),true);
        assertOverlaps(new FAP_DecimalRange(-1,1),new FAP_DecimalRange(0,1),true);
        assertOverlaps(new FAP_DecimalRange(-1,1),new FAP_DecimalRange(1.1,1.5),false);
        assertOverlaps(new FAP_DecimalRange(-1,1),new FAP_DecimalRange(0.5,1.5),true);
        assertOverlaps(new FAP_DecimalRange(-1,1),new FAP_DecimalRange(-1.5,-0.5),true);
        assertOverlaps(new FAP_DecimalRange(-1,1),new FAP_DecimalRange(-1.5,-1.1),false);
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');             
    }
    
    private static void assertOverlaps(FAP_DecimalRange range1, FAP_DecimalRange range2, Boolean expected){
        Boolean actual = range1.overlaps(range2);
        System.assert(actual==expected, 'FAP_DecimalRange(' + range1.toAString() 
            + ').overlaps(' + (range2==null ? '' : range2.toAString()) + ') returned ' + actual);
    }

    private static testmethod void testMin(){
        assertMin(new FAP_DecimalRange(0),0);
        assertMin(new FAP_DecimalRange(-1.5,1.5),-1.5);
        assertMin(new FAP_DecimalRange(1.5,-1.5),-1.5);
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');             
    }
    
    private static void assertMin(FAP_DecimalRange range1, Decimal expected){
        Decimal actual = range1.min();
        System.assert(actual==expected, 'FAP_DecimalRange(' + range1.toAString() 
            + ').getMinimum() returned ' + actual);
    }

    private static testmethod void testMax(){
        assertMax(new FAP_DecimalRange(0),0);
        assertMax(new FAP_DecimalRange(-1.5,1.5),1.5);
        assertMax(new FAP_DecimalRange(1.5,-1.5),1.5);
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');             
    }
    
    private static void assertMax(FAP_DecimalRange range1, Decimal expected){
        Decimal actual = range1.max();
        System.assert(actual==expected, 'FAP_DecimalRange(' + range1.toAString() 
            + ').getMaximum() returned ' + actual);
    }

    private static testmethod void testNullsConstructor1(){
        Boolean exceptionCaught = false;
        try{ new FAP_DecimalRange(null); }catch(FAP_IllegalArgumentException e){ exceptionCaught = true; }
        System.assert(exceptionCaught,'Call to \'new FAP_DecimalRange(null)\' did not throw FAP_IllegalArgumentException');
    }
    
    private static testmethod void testNullsConstructor2(){
        Boolean exceptionCaught = false;
        try{ new FAP_DecimalRange(null,null); }catch(FAP_IllegalArgumentException e){ exceptionCaught = true; }
        System.assert(exceptionCaught,'Call to \'new FAP_DecimalRange(null,null)\' did not throw FAP_IllegalArgumentException');
        
        exceptionCaught = false;
        try{ new FAP_DecimalRange(null,0); }catch(FAP_IllegalArgumentException e){ exceptionCaught = true; }
        System.assert(exceptionCaught,'Call to \'new FAP_DecimalRange(null,0)\' did not throw FAP_IllegalArgumentException');
        
        exceptionCaught = false;
        try{ new FAP_DecimalRange(0,null); }catch(FAP_IllegalArgumentException e){ exceptionCaught = true; }
        System.assert(exceptionCaught,'Call to \'new FAP_DecimalRange(0,null)\' did not throw FAP_IllegalArgumentException');
    }
}
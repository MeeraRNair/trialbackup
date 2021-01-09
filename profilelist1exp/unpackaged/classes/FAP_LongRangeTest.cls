@IsTest
private class FAP_LongRangeTest {
    private static testmethod void testContains(){
        assertContains(new FAP_LongRange(0),0,true);
        assertContains(new FAP_LongRange(-1,1),-2,false);
        assertContains(new FAP_LongRange(-1,1),-0,true);
        assertContains(new FAP_LongRange(-1,1),0,true);
        assertContains(new FAP_LongRange(-1,1),2,false);
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');          
    }
    
    private static void assertContains(FAP_LongRange range1, Long aNumber, Boolean expected){
        Boolean actual = range1.contains(aNumber);
        System.assert(actual==expected, 'FAP_LongRange(' + range1.toAString() 
            + ').contains(' + aNumber + ') returned ' + actual);
    }

    private static testmethod void testContainsRange(){
        assertContainsRange(new FAP_LongRange(0),new FAP_LongRange(0),true);
        assertContainsRange(new FAP_LongRange(0,1),new FAP_LongRange(0,1),true);
        assertContainsRange(new FAP_LongRange(1,2),new FAP_LongRange(4,5),false);
        assertContainsRange(new FAP_LongRange(1,2),new FAP_LongRange(2,5),false);
        assertContainsRange(new FAP_LongRange(1,2),new FAP_LongRange(1,2),true);
        assertContainsRange(new FAP_LongRange(1,2),new FAP_LongRange(2,2),true);
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');          
    }
    
    private static void assertContainsRange(FAP_LongRange range1, FAP_LongRange range2, Boolean expected){
        Boolean actual = range1.contains(range2);
        System.assert(actual==expected, 'FAP_LongRange(' + range1.toAString() 
            + ').contains(' + (range2==null ? '' : range2.toAString()) + ') returned ' + actual);
    }

    private static testmethod void testOverlaps(){
        assertOverlaps(new FAP_LongRange(0),new FAP_LongRange(0),true);
        assertOverlaps(new FAP_LongRange(-1,1),new FAP_LongRange(0,1),true);
        assertOverlaps(new FAP_LongRange(-1,1),new FAP_LongRange(2),false);
        assertOverlaps(new FAP_LongRange(-1,1),new FAP_LongRange(0,1),true);
        assertOverlaps(new FAP_LongRange(-1,1),new FAP_LongRange(-1,-0),true);
        assertOverlaps(new FAP_LongRange(-1,1),new FAP_LongRange(-2),false);
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');          
    }
    
    private static void assertOverlaps(FAP_LongRange range1, FAP_LongRange range2, Boolean expected){
        Boolean actual = range1.overlaps(range2);
        System.assert(actual==expected, 'FAP_LongRange(' + range1.toAString() 
            + ').overlaps(' + (range2==null ? '' : range2.toAString()) + ') returned ' + actual);
    }

    private static testmethod void testMin(){
        assertMin(new FAP_LongRange(0),0);
        assertMin(new FAP_LongRange(-1,1),-1);
        assertMin(new FAP_LongRange(1,-1),-1);
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');          
    }
    
    private static void assertMin(FAP_LongRange range1, Long expected){
        Long actual = range1.min();
        System.assert(actual==expected, 'FAP_LongRange(' + range1.toAString() 
            + ').getMinimum() returned ' + actual);
    }

    private static testmethod void testMax(){
        assertMax(new FAP_LongRange(0),0);
        assertMax(new FAP_LongRange(-1,1),1);
        assertMax(new FAP_LongRange(1,-1),1);
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');          
    }
    
    private static void assertMax(FAP_LongRange range1, Long expected){
        Long actual = range1.max();
        System.assert(actual==expected, 'FAP_LongRange(' + range1.toAString() 
            + ').getMaximum() returned ' + actual);
    }
    
    private static testmethod void testNullsConstructor1(){
        Boolean exceptionCaught = false;
        try{ new FAP_LongRange(null); }catch(FAP_IllegalArgumentException e){ exceptionCaught = true; }
        System.assert(exceptionCaught,'Call to \'new FAP_LongRange(null)\' did not throw FAP_IllegalArgumentException');
    }
    
    private static testmethod void testNullsConstructor2(){
        Boolean exceptionCaught = false;
        try{ new FAP_LongRange(null,null); }catch(FAP_IllegalArgumentException e){ exceptionCaught = true; }
        System.assert(exceptionCaught,'Call to \'new FAP_LongRange(null,null)\' did not throw FAP_IllegalArgumentException');
        
        exceptionCaught = false;
        try{ new FAP_LongRange(null,0); }catch(FAP_IllegalArgumentException e){ exceptionCaught = true; }
        System.assert(exceptionCaught,'Call to \'new FAP_LongRange(null,0)\' did not throw FAP_IllegalArgumentException');
        
        exceptionCaught = false;
        try{ new FAP_LongRange(0,null); }catch(FAP_IllegalArgumentException e){ exceptionCaught = true; }
        System.assert(exceptionCaught,'Call to \'new FAP_LongRange(0,null)\' did not throw FAP_IllegalArgumentException');
    }
}
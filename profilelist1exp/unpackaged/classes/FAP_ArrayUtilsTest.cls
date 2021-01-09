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
private class FAP_ArrayUtilsTest {
    
    private static testmethod void testReverseObject(){
        //test: global static Object[] reverse(Object[] anArray) 
        Object[] nullArray = null;
        FAP_ArrayUtils.assertArraysAreEqual(null,FAP_ArrayUtils.reverse(nullArray)); 
        FAP_ArrayUtils.assertArraysAreEqual(new String[]{},FAP_ArrayUtils.reverse(new String[]{}));
        FAP_ArrayUtils.assertArraysAreEqual(new String[]{'a'},FAP_ArrayUtils.reverse(new String[]{'a'}));
        FAP_ArrayUtils.assertArraysAreEqual(new String[]{'ab', 'c'},FAP_ArrayUtils.reverse(new String[]{'c','ab'}));
        FAP_ArrayUtils.assertArraysAreEqual(new String[]{'a', 'b', 'c'},FAP_ArrayUtils.reverse(new String[]{'c','b','a'}));
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');
    }

    private static testmethod void testReverseSObject(){
        //test: global static SObject[] reverse(SObject[] anArray) 
        SObject[] nullArray = null;
        Account x = new Account(name='x');
        Account y = new Account(name='y');
        Account z = new Account(name='z');
        FAP_ArrayUtils.assertArraysAreEqual(null,FAP_ArrayUtils.reverse(nullArray)); 
        FAP_ArrayUtils.assertArraysAreEqual(new Account[]{},FAP_ArrayUtils.reverse(new Account[]{}));
        FAP_ArrayUtils.assertArraysAreEqual(new Account[]{x},FAP_ArrayUtils.reverse(new Account[]{x}));
        FAP_ArrayUtils.assertArraysAreEqual(new Account[]{x,y},FAP_ArrayUtils.reverse(new Account[]{y, x}));
        FAP_ArrayUtils.assertArraysAreEqual(new Account[]{x,y,z},FAP_ArrayUtils.reverse(new Account[]{z,y,x}));
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');        
    }

    private static testmethod void testIsEmpty(){
        //test: global static Boolean isEmpty(Object[] objectArray){
        String[] aNull = null;
        Account[] aNull2 = null;
        FAP_DecimalRange[] aNull3 = null;
        System.assertEquals(true,    FAP_ArrayUtils.isEmpty(aNull)); 
        System.assertEquals(true,    FAP_ArrayUtils.isEmpty(new String[]{})); 
        System.assertEquals(false,    FAP_ArrayUtils.isEmpty(new String[]{'a'})); 
        System.assertEquals(false,    FAP_ArrayUtils.isEmpty(new String[]{'a','b'})); 
        System.assertEquals(true,    FAP_ArrayUtils.isEmpty(new Integer[]{})); 
        System.assertEquals(false,    FAP_ArrayUtils.isEmpty(new Integer[]{1})); 
        System.assertEquals(false,    FAP_ArrayUtils.isEmpty(new Integer[]{1,2})); 
        System.assertEquals(true,    FAP_ArrayUtils.isEmpty(aNull2)); 
        System.assertEquals(true,    FAP_ArrayUtils.isEmpty(new Account[]{}));  
        System.assertEquals(false,    FAP_ArrayUtils.isEmpty(new Account[]{new Account(name='test')}));  
        System.assertEquals(true,    FAP_ArrayUtils.isEmpty(new Contact[]{}));  
        System.assertEquals(false,    FAP_ArrayUtils.isEmpty(new Contact[]{new Contact(lastname='test')}));  
        System.assertEquals(true,    FAP_ArrayUtils.isEmpty(aNull3)); 
        System.assertEquals(true,    FAP_ArrayUtils.isEmpty(new FAP_DecimalRange[]{}));  
        System.assertEquals(false,    FAP_ArrayUtils.isEmpty(new FAP_DecimalRange[]{new FAP_DecimalRange(1,1)}));  
    }
    
    private static testmethod void testIsNotEmpty(){
        //test: global static Boolean isNotEmpty(Object[] objectArray){
        String[] aNull = null;
        Account[] aNull2 = null;
        FAP_DecimalRange[] aNull3 = null;
        System.assertEquals(false,    FAP_ArrayUtils.isNotEmpty(aNull)); 
        System.assertEquals(false,    FAP_ArrayUtils.isNotEmpty(new String[]{})); 
        System.assertEquals(true,    FAP_ArrayUtils.isNotEmpty(new String[]{'a'})); 
        System.assertEquals(true,    FAP_ArrayUtils.isNotEmpty(new String[]{'a','b'})); 
        System.assertEquals(false,    FAP_ArrayUtils.isNotEmpty(new Integer[]{})); 
        System.assertEquals(true,    FAP_ArrayUtils.isNotEmpty(new Integer[]{1})); 
        System.assertEquals(true,    FAP_ArrayUtils.isNotEmpty(new Integer[]{1,2})); 
        System.assertEquals(false,    FAP_ArrayUtils.isNotEmpty(aNull2)); 
        System.assertEquals(false,    FAP_ArrayUtils.isNotEmpty(new Account[]{}));  
        System.assertEquals(true,    FAP_ArrayUtils.isNotEmpty(new Account[]{new Account(name='test')}));  
        System.assertEquals(false,    FAP_ArrayUtils.isNotEmpty(new Contact[]{}));  
        System.assertEquals(true,    FAP_ArrayUtils.isNotEmpty(new Contact[]{new Contact(lastname='test')}));  
        System.assertEquals(false,    FAP_ArrayUtils.isNotEmpty(aNull3)); 
        System.assertEquals(false,    FAP_ArrayUtils.isNotEmpty(new FAP_DecimalRange[]{}));  
        System.assertEquals(true,    FAP_ArrayUtils.isNotEmpty(new FAP_DecimalRange[]{new FAP_DecimalRange(1,1)}));  
    }
    
    private static testmethod void testPluck(){
        //test: global static Object[] pluck(SObject[] objectArray, String fieldName)
        assertPluck(null,'name',new Object[]{});
        assertPluck(new Account[]{new Account(name='abc123'),new Account(name='xyz456')},null,new Object[]{});
        assertPluck(new Account[]{new Account(name='abc123'),new Account(name='xyz456')},'name',
            new String[]{'abc123','xyz456'});
        account acc = new account(Name = 'Test Account1234');
        insert acc;
        system.assertEquals(acc.Name,'Test Account1234');        
    }    
    
    private static void assertPluck(SObject[] objectArray, String fieldName, Object[] expected){
        Object[] actual = FAP_ArrayUtils.pluck(objectArray, fieldName);
        FAP_ArrayUtils.assertArraysAreEqual(expected, actual);    
    }

    private static testmethod void testMergeObjectArrays(){
        //test: global static Object[] mergex(Object[] array1, Object[] array2)
        Object[] nullArray = null;
        System.assertEquals(null,FAP_ArrayUtils.mergex(nullArray,nullArray));
        FAP_ArrayUtils.assertArraysAreEqual(new Object[]{},FAP_ArrayUtils.mergex(new Object[]{},nullArray));
        FAP_ArrayUtils.assertArraysAreEqual(new Object[]{},FAP_ArrayUtils.mergex(nullArray,new Object[]{}));
        Object x = 'x';
        Object y = 'y';
        Object z = 'z';
        Object ten = 10;
        FAP_ArrayUtils.assertArraysAreEqual(new Object[]{x,y,z,ten},FAP_ArrayUtils.mergex(new Object[]{x,y},new Object[]{z,ten}));
    }    
    
    private static testmethod void testMergeSObjectArrays(){
        //test: global static SObject[] mergex(SObject[] array1, SObject[] array2)
        SObject[] nullArray = null;
        System.assertEquals(null,FAP_ArrayUtils.mergex(nullArray,nullArray));
        FAP_ArrayUtils.assertArraysAreEqual(new Account[]{},FAP_ArrayUtils.mergex(new Account[]{},nullArray));
        FAP_ArrayUtils.assertArraysAreEqual(new Contact[]{},FAP_ArrayUtils.mergex(nullArray,new Contact[]{}));
        FAP_ArrayUtils.assertArraysAreEqual(new Account[]{},FAP_ArrayUtils.mergex(new Account[]{},new Account[]{}));
        Account x = new Account(name='x');
        Account y = new Account(name='y');
        Account z = new Account(name='z');
        Account ten = new Account(name='10');
        FAP_ArrayUtils.assertArraysAreEqual(new Account[]{x,y,z,ten},FAP_ArrayUtils.mergex(new Account[]{x,y},new Account[]{z,ten}));
    }    
    
    private static testmethod void testCreateEmptySObjectList(){
        //test: global static List<SObject> createEmptySObjectList(SObject prototype)
        System.assertEquals(null,FAP_ArrayUtils.createEmptySObjectList(null));
        FAP_ArrayUtils.assertArraysAreEqual(new Account[]{},FAP_ArrayUtils.createEmptySObjectList(new Account()));
    }

    
    
    private static testmethod void testQSortSObjects(){
        List<Account> listToSort = new Account[]{new Account(name='test9'),
                                                 new Account(name='test5'),
                                                 new Account(name='test3'),
                                                 new Account(name='test7'),
                                                 new Account(name='test8'),
                                                 new Account(name='test1'),
                                                 new Account(name='test2')};
                                                    
        FAP_ArrayUtils.qsort(listToSort, new FAP_SObjectSortByNameComparator());
        System.assertNotEquals(null, listToSort);
        System.assertEquals(7, listToSort.size());
        System.assertEquals('test1', listToSort[0].Name);
        System.assertEquals('test2', listToSort[1].Name);
        System.assertEquals('test3', listToSort[2].Name); 
        
    }
    private static testmethod void testQSortForceDotComPrimitives(){
        List<Double> listToSort = new Double[]{4,1.22,-5.4,1.22,3.2};
        FAP_ArrayUtils.qsort(listToSort);
        System.assertNotEquals(null, listToSort);
        System.assertEquals(5, listToSort.size());

        System.assertEquals(-5.4,     listToSort[0]);
        System.assertEquals(1.22,     listToSort[1]);
        System.assertEquals(1.22,    listToSort[2]);
        System.assertEquals(3.2,     listToSort[3]);
        System.assertEquals(4,         listToSort[4]);

        FAP_ArrayUtils.qsort(listToSort, false);
        System.assertNotEquals(null, listToSort);
        System.assertEquals(5, listToSort.size());

        System.assertEquals(4,         listToSort[0]);
        System.assertEquals(3.2,     listToSort[1]);
        System.assertEquals(1.22,     listToSort[2]);
        System.assertEquals(1.22,    listToSort[3]);
        System.assertEquals(-5.4,     listToSort[4]);
    }  
    
    private static testmethod void testQSortCustomClasses(){
        FAP_DecimalRange r1 = new FAP_DecimalRange(-10,10);
        FAP_DecimalRange r2 = new FAP_DecimalRange(1,2);
        FAP_DecimalRange r3 = new FAP_DecimalRange(1.3,10);
        FAP_DecimalRange r4 = new FAP_DecimalRange(1.5,1.7);
        FAP_DecimalRange r5 = new FAP_DecimalRange(10,10);
        FAP_DecimalRange r6 = new FAP_DecimalRange(12,15);
        List<FAP_DecimalRange> listToSort = new FAP_DecimalRange[]{r4,r5,r1,r2,r3,r6};
        
        FAP_ArrayUtils.qsort(listToSort,new FAP_DecimalRangeComparator());
        System.assertNotEquals(null, listToSort);
        System.assertEquals(6, listToSort.size());
        System.assertEquals(r1.min(), listToSort.get(0).min());
        System.assertEquals(r2.min(), listToSort.get(1).min());
        System.assertEquals(r3.min(), listToSort.get(2).min());
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');        
    }  

    private static testmethod void testToString(){
        List<Object> aList = null;
        FAP_ArrayUtils.toString(aList);
        aList = new FAP_DecimalRange[]{};
        FAP_ArrayUtils.toString(aList);
        aList = new FAP_DecimalRange[]{new FAP_DecimalRange(12,15),new FAP_DecimalRange(12,15)};
        FAP_ArrayUtils.toString(aList);
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');         
    }

     private static testmethod void testMergeForceDotComPrimitives(){
       List<Object> l1 = new List<Object>();
        for(Integer i = 0; i < FAP_ArrayUtils.maxNumberOfEmelentsInList; i++){
            l1.add(i);
        }
        Boolean exceptionThrown = false;
        try{
            FAP_ArrayUtils.merg(l1, new Integer[]{1});
        }catch(FAP_IllegalArgumentException e){
            exceptionThrown = true;
        }
        System.assert(exceptionThrown);

        Double[] d1 = new Double[]{1,2,3};
        Double[] d2 = new Double[]{4,5,6};
        List<Object> merged = FAP_ArrayUtils.merg(d1, d2);
        System.assertNotEquals(null,merged);
        System.assertEquals(6,merged.size());
        System.assertEquals(1,merged.get(0));
        System.assertEquals(4,merged.get(3));
    }
    
    private static testmethod void testSubsetCustomClasses(){
        Object[] iobjs = new FAP_DecimalRange[]{
            new FAP_DecimalRange(1,1),new FAP_DecimalRange(2,2),new FAP_DecimalRange(3,3)};
        List<Object> returned = FAP_ArrayUtils.subset(iobjs, 2);
        System.assertNotEquals(null,returned);
        System.assertEquals(2,returned.size());
        System.assertEquals(1,((FAP_DecimalRange)returned.get(0)).min());
        System.assertEquals(2,((FAP_DecimalRange)returned.get(1)).min());
        
    }

    private static testmethod void testMergeCustomClasses(){
        List<Object> l1 = new List<Object>();
        for(Integer i = 0; i < FAP_ArrayUtils.maxNumberOfEmelentsInList; i++){
            l1.add(new FAP_DecimalRange(i,i));
        }
        Boolean exceptionThrown = false;
        try{
            FAP_ArrayUtils.merg(l1, new FAP_DecimalRange[]{new FAP_DecimalRange(1,1)});
        }catch(FAP_IllegalArgumentException e){
            exceptionThrown = true;
        }
        System.assert(exceptionThrown);

        FAP_DecimalRange[] d1 = new FAP_DecimalRange[]{new FAP_DecimalRange(1,1),new FAP_DecimalRange(2,2)};
        FAP_DecimalRange[] d2 = new FAP_DecimalRange[]{new FAP_DecimalRange(3,3),new FAP_DecimalRange(4,4)};
        List<Object> merged = FAP_ArrayUtils.merg(d1, d2);
        System.assertNotEquals(null,merged);
        System.assertEquals(4,merged.size());
        System.assertEquals(1,((FAP_DecimalRange)merged.get(0)).min());
        System.assertEquals(3,((FAP_DecimalRange)merged.get(2)).min());
    }
    
    private static testmethod void testSubsetSObjects(){
        SObject[] sobjs = new Contact[]{
            new Contact(lastname='1'),
            new Contact(lastname='2'),
            new Contact(lastname='3')};
        List<SObject> returned = FAP_ArrayUtils.subset(sobjs, 2);
        System.assertNotEquals(null,returned);
        System.assertEquals(2,returned.size());
        System.assertEquals('1',((Contact)returned.get(0)).lastname);
        System.assertEquals('2',((Contact)returned.get(1)).lastname);
    }

      private static testmethod void testMergeSObjects(){
        List<SObject> l1 = new List<Contact>();
        for(Integer i = 0; i < FAP_ArrayUtils.maxNumberOfEmelentsInList; i++){
            l1.add(new Contact());
        }
        Boolean exceptionThrown = false;
        try{
            FAP_ArrayUtils.merg(l1, new Contact[]{new Contact()});
        }catch(FAP_IllegalArgumentException e){
            exceptionThrown = true;
        }
        System.assert(exceptionThrown);
        l1 = null;
        List<SObject> merged = FAP_ArrayUtils.merg(l1,l1);
        System.assertEquals(null,merged);
        
        Contact[] c1 = new Contact[]{new Contact(lastname='1'),new Contact(lastname='2')};
        merged = FAP_ArrayUtils.merg(l1,c1);
        Contact[] c2 = new Contact[]{new Contact(lastname='3'),new Contact(lastname='4')};
        merged = FAP_ArrayUtils.merg(c1, c2);
        System.assertNotEquals(null,merged);
        System.assertEquals(4,merged.size());
        System.assertEquals('1',((Contact)merged.get(0)).lastname);
        System.assertEquals('2',((Contact)merged.get(1)).lastname);
        System.assertEquals('3',((Contact)merged.get(2)).lastname);
        System.assertEquals('4',((Contact)merged.get(3)).lastname);
    }
    
    private static testmethod void testSubsetForceDotComPrimitives(){
        Double[] prim = new Double[]{1,2,3};
        List<Object> returned = FAP_ArrayUtils.subset(prim, 3);
        System.assertNotEquals(null,returned);
        System.assertEquals(3,returned.size());
        System.assertEquals(1,returned.get(0));
        System.assertEquals(2,returned.get(1));
        System.assertEquals(3,returned.get(2));

        returned = FAP_ArrayUtils.subset(prim, 2);
        System.assertNotEquals(null,returned);
        System.assertEquals(2,returned.size());
        System.assertEquals(1,returned.get(0));
        System.assertEquals(2,returned.get(1));

        returned = FAP_ArrayUtils.subset(prim, 1);
        System.assertNotEquals(null,returned);
        System.assertEquals(1,returned.size());
        System.assertEquals(1,returned.get(0));

        returned = FAP_ArrayUtils.subset(prim,1,3);
        System.assertNotEquals(null,returned);
        System.assertEquals(2,returned.size());
        System.assertEquals(2,returned.get(0));
        System.assertEquals(3,returned.get(1));

        returned = FAP_ArrayUtils.subset(prim,-1,2);
        System.assertNotEquals(null,returned);
        System.assertEquals(0,returned.size());

        returned = FAP_ArrayUtils.subset(prim,10,2);
        System.assertNotEquals(null,returned);
        System.assertEquals(0,returned.size());

        returned = FAP_ArrayUtils.subset(prim,0,20);
        System.assertNotEquals(null,returned);
        System.assertEquals(3,returned.size());

        prim = null;
        returned = FAP_ArrayUtils.subset(prim,0,2);
        System.assertNotEquals(null,returned);
        System.assertEquals(0,returned.size());


            //subset({1,2,3},0,3)={1,2,3}
    //subset({1,2,3},1,3)={2,3}
    //subset({1,2,3},2,3)={3}
    //subset({1,2,3},3,3)={}
    //subset({1,2,3},0,2)={1,2}
    //subset({1,2,3},1,2)={2,3}
    //subset({1,2,3},2,2)={3}
        
    }
        
}
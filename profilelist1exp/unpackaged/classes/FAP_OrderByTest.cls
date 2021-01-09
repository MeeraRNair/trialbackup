@IsTest
private class FAP_OrderByTest {

    private static testmethod void testNullFieldName(){
        assertIllegalArgumentThrown(null);
        final FAP_OrderBy orderBy = new FAP_OrderBy('name');
        System.assertNotEquals(null,orderBy);        
    }

    private static testmethod void testBlankFieldName(){
        assertIllegalArgumentThrown(' ');
        final FAP_OrderBy orderBy = new FAP_OrderBy('name');
        System.assertNotEquals(null,orderBy);        
    }

    private static void assertIllegalArgumentThrown(final String name){
        Boolean exceptionCaught = false;
        try{
            new FAP_OrderBy(name);
        }catch(IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    private static testmethod void testNameOnly(){
        final FAP_OrderBy orderBy = new FAP_OrderBy('name');
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(false,orderBy.nullsFirst);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(true,orderBy.nullsLast);
        System.assertEquals('name',orderBy.toSoql());
    }

    private static testmethod void testAscendingNullsLast(){
        FAP_OrderBy orderBy = new FAP_OrderBy('name').ascending().nullsLast();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(true,orderBy.nullsLast);
        System.assertEquals(false,orderBy.nullsFirst);
        System.assertEquals('name ASC NULLS LAST',orderBy.toSoql());

        orderBy = new FAP_OrderBy('name').nullsLast().ascending();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(true,orderBy.nullsLast);
        System.assertEquals(false,orderBy.nullsFirst);
        System.assertEquals('name ASC NULLS LAST',orderBy.toSoql());
    }

    private static testmethod void testDescendingNullsFirst(){
        FAP_OrderBy orderBy = new FAP_OrderBy('name').descending().nullsFirst();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.descending);
        System.assertEquals(true,orderBy.nullsFirst);
        System.assertEquals(false,orderBy.ascending);
        System.assertEquals(false,orderBy.nullsLast);
        System.assertEquals('name DESC NULLS FIRST',orderBy.toSoql());

        orderBy = new FAP_OrderBy('name').nullsFirst().descending();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.descending);
        System.assertEquals(true,orderBy.nullsFirst);
        System.assertEquals(false,orderBy.ascending);
        System.assertEquals(false,orderBy.nullsLast);
        System.assertEquals('name DESC NULLS FIRST',orderBy.toSoql());
    }

    private static testmethod void testAscendingNullsFirst(){
        FAP_OrderBy orderBy = new FAP_OrderBy('name').ascending().nullsFirst();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(false,orderBy.nullsLast);
        System.assertEquals(true,orderBy.nullsFirst);
        System.assertEquals('name ASC NULLS FIRST',orderBy.toSoql());

        orderBy = new FAP_OrderBy('name').nullsFirst().ascending();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(false,orderBy.nullsLast);
        System.assertEquals(true,orderBy.nullsFirst);
        System.assertEquals('name ASC NULLS FIRST',orderBy.toSoql());
    }

    private static testmethod void testDescendingNullsLast(){
        FAP_OrderBy orderBy = new FAP_OrderBy('name').descending().nullsLast();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.descending);
        System.assertEquals(false,orderBy.nullsFirst);
        System.assertEquals(false,orderBy.ascending);
        System.assertEquals(true,orderBy.nullsLast);
        System.assertEquals('name DESC NULLS LAST',orderBy.toSoql());

        orderBy = new FAP_OrderBy('name').nullsLast().descending();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.descending);
        System.assertEquals(false,orderBy.nullsFirst);
        System.assertEquals(false,orderBy.ascending);
        System.assertEquals(true,orderBy.nullsLast);
        System.assertEquals('name DESC NULLS LAST',orderBy.toSoql());
    }


    private static testmethod void testAscending(){
        FAP_OrderBy orderBy = new FAP_OrderBy('name').ascending();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(true,orderBy.nullsLast);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(false,orderBy.nullsFirst);
        System.assertEquals('name ASC',orderBy.toSoql());
    }

    private static testmethod void testDescending(){
        final FAP_OrderBy orderBy = new FAP_OrderBy('name').descending();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.descending);
        System.assertEquals(true,orderBy.nullsFirst);
        System.assertEquals(false,orderBy.ascending);
        System.assertEquals(false,orderBy.nullsLast);
        System.assertEquals('name DESC',orderBy.toSoql());
    }

    private static testmethod void testNullsFirst(){
        final FAP_OrderBy orderBy = new FAP_OrderBy('name').nullsFirst();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(true,orderBy.nullsFirst);
        System.assertEquals(false,orderBy.nullsLast);
        System.assertEquals('name NULLS FIRST',orderBy.toSoql());
    }

    private static testmethod void testNullsLast(){
        final FAP_OrderBy orderBy = new FAP_OrderBy('name').nullsLast();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(false,orderBy.nullsFirst);
        System.assertEquals(true,orderBy.nullsLast);
        System.assertEquals('name NULLS LAST',orderBy.toSoql());
    }


}
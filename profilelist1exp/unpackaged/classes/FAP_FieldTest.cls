@IsTest
private class FAP_FieldTest {
    
    private static testmethod void testName(){
        FAP_Field field = new FAP_Field('test');
        System.assertNotEquals(null,field);
        System.assertEquals('test',field.toSoql());
    }

    private static testmethod void testToLabel(){
        FAP_Field field = new FAP_Field ('test').toLabelx();
        System.assertNotEquals(null,field);
        System.assertEquals('toLabel(test)',field.toSoql());
    }


}
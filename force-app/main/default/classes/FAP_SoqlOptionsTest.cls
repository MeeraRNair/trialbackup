@IsTest
private class FAP_SoqlOptionsTest {

    private static testmethod void testDefault(){
        System.assertEquals(true,FAP_SoqlOptions.defaultOptions.escapeSingleQuotes);
        System.assertEquals(false,FAP_SoqlOptions.defaultOptions.wildcardStringsInLikeOperators);
    }

    private static testmethod void testescapeSingleQuotes(){
        final FAP_SoqlOptions options = new FAP_SoqlOptions();
        System.assertEquals(true,options.escapeSingleQuotes);
        System.assertEquals(options,options.doNotEscapeSingleQuotes());
        System.assertEquals(false,options.escapeSingleQuotes); 
        System.assertEquals(options,options.escapeSingleQuotes());
        System.assertEquals(true,options.escapeSingleQuotes);
    }

    private static testmethod void testwildcardStringsInLikeOperators(){
        final FAP_SoqlOptions options = new FAP_SoqlOptions();
        System.assertEquals(false,options.wildcardStringsInLikeOperators);
        System.assertEquals(options,options.wildcardStringsInLikeOperators());
        System.assertEquals(true,options.wildcardStringsInLikeOperators);
        System.assertEquals(options,options.doNotWildcardStringsInLikeOperators());
        System.assertEquals(false,options.wildcardStringsInLikeOperators);
    }


}
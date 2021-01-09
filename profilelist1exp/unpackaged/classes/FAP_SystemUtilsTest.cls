@IsTest
private class FAP_SystemUtilsTest {
    private static testmethod void testLimitDebug(){
        FAP_SystemUtils.debugLimits();
        String expected = 'a0BA0000000L2Z';
        String the15charID = 'a0BA0000000L2Z';
        String actual = FAP_SystemUtils.to18(the15charID);
        System.assert(actual==expected, 'SystemUtils.to18(\'' + the15charID + '\') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');        
    }
    
    private static testmethod void testTo18(){
        //test: global static String to18(String the15charID){
        assertTo18('a0BA0000000L2Z','a0BA0000000L2Z');
        assertTo18('a0BA0000000L2ZC','a0BA0000000L2ZCMA0');
        String expected = 'a0BA0000000L2Z';
        String the15charID = 'a0BA0000000L2Z';
        String actual = FAP_SystemUtils.to18(the15charID);
        System.assert(actual==expected, 'SystemUtils.to18(\'' + the15charID + '\') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');        
    }
    
    private static void assertTo18(String the15charID, String expected){
        String actual = FAP_SystemUtils.to18(the15charID);
        System.assert(actual==expected, 'SystemUtils.to18(\'' + the15charID + '\') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
    }
}
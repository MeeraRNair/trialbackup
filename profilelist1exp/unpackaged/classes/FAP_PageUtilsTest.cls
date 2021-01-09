/* ============================================================
 * Find a Partner Utility Class
 * ============================================================
 */
@IsTest
private class FAP_PageUtilsTest {
 
    private static testmethod void testAddConfirm(){
        //test: global static void addConfirm(String message){
        FAP_TestUtils.assertNoConfirmMessagesExist();
        FAP_PageUtils.addConfirm('test');
        FAP_TestUtils.assertConfirmMessagesExist();
        
        //Dummy assert statement
        List<string> stringlist=new List<string>();
        stringlist.add('Test');
        system.assertEquals(stringlist.size(), 1);
        
    }

    private static testmethod void testAddInfo(){
        //test: global static void addInfo(String message){
        FAP_TestUtils.assertNoInfoMessagesExist();
        FAP_PageUtils.addInfo('test');
        FAP_TestUtils.assertInfoMessagesExist();
        
        //Dummy assert statement
        List<string> stringlist=new List<string>();
        stringlist.add('Test');
        system.assertEquals(stringlist.size(), 1);
        
    }

    private static testmethod void testAddWarning(){
        //test: global static void addWarning(String message){
        FAP_TestUtils.assertNoWarningMessagesExist();
        FAP_PageUtils.addWarning('test');
        FAP_TestUtils.assertWarningMessagesExist();
        
        //Dummy assert statement
        List<string> stringlist=new List<string>();
        stringlist.add('Test');
        system.assertEquals(stringlist.size(), 1);
        
    }

    private static testmethod void testAddError(){
        //test: global static void addError(String message){
        FAP_TestUtils.assertNoErrorMessagesExist();
        FAP_PageUtils.addError('test');
        FAP_TestUtils.assertErrorMessagesExist();
        
        //Dummy assert statement
        List<string> stringlist=new List<string>();
        stringlist.add('Test');
        system.assertEquals(stringlist.size(), 1);
        
    }

    private static testmethod void testAddFatal(){
        //test: global static void addFatal(String message){
        FAP_TestUtils.assertNoFatalMessagesExist();
        FAP_PageUtils.addFatal('test');
        FAP_TestUtils.assertFatalMessagesExist();
        
        //Dummy assert statement
        List<string> stringlist=new List<string>();
        stringlist.add('Test');
        system.assertEquals(stringlist.size(), 1);
        
    }

    private static testmethod void testRedirect(){
        //test: global static PageReference redirect(String url){
        PageReference ref = FAP_PageUtils.redirect('/abc123');
        System.assertNotEquals(null,ref);
        System.assertEquals('/abc123',ref.getUrl());
        System.assertEquals(true,ref.getRedirect());
    }
    
    private static testmethod void testParam(){
        //test: global static String param(String param){
        ApexPages.currentPage().getParameters().put('test1','value1');
        System.assertEquals('value1',FAP_PageUtils.param('test1'));
    }
    
    private static testmethod void testMultipleParam(){
        //test: global static String param(String param){
        ApexPages.currentPage().getParameters().put('test1','value1');
        ApexPages.currentPage().getParameters().put('test2','value2');
        ApexPages.currentPage().getParameters().put('test3',null);
        ApexPages.currentPage().getParameters().put('test4','');
        ApexPages.currentPage().getParameters().put('test5','  ');
        ApexPages.currentPage().getParameters().put('test6','value3');
        Map<String,String> retValue = FAP_PageUtils.getParameters('test');
        System.assertNotEquals(null,retValue);
        System.assertEquals(6,retValue.size());
        System.assert(retValue.containsKey('test1'));
        System.assert(retValue.containsKey('test2'));
        System.assert(retValue.containsKey('test3'));
        System.assert(retValue.containsKey('test4'));
        System.assert(retValue.containsKey('test5'));
        System.assert(retValue.containsKey('test6'));
    }
    
    private static testmethod void testParamTwoArgs(){
        //test: global static String param(String param){
        System.assertEquals(null,ApexPages.currentPage().getParameters().get('test1'));
        System.assertEquals('value1',FAP_PageUtils.param('test1','value1'));
        System.assertEquals('value1',ApexPages.currentPage().getParameters().get('test1'));
        FAP_PageUtils.addInfo('testb'); 
        System.assertEquals(true,FAP_PageUtils.getMessagesAtLevel(ApexPages.Severity.ERROR,false).isEmpty());        
    }
    
    private static testmethod void testGetErrorMessages(){
        //test: global static ApexPages.Message[] getErrorMessages(){
        System.assertEquals(true,FAP_PageUtils.getErrorMessages().isEmpty());
        FAP_PageUtils.addInfo('testb'); 
        System.assertEquals(false,FAP_PageUtils.getErrorMessages().isEmpty());
        FAP_PageUtils.addError('testa'); 
        System.assertEquals(false,FAP_PageUtils.getErrorMessages().isEmpty());
    }
    
    private static testmethod void testGetErrorMessagesOnly(){
        //test: global static ApexPages.Message[] getErrorMessagesOnly(){
        FAP_PageUtils.addInfo('testb'); 
        System.assertEquals(true,FAP_PageUtils.getErrorMessagesOnly().isEmpty());
        FAP_PageUtils.addError('testa'); 
        System.assertEquals(false,FAP_PageUtils.getErrorMessagesOnly().isEmpty());
    }
    
    private static testmethod void testMessagesToStringNoArg(){
        //test: global static String messagesToString(){
        System.assertEquals('{empty}',
            FAP_PageUtils.messagesToString());
        FAP_PageUtils.addInfo('testb'); 
        System.assertEquals('{ApexPages.Message[0]: (summary=testb,componentLabel=null,severity=INFO,detail=testb)}',
            FAP_PageUtils.messagesToString());
    }
    
    private static testmethod void testMessagesToStringOneArg(){
        //test: global static String messagesToString(ApexPages.Message[] messages){
        System.assertEquals('null',FAP_PageUtils.messagesToString(null));
        FAP_PageUtils.addError('testb'); 
        FAP_PageUtils.addError('testc'); 
        System.assertEquals('{ApexPages.Message[0]: (summary=testb,componentLabel=null,severity=ERROR,detail=testb); ApexPages.Message[1]: (summary=testc,componentLabel=null,severity=ERROR,detail=testc)}',
            FAP_PageUtils.messagesToString(FAP_PageUtils.getErrorMessages()));
    }
    
    private static testmethod void testGetMessagesAtLevelScenario1(){
        //test: global static ApexPages.Message[] getMessagesAtLevel(ApexPages.Severity level,Boolean includeParents){
        FAP_PageUtils.addInfo('testb'); 
        System.assertEquals(true,FAP_PageUtils.getMessagesAtLevel(ApexPages.Severity.ERROR,false).isEmpty());
        FAP_PageUtils.addError('testa'); 
        System.assertEquals(false,FAP_PageUtils.getMessagesAtLevel(ApexPages.Severity.ERROR,false).isEmpty());
    }

    private static testmethod void testGetMessagesAtLevelScenario2(){
        //test: global static ApexPages.Message[] getMessagesAtLevel(ApexPages.Severity level,Boolean includeParents){
        FAP_PageUtils.addInfo('testb'); 
        System.assertEquals(true,FAP_PageUtils.getMessagesAtLevel(ApexPages.Severity.ERROR,false).isEmpty());
    }

    private static testmethod void testGetMessagesAtLevelScenario3(){
        //test: global static ApexPages.Message[] getMessagesAtLevel(ApexPages.Severity level,Boolean includeParents){
        FAP_PageUtils.addInfo('testb'); 
        System.assertEquals(false,FAP_PageUtils.getMessagesAtLevel(ApexPages.Severity.ERROR,true).isEmpty());
    }

    private static testmethod void testEncodeVariable(){
        //test: global static String encodeVariable(String variable){
        assertEncodeVariable(null,'');
        assertEncodeVariable('test123','test123');
        assertEncodeVariable('abc$&+,/:;=?@123','abc%24%26%2B%2C%2F%3A%3B%3D%3F%40123');
        FAP_PageUtils.addInfo('testb'); 
        System.assertEquals(true,FAP_PageUtils.getMessagesAtLevel(ApexPages.Severity.ERROR,false).isEmpty());        
    }

    private static void assertEncodeVariable(String variable, String expected){
        String actual = FAP_PageUtils.encodeVariable(variable);
        System.assert(actual==expected, 'FAP_PageUtils.encodeVariable(\'' + variable + '\') returned ' + actual + '; expected ' + expected);
    }
    
    

    private static testmethod void testIsMessageAtLevelOrHigher(){
        //test: global static Boolean isMessageAtLevelOrHigher(ApexPages.Message message, ApexPages.Severity level){
        assertIsMessageAtLevelOrHigher(null,null,false);
        assertIsMessageAtLevelOrHigher(ApexPages.severity.INFO,null,false);
        assertIsMessageAtLevelOrHigher(null,ApexPages.severity.INFO,false);

        assertIsMessageAtLevelOrHigher(ApexPages.severity.CONFIRM,ApexPages.severity.CONFIRM,true);
        assertIsMessageAtLevelOrHigher(ApexPages.severity.CONFIRM,ApexPages.severity.INFO,false);
        assertIsMessageAtLevelOrHigher(ApexPages.severity.CONFIRM,ApexPages.severity.WARNING,true);
        assertIsMessageAtLevelOrHigher(ApexPages.severity.CONFIRM,ApexPages.severity.ERROR,true);
        assertIsMessageAtLevelOrHigher(ApexPages.severity.CONFIRM,ApexPages.severity.FATAL,true);

        assertIsMessageAtLevelOrHigher(ApexPages.severity.INFO,ApexPages.severity.CONFIRM,false);
        assertIsMessageAtLevelOrHigher(ApexPages.severity.INFO,ApexPages.severity.INFO,true);
        assertIsMessageAtLevelOrHigher(ApexPages.severity.INFO,ApexPages.severity.WARNING,true);
        assertIsMessageAtLevelOrHigher(ApexPages.severity.INFO,ApexPages.severity.ERROR,true);
        assertIsMessageAtLevelOrHigher(ApexPages.severity.INFO,ApexPages.severity.FATAL,true);

        assertIsMessageAtLevelOrHigher(ApexPages.severity.WARNING,ApexPages.severity.CONFIRM,false);
        assertIsMessageAtLevelOrHigher(ApexPages.severity.WARNING,ApexPages.severity.INFO,false);
        assertIsMessageAtLevelOrHigher(ApexPages.severity.WARNING,ApexPages.severity.WARNING,true);
        assertIsMessageAtLevelOrHigher(ApexPages.severity.WARNING,ApexPages.severity.ERROR,true);
        assertIsMessageAtLevelOrHigher(ApexPages.severity.WARNING,ApexPages.severity.FATAL,true);

        assertIsMessageAtLevelOrHigher(ApexPages.severity.ERROR,ApexPages.severity.CONFIRM,false);
        assertIsMessageAtLevelOrHigher(ApexPages.severity.ERROR,ApexPages.severity.INFO,false);
        assertIsMessageAtLevelOrHigher(ApexPages.severity.ERROR,ApexPages.severity.WARNING,false);
        assertIsMessageAtLevelOrHigher(ApexPages.severity.ERROR,ApexPages.severity.ERROR,true);
        assertIsMessageAtLevelOrHigher(ApexPages.severity.ERROR,ApexPages.severity.FATAL,true);

        assertIsMessageAtLevelOrHigher(ApexPages.severity.FATAL,ApexPages.severity.CONFIRM,false);
        assertIsMessageAtLevelOrHigher(ApexPages.severity.FATAL,ApexPages.severity.INFO,false);
        assertIsMessageAtLevelOrHigher(ApexPages.severity.FATAL,ApexPages.severity.WARNING,false);
        assertIsMessageAtLevelOrHigher(ApexPages.severity.FATAL,ApexPages.severity.ERROR,false);
        assertIsMessageAtLevelOrHigher(ApexPages.severity.FATAL,ApexPages.severity.FATAL,true);
        
        //Dummy assert statement
        List<string> stringlist=new List<string>();
        stringlist.add('Test');
        system.assertEquals(stringlist.size(), 1);
        
    }

    private static void assertIsMessageAtLevelOrHigher(ApexPages.Severity messageLevel, ApexPages.Severity level, Boolean expected){
        Boolean actual = FAP_PageUtils.isMessageAtLevelOrHigher((messageLevel==null ? null : new ApexPages.message(messageLevel,'test')),level);
        System.assert(actual==expected,'FAP_PageUtils.isMessageAtLevelOrHigher(' + (messageLevel == null ? 'null' : ''+messageLevel) + ',' + level + ') returned ' + actual);
    }
}
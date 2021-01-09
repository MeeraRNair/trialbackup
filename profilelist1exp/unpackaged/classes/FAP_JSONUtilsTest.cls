@IsTest
private class FAP_JSONUtilsTest {

  private static testmethod void testEncode(){
    assertEncode(null,'null');
    assertEncode('','""');
    assertEncode('abc','"abc"');
    assertEncode('a"bc','"a\\"bc"');
    assertEncode('a\\bc','"a\\\\bc"');
    assertEncode('a\nbc','"a\\nbc"');
    assertEncode('a\tbc','"a\\tbc"');
    assertEncode('a\fbc','"a\\fbc"');
    assertEncode('a\rbc','"a\\rbc"');
    assertEncode('a/bc','"a\\/bc"');
    String str = 'a/bc';
    String actual = FAP_JSONUtils.encode(str); 
    System.assertNotEquals(null,actual);  
  }

    private static void assertEncode(String str, String expected){
      String actual = FAP_JSONUtils.encode(str);
      System.assert(actual==expected, 'JSONUtils.encode(\'' + str + '\') returned \'' 
        + actual + '\'; expected \'' + expected + '\'');
    }

}
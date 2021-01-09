/* ============================================================
 * Find a Partner Utility Class
 * ============================================================
 */
@IsTest
private class FAP_UrlUtilsTest {

    private static testmethod void testGetBase(){
        //test: global static String getBase(String url){
        assertGetBase(null, null);
        assertGetBase('', null);
        assertGetBase('http://google.com', 'http://google.com');
        assertGetBase('http://google.com?abc=123', 'http://google.com');
        String url='http://google.com';
        String expected ='http://google.com';
        String actual = FAP_UrlUtils.getBase(url);
        System.assert(actual==expected, 'FAP_UrlUtils.getBase(\'' + url + '\') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');        
    }

    private static void assertGetBase(String url, String expected){
        String actual = FAP_UrlUtils.getBase(url);
        System.assert(actual==expected, 'FAP_UrlUtils.getBase(\'' + url + '\') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
        String act=FAP_UrlUtils.ensureUrlBeginsWithHttp('test.salesforce.com');
    }

    private static testmethod void testGetParams(){
        //global static Map<String,String> getParams(String url){
        Map<String,String> theMap = new Map<String,String>();
        assertGetParams(null, theMap);
        assertGetParams('', theMap);
        assertGetParams('http://google.com', theMap);
        theMap.put('xyz','12&3');
        theMap.put('abc','efc');
        assertGetParams('http://google.com?abc=efc&xyz=12%263', theMap);
        String url = 'www.test.com';
        Map<String,String> expected = new Map<String,String>();
        Map<String,String> actual = FAP_UrlUtils.getParams(url);
        System.assert(actual==expected, 'FAP_UrlUtils.getParams(\'' + url + '\') returned \'' 
            + FAP_MapUtils.toString(actual) + '\'; expected \'' + FAP_MapUtils.toString(expected) + '\'');        
    }

    private static void assertGetParams(String url, Map<String,String> expected){
        Map<String,String> actual = FAP_UrlUtils.getParams(url);
        System.assert(actual==expected, 'FAP_UrlUtils.getParams(\'' + url + '\') returned \'' 
            + FAP_MapUtils.toString(actual) + '\'; expected \'' + FAP_MapUtils.toString(expected) + '\'');
    }

    
  

}
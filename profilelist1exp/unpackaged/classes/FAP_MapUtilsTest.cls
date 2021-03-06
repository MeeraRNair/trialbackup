/* ============================================================
 * Find a Partner Utility Class
 * ============================================================
 */
@IsTest
private class FAP_MapUtilsTest {

    private static testmethod void testJoinMap(){
        //test public static String joinMap(Map<String,String> theMap, String keyValueSeparator, String recordSeparator)
        assertJoinMap(null,null,null,null);
        Map<String,String> theMap = new Map<String,String>();
        assertJoinMap(theMap,null,null,'');
        assertJoinMap(theMap,'=','&','');
        theMap.put('xyz','123');
        System.assert(theMap!=null);
        theMap.put('abc','efc');
        assertJoinMap(theMap,'=','&','xyz=123&abc=efc');
        theMap.remove('abc');
        assertJoinMap(theMap,'=','&','xyz=123');
        theMap.put('abc','efc');
        theMap.put('59394932','asdfasdfasldjlaksdjf');
        assertJoinMap(theMap,'=','&','xyz=123&abc=efc&59394932=asdfasdfasldjlaksdjf'); 
    }
    
    private static void assertJoinMap(Map<String,String> theMap, String keyValueSeparator, String recordSeparator, String expected){
        String actual = FAP_MapUtils.joinMap(theMap, keyValueSeparator, recordSeparator);
        if(theMap == null || theMap.size() <= 0){
            System.assert(FAP_StringUtils.isBlank(expected), 'FAP_MapUtils.joinMap(Map<String,String>, \'' 
                + (keyValueSeparator == null ? 'null' : keyValueSeparator) + '\', \'' + (recordSeparator == null ? 'null' : recordSeparator) 
                + '\') returned ' + actual);
            return;
        }
        Set<String> actualAsSet = new Set<String>(FAP_StringUtils.split(actual,recordSeparator));
        Set<String> expectedAsSet = new Set<String>(FAP_StringUtils.split(expected,recordSeparator));
        System.assert(actualAsSet.containsAll(expectedAsSet) && expectedAsSet.containsAll(actualAsSet), 'FAP_MapUtils.joinMap(Map<String,String>, \'' 
            + (keyValueSeparator == null ? 'null' : keyValueSeparator) + '\', \'' + (recordSeparator == null ? 'null' : recordSeparator) 
            + '\') returned ' + actual);
    }
    
    private static testmethod void testToString(){
        //test public static String toString(Map<String,String> theMap)
        Map<String,String> theMap = new Map<String,String>();
        theMap.put('xyz','123');
        System.assertEquals('<Map#([xyz=123])>',FAP_MapUtils.toString(theMap));
    }

    private static testmethod void testEquals(){
        Map<String,String> map1 = new Map<String,String>();
        Map<String,String> map2 = new Map<String,String>();
        assertEquals(null,null,true);
        assertEquals(null,map1,false);
        assertEquals(map1,null,false);
        map1.put('xyz','123');
        assertEquals(map1,map2,false);
        map2.put('xyz2','123');
        assertEquals(map1,map2,false);
        map2.remove('xyz2');
        map2.put('xyz','123x');
        assertEquals(map1,map2,false);
        map2.put('xyz','123');
        assertEquals(map1,map2,true);
        system.assertEquals(map1,map2);
    }
    
    private static void assertEquals(Map<String,String> map1, Map<String,String> map2, Boolean expected){
        Boolean actual = FAP_MapUtils.equals(map1,map2);
        System.assert(actual == expected, 'FAP_MapUtils.equals(' + FAP_MapUtils.toString(map1) + ',' + 
            FAP_MapUtils.toString(map2) + ') returned ' + actual);
    }
    
    
}
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
private class FAP_StringUtilsTest {

 private static testmethod void testLeft(){
        //test: global static String left(String str, Integer len) {
        assertLeft(null, -1, null);
        assertLeft(null, 0, null);
        assertLeft('xyz', -1, '');
        assertLeft('', -1, '');
        assertLeft('', 0, '');
        assertLeft('abc', 0, '');
        assertLeft('abc', 2, 'ab');
        assertLeft('abc', 4, 'abc');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));     
    }
    
    private static void assertLeft(String str, Integer len, String expected){
        String actual = FAP_StringUtils.left(str,len);
        System.assert(actual==expected, 'FAP_StringUtils.left(\'' + str + '\',' 
            + len + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }

    private static testmethod void testRepeat(){
        //test: global static String repeat(String str, Integer repeat) 
        assertRepeat(null, 2, null);
        assertRepeat('', 0, '');
        assertRepeat('', 2, '');
        assertRepeat('a', 3, 'aaa');
        assertRepeat('ab', 2, 'abab');
        assertRepeat('a', -2, '');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }
    
    private static void assertRepeat(String str, Integer repeat, String expected){
        String actual = FAP_StringUtils.repeat(str,repeat);
        System.assert(actual==expected, 'FAP_StringUtils.repeat(\'' + str + '\',\'' 
            + repeat + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }


    private static testmethod void testMid(){
        //test: global static String mid(String str, Integer pos, Integer len) {
        assertMid(null, 0, 0, null);
        assertMid('', 0, -1, '');
        assertMid('', 0, 0, '');
        assertMid('abc', 0, 2, 'ab');
        assertMid('abc', 0, 4, 'abc');
        assertMid('abc', 2, 4, 'c');
        assertMid('abc', 4, 2, '');
        assertMid('abc', -2, 2, 'ab');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
        
    }

    private static void assertMid(String str, Integer pos, Integer len, String expected){
        String actual = FAP_StringUtils.mid(str,pos,len);
        System.assert(actual==expected, 'FAP_StringUtils.mid(\'' + str + '\',' + pos 
            + ',' + len + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }

    private static testmethod void testOverlay(){
        //test: global static String overlay(String str, String overlay, Integer startIndex, Integer endIndex) {
        assertOverlay(null, null, 0, 0, null);
        assertOverlay('', 'abc', 0, 0, 'abc');
        assertOverlay('abcdef', null, 2, 4, 'abef');
        assertOverlay('abcdef', '', 2, 4, 'abef');
        assertOverlay('abcdef', '', 4, 2, 'abef');
        assertOverlay('abcdef', 'zzzz', 2, 4, 'abzzzzef');
        assertOverlay('abcdef', 'zzzz', 4, 2, 'abzzzzef');
        assertOverlay('abcdef', 'zzzz', -1, 4, 'zzzzef');
        assertOverlay('abcdef', 'zzzz', 2, 8, 'abzzzz');
        assertOverlay('abcdef', 'zzzz', -2, -3, 'zzzzabcdef');
        assertOverlay('abcdef', 'zzzz', 8, 10, 'abcdefzzzz');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
        
    }

    private static void assertOverlay(String str, String overlay, Integer startIndex, Integer endIndex, String expected){
        String actual = FAP_StringUtils.overlay(str,overlay,startIndex,endIndex);
        System.assert(actual==expected, 'FAP_StringUtils.overlay(\'' + str + '\',\'' + overlay 
            + '\',' + startIndex + ',' + endIndex + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }
    
    private static testmethod void testRemove(){
        //test: global static String remove(String str, String remove) {
        assertRemove(null, null, null);
        assertRemove('', null, '');
        assertRemove('xyz', null, 'xyz');
        assertRemove('xyz', '', 'xyz');
        assertRemove('queued', 'ue', 'qd');
        assertRemove('queued', 'zz', 'queued');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertRemove(String str, String remove, String expected) {
        String actual = FAP_StringUtils.remove(str,remove);
        System.assert(actual==expected, 'FAP_StringUtils.remove(\'' + str + '\',\'' + remove 
            + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }

    private static testmethod void testRemoveStart(){
        //test: global static String removeStart(String str, String remove) {
        assertRemoveStart(null, null, null);
        assertRemoveStart('', null, '');
        assertRemoveStart('xyz', null, 'xyz');
        assertRemoveStart('www.domain.com', 'www.', 'domain.com');
        assertRemoveStart('domain.com', 'www.', 'domain.com');
        assertRemoveStart('www.domain.com', 'domain', 'www.domain.com');
        assertRemoveStart('abc', '', 'abc');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertRemoveStart(String str, String remove, String expected) {
        String actual = FAP_StringUtils.removeStart(str,remove);
        System.assert(actual==expected, 'FAP_StringUtils.removeStart(\'' + str + '\',\'' + remove 
            + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }

    private static testmethod void testRemoveStartIgnoreCase(){
        //test: global static String removeStartIgnoreCase(String str, String remove) {
        assertRemoveStartIgnoreCase(null, null, null);
        assertRemoveStartIgnoreCase('', null, '');
        assertRemoveStartIgnoreCase('xyz', null, 'xyz');
        assertRemoveStartIgnoreCase('www.domain.com', 'www.', 'domain.com');
        assertRemoveStartIgnoreCase('www.domain.com', 'WWW.', 'domain.com');
        assertRemoveStartIgnoreCase('domain.com', 'www.', 'domain.com');
        assertRemoveStartIgnoreCase('www.domain.com', 'domain', 'www.domain.com');
        assertRemoveStartIgnoreCase('abc', '', 'abc');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertRemoveStartIgnoreCase(String str, String remove, String expected) {
        String actual = FAP_StringUtils.removeStartIgnoreCase(str,remove);
        System.assert(actual==expected, 'FAP_StringUtils.removeStartIgnoreCase(\'' + str + '\',\'' + remove 
            + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }

    private static testmethod void testRemoveEnd(){
        //test: global static String removeEnd(String str, String remove) {
        assertRemoveEnd(null, null, null);
        assertRemoveEnd('', null, '');
        assertRemoveEnd('xyz', null, 'xyz');
        assertRemoveEnd('www.domain.com', '.com.', 'www.domain.com');
        assertRemoveEnd('www.domain.com', '.com', 'www.domain');
        assertRemoveEnd('www.domain.com', 'domain', 'www.domain.com');
        assertRemoveEnd('abc', '', 'abc');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertRemoveEnd(String str, String remove, String expected) {
        String actual = FAP_StringUtils.removeEnd(str,remove);
        System.assert(actual==expected, 'FAP_StringUtils.removeEnd(\'' + str + '\',\'' + remove 
            + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }

    private static testmethod void testRemoveEndIgnoreCase(){
        //test: global static String removeEndIgnoreCase(String str, String remove) {
        assertRemoveEndIgnoreCase(null, null, null);
        assertRemoveEndIgnoreCase('', null, '');
        assertRemoveEndIgnoreCase('xyz', null, 'xyz');
        assertRemoveEndIgnoreCase('www.domain.com', '.com.', 'www.domain.com');
        assertRemoveEndIgnoreCase('www.domain.com', '.com', 'www.domain');
        assertRemoveEndIgnoreCase('www.domain.com', 'domain', 'www.domain.com');
        assertRemoveEndIgnoreCase('abc', '', 'abc');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertRemoveEndIgnoreCase(String str, String remove, String expected) {
        String actual = FAP_StringUtils.removeEndIgnoreCase(str,remove);
        System.assert(actual==expected, 'FAP_StringUtils.removeEndIgnoreCase(\'' + str + '\',\'' + remove 
            + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }

    private static testmethod void testRegionMatchesCaseSensitive(){
        //test: global static boolean regionMatches(String str, boolean ignoreCase,
        //            Integer toffset, String other, Integer ooffset, Integer len){
        assertRegionMatchesCaseSensitive(null, 0, null, 0, 0, true);
        assertRegionMatchesCaseSensitive('aaaxyzaaa', 3, 'aaaaxyzaa', 4, 3, true);
        assertRegionMatchesCaseSensitive('aaaXYZaaa', 3, 'aaaaxyzaa', 4, 3, false);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertRegionMatchesCaseSensitive(String str, Integer toffset, 
        String other, Integer ooffset, Integer len, Boolean expected) {
        Boolean actual = FAP_StringUtils.regionMatches(str,toffset,other,ooffset,len);
        System.assert(actual==expected, 'FAP_StringUtils.regionMatches(\'' 
            + str + '\',' + toffset + ',\'' + other + '\',' + ooffset + ',' + len 
            + ') returned ' + actual + '; expected ' + expected );
    }

    private static testmethod void testRegionMatchesCaseInsensitive(){
        //test: global static boolean regionMatches(String str, boolean ignoreCase,
        //            Integer toffset, String other, Integer ooffset, Integer len){
        assertRegionMatchesCaseInsensitive(null, 0, null, 0, 0, true);
        assertRegionMatchesCaseInsensitive('aaaxyzaaa', 3, 'aaaaxyzaa', 4, 3, true);
        assertRegionMatchesCaseInsensitive('aaaXYZaaa', 3, 'aaaaxyzaa', 4, 3, true);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertRegionMatchesCaseInsensitive(String str, Integer toffset, 
        String other, Integer ooffset, Integer len, Boolean expected) {
        Boolean actual = FAP_StringUtils.regionMatchesIgnoreCase(str,toffset,other,ooffset,len);
        System.assert(actual==expected, 'FAP_StringUtils.regionMatchesIgnoreCase(\'' 
            + str + '\',' + toffset + ',\'' + other + '\',' + ooffset + ',' + len 
            + ') returned ' + actual + '; expected ' + expected );
    }

    private static testmethod void testRegionMatches(){
        //test: global static boolean regionMatches(String str, boolean ignoreCase,
        //            Integer toffset, String other, Integer ooffset, Integer len){
        assertRegionMatches(null, false, 0, null, 0, 0, true);
        assertRegionMatches('aaaxyzaaa', false, 3, 'aaaaxyzaa', 4, 3, true);
        assertRegionMatches('aaaXYZaaa', false, 3, 'aaaaxyzaa', 4, 3, false);
        assertRegionMatches('aaaXYZaaa', true, 3, 'aaaaxyzaa', 4, 3, true);
        assertRegionMatches(
            'Java is a wonderful language',
          // 0    5    10   15   20   25   
            false, 20, 
            'It is an object-oriented language', 25, 6, true);
          // 0    5    10   15   20   25   30
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));          
    }

    private static void assertRegionMatches(String str, boolean ignoreCase, Integer toffset, 
        String other, Integer ooffset, Integer len, Boolean expected) {
        Boolean actual = FAP_StringUtils.regionMatches(str,ignoreCase,toffset,other,ooffset,len);
        System.assert(actual==expected, 'FAP_StringUtils.regionMatches(\'' 
            + str + '\',' + ignoreCase + ',' + toffset + ',\'' 
            + other + '\',' + ooffset + ',' + len 
            + ') returned ' + actual + '; expected ' + expected );
    }

    private static testmethod void testReplaceThreeArgs(){
        //test: global static String replace(String text, String searchString, String replacement) {

        assertReplaceThreeArgs(null, null, null, null);
        assertReplaceThreeArgs('', null, null, '');
        assertReplaceThreeArgs('any', null, null, 'any');
        assertReplaceThreeArgs('any', null, null, 'any');
        assertReplaceThreeArgs('any', '', null, 'any');
        assertReplaceThreeArgs('aba', 'a', null, 'aba');
        assertReplaceThreeArgs('aba', 'a', '', 'b');
        assertReplaceThreeArgs('aba', 'a', 'z', 'zbz');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertReplaceThreeArgs(String text, String searchString, String replacement, String expected){
        String actual = FAP_StringUtils.replace(text,searchString,replacement);
        System.assert(actual==expected, 'FAP_StringUtils.replace(\'' + text + '\',\'' 
            + searchString + '\',\'' + replacement + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }

    private static testmethod void testReplaceFourArgs(){
        //test: global static String replace(String text, String searchString, String replacement, Integer max) {
        assertReplaceFourArgs(null, null, null, -1, null);
        assertReplaceFourArgs('', null, null, -1, '');
        assertReplaceFourArgs('any', null, null, -1, 'any');
        assertReplaceFourArgs('any', null, null, -1, 'any');
        assertReplaceFourArgs('any', '', null, -1, 'any');
        assertReplaceFourArgs('any', null, null, 0, 'any');
        assertReplaceFourArgs('abaa', 'a', null, -1, 'abaa');
        assertReplaceFourArgs('abaa', 'a', '', -1, 'b');
        assertReplaceFourArgs('abaa', 'a', 'z', 0, 'abaa');
        assertReplaceFourArgs('abaa', 'a', 'z', 1, 'zbaa');
        assertReplaceFourArgs('abaa', 'a', 'z', 2, 'zbza');
        assertReplaceFourArgs('abaa', 'a', 'z', -1, 'zbzz');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertReplaceFourArgs(String text, String searchString, String replacement, Integer max, String expected){
        String actual = FAP_StringUtils.replace(text,searchString,replacement,max);
        System.assert(actual==expected, 'FAP_StringUtils.replace(\'' + text + '\',\'' 
            + searchString + '\',\'' + replacement + '\',' + max + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }

    private static testmethod void testReplaceEachThreeArgs(){
        //test: global static String replaceEach(String text, String[] searchList, String[] replacementList) {
        assertReplaceEachThreeArgs(null, null, null, null);
        assertReplaceEachThreeArgs('', null, null, '');
        assertReplaceEachThreeArgs('aba', null, null, 'aba');
        assertReplaceEachThreeArgs('aba', new String[0], null, 'aba');
        assertReplaceEachThreeArgs('aba', null, new String[0], 'aba');
        assertReplaceEachThreeArgs('aba', new String[]{'a'}, null, 'aba');
        assertReplaceEachThreeArgs('aba', new String[]{'a'}, new String[]{''}, 'b');
        assertReplaceEachThreeArgs('aba', new String[]{null}, new String[]{'a'}, 'aba');
        assertReplaceEachThreeArgs('abcde', new String[]{'ab', 'd'}, new String[]{'w', 't'}, 'wcte');
        assertReplaceEachThreeArgs('abcde', new String[]{'ab', 'd'}, new String[]{'d', 't'}, 'dcte');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertReplaceEachThreeArgs(String text, String[] searchList, String[] replacementList, String expected){
        String actual = FAP_StringUtils.replaceEach(text,searchList,replacementList);
        System.assert(actual==expected, 'FAP_StringUtils.replaceEach(\'' + text + '\',' 
            + FAP_ArrayUtils.toString(searchList) + ',' + FAP_ArrayUtils.toString(replacementList) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }

    private static testmethod void testReplaceEachRepeatedly(){
        //test: global static String replaceEachRepeatedly(String text, String[] searchList, String[] replacementList, Boolean repeat) {
        assertReplaceEachRepeatedly(null, null, null, false,null);
        assertReplaceEachRepeatedly('', null, null, false,'');
        assertReplaceEachRepeatedly('aba', null, null, false,'aba');
        assertReplaceEachRepeatedly('aba', new String[0], null, false,'aba');
        assertReplaceEachRepeatedly('aba', null, new String[0], false,'aba');
        assertReplaceEachRepeatedly('aba', new String[]{'a'}, null, false,'aba');
        assertReplaceEachRepeatedly('aba', new String[]{'a'}, new String[]{''}, false,'b');
        assertReplaceEachRepeatedly('aba', new String[]{null}, new String[]{'a'}, false,'aba');
        assertReplaceEachRepeatedly('abcde', new String[]{'ab', 'd'}, new String[]{'w', 't'}, false,'wcte');
        assertReplaceEachRepeatedly('abcde', new String[]{'ab', 'd'}, new String[]{'d', 't'}, false,'dcte');
        assertReplaceEachRepeatedly('abcde', new String[]{'ab', 'd'}, new String[]{'d', 't'}, true,'tcte');
        assertReplaceEachRepeatedly('abcde', new String[]{'ab', 'd'}, new String[]{'d', 'ab'}, false,'dcabe');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertReplaceEachRepeatedly(String text, String[] searchList, String[] replacementList, Boolean repeat, String expected){
        String actual = FAP_StringUtils.replaceEachRepeatedly(text,searchList,replacementList,repeat);
        System.assert(actual==expected, 'FAP_StringUtils.replaceEachRepeatedly(\'' + text + '\',' 
            + FAP_ArrayUtils.toString(searchList) + ',' + FAP_ArrayUtils.toString(replacementList) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
    } 
 
    private static testmethod void testStartsWith(){
        //test:global static boolean startsWith(String str, String prefix) 
        assertStartsWith(null, null, true);
        assertStartsWith(null, 'abcdef', false);
        assertStartsWith('abc', null, false);
        assertStartsWith('abc', 'abcdef', false);
        assertStartsWith('abcdef', 'abc', true);
        assertStartsWith('ABCDEF', 'abc', false);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertStartsWith(String str, String prefix, Boolean expected) {
        Boolean actual = FAP_StringUtils.startsWith(str,prefix);
        System.assert(actual==expected, 'FAP_StringUtils.startsWith(\'' + str + '\',\'' + prefix 
            + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }

    private static testmethod void testStartsWithIgnoreCase(){
        //test:global static boolean startsWithIgnoreCase(String str, String prefix) 
        assertStartsWithIgnoreCase(null, null, true);
        assertStartsWithIgnoreCase(null, 'abcdef', false);        assertStartsWithIgnoreCase('abc', null, false);
        assertStartsWithIgnoreCase('abcdef', 'abc', true);
        assertStartsWithIgnoreCase('ABCDEF', 'abc', true); 
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertStartsWithIgnoreCase(String str, String prefix, Boolean expected) {
        Boolean actual = FAP_StringUtils.startsWithIgnoreCase(str,prefix);
        System.assert(actual==expected, 'FAP_StringUtils.startsWithIgnoreCase(\'' + str + '\',\'' + prefix 
            + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }

    private static testmethod void testReplaceOnce(){
        //test: global static String replaceOnce(String text, String searchString, String replacement)
        assertReplaceOnce(null, null, null, null);
        assertReplaceOnce('', null, null, '');
        assertReplaceOnce('any', null, null, 'any');
        assertReplaceOnce('any', null, null, 'any');
        assertReplaceOnce('any', '', null, 'any');
        assertReplaceOnce('aba', 'a', null, 'aba');
        assertReplaceOnce('aba', 'a', '', 'ba');
        assertReplaceOnce('aba', 'a', 'z', 'zba');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertReplaceOnce(String text, String searchString, String replacement, String expected) {
        String actual = FAP_StringUtils.replaceOnce(text, searchString, replacement);
        System.assert(actual==expected, 'FAP_StringUtils.replaceOnce(\'' + text + '\',\'' + searchString 
            + '\',\'' + replacement + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }
    
    private static testmethod void testReverse(){
        //test: global static String reverse(String str)
        assertReverse(null, null);
        assertReverse('', '');
        assertReverse('bat', 'tab');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));
    }

    private static void assertReverse(String str, String expected) {
        String actual = FAP_StringUtils.reverse(str); 
        System.assert(actual==expected, 'FAP_StringUtils.reverse(\'' + str 
            + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }
    
    private static testmethod void testReverseDelimited(){
        //test: global static String reverseDelimited(String str, String separatorChar) 
        assertReverseDelimited(null, null, null);
        assertReverseDelimited('', null, '');
        assertReverseDelimited('a.b.c', 'x', 'a.b.c');
        assertReverseDelimited('a.b.c', '.', 'c.b.a');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertReverseDelimited(String str, String separatorChar, String expected) {
        String actual = FAP_StringUtils.reverseDelimited(str, separatorChar);
        System.assert(actual==expected, 'FAP_StringUtils.reverseDelimited(\'' + str + '\',\'' + separatorChar 
            + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }
    
    private static testmethod void testRight(){
        //test: global static String right(String str, Integer len) 
        assertRight(null, 0, null);
        assertRight('abcdefg', -1, '');
        assertRight('', -1, '');
        assertRight('abc', 0, '');
        assertRight('abc', 2, 'bc');
        assertRight('abc', 4, 'abc');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertRight(String str, Integer len, String expected) {
        String actual = FAP_StringUtils.right(str, len);
        System.assert(actual==expected, 'FAP_StringUtils.right(\'' + str + '\',' + len 
            + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }
    
    private static testmethod void testSplitByCharacterTypeCamelCase(){
        //test: global static String[] splitByCharacterTypeCamelCase(String str)
        assertSplitByCharacterTypeCamelCase(null,             null);
        assertSplitByCharacterTypeCamelCase('',             new String[]{});
        assertSplitByCharacterTypeCamelCase('ab de fg',     new String[]{'ab', ' ', 'de', ' ', 'fg'});
        assertSplitByCharacterTypeCamelCase('ab   de fg',     new String[]{'ab', '   ', 'de', ' ', 'fg'});
        assertSplitByCharacterTypeCamelCase('ab:cd:ef',     new String[]{'ab', ':', 'cd', ':', 'ef'});
        assertSplitByCharacterTypeCamelCase('number5',         new String[]{'number', '5'});
        assertSplitByCharacterTypeCamelCase('fooBar',         new String[]{'foo', 'Bar'});
        assertSplitByCharacterTypeCamelCase('foo200Bar',     new String[]{'foo', '200', 'Bar'});
        assertSplitByCharacterTypeCamelCase('ASFRules',     new String[]{'ASF', 'Rules'});
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertSplitByCharacterTypeCamelCase(String str, Object[] expected) {
        FAP_ArrayUtils.AssertArraysAreEqual(expected,FAP_StringUtils.splitByCharacterTypeCamelCase(str));
    }
    
    private static testmethod void testSplitByCharacterType(){
        //test:  global static String[] splitByCharacterType(String str)
        assertSplitByCharacterType(null,             null);
        assertSplitByCharacterType('',                 new String[]{});
        assertSplitByCharacterType('ab de fg',         new String[]{'ab', ' ', 'de', ' ', 'fg'});
        assertSplitByCharacterType('ab   de fg',     new String[]{'ab', '   ', 'de', ' ', 'fg'});
        assertSplitByCharacterType('ab:cd:ef',         new String[]{'ab', ':', 'cd', ':', 'ef'});
        assertSplitByCharacterType('number5',         new String[]{'number', '5'});
        assertSplitByCharacterType('fooBar',         new String[]{'foo', 'B', 'ar'});
        assertSplitByCharacterType('foo200Bar',     new String[]{'foo', '200', 'B', 'ar'});
        assertSplitByCharacterType('ASFRules',         new String[]{'ASFR', 'ules'});
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertSplitByCharacterType(String str, Object[] expected) {
        FAP_ArrayUtils.AssertArraysAreEqual(expected,FAP_StringUtils.splitByCharacterType(str));
    }
     
    private static testmethod void testTrimToEmpty(){
        //test: global static String trimToEmpty(String str) {
        assertTrimToEmpty(null, '');
        assertTrimToEmpty('', '');
        assertTrimToEmpty('     ', '');
        assertTrimToEmpty('abc', 'abc');
        assertTrimToEmpty('    abc    ', 'abc');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertTrimToEmpty(String str, String expected) {
        String actual = FAP_StringUtils.trimToEmpty(str);
        System.assert(actual==expected, 'FAP_StringUtils.trimToEmpty(\'' + str + '\') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
    }

    private static testmethod void testTrimToNull(){
        //test:  global static String trimToNull(String str) {
        assertTrimToNull(null, null);
        assertTrimToNull('', null);
        assertTrimToNull('     ', null);
        assertTrimToNull('abc', 'abc');
        assertTrimToNull('    abc    ', 'abc');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertTrimToNull(String str, String expected) {
        String actual = FAP_StringUtils.trimToNull(str);
        System.assert(actual==expected, 'FAP_StringUtils.trimToNull(\'' + str + '\') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
    }    
    
    private static testmethod void testStripOneArg(){
        //test: global static String strip(String str)
        assertStripOneArg(null, null);
        assertStripOneArg('', '');
        assertStripOneArg('   ', '');
        assertStripOneArg('abc', 'abc');
        assertStripOneArg('  abc', 'abc');
        assertStripOneArg('abc  ', 'abc');
        assertStripOneArg(' abc ', 'abc');
        assertStripOneArg(' ab c ', 'ab c');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertStripOneArg(String str, String expected) {
        String actual = FAP_StringUtils.strip(str);
        System.assert(actual==expected, 'FAP_StringUtils.strip(\'' + str + '\') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
    }    
    
    private static testmethod void testStripToNull(){
        //test: global static String stripToNull(String str) {
        assertStripToNull(null,null);
        assertStripToNull('',null);
        assertStripToNull('   ',null);
        assertStripToNull('abc','abc');
        assertStripToNull('  abc','abc');
        assertStripToNull('abc  ','abc');
        assertStripToNull(' abc ','abc');
        assertStripToNull(' ab c ','ab c');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertStripToNull(String str, String expected) {
        String actual = FAP_StringUtils.stripToNull(str);
        System.assert(actual==expected, 'FAP_StringUtils.stripToNull(\'' + str + '\') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
    }    
    
    private static testmethod void testStripToEmpty(){
        //test: global static String stripToEmpty(String str) {
        assertStripToEmpty(null, '');
        assertStripToEmpty('', '');
        assertStripToEmpty('   ', '');
        assertStripToEmpty('abc', 'abc');
        assertStripToEmpty('  abc', 'abc');
        assertStripToEmpty('abc  ', 'abc');
        assertStripToEmpty(' abc ', 'abc');
        assertStripToEmpty(' ab c ', 'ab c');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertStripToEmpty(String str, String expected) {
        String actual = FAP_StringUtils.stripToEmpty(str);
        System.assert(actual==expected, 'FAP_StringUtils.stripToEmpty(\'' + str + '\') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
    }    

    private static testmethod void testStripTwoArgs(){
        //test: global static String strip(String str, String stripChars)
        assertStripTwoArgs(null, null, null);
        assertStripTwoArgs('', null, '');
        assertStripTwoArgs('abc', null, 'abc');
        assertStripTwoArgs('  abc', null, 'abc');
        assertStripTwoArgs('abc  ', null, 'abc');
        assertStripTwoArgs(' abc ', null, 'abc');
        assertStripTwoArgs('  abcyx', 'xyz', '  abc');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertStripTwoArgs(String str, String stripChars, String expected) {
        String actual = FAP_StringUtils.strip(str,stripChars);
        System.assert(actual==expected, 'FAP_StringUtils.strip(\'' + str + '\',\'' + stripChars + '\') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
    }   

    private static testmethod void testStripStart(){
        //test:  global static String stripStart(String str, String stripChars)
        assertStripStart(null, null, null);
        assertStripStart('', null, '');
        assertStripStart('abc', '', 'abc');
        assertStripStart('abc', null, 'abc');
        assertStripStart('  abc', null, 'abc');
        assertStripStart('abc  ', null, 'abc  ');
        assertStripStart(' abc ', null, 'abc ');
        assertStripStart('yxabc  ', 'xyz', 'abc  ');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));       
    }

    private static void assertStripStart(String str, String stripChars, String expected) {
        String actual = FAP_StringUtils.stripStart(str,stripChars);
        System.assert(actual==expected, 'FAP_StringUtils.stripStart(\'' + str + '\',\'' + stripChars 
            + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }              

    private static testmethod void testStripEnd(){
        //test: global static String stripEnd(String str, String stripChars)
        assertStripEnd(null, null, null);
        assertStripEnd('', null, '');
        assertStripEnd('abc', '', 'abc');
        assertStripEnd('abc', null, 'abc');
        assertStripEnd('  abc', null, '  abc');
        assertStripEnd('abc  ', null, 'abc');
        assertStripEnd(' abc ', null, ' abc');
        assertStripEnd('  abcyx', 'xyz', '  abc');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertStripEnd(String str, String stripChars, String expected) {
        String actual = FAP_StringUtils.stripEnd(str,stripChars);
        System.assert(actual==expected, 'FAP_StringUtils.stripEnd(\'' + str + '\', \'' + stripChars 
            + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }  

    private static testmethod void testStripAllOneArg(){
        //test: global static String[] stripAll(String[] strs)
        assertStripAllOneArg(null, null);
        assertStripAllOneArg(new String[]{}, new String[]{});
        assertStripAllOneArg(new String[]{'abc', '  abc'}, new String[]{'abc', 'abc'});
        assertStripAllOneArg(new String[]{'abc  ', null}, new String[]{'abc', null});
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertStripAllOneArg(String[] strs, String[] expected) {
        FAP_ArrayUtils.assertArraysAreEqual(expected,FAP_StringUtils.stripAll(strs));
    } 
     
    private static testmethod void testStripAllTwoArgs(){
        //test: global static String[] stripAll(String[] strs, String stripChars)
        assertStripAllTwoArgs(null, null, null);
        assertStripAllTwoArgs(new String[]{}, null, new String[]{});
        assertStripAllTwoArgs(new String[]{'abc', '  abc'}, null, new String[]{'abc', 'abc'});
        assertStripAllTwoArgs(new String[]{'abc  ', null}, null, new String[]{'abc', null});
        assertStripAllTwoArgs(new String[]{'abc  ', null}, 'yz', new String[]{'abc  ', null});
        assertStripAllTwoArgs(new String[]{'yabcz', null}, 'yz', new String[]{'abc', null});
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertStripAllTwoArgs(String[] strs, String stripChars, String[] expected) {
        FAP_ArrayUtils.assertArraysAreEqual(expected,FAP_StringUtils.stripAll(strs,stripChars));
    }
    
    private static testmethod void testSubstringBefore(){
        //test: global static String substringBefore(String str, String separator)
        assertSubstringBefore(null, null, null);
        assertSubstringBefore('', null, '');
        assertSubstringBefore('abc', 'a', '');
        assertSubstringBefore('abcba', 'b', 'a');
        assertSubstringBefore('abc', 'c', 'ab');
        assertSubstringBefore('abc', 'd', 'abc');
        assertSubstringBefore('abc', '', '');
        assertSubstringBefore('abc', null, 'abc');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertSubstringBefore(String str, String separator, String expected) {
        String actual = FAP_StringUtils.substringBefore(str,separator);
        System.assert(actual==expected, 'FAP_StringUtils.substringBefore(\'' + str + '\', \'' + separator 
            + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }  

    private static testmethod void testSubstringAfter(){
        //test: global static String substringAfter(String str, String separator)
        assertSubstringAfter(null, null, null);
        assertSubstringAfter('', null, '');
        assertSubstringAfter('asdf', null, '');
        assertSubstringAfter(null, null, null);
        assertSubstringAfter('abc', 'a', 'bc');
        assertSubstringAfter('abcba', 'b', 'cba');
        assertSubstringAfter('abc', 'c', '');
        assertSubstringAfter('abc', 'd', '');
        assertSubstringAfter('abc', '', 'abc');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertSubstringAfter(String str, String separator, String expected) {
        String actual = FAP_StringUtils.substringAfter(str,separator);
        System.assert(actual==expected, 'FAP_StringUtils.substringAfter(\'' + str + '\', \'' + separator 
            + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }  

    private static testmethod void testSubstringBeforeLast(){
        //test: global static String substringBeforeLast(String str, String separator)
        assertSubstringBeforeLast(null, null, null);
        assertSubstringBeforeLast('', null, '');
        assertSubstringBeforeLast('abcba', 'b', 'abc');
        assertSubstringBeforeLast('abc', 'c', 'ab');
        assertSubstringBeforeLast('a', 'a', '');
        assertSubstringBeforeLast('a', 'z', 'a');
        assertSubstringBeforeLast('a', null, 'a');
        assertSubstringBeforeLast('a', '', 'a');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertSubstringBeforeLast(String str, String separator, String expected) {
        String actual = FAP_StringUtils.substringBeforeLast(str,separator);
        System.assert(actual==expected, 'FAP_StringUtils.substringBeforeLast(\'' + str + '\', \'' + separator 
            + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }  

    private static testmethod void testSubstringAfterLast(){
        //test: global static String substringAfterLast(String str, String separator)
        assertSubstringAfterLast(null, null, null);
        assertSubstringAfterLast('', null, '');
        assertSubstringAfterLast('adsfa', null, '');
        assertSubstringAfterLast(null, '', null);
        assertSubstringAfterLast('abc', 'a', 'bc');
        assertSubstringAfterLast('abcba', 'b', 'a');
        assertSubstringAfterLast('abc', 'c', '');
        assertSubstringAfterLast('a', 'a', '');
        assertSubstringAfterLast('a', 'z', '');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertSubstringAfterLast(String str, String separator, String expected) {
        String actual = FAP_StringUtils.substringAfterLast(str,separator);
        System.assert(actual==expected, 'FAP_StringUtils.substringAfterLast(\'' + str + '\', \'' + separator 
            + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }  

    private static testmethod void testSubstringBetweenTwoArgs(){
        //test: global static String substringBetween(String str, String tag)
        assertSubstringBetweenTwoArgs(null, null, null);
        assertSubstringBetweenTwoArgs('', '', '');
        assertSubstringBetweenTwoArgs('', 'tag', null);
        assertSubstringBetweenTwoArgs('tagabctag', null, null);
        assertSubstringBetweenTwoArgs('tagabctag', '', '');
        assertSubstringBetweenTwoArgs('tagabctag', 'tag', 'abc');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertSubstringBetweenTwoArgs(String str, String tag, String expected) {
        String actual = FAP_StringUtils.substringBetween(str,tag);
        System.assert(actual==expected, 'FAP_StringUtils.substringBetween(\'' + str + '\', \'' + tag 
            + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }  

    private static testmethod void testSubstringBetweenThreeArgs(){
        //test: global static String substringBetween(String str, String open, String close)
        assertSubstringBetweenThreeArgs('wx[b]yz', '[', ']', 'b');
        assertSubstringBetweenThreeArgs(null, null, null, null);
        assertSubstringBetweenThreeArgs(null, null, null, null);
        assertSubstringBetweenThreeArgs(null, null, null, null);
        assertSubstringBetweenThreeArgs('', '', '', '');
        assertSubstringBetweenThreeArgs('', '', ']', null);
        assertSubstringBetweenThreeArgs('', '[', ']', null);
        assertSubstringBetweenThreeArgs('yabcz', '', '', '');
        assertSubstringBetweenThreeArgs('yabcz', 'y', 'z', 'abc');
        assertSubstringBetweenThreeArgs('yabczyabcz', 'y', 'z', 'abc');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    } 

    private static void assertSubstringBetweenThreeArgs(String str, String open, String close, String expected) {
        String actual = FAP_StringUtils.substringBetween(str,open,close);
        System.assert(actual==expected, 'FAP_StringUtils.substringBetween(\'' + str + '\',\'' + open + '\', \'' + close 
            + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }  

    private static testmethod void testSubstringsBetween(){
        //test: global static String[] substringsBetween(String str, String open, String close)
        assertSubstringsBetween('[a][b][c]', '[', ']', new String[]{'a','b','c'});
        assertSubstringsBetween(null, null, null, null);
        assertSubstringsBetween('asdf', '[', ']', null);
        assertSubstringsBetween('a[df', '[', ']', null);
        assertSubstringsBetween('', '[', ']', new String[]{});
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertSubstringsBetween(String str, String open, String close, String[] expected) {
        FAP_ArrayUtils.assertArraysAreEqual(expected, FAP_StringUtils.substringsBetween(str,open,close));
    }  

    private static testmethod void testEnsureStringStartsEndsWithChar(){
        //test: global static String ensureStringStartsEndsWithChar(String str, String charc){
        assertEnsureStringStartsEndsWithChar(null, null, null);
        assertEnsureStringStartsEndsWithChar(null, 'abc', null);
        assertEnsureStringStartsEndsWithChar('', 'abc', 'abcabc');
        assertEnsureStringStartsEndsWithChar('test123', null, 'test123');
        assertEnsureStringStartsEndsWithChar('test123', 'abc', 'abctest123abc');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertEnsureStringStartsEndsWithChar(String str, String charc, String expected) {
        String actual = FAP_StringUtils.ensureStringStartsEndsWithChar(str,charc);
        System.assert(actual==expected, 'FAP_StringUtils.ensureStringStartsEndsWithChar(\'' + str + '\', \'' + charc 
            + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }  

    private static testmethod void testToCharArray(){
        //test: global static String[] toCharArray(String str){
        FAP_ArrayUtils.assertArraysAreEqual(new String[]{},FAP_StringUtils.toCharArray(null));
        FAP_ArrayUtils.assertArraysAreEqual(new String[]{},FAP_StringUtils.toCharArray(''));
        FAP_ArrayUtils.assertArraysAreEqual(new String[]{' '},FAP_StringUtils.toCharArray(' '));
        FAP_ArrayUtils.assertArraysAreEqual(new String[]{' ',' '},FAP_StringUtils.toCharArray('  '));
        FAP_ArrayUtils.assertArraysAreEqual(new String[]{'a','b','c'},FAP_StringUtils.toCharArray('abc'));
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static testmethod void testTrimAllSet(){
        Set<String> nullSet = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullSet));
        FAP_SetUtils.assertEquals(new Set<String>{'a','b'},FAP_StringUtils.trimAll(new Set<String>{' a ',' b '}));
    }

    private static testmethod void testTrimAllList(){
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));
        FAP_ArrayUtils.assertArraysAreEqual(new List<String>{'a','b'},FAP_StringUtils.trimAll(new List<String>{' a ',' b '}));
    }


 /*   private static testmethod void testAbbreviateTwoArgs(){
        assertAbbreviateTwoArgs(null,         -1, null,         false);
        assertAbbreviateTwoArgs('',         4,     '',            false);
        assertAbbreviateTwoArgs('abcdefg',     6,     'abc...',    false);
        assertAbbreviateTwoArgs('abcdefg',     7,     'abcdefg',    false);
        assertAbbreviateTwoArgs('abcdefg',     8,     'abcdefg',     false);
        assertAbbreviateTwoArgs('abcdefg',     4,     'a...',     false);
        assertAbbreviateTwoArgs('abcdefg',     3,     null,         true);
    }    
   */  
    private static void assertAbbreviateTwoArgs(String str, Integer maxWidth, 
        String expected, Boolean excepExpected){

        String actual = null;
        Boolean excepActual = false;
        try{
            actual = FAP_StringUtils.abbreviate(str,maxWidth);
        } catch (FAP_IllegalArgumentException e){
            excepActual = true;
        }
        if(excepExpected && excepActual){
            return;
        }
        System.assert(excepExpected == excepActual, 'FAP_StringUtils.abbreviate(\'' 
            + str + '\',' + maxWidth + ') ' 
            + (excepExpected ? 'did not throw' : 'unexpectedly threw') 
            + ' IllegalArgumentException');
        if(!excepExpected && !excepActual){
            System.assert(actual==expected, 'FAP_StringUtils.abbreviate(\'' + str + '\',' 
                + maxWidth + ') returned ' + actual + '; expected ' + expected);
        }
    }
    
 /*   private static testmethod void testAbbreviateThreeArgs(){
        assertAbbreviateThreeArgs(null,                 -1,    -1,     null,             false);
        assertAbbreviateThreeArgs('',                     0,     4,         '',                false);
        assertAbbreviateThreeArgs('abcdefghijklmno',    -1, 10,     'abcdefg...',    false);
        assertAbbreviateThreeArgs('abcdefghijklmno',     0,     10,     'abcdefg...',    false);
        assertAbbreviateThreeArgs('abcdefghijklmno',     1,     10,     'abcdefg...',    false);
        assertAbbreviateThreeArgs('abcdefghijklmno',     4,     10,     'abcdefg...',    false);
        assertAbbreviateThreeArgs('abcdefghijklmno',     5,     10,     '...fghi...',    false);
        assertAbbreviateThreeArgs('abcdefghijklmno',     6,     10,     '...ghij...',    false);
        assertAbbreviateThreeArgs('abcdefghijklmno',     8,     10,     '...ijklmno',    false);
        assertAbbreviateThreeArgs('abcdefghijklmno',     10, 10,     '...ijklmno',    false);
        assertAbbreviateThreeArgs('abcdefghijklmno',     12, 10,     '...ijklmno',    false);
        assertAbbreviateThreeArgs('abcdefghijklmno',     20, 10,     '...ijklmno',    false);
        assertAbbreviateThreeArgs('abcdefghij',         0,     3,        null,            true);
        assertAbbreviateThreeArgs('abcdefghij',         5,     6,        null,            true);
    }    
   */ 
    private static void assertAbbreviateThreeArgs(String str, Integer offset, Integer maxWidth, 
        String expected, Boolean excepExpected){

        String actual = null;
        Boolean excepActual = false;
        try{
            actual = FAP_StringUtils.abbreviate(str,offset,maxWidth);
        } catch (FAP_IllegalArgumentException e){
            excepActual = true;
        }
        if(excepExpected && excepActual){
            return;
        }
        System.assert(excepExpected == excepActual, 'FAP_StringUtils.abbreviate(\'' 
            + str + '\',' + offset + ',' + maxWidth + ') ' 
            + (excepExpected ? 'did not throw' : 'unexpectedly threw') 
            + ' IllegalArgumentException');
        if(!excepExpected && !excepActual){
            System.assert(actual==expected, 'FAP_StringUtils.abbreviate(\'' + str + '\',' 
                + offset + ',' + maxWidth + ') returned ' + actual + '; expected ' + expected);
        }
    }
 
    private static testmethod void testIndexOfAny(){
        //test: global static int indexOfAny(String str, String searchChars) {
        assertIndexOfAny(null, null, -1);
        assertIndexOfAny('', null, -1);
        assertIndexOfAny(null, '', -1);
        assertIndexOfAny('zzabyycdxx', 'za', 0);
        assertIndexOfAny('zzabyycdxx', 'by', 3);
        assertIndexOfAny('aba','z', -1);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));       
    }    
    
    private static void assertIndexOfAny(String str, String searchChars, Integer expected){
        Integer actual = FAP_StringUtils.indexOfAny(str,searchChars);
        System.assert(actual==expected, 'FAP_StringUtils.indexOfAny(\'' + str + '\',' 
            + searchChars + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }
    
     private static testmethod void testLastIndexOfAny(){
        //test: global static Integer lastIndexOfAny(String str, String[] searchStrs) {
        assertLastIndexOfAny(null, null, -1);
        assertLastIndexOfAny('', null, -1);
        assertLastIndexOfAny(null, new String[]{}, -1);
        assertLastIndexOfAny(null, new String[]{null}, -1);
        assertLastIndexOfAny('', new String[]{null}, -1);
        assertLastIndexOfAny('zzabyycdxx', new String[]{'ab','cd'}, 6);
        assertLastIndexOfAny('zzabyycdxx', new String[]{'cd','ab'}, 6);
        assertLastIndexOfAny('zzabyycdxx', new String[]{'mn','op'}, -1);
        assertLastIndexOfAny('zzabyycdxx', new String[]{'mn','op'}, -1);
        assertLastIndexOfAny('zzabyycdxx', new String[]{'mn',''}, 10);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));         
    }
    
    private static void assertLastIndexOfAny(String str, String[] searchStrs, Integer expected){
        Integer actual = FAP_StringUtils.lastIndexOfAny(str,searchStrs);
        System.assert(actual==expected, 'FAP_StringUtils.lastIndexOfAny(\'' + str + '\',' 
            + FAP_ArrayUtils.toString(searchStrs) + ') returned ' + actual + '; expected ' + expected);
    }
    
    private static testmethod void testLastIndexOfTwoArgs(){
        //test: global static Integer lastIndexOf(String str, String searchStr) {
        assertLastIndexOfTwoArgs(null, '', -1);
        assertLastIndexOfTwoArgs('', null, -1);
        assertLastIndexOfTwoArgs('', '', 0);
        assertLastIndexOfTwoArgs('aabaabaa', 'a', 7);
        assertLastIndexOfTwoArgs('aabaabaa', 'b', 5);
        assertLastIndexOfTwoArgs('aabaabaa', 'ab', 4);
        assertLastIndexOfTwoArgs('aabaabaa', '', 8);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertLastIndexOfTwoArgs(String str, String searchStr, Integer expected){
        Integer actual = FAP_StringUtils.lastIndexOf(str,searchStr);
        System.assert(actual==expected, 'FAP_StringUtils.lastIndexOf(\'' + str + '\',\'' 
            + searchStr + '\') returned ' + actual + '; expected ' + expected);
    }
    
    private static testmethod void testLastIndexOfThreeArgs(){
        //test: global static Integer lastIndexOf(String str, String searchStr, Integer startPos) {
        assertLastIndexOfThreeArgs(null, null, -1, -1);
        assertLastIndexOfThreeArgs('', null, -1, -1);
        assertLastIndexOfThreeArgs('aabaabaa', 'a', 8, 7);
        assertLastIndexOfThreeArgs('aabaabaa', 'b', 8, 5);
        assertLastIndexOfThreeArgs('aabaabaa', 'ab', 8, 4);
        assertLastIndexOfThreeArgs('aabaabaa', 'b', 9, 5);
        assertLastIndexOfThreeArgs('aabaabaa', 'b', -1, -1);
        assertLastIndexOfThreeArgs('aabaabaa', 'a', 0, 0);
        assertLastIndexOfThreeArgs('aabaabaa', 'b', 0, -1);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }
    
    private static void assertLastIndexOfThreeArgs(String str, String searchStr, Integer startPos, Integer expected){
        Integer actual = FAP_StringUtils.lastIndexOf(str,searchStr,startPos);
        System.assert(actual==expected, 'FAP_StringUtils.lastIndexOf(\'' + str + '\',\'' 
            + searchStr + '\',' + startPos + ') returned ' + actual + '; expected ' + expected);
    }
    
    private static testmethod void testIndexOfAnyStringArray(){
        //test: global static Integer indexOfAny(String str, String[] searchStrs) {
        assertIndexOfAnyStringArray(null, null, -1);
        assertIndexOfAnyStringArray(null, new String[]{}, -1);
        assertIndexOfAnyStringArray('zzabyycdxx', new String[]{null}, -1);
        assertIndexOfAnyStringArray('zzabyycdxx', new String[]{'ab','cd'}, 2);
        assertIndexOfAnyStringArray('zzabyycdxx', new String[]{'cd','ab'}, 2);
        assertIndexOfAnyStringArray('zzabyycdxx', new String[]{'mn','op'}, -1);
        assertIndexOfAnyStringArray('zzabyycdxx', new String[]{'zab','aby'}, 1);
        assertIndexOfAnyStringArray('zzabyycdxx', new String[]{''}, 0);
        assertIndexOfAnyStringArray('', new String[]{''}, 0);
        assertIndexOfAnyStringArray('', new String[]{'a'}, -1);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertIndexOfAnyStringArray(String str, String[] searchStrs, Integer expected){
        Integer actual = FAP_StringUtils.indexOfAny(str,searchStrs);
        System.assert(actual==expected, 'FAP_StringUtils.indexOfAny(\'' + str + '\',' 
            + FAP_ArrayUtils.toString(searchStrs) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }

    private static testmethod void testCenterTwoArgs(){
        assertCenterTwoArgs(null,     -1,    null);
        assertCenterTwoArgs('',     4,    '    ');
        assertCenterTwoArgs('ab',     -1,    'ab');
        assertCenterTwoArgs('ab',     4,    ' ab ');
        assertCenterTwoArgs('abcd', 2,    'abcd');
        assertCenterTwoArgs('a',     4,    ' a  ');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertCenterTwoArgs(String str, Integer size, String expected){
        String actual = FAP_StringUtils.center(str,size);
        System.assert(actual==expected, 'FAP_StringUtils.center(\'' + str + '\',' 
            + size + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }
    
    private static testmethod void testChompOneArg(){
        assertChompOneArg(null,                null);
        assertChompOneArg('',                '');
        assertChompOneArg('abc \r',            'abc ');
        assertChompOneArg('abc\n',            'abc');
        assertChompOneArg('abc\r\n',        'abc');
        assertChompOneArg('abc\r\n\r\n',    'abc\r\n');
        assertChompOneArg('abc\n\r',        'abc\n');
        assertChompOneArg('abc\n\rabc',        'abc\n\rabc');
        assertChompOneArg('\t',                '\t');
        assertChompOneArg('\r',                '');
        assertChompOneArg('\n',                '');
        assertChompOneArg('\r\n',            '');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertChompOneArg(String str, String expected){
        String actual = FAP_StringUtils.chomp(str);
        System.assert(actual==expected, 'FAP_StringUtils.chomp(\'' + str + '\') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
    }
    
    private static testmethod void testChompTwoArgs(){
        assertChompTwoArgs(null,         null,         null);
        assertChompTwoArgs('',             null,         '');
        assertChompTwoArgs('foobar',     'bar',         'foo');
        assertChompTwoArgs('foobar',     'baz',         'foobar');
        assertChompTwoArgs('foo',        'foo',         '');
        assertChompTwoArgs('foo ',         'foo',         'foo ');
        assertChompTwoArgs(' foo',         'foo',         ' ');
        assertChompTwoArgs('foo',         'foooo',     'foo');
        assertChompTwoArgs('foo',         '',         'foo');
        assertChompTwoArgs('foo',         null,         'foo');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertChompTwoArgs(String str, String separator, String expected){
        String actual = FAP_StringUtils.chomp(str,separator);
        System.assert(actual==expected, 'FAP_StringUtils.chomp(\'' + str + '\', \'' + separator + '\') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
    }
    
    
    private static testmethod void testCenterThreeArgs(){
        assertCenterThreeArgs(null,     -1, null,     null);
        assertCenterThreeArgs('',         4,     ' ',     '    ');
        assertCenterThreeArgs('ab',     -1, ' ',     'ab');
        assertCenterThreeArgs('ab',     4,     ' ',     ' ab ');
        assertCenterThreeArgs('abcd',     2,     ' ',     'abcd');
        assertCenterThreeArgs('a',         4,     ' ',     ' a  ');
        assertCenterThreeArgs('a',         4,     'yz',     'yayz');
        assertCenterThreeArgs('abc',     7,     null,     '  abc  ');
        assertCenterThreeArgs('abc',     7,     '',     '  abc  ');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertCenterThreeArgs(String str, Integer size, String padStr, String expected){
        String actual = FAP_StringUtils.center(str,size, padStr);
        System.assert(actual==expected, 'FAP_StringUtils.center(\'' + str + '\',' 
            + size + ',\'' + padStr + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }
    
    private static testmethod void testChop(){
        assertChop(null,        null);
        assertChop('',             '');
        assertChop('abc \r',     'abc ');
        assertChop('abc\n',     'abc');
        assertChop('abc\r\n',     'abc');
        assertChop('abc',         'ab');
        assertChop('abc\nabc',     'abc\nab');
        assertChop('a',         '');
        assertChop('\r',         '');
        assertChop('\n',         '');
        assertChop('\r\n',         '');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertChop(String str, String expected){
        String actual = FAP_StringUtils.chop(str);
        System.assert(actual==expected, 'FAP_StringUtils.chop(\'' + str + '\') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
    }
    
    private static testmethod void testContainsAny(){
        assertContainsAny(null,         null,     false);
        assertContainsAny('',             null,     false);
        assertContainsAny(null,         null,     false);
        assertContainsAny(null,         '',     false);
        assertContainsAny('zzabyycdxx', 'za',     true);
        assertContainsAny('zzabyycdxx', 'by',     true);
        assertContainsAny('aba',        'z',     false);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertContainsAny(String str, String searchChars, Boolean expected){
        Boolean actual = FAP_StringUtils.containsAny(str,searchChars);
        System.assert(actual==expected, 'FAP_StringUtils.containsAny(\'' + str + '\',\'' + searchChars + '\') returned ' 
            + actual);
    }
    
    
    private static testmethod void testContainsNone(){
        //test: global static boolean containsNone(String str, String invalidChars) {
        assertContainsNone(null,     null,     true);
        assertContainsNone(null,     null,     true);
        assertContainsNone('',         null,     true);
        assertContainsNone('ab',     '',     true);
        assertContainsNone('abab',     'xyz',     true);
        assertContainsNone('ab1',     'xyz',     true);
        assertContainsNone('abz',     'xyz',     false);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertContainsNone(String str, String invalidChars, Boolean expected){
        Boolean actual = FAP_StringUtils.containsNone(str,invalidChars);
        System.assert(actual==expected, 'FAP_StringUtils.containsNone(\'' + str + '\',\'' + invalidChars + '\') returned ' 
            + actual);
    }
    
    private static testmethod void testContainsOnly(){
        //test: global static boolean containsOnly(String str, String valid) {
        assertContainsOnly(null,     null,    false);
        assertContainsOnly(null,     null,    false);
        assertContainsOnly('',         null,    false);
        assertContainsOnly('',         '',        true);
        assertContainsOnly('ab',     '',        false);
        assertContainsOnly('abab',     'abc',    true);
        assertContainsOnly('ab1',     'abc',    false);
        assertContainsOnly('abz',     'abc',     false);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertContainsOnly(String str, String valid, Boolean expected){
        Boolean actual = FAP_StringUtils.containsOnly(str,valid);
        System.assert(actual==expected, 'FAP_StringUtils.containsOnly(\'' + str + '\',\'' + valid + '\') returned ' 
            + actual);
    }
    
    private static testmethod void testCountMatches(){
        //test: global static Integer countMatches(String str, String sub) {
        assertCountMatches(null, null, 0);
        assertCountMatches('', null, 0);
        assertCountMatches('abba', null, 0);
        assertCountMatches('abba', '', 0);
        assertCountMatches('abba', 'a', 2);
        assertCountMatches('abba', 'ab', 1);
        assertCountMatches('abba', 'xxx', 0);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertCountMatches(String str, String sub, Integer expected){
        Integer actual = FAP_StringUtils.countMatches(str,sub);
        System.assert(actual==expected, 'FAP_StringUtils.countMatches(\'' + str + '\',\'' + sub + '\') returned ' 
            + actual + '; expected ' + expected);
    }

    private static testmethod void testDefaultIfEmpty(){
        //test: global static String defaultIfEmpty(String str, String defaultStr) {
        assertDefaultIfEmpty(null, 'NULL', 'NULL');
        assertDefaultIfEmpty('', 'NULL', 'NULL');
        assertDefaultIfEmpty('bat', 'NULL', 'bat');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertDefaultIfEmpty(String str, String defaultStr, String expected){
        String actual = FAP_StringUtils.defaultIfEmpty(str,defaultStr);
        System.assert(actual==expected, 'FAP_StringUtils.defaultIfEmpty(\'' + str + '\',\'' + defaultStr + '\') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
    }
    
    private static testmethod void testDefaultStringOneArg(){
        //test: global static String defaultString(String str) {
        assertDefaultStringOneArg(null, '');
        assertDefaultStringOneArg('', '');
        assertDefaultStringOneArg('bat', 'bat');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertDefaultStringOneArg(String str, String expected){
        String actual = FAP_StringUtils.defaultString(str);
        System.assert(actual==expected, 'FAP_StringUtils.defaultString(\'' + str + '\') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
    }
    
    private static testmethod void testDefaultStringTwoArgs(){
        //test: global static String defaultString(String str, String defaultStr) {
        assertDefaultStringTwoArgs(null, 'NULL', 'NULL');
        assertDefaultStringTwoArgs('', 'NULL', '');
        assertDefaultStringTwoArgs('bat', 'NULL', 'bat');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertDefaultStringTwoArgs(String str, String defaultStr, String expected){
        String actual = FAP_StringUtils.defaultString(str,defaultStr);
        System.assert(actual==expected, 'FAP_StringUtils.defaultString(\'' + str + '\',\'' + defaultStr + '\') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
    }
    

    private static testmethod void testDeleteWhitespace(){
        //test: global static String deleteWhitespace(String str) {
        assertDeleteWhitespace(null,             null);
        assertDeleteWhitespace('',                 '');
        assertDeleteWhitespace('abc',             'abc');
        assertDeleteWhitespace('   ab  c  ',     'abc');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertDeleteWhitespace(String str, String expected){
        String actual = FAP_StringUtils.deleteWhitespace(str);
        System.assert(actual==expected, 'FAP_StringUtils.deleteWhitespace(\'' + str + '\') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
    }

    private static testmethod void testDifference(){
        //test: global static String difference(String str1, String str2) {
        assertDifference(null,         null,         null);
        assertDifference('',         null,         '');
        assertDifference('',         '',         '');
        assertDifference('',         'abc',         'abc');
        assertDifference('abc',     '',         '');
        assertDifference('abc',     'abc',         '');
        assertDifference('ab',         'abxyz',     'xyz');
        assertDifference('abcde',     'abxyz',    'xyz');
        assertDifference('abcde',     'xyz',         'xyz');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertDifference(String str1, String str2, String expected){
        String actual = FAP_StringUtils.difference(str1,str2);
        System.assert(actual==expected, 'FAP_StringUtils.difference(\'' + str1 + '\',\'' + str2 + '\') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
    }



    private static testmethod void testEquals(){
        //test: global static Boolean equals(String str1, String str2) {
        assertEquals(null,     null,     true);
        assertEquals(null,     'abc',     false);
        assertEquals('abc', null,     false);
        assertEquals('abc', 'abc',     true);
        assertEquals('abc', 'ABC',     false);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertEquals(String str1, String str2, Boolean expected){
        Boolean actual = FAP_StringUtils.equals(str1,str2); 
        System.assert(actual==expected, 'FAP_StringUtils.equals(\'' + str1 + '\',\'' + str2 + '\') returned ' + actual);
    }

    private static testmethod void testEqualsIgnoreCase(){
        //test: global static Boolean equalsIgnoreCase(String str1, String str2) {
        assertEqualsIgnoreCase(null,     null,     true);
        assertEqualsIgnoreCase(null,     'abc',     false);
        assertEqualsIgnoreCase('abc',     null,     false);
        assertEqualsIgnoreCase('abc',     'abc',     true);
        assertEqualsIgnoreCase('abc',     'ABC',     true);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertEqualsIgnoreCase(String str1, String str2, Boolean expected){
        Boolean actual = FAP_StringUtils.equalsIgnoreCase(str1,str2);
        System.assert(actual==expected, 'FAP_StringUtils.equalsIgnoreCase(\'' + str1 + '\',\'' + str2 + '\') returned ' + actual);
    }

    private static testmethod void testIndexOf(){
        //test: global static Integer indexOf(String str, String searchStr) {
        assertIndexOf(null,         null,     -1);
        assertIndexOf('',             null,     -1);
        assertIndexOf('aabaabaa',     'a',     0);
        assertIndexOf('aabaabaa',     'b',    2);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
     }    
    
    private static void assertIndexOf(String str1, String searchStr, Integer expected){
        Integer actual = FAP_StringUtils.indexOf(str1,searchStr);
        System.assert(actual==expected, 'FAP_StringUtils.indexOf(\'' + str1 + '\',\'' + searchStr + '\') returned ' 
            + actual + '; expected ' + expected);
    }

    private static testmethod void testIndexOfDifference(){
        //test: global static Integer indexOfDifference(String str1, String str2) {
        assertIndexOfDifference(null,         null,         -1);
        assertIndexOfDifference(null,         '',         0);
        assertIndexOfDifference('',         null,         0);
        assertIndexOfDifference('',         '',         -1);
        assertIndexOfDifference('',         'abc',         0);
        assertIndexOfDifference('abc',         '',         0);
        assertIndexOfDifference('abc',         'abc',         -1);
        assertIndexOfDifference('ab',         'abxyz',     2);
        assertIndexOfDifference('abcde',     'abxyz',     2);
        assertIndexOfDifference('abcde',     'xyz',         0);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertIndexOfDifference(String str1, String str2, Integer expected){
        Integer actual = FAP_StringUtils.indexOfDifference(str1,str2);
        System.assert(actual==expected, 'FAP_StringUtils.indexOfDifference(\'' + str1 + '\',\'' + str2 + '\') returned ' 
            + actual + '; expected ' + expected);
    }
    
    private static testmethod void testIndexOfAnyBut(){
        //test: global static int indexOfAnyBut(String str, String searchChars) {
        assertIndexOfAnyBut(null,             null,    -1);
        assertIndexOfAnyBut('',             null,    -1);
        assertIndexOfAnyBut(null,             null,    -1);
        assertIndexOfAnyBut(null,             '',        -1);
        assertIndexOfAnyBut('zzabyycdxx',     'za',    3);
        assertIndexOfAnyBut('zzabyycdxx',     '',        0);
        assertIndexOfAnyBut('aba',            'ab',    -1);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertIndexOfAnyBut(String str, String searchChars, Integer expected){
        Integer actual = FAP_StringUtils.indexOfAnyBut(str,searchChars);
        System.assert(actual==expected, 'FAP_StringUtils.indexOfAnyBut(\'' + str + '\',\'' + searchChars + '\') returned ' 
            + actual + '; expected ' + expected);
    }
    
    private static testmethod void testLowerCase(){
        assertLowerCase(null, null);
        assertLowerCase('ABC', 'abc');
        assertLowerCase('abc', 'abc');
        assertLowerCase('aBc', 'abc');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertLowerCase(String str, String expected){
        String actual = FAP_StringUtils.lowerCase(str);
        System.assert(actual==expected, 'FAP_StringUtils.lowerCase(\'' + str + '\') returned ' + actual);
    }
    
    private static testmethod void testUpperCase(){
        assertUpperCase(null, null);
        assertUpperCase('ABC', 'ABC');
        assertUpperCase('abc', 'ABC');
        assertUpperCase('aBc', 'ABC');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertUpperCase(String str, String expected){
        String actual = FAP_StringUtils.upperCase(str);
        System.assert(actual==expected, 'FAP_StringUtils.upperCase(\'' + str + '\') returned ' + actual);
    }
    
    private static testmethod void testCapitalize(){
        assertCapitalize(null, null);
        assertCapitalize('ABC', 'ABC');
        assertCapitalize('abc', 'Abc');
        assertCapitalize('aBc', 'ABc');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertCapitalize(String str, String expected){
        String actual = FAP_StringUtils.capitalize(str);
        System.assert(actual==expected, 'FAP_StringUtils.capitalize(\'' + str + '\') returned ' + actual);
    }
    
    private static testmethod void testUncapitalize(){
        assertUncapitalize(null, null);
        assertUncapitalize('ABC', 'aBC');
        assertUncapitalize('abc', 'abc');
        assertUncapitalize('aBc', 'aBc');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertUncapitalize(String str, String expected){
        String actual = FAP_StringUtils.uncapitalize(str);
        System.assert(actual==expected, 'FAP_StringUtils.uncapitalize(\'' + str + '\') returned ' + actual);
    }
    
    private static testmethod void testSwapCase(){
        assertSwapCase(null, null);
        assertSwapCase('', '');
        assertSwapCase('The dog has a BONE', 'tHE DOG HAS A bone');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertSwapCase(String str, String expected){
        String actual = FAP_StringUtils.swapCase(str);
        System.assert(actual==expected, 'FAP_StringUtils.swapCase(\'' + str + '\') returned ' + actual);
    }
    
    private static testmethod void testIsEmpty(){
        assertIsEmpty(null,     true);
        assertIsEmpty('',        true);
        assertIsEmpty(' ',        false);
        assertIsEmpty('bob',    false);
        assertIsEmpty('  bob  ',false);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertIsEmpty(String str, Boolean expected){
        Boolean actual = FAP_StringUtils.IsEmpty(str);
        System.assert(actual==expected, 'FAP_StringUtils.IsEmpty(\'' + str + '\') returned ' + actual);
    }
    
    private static testmethod void testIsNotEmpty(){
        assertIsNotEmpty(null,         false);
        assertIsNotEmpty('',        false);
        assertIsNotEmpty(' ',        true);
        assertIsNotEmpty('bob',        true);
        assertIsNotEmpty('  bob  ',    true);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertIsNotEmpty(String str, Boolean expected){
        Boolean actual = FAP_StringUtils.IsNotEmpty(str);
        System.assert(actual==expected, 'FAP_StringUtils.IsNotEmpty(\'' + str + '\') returned ' + actual);
    }

    private static testmethod void testIsAlpha(){
        //test: global static boolean isAlpha(String str) {
        assertIsAlpha(null, false);
        assertIsAlpha('', true);
        assertIsAlpha('  ', false);
        assertIsAlpha('abc', true);
        assertIsAlpha('ab2c', false);
        assertIsAlpha('ab-c', false);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertIsAlpha(String str, Boolean expected){
        Boolean actual = FAP_StringUtils.isAlpha(str);
        System.assert(actual==expected, 'FAP_StringUtils.isAlpha(\'' + str + '\') returned ' + actual);
    }

    private static testmethod void testIsAlphaSpace(){
        //test: global static boolean isAlphaSpace(String str) {
        assertIsAlphaSpace(null, false);
        assertIsAlphaSpace('', true);
        assertIsAlphaSpace('  ', true);
        assertIsAlphaSpace('abc', true);
        assertIsAlphaSpace('ab c', true);
        assertIsAlphaSpace('ab2c', false);
        assertIsAlphaSpace('ab-c', false);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertIsAlphaSpace(String str, Boolean expected){
        Boolean actual = FAP_StringUtils.isAlphaSpace(str);
        System.assert(actual==expected, 'FAP_StringUtils.isAlphaSpace(\'' + str + '\') returned ' + actual);
    }

    private static testmethod void testIsAlphanumeric(){
        //test: global static boolean isAlphanumeric(String str) {
        assertIsAlphanumeric(null, false);
        assertIsAlphanumeric('', true);
        assertIsAlphanumeric('  ', false);
        assertIsAlphanumeric('abc', true);
        assertIsAlphanumeric('ab c', false);
        assertIsAlphanumeric('ab2c', true);
        assertIsAlphanumeric('ab-c', false);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertIsAlphanumeric(String str, Boolean expected){
        Boolean actual = FAP_StringUtils.isAlphanumeric(str);
        System.assert(actual==expected, 'FAP_StringUtils.isAlphanumeric(\'' + str + '\') returned ' + actual);
    }

    private static testmethod void testIsAlphanumericSpace(){
        //test: global static boolean isAlphanumericSpace(String str) {
        assertIsAlphanumericSpace(null, false);
        assertIsAlphanumericSpace('', true);
        assertIsAlphanumericSpace('  ', true);
        assertIsAlphanumericSpace('abc', true);
        assertIsAlphanumericSpace('ab c', true);
        assertIsAlphanumericSpace('ab2c', true);
        assertIsAlphanumericSpace('ab-c', false);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertIsAlphanumericSpace(String str, Boolean expected){
        Boolean actual = FAP_StringUtils.isAlphanumericSpace(str);
        System.assert(actual==expected, 'FAP_StringUtils.isAlphanumericSpace(\'' + str + '\') returned ' + actual);
    }

    private static testmethod void testIsAsciiPrintable(){
        //test: global static boolean isAsciiPrintable(String str) {
        assertIsAsciiPrintable(null, false);
        assertIsAsciiPrintable('', true);
        assertIsAsciiPrintable(' ', true);
        assertIsAsciiPrintable('Ceki', true);
        assertIsAsciiPrintable('ab2c', true);
        assertIsAsciiPrintable('!ab-c~', true);
        assertIsAsciiPrintable(' ', true);
        assertIsAsciiPrintable('!', true);
        assertIsAsciiPrintable('~', true);
        assertIsAsciiPrintable('', false);
        assertIsAsciiPrintable('Ceki Gülcü', false);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertIsAsciiPrintable(String str, Boolean expected){
        Boolean actual = FAP_StringUtils.isAsciiPrintable(str);
        System.assert(actual==expected, 'FAP_StringUtils.isAsciiPrintable(\'' + str + '\') returned ' + actual);
    }

    private static testmethod void testIsNumeric(){
        //test: global static boolean isNumeric(String str) {
        assertIsNumeric(null, false);
        assertIsNumeric('', true);
        assertIsNumeric('  ', false);
        assertIsNumeric('123', true);
        assertIsNumeric('12 3', false);
        assertIsNumeric('ab2c', false);
        assertIsNumeric('12-3', false);
        assertIsNumeric('12.3', false);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertIsNumeric(String str, Boolean expected){
        Boolean actual = FAP_StringUtils.isNumeric(str);
        System.assert(actual==expected, 'FAP_StringUtils.isNumeric(\'' + str + '\') returned ' + actual);
    }

    private static testmethod void testIsNumericSpace(){
        //test: global static boolean isNumericSpace(String str) {
        assertIsNumericSpace(null, false);
        assertIsNumericSpace('', true);
        assertIsNumericSpace('  ', true);
        assertIsNumericSpace('123', true);
        assertIsNumericSpace('12 3', true);
        assertIsNumericSpace('ab2c', false);
        assertIsNumericSpace('12-3', false);
        assertIsNumericSpace('12.3', false);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertIsNumericSpace(String str, Boolean expected){
        Boolean actual = FAP_StringUtils.isNumericSpace(str);
        System.assert(actual==expected, 'FAP_StringUtils.isNumericSpace(\'' + str + '\') returned ' + actual);
    }

    private static testmethod void testIsWhitespace(){
        //test: global static boolean isWhitespace(String str) {
        assertIsWhitespace(null, false);
        assertIsWhitespace('', true);
        assertIsWhitespace('  ', true);
        assertIsWhitespace('abc', false);
        assertIsWhitespace('ab2c', false);
        assertIsWhitespace('ab-c', false);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertIsWhitespace(String str, Boolean expected){
        Boolean actual = FAP_StringUtils.isWhitespace(str);
        System.assert(actual==expected, 'FAP_StringUtils.isWhitespace(\'' + str + '\') returned ' + actual);
    }

    private static testmethod void testLength(){
        assertLength(null,         0);
        assertLength('',        0);
        assertLength(' ',        1);
        assertLength('bob',        3);
        assertLength('  bob  ',    7);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertLength(String str, Integer expected){
        Integer actual = FAP_StringUtils.length(str);
        System.assert(actual==expected, 'FAP_StringUtils.length(\'' + str + '\') returned ' + actual);
    }

    private static testmethod void testIsBlank(){
        assertOnIsBlank(true, null);
        assertOnIsBlank(true, '');
        assertOnIsBlank(true, '     ');
        assertOnIsBlank(true, '\n');
        assertOnIsBlank(false, 'x');
        assertOnIsBlank(false, ' x');
        assertOnIsBlank(false, 'asdfasdfasdf ');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }
    
    private static void assertOnIsBlank(Boolean expectedReturnValue, String theString){
        System.assert(FAP_StringUtils.isBlank(theString)==expectedReturnValue,
            'FAP_StringUtils.isBlank(\'' + (theString == null ? 'null' : theString) + '\') returned ' + !expectedReturnValue);
    }

    private static testmethod void testIsNotBlank(){
        assertOnIsNotBlank(false, null);
        assertOnIsNotBlank(false, '');
        assertOnIsNotBlank(false, '     ');
        assertOnIsNotBlank(false, '\n');
        assertOnIsNotBlank(true, 'x');
        assertOnIsNotBlank(true, ' x');
        assertOnIsNotBlank(true, 'asdfasdfasdf ');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }
    
    private static void assertOnIsNotBlank(Boolean expectedReturnValue, String theString){
        System.assert(FAP_StringUtils.isNotBlank(theString)==expectedReturnValue,
            'FAP_StringUtils.isNotBlank(\'' + (theString == null ? 'null' : theString) + '\') returned ' + !expectedReturnValue);
    }
    
    private static testmethod void testTrim(){
        assertTrim(null, null);
        assertTrim('', '');
        assertTrim('a', 'a');
        assertTrim('\n', '');
        assertTrim('   ', '');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }
    
    private static void assertTrim(String str, String expected){
        String actual = FAP_StringUtils.trim(str);
        System.assert(actual==expected, 'FAP_StringUtils.trim(\'' + str + '\') returned [' + actual + '], expected [' + expected + ']');
    }
     
    
    
    private static testmethod void testJoinStrings(){
        assertJoinStrings(null, null, null);
        assertJoinStrings(new Set<String>(), ':', null);
        assertJoinStrings(new Set<String>{'a','b','c'}, ':', 'a:c:b');
        assertJoinStrings(new Set<String>{' ','b','c'}, ':', 'c:b');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertJoinStrings(Set<String> strings, String separator, String expectedReturnValue){
        String actual = FAP_StringUtils.joinStrings(strings,separator);
        if(strings == null || strings.size() <= 0){
            System.assert(FAP_StringUtils.isBlank(expectedReturnValue), 'FAP_StringUtils.joinStrings(Set<String>, \'' + (separator == null ? 'null' : separator) + '\') returned ' + actual);
            return;
        }
        Set<String> actualAsSet = new Set<String>(FAP_StringUtils.split(actual,separator));
        Set<String> expectedAsSet = new Set<String>(FAP_StringUtils.split(expectedReturnValue,separator));
        System.assert(actualAsSet.containsAll(expectedAsSet) && expectedAsSet.containsAll(actualAsSet),
            'FAP_StringUtils.joinStrings(Set<String>, \'' + (separator == null ? 'null' : separator) + '\') returned ' + 
                actual + '; expected: ' + expectedReturnValue);
    }
    
    
    private static testmethod void testJoinStringsList(){
        assertJoinStringsList(null, null, null);
        assertJoinStringsList(new List<String>(), ':', null);
        assertJoinStringsList(new List<String>{'a','b','c'}, ':', 'a:c:b');
        assertJoinStringsList(new List<String>{' ','b','c'}, ':', 'c:b');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertJoinStringsList(List<String> strings, String separator, String expectedReturnValue){
        String actual = FAP_StringUtils.joinStrings(strings,separator);
        if(strings == null || strings.size() <= 0){
            System.assert(FAP_StringUtils.isBlank(expectedReturnValue), 'FAP_StringUtils.joinStrings(List<String>, \'' + (separator == null ? 'null' : separator) + '\') returned ' + actual);
            return;
        }
        Set<String> actualAsSet = new Set<String>(FAP_StringUtils.split(actual,separator));
        Set<String> expectedAsSet = new Set<String>(FAP_StringUtils.split(expectedReturnValue,separator));
        System.assert(actualAsSet.containsAll(expectedAsSet) && expectedAsSet.containsAll(actualAsSet),
            'FAP_StringUtils.joinStrings(List<String>, \'' + (separator == null ? 'null' : separator) + '\') returned ' + 
                actual + '; expected: ' + expectedReturnValue);
    }
    
    private static testmethod void testEndsWith(){
        assertEndsWith(null, null, true);
        assertEndsWith('abcdef', null, false);
        assertEndsWith(null, 'def', false);
        assertEndsWith('abcdef', 'def', true);
        assertEndsWith('ABCDEF', 'def', false);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static testmethod void testEndsWithIgnoreCase(){
        assertEndsWithIgnoreCase(null, null, true);
        assertEndsWithIgnoreCase('abcdef', null, false);
        assertEndsWithIgnoreCase(null, 'def', false);
        assertEndsWithIgnoreCase('abcdef', 'def', true);
        assertEndsWithIgnoreCase('ABCDEF', 'def', true);
        assertEndsWithIgnoreCase('ABCDEF', 'ABCDEFA', false);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertEndsWith(String str, String suffix, Boolean expected){
        Boolean actual = FAP_StringUtils.endsWith(str,suffix);
        System.assert(actual==expected, 'FAP_StringUtils.endsWith(\'' + str + '\',\'' + suffix + '\') returned ' + actual);
    }
    
    private static void assertEndsWithIgnoreCase(String str, String suffix, Boolean expected){
        Boolean actual = FAP_StringUtils.endsWithIgnoreCase(str,suffix);
        System.assert(actual==expected, 'FAP_StringUtils.endsWithIgnoreCase(\'' + str + '\',\'' + suffix + '\') returned ' + actual);
    }

    private static testmethod void testContains(){
        assertContains(null, null, false);
        assertContains('abcdef', null, false);
        assertContains(null, 'def', false);
        assertContains('abcdef', 'ab', true);
        assertContains('abcdef', 'xab', false);
        assertContains('ABCDEF', 'AB', true);
        assertContains('ABCDEF', 'Ab', false);

        assertContains('abcdef', 'ef', true);
        assertContains('abcdef', 'xef', false);
        assertContains('ABCDEF', 'EF', true);
        assertContains('ABCDEF', 'Ef', false);

        assertContains('abcdef', 'cde', true);
        assertContains('abcdef', 'xcde', false);
        assertContains('ABCDEF', 'CDE', true);
        assertContains('ABCDEF', 'CDe', false);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertContains(String str, String searchStr, Boolean expected){
        Boolean actual = FAP_StringUtils.contains(str,searchStr);
        System.assert(actual==expected, 'FAP_StringUtils.contains(\'' + str + '\',\'' + searchStr + '\') returned ' + actual);
    }
    
    private static testmethod void testContainsIgnoreCase(){
        assertContainsIgnoreCase(null, null, false);
        assertContainsIgnoreCase('abcdef', null, false);
        assertContainsIgnoreCase(null, 'def', false);
        assertContainsIgnoreCase('abcdef', 'ab', true);
        assertContainsIgnoreCase('abcdef', 'xab', false);
        assertContainsIgnoreCase('ABCDEF', 'AB', true);
        assertContainsIgnoreCase('ABCDEF', 'Ab', true);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertContainsIgnoreCase(String str, String searchStr, Boolean expected){
        Boolean actual = FAP_StringUtils.containsIgnoreCase(str,searchStr);
        System.assert(actual==expected, 'FAP_StringUtils.containsIgnoreCase(\'' + str + '\',\'' + searchStr + '\') returned ' + actual);
    }

    private static testmethod void testSplitOneArg(){
        assertSplitOneArg(null,         null);
        assertSplitOneArg('',             new String[]{''});
        assertSplitOneArg('abc def',     new String[]{'abc','def'});
        assertSplitOneArg('abc  def',     new String[]{'abc','def'});
        assertSplitOneArg(' abc ',         new String[]{'abc'});
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertSplitOneArg(String str, String[] expected){
        String[] actual = FAP_StringUtils.split(str);
        if(actual == null){
            System.assert(expected == null, 'FAP_StringUtils.split(\'' + str + '\') returned ' + FAP_ArrayUtils.toString(actual));
            return;
        }
        for(Integer i = 0; i < actual.size(); i++){
            System.assert(expected[i] == actual[i], 'FAP_StringUtils.split(\'' + str + '\') returned ' + FAP_ArrayUtils.toString(actual));
        }
    }
    
    private static testmethod void testSplitOneArgPreserveAllTokens(){
        assertSplitOneArgPreserveAllTokens(null,         null);
        assertSplitOneArgPreserveAllTokens('',             new String[]{''});
        assertSplitOneArgPreserveAllTokens('abc def',     new String[]{'abc','def'});
        assertSplitOneArgPreserveAllTokens('abc  def',     new String[]{'abc','','def'});
        assertSplitOneArgPreserveAllTokens(' abc ',     new String[]{'','abc',''});
        assertSplitOneArgPreserveAllTokens('a b c',     new String[]{'a','b','c'});
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertSplitOneArgPreserveAllTokens(String str, String[] expected){
        String[] actual = FAP_StringUtils.splitPreserveAllTokens(str);
        if(actual == null){
            System.assert(expected == null, 'FAP_StringUtils.splitPreserveAllTokens(\'' + str + '\') returned ' + FAP_ArrayUtils.toString(actual));
            return;
        }
        for(Integer i = 0; i < actual.size(); i++){
            System.assert(expected[i] == actual[i], 'FAP_StringUtils.splitPreserveAllTokens(\'' + str + '\') returned ' + FAP_ArrayUtils.toString(actual));
        }
    }

    private static testmethod void testCharAt(){
        assertCharAt(null, -1, null);
        assertCharAt(null, 0, null);
        assertCharAt('abc', -1, null);
        assertCharAt('abc', 3, null);
        assertCharAt('abc', 0, 'a');
        assertCharAt('abc', 2, 'c');
        assertCharAt('abcde', -2, null);
        assertCharAt('abcde', 0, 'a');
        assertCharAt('abcde', 1, 'b');
        assertCharAt('abcde', 4, 'e');
        assertCharAt('abcde', 5, null);
        assertCharAt('', 0, '');
        assertCharAt(' ', 0, ' ');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertCharAt(String str, Integer index, String expected){
        String actual = FAP_StringUtils.charAt(str,index);
        System.assert(actual==expected, 'FAP_StringUtils.charAt(\'' + str + '\',' + index + ') returned ' + actual);
    }
    
    private static testmethod void testSplitTwoArgs(){
        assertSplitTwoArgs(null,         null,     null);
        assertSplitTwoArgs('',             null,     new String[]{''});
        assertSplitTwoArgs('',             'abc',     new String[]{''});
        assertSplitTwoArgs('a.b.c',     '.',    new String[]{'a','b','c'});
        assertSplitTwoArgs('a..b.c',    '.',     new String[]{'a','b','c'});
        assertSplitTwoArgs('a..b..c',    '..',     new String[]{'a','b','c'});
        assertSplitTwoArgs('a:b:c',     '.',     new String[]{'a:b:c'});
        assertSplitTwoArgs('a b c',     ' ',     new String[]{'a','b','c'});
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    

    private static void assertSplitTwoArgs(String str, String separator, String[] expected){
        String[] actual = FAP_StringUtils.split(str,separator);
        if(actual == null){
            System.assert(expected == null, 'FAP_StringUtils.split(\'' + str + '\',\'' + separator + '\') returned ' + FAP_ArrayUtils.toString(actual));
            return;
        }
        for(Integer i = 0; i < actual.size(); i++){
            System.assert(expected[i] == actual[i], 'FAP_StringUtils.split(\'' + str + '\',\'' + separator + '\') returned ' + FAP_ArrayUtils.toString(actual));
        }
    }

    private static testmethod void testSplitThreeArgs(){
        assertSplitThreeArgs(null,             '',     1,     null);
        assertSplitThreeArgs('',             '',     1,     new String[]{''});
        assertSplitThreeArgs('ab cd ef',     null,     0,     new String[]{'ab', 'cd', 'ef'});
        assertSplitThreeArgs('ab   cd ef',     null,     0,     new String[]{'ab', 'cd', 'ef'});
        assertSplitThreeArgs('ab:cd:ef',     ':',     0,     new String[]{'ab', 'cd', 'ef'});
        assertSplitThreeArgs('ab:cd:ef',     ':',     2,     new String[]{'ab', 'cd:ef'});
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertSplitThreeArgs(String str, String separator, Integer max, String[] expected){
        String[] actual = FAP_StringUtils.split(str,separator,max);
        if(actual == null){
            System.assert(expected == null, 'FAP_StringUtils.split(\'' + str + '\',\'' + separator + '\',' + max + ') returned ' + FAP_ArrayUtils.toString(actual));
            return;
        }
        for(Integer i = 0; i < actual.size(); i++){
            System.assert(expected[i] == actual[i], 'FAP_StringUtils.split(\'' + str + '\',\'' + separator + '\',' + max + ') returned ' + FAP_ArrayUtils.toString(actual));
        }
    }
    
    private static testmethod void testSplitByWholeSeparatorTwoArg(){
        assertSplitByWholeSeparatorTwoArg(null,             null,     null);
        assertSplitByWholeSeparatorTwoArg('',                 null,    new String[]{''});
        assertSplitByWholeSeparatorTwoArg('ab cd ef',         null,    new String[]{'ab', 'cd', 'ef'});
        assertSplitByWholeSeparatorTwoArg('ab cd ef',         ' ',    new String[]{'ab', 'cd', 'ef'});
        assertSplitByWholeSeparatorTwoArg('ab     cd ef',     null,    new String[]{'ab', 'cd', 'ef'});
        assertSplitByWholeSeparatorTwoArg('ab:cd:ef',         ':',    new String[]{'ab', 'cd', 'ef'});
        assertSplitByWholeSeparatorTwoArg('ab-!-cd-!-ef',     '-!-',    new String[]{'ab', 'cd', 'ef'});
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertSplitByWholeSeparatorTwoArg(String str, String separator, String[] expected){
        String[] actual = FAP_StringUtils.splitByWholeSeparator(str,separator);
        if(actual == null){
            System.assert(expected == null, 'FAP_StringUtils.splitByWholeSeparator(\'' + str + '\',\'' + separator + '\') returned ' + FAP_ArrayUtils.toString(actual));
            return;
        }
        for(Integer i = 0; i < actual.size(); i++){
            System.assert(expected[i] == actual[i], 'FAP_StringUtils.splitByWholeSeparator(\'' + str + '\',\'' + separator + '\') returned ' + FAP_ArrayUtils.toString(actual));
        }
    }
    
    private static testmethod void testSplitPreserveAllTokensTwoArg(){
        //test global static String[] splitPreserveAllTokens(String str, String separatorChars) {
        assertSplitPreserveAllTokensTwoArg(null,             null,    null);
        assertSplitPreserveAllTokensTwoArg('',                 null,    new String[]{''});
        assertSplitPreserveAllTokensTwoArg('abc def',         null,    new String[]{'abc', 'def'});
        assertSplitPreserveAllTokensTwoArg('abc def',         ' ',    new String[]{'abc', 'def'});
        assertSplitPreserveAllTokensTwoArg('abc  def',         ' ',    new String[]{'abc', '', 'def'});
        assertSplitPreserveAllTokensTwoArg('ab:cd:ef',         ':',    new String[]{'ab', 'cd', 'ef'});
        assertSplitPreserveAllTokensTwoArg('ab:cd:ef:',     ':',    new String[]{'ab', 'cd', 'ef', ''});
        assertSplitPreserveAllTokensTwoArg('ab:cd:ef::',     ':',    new String[]{'ab', 'cd', 'ef', '', ''});
        assertSplitPreserveAllTokensTwoArg('ab::cd:ef',     ':',    new String[]{'ab', '', 'cd', 'ef'});
        assertSplitPreserveAllTokensTwoArg(':cd:ef',         ':',    new String[]{'', 'cd', 'ef'});
        assertSplitPreserveAllTokensTwoArg('::cd:ef',         ':',    new String[]{'', '', 'cd', 'ef'});
        assertSplitPreserveAllTokensTwoArg(':cd:ef:',         ':',    new String[]{'', 'cd', 'ef', ''});
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertSplitPreserveAllTokensTwoArg(String str, String separator, String[] expected){
        String[] actual = FAP_StringUtils.splitPreserveAllTokens(str,separator);
        if(actual == null){
            System.assert(expected == null, 'FAP_StringUtils.splitPreserveAllTokens(\'' + str + '\',\'' + separator + '\') returned ' + FAP_ArrayUtils.toString(actual));
            return;
        }
        for(Integer i = 0; i < actual.size(); i++){
            System.assert(expected[i] == actual[i], 'FAP_StringUtils.splitPreserveAllTokens(\'' + str + '\',\'' + separator + '\') returned ' + FAP_ArrayUtils.toString(actual));
        }
    }

    private static testmethod void testSplitPreserveAllTokensThreeArgs(){
        //test global static String[] splitPreserveAllTokens(String str, String separatorChars, Integer max) {
        assertSplitPreserveAllTokensThreeArgs(null,         null,    -1, null);
        assertSplitPreserveAllTokensThreeArgs('',             null,     -1,    new String[]{''});
        assertSplitPreserveAllTokensThreeArgs('ab cd ef',     null,     0,    new String[]{'ab', 'cd', 'ef'});
        assertSplitPreserveAllTokensThreeArgs('ab   cd ef', null,     0,    new String[]{'ab', '', '', 'cd', 'ef'});
        assertSplitPreserveAllTokensThreeArgs('ab:cd:ef',     ':',     0,    new String[]{'ab', 'cd', 'ef'});
        assertSplitPreserveAllTokensThreeArgs('ab:cd:ef',     ':',     2,    new String[]{'ab', 'cd:ef'});
        assertSplitPreserveAllTokensThreeArgs('ab::cd::ef', '::',     2,    new String[]{'ab', ':cd::ef'});
        assertSplitPreserveAllTokensThreeArgs('ab   de fg', null,     2,    new String[]{'ab', '  de fg'});
        assertSplitPreserveAllTokensThreeArgs('ab   de fg', null,     3,    new String[]{'ab', '', ' de fg'});
        assertSplitPreserveAllTokensThreeArgs('ab   de fg', null,     4,    new String[]{'ab', '', '', 'de fg'});
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertSplitPreserveAllTokensThreeArgs(String str, String separatorChars, 
        Integer max, String[] expected){

        String[] actual = FAP_StringUtils.splitPreserveAllTokens(str,separatorChars,max);
        if(actual == null){
            System.assert(expected == null, 'FAP_StringUtils.splitPreserveAllTokens(\'' + str + '\',\'' + separatorChars + '\',' + max + ') returned ' + FAP_ArrayUtils.toString(actual));
            return;
        }
        for(Integer i = 0; i < actual.size(); i++){
            System.assert(expected[i] == actual[i], 'FAP_StringUtils.splitPreserveAllTokens(\'' + str + '\',\'' + separatorChars + '\',' + max + ') returned ' + FAP_ArrayUtils.toString(actual));
        }
    }

    private static testmethod void testSplitByWholeSeparatorThreeArgs(){
        //test global static String[] splitByWholeSeparator(String str, String separator, Integer max ) {
        
        assertTestSplitByWholeSeparatorThreeArgs(null,             null,     0, null);
        assertTestSplitByWholeSeparatorThreeArgs('',                 null,    0, new String[]{''});
        assertTestSplitByWholeSeparatorThreeArgs('ab cd ef',         null,    0, new String[]{'ab', 'cd', 'ef'});
        assertTestSplitByWholeSeparatorThreeArgs('ab cd ef',         ' ',    0, new String[]{'ab', 'cd', 'ef'});
        assertTestSplitByWholeSeparatorThreeArgs('ab     cd ef',     null,    0, new String[]{'ab', 'cd', 'ef'});
        assertTestSplitByWholeSeparatorThreeArgs('ab:cd:ef',         ':',    1, new String[]{'ab:cd:ef'});
        assertTestSplitByWholeSeparatorThreeArgs('ab:cd:ef',         ':',    2, new String[]{'ab', 'cd:ef'});
        assertTestSplitByWholeSeparatorThreeArgs('ab:cd:ef',         ':',    3, new String[]{'ab', 'cd', 'ef'});
        assertTestSplitByWholeSeparatorThreeArgs('ab-!-cd-!-ef',     '-!-',    5, new String[]{'ab', 'cd', 'ef'});
        assertTestSplitByWholeSeparatorThreeArgs('ab-!-cd-!-ef',     '-!-',    2, new String[]{'ab', 'cd-!-ef'});
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));
    }
    private static void assertTestSplitByWholeSeparatorThreeArgs(String str, String separator, 
        Integer max, String[] expected){

        String[] actual = FAP_StringUtils.splitByWholeSeparator(str,separator,max);
        if(actual == null){
            System.assert(expected == null, 'FAP_StringUtils.splitByWholeSeparator(\'' + str + '\',\'' + separator + '\',' + max + ') returned ' + FAP_ArrayUtils.toString(actual));
            return;
        }
        for(Integer i = 0; i < actual.size(); i++){
            System.assert(expected[i] == actual[i], 'FAP_StringUtils.splitByWholeSeparator(\'' + str + '\',\'' + separator + '\',' + max + ') returned ' + FAP_ArrayUtils.toString(actual));
        }
    }

    private static testmethod void testSplitByWholeSeparatorPreserveAllTokensTwoArgs(){
        //test global static String[] splitByWholeSeparatorPreserveAllTokens(String str, String separator) {
        assertSplitByWholeSeparatorPreserveAllTokensTwoArgs(null,             null,     null);
        assertSplitByWholeSeparatorPreserveAllTokensTwoArgs('',             null,    new String[]{''});
        assertSplitByWholeSeparatorPreserveAllTokensTwoArgs('ab cd ef',     null,    new String[]{'ab', 'cd', 'ef'});
        assertSplitByWholeSeparatorPreserveAllTokensTwoArgs('ab cd ef',     ' ',    new String[]{'ab', 'cd', 'ef'});
        assertSplitByWholeSeparatorPreserveAllTokensTwoArgs('ab   cd ef',     null,    new String[]{'ab', '', '', 'cd', 'ef'});
        assertSplitByWholeSeparatorPreserveAllTokensTwoArgs('ab:cd:ef',     ':',    new String[]{'ab', 'cd', 'ef'});
        assertSplitByWholeSeparatorPreserveAllTokensTwoArgs('ab-!-cd-!-ef', '-!-',    new String[]{'ab', 'cd', 'ef'});
        assertSplitByWholeSeparatorPreserveAllTokensTwoArgs('ab-!--!-cd-!-ef','-!-',    new String[]{'ab', '', 'cd', 'ef'});
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }
    private static void assertSplitByWholeSeparatorPreserveAllTokensTwoArgs(String str, String separator, String[] expected){

        String[] actual = FAP_StringUtils.splitByWholeSeparatorPreserveAllTokens(str,separator);
        if(actual == null){
            System.assert(expected == null, 'FAP_StringUtils.splitByWholeSeparatorPreserveAllTokens(\'' + str + '\',\'' + separator + '\') returned ' + FAP_ArrayUtils.toString(actual));
            return;
        }
        for(Integer i = 0; i < actual.size(); i++){
            System.assert(expected[i] == actual[i], 'FAP_StringUtils.splitByWholeSeparatorPreserveAllTokens(\'' + str + '\',\'' + separator + '\') returned ' + FAP_ArrayUtils.toString(actual));
        }
    }

    private static testmethod void testSplitByWholeSeparatorPreserveAllTokensThreeArgs(){
        //test global static String[] splitByWholeSeparatorPreserveAllTokens(String str, String separator, Integer max) {

        assertSplitByWholeSeparatorPreserveAllTokensThreeArgs(null,                 null,     0, null);
        assertSplitByWholeSeparatorPreserveAllTokensThreeArgs('',                 null,    0, new String[]{''});
        assertSplitByWholeSeparatorPreserveAllTokensThreeArgs('ab cd ef',         null,    0, new String[]{'ab', 'cd', 'ef'});
        assertSplitByWholeSeparatorPreserveAllTokensThreeArgs('ab cd ef',         ' ',    0, new String[]{'ab', 'cd', 'ef'});
        assertSplitByWholeSeparatorPreserveAllTokensThreeArgs('ab   cd ef',         ' ',    0, new String[]{'ab', '', '', 'cd', 'ef'});
        assertSplitByWholeSeparatorPreserveAllTokensThreeArgs('ab:cd:ef',         ':',    1, new String[]{'ab:cd:ef'});
        assertSplitByWholeSeparatorPreserveAllTokensThreeArgs('ab:cd:ef',         ':',    2, new String[]{'ab', 'cd:ef'});
        assertSplitByWholeSeparatorPreserveAllTokensThreeArgs('ab:cd:ef',         ':',    3, new String[]{'ab', 'cd', 'ef'});
        assertSplitByWholeSeparatorPreserveAllTokensThreeArgs('ab::cd:ef',         ':',    2, new String[]{'ab', ':cd:ef'});
        assertSplitByWholeSeparatorPreserveAllTokensThreeArgs('ab-!-cd-!-ef',     '-!-',    5, new String[]{'ab', 'cd', 'ef'});
        assertSplitByWholeSeparatorPreserveAllTokensThreeArgs('ab-!-cd-!-ef',     '-!-',    2, new String[]{'ab', 'cd-!-ef'});
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }
    private static void assertSplitByWholeSeparatorPreserveAllTokensThreeArgs(String str, String separator, 
        Integer max, String[] expected){

        String[] actual = FAP_StringUtils.splitByWholeSeparatorPreserveAllTokens(str,separator,max);
        if(actual == null){
            System.assert(expected == null, 'FAP_StringUtils.splitByWholeSeparatorPreserveAllTokens(\'' + str + '\',\'' + separator + '\',' + max + ') returned ' + FAP_ArrayUtils.toString(actual));
            return;
        }
        for(Integer i = 0; i < actual.size(); i++){
            System.assert(expected[i] == actual[i], 'FAP_StringUtils.splitByWholeSeparatorPreserveAllTokens(\'' + str + '\',\'' + separator + '\',' + max + ') returned ' + FAP_ArrayUtils.toString(actual));
        }
    }

    private static testmethod void testLeftPadTwoArgs(){
        // test: global static String leftPad(String str, Integer size) {
        assertLeftPadTwoArgs(null,     -1,    null);
        assertLeftPadTwoArgs('',     3,     '   ');
        assertLeftPadTwoArgs('bat', 3,     'bat');
        assertLeftPadTwoArgs('bat', 5,     '  bat');
        assertLeftPadTwoArgs('bat', 1,    'bat');
        assertLeftPadTwoArgs('bat', -1,    'bat');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertLeftPadTwoArgs(String str, Integer size, String expected){
        String actual = FAP_StringUtils.leftPad(str,size);
        System.assert(actual==expected, 'FAP_StringUtils.leftPad(\'' + str + '\',' 
            + size + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }
    
    private static testmethod void testLeftPadThreeArgs(){
        //test: global static String leftPad(String str, Integer size, String padStr) {
        assertLeftPadThreeArgs(null,     -1, null,     null);
        assertLeftPadThreeArgs('',         3,     'z',     'zzz'); 
        assertLeftPadThreeArgs('bat',     3,     'yz',     'bat');
        assertLeftPadThreeArgs('bat',     5,     'yz',     'yzbat');
        assertLeftPadThreeArgs('bat',     8,     'yz',     'yzyzybat');
        assertLeftPadThreeArgs('bat',     1,     'yz',     'bat');
        assertLeftPadThreeArgs('bat',     -1, 'yz',     'bat');
        assertLeftPadThreeArgs('bat',     5,     null,     '  bat');
        assertLeftPadThreeArgs('bat',     5,     '',     '  bat');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    

    private static void assertLeftPadThreeArgs(String str, Integer size, String padStr, String expected){
        String actual = FAP_StringUtils.leftPad(str,size,padStr);
        System.assert(actual==expected, 'FAP_StringUtils.leftPad(\'' + str + '\',' 
            + size + ',\'' + padStr + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }
    
    private static testmethod void testRightPadTwoArgs(){
        //test: global static String rightPad(String str, Integer size) {
        assertRightPadTwoArgs(null,     -1, null);
        assertRightPadTwoArgs('',         3,     '   ');
        assertRightPadTwoArgs('bat',     3,     'bat');
        assertRightPadTwoArgs('bat',     5,     'bat  ');
        assertRightPadTwoArgs('bat',     1,     'bat');
        assertRightPadTwoArgs('bat',     -1, 'bat');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertRightPadTwoArgs(String str, Integer size, String expected){
        String actual = FAP_StringUtils.rightPad(str,size);
        System.assert(actual==expected, 'FAP_StringUtils.rightPad(\'' + str + '\',' 
            + size + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }
    
    private static testmethod void testRightPadThreeArgs(){
        //test: global static String rightPad(String str, Integer size, String padStr) {
        assertRightPadThreeArgs(null,     -1, null,     null);
        assertRightPadThreeArgs('',     3,     '',     '   ');
        assertRightPadThreeArgs('',     3,     'z',     'zzz');
        assertRightPadThreeArgs('bat',     3,     'z',     'bat');
        assertRightPadThreeArgs('bat',     5,     'z',     'batzz');
        assertRightPadThreeArgs('bat',     1,     'z',     'bat');
        assertRightPadThreeArgs('bat',     -1,    'z',     'bat');
        assertRightPadThreeArgs('bat',     6,    'abcd', 'batabc');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));       
    }    
    
    private static void assertRightPadThreeArgs(String str, Integer size, String padStr, String expected){
        String actual = FAP_StringUtils.rightPad(str,size,padStr);
        System.assert(actual==expected, 'FAP_StringUtils.rightPad(\'' + str + '\',' 
            + size + ',\'' + padStr + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }

    private static testmethod void testGetCommonPrefix(){
        //test: global static String getCommonPrefix(List<String> strs) {
        assertGetCommonPrefix(null,                                             '');
        assertGetCommonPrefix(null,                                             '');
        assertGetCommonPrefix(new String[] {},                                     '');
        assertGetCommonPrefix(new String[] {'abc'},                             'abc');
        assertGetCommonPrefix(new String[] {null, null},                         '');
        assertGetCommonPrefix(new String[] {'', ''},                             '');
        assertGetCommonPrefix(new String[] {'', null},                             '');
        assertGetCommonPrefix(new String[] {'abc', null, null},                 '');
        assertGetCommonPrefix(new String[] {null, null, 'abc'},                 '');
        assertGetCommonPrefix(new String[] {'', 'abc'},                         '');
        assertGetCommonPrefix(new String[] {'abc', ''},                         '');
        assertGetCommonPrefix(new String[] {'abc', 'abc'},                         'abc');
        assertGetCommonPrefix(new String[] {'abc', 'a'},                         'a');
        assertGetCommonPrefix(new String[] {'ab', 'abxyz'},                     'ab');
        assertGetCommonPrefix(new String[] {'abcde', 'abxyz'},                     'ab');
        assertGetCommonPrefix(new String[] {'abcde', 'xyz'},                     '');
        assertGetCommonPrefix(new String[] {'xyz', 'abcde'},                     '');
        assertGetCommonPrefix(new String[] {'i am a machine', 'i am a robot'},     'i am a ');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertGetCommonPrefix(String[] strs, String expected){
        String actual = FAP_StringUtils.getCommonPrefix(strs);
        System.assert(actual==expected, 'FAP_StringUtils.getCommonPrefix(' + FAP_ArrayUtils.toString(strs) 
            + ') returned \'' + actual + '\', expected \'' + expected + '\'');
    }

    private static testmethod void testIndexOfDifferenceArrayInput(){
        //test: global static Integer indexOfDifference(String[] strs) {
        assertIndexOfDifferenceArrayInput(null,                                             -1);
        assertIndexOfDifferenceArrayInput(new String[] {},                                     -1);
        assertIndexOfDifferenceArrayInput(new String[] {'abc'},                             -1);
        assertIndexOfDifferenceArrayInput(new String[] {null, null},                         -1);
        assertIndexOfDifferenceArrayInput(new String[] {'', ''},                             -1);
        assertIndexOfDifferenceArrayInput(new String[] {'', null},                             0);
        assertIndexOfDifferenceArrayInput(new String[] {'abc', null, null},                 0);
        assertIndexOfDifferenceArrayInput(new String[] {null, null, 'abc'},                 0);
        assertIndexOfDifferenceArrayInput(new String[] {'', 'abc'},                         0);
        assertIndexOfDifferenceArrayInput(new String[] {'abc', ''},                            0);
        assertIndexOfDifferenceArrayInput(new String[] {'abc', 'abc'},                         -1);
        assertIndexOfDifferenceArrayInput(new String[] {'abc', 'a'},                         1);
        assertIndexOfDifferenceArrayInput(new String[] {'ab', 'abxyz'},                     2);
        assertIndexOfDifferenceArrayInput(new String[] {'abcde', 'abxyz'},                     2);
        assertIndexOfDifferenceArrayInput(new String[] {'abcde', 'xyz'},                     0);
        assertIndexOfDifferenceArrayInput(new String[] {'xyz', 'abcde'},                     0);
        assertIndexOfDifferenceArrayInput(new String[] {'i am a machine', 'i am a robot'},     7);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertIndexOfDifferenceArrayInput(String[] strs, Integer expected){
        Integer actual = FAP_StringUtils.indexOfDifference(strs);
        System.assert(actual==expected, 'FAP_StringUtils.indexOfDifference(' + FAP_ArrayUtils.toString(strs) 
            + ') returned ' + actual + '; expected ' + expected);
    }


     /*  private static testmethod void testGetLevenshteinDistance(){
        //test: global static Integer getLevenshteinDistance(String s, String t) {
        //assertGetLevenshteinDistance(null,             null,         -1,    true);
        //assertGetLevenshteinDistance(null,             null,         -1,    true);
        assertGetLevenshteinDistance('',            '',         0,    false);
        assertGetLevenshteinDistance('',            'a',         1,    false);
        assertGetLevenshteinDistance('aaapppp',     '',         7,    false);
        assertGetLevenshteinDistance('frog',         'fog',         1,    false);
        assertGetLevenshteinDistance('fly',         'ant',         3,    false);
        assertGetLevenshteinDistance('elephant',     'hippo',     7,    false);
        assertGetLevenshteinDistance('hippo',         'elephant', 7,    false);
        assertGetLevenshteinDistance('hippo',         'zzzzzzzz', 8,    false);
        assertGetLevenshteinDistance('hello',         'hallo',     1,    false);
    }    
    
 private static void assertGetLevenshteinDistance(String s, String t, 
        Integer expected, Boolean excepExpected){

        Integer actual = null;
        Boolean excepActual = false;
        try{
            actual = FAP_StringUtils.getLevenshteinDistance(s,t);
        } catch (FAP_IllegalArgumentException e){
            excepActual = true;
        }
        if(excepExpected && excepActual){
            return;
        }
        System.assert(excepExpected == excepActual, 'FAP_StringUtils.getLevenshteinDistance(\'' 
            + s + '\',\'' + t + '\') ' 
            + (excepExpected ? 'did not throw' : 'unexpectedly threw') 
            + ' FAP_IllegalArgumentException');
        if(!excepExpected && !excepActual){
            System.assert(actual==expected, 'FAP_StringUtils.getLevenshteinDistance(\'' + s + '\',\'' 
                + t + '\') returned ' + actual + '; expected ' + expected);
        }
    }
*/

     private static testmethod void testIndexOfThreeArgs(){
        //test: global static Integer indexOf(String str, String searchStr, Integer startPos) {
        assertIndexOfThreeArgs(null,         null,     -1, -1);
        assertIndexOfThreeArgs('',             '',     0,     0);
        assertIndexOfThreeArgs('aabaabaa',     'a',     0,     0);
        assertIndexOfThreeArgs('aabaabaa',     'b',     0,     2);
        assertIndexOfThreeArgs('aabaabaa',     'ab',     0,     1);
        assertIndexOfThreeArgs('aabaabaa',     'b',     3,     5);
        assertIndexOfThreeArgs('aabaabaa',     'b',     9,     -1);
        assertIndexOfThreeArgs('aabaabaa',     'b',     -1, 2);
        assertIndexOfThreeArgs('aabaabaa',     '',     2,     2);
        assertIndexOfThreeArgs('abc',         '',     9,     3);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));         
    }    

    private static void assertIndexOfThreeArgs(String str, String searchStr, Integer startPos, Integer expected){
        Integer actual = FAP_StringUtils.indexOf(str,searchStr,startPos);
        System.assert(actual==expected, 'FAP_StringUtils.indexOf(\'' + str + '\',\'' 
            + searchStr + '\',' + startPos + ') returned ' + actual + '; expected ' + expected);
    }

    private static testmethod void testOrdinalIndexOf(){
        //test: global static Integer ordinalIndexOf(String str, String searchStr, Integer ordinal) {
        assertOrdinalIndexOf(null,             null,     -1, -1);
        assertOrdinalIndexOf('',             '',     -1, -1);
        assertOrdinalIndexOf('aabaabaa',     'a',     1,     0);
        assertOrdinalIndexOf('aabaabaa',     'a',     2,     1);
        assertOrdinalIndexOf('aabaabaa',     'b',     1,     2);
        assertOrdinalIndexOf('aabaabaa',     'b',     2,     5);
        assertOrdinalIndexOf('aabaabaa',     'ab',     1,     1);
        assertOrdinalIndexOf('aabaabaa',     'ab',     2,     4);
        assertOrdinalIndexOf('aabaabaa',     'z',     1,     -1);
        assertOrdinalIndexOf('aabaabaa',     '',     1,     0);
        assertOrdinalIndexOf('aabaabaa',     '',     2,     0);
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    

    private static void assertOrdinalIndexOf(String str, String searchStr, Integer ordinal, Integer expected){
        Integer actual = FAP_StringUtils.ordinalIndexOf(str,searchStr,ordinal);
        System.assert(actual==expected, 'FAP_StringUtils.ordinalIndexOf(\'' + str + '\',\'' 
            + searchStr + '\',' + ordinal + ') returned ' + actual + '; expected ' + expected);
    }

    private static testmethod void testValidateChar(){
        try{
            Character.validateChar('ab');  //should throw exception since string has > 1 chars
            System.assert(false,'Character.validateChar(\'ab\') did not throw InvalidCharacterStringException');
        }catch(InvalidCharacterStringException e){}
    }

    private static testmethod void testJoinArrayOneArg(){
        //test: global static String joinArray(Object[] objectArray) {
        assertJoinArrayOneArg(null, null);
        assertJoinArrayOneArg(new String[]{}, '');
        assertJoinArrayOneArg(new String[]{null}, '');
        assertJoinArrayOneArg(new String[]{'a', 'b', 'c'}, 'abc');
        assertJoinArrayOneArg(new String[]{null, '', 'a'}, 'a');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }
    
    private static void assertJoinArrayOneArg(Object[] objectArray, String expected){
        String actual = FAP_StringUtils.joinArray(objectArray);
        System.assert(actual==expected, 'FAP_StringUtils.joinArray(\'' + FAP_ArrayUtils.toString(objectArray) + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }

    private static testmethod void testJoinArrayTwoArgs(){
        //test: global static String joinArray(Object[] objectArray, String separator) {
        assertJoinArrayTwoArgs(null, null, null);
        assertJoinArrayTwoArgs(new String[]{}, null, '');
        assertJoinArrayTwoArgs(new String[]{null}, null, '');
        assertJoinArrayTwoArgs(new String[]{'a', 'b', 'c'}, ';', 'a;b;c');
        assertJoinArrayTwoArgs(new String[]{'a', 'b', 'c'}, null, 'abc');
        assertJoinArrayTwoArgs(new String[]{null, '', 'a'}, ';', ';;a');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }
    
    private static void assertJoinArrayTwoArgs(Object[] objectArray, String separator, String expected){
        String actual = FAP_StringUtils.joinArray(objectArray,separator);
        System.assert(actual==expected, 'FAP_StringUtils.joinArray(\'' + FAP_ArrayUtils.toString(objectArray) + '\',\''
            + separator + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }

    private static testmethod void testJoinArrayFourArgs(){
        //test: global static String joinArray(Object[] objectArray, String separator, Integer startIndex, Integer endIndex) {
        assertJoinArrayFourArgs(null, null, 0, 2, null);
        assertJoinArrayFourArgs(new String[]{}, null, 0, 1, '');
        assertJoinArrayFourArgs(new String[]{null}, null, 0, 1, '');
        assertJoinArrayFourArgs(new String[]{'a', 'b', 'c'}, '--', 0, 3, 'a--b--c');
        assertJoinArrayFourArgs(new String[]{'a', 'b', 'c'}, null, 0, 3, 'abc');
        assertJoinArrayFourArgs(new String[]{'a', 'b', 'c'}, '', 0, 0, '');
        assertJoinArrayFourArgs(new String[]{'a', 'b', 'c'}, '', 0, 1, 'a');
        assertJoinArrayFourArgs(new String[]{'a', 'b', 'c'}, '', 0, 2, 'ab');
        assertJoinArrayFourArgs(new String[]{'a', 'b', 'c'}, '', 0, 3, 'abc');
        assertJoinArrayFourArgs(new String[]{'a', 'b', 'c'}, '', -1, 4, 'abc');
        assertJoinArrayFourArgs(new String[]{'a', 'b', 'c'}, '', 1, 1, '');
        assertJoinArrayFourArgs(new String[]{'a', 'b', 'c'}, '', 1, 2, 'b');
        assertJoinArrayFourArgs(new String[]{'a', 'b', 'c'}, '', 1, 3, 'bc');
        assertJoinArrayFourArgs(new String[]{'a', 'b', 'c'}, '', 2, 2, '');
        assertJoinArrayFourArgs(new String[]{'a', 'b', 'c'}, '', 2, 3, 'c');
        assertJoinArrayFourArgs(new String[]{null, '', 'a'}, ',', 0, 3, ',,a');
        assertJoinArrayFourArgs(new Long[]{3, 4, -1}, 'xyz', 0, 3, '3xyz4xyz-1');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertJoinArrayFourArgs(Object[] objectArray, String separator, Integer startIndex, Integer endIndex, String expected){
        String actual = FAP_StringUtils.joinArray(objectArray,separator,startIndex,endIndex);
        System.assert(actual==expected, 'FAP_StringUtils.joinArray(\'' + FAP_ArrayUtils.toString(objectArray) + '\',\''
            + separator + '\',' + startIndex + ',' + endIndex + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }

     

    private static testmethod void testJoinSetBooleanSet(){ 
        //global static String joinSet(Set<Boolean> booleanSet, String separator) 
        assertJoinSetBooleanSet(null, '|', null);
        assertJoinSetBooleanSet(new Set<Boolean>{}, '|', '');
        assertJoinSetBooleanSet(new Set<Boolean>{true}, '|', 'true');
        assertJoinSetBooleanSet(new Set<Boolean>{true, false}, '|', 'false|true');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }
    
    private static testmethod void testJoinSetDateSet(){ 
        //global static String joinSet(Set<Date> dateSet, String separator) 
        assertJoinSetDateSet(null, '|', null);
        assertJoinSetDateSet(new Set<Date>{}, '|', '');
        Date date1 = Date.newInstance(2009,1,1);
        Date date2 = Date.newInstance(2009,1,2);
        assertJoinSetDateSet(new Set<Date>{date1}, '|', ''+date1+'' );
        assertJoinSetDateSet(new Set<Date>{date1,date2}, '|', ''+date1+'|'+date2+'' );
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }
    
    private static testmethod void testJoinSetDatetimeSet(){ 
        //global static String joinSet(Set<Datetime> datetimeSet, String separator) 
        assertJoinSetDatetimeSet(null, '|', null);
        assertJoinSetDatetimeSet(new Set<Datetime>{}, '|', '');
        Datetime date1 = Datetime.newInstance(2009,1,1);
        Datetime date2 = Datetime.newInstance(2009,1,2);
        assertJoinSetDatetimeSet(new Set<Datetime>{date1}, '|', ''+date1+'' );
        assertJoinSetDatetimeSet(new Set<Datetime>{date1,date2}, '|', ''+date1+'|'+date2+'' );
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }
    
    private static testmethod void testJoinSetDecimalSet(){ 
        //global static String joinSet(Set<Decimal> decimalSet, String separator) 
        assertJoinSetDecimalSet(null, '|', null);
        assertJoinSetDecimalSet(new Set<Decimal>{}, '|', '');
        Decimal dec1 = 4.0;
        Decimal dec2 = 5.0;
        assertJoinSetDecimalSet(new Set<Decimal>{dec1}, '|', '' + dec1 + '');
        assertJoinSetDecimalSet(new Set<Decimal>{dec1,dec2}, '|', '' + dec1 + '|' + dec2 + '');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }
    
    private static testmethod void testJoinSetDoubleSet(){ 
        //global static String joinSet(Set<Double> doubleSet, String separator) 
        assertJoinSetDoubleSet(null, '|', null);
        assertJoinSetDoubleSet(new Set<Double>{}, '|', '');
        Double doub1 = 4.0;
        Double doub2 = 5.0;
        assertJoinSetDoubleSet(new Set<Double>{doub1}, '|', '' + doub1 + '');
        assertJoinSetDoubleSet(new Set<Double>{doub1,doub2}, '|', '' + doub1 + '|' + doub2 + '');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }
    
    private static testmethod void testJoinSetIDSet(){ 
        //global static String joinSet(Set<ID> idSet, String separator) 
        assertJoinSetIDSet(null, '|', null);
        assertJoinSetIDSet(new Set<ID>{}, '|', '');
        Account acct1 = new Account(name='acct1');
        insert acct1;
        Account acct2 = new Account(name='acct2');
        insert acct2;
        assertJoinSetIDSet(new Set<ID>{acct1.id}, '|', '' + acct1.id + '');
        assertJoinSetIDSet(new Set<ID>{acct1.id,acct2.id}, '|', '' + acct1.id + '|' + acct2.id + '');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }
    
    private static testmethod void testJoinSetIntegerSet(){ 
        //global static String joinSet(Set<Integer> integerSet, String separator) 
        assertJoinSetIntegerSet(null, '|', null);
        assertJoinSetIntegerSet(new Set<Integer>{}, '|', '');
        Integer int1 = 4;
        Integer int2 = 5;
        assertJoinSetIntegerSet(new Set<Integer>{int1}, '|', '' + int1 + '' );
        assertJoinSetIntegerSet(new Set<Integer>{int1,int2}, '|', '' + int1 + '|' + int2 + '' );
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }
    
    private static testmethod void testJoinSetLongSet(){ 
        //global static String joinSet(Set<Long> longSet, String separator) 
        assertJoinSetLongSet(null, '|', null);
        assertJoinSetLongSet(new Set<Long>{}, '|', '');
        Long long1 = 4;
        Long long2 = 5;
        assertJoinSetLongSet(new Set<Long>{long1}, '|', '' + long1 + '');
        assertJoinSetLongSet(new Set<Long>{long1,long2}, '|', '' + long1 + '|' + long2 + '');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }
    
    private static testmethod void testJoinSetTimeSet(){ 
        //global static String joinSet(Set<Time> timeSet, String separator) 
        assertJoinSetTimeSet(null, '|', null);
        assertJoinSetTimeSet(new Set<Time>{}, '|', '');
        Time time1 = Time.newInstance(18, 30, 2, 20);
        Time time2 = Time.newInstance(18, 30, 2, 21);
        assertJoinSetTimeSet(new Set<Time>{time1}, '|', '' + time1 + '' );
        assertJoinSetTimeSet(new Set<Time>{time1,time2}, '|', '' + time1 + '|' + time2 + '' );
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }
    
    private static testmethod void testJoinSetStringSet(){ 
        //global static String joinSet(Set<String> stringSet, String separator) 
        assertJoinSetStringSet(null, '|', null);
        assertJoinSetStringSet(new Set<String>{}, '|', '');
        String str1 = 'xyz';
        String str2 = 'abc';
        assertJoinSetStringSet(new Set<String>{str1}, '|', '' + str1 + '');
        assertJoinSetStringSet(new Set<String>{str1,str2}, '|', '' + str1 + '|' + str2 + '');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }
    
    private static void assertJoinSetBlobSet(Set<Blob> blobSet, String separator, String expected){ System.assert(!((blobSet == null && expected != null) || (blobSet != null && expected == null)),    'Invalid test input: both parameters should be null.');String actual = FAP_StringUtils.joinSet(blobSet,separator); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),separator));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),separator));     if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet), 'FAP_StringUtils.joinSet(' +     SetUtils.toString(blobSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}
    private static void assertJoinSetBooleanSet(Set<Boolean> booleanSet, String separator, String expected){ System.assert(!((booleanSet == null && expected != null) || (booleanSet != null && expected == null)),    'Invalid test input: both parameters should be null.');String actual = FAP_StringUtils.joinSet(booleanSet,separator); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),separator));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),separator));     if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet), 'FAP_StringUtils.joinSet(' +     SetUtils.toString(booleanSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}
    private static void assertJoinSetDateSet(Set<Date> dateSet, String separator, String expected){ System.assert(!((dateSet == null && expected != null) || (dateSet != null && expected == null)),    'Invalid test input: both parameters should be null.');String actual = FAP_StringUtils.joinSet(dateSet,separator); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),separator));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),separator));     if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet), 'FAP_StringUtils.joinSet(' +     SetUtils.toString(dateSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}
    private static void assertJoinSetDatetimeSet(Set<Datetime> datetimeSet, String separator, String expected){ System.assert(!((datetimeSet == null && expected != null) || (datetimeSet != null && expected == null)),    'Invalid test input: both parameters should be null.');String actual = FAP_StringUtils.joinSet(datetimeSet,separator); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),separator));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),separator));     if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet), 'FAP_StringUtils.joinSet(' +     SetUtils.toString(datetimeSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}
    private static void assertJoinSetDecimalSet(Set<Decimal> decimalSet, String separator, String expected){ System.assert(!((decimalSet == null && expected != null) || (decimalSet != null && expected == null)),    'Invalid test input: both parameters should be null.');String actual = FAP_StringUtils.joinSet(decimalSet,separator); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),separator));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),separator));     if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet), 'FAP_StringUtils.joinSet(' +     SetUtils.toString(decimalSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}
    private static void assertJoinSetDoubleSet(Set<Double> doubleSet, String separator, String expected){ System.assert(!((doubleSet == null && expected != null) || (doubleSet != null && expected == null)),    'Invalid test input: both parameters should be null.');String actual = FAP_StringUtils.joinSet(doubleSet,separator); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),separator));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),separator));     if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet), 'FAP_StringUtils.joinSet(' +     SetUtils.toString(doubleSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}
    private static void assertJoinSetIDSet(Set<ID> idSet, String separator, String expected){ System.assert(!((idSet == null && expected != null) || (idSet != null && expected == null)),    'Invalid test input: both parameters should be null.');String actual = FAP_StringUtils.joinSet(idSet,separator); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),separator));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),separator));     if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet), 'FAP_StringUtils.joinSet(' +     SetUtils.toString(idSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}
    private static void assertJoinSetIntegerSet(Set<Integer> integerSet, String separator, String expected){ System.assert(!((integerSet == null && expected != null) || (integerSet != null && expected == null)),    'Invalid test input: both parameters should be null.');String actual = FAP_StringUtils.joinSet(integerSet,separator); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),separator));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),separator));     if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet), 'FAP_StringUtils.joinSet(' +     SetUtils.toString(integerSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}
    private static void assertJoinSetLongSet(Set<Long> longSet, String separator, String expected){ System.assert(!((longSet == null && expected != null) || (longSet != null && expected == null)),    'Invalid test input: both parameters should be null.');String actual = FAP_StringUtils.joinSet(longSet,separator); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),separator));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),separator));     if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet), 'FAP_StringUtils.joinSet(' +     SetUtils.toString(longSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}
    private static void assertJoinSetTimeSet(Set<Time> timeSet, String separator, String expected){ System.assert(!((timeSet == null && expected != null) || (timeSet != null && expected == null)),    'Invalid test input: both parameters should be null.');String actual = FAP_StringUtils.joinSet(timeSet,separator); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),separator));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),separator));     if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet), 'FAP_StringUtils.joinSet(' +     SetUtils.toString(timeSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}
    private static void assertJoinSetStringSet(Set<String> stringSet, String separator, String expected){ System.assert(!((stringSet == null && expected != null) || (stringSet != null && expected == null)),    'Invalid test input: both parameters should be null.');String actual = FAP_StringUtils.joinSet(stringSet,separator); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),separator));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),separator));     if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet), 'FAP_StringUtils.joinSet(' +     SetUtils.toString(stringSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}

    private static Blob generateRandomBlob(){
        return EncodingUtil.base64Decode(''+System.currentTimeMillis()+Math.roundToLong(Math.random()*10000));    
    }

    private static testmethod void testReplaceChars(){
        //test: global static String replaceChars(String str, String searchChars, String replaceChars)
        assertReplaceChars(null, null, null, null);
        assertReplaceChars('', null, null, '');
        assertReplaceChars('abc', null, null, 'abc');
        assertReplaceChars('abc', '', null, 'abc');
        assertReplaceChars('abc', 'b', null, 'ac');
        assertReplaceChars('abc', 'b', '', 'ac');
        assertReplaceChars('abcba', 'bc', 'yz', 'ayzya');
        assertReplaceChars('abcba', 'bc', 'y', 'ayya');
        assertReplaceChars('abcba', 'bc', 'yzx', 'ayzya');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }    
    
    private static void assertReplaceChars(String str, String searchChars, String replaceChars, String expected){
        String actual = FAP_StringUtils.replaceChars(str,searchChars,replaceChars);
        System.assert(actual==expected, 'FAP_StringUtils.replaceChars(\'' + str + '\',\'' 
            + searchChars + '\',\'' + replaceChars + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }
    
    private static testmethod void testJoinSet(){
        //test: global static String joinSet(Set<Object> objectSet, String separator){
        assertJoinSet(null, null, null);
        assertJoinSet(new Set<Object>(), ':', null);
        assertJoinSet(new Set<Object>{'a','b','c'}, ':', 'a:c:b');
        assertJoinSet(new Set<Object>{' ','b','c'}, ':', 'c:b');
        assertJoinSet(new Set<Object>{true,false}, '|', 'true|false');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertJoinSet(Set<Object> objectSet, String separator, String expected){
        String actual = FAP_StringUtils.joinSet(objectSet,separator);
        if(objectSet == null || objectSet.size() <= 0){
            System.assert(FAP_StringUtils.isBlank(expected), 
                'FAP_StringUtils.joinSet(Set<Object>, \'' + (separator == null ? 'null' : separator) 
                + '\') returned \'' + actual + '\'; expected \'' + expected + '\'');
            return;
        }
        Set<String> actualAsSet = new Set<String>(FAP_StringUtils.split(actual,separator));
        Set<String> expectedAsSet = new Set<String>(FAP_StringUtils.split(expected,separator));
        System.assert(actualAsSet.containsAll(expectedAsSet) && expectedAsSet.containsAll(actualAsSet),
            'FAP_StringUtils.joinSet(Set<Object>, \'' + (separator == null ? 'null' : separator) + '\') returned \'' + 
                actual + '\'; expected \'' + expected + '\'');
    }

    private static testmethod void testSubstringTwoArgs(){
        //test: global static String substring(String str, Integer startIndex) {
        assertSubstringTwoArgs(null, -1, null);
        assertSubstringTwoArgs('', -2, '');
        assertSubstringTwoArgs('', -1, '');
        assertSubstringTwoArgs('', 0, '');
        assertSubstringTwoArgs('', 1, '');
        assertSubstringTwoArgs('abc', 0, 'abc');
        assertSubstringTwoArgs('abc', 2, 'c');
        assertSubstringTwoArgs('abc', 4, '');
        assertSubstringTwoArgs('abc', -2, 'bc');
        assertSubstringTwoArgs('abc', -4, 'abc');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
    }

    private static void assertSubstringTwoArgs(String str, Integer startIndex, String expected){
        String actual = FAP_StringUtils.substring(str, startIndex);
        System.assert(actual==expected, 'FAP_StringUtils.substring(\'' + str + '\',' 
            + startIndex + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }
    
    private static testmethod void testSubstringThreeArgs(){
        //test: global static String substring(String str, Integer startIndex, Integer endIndex) {
        assertSubstringThreeArgs(null, -1, -1, null);
        assertSubstringThreeArgs('', -1, -1, '');
        assertSubstringThreeArgs('abc', 0, 2, 'ab');
        assertSubstringThreeArgs('abc', 2, 0, '');
        assertSubstringThreeArgs('abc', 2, 4, 'c');
        assertSubstringThreeArgs('abc', 4, 6, '');
        assertSubstringThreeArgs('abc', 2, 2, '');
        assertSubstringThreeArgs('abc', -2, -1, 'b');
        assertSubstringThreeArgs('abc', -4, 2, 'ab');
        assertSubstringThreeArgs('abc', -5, -4, '');
        List<String> nullList = null;
        System.assertEquals(null,FAP_StringUtils.trimAll(nullList));        
        
    }
    
    private static void assertSubstringThreeArgs(String str, Integer startIndex, Integer endIndex, String expected){
        String actual = FAP_StringUtils.substring(str, startIndex, endIndex);
        system.debug('Test Entry');
        System.assert(actual==expected, 'FAP_StringUtils.substring(\'' + str + '\',' 
            + startIndex + ',' + endIndex + ') returned \'' + actual + '\'; expected \'' + expected + '\'');
    }
    
}
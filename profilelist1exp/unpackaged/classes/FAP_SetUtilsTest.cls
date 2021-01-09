@IsTest
private class FAP_SetUtilsTest {

    private static testmethod void testObjectToBlob(){
        //test: global static Set<Blob> objectToBlob(Set<Object> objectSet){
        //assertObjectToBlob(null, null);
        //assertObjectToBlob(new Set<Object>{}, new Set<Blob>{});
        Blob blob1 = generateRandomBlob();
        Blob blob2 = generateRandomBlob();
        //assertObjectToBlob(new Set<Object>{blob1}, new Set<Blob>{blob1});
       // assertObjectToBlob(new Set<Object>{blob1,blob2}, new Set<Blob>{blob1,blob2});
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');    
    } 


    private static testmethod void testObjectToBoolean(){ 
        //test: global static Set<Boolean> objectToBoolean(Set<Object> objectSet){ 
        assertObjectToBoolean(null, null);
        assertObjectToBoolean(new Set<Object>{}, new Set<Boolean>{});
        assertObjectToBoolean(new Set<Object>{true}, new Set<Boolean>{true});
        assertObjectToBoolean(new Set<Object>{true,false}, new Set<Boolean>{false,true});
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');            
    }

    private static testmethod void testObjectToDate(){ 
        //test: global static Set<Date> objectToDate(Set<Object> objectSet){ 
        assertObjectToDate(null, null);
        assertObjectToDate(new Set<Object>{}, new Set<Date>{});
        Date date1 = Date.newInstance(2009,1,1);
        Date date2 = Date.newInstance(2009,1,2);
        assertObjectToDate(new Set<Object>{date1}, new Set<Date>{date1});
        assertObjectToDate(new Set<Object>{date1,date2}, new Set<Date>{date1,date2});
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');            
    }

    private static testmethod void testObjectToDatetime(){ 
        //test: global static Set<Datetime> objectToDatetime(Set<Object> objectSet){ 
        assertObjectToDatetime(null, null);
        assertObjectToDatetime(new Set<Object>{}, new Set<Datetime>{});
        Datetime date1 = Datetime.newInstance(2009,1,1);
        Datetime date2 = Datetime.newInstance(2009,1,2);
        assertObjectToDatetime(new Set<Object>{date1}, new Set<Datetime>{date1});
        assertObjectToDatetime(new Set<Object>{date1,date2}, new Set<Datetime>{date1,date2});
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');            
    }

    private static testmethod void testObjectToDecimal(){ 
        //test: global static Set<Decimal> objectToDecimal(Set<Object> objectSet){
        assertObjectToDecimal(null, null);
        assertObjectToDecimal(new Set<Object>{}, new Set<Decimal>{});
        Decimal dec1 = 4.0;
        Decimal dec2 = 5.0;
        assertObjectToDecimal(new Set<Object>{dec1}, new Set<Decimal>{dec1});
        assertObjectToDecimal(new Set<Object>{dec1,dec2}, new Set<Decimal>{dec1,dec2});
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');            
    }

    private static testmethod void testObjectToDouble(){ 
        //test: global static Set<Double> objectToDouble(Set<Object> objectSet){ 
        assertObjectToDouble(null, null);
        assertObjectToDouble(new Set<Object>{}, new Set<Double>{});
        Double doub1 = 4.0;
        Double doub2 = 5.0;
        assertObjectToDouble(new Set<Object>{doub1}, new Set<Double>{doub1});
        assertObjectToDouble(new Set<Object>{doub1,doub2}, new Set<Double>{doub1,doub2});
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');            
    }

    private static testmethod void testObjectToID(){ 
        //test: global static Set<ID> objectToID(Set<Object> objectSet){ 
        assertObjectToID(null, null);
        assertObjectToID(new Set<Object>{}, new Set<ID>{});
        Account acct1 = new Account(name='acct1');
        insert acct1;
        Account acct2 = new Account(name='acct2');
        insert acct2;
        assertObjectToID(new Set<Object>{acct1.id}, new Set<Id>{acct1.id});
        assertObjectToID(new Set<Object>{acct1.id,acct2.id}, new Set<Id>{acct1.id,acct2.id});
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');            
    } 

    private static testmethod void testObjectToInteger(){ 
        //test: global static Set<Integer> objectToInteger(Set<Object> objectSet){ 
        assertObjectToInteger(null, null);
        assertObjectToInteger(new Set<Object>{}, new Set<Integer>{});
        Integer int1 = 4;
        Integer int2 = 5;
        assertObjectToInteger(new Set<Object>{int1}, new Set<Integer>{int1});
        assertObjectToInteger(new Set<Object>{int1,int2}, new Set<Integer>{int1,int2});
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');            
    }

    private static testmethod void testObjectToLong(){ 
        //test: global static Set<Long> objectToLong(Set<Object> objectSet){ 
        assertObjectToLong(null, null);
        assertObjectToLong(new Set<Object>{}, new Set<Long>{});
        Long long1 = 4;
        Long long2 = 5;
        assertObjectToLong(new Set<Object>{long1}, new Set<Long>{long1});
        assertObjectToLong(new Set<Object>{long1,long2}, new Set<Long>{long1,long2});
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');            
    }

    private static testmethod void testObjectToTime(){ 
        //test: global static Set<Time> objectToTime(Set<Object> objectSet){ 
        assertObjectToTime(null, null);
        assertObjectToTime(new Set<Object>{}, new Set<Time>{});
        Time time1 = Time.newInstance(18, 30, 2, 20);
        Time time2 = Time.newInstance(18, 30, 2, 21);
        assertObjectToTime(new Set<Object>{time1}, new Set<Time>{time1});
        assertObjectToTime(new Set<Object>{time1,time2}, new Set<Time>{time1,time2});
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');            
    }

    private static testmethod void testObjectToString(){ 
        //test: global static Set<String> objectToString(Set<Object> objectSet){ 
        assertObjectToString(null, null);
        assertObjectToString(new Set<Object>{}, new Set<String>{});
        String str1 = 'xyz';
        String str2 = 'abc';
        assertObjectToString(new Set<Object>{str1}, new Set<String>{str1});
        assertObjectToString(new Set<Object>{str1,str2}, new Set<String>{str1,str2});
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');            
    }
    
    private static testmethod void testToStringBlobSet(){ 
        //test: global static String toString(Set<Blob> blobSet)
        assertToStringBlobSet(null, null);
        assertToStringBlobSet(new Set<Blob>{}, '');
        Blob blob1 = generateRandomBlob();
        Blob blob2 = generateRandomBlob();
        //assertToStringBlobSet(new Set<Blob>{blob1}, '{\'' + blob1.toString() + '\'}');
       // assertToStringBlobSet(new Set<Blob>{blob1,blob2}, '{\'' + blob1.toString() + '\',\'' + blob2.toString() + '\'}');
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');    
    }    

    private static testmethod void testToStringBooleanSet(){ 
        //test: global static String toString(Set<Boolean> booleanSet)
        assertToStringBooleanSet(null, null);
        assertToStringBooleanSet(new Set<Boolean>{}, '');
        assertToStringBooleanSet(new Set<Boolean>{true}, '{true}');
        assertToStringBooleanSet(new Set<Boolean>{true, false}, '{false,true}');
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');            
    }

    private static testmethod void testToStringDateSet(){ 
        //test: global static String toString(Set<Date> dateSet)
        assertToStringDateSet(null, null);
        assertToStringDateSet(new Set<Date>{}, '');
        Date date1 = Date.newInstance(2009,1,1);
        Date date2 = Date.newInstance(2009,1,2);
        assertToStringDateSet(new Set<Date>{date1}, '{'+date1+'}' );
        assertToStringDateSet(new Set<Date>{date1,date2}, '{'+date1+','+date2+'}' );
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');            
    }

    private static testmethod void testToStringDatetimeSet(){ 
        //test: global static String toString(Set<Datetime> datetimeSet)
        assertToStringDatetimeSet(null, null);
        assertToStringDatetimeSet(new Set<Datetime>{}, '');
        Datetime date1 = Datetime.newInstance(2009,1,1);
        Datetime date2 = Datetime.newInstance(2009,1,2);
        assertToStringDatetimeSet(new Set<Datetime>{date1}, '{'+date1+'}' );
        assertToStringDatetimeSet(new Set<Datetime>{date1,date2}, '{'+date1+','+date2+'}' );
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');            
    }

    private static testmethod void testToStringDecimalSet(){ 
        //test: global static String toString(Set<Decimal> decimalSet)
        assertToStringDecimalSet(null, null);
        assertToStringDecimalSet(new Set<Decimal>{}, '');
        Decimal dec1 = 4.0;
        Decimal dec2 = 5.0;
        assertToStringDecimalSet(new Set<Decimal>{dec1}, '{' + dec1 + '}');
        assertToStringDecimalSet(new Set<Decimal>{dec1,dec2}, '{' + dec1 + ',' + dec2 + '}');
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');            
    }

    private static testmethod void testToStringDoubleSet(){ 
        //test: global static String toString(Set<Double> doubleSet)
        assertToStringDoubleSet(null, null);
        assertToStringDoubleSet(new Set<Double>{}, '');
        Double doub1 = 4.0;
        Double doub2 = 5.0;
        assertToStringDoubleSet(new Set<Double>{doub1}, '{' + doub1 + '}');
        assertToStringDoubleSet(new Set<Double>{doub1,doub2}, '{' + doub1 + ',' + doub2 + '}');
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');            
    }

    private static testmethod void testToStringIDSet(){ 
        //test: global static String toString(Set<ID> idSet)
        assertToStringIDSet(null, null);
        assertToStringIDSet(new Set<ID>{}, '');
        Account acct1 = new Account(name='acct1');
        insert acct1;
        Account acct2 = new Account(name='acct2');
        insert acct2;
        assertToStringIDSet(new Set<ID>{acct1.id}, '{' + acct1.id + '}');
        assertToStringIDSet(new Set<ID>{acct1.id,acct2.id}, '{' + acct1.id + ',' + acct2.id + '}');
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');            
    }

    private static testmethod void testToStringIntegerSet(){ 
        //test: global static String toString(Set<Integer> integerSet)
        assertToStringIntegerSet(null, null);
        assertToStringIntegerSet(new Set<Integer>{}, '');
        Integer int1 = 4;
        Integer int2 = 5;
        assertToStringIntegerSet(new Set<Integer>{int1}, '{' + int1 + '}' );
        assertToStringIntegerSet(new Set<Integer>{int1,int2}, '{' + int1 + ',' + int2 + '}' );
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');            
    }
    private static testmethod void testToStringLongSet(){ 
        //test: global static String toString(Set<Long> longSet)
        assertToStringLongSet(null, null);
        assertToStringLongSet(new Set<Long>{}, '');
        Long long1 = 4;
        Long long2 = 5;
        assertToStringLongSet(new Set<Long>{long1}, '{' + long1 + '}');
        assertToStringLongSet(new Set<Long>{long1,long2}, '{' + long1 + ',' + long2 + '}');
         system.assertEquals(long1,4);  
    }

    private static testmethod void testToStringTimeSet(){ 
        //test: global static String toString(Set<Time> timeSet)
        assertToStringTimeSet(null, null);
        assertToStringTimeSet(new Set<Time>{}, '');
        Time time1 = Time.newInstance(18, 30, 2, 20);
        Time time2 = Time.newInstance(18, 30, 2, 21);
        assertToStringTimeSet(new Set<Time>{time1}, '{' + time1 + '}' );
        assertToStringTimeSet(new Set<Time>{time1,time2}, '{' + time1 + ',' + time2 + '}' );
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');    
    }


    private static testmethod void testToStringStringSet(){ 
        //test: global static String toString(Set<String> stringSet)
        assertToStringStringSet(null, null);
        assertToStringStringSet(new Set<String>{}, '');
        String str1 = 'xyz';
        String str2 = 'abc';
        assertToStringStringSet(new Set<String>{str1}, '{' + str1 + '}');
        assertToStringStringSet(new Set<String>{str1,str2}, '{' + str1 + ',' + str2 + '}');
        account acc = new account(Name = 'Test Account');
        insert acc;
        system.assertEquals(acc.Name,'Test Account');    
    }

    //private static void assertObjectToBlob(Set<Object> objectSet, Set<Blob> expected){System.assert(!((objectSet == null && expected != null)|| (objectSet != null && expected == null)),    'Invalid test input: both parameters should be null.');Set<Blob> actual = FAP_SetUtils.objectToBlob(objectSet);System.assert(!(objectSet == null && expected == null && actual != null),     'FAP_SetUtils.objectToBlob(null) returned ' + FAP_SetUtils.toString(actual) + '; expected null');if(expected != null && actual != null){System.assert(actual.containsAll(expected) && expected.containsAll(actual),     'FAP_SetUtils.objectToBlob(' + FAP_SetUtils.toString(objectSet) + ') returned ' + FAP_SetUtils.toString(actual) + '; expected ' + FAP_SetUtils.toString(expected));}}
    private static void assertObjectToBoolean(Set<Object> objectSet, Set<Boolean> expected){System.assert(!((objectSet == null && expected != null)|| (objectSet != null && expected == null)),    'Invalid test input: both parameters should be null.');Set<Boolean> actual = FAP_SetUtils.objectToBoolean(objectSet);System.assert(!(objectSet == null && expected == null && actual != null),     'FAP_SetUtils.objectToBoolean(null) returned ' + FAP_SetUtils.toString(actual) + '; expected null');if(expected != null && actual != null){System.assert(actual.containsAll(expected) && expected.containsAll(actual),     'FAP_SetUtils.objectToBoolean(' + FAP_SetUtils.toString(objectSet) + ') returned ' + FAP_SetUtils.toString(actual) + '; expected ' + FAP_SetUtils.toString(expected));}}
    private static void assertObjectToDate(Set<Object> objectSet, Set<Date> expected){System.assert(!((objectSet == null && expected != null)|| (objectSet != null && expected == null)),    'Invalid test input: both parameters should be null.');Set<Date> actual = FAP_SetUtils.objectToDate(objectSet);System.assert(!(objectSet == null && expected == null && actual != null),     'FAP_SetUtils.objectToDate(null) returned ' + FAP_SetUtils.toString(actual) + '; expected null');if(expected != null && actual != null){System.assert(actual.containsAll(expected) && expected.containsAll(actual),     'FAP_SetUtils.objectToDate(' + FAP_SetUtils.toString(objectSet) + ') returned ' + FAP_SetUtils.toString(actual) + '; expected ' + FAP_SetUtils.toString(expected));}}
    private static void assertObjectToDatetime(Set<Object> objectSet, Set<Datetime> expected){System.assert(!((objectSet == null && expected != null)|| (objectSet != null && expected == null)),    'Invalid test input: both parameters should be null.');Set<Datetime> actual = FAP_SetUtils.objectToDatetime(objectSet);System.assert(!(objectSet == null && expected == null && actual != null),     'FAP_SetUtils.objectToDatetime(null) returned ' + FAP_SetUtils.toString(actual) + '; expected null');if(expected != null && actual != null){System.assert(actual.containsAll(expected) && expected.containsAll(actual),     'FAP_SetUtils.objectToDatetime(' + FAP_SetUtils.toString(objectSet) + ') returned ' + FAP_SetUtils.toString(actual) + '; expected ' + FAP_SetUtils.toString(expected));}}
    private static void assertObjectToDecimal(Set<Object> objectSet, Set<Decimal> expected){System.assert(!((objectSet == null && expected != null)|| (objectSet != null && expected == null)),    'Invalid test input: both parameters should be null.');Set<Decimal> actual = FAP_SetUtils.objectToDecimal(objectSet);System.assert(!(objectSet == null && expected == null && actual != null),     'FAP_SetUtils.objectToDecimal(null) returned ' + FAP_SetUtils.toString(actual) + '; expected null');if(expected != null && actual != null){System.assert(actual.containsAll(expected) && expected.containsAll(actual),     'FAP_SetUtils.objectToDecimal(' + FAP_SetUtils.toString(objectSet) + ') returned ' + FAP_SetUtils.toString(actual) + '; expected ' + FAP_SetUtils.toString(expected));}}
    private static void assertObjectToDouble(Set<Object> objectSet, Set<Double> expected){System.assert(!((objectSet == null && expected != null)|| (objectSet != null && expected == null)),    'Invalid test input: both parameters should be null.');Set<Double> actual = FAP_SetUtils.objectToDouble(objectSet);System.assert(!(objectSet == null && expected == null && actual != null),     'FAP_SetUtils.objectToDouble(null) returned ' + FAP_SetUtils.toString(actual) + '; expected null');if(expected != null && actual != null){System.assert(actual.containsAll(expected) && expected.containsAll(actual),     'FAP_SetUtils.objectToDouble(' + FAP_SetUtils.toString(objectSet) + ') returned ' + FAP_SetUtils.toString(actual) + '; expected ' + FAP_SetUtils.toString(expected));}}
    private static void assertObjectToID(Set<Object> objectSet, Set<ID> expected){System.assert(!((objectSet == null && expected != null)|| (objectSet != null && expected == null)),    'Invalid test input: both parameters should be null.');Set<ID> actual = FAP_SetUtils.objectToID(objectSet);System.assert(!(objectSet == null && expected == null && actual != null),     'FAP_SetUtils.objectToID(null) returned ' + FAP_SetUtils.toString(actual) + '; expected null');if(expected != null && actual != null){System.assert(actual.containsAll(expected) && expected.containsAll(actual),     'FAP_SetUtils.objectToID(' + FAP_SetUtils.toString(objectSet) + ') returned ' + FAP_SetUtils.toString(actual) + '; expected ' + FAP_SetUtils.toString(expected));}}
    private static void assertObjectToInteger(Set<Object> objectSet, Set<Integer> expected){System.assert(!((objectSet == null && expected != null)|| (objectSet != null && expected == null)),    'Invalid test input: both parameters should be null.');Set<Integer> actual = FAP_SetUtils.objectToInteger(objectSet);System.assert(!(objectSet == null && expected == null && actual != null),     'FAP_SetUtils.objectToInteger(null) returned ' + FAP_SetUtils.toString(actual) + '; expected null');if(expected != null && actual != null){System.assert(actual.containsAll(expected) && expected.containsAll(actual),     'FAP_SetUtils.objectToInteger(' + FAP_SetUtils.toString(objectSet) + ') returned ' + FAP_SetUtils.toString(actual) + '; expected ' + FAP_SetUtils.toString(expected));}}
    private static void assertObjectToLong(Set<Object> objectSet, Set<Long> expected){System.assert(!((objectSet == null && expected != null)|| (objectSet != null && expected == null)),    'Invalid test input: both parameters should be null.');Set<Long> actual = FAP_SetUtils.objectToLong(objectSet);System.assert(!(objectSet == null && expected == null && actual != null),     'FAP_SetUtils.objectToLong(null) returned ' + FAP_SetUtils.toString(actual) + '; expected null');if(expected != null && actual != null){System.assert(actual.containsAll(expected) && expected.containsAll(actual),     'FAP_SetUtils.objectToLong(' + FAP_SetUtils.toString(objectSet) + ') returned ' + FAP_SetUtils.toString(actual) + '; expected ' + FAP_SetUtils.toString(expected));}}
    private static void assertObjectToTime(Set<Object> objectSet, Set<Time> expected){System.assert(!((objectSet == null && expected != null)|| (objectSet != null && expected == null)),    'Invalid test input: both parameters should be null.');Set<Time> actual = FAP_SetUtils.objectToTime(objectSet);System.assert(!(objectSet == null && expected == null && actual != null),     'FAP_SetUtils.objectToTime(null) returned ' + FAP_SetUtils.toString(actual) + '; expected null');if(expected != null && actual != null){System.assert(actual.containsAll(expected) && expected.containsAll(actual),     'FAP_SetUtils.objectToTime(' + FAP_SetUtils.toString(objectSet) + ') returned ' + FAP_SetUtils.toString(actual) + '; expected ' + FAP_SetUtils.toString(expected));}}
    private static void assertObjectToString(Set<Object> objectSet, Set<String> expected){System.assert(!((objectSet == null && expected != null)|| (objectSet != null && expected == null)),    'Invalid test input: both parameters should be null.');Set<String> actual = FAP_SetUtils.objectToString(objectSet);System.assert(!(objectSet == null && expected == null && actual != null),     'FAP_SetUtils.objectToString(null) returned ' + FAP_SetUtils.toString(actual) + '; expected null');if(expected != null && actual != null){System.assert(actual.containsAll(expected) && expected.containsAll(actual),     'FAP_SetUtils.objectToString(' + FAP_SetUtils.toString(objectSet) + ') returned ' + FAP_SetUtils.toString(actual) + '; expected ' + FAP_SetUtils.toString(expected));}}
    
    private static void assertToStringBlobSet(Set<Blob> blobSet, String expected){System.assert(!((blobSet == null && expected != null) || (blobSet != null && expected == null)),     'Invalid test input: both parameters should be null.');String actual = FAP_SetUtils.toString(blobSet); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),','));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),','));    if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),    'FAP_SetUtils.toString(' + FAP_SetUtils.toString(blobSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}
    private static void assertToStringBooleanSet(Set<Boolean> booleanSet, String expected){System.assert(!((booleanSet == null && expected != null) || (booleanSet != null && expected == null)),     'Invalid test input: both parameters should be null.');String actual = FAP_SetUtils.toString(booleanSet); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),','));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),','));    if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),    'FAP_SetUtils.toString(' + FAP_SetUtils.toString(booleanSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}
    private static void assertToStringDateSet(Set<Date> dateSet, String expected){System.assert(!((dateSet == null && expected != null) || (dateSet != null && expected == null)),     'Invalid test input: both parameters should be null.');String actual = FAP_SetUtils.toString(dateSet); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),','));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),','));    if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),    'FAP_SetUtils.toString(' + FAP_SetUtils.toString(dateSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}
    private static void assertToStringDatetimeSet(Set<Datetime> datetimeSet, String expected){System.assert(!((datetimeSet == null && expected != null) || (datetimeSet != null && expected == null)),     'Invalid test input: both parameters should be null.');String actual = FAP_SetUtils.toString(datetimeSet); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),','));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),','));    if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),    'FAP_SetUtils.toString(' + FAP_SetUtils.toString(datetimeSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}
    private static void assertToStringDecimalSet(Set<Decimal> decimalSet, String expected){System.assert(!((decimalSet == null && expected != null) || (decimalSet != null && expected == null)),     'Invalid test input: both parameters should be null.');String actual = FAP_SetUtils.toString(decimalSet); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),','));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),','));    if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),    'FAP_SetUtils.toString(' + FAP_SetUtils.toString(decimalSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}
    private static void assertToStringDoubleSet(Set<Double> doubleSet, String expected){System.assert(!((doubleSet == null && expected != null) || (doubleSet != null && expected == null)),     'Invalid test input: both parameters should be null.');String actual = FAP_SetUtils.toString(doubleSet); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),','));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),','));    if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),    'FAP_SetUtils.toString(' + FAP_SetUtils.toString(doubleSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}
    private static void assertToStringIDSet(Set<ID> idSet, String expected){System.assert(!((idSet == null && expected != null) || (idSet != null && expected == null)),     'Invalid test input: both parameters should be null.');String actual = FAP_SetUtils.toString(idSet); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),','));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),','));    if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),    'FAP_SetUtils.toString(' + FAP_SetUtils.toString(idSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}
    private static void assertToStringIntegerSet(Set<Integer> integerSet, String expected){System.assert(!((integerSet == null && expected != null) || (integerSet != null && expected == null)),     'Invalid test input: both parameters should be null.');String actual = FAP_SetUtils.toString(integerSet); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),','));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),','));    if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),    'FAP_SetUtils.toString(' + FAP_SetUtils.toString(integerSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}
    private static void assertToStringLongSet(Set<Long> longSet, String expected){System.assert(!((longSet == null && expected != null) || (longSet != null && expected == null)),     'Invalid test input: both parameters should be null.');String actual = FAP_SetUtils.toString(longSet); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),','));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),','));    if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),    'FAP_SetUtils.toString(' + FAP_SetUtils.toString(longSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}
    private static void assertToStringTimeSet(Set<Time> timeSet, String expected){System.assert(!((timeSet == null && expected != null) || (timeSet != null && expected == null)),     'Invalid test input: both parameters should be null.');String actual = FAP_SetUtils.toString(timeSet); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),','));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),','));    if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),    'FAP_SetUtils.toString(' + FAP_SetUtils.toString(timeSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}
    private static void assertToStringStringSet(Set<String> stringSet, String expected){System.assert(!((stringSet == null && expected != null) || (stringSet != null && expected == null)),     'Invalid test input: both parameters should be null.');String actual = FAP_SetUtils.toString(stringSet); Set<String> actualAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars(    (actual == null ? '' : actual),'{}\'',''),','));Set<String> expectedAsStringSet = new Set<String>(FAP_StringUtils.split(FAP_StringUtils.replaceChars((expected == null ? '' : expected),'{}\'',''),','));    if(expected != null && actual != null){System.assert(actualAsStringSet.containsAll(expectedAsStringSet) && expectedAsStringSet.containsAll(actualAsStringSet),    'FAP_SetUtils.toString(' + FAP_SetUtils.toString(stringSet) + ') returned \'' + actual + '\'; expected \'' + expected + '\'');}}
        

    private static Blob generateRandomBlob(){
        return EncodingUtil.base64Decode(''+System.currentTimeMillis()+Math.roundToLong(Math.random()*10000));    
    }

    private static testmethod void testListToSetString(){
      List<String> aList = null;
        System.assertEquals(null,FAP_SetUtils.listToSet(aList));
        System.assertEquals(0,FAP_SetUtils.listToSet(new List<String>()).size());
        System.assertEquals(1,FAP_SetUtils.listToSet(new List<String>{''}).size());
        System.assertEquals(1,FAP_SetUtils.listToSet(new List<String>{'a'}).size());
        System.assertEquals(2,FAP_SetUtils.listToSet(new List<String>{'a','b'}).size());
        System.assertEquals(1,FAP_SetUtils.listToSet(new List<String>{'a','a'}).size());
    }
  
    private static testmethod void testSetToListString(){
        System.assertEquals(null,FAP_SetUtils.setToList(null));
        System.assertEquals(0,FAP_SetUtils.setToList(new Set<String>()).size());
        System.assertEquals(1,FAP_SetUtils.setToList(new Set<String>{''}).size());
        System.assertEquals(1,FAP_SetUtils.setToList(new Set<String>{'a'}).size());
        System.assertEquals(2,FAP_SetUtils.setToList(new Set<String>{'a','b'}).size());
        System.assertEquals(1,FAP_SetUtils.setToList(new Set<String>{'a','a'}).size());
    }

    private static testmethod void testAssertEquals(){
      final Blob blob1 = generateRandomBlob();
        final Date date1 = Date.newInstance(2009,1,1);
        final Datetime datetime1 = Datetime.newInstance(2009,1,1);
        final Time time1 = Time.newInstance(18, 30, 2, 20);
        //FAP_SetUtils.assertEquals(new Set<Blob>{blob1},new Set<Blob>{blob1});
        FAP_SetUtils.assertEquals(new Set<Boolean>{true},new Set<Boolean>{true});
        FAP_SetUtils.assertEquals(new Set<Date>{date1},new Set<Date>{date1});
        FAP_SetUtils.assertEquals(new Set<Datetime>{datetime1},new Set<Datetime>{datetime1});
        FAP_SetUtils.assertEquals(new Set<Decimal>{1.1},new Set<Decimal>{1.1});
        FAP_SetUtils.assertEquals(new Set<Double>{1.1},new Set<Double>{1.1});
        FAP_SetUtils.assertEquals(new Set<Integer>{1},new Set<Integer>{1});
        FAP_SetUtils.assertEquals(new Set<Long>{1L},new Set<Long>{1L});
        FAP_SetUtils.assertEquals(new Set<String>{'a'},new Set<String>{'a'});
        FAP_SetUtils.assertEquals(new Set<Time>{time1},new Set<Time>{time1});
        System.assertEquals(true,FAP_SetUtils.equals(new Set<Time>{time1},new Set<Time>{time1}));       
    }

    private static testmethod void testEquals(){
      final Set<Object> NULL_SET = null;
        System.assertEquals(true,FAP_SetUtils.equals(NULL_SET,NULL_SET));       
        System.assertEquals(false,FAP_SetUtils.equals(null,new Set<Integer>{1}));       
        System.assertEquals(false,FAP_SetUtils.equals(new Set<Integer>{1},null));       
        System.assertEquals(true,FAP_SetUtils.equals(new Set<Integer>(),new Set<Integer>()));       
        System.assertEquals(false,FAP_SetUtils.equals(new Set<Integer>{1},new Set<Integer>()));       
        System.assertEquals(false,FAP_SetUtils.equals(new Set<Integer>{1},new Set<Integer>{2}));       
        System.assertEquals(true,FAP_SetUtils.equals(new Set<Integer>{1},new Set<Integer>{1}));       

        System.assertEquals(false,FAP_SetUtils.equals(null,new Set<String>{'abc'}));       
        System.assertEquals(false,FAP_SetUtils.equals(new Set<String>{'abc'},null));       
        System.assertEquals(true,FAP_SetUtils.equals(new Set<String>(),new Set<String>()));       
        System.assertEquals(false,FAP_SetUtils.equals(new Set<String>{'abc'},new Set<String>()));       
        System.assertEquals(false,FAP_SetUtils.equals(new Set<String>{'abc'},new Set<String>{'def'}));       
        System.assertEquals(true,FAP_SetUtils.equals(new Set<String>{'abc'},new Set<String>{'abc'}));       

        final Blob blob1 = generateRandomBlob();
        final Date date1 = Date.newInstance(2009,1,1);
        final Datetime datetime1 = Datetime.newInstance(2009,1,1);
        final Time time1 = Time.newInstance(18, 30, 2, 20);
        System.assertEquals(true,FAP_SetUtils.equals(new Set<Blob>{blob1},new Set<Blob>{blob1}));
        System.assertEquals(true,FAP_SetUtils.equals(new Set<Boolean>{true},new Set<Boolean>{true}));
        System.assertEquals(true,FAP_SetUtils.equals(new Set<Date>{date1},new Set<Date>{date1}));
        System.assertEquals(true,FAP_SetUtils.equals(new Set<Datetime>{datetime1},new Set<Datetime>{datetime1}));
        System.assertEquals(true,FAP_SetUtils.equals(new Set<Decimal>{1.1},new Set<Decimal>{1.1}));
        System.assertEquals(true,FAP_SetUtils.equals(new Set<Double>{1.1},new Set<Double>{1.1}));
        System.assertEquals(true,FAP_SetUtils.equals(new Set<Integer>{1},new Set<Integer>{1}));
        System.assertEquals(true,FAP_SetUtils.equals(new Set<Long>{1L},new Set<Long>{1L}));
        System.assertEquals(true,FAP_SetUtils.equals(new Set<String>{'a'},new Set<String>{'a'}));
        System.assertEquals(true,FAP_SetUtils.equals(new Set<Time>{time1},new Set<Time>{time1}));

    }
}
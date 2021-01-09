@IsTest
private class PartnerLanguageTest {
	
	private static testmethod void Init(){
		PartnerLanguage pl = new PartnerLanguage();
		String testStr = pl.returnDefaultKey();
		System.debug('teststr >>>'+testStr);
		Map<String,String> tempMap = pl.returnUsrMap();
		System.debug('size ==' + tempMap.size());
		System.debug('keyset' + tempMap.keySet());
		System.assertNotEquals(3,tempMap.size());
		System.assertEquals(22,tempMap.size());
		System.assertEquals('',testStr);
		System.assertNotEquals('us',testStr); 
	}

	private static testmethod void returnMatchValueTest(){
		String testParam = 'ko';
		PartnerLanguage pl = new PartnerLanguage();
		System.assertEquals(true,pl.checkingExistence(testParam));
		System.assertNotEquals(false,pl.checkingExistence(testParam));
		String resultStr = pl.returnMatchValue(testParam);
		System.assertEquals(true,StringUtils.equalsIgnoreCase('KOREAN', resultStr));
		
		String falseParamStr = 'uk';
		String falseResultStr = pl.returnMatchValue(falseParamStr);
		System.debug('falseResultStr='+falseResultStr);
		System.assertEquals(true,StringUtils.isBlank(falseResultStr));
		//System.assertNotEquals('uk',falseResultStr);
	}
	
}
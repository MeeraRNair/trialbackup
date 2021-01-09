@isTest
private class PartnerCountryTest {

    private static testmethod void Init(){
		PartnerCountry pc = new PartnerCountry();
		String testStr = pc.returnDefaultKey();
		Map<String,String> tempMap = pc.returnUsrMap();
		System.debug('size ==' + tempMap.size());
		System.debug('keyset' + tempMap.keySet());
		System.assertNotEquals(3,tempMap.size());
		//System.assertEquals(70,tempMap.size());
		System.assertEquals(tempMap.size(),pc.returnUsrMap().size());
		System.assertEquals(true,StringUtils.equalsIgnoreCase('', testStr));
		System.assertNotEquals('en-us',testStr); 
	}

	private static testmethod void returnMatchValueTest(){
		Country__c countries = [
                select id,name,code__c  
                from Country__c 
                where Is_Active_Partner_Country__c = true and name='CHILE'
                limit 1];
        String testCountryID = countries.id;        
		String testParam = 'CL';
		PartnerCountry pc = new PartnerCountry();
		System.assertEquals(true,pc.checkingExistence(testParam));
		System.assertNotEquals(false,pc.checkingExistence(testParam));
		String resultStr = pc.returnMatchValue(testParam);
		System.debug('resultStr >>>>' +resultStr);
		System.assertEquals(true,StringUtils.equalsIgnoreCase(testCountryID, resultStr));
		
		String falseParamStr = 'uk';
		String falseResultStr = pc.returnMatchValue(falseParamStr);
		System.debug('falseResultStr='+falseResultStr);
		System.assertNotEquals(true,StringUtils.equalsIgnoreCase(testCountryID, falseResultStr));
		
	}
}
@IsTest
private class TestPartnerRegistrationTab {
	private static testmethod void testTab(){
		PartnerRegistrationTab tab = new PartnerRegistrationTab('test1','test2');
		System.assertEquals('test1',tab.tabLabel);
		System.assertEquals('test2',tab.name);
		System.assertEquals(null,tab.next);
		System.assertEquals(null,tab.previous);
		System.assertEquals(false,tab.nextEnabled);
		System.assertEquals(false,tab.previousEnabled);
		System.assertNotEquals(null,tab.fields);
		System.assertEquals(0,tab.fields.size());
	}
	
}
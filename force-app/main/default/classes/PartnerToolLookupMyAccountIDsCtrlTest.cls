@IsTest
private class PartnerToolLookupMyAccountIDsCtrlTest {

	private static testmethod void testNormal(){
		PartnerToolLookupMyAccountIDsCtrl controller = new PartnerToolLookupMyAccountIDsCtrl();
		System.assertNotEquals(null,controller.ssoMyAccountLookupURL);
		
	}
}
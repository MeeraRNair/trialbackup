/**
Test class for PartnerSelfServiceUpdateMessageCtrl
 */
@isTest
private class PartnerSelfServiceUpdateMessageCtrlTest {

    public static testMethod void test_navigateToCompanyProfile() {
		//Test method for the Conitinue without entering data
		System.debug('#KP:START of test_navigateToCompanyProfile()');

		PageReference pageRef = Page.PartnerSelfServiceUpdateMessage;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('type', 'changed');
		PartnerSelfServiceUpdateMessageCtrlExt controller = new PartnerSelfServiceUpdateMessageCtrlExt();
		System.assertEquals('/apex/PartnerSelfServiceMyCompany', controller.navigateToCompanyProfile().getUrl() );
		
		System.debug('#KP:END of test_navigateToCompanyProfile()');
	}
	
	public static testMethod void test_messageTypes() {
		//Test method for the Conitinue without entering data
		System.debug('#KP:START of test_messageTypes()');

		PageReference pageRef = Page.PartnerSelfServiceUpdateMessage;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('type', 'changed');
		PartnerSelfServiceUpdateMessageCtrlExt controller = new PartnerSelfServiceUpdateMessageCtrlExt();
		System.assertEquals(PartnerSelfServiceUpdateMessageCtrlExt.SLA, controller.messageType);
		
		ApexPages.currentPage().getParameters().put('type', 'nochange');
		PartnerSelfServiceUpdateMessageCtrlExt controller2 = new PartnerSelfServiceUpdateMessageCtrlExt();
		System.assertEquals(PartnerSelfServiceUpdateMessageCtrlExt.NO_CHANGE, controller2.messageType);
		
		System.debug('#KP:END of test_messageTypes()');
	}
}
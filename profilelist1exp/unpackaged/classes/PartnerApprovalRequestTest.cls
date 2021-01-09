@IsTest
private class PartnerApprovalRequestTest {
	private static testmethod void testGettersSetters(){
		PartnerApprovalRequest request = new PartnerApprovalRequest();
		request.relatedToText = 'test1';
		System.assertEquals('test1', request.relatedToText);
		request.relatedToId = 'test2';
		System.assertEquals('test2', request.relatedToId);
		request.approvalType = 'test3';
		System.assertEquals('test3', request.approvalType);
		request.status = 'test4';
		System.assertEquals('test4', request.status);
		Long currentTime = System.currentTimeMillis();
		request.dateSubmitted = Datetime.newInstance(currentTime);
		System.assertEquals(Datetime.newInstance(currentTime), request.dateSubmitted);
	}
}
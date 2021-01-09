@IsTest
private class PartnerRegistrationProgressBarCtlExTest {

	private static testmethod void testPercentZero(){
		Partner_Request__c request = new Partner_Request__c();
		
		insert request;
		PartnerRegistrationProgressBarCtrlExt extension = new PartnerRegistrationProgressBarCtrlExt(
			new ApexPages.standardController(request));
		System.assertEquals(0,extension.percentComplete);
		
		for(Integer i = 0; i < 9; i++){
			if(i==0) request.Review_for_Completeness_Is_Complete_Flag__c = true;
			if(i==1) request.Check_For_Duplicates_Is_Complete_Flag__c = true;
			if(i==2) request.Perform_Credit_Check_Is_Complete_Flag__c = true;
			if(i==3) request.Export_Compliance_Check_Is_Complete_Flag__c = true;
			if(i==4) request.Check_Denied_Party_List_Is_Complete_Flag__c = true;
			if(i==5) request.Approve_Is_Complete_Flag__c = true;
			if(i==6) request.Send_Account_Suggestion_Is_Complete_Flag__c = true;
			if(i==7) request.Link_to_Account_Record_Is_Complete_Flag__c = true;
			if(i==8) request.Provision_First_User_Is_Complete_Flag__c = true;
			update request;
			extension = new PartnerRegistrationProgressBarCtrlExt(
				new ApexPages.standardController(request));
			System.debug('Loop '+i);			
			System.debug('TOTAL_COMPLETE_FLAG_COUNT >>'+PartnerRegistrationProgressBarCtrlExt.TOTAL_COMPLETE_FLAG_COUNT);
			System.debug('1st Percent complete >>>'+((i+1)*100)/13);	
			System.debug('Percent complete >>>'+extension.percentComplete);
			if(PartnerRegistrationProgressBarCtrlExt.TOTAL_COMPLETE_FLAG_COUNT == 12){
				System.assertEquals((((i+1)*100)/12),extension.percentComplete);
			}else{	
				System.assertEquals((((i+1)*100)/13),extension.percentComplete);
			}
			
		}
	}
}
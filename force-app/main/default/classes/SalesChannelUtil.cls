global class SalesChannelUtil {

	webService static string getSalesChannelParentId(String SalesChannelParentId) {
	
		system.debug('#### In SalesChannelUtil.getSalesChannelParentId . . . ');
	
		// Display input
		system.debug('#### SalesChannelParentId = ' + SalesChannelParentId);


		// Get the record ID of the sales channel parent
		List<Sales_Channel_Group__c> sSalesChannelParentId = new List<Sales_Channel_Group__c>();
		
		sSalesChannelParentId = [select Id from Sales_Channel_Group__c where Group_ID__c = :SalesChannelParentId];


		if (sSalesChannelParentId.size() == 0) {
			return 'null';
		}

		else {
			// Return the record ID
			return sSalesChannelParentId[0].Id;
		}
	
	}	// End getSalesChannelParentId()








	static testMethod void Test_NullRecords(){
	
		system.debug('#### In test method Test_NullRecords . . .');
	
		string sSalesChannelParentRecordId;
	
		Test.startTest();
		sSalesChannelParentRecordId = SalesChannelUtil.getSalesChannelParentId('654321');
		Test.stopTest();


		system.debug('#### Verify the records retrieved');
		system.assertEquals('null', sSalesChannelParentRecordId);


	}	// End Test_NullRecords()


	static testMethod void Test_OneRecord(){

		system.debug('#### In test method Test_OneRecord . . .');

		string sSalesChannelParentRecordId;


		Sales_Channel_Group__c TestSalesChannelRecord = new Sales_Channel_Group__c(Name='Test - SC Record 1', Group_ID__c='123456');

		insert TestSalesChannelRecord;
		
		string sTestSalesChannelRecordId = TestSalesChannelRecord.Id;

		Test.startTest();
		sSalesChannelParentRecordId = SalesChannelUtil.getSalesChannelParentId('123456');
		Test.stopTest();


		system.debug('#### Verify the records retrieved');
		system.assertEquals(sSalesChannelParentRecordId, sTestSalesChannelRecordId);


	}	// End Test_OneRecord()


}	// End SalesChannelUtil()
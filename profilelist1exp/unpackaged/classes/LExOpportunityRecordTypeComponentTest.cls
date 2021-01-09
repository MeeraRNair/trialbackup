@isTest(seeAllData=false)
private class LExOpportunityRecordTypeComponentTest {

    static testMethod void TestLExOpportunityRecordTypeComponentCtrl() {
    
        Test.startTest();  
        
        LExOpportunityRecordTypeComponentCtrl LExRTCtrl = new LExOpportunityRecordTypeComponentCtrl();
        
        List<RecordType> listRT = LExRTCtrl.getAvailableRecordTypes();
        
        Test.stopTest();        
        
        System.assertNotEquals(0,listRT.size());
    
    }
        
    
}
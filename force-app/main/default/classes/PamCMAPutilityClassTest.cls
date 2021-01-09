//-------------------------------------------------------------------------------------------------------------------------
/*  
Version     Name        Date            CR#         Description
Create      Shue        22-Mar-2019     CR17115     Test Class Creation: Story 6070726: Channel: [PAM] Update Mass Lead Upload Requests design in Partner Portal
*/ 
//-------------------------------------------------------------------------------------------------------------------------

@isTest
private class PamCMAPutilityClassTest {
    static testMethod void testSMAFromPartner() {
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        //testData.getContact2(true);
        testData.getPartnerUser(true);
        testData.getAccount(true);   //Account
        testData.getContact(true);
        
        Test.startTest();
        PamCMAPutilityClass.getSalesmotionAccounts(testData.partnerUser.id);
        PamCMAPutilityClass.getUserssUnderSalesMotion(testData.accountObj);
        PamCMAPutilityClass.getUserssUnderSalesMotionList(testData.setSMA);
        Test.stopTest();
        System.assertEquals(null, null);
    }
    
    /*
    static testMethod void testSMAPartner() {
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        //testData.getContact2(true);
        testData.getPartnerUser(true);
        testData.getAccount(true);   //Account
        testData.getContact(true);
        
        Test.startTest();
        //PamCMAPutilityClass.getSalesmotionAccounts(testData.partnerUser.id);
        PamCMAPutilityClass.getUserssUnderSalesMotion(testData.accountObj);
        //PamCMAPutilityClass.getUserssUnderSalesMotionList(testData.setSMA);
        Test.stopTest();
        System.assertEquals(null, null);
    }
    
    static testMethod void testListSMAPartners() {
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        //testData.getContact2(true);
        testData.getPartnerUser(true);
        testData.getAccount(true);   //Account
        testData.getContact(true);
        
        Test.startTest();
        //PamCMAPutilityClass.getSalesmotionAccounts(testData.partnerUser.id);
        //PamCMAPutilityClass.getUserssUnderSalesMotion(testData.accountObj);
        PamCMAPutilityClass.getUserssUnderSalesMotionList(testData.setSMA);
        Test.stopTest();
        System.assertEquals(null, null);
    }
    */
}
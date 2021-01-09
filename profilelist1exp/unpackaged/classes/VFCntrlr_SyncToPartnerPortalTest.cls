/*********************************************************************************************************************************************************************
REVISION HISTORY
================
Version     Author        Date            Release#    CR#     Description
-------     ------        ----            --------    ---     -----------
1.0      Krishnamoorthi  12-Dec-2012    	14.2      7777    Created for VFCntrlr_SyncToPartnerPortal apex class

***********************************************************************************************************************************************************************/
@isTest
private class VFCntrlr_SyncToPartnerPortalTest {
    Static list<Account> listAcc;
    @testSetup static void setup() {
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listAccTDF;
    }
    static testMethod void myUnitTest() {
        TriggerExecutionController.setSkipAllTriggers(true);
        test.startTest();
        listAcc = [select id from Account limit 1];
        Contact testContact = new Contact (AccountId=listAcc[0].Id, FirstName = 'Con', LastName = 'Test', Phone='3213213211');
        insert  testContact;
        system.assertEquals(listAcc[0].id, testContact.AccountId);
        PageReference  pr=new PageReference('/apex/SyncToPartnerPortal?id='+listAcc[0].id);
        Test.setCurrentPage(pr);
        VFCntrlr_SyncToPartnerPortal controller = new VFCntrlr_SyncToPartnerPortal();            
        controller.integratePartnerData();
        VFCntrlr_SyncToPartnerPortal.checkResponse('<InsertSegmentationDataResult>true</InsertSegmentationDataResult>');
        VFCntrlr_SyncToPartnerPortal.checkResponse('response');
        PageReference  pr1=new PageReference('/apex/SyncToPartnerPortal?id='+testContact.id);
        Test.setCurrentPage(pr1);
        VFCntrlr_SyncToPartnerPortal controller1 = new VFCntrlr_SyncToPartnerPortal();            
        controller1.integratePartnerData();
        VFCntrlr_SyncToPartnerPortal.checkExistingCont('ContactId is already associated with a different Parent');
        VFCntrlr_SyncToPartnerPortal.checkExistingCont('res');
        controller1.isSuccessContact = false;
        controller1.isExistContact=true;
        controller1.ok();
        test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
}
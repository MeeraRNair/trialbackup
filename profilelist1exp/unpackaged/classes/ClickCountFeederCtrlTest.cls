/*****************************************************************************************************************
* Name          : ClickCountFeederCtrlTest
* Description   : To Test the code coverage of ClickCountFeederCtrlTest
* ---------------------------------------------------------
* Revision  Name                Date                Description
* 1.0       Jessie              8th March 2017      CR14055: Story 3089187:SFDC Resource Centre Link Updates & Tracking 
******************************************************************************************************************/

@isTest

private class ClickCountFeederCtrlTest {
    
    private static ClickCountSetup__c objTestSetupMetadata ;
    
    private static testMethod void testSFDCResourceCentre(){
        
        createClickCountSetupMetadata();

        Test.startTest();
                
        PageReference ClickCountFeederPage =Page.ClickCountFeeder;
        
        ClickCountFeederPage.getParameters().put('name','Test_Test');
        
        Test.SetCurrentPage(ClickCountFeederPage);
        
        ClickCountFeederCtrl clickCountFeeder = new ClickCountFeederCtrl ();
        clickCountFeeder.routeToLink();
        
        System.assertEquals(objTestSetupMetadata.Route_To_URL__c , clickCountFeeder.objClickCountSetup.Route_To_URL__c);
        System.assertEquals(objTestSetupMetadata.Object_Name__c, clickCountFeeder.objClickCountSetup.Object_Name__c);
        System.assertEquals(objTestSetupMetadata.Region__c, clickCountFeeder.objClickCountSetup.Region__c);
        System.assertEquals(null, clickCountFeeder.strRecordId);
        System.assertEquals(objTestSetupMetadata.Source__c, clickCountFeeder.objClickCountSetup.Source__c);
        System.assertEquals(objTestSetupMetadata.User_Action__c, clickCountFeeder.objClickCountSetup.User_Action__c);        
               
        Test.stopTest(); 
        
    }
    
    private static testMethod void testException(){
        
        createClickCountSetupMetadata();
        
        Test.startTest();
        
        PageReference ClickCountFeederPage =Page.ClickCountFeeder;
        
         ClickCountFeederPage.getParameters().put('name','Test_Test2');
          
        Test.SetCurrentPage(ClickCountFeederPage);
        
        ClickCountFeederCtrl clickCountFeeder = new ClickCountFeederCtrl ();
        clickCountFeeder.routeToLink();
               
        Test.stopTest(); 
        
    }
    
    private static void createClickCountSetupMetadata(){
        
         objTestSetupMetadata = new ClickCountSetup__c (Name='Test_Test', Object_Name__c='Test Object Name', Route_To_URL__c = 'http://www.test.com?abc=abc');
         
         insert objTestSetupMetadata ;
    
    }
}
/***********************************************************
* Name          : VFCntrlr_GoalDealListing
* Description   : Test class for VFCntrlr_GoalDealListing
* ---------------------------------------------------------
* Revision      Name    Date            Description
* 1.0           MenMee  08.03.2010      Creation          
*
*
************************************************************/

@isTest
private class VFCntrlr_GoalDealListingTest{
 @testSetup static void setup() {
        // Create common test OWD settings
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;

        TriggerExecutionControl__c oTec = new TriggerExecutionControl__c();
        oTec.Name = 'Opportunity';
        oTec.RecursiveCount__c = 2;
        insert oTec;

        TriggerExecutionControl__c oliTect = new TriggerExecutionControl__c();
        oliTect.Name = 'OpportunityLineItem';
        oliTect.RecursiveCount__c = 2;
        insert oliTect;

        TriggerExecutionController.setSkipAllTriggers(true);

        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;

        TriggerExecutionController.setSkipAllTriggers(false);
    }
    static list<Opportunity> listOpp;
    static GoalIntegrationUtils.GoalDeal[] listgoalDeals = new GoalIntegrationUtils.GoalDeal[0];    

    static testMethod void vfCntrlrGoalDealListingnoRecordExceptionTest() {
        System.debug('***************** START VFCntrlr_GoalDealListing_noRecordExceptionTest *****************');
        
        listOpp=[Select id from Opportunity Limit 1];
        
        PageReference pageRef = Page.GoalDealCreation;
        Test.setCurrentPage(pageRef);
                             
        ApexPages.Standardcontroller con = new ApexPages.Standardcontroller(listOpp[0]);
        delete listOpp[0];
        
        Test.startTest();   
        VFCntrlr_GoalDealListing controller = new VFCntrlr_GoalDealListing(con);             
        Test.stopTest();
                
        System.assertEquals('Could not find a valid Opportunity record', controller.errorMessage);
                        
        System.debug('***************** END VFCntrlr_GoalDealListing_noRecordExceptionTest *****************');
    }

    static testMethod void vfCntrlrGoalDealListingconnectionFailTest() {
        System.debug('***************** START VFCntrlr_GoalDealListing_connectionFailTest *****************');
        
       // CreateTestData();       
                listOpp=[Select id from Opportunity Limit 1];
        GoalIntegrationUtils.isErrorResponse = true;
        GoalIntegrationUtils.isRunTest = true;      
                        
        PageReference pageRef = Page.GoalDealCreation;
        Test.setCurrentPage(pageRef);
                             
        ApexPages.Standardcontroller con = new ApexPages.Standardcontroller(listOpp[0]);
        
        Test.startTest();   
        VFCntrlr_GoalDealListing controller = new VFCntrlr_GoalDealListing(con);             
        Test.stopTest();
                
        System.assertEquals('The connection between SFDC and GOAL encountered an error.  Please try again or log a TT via Remedy.', controller.errorMessage);
                        
        System.debug('***************** END VFCntrlr_GoalDealListing_connectionFailTest *****************');
    }    
    
    static testMethod void vfCntrlrGoalDealListingnoDealAssociatedTest() {
        System.debug('***************** START VFCntrlr_GoalDealListing_noDealAssociatedTest *****************');
        
        //CreateTestData();       
                        listOpp=[Select id from Opportunity Limit 1];

        GoalIntegrationUtils.faultCode = 'fault:ven-query-1008';
        GoalIntegrationUtils.isErrorResponse = true;
                        
        PageReference pageRef = Page.GoalDealListing;
        Test.setCurrentPage(pageRef);
                             
        ApexPages.Standardcontroller con = new ApexPages.Standardcontroller(listOpp[0]);
        
        Test.startTest();   
        VFCntrlr_GoalDealListing controller = new VFCntrlr_GoalDealListing(con);             
        Test.stopTest();
                
        System.assertEquals('There is no GOAL deal associated with this opportunity', controller.errorMessage);
                        
        System.debug('***************** END VFCntrlr_GoalDealListing_noDealAssociatedTest *****************');
    }
        
    static testMethod void updateAllWinLossupdateAllDealToWinLoss() {
        System.debug('***************** START updateAllWinLoss_updateAllDealToWinLoss *****************');
        
       // CreateTestData();
                listOpp=[Select id from Opportunity Limit 1];
system.assertNotEquals(listOpp[0].id, null);
        PageReference pageRef = Page.GoalDealListing;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', listOpp[0].Id);
               
        ApexPages.Standardcontroller con = new ApexPages.Standardcontroller(listOpp[0]);
        VFCntrlr_GoalDealListing controller = new VFCntrlr_GoalDealListing(con);
        
        Test.startTest();
        controller.updateAllWinLoss();
        Test.stopTest();        
        
         //TestMethod do not support Web service callouts, just to get the error message        
        //System.assertEquals('A problem has occured: Methods defined as TestMethod do not support Web service callouts, test skipped', controller.errorMessage);                
                
        System.debug('***************** END updateAllWinLoss_updateAllDealToWinLoss *****************');
    }
    
    static testMethod void backToOpportunitybackToOppDetailedPage() {
        System.debug('***************** START backToOpportunity_backToOppDetailedPage *****************');
        
       // CreateTestData();
                listOpp=[Select id from Opportunity Limit 1];

        PageReference pageRef = Page.GoalDealListing;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', listOpp[0].Id);
        
        Test.startTest();
        ApexPages.Standardcontroller con = new ApexPages.Standardcontroller(listOpp[0]);
        VFCntrlr_GoalDealListing controller = new VFCntrlr_GoalDealListing(con);
        string stractualURL = controller.backToOpportunity;
        Test.stopTest();        
        
        System.assertEquals('/'+listOpp[0].Id, stractualURL);
        
        System.debug('***************** END backToOpportunity_backToOppDetailedPage *****************');
    }
    
    static testMethod void previousgoPrevious() {
        System.debug('***************** START Previous_goPrevious *****************');
        
        listOpp=[Select id from Opportunity Limit 1];
        for (Integer inti=0; inti < 25; inti++) {
            GoalIntegrationUtils.GoalDeal goalDeal = new GoalIntegrationUtils.GoalDeal();
            goalDeal.vid = 'G0000123'+inti;
            listgoalDeals.add(goalDeal);            
        }   
        GoalIntegrationUtils.goalDealList = listgoalDeals;
        GoalIntegrationUtils.isRunTest = true;      
                
        PageReference pageRef = Page.GoalDealListing;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', listOpp[0].Id);
        
        ApexPages.Standardcontroller con = new ApexPages.Standardcontroller(listOpp[0]);
        VFCntrlr_GoalDealListing controller = new VFCntrlr_GoalDealListing(con);
        
        Test.startTest();
        controller.Previous();
        Test.stopTest();
        
        System.assertEquals(null, controller.errorMessage);
        
        System.debug('***************** END Previous_goPrevious *****************');
    }
    
    static testMethod void nextgoNext() {
        System.debug('***************** START Next_goNext *****************');
        
        listOpp=[Select id from Opportunity Limit 1];
        for (Integer inti=0; inti < 25; inti++) {
            GoalIntegrationUtils.GoalDeal goalDeal = new GoalIntegrationUtils.GoalDeal();
            goalDeal.vid = 'G0000123'+inti;
            listgoalDeals.add(goalDeal);            
        }   
        GoalIntegrationUtils.goalDealList = listgoalDeals;
        GoalIntegrationUtils.isRunTest = true;      
                
        PageReference pageRef = Page.GoalDealListing;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', listOpp[0].Id);
        
        ApexPages.Standardcontroller con = new ApexPages.Standardcontroller(listOpp[0]);
        VFCntrlr_GoalDealListing controller = new VFCntrlr_GoalDealListing(con);
        
        Test.startTest();
        controller.Next();
        Test.stopTest();
        
        System.assertEquals(null, controller.errorMessage);        
              
        System.debug('***************** END Next_goNext *****************');
    }   
    
    static testMethod void hasPreviousAndNextTest() {
        System.debug('***************** START hasPreviousAndNextTest *****************');
        
        listOpp=[Select id from Opportunity Limit 1];
        
        PageReference pageRef = Page.GoalDealListing;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', listOpp[0].Id);

        ApexPages.Standardcontroller con = new ApexPages.Standardcontroller(listOpp[0]);
        VFCntrlr_GoalDealListing controller = new VFCntrlr_GoalDealListing(con);
                
        Test.startTest();
        boolean bprevAndNext = controller.hasPreviousAndNext;
        Test.stopTest();
        
        System.assertEquals(false, bprevAndNext);    
        
        System.debug('***************** END hasPreviousAndNextTest *****************');
    }

    static testMethod void doBackbackToOppDetailedPage() {
        System.debug('***************** START doBack_backToOppDetailedPage *****************');
        
        listOpp=[Select id from Opportunity Limit 1];
        
        PageReference pageRef = Page.GoalDealListing;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', listOpp[0].Id);
        
        Test.startTest();
        ApexPages.Standardcontroller con = new ApexPages.Standardcontroller(listOpp[0]);
        VFCntrlr_GoalDealListing controller = new VFCntrlr_GoalDealListing(con);
        string stractualURL = controller.doBack().getURL();
        Test.stopTest();        
        
        System.assertEquals('/'+listOpp[0].Id, stractualURL);
        
        System.debug('***************** END doBack_backToOppDetailedPage *****************');
    }
        
   /* private static void CreateTestData() {
        
       /* Account testAccount = new Account(name = 'Test Account');
        insert testAccount;
        
        RecordType rectype=[Select Name, Id From RecordType where Name='Standard Opportunity' Limit 1];     
        testOpp = new Opportunity(RecordTypeId= rectype.Id, 
                                Name='Test Opportunity', AccountId= testAccount.Id, CurrencyIsoCode='USD',
                                Type='Deal/Bid Direct', CloseDate= system.today(), 
                                Solution_Type__c='Business Processing',  StageName='Plan - 1%');    
        insert testOpp; 

    }*/
}
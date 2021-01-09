/***********************************************************
* Name          : GoalIntegrationUtils 
* Description   : All methods for Goal Integration
* ---------------------------------------------------------
* Revision      Release	Name    Date            Description
* 1.0           11.10	MenMee  09.08.2010		CR2688 Migrate Dell Portal functionality to SFDC to capture Software and Peripherals deals         
*
*
************************************************************/

@isTest
private class VFCntrlr_SnPRecalculateTest {
    static list<Opportunity> listOpp;
    @testSetup static void setup() {
        OWD__c owdsetting = new OWD__c();
        owdsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdsetting.Oppty_Stage10__c = 'Discover - 10%';
        owdsetting.Oppty_Stage100__c = 'Win - 100%';
        owdsetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdsetting.Oppty_Stage60__c = 'Propose - 60%';
        owdsetting.Oppty_Stage90__c = 'Commit - 90%';
        owdsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdsetting.Oppty_Stage1__c = 'Plan - 1%';
        insert owdsetting;
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTdf;
        list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(1, 'Standard Opportunity');
        listOppTdf[0].AccountId=listAccTdf[0].id;
        insert listOppTdf;
    }   
    
    static testMethod void vfCntrlrSnPRecalculateRefreshTest() {
        System.debug('***************** START VFCntrlr_SnPRecalculate_RefreshTest *****************');
        
        //TestDataCreation();
        listOpp=[select id from Opportunity Limit 1];
        PageReference pageRef = page.SnPRecalculate;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('OppId', listOpp[0].Id);
        
        ApexPages.StandardController con = new ApexPages.Standardcontroller(listOpp[0]);		
        Test.startTest();
        VFCntrlr_SnPRecalculate controller = new VFCntrlr_SnPRecalculate(con);								
        controller.recalculateAll();
        Test.stopTest();
        
        System.assert(!controller.isError);
        System.assertEquals('Done', controller.statusMessage);
        System.assertEquals(0, [SELECT Count() FROM S_P_Vendors__c WHERE Opportunity__r.Id =:listOpp[0].Id]);
        
        System.debug('***************** END VFCntrlr_SnPRecalculate_RefreshTest *****************');
    }
    
    static testMethod void vfCntrllrSnPRecalculatenoRecordExceptionTest() {
        System.debug('***************** START VFCntrllr_SnP_Recalculate_noRecordExceptionTest *****************');
        
        //TestDataCreation();
        listOpp=[select id from Opportunity Limit 1];
        PageReference pageRef = page.SnPRecalculate;
        Test.setCurrentPage(pageRef);
        
        ApexPages.Standardcontroller con = new ApexPages.StandardController(listOpp[0]);				
        Test.startTest();
        VFCntrlr_SnPRecalculate controller = new VFCntrlr_SnPRecalculate(con);		
        
        System.assertEquals(null, controller.recalculateAll());
        System.assert(controller.isError);		
        System.assertEquals('/006/o', controller.backToOpportunity().getURL());
        
        controller.isFromTest = true; 
        controller.recalculateAll();
        Test.stopTest();
        System.assert(StringUtils.contains(controller.statusMessage, 'A problem has occured:' ));
        
        System.debug('***************** END VFCntrllr_SnP_Recalculate_noRecordExceptionTest *****************');
    }
    
    static testMethod void backToOpportunityTest() {
        System.debug('***************** START backToOpportunityTest *****************');
        
        //TestDataCreation();
        listOpp=[select id from Opportunity Limit 1];
        
        PageReference pageRef = page.SnPRecalculate;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('OppId', listOpp[0].Id);		
        ApexPages.Standardcontroller con = new ApexPages.StandardController(listOpp[0]);					
        VFCntrlr_SnPRecalculate controller = new VFCntrlr_SnPRecalculate(con);
        
        System.assertEquals('/'+listOpp[0].Id, controller.backToOpportunity().getURL());
        
        System.debug('***************** END backToOpportunityTest *****************');		
    }
    
    /*private static void TestDataCreation() {

/*Account testAcc = new Account(Name = 'Test Account');
insert testAcc;

//Opportunity
testOpp = new Opportunity(Name='Test Opp', recordtypeid='012A0000000TWOi',
Skip_Calculate_LOT_OCEAN__c=true, StageName = 'Discover - 10%',
CloseDate = System.today() + 30,
Primary_Product_Delivery_Address_Region__c = 'APJ',
Primary_Product_Delivery_Address_Country__c = 'MALAYSIA',
AccountId = testAcc.Id);
insert testOpp;

}*/
    
}
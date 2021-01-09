/**************************************************************
* Name          : VFC_AccountPlanSummaryTest
* Description   : Test class for  VFC_AccountPlanSummary
*
* Version        Date        Author                 Remark
* -------------------------------------------------------------
* 1.0           6/01/2015    Shahiruni Wahida       CR 11515
***************************************************************/

@isTest
public class VFC_AccountPlanSummaryTest {
    static SFDC_Acct_Plan__c testAccountPlan;
    static Account testAccount;
    static VFC_AccountPlanSummary aps;
    static Contact testContact;
    static User APOwner;
    static User salesManager;
    
    
    // test refresh
    static testMethod void testRefresh(){
        aps = new VFC_AccountPlanSummary();
        aps.theRefresh();
    }
    
    
    // test APS view acc plan status - pending, waiting for strat, submit for appr
    static testMethod void test_APLStatus(){
        test.startTest();
        TriggerExecutionController.setSkipallTriggers(true);
        aps = new VFC_AccountPlanSummary();
        
        createTestData();
        
        PageReference p = Page.AccountPlanSummary;
        Test.setcurrentpage(p);
        apexpages.currentpage().getparameters().put('id',testAccountPlan.id);

        aps.getAccPlans();
        
        System.assertEquals(testAccountPlan.Plan_Status__c, null);
        TriggerExecutionController.setSkipallTriggers(false);
        test.stopTest();
    }
    
    
    static testMethod void testPending_APLStatus(){
        test.startTest();
        TriggerExecutionController.setSkipallTriggers(true);
        aps = new VFC_AccountPlanSummary();
        
        createTestData();
        
        testAccountPlan.Plan_Status__c = 'Pending';
        update testAccountPlan;
        
        PageReference p = Page.AccountPlanSummary;
        Test.setcurrentpage(p);
        apexpages.currentpage().getparameters().put('id',testAccountPlan.id);

        aps.getAccPlans();
        
        System.assertEquals(testAccountPlan.Plan_Status__c, 'Pending');
        TriggerExecutionController.setSkipallTriggers(false);
        test.stopTest();
    }
    
    
    // test APS view acc plan status - rev and appr
    static testMethod void testRAA_APLStatus(){
        test.startTest();
        TriggerExecutionController.setSkipallTriggers(true);
        aps = new VFC_AccountPlanSummary();
        
        createTestData();
        
        testAccountPlan.Plan_Status__c = 'Reviewed and Approved';
        update testAccountPlan;
        
        PageReference p = Page.AccountPlanSummary;
        Test.setcurrentpage(p);
        apexpages.currentpage().getparameters().put('id',testAccountPlan.id);
        
        aps.getAccPlans();
        
        System.assertEquals(testAccountPlan.Plan_Status__c, 'Reviewed and Approved');
        TriggerExecutionController.setSkipallTriggers(false);
        test.stopTest();
    }
    
    
    // test APS view acc plan status - rejected
    static testMethod void testRejected_APLStatus(){
        test.startTest();
        TriggerExecutionController.setSkipallTriggers(true);
        aps = new VFC_AccountPlanSummary();
        
        createTestData();
        
        testAccountPlan.Plan_Status__c = 'Rejected';
        update testAccountPlan;
        
        PageReference p = Page.AccountPlanSummary;
        Test.setcurrentpage(p);
        apexpages.currentpage().getparameters().put('id',testAccountPlan.id);
        
        aps.getAccPlans();
        
        System.assertEquals(testAccountPlan.Plan_Status__c, 'Rejected');
        TriggerExecutionController.setSkipallTriggers(false);
        test.stopTest();
    }
    
    
    // test APS view contact with Main_Contact__c true 
    static testMethod void testMainContactTrue_APLStatus(){
        test.startTest();
        TriggerExecutionController.setSkipallTriggers(true);
        aps = new VFC_AccountPlanSummary();
        
        createTestData();
        
        testContact.Main_Contact__c = true;
        update testContact;
        
        PageReference p = Page.AccountPlanSummary;
        Test.setcurrentpage(p);
        apexpages.currentpage().getparameters().put('id',testAccountPlan.id);
        
        aps.getAccPlans();
        
        integer APLCount = [SELECT COUNT() 
                                FROM Contact 
                                WHERE AccountId = :testAccountPlan.Account__c 
                                AND Main_Contact__c = true];
                                
        System.assertEquals(1, APLCount);
        TriggerExecutionController.setSkipallTriggers(false);
        test.stopTest();
    }
    
    
    // test APS view contact with Main_Contact__c false 
    static testMethod void testMainContactFalse_APLStatus(){
        Test.startTest();
        TriggerExecutionController.setSkipallTriggers(true);
        aps = new VFC_AccountPlanSummary();
        
        createTestData();
        
        testContact.Main_Contact__c = false;
        update testContact;
        
        PageReference p = Page.AccountPlanSummary;
        Test.setcurrentpage(p);
        apexpages.currentpage().getparameters().put('id',testAccountPlan.id);
        
        aps.getAccPlans();
        
        integer APLCount = [SELECT COUNT() 
                                FROM Contact 
                                WHERE AccountId = :testAccountPlan.Account__c 
                                AND Main_Contact__c = true];
                                
        System.assertEquals(0, APLCount);
        TriggerExecutionController.setSkipallTriggers(false);
        Test.stopTest();
    }

    //insert Custom Setting for test classes - Afiq FY180203 8 Feb 2018- START
    @testSetup static void setup() {
        OWD__c OWDsetting = new OWD__c();
        OWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        OWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        OWDsetting.Oppty_Stage100__c = 'Win - 100%';
        OWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        OWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        OWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        OWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        OWDsetting.Oppty_Stage1__c = 'Plan - 1%';
        insert OWDsetting;
    }   
    //insert Custom Setting for test classes - Afiq FY180203 8 Feb 2018 - END
    
    
    // create test data
    static void createTestData(){
        Profile profile = [select Id from profile where Name = 'System Administrator' limit 1];
        
        //Create a user with Standard User profile
        User recordCreator = new User(Username = 'TestValidUser1' + '@dell.com',
                            Alias = 'Test', 
                            Email = 'Test212'+'@dell.com', 
                            LastName = 'Test22',
                            Title = 'GCC Program Manager', 
                            ProfileId = profile.Id, 
                            LanguageLocaleKey = 'en_US', 
                            LocaleSidKey = 'en_US', 
                            EmailEncodingKey = 'UTF-8', 
                            TimeZoneSidKey = 'America/Los_Angeles',
                            Country = 'US',
                            Badge_Number__c = 'Test'+System.currentTimeMillis());
        insert recordCreator;
        
        APOwner = new User(Username = 'TestValidUser3' + '@dell.com',
                            Alias = 'Test', 
                            Email = 'Test213'+'@dell.com', 
                            LastName = 'Test33',
                            Title = 'GCC Program Manager', 
                            ProfileId = profile.Id, 
                            LanguageLocaleKey = 'en_US', 
                            LocaleSidKey = 'en_US', 
                            EmailEncodingKey = 'UTF-8', 
                            TimeZoneSidKey = 'America/Los_Angeles',
                            Country = 'US',
                            Badge_Number__c = 'Test'+System.currentTimeMillis());
        insert APOwner;
        
        salesManager = new User(Username = 'TestValidUser2' + '@dell.com',
                            Alias = 'Test', 
                            Email = 'Test212'+'@dell.com', 
                            LastName = 'Test22',
                            Title = 'GCC Program Manager', 
                            ProfileId = profile.Id, 
                            LanguageLocaleKey = 'en_US', 
                            LocaleSidKey = 'en_US', 
                            EmailEncodingKey = 'UTF-8', 
                            TimeZoneSidKey = 'America/Los_Angeles',
                            Country = 'US',
                            Badge_Number__c = 'Test'+System.currentTimeMillis());
        insert salesManager;
        
        
        System.runAs(recordCreator) {
            //Create Account
            testAccount = new Account(Name = 'Test Account for Account Plan Test', Type = 'End User', Participating_in_LOB_Program__c = true, OwnerId = recordCreator.Id);
            insert testAccount;
            
            //Create Contact`
            testContact = new Contact (Main_Contact__c = true, AccountId=testAccount.Id, FirstName = 'Con', LastName = 'Test', Phone='3213213211', Email='test@dell.com', Partner_My_Account_GUID__c = '0d37f1ab-c49b-4c11-9d1d-45acd229a989');
            insert testContact;
            
            testAccountPlan = new SFDC_Acct_Plan__c(Account__c = testAccount.Id, Name = 'TestAccPlan', 
                                //Account_Plan_ID__c = 'AP-123456',
                                Plan_Starting_Fiscal_Year__c = 'FY15',
                                Business_Description__c = 'testAP desc',
                                Customer_Industry_Challenges__c = 'testAP cip',
                                Overall_Customer_Short_Term_Goals__c = '5',
                                Overall_Customer_Long_Term_Goals__c = '14',
                                Last_4Q_Revenue__c = 1100.00,
                                X4Q_Revenue_Plan__c = 2100.00,
                                Last_4Q_Margin__c = 3100.00,
                                Sponsor_Champion__c = testContact.Id, 
                                Account_Plan_Owner__c = APOwner.Id,
                                Dell_Executive_Sponsor__c = APOwner.Id,
                                Account_Executive__c = APOwner.Id,
                                Inside_Sales_Representative__c = APOwner.Id,
                                Sales_Manager__c = salesManager.Id, 
                                Go_To_Market_Approach__c = 'Indirect',
                                Go_To_Market_Approach_Comments__c = 'testAP GTM comment', 
                                Dell_s_Value_Proposition__c = 'testAP GTM dvp',
                                Anticipated_IT_Spend_with_Dell__c = 290.00,
                                //Plan_Status__c = 'Reviewed and Approved',
                                Account_Annual_IT_Spend__c = 280.00 
                                );
            insert testAccountPlan;
            
            SFDC_Strategy__c testStrategy1 = new SFDC_Strategy__c(Name = 'Test Strategy 01', SFDC_Acct_Plan__c = testAccountPlan.Id, Potential_Strategy_Value__c=680000, When_do_you_plan_to_realize_Strategy__c='2nd Q (This FY)', Which_LOB_will_you_offer__c='Services');
            SFDC_Strategy__c testStrategy2 = new SFDC_Strategy__c(Name = 'Test Strategy 02', SFDC_Acct_Plan__c = testAccountPlan.Id, Potential_Strategy_Value__c=355000, When_do_you_plan_to_realize_Strategy__c='3rd Q (This FY)');
            
            List<SFDC_Strategy__c> testStrategyList = new List<SFDC_Strategy__c>();
            testStrategyList.add(testStrategy1);
            testStrategyList.add(testStrategy2);
                    
            insert testStrategyList;          
            
            TriggerControlHandler.setOpportunityTriggersInactive();
                    
            Opportunity testOppty1 = new Opportunity(Name='Test Oppty1',AccountId=testAccount.Id,StageName='Plan - 1%',CloseDate=System.Today()+20, Amount=355000, Related_Strategy__c=testStrategy1.Id);
            insert testOppty1;       
                     
            TriggerControlHandler.setOpportunityTriggersActive();
        }
    }
}
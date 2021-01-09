@isTest
private class AccountPlanBeforeInsertBeforeUpdateTest {
    private static Account testAccount;
    private static SFDC_Acct_Plan__c testAccPlan;
    
    
    private static testMethod void test() {
        Map<String, Id> userMap = new Map<String, Id>();
        
        createTestData();
        
        Test.startTest();
        List<AccountTeamMember> queryAccTM = [SELECT AccountId,Id,UserId,User.Title FROM AccountTeamMember WHERE AccountId = :testAccount.id AND User.Title IN ('SVC_ASE', 'SVC_CE') ORDER BY LastModifiedDate];
        System.assertEquals(2, queryAccTM.size());

        if(!queryAccTM.isEmpty() & queryAccTM.size() > 0){
            for(AccountTeamMember atm: queryAccTM){
                if(atm != null){
                    if(atm.User.Title == 'SVC_ASE'){
                        userMap.put('SVC_ASE_'+atm.AccountId, atm.User.Id);
                    }
                    if(atm.User.Title == 'SVC_CE'){
                        userMap.put('SVC_CE_'+atm.AccountId, atm.User.Id);
                    }       
                }
            }
        }
        
        List<SFDC_Acct_Plan__c> apList = [SELECT id, RSD_Review_Feedback__c, Services_Account_Sales_Executive__c, Services_Customer_Executive__c, Account__c FROM SFDC_Acct_Plan__c WHERE Account__c = :testAccount.Id];
        List<SFDC_Acct_Plan__c> apListUpdate = new List<SFDC_Acct_Plan__c>();
        for(SFDC_Acct_Plan__c ap: apList){
            ap.Services_Account_Sales_Executive__c = userMap.get('SVC_ASE_'+testAccount.id);
            ap.Services_Customer_Executive__c = userMap.get('SVC_CE_'+testAccount.id);
            ap.RSD_Review_Feedback__c = 'update test RSD review feedback';
            apListUpdate.add(ap);
        }
        update apListUpdate;
        Test.stopTest();
    }
    
    /*private static testMethod void testModifyPlanningYear() {
        
        createTestDataSet2();
        
        Test.startTest();
               
        SFDC_Acct_Plan__c foundAp = [SELECT id, Plan_Starting_Fiscal_Year__c, Calculated_Annual_Value_of_Strategies__c, Account__c FROM SFDC_Acct_Plan__c WHERE Id = :testAccPlan.Id];
        
        System.AssertEquals(foundAp.Calculated_Annual_Value_of_Strategies__c, 1.00);
                
        foundAp.Plan_Starting_Fiscal_Year__c = 'FY17';
        
        update foundAp;
        
        foundAp = [SELECT id, Plan_Starting_Fiscal_Year__c, Calculated_Annual_Value_of_Strategies__c, Account__c FROM SFDC_Acct_Plan__c WHERE Id = :testAccPlan.Id];
        
        System.AssertEquals(foundAp.Calculated_Annual_Value_of_Strategies__c, 2.00);
        
        Test.stopTest();
    }*/
    
    private static void createTestData(){
        List<AccountTeamMember> testATM = new List<AccountTeamMember>();
        AccountTeamMember atm = new AccountTeamMember();
        
        TriggerExecutionController.setSkipAccounttriggers(true);
        //Create test account
        testAccount = new Account(Name='Test Account', Type='End User');
        insert testAccount;
		
        
        //Create a user with Standard User profile       
        List<User> userList = new List<User>();
        Profile profile = [select id from profile where Name = 'System Administrator' limit 1];
        
        User userRecord = new User(Username='testUser1'+ System.currentTimeMillis()+'@dell.com',
                                        Alias = 'Test1', 
                                        Email='testUser1'+'@dell.com',            
                                        LastName='Test1',
                                        Title='SVC_ASE', 
                                        ProfileId = profile.Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        Country='US',
                                        Badge_Number__c='Test1'+System.currentTimeMillis());
        User userRecord2 = new User(Username='testUser2'+ System.currentTimeMillis()+'@dell.com',
                                        Alias = 'Test2', 
                                        Email='testUser2'+'@dell.com',            
                                        LastName='Test2',
                                        Title='SVC_CE', 
                                        ProfileId = profile.Id, 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        EmailEncodingKey='UTF-8', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        Country='US',
                                        Badge_Number__c='Test2'+System.currentTimeMillis());
        userList.add(userRecord);
        userList.add(userRecord2);
        insert userList;

        //Create Account Plan
        testAccPlan = new SFDC_Acct_Plan__c (name='TestPlan01',Plan_Starting_Fiscal_Year__c= 'FY19', Account__c= testAccount.Id, Sales_Manager__c = userList[0].Id, RSD_Review_Feedback__c ='test RSD review feedback');
        insert testAccPlan;
        
        SFDC_Acct_Plan__c testAccPlan1 = new SFDC_Acct_Plan__c (name='TestPlan01',Plan_Starting_Fiscal_Year__c= 'FY19', Account__c= testAccount.Id, Sales_Manager__c = userList[0].Id, RSD_Review_Feedback__c ='test RSD review feedback', recordtypeId = IdLookupUtils.getRecordTypeId('Channel/Partner Account Plan','SFDC_Acct_Plan__c',true));
        
        Database.SaveResult[] listATMResult = Database.insert(new List<SFDC_Acct_Plan__c>{testAccPlan1},false);
        
        
        //Create Account Team Memmber
        for(integer i=0;i<userList.size();i++){
            atm = new AccountTeamMember (AccountId=testAccount.Id, userId = userList[i].Id, AccountAccessLevel='Read', CaseAccessLevel='Read', OpportunityAccessLevel='Read');
            testATM.add(atm);
        }
        insert testATM;
        TriggerExecutionController.setSkipAccounttriggers(false);
    }

    private static void createTestDataSet2(){
        
        //Create test account
        testAccount = new Account(Name='Test Account', Type='End User');
        insert testAccount;

        //Create Account Plan
        testAccPlan = new SFDC_Acct_Plan__c (name='TestPlan01',Account__c= testAccount.Id, Plan_Starting_Fiscal_Year__c='FY16');
        insert testAccPlan;

        //create strategy
        
        List<SFDC_Strategy__c> strategyList = new List<SFDC_Strategy__c>();
        
        SFDC_Strategy__c StrategyRec1 = new SFDC_Strategy__c(
            SFDC_Acct_Plan__c = testAccPlan.id,
            When_do_you_plan_to_realize_Strategy__c = 'FY16',
            Potential_Strategy_Value__c = 1.00
        );        
        strategyList.add(StrategyRec1);
        
        SFDC_Strategy__c StrategyRec2 = new SFDC_Strategy__c(
            SFDC_Acct_Plan__c = testAccPlan.id,
            When_do_you_plan_to_realize_Strategy__c = 'FY17',
            Potential_Strategy_Value__c = 1.00
        );
        strategyList.add(StrategyRec2);
        
        SFDC_Strategy__c StrategyRec3 = new SFDC_Strategy__c(
            SFDC_Acct_Plan__c = testAccPlan.id,
            When_do_you_plan_to_realize_Strategy__c = 'FY16',
            Potential_Strategy_Value__c = null
        );
        strategyList.add(StrategyRec3);
        
        SFDC_Strategy__c StrategyRec4 = new SFDC_Strategy__c(
            SFDC_Acct_Plan__c = testAccPlan.id,
            When_do_you_plan_to_realize_Strategy__c = 'FY17',
            Potential_Strategy_Value__c = 1.00
        );
        strategyList.add(StrategyRec4);
        
        insert strategyList ;
        
    }
    
}
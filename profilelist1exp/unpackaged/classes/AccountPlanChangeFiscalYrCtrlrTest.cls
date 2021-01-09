@isTest
public class AccountPlanChangeFiscalYrCtrlrTest {
    static User userRecord;
    static User salesMgr;
    static User pdmMgr;
    static CustomerInteraction__c  tripRecordAcc;
    static Accnt_Plan_Target_FY__c testAccPlanTgtFY;
    static  AccountPlanChangeFiscalYrCtrlr controller;
    private static Account testAccount;
    private static SFDC_Acct_Plan__c testAccPlan;
    private static SFDC_Strategy__c testStrategy;
    private static SFDC_Strategy__c testStrategy1;
    private static SFDC_Strategy__c testPartnerStrategy;
    private static SFDC_Strategy__c testPartnerStrategy1;
    private static SFDC_Acct_Plan__c testPartnerAccountPlan;
    private static Partner_Business_Enablement__c testPartnerBizEnablement;
    private static Partner_Detailing__c testPartnerDetailing;
    static Id partnerAccPlanRTId= IdLookupUtils.getRecordTypeId('Channel/Partner Account Plan','SFDC_Acct_Plan__c',true);
    static  Id directAccPlanRTId= IdLookupUtils.getRecordTypeId('Direct Relationship Account Plan','SFDC_Acct_Plan__c',true);
    
    static void TestDataCreation() {
        //Create a user with Standard User profile      
        Profile profile = [select Id from profile where Name = 'System Administrator' limit 1];
        
        userRecord = new User(Username = 'TestValidUser1@dell.com',
                              Alias = 'Test', 
                              Email = 'Test212@dell.com', 
                              LastName = 'Test22',
                              Title = 'GCC Program Manager', 
                              ProfileId = profile.Id, 
                              LanguageLocaleKey = 'en_US', 
                              LocaleSidKey = 'en_US', 
                              EmailEncodingKey = 'UTF-8', 
                              TimeZoneSidKey = 'America/Los_Angeles',
                              Country = 'US',
                              Badge_Number__c = 'Test' + System.currentTimeMillis());
        //insert userRecord;
        userRecord = [ select Id from User where Id = :UserInfo.getUserId() ];
        salesMgr = new User(Username = 'TestValidUserAccPlan2@dell.com',
                            Alias = 'Test', 
                            Email = 'Test212@dell.com', 
                            LastName = 'Test22',
                            Title = 'GCC Program Manager', 
                            ProfileId = profile.Id, 
                            LanguageLocaleKey = 'en_US', 
                            LocaleSidKey = 'en_US', 
                            EmailEncodingKey = 'UTF-8', 
                            TimeZoneSidKey = 'America/Los_Angeles',
                            Country = 'US',
                            Badge_Number__c = 'Test' + System.currentTimeMillis());
        insert salesMgr;
        
        pdmMgr = new User(Username = 'TestPDM@dell.com',
                          Alias = 'Test', 
                          Email = 'TestPDM@dell.com', 
                          LastName = 'Testpdm22',
                          Title = 'GCC Program Manager', 
                          ProfileId = profile.Id, 
                          LanguageLocaleKey = 'en_US', 
                          LocaleSidKey = 'en_US', 
                          EmailEncodingKey = 'UTF-8', 
                          TimeZoneSidKey = 'America/Los_Angeles',
                          Country = 'US',
                          Badge_Number__c = 'Tst' + System.currentTimeMillis());
        insert pdmMgr;
        
        
        
        Date startDate = Date.today().addMonths(-3);//Date.newInstance(2018, 01, 01);
        Date endDate = Date.today().addYears(1);//Date.newInstance(2019, 12, 31);
        
        //Create a value in the  Custom Setting "Account Plan - Change FY" for the current Test FY
        
        
        
        
        System.runAs(userRecord) {
            
            testAccPlanTgtFY=new Accnt_Plan_Target_FY__c(Name='AccountPlanChangeFY17Test',Target_FY__c=19,start_date__c=startDate,end_date__c=endDate);
            insert testAccPlanTgtFY;
            //Create Account
            TriggerExecutionController.setSkipAccountTriggers(true);
            testAccount = new Account(Name = 'Test EU Account for Account Plan Test', Type = 'End User', Participating_in_LOB_Program__c = true, OwnerId = userRecord.Id);
            insert testAccount;
            TriggerExecutionController.setSkipAccountTriggers(false);
            //Create Trip Report
            
            tripRecordAcc = new CustomerInteraction__c();
            tripRecordAcc.Name = 'testTripRecord'; 
            tripRecordAcc.Goal_Objective__c = 'testGoal';
            tripRecordAcc.Type__c = 'testType';
            tripRecordAcc.Date__c = System.Today();
            tripRecordAcc.Account__c = testAccount.Id;
            insert tripRecordAcc; 
        }
        
    }
    
    static void TestDataCreationForSFDCUser(){
        
        System.runAs(userRecord) {
            //Create Account Plan for the Account
            testAccPlan= new SFDC_Acct_Plan__c(Name = 'TestPlan01', Account__c = testAccount.Id, Sales_Manager__c = salesMgr.Id , Approved_by_Sales_Management__c=null,Manager__c=null,RecordTypeId=directAccPlanRTId,Plan_Starting_Fiscal_Year__c='FY19');
            
            insert testAccPlan;
            
            List<AccountTeamMember> atmArray=new List<AccountTeamMember>();
            AccountTeamMember atm01=new AccountTeamMember(userId=salesMgr.Id,TeamMemberRole='Account Executive',accountId = testAccount.Id); 
            atmArray.add(atm01);
            AccountTeamMember atm02=new AccountTeamMember(userId=pdmMgr.Id,TeamMemberRole='Inside Sales Rep',accountId = testAccount.Id); 
            atmArray.add(atm02);
            
            insert atmArray;
            
            
            //Create Strategy for Account Plan
            
            List<SFDC_Strategy__c> strategyList = new List<SFDC_Strategy__c>();
            testStrategy=new SFDC_Strategy__c(Name='TestStrategy',SFDC_Acct_Plan__c=testAccPlan.Id,Customer_Business_Challenges_Objectives__c='Test Customer Objectives',IT_Implications__c='Test IT Implications',Dell_s_Strategy_Response__c='Test Dell Proposed Solution',When_do_you_plan_to_realize_Strategy__c='FY17',Which_LOB_will_you_offer__c='Services',Region__c='APJ',Potential_Strategy_Value__c=12,Strengths__c='Test Soln Strengths',Threats__c='Test threats');
            testStrategy1=new SFDC_Strategy__c(Name='TestStrategy1',SFDC_Acct_Plan__c=testAccPlan.Id,Customer_Business_Challenges_Objectives__c='Test Customer Objectives',IT_Implications__c='Test IT Implications',Dell_s_Strategy_Response__c='Test Dell Proposed Solution',When_do_you_plan_to_realize_Strategy__c='FY18',Which_LOB_will_you_offer__c='Services',Region__c='APJ',Potential_Strategy_Value__c=12,Strengths__c='Test Soln Strengths',Threats__c='Test threats');
            strategyList.add(testStrategy);
            strategyList.add(testStrategy1);
            //insert testStrategy;
            //insert testStrategy1;
            insert strategyList;
            
            //Create Notes & Attachments:
            
            Blob attachmentBody = Blob.valueOf('TestAttachmentBody TestAttachmentBody TestAttachmentBody');
            Attachment testAttachment=new Attachment(Name = 'TestAttachment', Body = attachmentBody, ParentId=testAccPlan.Id,description='test attachment description');
            insert testAttachment;
            
            Note testNote=new Note( Body = 'TestNoteBody TestNoteBody TestAttachmentBody', ParentId=testAccPlan.Id,Title='TestNoteTitle',IsPrivate=True);
            insert testNote;
            
            // Add parameters to page URL
            
            ApexPages.currentPage().getParameters().put('id', String.valueOf(testAccPlan.id));
            System.debug(ApexPages.currentPage().getParameters().get('id'));
            Map<String, Id> userMap = new Map<String, Id>();
            
            
            controller=new AccountPlanChangeFiscalYrCtrlr(new ApexPages.StandardController(testAccPlan));
            integer testnextFiscalYear=controller.nextFiscalYear;
            boolean testisException=controller.isException;
            string testexceptionMessageDetail=controller.exceptionMessageDetail;
            string testexceptionMessageTitle=controller.exceptionMessageTitle;
            
        }   
        
    }
    
    static void TestDataCreationForPartner(){
        
        System.runAs(userRecord) {
            //Create Partner Account Plan for the Account
            testPartnerAccountPlan = new SFDC_Acct_Plan__c(Name = 'TestPlan01', Account__c = testAccount.Id, Manager__c = pdmMgr.Id , Approved_by_Sales_Management__c=null,RecordTypeId=partnerAccPlanRTId);
            insert testPartnerAccountPlan;
            
            //Create Partner Strategy for Account Plan
            
            testPartnerStrategy = new SFDC_Strategy__c(Name='TestStrategy',SFDC_Acct_Plan__c=testPartnerAccountPlan.Id,Customer_Business_Challenges_Objectives__c='Test Customer Objectives',IT_Implications__c='Test IT Implications',Dell_s_Strategy_Response__c='Test Dell Proposed Solution',When_do_you_plan_to_realize_Strategy__c='FY116',Which_LOB_will_you_offer__c='Services',Region__c='APJ',Potential_Strategy_Value__c=12,Strengths__c='Test Soln Strengths',Threats__c='Test threats');
            
            testPartnerStrategy1=new SFDC_Strategy__c(Name='TestStrategy1',SFDC_Acct_Plan__c=testPartnerAccountPlan.Id,Customer_Business_Challenges_Objectives__c='Test Customer Objectives',IT_Implications__c='Test IT Implications',Dell_s_Strategy_Response__c='Test Dell Proposed Solution',When_do_you_plan_to_realize_Strategy__c='FY18',Which_LOB_will_you_offer__c='Services',Region__c='APJ',Potential_Strategy_Value__c=12,Strengths__c='Test Soln Strengths',Threats__c='Test threats');
            
            insert testPartnerStrategy;
            insert testPartnerStrategy1;
            
            //Create Notes & Attachments:
            
            Blob attachmentBody = Blob.valueOf('TestAttachmentBody TestAttachmentBody TestAttachmentBody');
            Attachment testAttachment=new Attachment(Name = 'TestAttachment', Body = attachmentBody, ParentId=testPartnerAccountPlan.Id,description='test attachment description');
            insert testAttachment;
            
            Note testNote=new Note( Body = 'TestNoteBody TestNoteBody TestAttachmentBody', ParentId=testPartnerAccountPlan.Id,Title='TestNoteTitle',IsPrivate=True);
            insert testNote;
            
            // Add parameters to page URL
            
            ApexPages.currentPage().getParameters().put('id', String.valueOf(testPartnerAccountPlan.id));
            System.debug(ApexPages.currentPage().getParameters().get('id'));
            Map<String, Id> userMap = new Map<String, Id>();
            controller=new AccountPlanChangeFiscalYrCtrlr(new ApexPages.StandardController(testPartnerAccountPlan));
            
            //Create Partner Business Enablement
            testPartnerBizEnablement= new Partner_Business_Enablement__c (Channel_Plan_Name__c=testPartnerAccountPlan.id,Name='TestPartnerBizEnablement',Initiative_Owner__c=pdmMgr.Id);
            insert testPartnerBizEnablement;
            
            //Create Partner Detailing
            testPartnerDetailing= new Partner_Detailing__c (Partner_Business_Plan_Name__c=testPartnerAccountPlan.id,Name='TestPartnerBizEnablement',Countries_Covered__c='TestCountry');
            insert testPartnerDetailing;
            
            
        }
    }
    
    
    public static testMethod void test_PositiveScenario_DirectAccPlan() {
        //try{
            TriggerExecutionController.setSkipAllTriggers(true);
            ProcessFlowTriggerController.isTest = true;
            TestDataCreation();
            TestDataCreationForSFDCUser();
            TriggerExecutionController.setSkipAllTriggers(true);
            //Map the Trip Report to the appropriate Account Plan
            Test.startTest();
            tripRecordAcc.Related_Account_Plans__c   = testAccPlan.Id;
            update tripRecordAcc;  
            
            controller.changeFY_Yes();  
            controller.changeFY_No();
            
            Test.stopTest();
            
            delete testAccPlan;
        /*}
        
        catch(DMLException de){
            
            System.assert(true, 'DMLException'+de);
            System.debug('DMLException Message::'+de.getMessage());
            
        }
        catch(Exception e){
            
            System.assert(true, 'Exception' + e);
            System.debug('Exception Message::'+e.getMessage());
        }*/
    }
    
    
     // Negative Scenario
    public static testMethod void test_NegativeScenario_DirectAccountPlan() {
        //try{
            ProcessFlowTriggerController.isTest = true;
            TestDataCreation();
            TestDataCreationForSFDCUser();
            Test.startTest();
            testStrategy1.When_do_you_plan_to_realize_Strategy__c='qowiqoiewoerworhteoprtheroiteiroteoterotehtor';
            testStrategy1.Threats__c='qqqqqqqqqqqqqqffffffffffffffffffffffffffffffaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
            update testStrategy1;
            
            
            controller.changeFY_Yes();
            controller.changeFY_No();
            
            Test.stopTest();
        /*}
        
        catch(DMLException de){
            
            System.assert(true, 'DMLException'+de);
            System.debug('DMLException Message::'+de.getMessage());
            
        }
        catch(Exception e){
            
            System.assert(true, 'Exception' + e);
            System.debug('Exception Message::'+e.getMessage());
        }*/
    }
    
    public static testMethod void test_PositiveScenario_PartnerAccPlan() {
        try{
            ProcessFlowTriggerController.isTest = true;
            TestDataCreation();
            TestDataCreationForPartner();
            //Map the Trip Report to the appropriate Account Plan
            
            tripRecordAcc.Related_Account_Plans__c   = testPartnerAccountPlan.Id;
            update tripRecordAcc;  
            
            Test.startTest();
            controller.changeFY_Yes();  
            controller.changeFY_No();
            
            Test.stopTest();
            
        }
        
        catch(DMLException de){
            
            System.assert(true, 'DMLException'+de);
            System.debug('DMLException Message::'+de.getMessage());
            
        }
        catch(Exception e){
            
            System.assert(true, 'Exception' + e);
            System.debug('Exception Message::'+e.getMessage());
        }
    }
    
    
    
}
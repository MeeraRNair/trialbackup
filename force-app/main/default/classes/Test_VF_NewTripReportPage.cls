/***************************************************************************************************


Revision    Name           Date        CR Number    Description
------------------------------------------------------------
1.0         Sriram      07-June-2017    CR 14401     Non SSO Profile Clean Up 
***************************************************************************************************/

//CR 14401 @isTest(SeeAllData = false)
@isTest
private class Test_VF_NewTripReportPage{
    
    public static testmethod void eventTripReport(){
        TriggerExecutionController.setSkipAllTriggers(true);
        
        List<User> testUser = new List<User>();
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name LIKE 'System Administrator' ORDER BY Name DESC LIMIT 1];
        
        testUser.add(new User(Username='testSalesUser001' +'@dell.com',
                              Alias = 'Test1', 
                              Email='testSalesUser1'+'@dell.com',            
                              LastName='Test1',
                              ProfileId = profile.Id, 
                              Badge_Number__c = 'test123', 
                              LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', 
                              EmailEncodingKey='UTF-8', 
                              TimeZoneSidKey='America/Los_Angeles'));
        
        insert testUser;
        TriggerExecutionController.setSkipAccountTriggers(true);
        Account acc = new Account();
        acc.Name = 'testAccount';
        insert acc;
        TriggerExecutionController.setSkipAccountTriggers(false);
        Contact con1 = new Contact();
        con1.LastName  = 'conLastName';
        con1.FirstName = 'conFirstName';
        con1.Email = 'test@test.com';
        con1.AccountId = acc.Id;
        insert con1;
        
        SFDC_Acct_Plan__c ACCPLN= new SFDC_Acct_Plan__c();
        ACCPLN.Name= 'Test';
        ACCPLN.Plan_Starting_Fiscal_Year__c = 'FY16';
        ACCPLN.Account__c = acc.id;
        ACCPLN.Business_Description__c = 'Test';
        ACCPLN.Customer_Industry_Challenges__c = 'Test';
        ACCPLN.Overall_Customer_Short_Term_Goals__c = 'Test';
        ACCPLN.Overall_Customer_Long_Term_Goals__c = 'Test';
        ACCPLN.Last_4Q_Revenue__c = 12;
        ACCPLN.Last_4Q_Margin__c = 23;
        ACCPLN.Sponsor_Champion__c = Con1.id;
        ACCPLN.Account_Executive__c = testUser[0].Id;
        ACCPLN.Account_Plan_Owner__c = testUser[0].Id;
        ACCPLN.Dell_Executive_Sponsor__c = testUser[0].Id;
        ACCPLN.Inside_Sales_Representative__c = testUser[0].Id;
        ACCPLN.Sales_Manager__c = testUser[0].Id;
        ACCPLN.Go_To_Market_Approach__c = 'Direct';
        ACCPLN.Go_To_Market_Approach_Comments__c = 'Test';
        ACCPLN.Risks_and_Mitigation__c = 'Test';
        ACCPLN.Dell_s_Value_Proposition__c = 'Test';
        
        insert ACCPLN;
        
        Opportunity oppRecord = new Opportunity();
        oppRecord.StageName = 'Plan - 1%';
        oppRecord.CloseDate = System.Today();
        oppRecord.Name = 'Test Opp';
        insert oppRecord;
        
        Support_Request__c sQ = new Support_Request__c();
        sQ.Opportunity__c = oppRecord.Id;
        insert sQ;
        
        Related_To_Map__c relatedMap = new Related_To_Map__c();
        relatedMap.Name = Support_Request__c.SObjectType.getDescribe().getKeyPrefix();
        relatedMap.Account_FieldName__c = 'Opportunity__r.AccountId';
        relatedMap.Object_Name__c = 'Support_Request__c';
        insert relatedMap;
        
        CustomerInteraction__c  tripRecordAcc = new CustomerInteraction__c();
        tripRecordAcc.Name = 'testTripRecord'; 
        tripRecordAcc.Goal_Objective__c = 'testGoal';
        tripRecordAcc.Type__c = 'testType';
        tripRecordAcc.Date__c = System.Today();
        tripRecordAcc.Account__c = acc.Id;
        insert tripRecordAcc;
        
        List<Event> eventList = new List<Event>();    
        Event callEvent  = new Event();
        callEvent.OwnerId = UserInfo.GetUserId();
        callEvent.Subject = 'testSubject';
        callEvent.Type = 'Customer Visit';
        callEvent.WhatId = acc.Id;   
        callEvent.WhoId = Con1.Id;  
        callEvent.StartDateTime = System.Now();
        callEvent.EndDateTime = System.Now();
        callEvent.End_in_Mind__c = 'testEnd';
        callEvent.Description ='testDescription';
        callEvent.Agenda__c = 'testAgenda';
        callEvent.Outcome__c = 'testOutcome';
        callEvent.RecordTypeId =[SELECT Id FROM RecordType WHERE SobjectType = 'Event' AND Name LIKE '%Call Plan%' LIMIT 1].Id;
        eventList.add(callEvent);
        
        
     /* Contact con1 = new Contact();
        con1.LastName  = 'conLastName';
        con1.FirstName = 'conFirstName';
        con1.Email = 'test@test.com';
        con1.AccountId = acc.Id;
        insert con1;
        
        Event callEvent1  = new Event();
        callEvent1.OwnerId = UserInfo.GetUserId();
        callEvent1.Subject = 'testSubject';
        callEvent1.Type = 'Customer Visit';
        callEvent1.WhoId = Con1.Id;
        callEvent1.WhatId = acc.Id;
        callEvent1.StartDateTime = System.Now();
        callEvent1.EndDateTime = System.Now();
        callEvent1.End_in_Mind__c = 'testEnd';
        callEvent1.Description ='testDescription';
        callEvent1.Agenda__c = 'testAgenda';
        callEvent1.Outcome__c = 'testOutcome';
        callEvent1.RecordTypeId =[SELECT Id FROM RecordType WHERE SobjectType = 'Event' AND Name LIKE '%Call Plan%' LIMIT 1].Id;
        eventList.add(callEvent1);
        */
        
        Event callStdEvent  = new Event();
        callStdEvent.OwnerId = UserInfo.GetUserId();
        callStdEvent.Subject = 'testSubject';
        callStdEvent.Type = 'testType';
        callStdEvent.WhatId = acc.Id;
        callStdEvent.StartDateTime = System.Now();
        callStdEvent.EndDateTime = System.Now();
        callStdEvent.End_in_Mind__c = 'testEnd';
        callStdEvent.Agenda__c = 'testAgenda';
        callStdEvent.Outcome__c ='testOutcome';
        callStdEvent.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Event' AND Name LIKE '%GBL_Standard_Event_RT%' LIMIT 1].Id;
        eventList.add(callStdEvent);
        
        Event callStdEvent2  = new Event();
        callStdEvent2.OwnerId = UserInfo.GetUserId();
        callStdEvent2.Subject = 'testSubject';
        callStdEvent2.Type = 'testType';
        callStdEvent2.StartDateTime = System.Now();
        callStdEvent2.EndDateTime = System.Now();
        callStdEvent2.End_in_Mind__c = 'testEnd';
        callStdEvent2.Agenda__c = 'testAgenda';
        callStdEvent2.Outcome__c ='testOutcome';
        callStdEvent2.WhatId = sQ.Id;
        callStdEvent2.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Event' AND Name LIKE '%GBL_Standard_Event_RT%' LIMIT 1].Id;
        eventList.add(callStdEvent2);
        
        insert EventList; 
        
        /*** Call Plan Record ***/    
        PageReference pageRef4 =Page.NewTripReportPage;
        Test.setCurrentPage(pageRef4);
        ApexPages.currentPage().getParameters().put('EventId',callEvent.Id);
        ApexPages.currentPage().getParameters().put('retURL',callEvent.Id);    
        ApexPages.StandardController  stdCon4 = new ApexPages.StandardController(tripRecordAcc);
        VF_NewTripReportPage controller4 = new VF_NewTripReportPage(stdCon4);
        controller4.getObjectsList();
        controller4.save();
        controller4.saveNew();
        controller4.cancel();
        
        List<CustomerInteraction__c> tripReportList = [Select Id from CustomerInteraction__c where Account__c =: acc.Id];
        system.assertEquals(2,tripReportList.size());
        
        
        Test.starttest();
        callEvent.Type = 'Meeting (at Customer Site)';
        update callEvent;
        VF_NewTripReportPage controller9 = new VF_NewTripReportPage(stdCon4);
        
        callEvent.Type = 'Partner Meeting';
        update callEvent;
        VF_NewTripReportPage controller10 = new VF_NewTripReportPage(stdCon4);
        
        callEvent.Type = 'EBC';
        update callEvent;
        VF_NewTripReportPage controller11 = new VF_NewTripReportPage(stdCon4);
        /*** Standard Event ***/
        PageReference pageRef8 =Page.NewTripReportPage;
        Test.setCurrentPage(pageRef8);
        ApexPages.currentPage().getParameters().put('EventId',callStdEvent.Id);
        ApexPages.currentPage().getParameters().put('retURL',callStdEvent.Id);    
        ApexPages.StandardController  stdCon8 = new ApexPages.StandardController(tripRecordAcc);
        VF_NewTripReportPage controller8 = new VF_NewTripReportPage(stdCon8); 
        
        PageReference pageRef13 =Page.NewTripReportPage;
        Test.setCurrentPage(pageRef13);
        ApexPages.currentPage().getParameters().put('EventId',callStdEvent2.Id);
        ApexPages.currentPage().getParameters().put('retURL',callStdEvent2.Id);    
        ApexPages.StandardController  stdCon13 = new ApexPages.StandardController(tripRecordAcc);
        VF_NewTripReportPage controller13 = new VF_NewTripReportPage(stdCon13); 
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.Stoptest();
    }    
    public static testmethod void AccountPlanTripRecord(){
        Test.Starttest();
        TriggerExecutionController.setSkipAllTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true);
        Account acc = new Account();
        acc.Name = 'testAccount';
        insert acc;
        TriggerExecutionController.setSkipAccountTriggers(false);
        Contact con = new Contact();
        con.LastName  = 'conLastName';
        con.FirstName = 'conFirstName';
        con.Email = 'test@test.com';
        con.AccountId = acc.Id;
        insert con;
        
        SFDC_Acct_Plan__c accPlan = new SFDC_Acct_Plan__c();
        accPlan.Name = 'testAccPlan';
        accPlan.Plan_Starting_Fiscal_Year__c = 'testFiscalYear';
        accPlan.Account__c = acc.Id;
        accPlan.Sales_Manager__c = UserInfo.GetUserId();
        insert accPlan;
        
        CustomerInteraction__c  tripRecordAccountPlan = new CustomerInteraction__c();
        tripRecordAccountPlan.Name = 'testTripRecord'; 
        tripRecordAccountPlan.Goal_Objective__c = 'testGoal';
        tripRecordAccountPlan.Type__c = 'testType';
        tripRecordAccountPlan.Date__c = System.Today();
        tripRecordAccountPlan.Account__c = acc.Id;
        tripRecordAccountPlan.Customer_Attendee1__c = con.Id;
        tripRecordAccountPlan.Related_Account_Plans__c = accPlan.Id;
        insert tripRecordAccountPlan;
        
        
        /*** Account Plan  ***/
        PageReference pageRef5 =Page.NewTripReportPage;
        Test.setCurrentPage(pageRef5);
        ApexPages.currentPage().getParameters().put('retURL','/'+accPlan.Id);
        ApexPages.StandardController  stdCon5 = new ApexPages.StandardController(tripRecordAccountPlan);
        VF_NewTripReportPage controller5 = new VF_NewTripReportPage(stdCon5);
        
        PageReference pageRef1 =Page.NewTripReportPage;
        Test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('Id',tripRecordAccountPlan.Id);
        ApexPages.currentPage().getParameters().put('retURL','%20'+tripRecordAccountPlan.Id);
        ApexPages.StandardController  stdCon1 = new ApexPages.StandardController(tripRecordAccountPlan);
        VF_NewTripReportPage controller1 = new VF_NewTripReportPage(stdCon1);
        controller1.getObjectsList();    
        controller1.save();
        controller1.saveNew();
        
        PageReference pageRef12 =Page.NewTripReportPage;
        Test.setCurrentPage(pageRef12);
        ApexPages.currentPage().getParameters().put('Id',tripRecordAccountPlan.Id);
        ApexPages.currentPage().getParameters().put('retURL',tripRecordAccountPlan.Id);
        ApexPages.currentPage().getParameters().put('clone','1');    
        ApexPages.StandardController  stdCon12 = new ApexPages.StandardController(tripRecordAccountPlan);
        VF_NewTripReportPage controller12 = new VF_NewTripReportPage(stdCon12);
        controller12.getObjectsList();    
        controller12.save();
        controller12.saveNew();
        List<CustomerInteraction__c> tripReportList = [Select Id from CustomerInteraction__c where Related_Account_Plans__c =: accPlan.Id];
        system.assertEquals(2,tripReportList.size());
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.Stoptest();
    }
    
    public static testmethod  void strategyTripRecord(){
        Test.Starttest();
        TriggerExecutionController.setSkipAllTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true);
        Account acc = new Account();
        acc.Name = 'testAccount';
        insert acc;
        Account acc1 = new Account();
        acc1.Name = 'testAccount1';
        insert acc1;
        TriggerExecutionController.setSkipAccountTriggers(false);
        
        Contact con = new Contact();
        con.LastName  = 'conLastName';
        con.FirstName = 'conFirstName';
        con.Email = 'test@test.com';
        con.AccountId = acc.Id;
        insert con;
        
        SFDC_Acct_Plan__c accPlan = new SFDC_Acct_Plan__c();
        accPlan.Name = 'testAccPlan';
        accPlan.Plan_Starting_Fiscal_Year__c = 'testFiscalYear';
        accPlan.Account__c = acc.Id;
        accPlan.Sales_Manager__c = UserInfo.GetUserId();
        insert accPlan;
        
        
        SFDC_Strategy__c strategy = new SFDC_Strategy__c();
        strategy.Strategy_Owner__c = UserInfo.GetUserId();
        strategy.Name = 'testStrategy';
        strategy.SFDC_Acct_Plan__c = accPlan.Id;
        strategy.Customer_Business_Challenges_Objectives__c = 'testStrategy';
        strategy.Sponsor_Champion__c = con.Id;
        strategy.Business_Priority__c = 'testBusinessPriority';
        strategy.Technology_Priority__c = 'testTechPriority';
        strategy.Dell_s_Strategy_Response__c = 'testResponse';
        strategy.When_do_you_plan_to_realize_Strategy__c = 'testPlan';
        strategy.Region__c = 'testRegion';
        strategy.Which_LOB_will_you_offer__c = 'testLOB';
        strategy.Is_Dell_the_Incumbent_Vendor__c = 'Yes';
        insert strategy;
        
        CustomerInteraction__c  tripRecordStrategy = new CustomerInteraction__c();
        tripRecordStrategy.Name = 'testTripRecord'; 
        tripRecordStrategy.Goal_Objective__c = 'testGoal';
        tripRecordStrategy.Type__c = 'testType';
        tripRecordStrategy.Date__c = System.Today();
        tripRecordStrategy.Account__c = acc.Id;
        tripRecordStrategy.Customer_Attendee1__c = con.Id;
        tripRecordStrategy.Related_Strategy__c = strategy.Id;
        insert tripRecordStrategy;
        
        
        
        /*** Strategy ***/
        
        PageReference pageRef6 =Page.NewTripReportPage;
        Test.setCurrentPage(pageRef6);
        ApexPages.currentPage().getParameters().put('retURL','/'+strategy.Id);
        ApexPages.StandardController  stdCon6 = new ApexPages.StandardController(tripRecordStrategy);
        VF_NewTripReportPage controller6 = new VF_NewTripReportPage(stdCon6);
        
        PageReference pageRef2 =Page.NewTripReportPage;
        Test.setCurrentPage(pageRef2);
        ApexPages.currentPage().getParameters().put('Id',tripRecordStrategy.Id);
        ApexPages.StandardController  stdCon2 = new ApexPages.StandardController(tripRecordStrategy);
        VF_NewTripReportPage controller2 = new VF_NewTripReportPage(stdCon2);
        controller2.getObjectsList();    
        controller2.save();
        controller2.saveNew();
        
        PageReference pageRef12 =Page.NewTripReportPage;
        Test.setCurrentPage(pageRef12);
        ApexPages.currentPage().getParameters().put('Id',tripRecordStrategy.Id);
        ApexPages.currentPage().getParameters().put('retURL',tripRecordStrategy.Id);
        ApexPages.currentPage().getParameters().put('clone','1');    
        ApexPages.StandardController  stdCon12 = new ApexPages.StandardController(tripRecordStrategy);
        VF_NewTripReportPage controller12 = new VF_NewTripReportPage(stdCon12);
        controller12.getObjectsList();    
        controller12.save();
        controller12.saveNew();
        
        List<CustomerInteraction__c> tripReportList = [Select Id from CustomerInteraction__c where Related_Strategy__c =: strategy.Id];
        system.assertEquals(2,tripReportList.size());
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.Stoptest();
    }
    
    public static testmethod void oppTripRecord(){
        Test.Starttest();
        TriggerExecutionController.setSkipAllTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true);
        Account acc = new Account();
        acc.Name = 'testAccount';
        insert acc;
        TriggerExecutionController.setSkipAccountTriggers(false);
        Contact con = new Contact();
        con.LastName  = 'conLastName';
        con.FirstName = 'conFirstName';
        con.Email = 'test@test.com';
        con.AccountId = acc.Id;
        insert con;
        
        Opportunity oppRecord = new Opportunity();
        oppRecord.StageName = 'Plan - 1%';
        oppRecord.CloseDate = System.Today();
        oppRecord.Name = 'Test Opp';
        oppRecord.AccountID=acc.Id;
        ProcessFlowTriggerController.isTest = true;
        insert oppRecord;
        ProcessFlowTriggerController.isTest = false;
        
        CustomerInteraction__c  tripRecordOpp = new CustomerInteraction__c();
        tripRecordOpp.Name = 'testTripRecord'; 
        tripRecordOpp.Goal_Objective__c = 'testGoal';
        tripRecordOpp.Type__c = 'testType';
        tripRecordOpp.Date__c = System.Today();
        tripRecordOpp.Account__c = acc.Id;
        tripRecordOpp.Customer_Attendee1__c = con.Id;
        tripRecordOpp.Related_Opportunity__c  = oppRecord.Id;
        insert tripRecordOpp;
        
        
        // tripRecordOpp.Account__c = acc1.Id;
        /*** Opportunity ***/
        PageReference pageRef7 =Page.NewTripReportPage;
        Test.setCurrentPage(pageRef7);
        ApexPages.currentPage().getParameters().put('retURL','/'+oppRecord.Id);
        ApexPages.StandardController  stdCon7 = new ApexPages.StandardController(tripRecordOpp);
        VF_NewTripReportPage controller7 = new VF_NewTripReportPage(stdCon7);
        
        PageReference pageRef3 =Page.NewTripReportPage;
        Test.setCurrentPage(pageRef3);
        ApexPages.currentPage().getParameters().put('Id',tripRecordOpp.Id);
        ApexPages.StandardController  stdCon3 = new ApexPages.StandardController(tripRecordOpp);
        VF_NewTripReportPage controller3 = new VF_NewTripReportPage(stdCon3);
        controller3.getObjectsList();
        controller3.save();
        controller3.saveNew();
        
        PageReference pageRef12 =Page.NewTripReportPage;
        Test.setCurrentPage(pageRef12);
        ApexPages.currentPage().getParameters().put('Id',tripRecordOpp.Id);
        ApexPages.currentPage().getParameters().put('retURL',tripRecordOpp.Id);
        ApexPages.currentPage().getParameters().put('clone','1');    
        ApexPages.StandardController  stdCon12 = new ApexPages.StandardController(tripRecordOpp);
        VF_NewTripReportPage controller12 = new VF_NewTripReportPage(stdCon12);
        controller12.getObjectsList();    
        controller12.save();
        controller12.saveNew();
        
        List<CustomerInteraction__c> tripReportList = [Select Id from CustomerInteraction__c where Related_Opportunity__c  =: oppRecord.Id];
        system.assertEquals(2,tripReportList.size());
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.Stoptest();
    }  
    
    public static testmethod void conTripRecord(){
        Test.Starttest();
        TriggerExecutionController.setSkipAllTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true);
        Account acc = new Account();
        acc.Name = 'testAccount';
        insert acc;
        TriggerExecutionController.setSkipAccountTriggers(false);
        Contact con = new Contact();
        con.LastName  = 'conLastName';
        con.FirstName = 'conFirstName';
        con.Email = 'test@test.com';
        con.AccountId = acc.Id;
        insert con;
        
        CustomerInteraction__c  tripRecordOpp = new CustomerInteraction__c();
        tripRecordOpp.Name = 'testTripRecord'; 
        tripRecordOpp.Goal_Objective__c = 'testGoal';
        tripRecordOpp.Type__c = 'testType';
        tripRecordOpp.Date__c = System.Today();
        tripRecordOpp.Account__c = acc.Id;
        tripRecordOpp.Customer_Attendee1__c = con.Id;
        insert tripRecordOpp;
        
        
        PageReference pageRef7 =Page.NewTripReportPage;
        Test.setCurrentPage(pageRef7);
        ApexPages.currentPage().getParameters().put('retURL','/'+con.Id);
        ApexPages.StandardController  stdCon7 = new ApexPages.StandardController(tripRecordOpp);
        VF_NewTripReportPage controller7 = new VF_NewTripReportPage(stdCon7);
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.Stoptest();
    }
    
    public static testmethod  void readOnlyProfile(){
        Test.Starttest();
        TriggerExecutionController.setSkipAllTriggers(true);
        CustomerInteraction__c  tripRecordAcc = new CustomerInteraction__c();
        tripRecordAcc.Name = 'testTripRecord'; 
        tripRecordAcc.Type__c = 'testType';
        tripRecordAcc.Date__c = System.Today();
        
        ID p = [Select Id from Profile where Name ='Read Only'].Id;
        User readOnly = new User();
        readOnly.Alias = 'testAl';
        readOnly.CommunityNickname = 'testCommName';
        readOnly.Email = 'test@dell.com';
        readOnly.LastName = 'testLastName';
        readOnly.UserName = 'testLogACall@test.com';
        readOnly.TimeZoneSidKey = 'GMT';
        readOnly.LocaleSidKey = 'en_US';
        readOnly.EmailEncodingKey = 'UTF-8';
        readOnly.ProfileId = p;
        readOnly.IsActive = true;
        readOnly.LanguageLocaleKey = 'en_US';
        readOnly.Badge_Number__c = 'test123';  
        insert readOnly;
        
        
        System.RunAs(readOnly){
            PageReference pageRef =Page.NewTripReportPage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('retURL','retURL');        
            ApexPages.StandardController  stdCon = new ApexPages.StandardController(tripRecordAcc);
            VF_NewTripReportPage controller = new VF_NewTripReportPage(stdCon);
            
            system.assertEquals(true,controller.errorFlag);                 
        }
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.Stoptest();
    }
    
    public static testmethod  void ExecTripRecord(){
        Test.Starttest();
        TriggerExecutionController.setSkipAllTriggers(True);
        CustomerInteraction__c  tripRecordAcc = new CustomerInteraction__c();
        tripRecordAcc.Name = 'testTripRecord'; 
        tripRecordAcc.Type__c = 'testType';
        tripRecordAcc.Date__c = System.Today();
        
        
        PageReference pageRef =Page.NewTripReportPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('retURL','retURL');        
        ApexPages.StandardController  stdCon = new ApexPages.StandardController(tripRecordAcc);
        VF_NewTripReportPage controller = new VF_NewTripReportPage(stdCon);
        controller.SaveNew();
        controller.Save();
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.Stoptest();
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
    
}
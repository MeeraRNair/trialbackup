@isTest
Public Class AccountPlanNewOverrideController_Test {

    Public Static testmethod void TestController() {
    
        AccountPlanNewOverrideController controller = New AccountPlanNewOverrideController(New ApexPages.StandardController(New Account()));
        controller.createNewAccountPlan();
        controller.redirectBack();
        controller.getHasMessage();
        
        Account testAccount2 = New Account(Name ='Test AccountPlanNewOverrideController',Description = 'Test Test Test', Fiscal_Year_End__c = System.Today());
        insert testAccount2;
        
        User currentUser = [SELECT TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey, ProfileId FROM User WHERE Id=:UserInfo.GetUserId()];
        
        User testUser1 = New User(FirstName ='Test', Badge_Number__c='test1234561', LastName='Test', UserName='testAccountPlanNewOverrideController1@dell.com', ProfileId=currentUser.ProfileId,
                                EmailEncodingKey = currentUser.EmailEncodingKey, LanguageLocaleKey = currentUser.LanguageLocaleKey, Email ='testAccountPlanNewOverrideController@dell.com', Alias='test123', TimeZoneSidKey=currentUser.TimeZoneSidKey, LocaleSidKey=currentUser.LocaleSidKey);
        
        User testUser2 = New User(FirstName ='Test', Badge_Number__c='test1234562', LastName='Test', UserName='testAccountPlanNewOverrideController2@dell.com', ProfileId=currentUser.ProfileId,
                                EmailEncodingKey = currentUser.EmailEncodingKey, LanguageLocaleKey = currentUser.LanguageLocaleKey, Email ='testAccountPlanNewOverrideController@dell.com', Alias='test123', TimeZoneSidKey=currentUser.TimeZoneSidKey, LocaleSidKey=currentUser.LocaleSidKey);
        
        User testUser3 = New User(FirstName ='Test', Badge_Number__c='test1234563', LastName='Test', UserName='testAccountPlanNewOverrideController3@dell.com', ProfileId=currentUser.ProfileId,
                                EmailEncodingKey = currentUser.EmailEncodingKey, LanguageLocaleKey = currentUser.LanguageLocaleKey, Email ='testAccountPlanNewOverrideController@dell.com', Alias='test123', TimeZoneSidKey=currentUser.TimeZoneSidKey, LocaleSidKey=currentUser.LocaleSidKey);
                                
        //5.0 starts
        User testUser4 = New User(FirstName ='Test', Badge_Number__c='test1234564', LastName='Test', UserName='testAccountPlanNewOverrideController4@dell.com', ProfileId=currentUser.ProfileId,
                                EmailEncodingKey = currentUser.EmailEncodingKey, LanguageLocaleKey = currentUser.LanguageLocaleKey, Email ='testAccountPlanNewOverrideController@dell.com', Alias='test123', TimeZoneSidKey=currentUser.TimeZoneSidKey, LocaleSidKey=currentUser.LocaleSidKey);
        User testUser5 = New User(FirstName='Test', Badge_Number__c='test1234565', LastName='Test', UserName='testAccountPlanNewOverrideController5@dell.com', ProfileId=currentUser.ProfileId,
                                EmailEncodingKey=currentUser.EmailEncodingKey, LanguageLocaleKey=currentUser.LanguageLocaleKey,Email='testAccountPlanNewOverrideController@dell.com', Alias='test123', TimeZoneSidKey=currentUser.TimeZoneSidKey, LocaleSidKey=currentUser.LocaleSidKey);
        //5.0 ends
        
        //v9.0 start
        User testUser6 = New User(FirstName ='Test', Badge_Number__c='test1234566', LastName='Test \'1', UserName='testAccountPlanNewOverrideController6@dell.com', ProfileId=currentUser.ProfileId,
                                EmailEncodingKey = currentUser.EmailEncodingKey, LanguageLocaleKey = currentUser.LanguageLocaleKey, Email ='testAccountPlanNewOverrideController@dell.com', Alias='test123', TimeZoneSidKey=currentUser.TimeZoneSidKey, LocaleSidKey=currentUser.LocaleSidKey);
        User testUser7 = New User(FirstName='Test', Badge_Number__c='test1234567', LastName='Test', UserName='testAccountPlanNewOverrideController7@dell.com', ProfileId=currentUser.ProfileId,
                                EmailEncodingKey=currentUser.EmailEncodingKey, LanguageLocaleKey=currentUser.LanguageLocaleKey,Email='testAccountPlanNewOverrideController@dell.com', Alias='test123', TimeZoneSidKey=currentUser.TimeZoneSidKey, LocaleSidKey=currentUser.LocaleSidKey);
        //v9.0 end

         //v10.0 start
        User testUser8 = New User(FirstName ='Test', Badge_Number__c='test1234568', LastName='Test \'1', UserName='testAccountPlanNewOverrideController8@dell.com', ProfileId=currentUser.ProfileId,
                                EmailEncodingKey = currentUser.EmailEncodingKey, LanguageLocaleKey = currentUser.LanguageLocaleKey, Email ='testAccountPlanNewOverrideController@dell.com', Alias='test123', TimeZoneSidKey=currentUser.TimeZoneSidKey, LocaleSidKey=currentUser.LocaleSidKey);
        User testUser9 = New User(FirstName='Test', Badge_Number__c='test1234569', LastName='Test', UserName='testAccountPlanNewOverrideController9@dell.com', ProfileId=currentUser.ProfileId,
                                EmailEncodingKey=currentUser.EmailEncodingKey, LanguageLocaleKey=currentUser.LanguageLocaleKey,Email='testAccountPlanNewOverrideController@dell.com', Alias='test123', TimeZoneSidKey=currentUser.TimeZoneSidKey, LocaleSidKey=currentUser.LocaleSidKey);
        //v10.0 end
        
        List<User> userList = New List<User>();
        userList.add(testUser1 );
        userList.add(testUser2 );
        userList.add(testUser3 ); 
        userList.add(testUser4 ); //5.0
        userList.add(testUser5 ); //5.0
        userList.add(testUser6 ); //9.0
        userList.add(testUser7 ); //9.0
        userList.add(testUser8 ); //10.0
        userList.add(testUser9 ); //10.0
        insert userList;

      
        AccountTeamMember testAE = New AccountTeamMember(TeamMemberROle ='Account Executive', UserId=testUser1.Id, AccountId=testAccount2.Id, AccountAccessLevel='Read', CaseAccessLevel='Read', OpportunityAccessLevel='Read');
        AccountTeamMember testISR = New AccountTeamMember(TeamMemberROle='Inside Sales Rep', UserId=testUser2.Id, AccountId=testAccount2.Id, AccountAccessLevel='Read', CaseAccessLevel='Read', OpportunityAccessLevel='Read');
        AccountTeamMember testRSM = New AccountTeamMember(TeamMemberROle ='Regional Sales Manager', UserId=testUser3.Id, AccountId=testAccount2.Id, AccountAccessLevel='Read', CaseAccessLevel='Read', OpportunityAccessLevel='Read');
        AccountTeamMember testPDM = New AccountTeamMember(TeamMemberROle='Partner Development Manager', UserId=testUser4.Id, AccountId=testAccount2.Id, AccountAccessLevel='Read', CaseAccessLevel='Read', OpportunityAccessLevel='Read');    //5.0
        AccountTeamMember testCAM = New AccountTeamMember(TeamMemberROle ='Inside Channel Account Manager', UserId=testUser5.Id, AccountId=testAccount2.Id, AccountAccessLevel='Read', CaseAccessLevel='Read', OpportunityAccessLevel='Read'); //5.0
        AccountTeamMember testSC = New AccountTeamMember(TeamMemberROle='System Consultant', UserId=testUser6.Id, AccountId=testAccount2.Id, AccountAccessLevel='Read', CaseAccessLevel='Read', OpportunityAccessLevel='Read'); //9.0
        AccountTeamMember testTSR = New AccountTeamMember(TeamMemberROle ='Technical Sales Rep', UserId=testUser7.Id, AccountId=testAccount2.Id, AccountAccessLevel='Read', CaseAccessLevel='Read', OpportunityAccessLevel='Read'); //9.0
        AccountTeamMember testDCSS = New AccountTeamMember(TeamMemberROle='DC Sales Specialist', UserId=testUser8.Id, AccountId=testAccount2.Id, AccountAccessLevel='Read', CaseAccessLevel='Read', OpportunityAccessLevel='Read'); //10.0
        AccountTeamMember testASE = New AccountTeamMember(TeamMemberROle ='Account System Engineer', UserId=testUser9.Id, AccountId=testAccount2.Id, AccountAccessLevel='Read', CaseAccessLevel='Read', OpportunityAccessLevel='Read'); //10.0
    
        List<AccountTeamMember> atmList = New List<AccountTeamMember>();
        atmList.add(testAE );
        atmList.add(testISR );
        atmList.add(testRSM );
        atmList.add(testPDM );  //5.0
        atmList.add(testCAM );  //5.0
        atmList.add(testSC );  //9.0
        atmList.add(testTSR );  //9.0
        atmList.add(testDCSS );  //10.0
        atmList.add(testASE );  //10.0
        insert atmList;
        
        
        list<Account_Plan_Fields__c> apf_customSetting_List = New list<Account_Plan_Fields__c>();
        Account_Plan_Fields__c apf_aplOwner = New Account_Plan_Fields__c(name = 'Account_Plan_Lite_Owner__c', field_id__c = 'xxxxxxxx');
        Account_Plan_Fields__c apf_aplManager = New Account_Plan_Fields__c(name = 'AP_Lite_Manager__c', field_id__c = 'mmmmmmm');
        Account_Plan_Fields__c apf_sc = New Account_Plan_Fields__c(name = 'System_Consultant__c', field_id__c = 'ssssssss');
        Account_Plan_Fields__c apf_tsr = New Account_Plan_Fields__c(name = 'Technical_Sales_Rep__c', field_id__c = 'ttttt');
        Account_Plan_Fields__c apfDCSS = New Account_Plan_Fields__c(name = 'Data_Center_Sales_Executive__c', field_id__c = 'ssssssss'); //10.0
        Account_Plan_Fields__c apfASE = New Account_Plan_Fields__c(name = 'Account_Systems_Engineer__c', field_id__c = 'ttttt'); //10.0
        apf_customSetting_List.add(apf_aplOwner);
        apf_customSetting_List.add(apf_aplManager);
        apf_customSetting_List.add(apf_sc);
        apf_customSetting_List.add(apf_tsr);
        apf_customSetting_List.add(apfDCSS); //10.0
        apf_customSetting_List.add(apfASE);//10.0
        insert apf_customSetting_List;
        
        controller = New AccountPlanNewOverrideController(New ApexPages.StandardController(testAccount2));
        controller.createNewAccountPlan();
        controller.redirectBack();
        controller.getHasMessage();
        
    }
}
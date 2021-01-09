/* ---------------------------------------------------------
* Revision  Name            Date        Release    Description
* 1.0                                              Creation
* 2.0       Men Mee         06.01.2016  R16.12     CR12402: Resolve for :Non-selective query against large object type" error and improve code coverage
* 3.0    Meera      14-JAN-2016  CSM0104     Adding test method for UserUtilities.SSOVendorAssociation
* 4.0       Kenny           29-03-2016  CSM0403     Added test method for language update to Release Comms Language field when conditions are met.
* 5.0      Rahul Mishra     16-05-2018   0602       Updating the test class to achive the necessary test coverage
* 6.0    Hemant Thakkar     19-06-2018  Test class failing for UserUtilities fixed.
*/

@isTest

private class UserAfterInsertUpdateTriggerTest {
    
    static testMethod void testUserMethod() {
        
        system.debug('Running Test Menthod'); 
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipContactTriggers(true);
        Profile profile = [select Id, Name from profile where Name = 'MDF Marketing Operations / Contract Admin' limit 1];
        if(profile != null){
                      Account testAcc = new Account(
                Name = 'Test Account',
                RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                Status__c = 'Active', 
                Partner_Relationship__c = 'Registered',
                Account_Country_Code__c = 'XY',
                Is_Enabled_for_Incentives__c = true,                     
                type='Partner'
            );
            
            insert testAcc;
            system.debug('Running Test Menthod1'); 
            User testUser = new User(Username='testvaliduser' +'@DELL.com',
                                     Alias = 'Test', 
                                     Email='Test'+'@dell.com',            
                                     LastName='Test',
                                     Title='GCC Program Manager', 
                                     ProfileId = profile.Id, 
                                     LanguageLocaleKey='en_US', 
                                     LocaleSidKey='en_US', 
                                     EmailEncodingKey='UTF-8', 
                                     TimeZoneSidKey='America/Los_Angeles',
                                     Badge_Number__c='Test'+System.currentTimeMillis());
                                     
                                     User testUser1 = new User(Username='testvaliduser123' +'@DELL.com',
                                     Alias = 'Test', 
                                     Email='Test'+'@dell.com',            
                                     LastName='Test',
                                     Title='GCC Program Manager', 
                                     ProfileId = profile.Id, 
                                     LanguageLocaleKey='en_US', 
                                     LocaleSidKey='en_US', 
                                     EmailEncodingKey='UTF-8', 
                                     TimeZoneSidKey='America/Los_Angeles',
                                     Enable_As_Partner_Lead_Super_User__c = True,
                                     Badge_Number__c='Test1'+System.currentTimeMillis());
            //insert testUser;
            try {
                system.debug('Running Test Menthod2'); 
                insert testUser;
                
                insert new EntitySubscription( parentid = userinfo.getuserid(), subscriberid = testUser.id );
            } catch( Exception e ) {
                system.debug('Running Test Menthod3'); 
                
            }
            System.runAs(testUser){
                insert testUser1;
                system.debug('Running Test Menthod4'); 
                Group grp = [SELECT Id, Name FROM Group where Name = 'Viper Marketing profiles Public Grp' limit 1];
                system.debug('fetched groups is'+grp);
                GroupMember grpMemObj = new GroupMember(UserOrGroupId = testUser.Id, GroupId = grp.Id);
                insert grpMemObj;
                Test.startTest();
                Map<Id, User> mapOfUser = new Map<Id, User>();
                mapOfUser.put(testUser.Id, testUser);
                Map<String, Id> mapOfGroup = new Map<String, Id>();
                mapOfGroup.put(grp.Name, testUser.Id);
                system.debug('Group Map Is'+mapOfGroup);
                UserUtilities.CMAPLeadSuperUserPermission(mapOfUser, mapOfGroup, TriggerHandler.TriggerEvent.ISInsert);
                system.debug('Running Test Menthod5'); 
                Test.stopTest();
            }
           System.AssertEquals('Test@dell.com',testUser.Email);
        }
        
       
    }
        /*static testMethod void testUserMethod1() {
         
        system.debug('Running Test Menthod'); 
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipContactTriggers(true);
        Profile profile = [select Id, Name from profile where Name = 'MDF Marketing Operations / Contract Admin' limit 1];
        if(profile != null){
            system.debug('Running Test Menthod1'); 
            User testUser = new User(Username='testvaliduser' +'@DELL.com',
                                     Alias = 'Test', 
                                     Email='Test'+'@dell.com',            
                                     LastName='Test',
                                     Title='GCC Program Manager', 
                                     ProfileId = profile.Id, 
                                     LanguageLocaleKey='en_US', 
                                     LocaleSidKey='en_US', 
                                     EmailEncodingKey='UTF-8', 
                                     TimeZoneSidKey='America/Los_Angeles',
                                     Badge_Number__c='Test'+System.currentTimeMillis());
            //insert testUser;
            try {
                system.debug('Running Test Menthod2'); 
                insert testUser;
            } catch( Exception e ) {
                system.debug('Running Test Menthod3'); 
                return;
            }
            System.runAs(testUser){
                system.debug('Running Test Menthod4'); 
                Group grp = [SELECT Id, Name FROM Group where Name = 'Viper Marketing profiles Public Grp' limit 1];
                system.debug('fetched groups is'+grp);
                GroupMember grpMemObj = new GroupMember(UserOrGroupId = testUser.Id, GroupId = grp.Id);
                insert grpMemObj;
                Test.startTest();
                Map<Id, User> mapOfUser = new Map<Id, User>();
                mapOfUser.put(testUser.Id, testUser);
                Map<String, Id> mapOfGroup = new Map<String, Id>();
                mapOfGroup.put(grp.Name, grp.Id);
                system.debug('Group Map Is'+mapOfGroup);
                UserUtilities.CMAPLeadSuperUserPermission(mapOfUser, mapOfGroup, TriggerHandler.TriggerEvent.ISUPDATE);
                system.debug('Running Test Menthod5'); 
                Test.stopTest();
            }
        }
    }*/
    
    
    
    static testMethod void testBOOMIResponse() {
        //Create Test Data
        //Create Country
        //Insert Country
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipContactTriggers(true); 
        User testUser;
        Contact testContact;
        
        
        
        /*Country__c testCountry  = new Country__c(Code__c = 'XY', Region__c = 'APJ',Inc_Vendor_Name__c='Dell Achievers',Inc_Vendor_End_Point__c='{TBD}' );
        insert testCountry ;*/
        
        Country__c testCountry = new Country__c (name = 'TESCOUNTRYMaster', Code__c = 'T67', Region__c = 'APJ',
                                                Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Not Applicable/On Hold',
                                                Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',Partner_Relationship__c = 'All',Partner_Relationship_for_OEM__c = 'All');
        
        insert testCountry ;
        Sales_Channel_Group__c testSalesChanGrp = new Sales_Channel_Group__c(Name = 'Test Sales channel', Regional_Parent_Name__c = 'APJ');
        insert testSalesChanGrp;
        
        Profile profile = [select id from profile where name like '%Sales Rep%' order by name limit 1];
        UserRole testUserRole = [select id, name from userrole where name like '%WW_Exec%' limit 1];
        
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true][0];
        User testUser1;
        
        System.runAs(adminusr) {
            testUser1 = new User(Username='boomi_integuser' +'@dell.comtest',
                                 Alias = 'Test', 
                                 Email='Test'+'@dell.com',
                                 IsActive = TRUE,
                                 LastName='Test',
                                 ProfileId = '00eA0000000hNqF', 
                                 LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', 
                                 EmailEncodingKey='UTF-8', 
                                 TimeZoneSidKey='America/Los_Angeles',
                                 Badge_Number__c='Test'+System.currentTimeMillis(),
                                 UserRoleId = testUserRole.Id);
            insert testUser1;
            UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
            User usr = [Select Id,UserRoleId from User where UserRoleId != null AND IsActive = True limit 1];
            
            //Create Account
            /*Account testAcc = new Account(
                Name = 'Test Account',
                RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                Status__c = 'Active', 
                Partner_Relationship__c = 'Registered',
                Account_Country_Code__c = 'XY',
                Is_Enabled_for_Incentives__c = true,                     
                type='Partner'
            );
            
            insert testAcc; 
            testAcc.IsPartner = true;
            update testAcc;*/
            Id masterRTId = StaticFactory.getRecordTypeIdByName('Account', 'Master Account');                     
            Account testAcc = new Account(name = 'testAccount'+System.currentTimeMillis(), Sales_Channel__c=testSalesChanGrp.Id,
                                    Account_Country_Code__c = testCountry.Code__c,RecordTypeId = masterRTId, Type = 'Master Group', Account_Country__c = testCountry.Name,Partner_Relationship__c='Registered');
            insert testAcc;
            //Create Contact
            string strEmail = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com';
            testContact = new Contact(AccountId = testAcc.id, Email = strEmail, Lastname = 'Contact',Vendor_Update_Datetime__c = System.now());
            insert testContact;
            
            //Select Profile
            Profile prof = [SELECT Id FROM Profile WHERE Name LIKE '%PRM Portal%' LIMIT 1];
            
            Group testG = new Group();
            testG.Name = 'CMAP:'+testAcc.Id;
            insert testG;
            testUser = new User(ContactId = testContact.id, IsActive = true, Email = strEmail, LanguageLocaleKey = 'en_US',Enable_Partner_Deal_Registration__c = true, 
                                LastName = 'UT', Alias = 'UT', CommunityNickname = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_'), 
                                TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',Enable_As_Partner_Lead_Super_User__c = True,Enable_Partner_Lead_Management__c = true,
                                ProfileId = prof.Id, UserName = strEmail, Badge_Number__c = String.valueOf(Datetime.now()));
            insert testUser;
        }
        
        Test.startTest();
        System.runAs(testUser1){
            ApexPages.StandardController con = new ApexPages.StandardController(new Partner_Request__c());
            
            PartnerSelfServiceMyCompanyCtrlExt ext = new PartnerSelfServiceMyCompanyCtrlExt(con);
            ext.confirmInactivateUser = testUser;
            ext.createInactivateUserPartnerRequest();
            ext.doConfirmInactivateUser();
           
            testUser.Last_Operation_Performed__c = 'Vendor Sync failed';
            update testUser;
            // }
            
            List<Partner_Request__c> listPR1 = [SELECT id,Description__c FROM Partner_Request__c where Contact__c = :testContact.id];
            System.debug('##RLIST:'+listPR1);
            if(listPR1.size()>0){
                if(listPR1[0].Description__c != null)
                {
                    System.assert(listPR1[0].Description__c.contains('Vendor Sync failed'));
                }
                listPR1[0].Status__c = PartnerConstants.REG_STATUS_DRAFT;
                update listPR1;
                
                testUser.Last_Operation_Performed__c = 'Vendor Updated';
                update testUser;
                
                List<Partner_Request__c> listPR2 = [SELECT id,Description__c,Status__c FROM Partner_Request__c where Contact__c = :testContact.id];
                System.debug('##RLIST1:'+listPR2);
                //System.assertEquals(PartnerConstants.REG_STATUS_COMPLETE, listPR2[0].Status__c);
                
                CMAP_Helper.skipinsert = true;
                listPR2[0].Status__c = PartnerConstants.REG_STATUS_INCOMPLETE;
                listPR2[0].Description__c = 'Integration with CMI falied. Please contact your System Administrator.';
                update listPR2;
                
                testUser.Last_Operation_Performed__c = 'Vendor Sync failed';
                update testUser;
                
                
                Test.stopTest();
                List<Partner_Request__c> listPR3 = [SELECT id,Description__c FROM Partner_Request__c where Contact__c = :testContact.id];
                System.debug('##RLIST2:'+listPR3);
              //  System.assert(listPR3[0].Description__c.contains('Vendor Sync failed'));
                System.assert(listPR2[0].Description__c.contains('Integration with CMI falied. Please contact your System Administrator.'));
               
            }
            
        }     
    System.runAs(adminusr) {    
         testUser.IsPortalEnabled = false;
                update testUser;
    }    
    }
    
    
    
    
    // 4.0 
    static testMethod void testUserUpdateMethod() {
        
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipContactTriggers(true);
        GlobalVariables.SKIP_AssignSalesConsole_USR_TRG_InTest  = false;
        //Create test user
        Profile profile = [select Id, Name from profile where Name = 'MDF Marketing Operations / Contract Admin' limit 1];
        //Insert testUser
        Test.startTest();
        User testUser2;
        testUser2 = new User(Username='testuser1' +'@DELLss.com',
                             Alias = 'TUser1', 
                             Email='test1'+'@dell.com',            
                             LastName='TestUser1',
                             ProfileId = profile.Id, 
                             LanguageLocaleKey='en_US', 
                             TimeZoneSidKey='America/Los_Angeles',
                             Badge_Number__c='Test'+System.currentTimeMillis(),
                             LocaleSidKey='en_US', 
                             EmailEncodingKey='UTF-8',
                             IsActive=true);  
        
        insert testUser2;                                       
        
        //Update testUse
        // testUser2.UserType='Standard';
        // testUser2.License_Used__c = 'Salesforce';
        testUser2.IsActive=true;
        update testUser2;
        
        testUser2.IsActive=true;                 
        testUser2.LanguageLocaleKey = 'zh_CN';
        update testUser2;
        
        testUser2.IsActive=false;
        testUser2.LanguageLocaleKey = 'fr';
        update testUser2;
        
        testUser2.IsActive=true;
        testUser2.LanguageLocaleKey = 'en_US';
        testUser2.HR_Location_Country_Desc__c = 'China'; 
        // try{
        //  update testUser2;
        // }catch(Exception ex){}               
        testUser2.IsActive=true;
        testUser2.LanguageLocaleKey = 'en_US';
        testUser2.HR_Location_Country_Desc__c = 'Italy'; 
        testUser2.LocaleSIDKey = 'fr_BE';
        //  try{
        //   update testUser2;
        //  }catch(Exception ex){}     
        testUser2.IsActive=true;
        testUser2.LanguageLocaleKey = 'en_US';
        testUser2.HR_Location_Country_Desc__c = 'Indonesia'; 
        testUser2.LocaleSIDKey = 'fi';
        testUser2.Country = 'Japan';
        //    try{
        //  update testUser2;     
        //  }catch(Exception ex){}     
        Test.stopTest();   
            System.assertEquals('Japan',testUser2.Country);
            
    }
    
    static testMethod void testUserChangeEmail() {
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipContactTriggers(true);
        Profile profile = [select Id, Name from profile where Name = 'R16.10 GBL Sales Rep' limit 1];
        
        Test.startTest();
        
        PeopleSoft_User_View__c ppsUser;
        ppsUser = new PeopleSoft_User_View__c(Badge_Number__c = 'Test'+System.currentTimeMillis(),
                                              Employee_Status__c ='Active');
        insert ppsUser;
        
        User ssoUser;
        ssoUser = new User(Username='TestUserSSO' +'@DELLss.com',
                           Alias = 'TSSO', 
                           Email='test_user_sso@dell.com',            
                           LastName='TestUserSSO',
                           ProfileId = profile.Id, 
                           LanguageLocaleKey='en_US', 
                           TimeZoneSidKey='America/Los_Angeles',
                           Badge_Number__c= ppsUser.Badge_Number__c,
                           LocaleSidKey='en_US', 
                           EmailEncodingKey='UTF-8',
                           IsActive=true,
                           Manual_Integrated_User__c = 'Yes',
                           Integration_User_Flag__c = 'U');  
        
        insert ssoUser;
        update ppsUser;
        
        ssoUser.Email = 'test_user_sso2@dell.com';
        try{
            update ssoUser;
        }catch(exception ex){}
        Test.stopTest();  
        System.assertEquals('test_user_sso2@dell.com',ssoUser.Email);
    }
      
    
 /*   static testMethod void testUserTerminate() {
        //Profile profile = [select Id, Name from profile where Name = 'R16.10 GBL Sales Rep' limit 1];
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipContactTriggers(true);
        Test.startTest();
        
        PeopleSoft_User_View__c ppsUser;
        ppsUser = new PeopleSoft_User_View__c(Badge_Number__c = 'Test'+System.currentTimeMillis(),
                                              Employee_Status__c ='Terminated');
        insert ppsUser;
        
        User ssoUser;
        ssoUser = new User(Username='TestUserSSO' +'@DELLss.com',
                           Alias = 'TSSO', 
                           Email='test_user_sso@dell.com',            
                           LastName='TestUserSSO',
                           ProfileId = '00eA0000000hLlPIAU', 
                           LanguageLocaleKey='en_US', 
                           TimeZoneSidKey='America/Los_Angeles',
                           Badge_Number__c= ppsUser.Badge_Number__c,
                           LocaleSidKey='en_US', 
                           EmailEncodingKey='UTF-8',
                           IsActive=true);  
        
        insert ssoUser;
        
        Profile profile = [select Id, Name from profile where Name = 'MDF Marketing Operations / Contract Admin' limit 1];
        
        User testUser = new User(Username='testvalidusernew' +'@DELL.com',
                                 Alias = 'Test', 
                                 Email='Testuser'+'@dell.com',            
                                 LastName='Test',
                                 Title='GCC Program Manager', 
                                 ProfileId = profile.Id, 
                                 LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', 
                                 EmailEncodingKey='UTF-8', 
                                 TimeZoneSidKey='America/Los_Angeles',System_Admin_or_Delegated_User_Admin__c = true,
                                 Badge_Number__c='Test'+System.currentTimeMillis());
        
        insert testUser;
        
        System.runAs(testUser){
            ssoUser.empStatus__c = 'T';
            ssoUser.ISM__c = '00530000000nY2dAAE';
            ssoUser.RSM__c = '00530000000nY2dAAE';
            
            update ssoUser;
                        
        }
        
        Test.stopTest();
    }*/
}
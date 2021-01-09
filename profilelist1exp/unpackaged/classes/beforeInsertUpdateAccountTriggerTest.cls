/*
 REVISION HISTORY
================
 * Revision CR Number   Release No  Date            Modified By     Description
 * -------- ---------   ----------  -----------     ------------    -----------
 * 1.0      CR 13136    0602        10-May-2016     Sui Yee         Created with added channel lead 2.0 mandatory field. 
*/
@isTest
private class beforeInsertUpdateAccountTriggerTest {

    static testMethod void insertAccountTest() {
        //Create test data
        //Insert Country
        Country__c testCountry  = new Country__c(Code__c = '@@', Region__c = 'APJ',Inc_Vendor_Name__c='Partner Advantage',Inc_Vendor_End_Point__c='Test End point');
        insert testCountry; 
        
        //Create Account
        //SHue
        Test.startTest();
        Account testacc = new Account(
                      Name = 'Test AccountSSOCMAP',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active', 
                      Partner_Relationship__c = 'Registered',
                      Account_Country_Code__c = '@@',
                      Is_Enabled_for_Incentives__c = true,                      
                      Type = 'Partner');
                      
        insert testacc; 
        Test.stopTest();
        
        //Query and asserts BOOMI related fields
        Account res = [SELECT id,Is_Vendor_Update_Required__c,Operation_for_Boomi__c,Is_Vendor_Updated__c,Is_Incentive_Updated__c , last_Operation_Performed__c
                       FROM Account where id=:testacc.Id];
        
        // System.assertEquals(res.Is_Vendor_Update_Required__c, true); /* If the country is not for incentive the trigger will make this value false */
        System.assertEquals(res.Operation_for_Boomi__c, 'NEW_ACCOUNT');
        System.assertEquals(res.Is_Incentive_Updated__c, true);
        System.assertEquals(res.last_Operation_Performed__c, 'SFDC Updated');
        System.assertEquals(res.Is_Vendor_Updated__c, false);
        
        //Insert Account without opulating incentive
        Account testacc1 = new Account(
                      Name = 'Test Account',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active', 
                      Partner_Relationship__c = 'Registered',
                      Account_Country_Code__c = '@@',                      
                      type='Partner');
                      
        insert testacc1; 
        //Query and asserts BOOMI related fields
        Account res1 = [SELECT id,Is_Vendor_Update_Required__c,Is_Incentive_Updated__c
                       FROM Account where id=:testacc1.Id];
        
        System.assertEquals(res1.Is_Vendor_Update_Required__c, false);        
        System.assertEquals(res1.Is_Incentive_Updated__c, false);
        
        //Account update scenario
        testacc1.Is_Enabled_for_Incentives__c = true;
        update testacc1;
        Account res2 = [SELECT id,Is_Vendor_Update_Required__c,Operation_for_Boomi__c,Is_Vendor_Updated__c,Is_Incentive_Updated__c,last_Operation_Performed__c
                       FROM Account where id=:testacc1.Id];
        
        System.assertEquals(res2.Is_Vendor_Update_Required__c, true);
        System.assertEquals(res2.Operation_for_Boomi__c, 'NEW_ACCOUNT');
        System.assertEquals(res2.Is_Incentive_Updated__c, true);
        System.assertEquals(res2.last_Operation_Performed__c, 'SFDC Updated');
        System.assertEquals(res2.Is_Vendor_Updated__c, false);
        
        testacc.Is_Enabled_for_Incentives__c = false;
        testacc.Vendor_Update_Datetime__c = System.now();
        
        TriggerExecutionController.setSkipAllTriggers(true);
        update testacc;
        
        Account res3 = [SELECT id,Is_Vendor_Update_Required__c,Operation_for_Boomi__c,Is_Vendor_Updated__c,Is_Incentive_Updated__c ,last_Operation_Performed__c
                       FROM Account where id=:testacc.Id];
        
        System.assertEquals(res3.Is_Vendor_Update_Required__c, true);
        //System.assertEquals(res3.Operation_for_Boomi__c, 'UPDATE_ACCOUNT');
        System.assertEquals(res3.Is_Incentive_Updated__c, true);
        System.assertEquals(res3.last_Operation_Performed__c, 'SFDC Updated');
        System.assertEquals(res3.Is_Vendor_Updated__c, false);
        
        //Create a test BOOMI integration user
        Profile P = [SELECT id FROM Profile where name='Boomi Integration API Only'];
        UserRole testUserRole = [select id, name from userrole where name like '%WW_Exec%' limit 1];
        //To avoid mixed DML get an Admin user and create boomi user
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true][0];
        User testUser;
        System.runAs(adminusr) {
            testUser = new User(Username='boomi_integuser' +'@dell.comtest',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    ProfileId = '00eA0000000hNqF', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    UserRoleId = testUserRole.Id);
            insert testUser;
        }
        
        testacc.OwnerId = testUser.id;
        update testacc;
        System.runAs(testUser){
            
            testacc.last_Operation_Performed__c = 'Vendor Sync failed';
            update testacc;
            
            Account res4 = [SELECT id,Is_Enabled_for_Incentives__c,Is_Vendor_Update_Required__c,Operation_for_Boomi__c,Is_Vendor_Updated__c,Is_Incentive_Updated__c ,last_Operation_Performed__c
                       FROM Account where id=:testacc.Id];
        
            //System.assertEquals(res4.Is_Enabled_for_Incentives__c, true);
            
        }     
        
        testCountry.Inc_Vendor_Name__c = 'Dell Achievers';
        update testCountry;
        testacc1.Is_Vendor_Updated__c = true;
        testacc1.Vendor_Update_Datetime__c = System.now();
        //update testacc1;
        testacc1.name = 'Test Account New';
        update testacc1;
        
        TriggerExecutionController.setSkipAllTriggers(false);
        
        Account res5 = [SELECT id,Is_Enabled_for_Incentives__c,Is_Vendor_Update_Required__c,Operation_for_Boomi__c,Is_Vendor_Updated__c,Is_Incentive_Updated__c,last_Operation_Performed__c
                       FROM Account where id=:testacc1.Id];
        
        System.assertEquals(res5.Is_Enabled_for_Incentives__c, true);
        //System.assertEquals(res5.Is_Incentive_Updated__c, false);
        System.assertEquals(res5.Is_Vendor_Update_Required__c, true);       
            
    }
    
    static testMethod void CMAPLMChangesTestnonOEM() {
        CMAP_Helper.skipinsert = true;
        
        TriggerExecutionController.setSkipAllTriggers(true);
        
        Country__c testCountry = new Country__c (name = 'TESCOUNTRY', Code__c = 'T6', Region__c = 'APJ',
                                                Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Partner Advantage',
                                                Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',Partner_Relationship__c = 'Premier,Registered',Partner_Relationship_for_OEM__c = 'Premier,Registered',
                                                Inc_Vendor_End_Point__c='Test End point');
        
  
        
        
        insert testCountry;
        
        Sales_Channel_Group__c testSalesChanGrp = new Sales_Channel_Group__c(Name = 'Test Sales channel', Regional_Parent_Name__c = 'APJ');
        insert testSalesChanGrp;              
        
        Account testAcc = new Account(name = 'testAccount'+System.currentTimeMillis(), Is_Rebate_Partner__c = true,Sales_Channel__c=testSalesChanGrp.Id,
                                    Account_Country_Code__c = testCountry.Code__c, Account_Country__c = testCountry.Name,Partner_Relationship__c='Registered');
        insert testAcc;
        
        TriggerExecutionController.setSkipAllTriggers(false);
        
        testAcc.RecordTypeId = System.Label.RecType_Partner_Account;
        testAcc.IsPartner = true;
        testAcc.Type = 'Partner';
        update testAcc;
        
        TriggerExecutionController.setSkipAllTriggers(true);
        
        Contact testContact = new Contact(Status__c='Active', AccountId=testAcc.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact',  Partner_My_Account_GUID__c='validuser');
        insert testContact; 
    
        //Profile profile = [select id from profile where UserType = 'PowerPartner' limit 1]; // Fenny commented
        //Fenny added -- To prevent this user following group '#SFDC – Frequently Asked Questions (FAQ)' which will cause INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY at EntitySubscriptionUtils.followGroup
        Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
                              
        User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    ContactId = testContact.Id,
                                    isActive=true,
                                    Enable_Partner_Lead_Management__c = true,
                                    Enable_Partner_Deal_Registration__c = true);
        insert testUser;
        
        TriggerExecutionController.setSkipAllTriggers(false);
        
        Test.startTest();
        try{
            testAcc.Partner_Relationship__c = 'Preferred';
            update testAcc;
            
            Account res = [SELECT Inconsistency_in_Lead_Management_data__c,id FROM Account where id=:testAcc.id];
            System.assertEquals(res.Inconsistency_in_Lead_Management_data__c, true);
            //Try to uncheck and make sure error is throwing
            res.Inconsistency_in_Lead_Management_data__c = false;
            update res;
        }catch(Exception e){
            System.assert(e.getMessage().contains('There are existing users with Lead Management enabled. Please disable Lead Management access for these users to proceed.'));
        }
        
        Test.stopTest(); 
    }
    static testMethod void CMAPLMChangesTestOEM() {
        CMAP_Helper.skipinsert = true;
        
        TriggerExecutionController.setSkipAllTriggers(true);
        
        Country__c testCountry = new Country__c (name = 'TESCOUNTRY', Code__c = 'T6', Region__c = 'APJ',
                                                Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Partner Advantage',
                                                Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',Partner_Relationship__c = 'Premier,Registered',Partner_Relationship_for_OEM__c = 'Premier,Registered',
                                                Inc_Vendor_End_Point__c='Test End point');
        
  
        
        
        insert testCountry;
        Sales_Channel_Group__c testSalesChanGrp = new Sales_Channel_Group__c(Name = 'Test OEM Sales channel', Regional_Parent_Name__c = 'APJ');
        insert testSalesChanGrp;              
        Account testAcc = new Account(name = 'testAccount'+System.currentTimeMillis(), Is_Rebate_Partner__c = true,Sales_Channel__c=testSalesChanGrp.Id,
                                    Account_Country_Code__c = testCountry.Code__c, Account_Country__c = testCountry.Name,Partner_Relationship__c='Registered');
        insert testAcc;
        
        TriggerExecutionController.setSkipAllTriggers(false);
        
        testAcc.RecordTypeId = System.Label.RecType_Partner_Account;
        testAcc.IsPartner = true;
        testAcc.Type = 'Partner';
        update testAcc;
        
        TriggerExecutionController.setSkipAllTriggers(true);
        
        Contact testContact = new Contact(Status__c='Active', AccountId=testAcc.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact',  Partner_My_Account_GUID__c='validuser');
        insert testContact; 
    
    //Profile profile = [select id from profile where UserType = 'PowerPartner' limit 1]; // Fenny commented
    // Fenny added -- To prevent this user following group '#SFDC – Frequently Asked Questions (FAQ)' which will cause INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY at EntitySubscriptionUtils.followGroup
    Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
                              
        User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    ContactId = testContact.Id,
                                    isActive=true,
                                    Enable_Partner_Lead_Management__c = true,
                                    Enable_Partner_Deal_Registration__c = true);
        insert testUser;
        TriggerExecutionController.setSkipAllTriggers(false);
        
        Test.startTest();
        try{
            testAcc.Partner_Relationship__c = 'Preferred';
            update testAcc;
            
            Account res = [SELECT Inconsistency_in_Lead_Management_data__c,id FROM Account where id=:testAcc.id];
            System.assertEquals(res.Inconsistency_in_Lead_Management_data__c, true);
            //Try to uncheck and make sure error is throwing
            res.Inconsistency_in_Lead_Management_data__c = false;
            update res;
        }catch(Exception e){
            System.assert(e.getMessage().contains('There are existing users with Lead Management enabled. Please disable Lead Management access for these users to proceed.'));
        }
        
        Test.stopTest(); 
    }
    
    static testMethod void syncIncentivesEnabledTest() {
            CMAP_Helper.skipinsert = true;            
            //Id leadRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead - Submission');
            //V 1.0 Added channel lead 2.0 and mandatory field lead source, lead type, dell partner can contact me            
            Id leadRTId = StaticFactory.getRecordTypeIdByName('Lead', 'Channel Lead 2.0');         
            CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
            testData.getAccount(true);
            testData.getContact(true);
            TriggerExecutionController.setSkipUserTriggers(true);
            testData.getPartnerUser(true);    
            TriggerExecutionController.setSkipUserTriggers(false);
            TriggerExecutionController.setSkipCampaignTriggers(true);
            testData.getCampaign(true);
            TriggerExecutionController.setSkipCampaignTriggers(false);
            //CMAP_Helper.skipInsert = true;
            
            Test.startTest();
            
            Account testacc = new Account(
                      Name = 'syncIncentivesEnabledTest Account',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active', 
                      Partner_Relationship__c = 'Registered',
                      Account_Country_Code__c = '@@',                   
                      Type='Partner');
                      
            //GlobalVariables.BYPASS_ACCOUNT_TRIGGER = true;
            insert testacc; 
            //GlobalVariables.BYPASS_ACCOUNT_TRIGGER = false;
            
            Lead testLead = new Lead(LastName = 'Test Lead',
            Email = 'testincen@incentest.com',
            Status = 'Open - Channel Lead',
            Phone = '88967544',
            RecordTypeId = leadRTId,
            Country = 'US',
            Company = 'syncIncentivesEnabledTest Account',
            Are_you_a_Dell_Partner__c = 'Yes',
            Campaign__c  = testdata.campObj.Id,
            LeadSource = 'Web',
            Lead_Type__c = 'Inbound',
            Dell_Partner_can_contact_me__c = true,
            Account_Category__c = 'Partner',
            Account__c = testacc.id);            
            
            insert testLead;         
            
            testLead.Account__c = testacc.id;
            update testLead;                                             
            
            testacc.Account_Country_Code__c = '1@';
            testacc.Is_Enabled_for_Incentives__c = false;
            //GlobalVariables.BYPASS_ACCOUNT_TRIGGER = true;
            update testacc;
            //GlobalVariables.BYPASS_ACCOUNT_TRIGGER = false;
            
            Test.stopTest();
                   
    } 
    
    /*
    Revision    CR Number   Release No      Date            Modified By     Description
    --------    ---------   ----------      -----------     ------------    -----------
    1.0         CR12339     16.12           23-Nov-2015     Krishnamoorthi  Test method to cover populateCRMTFields method in AccountFieldPopulator class 
    2.0         CR13220                     10-june-2016    Swathi           //To cover this method populateProtectOptimizeFlagFieldsOnBeforeUpdate in class AccountFieldPopulator
    3.0         CR 15690    FY19-DCE-0602   27-Apr-2018     Emily           Field Trip clean up for Account (Part 2)
    */
    /*v3.0
    static testMethod void populateCRMTFieldsTest() {
         Account testacc = new Account(
                      Name = 'Test Account',
                      RecordTypeId = StaticFactory.getRecordTypeIdByName('Account', 'End-User Account'),
                      Status__c = 'Active', 
                      type='End User',Protect_Flag__c=True);
                      
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();
        insert testacc; 
        
        Profile p = [SELECT Id,Name FROM profile WHERE Name = 'System Administrator' LIMIT 1];
        User usr = new User(alias = 'newUser', 
                             email='Testuser@dellteam.com',
                             emailencodingkey='UTF-8', 
                             lastname='Test User', 
                             languagelocalekey='en_US',
                             localesidkey='en_US', 
                             profileid = p.Id,
                             Badge_Number__c=String.valueOf(Datetime.now()),
                             timezonesidkey='America/Los_Angeles', 
                             username=String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.dev');
         insert usr;
         
         User usr2 = new User(alias = 'newUser2', 
                             email='Testuser2@dellteam.com',
                             emailencodingkey='UTF-8', 
                             lastname='Test User2', 
                             languagelocalekey='en_US',
                             localesidkey='en_US', 
                             profileid = p.Id,
                             Badge_Number__c=String.valueOf(Datetime.now())+'u',
                             timezonesidkey='America/Los_Angeles', 
                             username=String.valueOf('T2' + Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.dev');
         insert usr2;
         
        AccountTeamMember accTM = new AccountTeamMember();
        accTM.AccountId = testacc.Id;
        accTM.UserId = usr.Id;
        accTM.TeamMemberRole = 'Services Customer Executive';
        insert accTM;
        TriggerExecutionController.setSkipAllTriggers(false);
        
        testacc.Services_Customer_Reference_Program__c = 'Yes';
        testacc.Industry = 'Aerospace';
        
        //To cover this method populateProtectOptimizeFlagFieldsOnBeforeUpdate in class AccountFieldPopulator
        testacc.Optimize_Flag__c = TRUE;
        update testacc;

        Account testacc2 = [SELECT Id, Name, Customer_Reference_Relationship_Owner__c, Is_User_Updated_Relationship_Owner__c FROM Account WHERE Id =: testacc.Id];
        //Assert Customer Reference Relationship Owner field is populated from Account Team Member and Boolean flag is false
        System.assertEquals(testacc2.Customer_Reference_Relationship_Owner__c,usr.Id);
        System.assertEquals(testacc2.Is_User_Updated_Relationship_Owner__c,false);
        
        AccountTeamMember accTM2 = [SELECT Id, TeamMemberRole FROM AccountTeamMember WHERE Id=: accTM.Id];
        accTM2.TeamMemberRole = 'Services Customer Exec Manager';
        update accTM2;
        
        testacc2.Name = 'Test EU Account';
        update testacc2;
        
        Account testacc3 = [SELECT Id, Customer_Reference_Relationship_Owner__c FROM Account WHERE Id =: testacc2.Id];
        //Assert Customer Reference Relationship Owner field is null when no Account Team member role 'Services Customer Executive'
        System.assertEquals(testacc3.Customer_Reference_Relationship_Owner__c,null);
        
        //Check for manual Customer_Reference_Relationship_Owner update
        testacc3.Customer_Reference_Relationship_Owner__c = usr2.Id;
        update testacc3;
        Account testacc4 = [SELECT Id, Customer_Reference_Relationship_Owner__c, Is_User_Updated_Relationship_Owner__c FROM Account WHERE Id =: testacc3.Id];
        //Assert the manually updated value and the boolean flag
        System.assertEquals(testacc4.Customer_Reference_Relationship_Owner__c,usr2.Id);
        System.assertEquals(testacc4.Is_User_Updated_Relationship_Owner__c,true);
        
        testacc4.Name = 'Test EU Account2';
        update testacc4;
        
         Account testacc5 = [SELECT Id, Customer_Reference_Relationship_Owner__c, Is_User_Updated_Relationship_Owner__c FROM Account WHERE Id =: testacc4.Id];
        //Assert when any other Account field updated there is no change in the  Customer_Reference_Relationship_Owner field
        System.assertEquals(testacc5.Customer_Reference_Relationship_Owner__c,usr2.Id);
        System.assertEquals(testacc5.Is_User_Updated_Relationship_Owner__c,true);
        
        Test.stopTest();
    
    }*/

}
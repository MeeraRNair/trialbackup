/*

 * Revision   Date            Modified By     Description
 * --------   -----------     ------------    -----------
 * 1.0        1-Dec-2019      Urvish          Created Class for Opportunity Split
 
*/

@isTest
public class OpportunitySplitProductHandlerAU_Test {

    @testSetup static void setup() {
        OWD__c oWDsetting = new OWD__c();
        oWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        oWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        oWDsetting.Oppty_Stage100__c = 'Win - 100%';
        oWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        oWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        oWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        oWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        oWDsetting.Oppty_Stage1__c = 'Plan - 1%';
        
        insert oWDsetting;
        
        EMC_General_Settings__c settingData = new EMC_General_Settings__c();
        settingData.ProfilesBypassMyquotesOpptyValidation__c= 'Boomi Integration API Only;';        
        insert settingData;
         
         List<GroupName__c> lstGrpName = new List<GroupName__c>();
         GroupName__c grpName1 = new GroupName__c();
         grpName1.Name ='FPG_DPS__c';
         grpName1.API_Name__c ='FPG_DPS__c';
         grpName1.Label__c ='Forecast Product Group DPS';
         grpName1.Group_Name__c ='DPS';
         lstGrpName.add(grpName1);
         
         GroupName__c grpName2 = new GroupName__c();
         grpName2.Name ='FPG_MDC__c';
         grpName2.API_Name__c ='FPG_MDC__c';
         grpName2.Label__c ='Forecast Product Group MDC';
         grpName2.Group_Name__c ='MDC';
         lstGrpName.add(grpName2);
         
         GroupName__c grpName3 = new GroupName__c();
         grpName3.Name ='FPG_UDS__c';
         grpName3.API_Name__c ='FPG_UDS__c';
         grpName3.Label__c ='Forecast Product Group UDS';
         grpName3.Group_Name__c ='UDS';
         lstGrpName.add(grpName3);
         
         GroupName__c grpName4 = new GroupName__c();
         grpName4.Name ='FPG_Enterprise__c';
         grpName4.API_Name__c ='FPG_Enterprise__c';
         grpName4.Label__c ='Forecast Product Group Enterprise';
         grpName4.Group_Name__c ='Enterprise';
         lstGrpName.add(grpName4);
         
         insert lstGrpName;
        
         
         List<Split_OverlayGroup__c> lstSplitGrp = new List<Split_OverlayGroup__c>();
         
         Split_OverlayGroup__c spltgrp1 = new Split_OverlayGroup__c();
         spltgrp1.Name = 'UDS';
         spltgrp1.Group_Name__c = 'UDS';
         spltgrp1.Team_Member_Role__c = 'UDS Inside Sales Mgr';
         lstSplitGrp.add(spltgrp1);
         
         Split_OverlayGroup__c spltgrp2 = new Split_OverlayGroup__c();
         spltgrp2.Name = 'MDC';
         spltgrp2.Group_Name__c = 'MDC';
         spltgrp2.Team_Member_Role__c = 'MDC Inside Sales Mgr';
         lstSplitGrp.add(spltgrp2);
         
         insert lstSplitGrp;
     } 
    
    static testMethod void testInsertbothLineItem() { 

        // 7.4 To create customsettings
    //    insert new Enable_Codes_Settings__c(Name='EMC Codes',Enable__c=true);
    
        TriggerExecutionController.setSkipAllTriggers(true);
         String strMockMetaData = '';

        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
                'AfterUpdate' => new List<Boolean>{false, false, true, false, false}
        };

        for(String strEvent : mapEvents.keySet()) {
            strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "OpportunityLineItem", "Class_Name__c": "OpportunitySplitProductHandlerAU"},';
        }

        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';

        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'OpportunityLineItem';
        tec.RecursiveCount__c = 2;
        insert tec;
        //Insert only appassure product
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');  
        insert testAccount;        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                CloseDate = System.Today() + 30 ); 
                                                      
        insert testOppty;   
        
        Profile testProfile = [select id, name from profile where name like '%Sales%' order by name limit 1 ];

        System.assert(testProfile != null);

        User testUser1 = new User(FirstName = 'Test 1', LastName = 'BatchDeleteACT Test', Title = 'OEM_SR', UserName = 'TestU1' + System.currentTimeMillis() + '@test.com', Email = 'TestU1@dell.com', Alias = 'test01', CommunityNickName = 'Test01', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest111');
        User testUser2 = new User(FirstName = 'Test 2', LastName = 'BatchDeleteACT Test', Title = 'OEM_SR', UserName = 'TestU2' + System.currentTimeMillis() + '@test.com', Email = 'TestU2@dell.com', Alias = 'test02', CommunityNickName = 'Test02', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest222');
        User testUser3 = new User(FirstName = 'Test 3', LastName = 'BatchDeleteACT Test', Title = 'QQQ_SR', UserName = 'TestU3' + System.currentTimeMillis() + '@test.com', Email = 'TestU3@dell.com', Alias = 'test03', CommunityNickName = 'Test03', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest333');
        User testUser4 = new User(FirstName = 'Test 4', LastName = 'BatchDeleteACT Test', Title = 'QQQ_SR', UserName = 'TestU4' + System.currentTimeMillis() + '@test.com', Email = 'TestU4@dell.com', Alias = 'test04', CommunityNickName = 'Test04', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest444');
        User testUser5 = new User(FirstName = 'Test 5', LastName = 'BatchDeleteACT Test', Title = 'MSG_SR', UserName = 'TestU5' + System.currentTimeMillis() + '@test.com', Email = 'TestU5@dell.com', Alias = 'test05', CommunityNickName = 'Test05', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest1115');
        User testUser6 = new User(FirstName = 'Test 6', LastName = 'BatchDeleteACT Test', Title = 'MSG_SR', UserName = 'TestU6' + System.currentTimeMillis() + '@test.com', Email = 'TestU6@dell.com', Alias = 'test06', CommunityNickName = 'Test06', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest2226');
        User testUser7 = new User(FirstName = 'Test 7', LastName = 'BatchDeleteACT Test', Title = 'QQQ_SR', UserName = 'TestU7' + System.currentTimeMillis() + '@test.com', Email = 'TestU7@dell.com', Alias = 'test07', CommunityNickName = 'Test07', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest3337');
        User testUser8 = new User(FirstName = 'Test 8', LastName = 'BatchDeleteACT Test', Title = 'QQQ_SR', UserName = 'TestU8' + System.currentTimeMillis() + '@test.com', Email = 'TestU8@dell.com', Alias = 'test08', CommunityNickName = 'Test08', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest4448');

        List < User > testUserList = new List < User > ();

        testUserList.add(testUser1);
        testUserList.add(testUser2);
        testUserList.add(testUser3);
        testUserList.add(testUser4);
        testUserList.add(testUser5);
        testUserList.add(testUser6);
        testUserList.add(testUser7);
        testUserList.add(testUser8);

        insert testUserList;

        AccountTeamMember testACT1 = new AccountTeamMember(UserId = testUser1.Id, TeamMemberRole = 'UDS Inside Sales Mgr', AccountId = testAccount.Id);
        AccountTeamMember testACT2 = new AccountTeamMember(UserId = testUser2.Id, TeamMemberRole = 'MDC Inside Sales Mgr', AccountId = testAccount.Id);
        AccountTeamMember testACT3 = new AccountTeamMember(UserId = testUser3.Id, TeamMemberRole = 'UDS Inside Sales Mgr', AccountId = testAccount.Id);
        AccountTeamMember testACT4 = new AccountTeamMember(UserId = testUser4.Id, TeamMemberRole = 'QQQ SR', AccountId = testAccount.Id);
        AccountTeamMember testACT5 = new AccountTeamMember(UserId = testUser5.Id, TeamMemberRole = 'MSG SR', AccountId = testAccount.Id);
        AccountTeamMember testACT6 = new AccountTeamMember(UserId = testUser6.Id, TeamMemberRole = 'QQQ SR', AccountId = testAccount.Id);
        AccountTeamMember testACT7 = new AccountTeamMember(UserId = testUser7.Id, TeamMemberRole = 'MSG SR', AccountId = testAccount.Id);
        AccountTeamMember testACT8 = new AccountTeamMember(UserId = testUser8.Id, TeamMemberRole = 'QQQ SR', AccountId = testAccount.Id);

        List < AccountTeamMember > testACTList = new List < AccountTeamMember > ();

        testACTList.add(testACT1);
        testACTList.add(testACT2);
        testACTList.add(testACT3);
        testACTList.add(testACT4);
        testACTList.add(testACT5);
        testACTList.add(testACT6);
        testACTList.add(testACT7);
        testACTList.add(testACT8);

        insert testACTList;
        
        List < OpportunityTeamMember > insert_OppMem = new List < OpportunityTeamMember > ();
        insert_OppMem.add(new OpportunityTeamMember(OpportunityID = testOppty.ID, OpportunityAccessLevel = 'Read', TeamMemberRole = 'UDS Inside Sales Mgr', UserID = testUser1.ID, End_User_Acct_Member__c = TRUE, Partner_Account_Member__c = FALSE));
        insert_OppMem.add(new OpportunityTeamMember(OpportunityID = testOppty.ID, OpportunityAccessLevel = 'Read', TeamMemberRole = 'MDC Inside Sales Mgr', UserID = testUser2.ID, End_User_Acct_Member__c = TRUE, Partner_Account_Member__c = FALSE));
        insert_OppMem.add(new OpportunityTeamMember(OpportunityID = testOppty.ID, OpportunityAccessLevel = 'Read', TeamMemberRole = 'UDS Inside Sales Mgr', UserID = testUser3.ID, End_User_Acct_Member__c = TRUE, Partner_Account_Member__c = FALSE));

        insert insert_OppMem;
        
        //Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
        Id pbk1 = Test.getStandardPricebookId();
        List<Product2> listProduct2 =new List<Product2>();     
        Product2 newPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'Test Product',
                                         Product_ID__c='test prod id1',
                                         FPG_UDS__c = true,
                                         FPG_MDC__c = false,
                                         FPG_DPS__c = false,
                                         FPG_Enterprise__c = false,
                                         IsActive = TRUE);
        listProduct2.add(newPrdct);                                 
        //insert newPrdct;
        Product2 newappPrdct = new Product2(Name = 'Test Product',
                                         Product_Line_Desc__c = 'AppAssure',
                                         Product_ID__c='test prod id2',
                                         FPG_MDC__c = true,
                                         FPG_UDS__c = false,
                                         FPG_DPS__c = false,
                                         FPG_Enterprise__c = false,
                                         IsActive = TRUE);
        listProduct2.add(newappPrdct);
        insert listProduct2;
        //insert newappPrdct;
        List<PricebookEntry> listPricebook =new List<PricebookEntry>();        
        PricebookEntry pBE= new PricebookEntry (Product2ID=newPrdct.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        listPricebook.add(pBE);                                        
        //insert pBE;
        PricebookEntry apppBE= new PricebookEntry (Product2ID=newappPrdct.id,
                                                Pricebook2ID=pbk1,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        //insert apppBE;
        listPricebook.add(apppBE);
        insert listPricebook;
        TriggerExecutionController.setSkipAllTriggers(false);
        
        List<OpportunityLineItem> listOpplnItem =new List<OpportunityLineItem>();
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[0].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    ); 
        OpportunityLineItem  testappLineItem = new OpportunityLineItem(Opportunityid =testOppty.Id,
                                                                    pricebookEntryId=listPricebook[1].id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                    );   
        listOpplnItem.add(testLineItem);
        listOpplnItem.add(testappLineItem); 
        insert listOpplnItem;
        TriggerExecutionController.setSkipAllTriggers(false);
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true); // 7.2
        Test.startTest();
        listOpplnItem[1].UnitPrice = 200;
        update listOpplnItem[1];
        //TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(false); // 7.2
        //insert testappLineItem;
        Test.stopTest();        
    }
    
}
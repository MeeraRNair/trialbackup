@isTest
public class OppSplitUtilHelper_Test {

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
	
		string Reve;
        string Over;
    
        List<OpportunitySplitType> oSplitType = new List<OpportunitySplitType>([select id,DeveloperName from OpportunitySplitType limit 2]);
        for(OpportunitySplitType ost : oSplitType){
            if(ost != null){
                if(ost.Developername == 'Revenue'){
                    Reve = ost.id;
                }
                else{
                    Over = ost.id;
                }
            }
        } 	

        TriggerExecutionController.setSkipAllTriggers(true);
    
        Account testAccount = new Account(Name='testOpportunityPlanRedirectPage Test Account');  
        insert testAccount;        
        Opportunity testOppty = new Opportunity(Name='testOpportunityPlanRedirectPage Test Oppty', 
                                                AccountId=testAccount.Id, 
                                                stagename='Discover - 10%',
                                                CloseDate = System.Today() + 30 ); 
                                                      
        insert testOppty;   
        
        Profile testProfile = [select id, name from profile where name like '%Sales%' order by name limit 1 ];

        System.assert(testProfile != null);
		List < User > testUserList = new List < User > ();
        User testUser1 = new User(FirstName = 'Test 1', LastName = 'BatchDeleteACT Test', Title = 'OEM_SR', UserName = 'TestU1' + System.currentTimeMillis() + '@test.com', Email = 'TestU1@dell.com', Alias = 'test01', CommunityNickName = 'Test01', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest111');
        User testUser2 = new User(FirstName = 'Test 2', LastName = 'BatchDeleteACT Test', Title = 'OEM_SR', UserName = 'TestU2' + System.currentTimeMillis() + '@test.com', Email = 'TestU2@dell.com', Alias = 'test02', CommunityNickName = 'Test02', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest222');
        User testUser3 = new User(FirstName = 'Test 3', LastName = 'BatchDeleteACT Test', Title = 'QQQ_SR', UserName = 'TestU3' + System.currentTimeMillis() + '@test.com', Email = 'TestU3@dell.com', Alias = 'test03', CommunityNickName = 'Test03', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest333');
        User testUser4 = new User(FirstName = 'Test 4', LastName = 'BatchDeleteACT Test', Title = 'QQQ_SR', UserName = 'TestU4' + System.currentTimeMillis() + '@test.com', Email = 'TestU4@dell.com', Alias = 'test04', CommunityNickName = 'Test04', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest444');
        User testUser5 = new User(FirstName = 'Test 5', LastName = 'BatchDeleteACT Test', Title = 'MSG_SR', UserName = 'TestU5' + System.currentTimeMillis() + '@test.com', Email = 'TestU5@dell.com', Alias = 'test05', CommunityNickName = 'Test05', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest1115');
        User testUser6 = new User(FirstName = 'Test 6', LastName = 'BatchDeleteACT Test', Title = 'MSG_SR', UserName = 'TestU6' + System.currentTimeMillis() + '@test.com', Email = 'TestU6@dell.com', Alias = 'test06', CommunityNickName = 'Test06', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest2226');
        User testUser7 = new User(FirstName = 'Test 7', LastName = 'BatchDeleteACT Test', Title = 'QQQ_SR', UserName = 'TestU7' + System.currentTimeMillis() + '@test.com', Email = 'TestU7@dell.com', Alias = 'test07', CommunityNickName = 'Test07', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest3337');
        User testUser8 = new User(FirstName = 'Test 8', LastName = 'BatchDeleteACT Test', Title = 'QQQ_SR', UserName = 'TestU8' + System.currentTimeMillis() + '@test.com', Email = 'TestU8@dell.com', Alias = 'test08', CommunityNickName = 'Test08', ProfileId = testProfile.Id, LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', TimeZoneSidKey = 'America/Los_Angeles', Badge_Number__c = 'testtest4448');
		
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
        AccountTeamMember testACT4 = new AccountTeamMember(UserId = testUser4.Id, TeamMemberRole = 'UDS Inside Sales Mgr', AccountId = testAccount.Id);
        AccountTeamMember testACT5 = new AccountTeamMember(UserId = testUser5.Id, TeamMemberRole = 'UDS Inside Sales Mgr', AccountId = testAccount.Id);
        AccountTeamMember testACT6 = new AccountTeamMember(UserId = testUser6.Id, TeamMemberRole = 'UDS Inside Sales Mgr', AccountId = testAccount.Id);
        AccountTeamMember testACT7 = new AccountTeamMember(UserId = testUser7.Id, TeamMemberRole = 'UDS Inside Sales Mgr', AccountId = testAccount.Id);
        AccountTeamMember testACT8 = new AccountTeamMember(UserId = testUser8.Id, TeamMemberRole = 'UDS Inside Sales Mgr', AccountId = testAccount.Id);
		
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
        insert_OppMem.add(new OpportunityTeamMember(OpportunityID = testOppty.ID, OpportunityAccessLevel = 'Read', TeamMemberRole = 'UDS Inside Sales Mgr', UserID = testUser3.ID, End_User_Acct_Member__c = TRUE, Partner_Account_Member__c = FALSE));
        insert_OppMem.add(new OpportunityTeamMember(OpportunityID = testOppty.ID, OpportunityAccessLevel = 'Read', TeamMemberRole = 'UDS Inside Sales Mgr', UserID = testUser4.ID, End_User_Acct_Member__c = TRUE, Partner_Account_Member__c = FALSE));
        insert_OppMem.add(new OpportunityTeamMember(OpportunityID = testOppty.ID, OpportunityAccessLevel = 'Read', TeamMemberRole = 'UDS Inside Sales Mgr', UserID = testUser5.ID, End_User_Acct_Member__c = TRUE, Partner_Account_Member__c = FALSE));
        insert_OppMem.add(new OpportunityTeamMember(OpportunityID = testOppty.ID, OpportunityAccessLevel = 'Read', TeamMemberRole = 'UDS Inside Sales Mgr', UserID = testUser6.ID, End_User_Acct_Member__c = TRUE, Partner_Account_Member__c = FALSE));
        insert_OppMem.add(new OpportunityTeamMember(OpportunityID = testOppty.ID, OpportunityAccessLevel = 'Read', TeamMemberRole = 'UDS Inside Sales Mgr', UserID = testUser7.ID, End_User_Acct_Member__c = TRUE, Partner_Account_Member__c = FALSE));
        insert_OppMem.add(new OpportunityTeamMember(OpportunityID = testOppty.ID, OpportunityAccessLevel = 'Read', TeamMemberRole = 'UDS Inside Sales Mgr', UserID = testUser8.ID, End_User_Acct_Member__c = TRUE, Partner_Account_Member__c = FALSE));
        
        insert_OppMem.add(new OpportunityTeamMember(OpportunityID = testOppty.ID, OpportunityAccessLevel = 'Read', TeamMemberRole = 'MDC Inside Sales Mgr', UserID = testUser2.ID, End_User_Acct_Member__c = TRUE, Partner_Account_Member__c = FALSE));

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
        
        List<OpportunitySplit> lstSplit = new List<OpportunitySplit>();
        OpportunitySplit objSplit1 = new OpportunitySplit(OpportunityId = testOppty.Id,
                                                          SplitPercentage = 100,
                                                          Forecast_Group__c = 'UDS',
                                                          SplitOwnerID = testUser1.Id,
                                                          SplitTypeId =Over,
                                                          Percentage__c = 100
                                                        );
        OpportunitySplit objSplit3 = new OpportunitySplit(OpportunityId = testOppty.Id,
                                                          SplitPercentage = 100,
                                                          Forecast_Group__c = 'UDS',
                                                          SplitOwnerID = testUser3.Id,
                                                          SplitTypeId =Over,
                                                          Percentage__c = 0
                                                        );
        OpportunitySplit objSplit4 = new OpportunitySplit(OpportunityId = testOppty.Id,
                                                          SplitPercentage = 100,
                                                          Forecast_Group__c = 'UDS',
                                                          SplitOwnerID = testUser4.Id,
                                                          SplitTypeId =Over,
                                                          Percentage__c = 0
                                                        );
        OpportunitySplit objSplit5 = new OpportunitySplit(OpportunityId = testOppty.Id,
                                                          SplitPercentage = 100,
                                                          Forecast_Group__c = 'UDS',
                                                          SplitOwnerID = testUser5.Id,
                                                          SplitTypeId =Over,
                                                          Percentage__c = 0
                                                        );
        OpportunitySplit objSplit6 = new OpportunitySplit(OpportunityId = testOppty.Id,
                                                          SplitPercentage = 100,
                                                          Forecast_Group__c = 'UDS',
                                                          SplitOwnerID = testUser6.Id,
                                                          SplitTypeId =Over,
                                                          Percentage__c = 0
                                                        );
        OpportunitySplit objSplit7 = new OpportunitySplit(OpportunityId = testOppty.Id,
                                                          SplitPercentage = 100,
                                                          Forecast_Group__c = 'UDS',
                                                          SplitOwnerID = testUser7.Id,
                                                          SplitTypeId =Over,
                                                          Percentage__c = 0
                                                        );
        OpportunitySplit objSplit8 = new OpportunitySplit(OpportunityId = testOppty.Id,
                                                          SplitPercentage = 100,
                                                          Forecast_Group__c = 'UDS',
                                                          SplitOwnerID = testUser8.Id,
                                                          SplitTypeId =Over,
                                                          Percentage__c = 0
                                                        );
        OpportunitySplit objSplit2 = new OpportunitySplit(OpportunityId = testOppty.Id,
                                                          SplitPercentage = 100,
                                                          Forecast_Group__c = 'MDC',
                                                          SplitOwnerID = testUser2.Id,
                                                          SplitTypeId =Over,
                                                          Percentage__c = 100
                                                        );
       
        lstSplit.add(objSplit1);
        lstSplit.add(objSplit2);
        lstSplit.add(objSplit3);
        lstSplit.add(objSplit4);
        lstSplit.add(objSplit5);
        lstSplit.add(objSplit6);
        lstSplit.add(objSplit7);
        lstSplit.add(objSplit8);
        insert lstSplit;
        
        
        Test.startTest();
		OppSplitUtilHelper.assembleOSDelArray(lstSplit);       
        Test.stopTest();  
        
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
}
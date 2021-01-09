/*
Revision    CR Number   Release No      Date            Modified By     Description
--------    ---------   ----------      -----------     ------------    -----------
1.0         13359       Sprint 13       2-August-2016   Kenny           To move test methods from VFCntrlr_UpdateSalesTeamMain main class to a new test class and created test data for all methods
*/    

@isTest 
public class VFCntrlr_UpdateSalesTeamMain_Test {
    static List<String> listObjAPINames = new List<String>{'Opportunity'};
        
        @testSetup static void setup() {
            OWD__c owdSetting = new OWD__c();
            owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
            owdSetting.Oppty_Stage10__c = 'Discover - 10%';
            owdSetting.Oppty_Stage100__c = 'Win - 100%';
            owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
            owdSetting.Oppty_Stage60__c = 'Propose - 60%';
            owdSetting.Oppty_Stage90__c = 'Commit - 90%';
            owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
            owdSetting.Oppty_Stage1__c = 'Plan - 1%';
            insert owdSetting;
            
            Profile profile = [select Id, Name from Profile where Name = 'System Administrator' limit 1];
            User testuser1 = new User(Username='test_user2' + System.currentTimeMillis() + '@DELL.com',
                                      Alias = 'Test', 
                                      Email='tes_user2'+'@dell.com',            
                                      LastName='Test',
                                      Title='GCC Program Manager', 
                                      ProfileId = profile.Id, 
                                      LanguageLocaleKey='en_US', 
                                      LocaleSidKey='en_US', 
                                      EmailEncodingKey='UTF-8', 
                                      TimeZoneSidKey='America/Los_Angeles',
                                      Badge_Number__c='Test'+System.currentTimeMillis());
            
            insert testuser1;
            TriggerExecutionController.setSkipAllTriggers(true); 
            
            list<User> listUserTdf=TestDataFactory.createNPortalUser(1);
            listUserTdf[0].isActive=true;
            insert listUserTdf;
            
            list<Account> listAccTdf=TestDataFactory.createNAccount(1, 'Partner Account');
            listAccTdf[0].Partner_Type__c = 'Distributor (GCC)';
            listAccTdf[0].Partner_Tier__c = 'Tier 1';
            listAccTdf[0].Status__c = 'Active';
            listAccTdf[0].Distribution_Sell_To_Countries__c = 'UNITED STATES';
            listAccTdf[0].DMU__c = false;                                         
            listAccTdf[0].Partner_Relationship__c = 'Authorized';
            listAccTdf[0].Account_Country__c = 'UNITED STATES';
            insert listAccTdf;
            
            list<Opportunity> listOppTdf=TestDataFactory.createNOpportunities(2, 'Standard Opportunity');
            for(Opportunity opp : listOppTdf){
                opp.AccountId=listAccTdf[0].id;
                opp.Probability = 1;
                opp.Forecast_Category_Override__c = 'Best Case';
            }
            listOppTdf[1].OwnerId  = testuser1.Id;
            insert listOppTdf;
            
            list<OpportunityTeamMember> listOppTeamMem=new list<OpportunityTeamMember>();
            OpportunityTeamMember testOppTeam = new OpportunityTeamMember();
            testOppTeam.OpportunityId = listOppTdf[0].Id; 
            testOppTeam.TeamMemberRole = 'DM Solutions Engineer';
            testOppTeam.UserId = listUserTdf[0].id;
            
            OpportunityTeamMember testOppTeam1 = new OpportunityTeamMember();
            testOppTeam1.OpportunityId = listOppTdf[1].Id; 
            testOppTeam1.TeamMemberRole = 'DM Solutions Engineer';
            testOppTeam1.UserId = testuser1.id;
            listOppTeamMem.add(testOppTeam);
            listOppTeamMem.add(testOppTeam1);
            insert testOppTeam;
            TriggerExecutionController.setSkipAllTriggers(false); 
        }   
    //Test Method 1: 
    static testMethod void testVFCntrlrUpdateSalesTeamMainCancel() {
        TriggerExecutionController.setSkipAllTriggers(true); 
        Test.startTest();
        
        //Test method for the function Cancel
        System.debug('#MN:START of testVFCntrlr_UpdateSalesTeamMainCancel()');
        PageReference pageRef = Page.Update_Sales_Team_Main;
        Test.setCurrentPage(pageRef);
        //Create Test Data 
        List<OpportunityTeamMember> listTeamMemberTest=[select opportunityid,TeamMemberRole,UserId,OpportunityAccessLevel from OpportunityTeamMember limit 1];
        
        List<Opportunity> listOpp=  [select id,Name,OwnerId from Opportunity where id=:listTeamMemberTest[0].opportunityId];
        
        ApexPages.currentPage().getParameters().put('id', listTeamMemberTest[0].opportunityId);
        // Instantiate a new controller with all parameters in the page
        VFCntrlr_UpdateSalesTeamMain controller = new VFCntrlr_UpdateSalesTeamMain();
        String strnextPage = controller.Cancel().getUrl();
        String strurlTobeChecked=(new ApexPages.StandardController(listOpp[0]).view()).getUrl();
        // Verify that the success page displays
        System.assertEquals(strurlTobeChecked,strnextPage);                                    
        System.debug('#MN:END of testVFCntrlr_UpdateSalesTeamMainCancel()');
        TriggerExecutionController.setSkipAllTriggers(false); 
        Test.stopTest();
    }
    
    //Test Method 2:
    public static testMethod void testVFCntrlrUpdateSalesTeamMainAdd() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();
        //Test method for the function Add
        System.debug('#MN:START of testVFCntrlr_UpdateSalesTeamMainAdd()');
        PageReference pageRef = Page.Update_Sales_Team_Main;
        Test.setCurrentPage(pageRef);
        //Create Test Data 
        List<OpportunityTeamMember> listTeamMemberTest=[select opportunityid,TeamMemberRole,UserId,OpportunityAccessLevel 
                                                        from OpportunityTeamMember limit 1];
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', listTeamMemberTest[0].opportunityId);
        // Instantiate a new controller with all parameters in the page
        VFCntrlr_UpdateSalesTeamMain controller = new VFCntrlr_UpdateSalesTeamMain();
        String strnextPage = controller.Add().getUrl();
        String strurlTobeChecked='/apex/addSalesTeamMembers?oid='+listTeamMemberTest[0].opportunityId;
        // Verify that the success page displays
        System.assertEquals(strurlTobeChecked,strnextPage);
        System.debug('#MN:END of testVFCntrlr_UpdateSalesTeamMainCancel()');
        TriggerExecutionController.setSkipAllTriggers(false); 
        Test.stopTest();
    }
    
    //Test Method 3:
    public static testMethod void testVFCntrlrUpdateSalesTeamMainDeleteTeamMember() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();       
        //Test method for the function DeleteTeamMember
        System.debug('#MN:START of testVFCntrlr_UpdateSalesTeamMainDeleteTeamMember()');
        PageReference pageRef = Page.Update_Sales_Team_Main;
        Test.setCurrentPage(pageRef);
        //Create Test Data
        List<OpportunityTeamMember> listTeamMemberTest=[select id,opportunityid,TeamMemberRole,UserId,OpportunityAccessLevel 
                                                        from OpportunityTeamMember limit 1];
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', listTeamMemberTest[0].opportunityId);
        // Instantiate a new controller with all parameters in the page
        VFCntrlr_UpdateSalesTeamMain controller = new VFCntrlr_UpdateSalesTeamMain();
        ApexPages.currentPage().getParameters().put('TMid', listTeamMemberTest[0].Id);
        // Verify that the success page displays
        System.assertEquals(null,controller.DeleteTeamMember());
        List<OpportunityTeamMember> listdelTeamMemberTest=[select id,opportunityid,TeamMemberRole,UserId,OpportunityAccessLevel 
                                                           from OpportunityTeamMember where id=:listTeamMemberTest[0].id];
        //Verify that the selected record get deleted
        //System.AssertEquals(0,listdelTeamMemberTest.size());     
        System.debug('#MN:END of testVFCntrlr_UpdateSalesTeamMainDeleteTeamMember()');
        TriggerExecutionController.setSkipAllTriggers(false); 
        Test.stopTest();
    }
    
    //Test Method 4:
    public static testMethod void testVFCntrlrUpdateSalesTeamMainDeleteAll() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();           
        //Test method for the function DeleteAll
        System.debug('#MN:START of testVFCntrlr_UpdateSalesTeamMainDeleteAll()');
        PageReference pageRef = Page.Update_Sales_Team_Main;
        Test.setCurrentPage(pageRef);
        //Create Test Data
        List<OpportunityTeamMember> listTeamMemberTest=[select opportunityid,TeamMemberRole,UserId,OpportunityAccessLevel 
                                                        from OpportunityTeamMember limit 1];
        
        List<Opportunity> listOpp=  [select id,Name from Opportunity where id=:listTeamMemberTest[0].opportunityId limit 1];
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', listTeamMemberTest[0].opportunityId);
        // Instantiate a new controller with all parameters in the page
        VFCntrlr_UpdateSalesTeamMain controller = new VFCntrlr_UpdateSalesTeamMain();
       // String strnextPage = controller.DeleteAll().getUrl();
        String strurlTobeChecked=(new ApexPages.StandardController(listOpp[0]).view()).getUrl();
        // Verify that the success page displays
        //System.assertEquals(strurlTobeChecked,strnextPage);
        List<OpportunityTeamMember> listexistTeamMemberTest=[select TeamMemberRole,UserId,OpportunityAccessLevel 
                                                             from OpportunityTeamMember where opportunityid=:listTeamMemberTest[0].opportunityid];
        // Verify that the All teammember of opportunity get deleted
        System.assertEquals(2,listexistTeamMemberTest.size());
        System.assertEquals(null, controller.DeleteAll());
        System.debug('#MN:END of testVFCntrlr_UpdateSalesTeamMainDeleteAll()');
        TriggerExecutionController.setSkipAllTriggers(false); 
        Test.stopTest();
    }
    
    //Test Method 5:
    public static testMethod void testVFCntrlrUpdateSalesTeamMainAddDefaultTeam() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();  
        //Test method for the function AddDefaultTeam
        System.debug('#MN:START of testVFCntrlr_UpdateSalesTeamMainAddDefaultTeam()');
        PageReference pageRef = Page.Update_Sales_Team_Main;
        Test.setCurrentPage(pageRef);
        
        list<User> listUser=[Select id from user where UserType =:'PowerPartner' Limit 1];
        //Create Test Data
        List<UserTeamMember> listDeafaultTeam= [SELECT OwnerId, UserId, OpportunityAccessLevel, TeamMemberRole 
                                                FROM UserTeamMember where User.IsActive=True and UserId =: listUser[0].Id];
        system.debug('deafaultteamlist:'+listDeafaultTeam);
        // List<Opportunity> OppList=new List<Opportunity>();
        List<Opportunity> listOpp=[select id, OwnerId, Name from Opportunity limit 2];
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', listOpp[1].Id);
        // Instantiate a new controller with all parameters in the page
        VFCntrlr_UpdateSalesTeamMain controller = new VFCntrlr_UpdateSalesTeamMain();
        controller.AddDefaultTeam();
        List<OpportunityTeamMember> listexistTeamMemberTest=[select TeamMemberRole,UserId,OpportunityAccessLevel 
                                                             from OpportunityTeamMember where opportunityid=:listOpp[1].id];
        List<UserTeamMember> listDeafaultTeamtoTest= [SELECT OwnerId, UserId, OpportunityAccessLevel, TeamMemberRole 
                                                      FROM UserTeamMember where OwnerId=:listOpp[1].OwnerId];
        //assert that default team get added to the sales team member list of opportunity
        System.assert(listexistTeamMemberTest.size()>=listDeafaultTeamtoTest.size());
        System.debug('#MN:END of testVFCntrlr_UpdateSalesTeamMainAddDefaultTeam()');
        TriggerExecutionController.setSkipAllTriggers(false); 
        test.stopTest();
    }
    //Test Method 6:
    public static testMethod void testVFCntrlrUpdateSalesTeamMainGetMethods() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();       
        //Test method for the function GetMethods
        System.debug('#MN:START of testVFCntrlr_UpdateSalesTeamMainGetMethods()');
        PageReference pageRef = Page.Update_Sales_Team_Main;
        Test.setCurrentPage(pageRef);
        //Create Test Data
        List<OpportunityTeamMember> listTeamMemberTest=[select opportunityid,TeamMemberRole,UserId,OpportunityAccessLevel 
                                                        from OpportunityTeamMember limit 1];
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', listTeamMemberTest[0].opportunityId);
        // Instantiate a new controller with all parameters in the page
        VFCntrlr_UpdateSalesTeamMain controller = new VFCntrlr_UpdateSalesTeamMain();
        List<OpportunityTeamMember> listexistTeamMemberTest=controller.getOpportunityTeamMembers();
        System.assert(listexistTeamMemberTest.size()>0);
        boolean bIsTeamMember=controller.getIsTeamMember();
        Opportunity currOpp=controller.getOpportunity();
        System.assertEquals(currOpp.id,listTeamMemberTest[0].opportunityid);
        boolean bdataAvailable=controller.getDataAvailable();
        boolean bNoTeamMembers=controller.getNoTeamMembers();
        System.debug('#MN:END of testVFCntrlr_UpdateSalesTeamMainGetMethods()');
        TriggerExecutionController.setSkipAllTriggers(false); 
        Test.stopTest();
    }
    //Test Method 7: 
    public static testMethod void testVFCntrlrUpdateSalesTeamMainCancelforDataNotAvailable() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();           
        //Test method for the function CancelNoDataAvailable
        System.debug('#MN:START of testVFCntrlr_UpdateSalesTeamMainCancelforDataNotAvailable()');
        PageReference pageRef = Page.Update_Sales_Team_Main;
        Test.setCurrentPage(pageRef);
        //Create Test Data 
        List<OpportunityTeamMember> listTeamMemberTest=[select opportunityid,TeamMemberRole,UserId,OpportunityAccessLevel 
                                                        from OpportunityTeamMember limit 1];
        
        List<Opportunity> listOpp=  [select id,Name from Opportunity where id=:listTeamMemberTest[0].opportunityId];
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', listTeamMemberTest[0].opportunityId);
        // Instantiate a new controller with all parameters in the page
        delete listOpp[0]; 
        VFCntrlr_UpdateSalesTeamMain controller = new VFCntrlr_UpdateSalesTeamMain();
        String strnextPage = controller.cancel().getUrl();
        // Verify that the success page displays
        System.assertEquals('/006/o', strnextPage);
        System.debug('#MN:END of testVFCntrlr_UpdateSalesTeamMainCancelforDataNotAvailable()');
        TriggerExecutionController.setSkipAllTriggers(false); 
        Test.stopTest();        
    }
    //Test Method 8:
    public static testMethod void testVFCntrlrUpdateSalesTeamMainAddDefaultTeamForceException() {
        TriggerExecutionController.setSkipAllTriggers(true); 
        SystemBehaviorBypasser.setSkipValidationRules(listObjAPINames);
        Test.startTest();
        //Test method for the function AddDefaultTeam
        System.debug('#MN:START of testVFCntrlr_UpdateSalesTeamMainAddDefaultTeamForceException()');
        PageReference pageRef = Page.Update_Sales_Team_Main;
        Test.setCurrentPage(pageRef);
        list<Opportunity> listOpp=[Select id from Opportunity Limit 2];
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', listOpp[0].Id);
        // Instantiate a new controller with all parameters in the page
        VFCntrlr_UpdateSalesTeamMain controller = new VFCntrlr_UpdateSalesTeamMain();
        delete listOpp[0];      
        //assert that add default team returns null
        System.assertEquals(null,controller.AddDefaultTeam());       
        System.debug('#MN:END of testVFCntrlr_UpdateSalesTeamMainAddDefaultTeamForceException()');
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false); 
    } 
    
    //Test Method 9:
    public static testMethod void testVFCntrlrUpdateSalesTeamMainDeleteTeamMemberForceException() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();
        //Test method for the function DeleteTeamMember
        System.debug('#MN:START of testVFCntrlr_UpdateSalesTeamMainDeleteTeamMemberForceException()');
        PageReference pageRef = Page.Update_Sales_Team_Main;
        Test.setCurrentPage(pageRef);
        //Create Test Data
        List<OpportunityTeamMember> listTeamMemberTest=[select id,opportunityid,TeamMemberRole,UserId,OpportunityAccessLevel 
                                                        from OpportunityTeamMember limit 1];
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', listTeamMemberTest[0].opportunityId);
        // Instantiate a new controller with all parameters in the page
        VFCntrlr_UpdateSalesTeamMain controller = new VFCntrlr_UpdateSalesTeamMain();
        ApexPages.currentPage().getParameters().put('TMid', listTeamMemberTest[0].Id);
        // Verify that the success page displays
        List<Opportunity> listOpp= [select id from Opportunity where id=:listTeamMemberTest[0].opportunityId limit 1];
        delete listOpp;
        System.assertEquals(null,controller.DeleteTeamMember());        
        System.debug('#MN:END of testVFCntrlr_UpdateSalesTeamMainDeleteTeamMemberForceException()');
        TriggerExecutionController.setSkipAllTriggers(false); 
        Test.stopTest();
    }    
}
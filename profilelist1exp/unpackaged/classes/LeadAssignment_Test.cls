/*
 * Author   : Ragu
 * Purpose  : To test LeadAssignment class. 
 *
 * Revision Ref Number  Release No      Date            Modified By     Description
 * -------- ----------  ----------      -----------     ------------    -----------
 * 1.0      CR 11967    16.10           22-Sep-2015     Ragu            Created.
 * 2.0      CR 11967    FY17-DCS-0502   31-Mar-2016     Gan             Added new test methods 
 * 2.1      TFS 1700383 FY17-DCS-0502   13-Apr-2016     Gan    
 */
 
@isTest
private class LeadAssignment_Test {

    static testMethod void test_GeneralMethods() {
        LeadAssignment.setForcePopulateFields(true);
        LeadAssignment.setForcePopulateFields(false);
    }

    static testMethod void test_LeadAssignmentToAccountOwner() {
        LeadAssignment_TestHelper.createAccounts();
        Account euAccount = LeadAssignment_TestHelper.endUserAccount;
        Account paAccount = LeadAssignment_TestHelper.partnerAccount;
        
        Test.startTest();
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        
        lstLeads[0].Account__c = euAccount.Id;
        lstLeads[1].Account__c = paAccount.Id;
        insert lstLeads;
        
        LeadAssignment.assignDirectLeads2(lstLeads);
        Test.stopTest();
    }
    
    static testMethod void test_LeadAssignmentBasedOnDefaultRoles() {
        LeadAssignment_TestHelper.createAccounts();
        Account euAccount = LeadAssignment_TestHelper.endUserAccount;
        Account paAccount = LeadAssignment_TestHelper.partnerAccount;
        
        LeadAssignment_TestHelper.createAccountTeam();
        
        Test.startTest();
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        
        lstLeads[0].Account__c = euAccount.Id;
        lstLeads[1].Account__c = paAccount.Id;
        insert lstLeads;
        
        //lstLeads[0].OwnerId = UserInfo.getUserId();
        //lstLeads[1].OwnerId = UserInfo.getUserId();
        //update lstLeads;
        Test.stopTest();
    }
    
    static testMethod void test_LeadAssignmentBasedOnGeo() {
        LeadAssignment_TestHelper.createAccounts();
        Account euAccount = LeadAssignment_TestHelper.endUserAccount;
        Account paAccount = LeadAssignment_TestHelper.partnerAccount;
        
        CampaignTestData.bCreate = false;
        CampaignTestData.iNumberOfCampaigns = 2;
        CampaignTestData.createCampaign2();
        list<Campaign> lstCampaigns = CampaignTestData.lstCampaigns;
        lstCampaigns[0].Follow_Up_Role__c = 'Business Development Manager';
        lstCampaigns[1].Follow_Up_Role__c = 'Business Development Manager';
        insert lstCampaigns;
        
        LeadAssignment_TestHelper.createAccountTeam();
        LeadAssignment_TestHelper.createTerritoryData();
        
        Test.startTest();
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 3;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        
        lstLeads[0].Account__c = euAccount.Id;
        lstLeads[1].Account__c = paAccount.Id;
        lstLeads[2].Account__c = paAccount.Id;
        lstLeads[2].Lead_Type__c = 'Outbound';
        lstCampaigns[1].Force_Follow_Up_Rule_for_Outbound_Leads__c= true;
        lstLeads[0].Campaign__c = lstCampaigns[0].Id;
        lstLeads[1].Campaign__c = lstCampaigns[0].Id;
        lstLeads[2].Campaign__c = lstCampaigns[1].Id;
        insert lstLeads;
        Test.stopTest();
    }
    
    static testMethod void test_LeadAssignmentBasedOnCampaignRoles() {
        LeadAssignment_TestHelper.createAccounts();
        Account euAccount = LeadAssignment_TestHelper.endUserAccount;
        Account paAccount = LeadAssignment_TestHelper.partnerAccount;
        LeadAssignment_TestHelper.createAccountTeam();
        
        CampaignTestData.bCreate = false;
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> lstCampaigns = CampaignTestData.lstCampaigns;
        lstCampaigns[0].Secondary_Role__c = 'Inside Sales Rep';
        insert lstCampaigns;
        
        Test.startTest();
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 2;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        
        // Test Secondary Role
        lstLeads[0].Account__c = euAccount.Id;
        lstLeads[1].Account__c = paAccount.Id;
        lstLeads[0].Campaign__c = lstCampaigns[0].Id;
        lstLeads[1].Campaign__c = lstCampaigns[0].Id;
        insert lstLeads;
        
        // Test Follow-Up Role
        lstCampaigns[0].Follow_Up_Role__c = 'Account Executive';
        update lstCampaigns;
        
        //lstLeads[0].Trigger_Lead_Assignment__c = true;
        //lstLeads[1].Trigger_Lead_Assignment__c = true;
        //update lstLeads;
        Test.stopTest();
    }
    
    //2.0
    static testMethod void test_LeadAssignmentBasedOnCampaignFollowUpRolesWithAccountOwner() {
        LeadAssignment_TestHelper.createAccountsWithOwner();
        Account euAccount = LeadAssignment_TestHelper.endUserAccount;
        Account paAccount = LeadAssignment_TestHelper.partnerAccount;
        
        LeadAssignment_TestHelper.createAccountTeamWithAccountOwnerAsAE();
        
        CampaignTestData.bCreate = false;
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> lstCampaigns = CampaignTestData.lstCampaigns;
        lstCampaigns[0].Follow_Up_Role__c = 'Account Executive';
        insert lstCampaigns;
        
        Test.startTest();
        system.assertNotEquals(euAccount.OwnerId, null);
        system.assertNotEquals(paAccount.OwnerId, null);
        
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        
        // Test Secondary Role
        lstLeads[0].Account__c = euAccount.Id;
        lstLeads[0].Campaign__c = lstCampaigns[0].Id;

        insert lstLeads;
        
        Lead ldToVerify = [Select id, ownerid from lead where id = :lstLeads[0].id];
        System.assertEquals(euAccount.OwnerId, ldToVerify.OwnerId);
       
        Test.stopTest();
    }
    
    //2.0
    static testMethod void test_LeadAssignmentBasedOnCampaignAccountOwnerFollowUpRoles() {
        LeadAssignment_TestHelper.createAccountsWithOwner();
        Account euAccount = LeadAssignment_TestHelper.endUserAccount;
        Account paAccount = LeadAssignment_TestHelper.partnerAccount;
        
        LeadAssignment_TestHelper.createAccountTeamWithAccountOwnerAsAE();
        
        CampaignTestData.bCreate = false;
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> lstCampaigns = CampaignTestData.lstCampaigns;
        lstCampaigns[0].Follow_Up_Role__c = 'Account Owner';
        insert lstCampaigns;
        
        Test.startTest();
        system.assertNotEquals(euAccount.OwnerId, null);
        system.assertNotEquals(paAccount.OwnerId, null);
        
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        
        // Test Secondary Role
        lstLeads[0].Account__c = euAccount.Id;
        lstLeads[0].Campaign__c = lstCampaigns[0].Id;
        
        insert lstLeads;
        
        Lead ldToVerify = [Select id, ownerid from lead where id = :lstLeads[0].id];
        System.assertEquals(euAccount.OwnerId, ldToVerify.OwnerId);
        
        Test.stopTest();
    }
    
    //2.0
    static testMethod void test_LeadAssignmentBasedOnCampaignSecondaryFollowUpRolesWithAccountOwner() {
        LeadAssignment_TestHelper.createAccountsWithOwner();
        Account euAccount = LeadAssignment_TestHelper.endUserAccount;
        Account paAccount = LeadAssignment_TestHelper.partnerAccount;
        
        LeadAssignment_TestHelper.createAccountTeamWithAccountOwnerAsAE();
        
        CampaignTestData.bCreate = false;
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> lstCampaigns = CampaignTestData.lstCampaigns;
        lstCampaigns[0].Secondary_Role__c = 'Account Executive';
        insert lstCampaigns;
        
        Test.startTest();
        system.assertNotEquals(euAccount.OwnerId, null);
        system.assertNotEquals(paAccount.OwnerId, null);
        
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        
        // Test Secondary Role
        lstLeads[0].Account__c = euAccount.Id;
        lstLeads[0].Campaign__c = lstCampaigns[0].Id;
        
        insert lstLeads;
        
        Lead ldToVerify = [Select id, ownerid from lead where id = :lstLeads[0].id];
        System.assertEquals(euAccount.OwnerId, ldToVerify.OwnerId);
        
        Test.stopTest();
    }
    
    //2.0
    static testMethod void test_LeadAssignmentBasedOnCampaignAccountOwnerSecondaryFollowUpRoles() {
        LeadAssignment_TestHelper.createAccountsWithOwner();
        Account euAccount = LeadAssignment_TestHelper.endUserAccount;
        Account paAccount = LeadAssignment_TestHelper.partnerAccount;
        
        LeadAssignment_TestHelper.createAccountTeamWithAccountOwnerAsAE();
        
        CampaignTestData.bCreate = false;
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> lstCampaigns = CampaignTestData.lstCampaigns;
        lstCampaigns[0].Secondary_Role__c = 'Account Owner';
        insert lstCampaigns;
        
        Test.startTest();
        system.assertNotEquals(euAccount.OwnerId, null);
        system.assertNotEquals(paAccount.OwnerId, null);
        
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        
        // Test Secondary Role
        lstLeads[0].Account__c = euAccount.Id;
        lstLeads[0].Campaign__c = lstCampaigns[0].Id;
       
        insert lstLeads;
        
        Lead ldToVerify = [Select id, ownerid from lead where id = :lstLeads[0].id];
        System.assertEquals(euAccount.OwnerId, ldToVerify.OwnerId);
        
        Test.stopTest();
    }
    
    //2.0
    static testMethod void test_LeadAssignmentBasedDefaultRolesAccountOwner() {
        LeadAssignment_TestHelper.createAccountsWithOwner();
        Account euAccount = LeadAssignment_TestHelper.endUserAccount;
        Account paAccount = LeadAssignment_TestHelper.partnerAccount;
        
        LeadAssignment_TestHelper.createAccountTeamWithAccountOwnerAsAEForDefaultRoleAssignment();
        
        CampaignTestData.bCreate = false;
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> lstCampaigns = CampaignTestData.lstCampaigns;
        lstCampaigns[0].Follow_Up_Role__c = 'Global Account Manager';
        lstCampaigns[0].Secondary_Role__c = 'Global Project Manager';
        insert lstCampaigns;
        
        Test.startTest();
        system.assertNotEquals(euAccount.OwnerId, null);
        system.assertNotEquals(paAccount.OwnerId, null);
        
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        
        // Test Default Role
        lstLeads[0].Account__c = euAccount.Id;
        lstLeads[0].Campaign__c = lstCampaigns[0].Id;
        
        insert lstLeads;
        
        Lead ldToVerify = [Select id, ownerid from lead where id = :lstLeads[0].id];
        System.assertEquals(euAccount.OwnerId, ldToVerify.OwnerId);
        
        Test.stopTest();
    }
    
    //2.0 test force follow up role for outbound lead
    static testMethod void test_LeadAssignmentForceFollowUpRole() {
        LeadAssignment_TestHelper.createAccountsWithOwner();
        Account euAccount = LeadAssignment_TestHelper.endUserAccount;
        Account paAccount = LeadAssignment_TestHelper.partnerAccount;
        
        LeadAssignment_TestHelper.createAccountTeamWithAccountOwnerAsAEForDefaultRoleAssignment();
        
        CampaignTestData.bCreate = false;
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> lstCampaigns = CampaignTestData.lstCampaigns;
        lstCampaigns[0].Follow_Up_Role__c = 'Global Account Manager';
        lstCampaigns[0].Secondary_Role__c = 'Global Project Manager';
        lstCampaigns[0].Force_Follow_Up_Rule_for_Outbound_Leads__c = true;
        insert lstCampaigns;
        
        Test.startTest();
        system.assertNotEquals(euAccount.OwnerId, null);
        system.assertNotEquals(paAccount.OwnerId, null);
        
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        
        // Test Default Role
        lstLeads[0].Account__c = euAccount.Id;
        lstLeads[0].Campaign__c = lstCampaigns[0].Id;
        lstLeads[0].Lead_Type__c = 'Outbound';
        
        insert lstLeads;
        
        Lead ldToVerify = [Select id, ownerid, createdById from lead where id = :lstLeads[0].id];
        System.assertEquals(ldToVerify.createdById, ldToVerify.Ownerid);
        
        Test.stopTest();
        
    }
    
    //2.1
    static testMethod void test_LeadAssignmentBasedOnCampaignSecondaryFollowUpRolesWithNonNumericAccountOwner() {
        LeadAssignment_TestHelper.createAccountsWithNonNumericOwner();
        Account euAccount = LeadAssignment_TestHelper.endUserAccount;
        Account paAccount = LeadAssignment_TestHelper.partnerAccount;
      
        LeadAssignment_TestHelper.createAccountTeamWithNonNumericAccountOwnerAsAE();
        
        CampaignTestData.bCreate = false;
        CampaignTestData.iNumberOfCampaigns = 1;
        CampaignTestData.createCampaign2();
        list<Campaign> lstCampaigns = CampaignTestData.lstCampaigns;
        lstCampaigns[0].Secondary_Role__c = 'Account Executive';
        insert lstCampaigns;
        
        Test.startTest();
        system.assertNotEquals(euAccount.OwnerId, null);
        system.assertNotEquals(paAccount.OwnerId, null);
        
        LeadTestData.bCreate = false;
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        
        // Test Secondary Role
        lstLeads[0].Account__c = euAccount.Id;
        lstLeads[0].Campaign__c = lstCampaigns[0].Id;
        
        insert lstLeads;
        
        Lead ldToVerify = [Select id, ownerid from lead where id = :lstLeads[0].id];
        System.assertEquals(euAccount.OwnerId, ldToVerify.OwnerId);
        
        Test.stopTest();
    }
    
}
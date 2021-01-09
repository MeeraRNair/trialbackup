/*
 * Author   : Ragu
 * Purpose  : To test LeadAssignmentHelper class. 
 *
 * Revision Ref Number  Release No      Date            Modified By     Description
 * -------- ----------  ----------      -----------     ------------    -----------
 * 1.0      CR 11967    16.10           22-Sep-2015     Ragu            Created.
 * 2.0      CR 12985    FY17-DCS-0502   31-Mar-2016     Gan    
 * 2.1      TFS 1700383 FY17-DCS-0502   13-Apr-2016     Gan             
 */
 
@isTest
private class LeadAssignmentHelper_Test {

    static testMethod void test_GeneralMethods() {
        LeadAssignment_TestHelper.createAccounts();
        Account euAccount = LeadAssignment_TestHelper.endUserAccount;
        map<Id, Account> mapAccounts = LeadAssignmentHelper.queryAccounts(new list<Lead>{new Lead(Firstname = 'Test', Lastname = 'Lastname', Account__c = euAccount.Id)});
        
        // Test getCampaignRoles() & getCampaignPrimaryRoles()
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        
        map<Id, Campaign> mapCampaigns = new map<Id, Campaign>([select Id, Follow_Up_Role__c, Secondary_Role__c from Campaign where Id = :lstLeads[0].Campaign__c]);
        
        Test.startTest();
        LeadAssignmentHelper.getCampaignRoles(lstLeads, mapCampaigns);
        LeadAssignmentHelper.getCampaignPrimaryRoles(lstLeads, mapCampaigns);
        Test.stopTest();
    }
    
    static testMethod void test_AccountTeamRelatedMethods() {
        LeadAssignment_TestHelper.createAccounts();
        Account euAccount = LeadAssignment_TestHelper.endUserAccount;
        Account paAccount = LeadAssignment_TestHelper.partnerAccount;
        LeadAssignment_TestHelper.createAccountTeam();
        
        Test.startTest();
        LeadAssignmentHelper.getAccountIdRoleTeamMemberMap(new set<Id>{euAccount.Id, paAccount.Id}, LeadAssignmentHelper.getAdditionalRoles());
        Test.stopTest();
    }
    
    static testMethod void test_TerritoryRelatedMethods() {
        TriggerExecutionController.setSkipAllTriggers(true);
        LeadAssignment_TestHelper.createAccounts();
        Account euAccount = LeadAssignment_TestHelper.endUserAccount;
        map<Id, Account> mapAccounts = LeadAssignmentHelper.queryAccounts(new list<Lead>{new Lead(Firstname = 'Test', Lastname = 'Lastname', Account__c = euAccount.Id)});
        
        
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        lstLeads.addAll(LeadTestData.lstLeads);
        
        map<Id, Campaign> mapCampaigns = new map<Id, Campaign>([select Id, Follow_Up_Role__c, Secondary_Role__c from Campaign where Id in : (new set<Id>{lstLeads[0].Campaign__c, lstLeads[1].Campaign__c})]);
        mapCampaigns.get(lstLeads[0].Campaign__c).Follow_Up_Role__c = 'Business Development Manager';
        mapCampaigns.get(lstLeads[1].Campaign__c).Follow_Up_Role__c = 'Business Development Representative';
        
        LeadAssignment_TestHelper.createTerritoryData();
        
        Test.startTest();
        LeadAssignmentHelper.prepareTerritoryDetails(lstLeads, mapCampaigns, mapAccounts);
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    static testMethod void test_ConfigurationRelatedMethods() {
        LeadAssignmentHelper.getOwnerFieldConfiguration();
        LeadAssignmentHelper.getUserFieldConfiguration();
        LeadAssignmentHelper.getTrackingFields();
        LeadAssignmentHelper.getDefaultRoles();
        LeadAssignmentHelper.getAdditionalRoles();
    }
    
    //2.0
    static testMethod void test_AccountOwnerAndRolesInTeam() {
        LeadAssignment_TestHelper.createAccountsWithOwner();
        Account euAccount = LeadAssignment_TestHelper.endUserAccount;
        LeadAssignment_TestHelper.createAccountTeamWithAccountOwnerAsAE();
        
        map<id, map<string, list<string>>> mapAccountRoleUserIds = LeadAssignmentHelper.getAccountIdRoleTeamMemberMap(new set<Id>{euAccount.Id}, LeadAssignmentHelper.getAdditionalRoles());
        map<Id, Account> mapAccounts = LeadAssignmentHelper.queryAccounts(new list<Lead>{new Lead(Firstname = 'Test', Lastname = 'Lastname', Account__c = euAccount.Id)});
        
        Test.startTest();
        LeadAssignmentHelper.getAccIdOwnerRolesInTeamMap(mapAccounts, mapAccountRoleUserIds);
        Test.stopTest();
        
    }
    
    //2.1
    static testMethod void test_getAccountIdRoleTeamMemberMap() {
        LeadAssignment_TestHelper.createAccounts();
        Account euAccount = LeadAssignment_TestHelper.endUserAccount;
        Account paAccount = LeadAssignment_TestHelper.partnerAccount;
        LeadAssignment_TestHelper.createAccountTeamWithNonNumericBadge();
        
        Test.startTest();
        LeadAssignmentHelper.getAccountIdRoleTeamMemberMap(new set<Id>{euAccount.Id, paAccount.Id}, LeadAssignmentHelper.getAdditionalRoles());
        Test.stopTest();
    }
    
}
/*
 * Author   : Ragu
 * Purpose  : Utility test class for creating Account related data. 
 *
 * Revision Ref Number  Release No      Date            Modified By     Description
 * -------- ----------  ----------      -----------     ------------    -----------
 * 1.0      CR 11967    16.10           23-Sep-2015     Ragu            Created.
 * 2.0      CR 11967    FY17-DCS-0502   31-Mar-2016     Gan             Create new testmethods
 * 2.1      TFS 1700383 FY17-DCS-0502   13-Apr-2016     Gan      
 * 3.0                  FY17-DCS-0602   18-May-2016     Gan             Fix the test failure during the 0502 deployment.   
 */
 
@isTest(SeeAllData=false)
public class LeadAssignment_TestHelper {

    public static Account endUserAccount;
    public static Account partnerAccount;
    
    public static testMethod void createAccounts() {
        // Create Accounts
        AccountTestData.iNumberOfAccounts = 1;
        AccountTestData.bCreate = false;
        
        AccountTestData.createEndUserAccount();
        endUserAccount = AccountTestData.lstAccounts[0];
        endUserAccount.Account_Country__c = 'Malaysia';
        endUserAccount.ShippingState = 'Selangor';
        endUserAccount.ShippingPostalCode = '63000';
        
        AccountTestData.createPartnerAccount();
        partnerAccount = AccountTestData.lstAccounts[0];
        partnerAccount.Account_Country__c = 'Malaysia';
        partnerAccount.ShippingState = 'Selangor';
        partnerAccount.ShippingPostalCode = '63000';
        
        insert (new list<Account>{endUserAccount, partnerAccount});
    }
    
    //2.0
    public static testMethod void createAccountsWithOwner() {
        
        UserTestData.iNumberOfUsers = 1;
        UserTestData.createInternalUsers();
        User lstUsers = UserTestData.lstUsers[0];
        
        // Create Accounts
        AccountTestData.iNumberOfAccounts = 1;
        AccountTestData.bCreate = false;
        
        AccountTestData.createEndUserAccount();
        endUserAccount = AccountTestData.lstAccounts[0];
        endUserAccount.Account_Country__c = 'Malaysia';
        endUserAccount.ShippingState = 'Selangor';
        endUserAccount.ShippingPostalCode = '63000';
        endUserAccount.OwnerId = lstUsers.Id;
        
        AccountTestData.createPartnerAccount();
        partnerAccount = AccountTestData.lstAccounts[0];
        partnerAccount.Account_Country__c = 'Malaysia';
        partnerAccount.ShippingState = 'Selangor';
        partnerAccount.ShippingPostalCode = '63000';
        partnerAccount.OwnerId = lstUsers.Id;
        
        insert (new list<Account>{endUserAccount, partnerAccount});
    }
    
    //2.1
    public static testMethod void createAccountsWithNonNumericOwner() {
        
        UserTestData.iNumberOfUsers = 1;
        UserTestData.bCreate = false;
        UserTestData.createInternalUsers();
        User owner = UserTestData.lstUsers[0];
        //3.0
        owner.badge_number__c = '987Af' + String.valueOf(Math.round(Math.random()*1000000000));
        
        insert owner;
        
        // Create Accounts
        AccountTestData.iNumberOfAccounts = 1;
        AccountTestData.bCreate = false;
        
        AccountTestData.createEndUserAccount();
        endUserAccount = AccountTestData.lstAccounts[0];
        endUserAccount.Account_Country__c = 'Malaysia';
        endUserAccount.ShippingState = 'Selangor';
        endUserAccount.ShippingPostalCode = '63000';
        endUserAccount.OwnerId = owner.Id;
        
        AccountTestData.createPartnerAccount();
        partnerAccount = AccountTestData.lstAccounts[0];
        partnerAccount.Account_Country__c = 'Malaysia';
        partnerAccount.ShippingState = 'Selangor';
        partnerAccount.ShippingPostalCode = '63000';
        partnerAccount.OwnerId = owner.Id;
        
        insert (new list<Account>{endUserAccount, partnerAccount});
    }
    
    public static testMethod void createAccountTeam() {
        if(endUserAccount == null || partnerAccount == null) {
            createAccounts();
        }
                
        // Create Account Team Members
        UserTestData.iNumberOfUsers = 5;
        //UserTestData.bCreate = false;
        UserTestData.createInternalUsers();
        list<User> lstUsers = UserTestData.lstUsers;
        
        //insert lstUsers;
        System.debug('endUserAccount: ' + endUserAccount);
        System.debug('partnerAccount: ' + partnerAccount);
        System.debug('lstUsers: ' + lstUsers);
        
        AccountTeamMember euAccTeamMember1 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[0].Id, TeamMemberRole = 'Account Executive');
        AccountTeamMember euAccTeamMember2 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[1].Id, TeamMemberRole = 'Inside Sales Rep');
        AccountTeamMember euAccTeamMember3 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[2].Id, TeamMemberRole = 'Inside Sales Manager');
        AccountTeamMember euAccTeamMember4 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[3].Id, TeamMemberRole = 'Regional Sales Manager');
        AccountTeamMember euAccTeamMember5 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[4].Id, TeamMemberRole = 'Regional Sales Manager');
        AccountTeamMember paAccTeamMember1 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[0].Id, TeamMemberRole = 'Partner Development Manager');
        AccountTeamMember paAccTeamMember2 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[1].Id, TeamMemberRole = 'Inside Channel Account Manager');
        AccountTeamMember paAccTeamMember3 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[2].Id, TeamMemberRole = 'Channel Inside Sales Manager');
        AccountTeamMember paAccTeamMember4 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[3].Id, TeamMemberRole = 'Regional Sales Manager');
        AccountTeamMember paAccTeamMember5 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[4].Id, TeamMemberRole = 'Regional Sales Manager');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert (new list<AccountTeamMember>{euAccTeamMember1, euAccTeamMember2, euAccTeamMember3, euAccTeamMember4, euAccTeamMember5, paAccTeamMember1, paAccTeamMember2, paAccTeamMember3, paAccTeamMember4, paAccTeamMember5});
    TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    //2.0
    public static testMethod void createAccountTeamWithAccountOwnerAsAE() {
        if(endUserAccount == null || partnerAccount == null) {
            createAccountsWithOwner();
        }
        
        // Create Account Team Members
        UserTestData.iNumberOfUsers = 5;
        UserTestData.createInternalUsers();
        list<User> lstUsers = UserTestData.lstUsers;
        
        AccountTeamMember euAccTeamMember1 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[0].Id, TeamMemberRole = 'Account Executive');
        AccountTeamMember euAccTeamMember2 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[1].Id, TeamMemberRole = 'Inside Sales Rep');
        AccountTeamMember euAccTeamMember3 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[2].Id, TeamMemberRole = 'Inside Sales Manager');
        AccountTeamMember euAccTeamMember4 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[3].Id, TeamMemberRole = 'Regional Sales Manager');
        AccountTeamMember euAccTeamMember5 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[4].Id, TeamMemberRole = 'Regional Sales Manager');
        AccountTeamMember euAccTeamMember6 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = endUserAccount.OwnerId, TeamMemberRole = 'Account Executive');
        
        AccountTeamMember paAccTeamMember1 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[0].Id, TeamMemberRole = 'Partner Development Manager');
        AccountTeamMember paAccTeamMember2 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[1].Id, TeamMemberRole = 'Inside Channel Account Manager');
        AccountTeamMember paAccTeamMember3 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[2].Id, TeamMemberRole = 'Channel Inside Sales Manager');
        AccountTeamMember paAccTeamMember4 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[3].Id, TeamMemberRole = 'Regional Sales Manager');
        AccountTeamMember paAccTeamMember5 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[4].Id, TeamMemberRole = 'Regional Sales Manager');
        AccountTeamMember paAccTeamMember6 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = partnerAccount.OwnerId, TeamMemberRole = 'Partner Development Manager');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert (new list<AccountTeamMember>{euAccTeamMember1, euAccTeamMember2, euAccTeamMember3, euAccTeamMember4, euAccTeamMember5, euAccTeamMember6, paAccTeamMember1, paAccTeamMember2, paAccTeamMember3, paAccTeamMember4, paAccTeamMember5, paAccTeamMember6});
    TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    //2.0
    public static testMethod void createAccountTeamWithAccountOwnerAsAEForDefaultRoleAssignment() {
        if(endUserAccount == null || partnerAccount == null) {
            createAccountsWithOwner();
        }
        
        // Create Account Team Members
        UserTestData.iNumberOfUsers = 4;
        UserTestData.createInternalUsers();
        list<User> lstUsers = UserTestData.lstUsers;
        
        AccountTeamMember euAccTeamMember1 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[0].Id, TeamMemberRole = 'Account Executive');
        AccountTeamMember euAccTeamMember2 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[1].Id, TeamMemberRole = 'Inside Sales Manager');
        AccountTeamMember euAccTeamMember3 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[2].Id, TeamMemberRole = 'Regional Sales Manager');
        AccountTeamMember euAccTeamMember4 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[3].Id, TeamMemberRole = 'Regional Sales Manager');
        AccountTeamMember euAccTeamMember5 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = endUserAccount.OwnerId, TeamMemberRole = 'Account Executive');

        
        AccountTeamMember paAccTeamMember1 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[0].Id, TeamMemberRole = 'Partner Development Manager');
        AccountTeamMember paAccTeamMember2 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[1].Id, TeamMemberRole = 'Channel Inside Sales Manager');
        AccountTeamMember paAccTeamMember3 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[2].Id, TeamMemberRole = 'Regional Sales Manager');
        AccountTeamMember paAccTeamMember4 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[3].Id, TeamMemberRole = 'Regional Sales Manager');
        AccountTeamMember paAccTeamMember5 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = partnerAccount.OwnerId, TeamMemberRole = 'Partner Development Manager');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert (new list<AccountTeamMember>{euAccTeamMember1, euAccTeamMember2, euAccTeamMember3, euAccTeamMember4, euAccTeamMember5, paAccTeamMember1, paAccTeamMember2, paAccTeamMember3, paAccTeamMember4, paAccTeamMember5});
        TriggerExecutionController.setSkipAllTriggers(false);
    }

    //2.1
    public static testMethod void createAccountTeamWithNonNumericAccountOwnerAsAE() {
        if(endUserAccount == null || partnerAccount == null) {
            createAccountsWithNonNumericOwner();
        }
        
        // Create Account Team Members
        UserTestData.iNumberOfUsers = 5;
        UserTestData.bCreate = false;
        UserTestData.createInternalUsers();
        list<User> lstUsers = UserTestData.lstUsers;
        
        //3.0
        // user with badge number
        lstUsers[0].badge_number__c = '1010' + String.valueOf(Math.round(Math.random()*1000000000)) + '0202';
        lstUsers[1].badge_number__c = '2020' + String.valueOf(Math.round(Math.random()*1000000000)) + '0303';
        lstUsers[2].badge_number__c = '3030' + String.valueOf(Math.round(Math.random()*1000000000)) + '0404';
        lstUsers[3].badge_number__c = '4040' + String.valueOf(Math.round(Math.random()*1000000000)) + '0505';
        lstUsers[4].badge_number__c = '5050' + String.valueOf(Math.round(Math.random()*1000000000)) + '0606';
        insert lstUsers;
        
        system.debug('ZY => userid : ' + endUserAccount.OwnerId + ', ' + partnerAccount.OwnerId + ', ' + lstUsers[0].Id + ', ' + lstUsers[1].Id + ', ' + lstUsers[2].Id + ', ' + lstUsers[3].Id + ', ' + lstUsers[4].Id);
        AccountTeamMember euAccTeamMember1 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[0].Id, TeamMemberRole = 'Account Executive');
        AccountTeamMember euAccTeamMember2 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[1].Id, TeamMemberRole = 'Inside Sales Rep');
        AccountTeamMember euAccTeamMember3 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[2].Id, TeamMemberRole = 'Inside Sales Manager');
        AccountTeamMember euAccTeamMember4 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[3].Id, TeamMemberRole = 'Regional Sales Manager');
        AccountTeamMember euAccTeamMember5 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[4].Id, TeamMemberRole = 'Regional Sales Manager');
        AccountTeamMember euAccTeamMember6 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = endUserAccount.OwnerId, TeamMemberRole = 'Account Executive');
        
        AccountTeamMember paAccTeamMember1 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[0].Id, TeamMemberRole = 'Partner Development Manager');
        AccountTeamMember paAccTeamMember2 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[1].Id, TeamMemberRole = 'Inside Channel Account Manager');
        AccountTeamMember paAccTeamMember3 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[2].Id, TeamMemberRole = 'Channel Inside Sales Manager');
        AccountTeamMember paAccTeamMember4 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[3].Id, TeamMemberRole = 'Regional Sales Manager');
        AccountTeamMember paAccTeamMember5 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[4].Id, TeamMemberRole = 'Regional Sales Manager');
        AccountTeamMember paAccTeamMember6 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = partnerAccount.OwnerId, TeamMemberRole = 'Partner Development Manager');
        TriggerExecutionController.setSkipAllTriggers(true);     
 
        insert (new list<AccountTeamMember>{euAccTeamMember1, euAccTeamMember2, euAccTeamMember3, euAccTeamMember4, euAccTeamMember5, euAccTeamMember6, paAccTeamMember1, paAccTeamMember2, paAccTeamMember3, paAccTeamMember4, paAccTeamMember5, paAccTeamMember6});
    TriggerExecutionController.setSkipAllTriggers(false);     
 
    }
    
    //2.1
    public static testMethod void createAccountTeamWithNonNumericBadge() {
        if(endUserAccount == null || partnerAccount == null) {
            createAccounts();
        }
        
        // Create Account Team Members
        UserTestData.iNumberOfUsers = 4;
        UserTestData.bCreate = false;
        UserTestData.createInternalUsers();
        list<User> lstUsers = UserTestData.lstUsers;
        
        //3.0
        // numeric user
        lstUsers[0].badge_number__c = '1010' + String.valueOf(Math.round(Math.random()*1000000000)) + '0202';
        // non numeric user
        lstUsers[1].badge_number__c = 'derkj' + String.valueOf(Math.round(Math.random()*1000000000));
        lstUsers[2].badge_number__c = '1' + String.valueOf(Math.round(Math.random()*1000000000)) + 'abcfh';
        lstUsers[3].badge_number__c = '2'+ String.valueOf(Math.round(Math.random()*1000000000)) + 'abcfh';

        insert lstUsers;
        
        AccountTeamMember euAccTeamMember1 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[0].Id, TeamMemberRole = 'Account Executive');
        AccountTeamMember euAccTeamMember2 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[1].Id, TeamMemberRole = 'Inside Sales Manager');
        AccountTeamMember euAccTeamMember3 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[2].Id, TeamMemberRole = 'Regional Sales Manager');
        AccountTeamMember euAccTeamMember4 = new AccountTeamMember(AccountId = endUserAccount.Id, UserId = lstUsers[3].Id, TeamMemberRole = 'Regional Sales Manager');

        AccountTeamMember paAccTeamMember1 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[0].Id, TeamMemberRole = 'Partner Development Manager');
        AccountTeamMember paAccTeamMember2 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[1].Id, TeamMemberRole = 'Channel Inside Sales Manager');
        AccountTeamMember paAccTeamMember3 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[2].Id, TeamMemberRole = 'Regional Sales Manager');
        AccountTeamMember paAccTeamMember4 = new AccountTeamMember(AccountId = partnerAccount.Id, UserId = lstUsers[3].Id, TeamMemberRole = 'Regional Sales Manager');
        
        TriggerExecutionController.setSkipAllTriggers(true);
        insert (new list<AccountTeamMember>{euAccTeamMember1, euAccTeamMember2, euAccTeamMember3, euAccTeamMember4, paAccTeamMember1, paAccTeamMember2, paAccTeamMember3, paAccTeamMember4});
        TriggerExecutionController.setSkipAllTriggers(false);

    }
    
    public static testMethod void createTerritoryData() {
        // Create Geography
        Id countryRTId = StaticFactory.getRecordTypeIdByName('Geography__c', 'Country');
        Id stateRTId = StaticFactory.getRecordTypeIdByName('Geography__c', 'State');
        Id zipcodeRTId = StaticFactory.getRecordTypeIdByName('Geography__c', 'Zipcode');
        
        Geography__c countryGeo = new Geography__c(Name = 'Malaysia', RecordTypeId = countryRTId);
        insert countryGeo;
        
        Geography__c stateGeo = new Geography__c(Name = 'Selangor', RecordTypeId = stateRTId, Country__c = countryGeo.Id);
        insert stateGeo;
        
        Geography__c zipGeo = new Geography__c(Name = '63000', RecordTypeId = zipcodeRTId, State__c = stateGeo.Id, Country__c = countryGeo.Id);
        insert zipGeo;
        
        
        // Create Territory
        Territory__c countryTerritory = new Territory__c(Name = 'Malaysia', Group__c = 'Cloud Client Computing', Geography_Type__c = 'Country', Is_Active__c = true);
        Territory__c stateTerritory = new Territory__c(Name = 'Selangor', Group__c = 'Cloud Client Computing', Geography_Type__c = 'State', Is_Active__c = true);
        Territory__c zipTerritory = new Territory__c(Name = 'Cyberjaya', Group__c = 'Cloud Client Computing', Geography_Type__c = 'Zipcode', Is_Active__c = true);
        insert (new list<Territory__c>{countryTerritory, stateTerritory, zipTerritory});
        
        
        // Create Territory and Geo Assignment
        Territory_Geo_Assignment__c countryTGA = new Territory_Geo_Assignment__c(Territory__c = countryTerritory.Id, Geography__c = countryGeo.Id);
        Territory_Geo_Assignment__c stateTGA = new Territory_Geo_Assignment__c(Territory__c = stateTerritory.Id, Geography__c = stateGeo.Id);
        Territory_Geo_Assignment__c zipTGA = new Territory_Geo_Assignment__c(Territory__c = zipTerritory.Id, Geography__c = zipGeo.Id);
        insert (new list<Territory_Geo_Assignment__c>{countryTGA, stateTGA, zipTGA});
        
        
        // Create Role
        Role__c bdmRole = new Role__c(Name = 'Business Development Manager', Group__c = 'Cloud Client Computing', Is_Active__c = true);
        Role__c bdrRole = new Role__c(Name = 'Business Development Representative', Group__c = 'Cloud Client Computing', Is_Active__c = true);
        insert (new list<Role__c>{bdmRole, bdrRole});
        
        
        // Create Territory and Sales User Assignment
        UserTestData.iNumberOfUsers = 4;
        UserTestData.createInternalUsers();
        list<User> lstUsers = UserTestData.lstUsers;
        
        Territory_Sales_User_Assignment__c countryTSUA1 = new Territory_Sales_User_Assignment__c(Territory__c = countryTerritory.Id, Group__c = 'Cloud Client Computing', Role__c = bdmRole.Id, User__c = lstUsers[0].Id, Is_Active__c = true);
        Territory_Sales_User_Assignment__c countryTSUA2 = new Territory_Sales_User_Assignment__c(Territory__c = countryTerritory.Id, Group__c = 'Cloud Client Computing', Role__c = bdrRole.Id, User__c = lstUsers[1].Id, Is_Active__c = true);
        Territory_Sales_User_Assignment__c stateTSUA = new Territory_Sales_User_Assignment__c(Territory__c = stateTerritory.Id, Group__c = 'Cloud Client Computing', Role__c = bdmRole.Id, User__c = lstUsers[2].Id, Is_Active__c = true);
        Territory_Sales_User_Assignment__c zipTSUA = new Territory_Sales_User_Assignment__c(Territory__c = zipTerritory.Id, Group__c = 'Cloud Client Computing', Role__c = bdmRole.Id, User__c = lstUsers[3].Id, Is_Active__c = true);
        insert (new list<Territory_Sales_User_Assignment__c>{countryTSUA1, countryTSUA2, stateTSUA, zipTSUA});
    }
    
}
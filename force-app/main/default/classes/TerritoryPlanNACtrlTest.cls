/***********************************************************
    * Name          : TerritoryPlanNACtrlTest 
    * ---------------------------------------------------------
    * Revision  Name     CR#        Date           Description
    * 1.0       Swathi   CR13026    11 Apr 2016    test class for Validate region and user for Territory plan printing 
    
************************************************************/
@isTest
private class TerritoryPlanNACtrlTest{

  static testMethod void testcreateaccountteammember(){     
    test.startTest();
    // Set up the Account record.
    Account Account_a = new Account(Name='Test Account',Account_Country__c = 'UNITED STATES');
    insert Account_a;
    
    AccountTeamMember ATM = New AccountTeamMember(AccountId = Account_a.id,UserId = UserInfo.getUserId(), TeamMemberRole = 'Account Executive');
    insert ATM;
    
    TerritoryPlanNACtrl TerritoryPlanNACtrl_controllervar = New TerritoryPlanNACtrl();
    TerritoryPlanNACtrl_controllervar.ValidateUser();
    test.stopTest();
  }
  
   static testMethod void testcreateaccountteammember_negative(){     
    test.startTest();
    // Set up the Account record.
    Account Account_a = new Account(Name='Test Account',Account_Country__c = 'UNITED STATES');
    insert Account_a;
    
    AccountTeamMember ATM = New AccountTeamMember(AccountId = Account_a.id,UserId = UserInfo.getUserId());
    
    insert ATM;
    
    TerritoryPlanNACtrl TerritoryPlanNACtrl_controllervar = New TerritoryPlanNACtrl();
    TerritoryPlanNACtrl_controllervar.ValidateUser();
    test.stopTest();
  }
  
   static testMethod void testasnoNAregion_negative(){     
    test.startTest();
    // Set up the Account record.
    Account Account_a = new Account(Name='Test Account',Account_Country__c = 'Malaysia');
    insert Account_a;
    
    AccountTeamMember ATM = New AccountTeamMember(AccountId = Account_a.id,UserId = UserInfo.getUserId(),TeamMemberRole = 'Account Executive');
    
    insert ATM;
    
    TerritoryPlanNACtrl TerritoryPlanNACtrl_controllervar = New TerritoryPlanNACtrl();
    TerritoryPlanNACtrl_controllervar.ValidateUser();
    test.stopTest();
  }
  
}
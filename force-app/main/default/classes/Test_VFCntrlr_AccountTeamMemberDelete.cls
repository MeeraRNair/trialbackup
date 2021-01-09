@isTest
private class Test_VFCntrlr_AccountTeamMemberDelete {

  private static testMethod void testMethodTest_VFCntrlr_AccountTeamMemberDelete() 
  {
      VFCntrlr_AccountTeamMemberDelete controller=new VFCntrlr_AccountTeamMemberDelete();
        List<AccountTeamMember> accntTeamList=new List<AccountTeamMember>();
        
        system.assertEquals(0,controller.getButtonClickCount());  
        system.assertEquals(0,controller.getTotalRecordsDeleted());         
        system.assertEquals('NOT STARTED', controller.getMessage());
        
        Profile profile = [select id from profile where Name = 'Standard User' limit 1];
        User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        insert testUser;
        
        Account testAccount=new Account(name='testAccountForTeamMemberDeletion',ownerId=testUser.id);
        insert testAccount;

        Map<String, String> sParams = new Map<String, String>();

        TestDataGenerator.setUserList(TestDataGenerator.getObject(new User(), 100));
        
        sParams.put('str_AccountId', testAccount.id);
        sParams.put('str_TeamMemberRole','ACCTADM' );
        accntTeamList = (List<AccountTeamMember>) TestDataGenerator.getObject(new AccountTeamMember(), 100, sParams, false);
        
        System.runAs(testUser){
            insert accntTeamList;
        }
        
        //asserts that all the Account team members were created.
        system.assertEquals(accntTeamList.size(),[select count() from AccountTeamMember where AccountId=:testAccount.id]);
        system.assertEquals('NOT STARTED', controller.getMessage());
        
        //force the query selection limit to 300
        controller.testInvocation=true;
        
        test.startTest();
        //calls the method to delete the Account team member.
        controller.deleteTeamMember();
                    
        test.stopTest(); 
        
        system.assertEquals(1,controller.getButtonClickCount());
        System.debug('#MN:END of testdeleteTeamMember()');

  }

}
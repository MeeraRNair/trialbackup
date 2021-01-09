@isTest
private class AccountBranchTest {

    //Test method for Account Branch creation and LOB record generation
    static testMethod void testAccBrLobRecGeneration() {
        //Variables       
        List<Account_Branch__c> listOfAccBrRecs = new List<Account_Branch__c>();
        Profile profile = [select id from profile where Name = 'Standard User' limit 1];
                                
        User testUser = new User(Username='testvaliduser' +'@dell.com',
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
        insert testUser;
        System.runAs(testUser){
        
            Account testEUAccount = new Account(Name='Test EU Account',Type = 'End User',
                                                Participating_in_LOB_Program__c = true,
                                                OwnerId = testUser.Id);
            insert testEUAccount;
            Account testEUAcc = new Account(Name='Test EU Account',Type = 'End User',
                                            Participating_in_LOB_Program__c = true,
                                            OwnerId = testUser.Id);
            insert testEUAcc;
            AccountBranchController controller = new AccountBranchController
                                                 (new ApexPages.StandardController(testEUAccount));
            Account_Branch__c accBrRec = new Account_Branch__c(Name = 'Test Account', 
                                                               Account__c = testEUAccount.Id);
            if(testEUAccount.OwnerId == Userinfo.getUserId() || testEUAcc.OwnerId == Userinfo.getUserId()){
                insert accBrRec;
            }
            
            PageReference  pr = new PageReference('/apex/AccountBranch?id='+testEUAccount.Id);
            Test.setCurrentPage(pr);
            
            for(Integer i=0; i<2; i++ ){
                Account_Branch__c accBrObj = new Account_Branch__c(Name = 'Test Account'+i, 
                                                                   Account__c = testEUAccount.Id);
                listOfAccBrRecs.add(accBrObj);
            }
            Account_Branch__c accBrObj2 = new Account_Branch__c(Name = 'Abc', 
                                                                Account__c = testEUAccount.Id);
            listOfAccBrRecs.add(accBrObj2);                                                       
            Account_Branch__c accBrObj3 = new Account_Branch__c(Name = 'Xyz', 
                                                                Account__c = testEUAcc.Id);
            listOfAccBrRecs.add(accBrObj3);
            if(testEUAccount.OwnerId == Userinfo.getUserId() || testEUAcc.OwnerId == Userinfo.getUserId()){                                                       
                insert listOfAccBrRecs;
            }
            controller.strAccBrnchNm = 'AccountBranchTestCR';
            controller.setStrStatus('Open');
            controller.getStrStatus();
            controller.getItems();
            controller.getLOBRegStatus();
            //controller.removeLOB();
            controller.getActiveLOBRegStatusValues();
            
            controller.listLOBRegStatus.clear();
            controller.getActiveLOBRegStatusValues();
            
            PageReference  pageRefExpected = new PageReference('/'+testEUAccount.Id);
            PageReference  pageRefActual = controller.createAccountBranch();
            String expected = pageRefExpected.getUrl();
            String actual = pageRefActual.getUrl();
            System.assertEquals(expected, actual);            
            controller.getItems();
        }
    }//End of testAccBrLobRecGeneration()
    
    
    //Test method for Account Branch creation and LOB record generation(showPage=false)
    static testMethod void testAccBrWithoutLOBParticipation() {
        //Variables
        Profile profile = [select id from profile where Name = 'Standard User' limit 1];                                
        User testUser = new User(Username='testvaliduser' +'@dell.com',
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
        insert testUser;
        System.runAs(testUser){
        
            Account testEUAccount = new Account(Name='Test EU Account',Type = 'End User',
                                                Participating_in_LOB_Program__c = false,
                                                OwnerId = testUser.Id);
            insert testEUAccount;
            AccountBranchController controller = new AccountBranchController
                                                 (new ApexPages.StandardController(testEUAccount));
            Account_Branch__c accBrRec = new Account_Branch__c(Name = 'Test Account', 
                                                               Account__c = testEUAccount.Id);
            if(testEUAccount.OwnerId == Userinfo.getUserId()){
                insert accBrRec;
            }
        }
    }//End of testAccBrWithoutLOBParticipation()
    
}//End of test class
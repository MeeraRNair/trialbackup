@isTest
//(SeeAllData=true)
private class BatchUpdAccountOwnerForPartnerECEMEATest {
    //Define variables
    static Profile testProfile;
    static User adminusr;
    static list<Account> listAcc;
    // static Account testAcc;
    // static Account updatedAcc;
    static UserRole testUserRole;
    static User testUser1;
    static User testUser2;
    @testSetup Static void setup(){
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF;
    }
    static testMethod void batchUpdAccountOwnerExecuteForPartnerECEMEATest() {        
        testDataCreation();
        System.assert(testUserRole != null);
     }
    static void testDataCreation(){
        adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true][0];
        testProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%System Administrator' LIMIT 1];
        //Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%R16.03 GBL Sales Rep' LIMIT 1];
        System.assert(testProfile != null);
        System.debug('testProfile details:'+testProfile);
        testUserRole = [select id, name from userrole where name like '%WW_Exec%' limit 1];
        System.assert(testUserRole != null);
        System.debug('testUserRole details:'+testUserRole);
        testUser1 = new User(FirstName='User 1', LastName='BUAccOwner', Title='SR',UserName='TestU1'+ System.currentTimeMillis() +'@test.com',Email='TestU1@dell.com',
                             Alias='test01',CommunityNickName='Test01',ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                             EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest111', UserRoleId = testUserRole.Id);
        insert testUser1;
        testUser2 = new User(FirstName='User 2', LastName='BUAccOwner', Title='SR',UserName='TestU2'+ System.currentTimeMillis() +'@test.com',Email='TestU2@dell.com',
                             Alias='test01',CommunityNickName='Test02',ProfileId = testProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                             EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',Badge_Number__c='testtest555', UserRoleId = testUserRole.Id);
        insert testUser2;
        System.debug('testUser1 details:'+testUser1);
        System.runAs(testUser1) {
            //Account testAcc = new Account(Name = 'Test Account',Priority__c =10, Owner_Update__c = testUser1.Id, Account_Country__c = 'INDIA');
            //insert testAcc;
     /*  Id accRTId= StaticFactory.getRecordTypeIdByName('Account', 'Partner Account');   
        
        testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.RecordtypeId = accRTId;
        testAcc.Type = 'Partner';
        testAcc.Priority__c = 20;
        //testAcc.Owner_Update__c = testUser1.Id;
        testAcc.Owner_Update__c = testUser2.Id;
        //testAcc.Owner_Update__c = '005Z0000001x7EXIAY';
        testAcc.Account_Country__c = 'QATAR';
        insert testAcc; */
            listAcc = [select id from Account limit 1];
            for(Account testAcc: listAcc){
                testAcc.Type = 'Partner';
                testAcc.Priority__c = 20;
                //testAcc.Owner_Update__c = testUser1.Id;
                testAcc.Owner_Update__c = testUser2.Id;
                //testAcc.Owner_Update__c = '005Z0000001x7EXIAY';
                testAcc.Account_Country__c = 'QATAR';
            }
            update listAcc;
       /* System.debug('Test account details:'+testAcc);
        System.debug('Test account details:'+[Select Id,New_Owner__c, ownerId, Owner_Update__c From Account Where Id = :testAcc.Id ]);  
        Boolean testenabledNotification = StringUtils.equalsIgnoreCase(StringUtils.defaultString(Label.GAM_Enable_Exception_emails),'TRUE');
        testenabledNotification = true;
        System.debug('########## batchUpdAccountOwnerExecuteForPartnerTest START ########## enabledNotification value is:'+testenabledNotification);  
        AccountOwnerTransitionUtils.enabledNotification = testenabledNotification;    
        System.debug('########## batchUpdAccountOwnerExecuteForPartnerTest START ##########');  
        Test.startTest();
        //BatchUpdAccountOwnerForPartnerExecuteEC.executeBatch(batch);
        String sch = '0 0 0 * * ?';
        System.schedule('Test', sch, new BatchUpdAccountOwnerForPartnerExecuteEC());    
        Test.stopTest();
        System.debug('########## batchUpdAccountOwnerExecuteForPartnerTest END ##########');*/
          Test.startTest();
        //BatchUpdAccountOwnerForPartnerExecuteEC.executeBatch(batch);
        String strsch = '0 0 0 * * ?';
        System.schedule('Test', strsch, new BatchUpdAccountOwnerForPartnerExecuteEC());    
        database.executeBatch( new BatchUpdAccountOwnerForPartnerECEMEA());
        Test.stopTest();
    }
    }
}
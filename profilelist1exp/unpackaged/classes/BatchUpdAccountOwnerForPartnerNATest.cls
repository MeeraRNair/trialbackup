@isTest(SeeAllData=true)
private class BatchUpdAccountOwnerForPartnerNATest {

    //Define variables
    static Profile testProfile;
    static User adminusr;
    static Account testAcc;
    static Account updatedAcc;
    static UserRole testUserRole;
    static User testUser1;
    static User testUser2;
    
    static testMethod void batchUpdAccountOwnerExecuteForPartnerNATest() {
        
        TestDataCreation();
        
     }
    
    static void TestDataCreation(){
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
        Id accRTId= StaticFactory.getRecordTypeIdByName('Account', 'Partner Account');   
        
        testAcc = new Account();
        testAcc.Name = 'Test Account';
        testAcc.RecordtypeId = accRTId;
        testAcc.Type = 'Partner';
        testAcc.Priority__c = 20;
        //testAcc.Owner_Update__c = testUser1.Id;
        testAcc.Owner_Update__c = testUser2.Id;
        //testAcc.Owner_Update__c = '005Z0000001x7EXIAY';
        testAcc.Account_Country__c = 'CANADA';
        insert testAcc;
        
       /* System.debug('Test account details:'+testAcc);
        System.debug('Test account details:'+[Select Id,New_Owner__c, ownerId, Owner_Update__c From Account Where Id = :testAcc.Id ]);  
        
        Boolean testenabledNotification = StringUtils.equalsIgnoreCase(StringUtils.defaultString(Label.BatchUpdAccount_Enable_Exception),'TRUE');
        
        testenabledNotification = true;
            
        System.debug('########## batchUpdAccountOwnerExecuteForPartnerTest START ########## enabledNotification value is:'+testenabledNotification);  
         
        AccountOwnerTransitionUtils.enabledNotification = testenabledNotification;
        
        System.debug('########## batchUpdAccountOwnerExecuteForPartnerTest START ##########');  
         
           
        Test.startTest();
        //BatchUpdAccountOwnerForPartnerExecuteNA.executeBatch(batch);
        String sch = '0 0 0 * * ?';
        System.schedule('Test', sch, new BatchUpdAccountOwnerForPartnerExecuteNA());
            
        Test.stopTest();
         
        System.debug('########## batchUpdAccountOwnerExecuteForPartnerTest END ##########');*/
        
        Test.startTest();
        //BatchUpdAccountOwnerForPartnerExecuteNA.executeBatch(batch);
        String sch = '0 0 0 * * ?';
        System.schedule('Test', sch, new BatchUpdAccountOwnerForPartnerExecuteNA());
         database.executeBatch( new BatchUpdAccountOwnerForPartnerNA());   
        Test.stopTest();
    }

}
}
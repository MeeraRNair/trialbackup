/**
 * Test class for beforeUpdateContactTrigger
  Bikram   14-01-2013  Removed field Is Country Enabled For Incentives R14.2 SSO
 */
@isTest
private class beforeUpdateContactTriggerTest {
    public static Account testAcc;
    public static Country__c testCountry;
    public static Contact testContact;
    public static User testUser;
    
    static testMethod void updateContact_BOOMIflagTest() {
        // Create Test Data
        createTestData();
        Test.startTest();
        //enable contact for incentives
        testContact.Is_Enabled_for_Incentives__c = true;
        update testContact;
        
        //retrieve result and asserts
        Contact res = [SELECT Is_Vendor_Update_Required__c,Is_Vendor_Updated__c,Operation_for_Boomi__c,Last_Operation_Performed__c,Is_Incentives_Updated__c
                       FROM Contact WHERE id=:testContact.id];
                       
        System.assertEquals(res.Is_Vendor_Update_Required__c, true);
        System.assertEquals(res.Is_Vendor_Updated__c, false);
        System.assertEquals(res.Operation_for_Boomi__c, 'NEW_USER');
        System.assertEquals(res.Last_Operation_Performed__c, 'SFDC Updated');
        System.assertEquals(res.Is_Incentives_Updated__c, true);
                
        //update details on a synched contact
        testCountry.Inc_Vendor_Name__c = 'Dell Achievers';
        update testCountry;
        testContact.Is_Vendor_Updated__c = true;
        testContact.Vendor_Update_Datetime__c = System.now();
        update testContact;
        
        //Asserts that no need to synch with vendor system
        Contact res1 = [SELECT Is_Vendor_Update_Required__c,Is_Vendor_Updated__c,Operation_for_Boomi__c,Last_Operation_Performed__c,Is_Incentives_Updated__c
                       FROM Contact WHERE id=:testContact.id];
                       
        System.assertEquals(res1.Is_Vendor_Update_Required__c, false);
        System.assertEquals(res1.Is_Vendor_Updated__c, true);
        System.assertEquals(res1.Operation_for_Boomi__c, null);
        Test.stopTest();
         
    }
    
    static testMethod void updateContact_BOOMIflagTest_Update_User() {
        // Create Test Data
        createTestData();
        System.debug('##1');
        Test.startTest();
        //enable contact for incentives
        testContact.Is_Enabled_for_Incentives__c = true;
        testContact.Is_Vendor_Updated__c = true;       
        testContact.Vendor_Update_Datetime__c = System.now();
        update testContact;
        System.debug('##2');
        //check for "UPDATE_USER"
        testContact.LastName = 'Contact1';
        update testContact;
        System.debug('##3');
        //retrieve result and asserts
        Contact res3 = [SELECT Is_Vendor_Update_Required__c,Is_Vendor_Updated__c,Operation_for_Boomi__c,Last_Operation_Performed__c,Is_Incentives_Updated__c
                       FROM Contact WHERE id=:testContact.id];
                       
        System.assertEquals(res3.Is_Vendor_Update_Required__c, true);
        System.assertEquals(res3.Is_Vendor_Updated__c, false);
        System.assertEquals(res3.Operation_for_Boomi__c, 'UPDATE_USER');
        System.assertEquals(res3.Last_Operation_Performed__c, 'SFDC Updated');        
        Test.stopTest();
        
    }
    
    static testMethod void updateContact_BOOMIflagTest_failure() {
        //Create Test Data
        //Create Country
        //Insert Country
        testCountry  = new Country__c(Code__c = 'XY', Region__c = 'NA',Inc_Vendor_Name__c='Partner Direct Rewards Center',Inc_Vendor_End_Point__c='Test End point');
        insert testCountry;
        
        //Create Account
        testAcc = new Account(
                      Name = 'Test Account',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active', 
                      Partner_Relationship__c = 'Registered',
                      Account_Country_Code__c = 'XY',
                      Is_Enabled_for_Incentives__c = true,                     
                      type='Partner'
                      );
        
        insert testAcc; 
        testAcc.IsPartner = true;
        update testAcc;
        
        //Create Contact
        string email = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com';
        testContact = new Contact(AccountId = testAcc.id, Email = email, Lastname = 'Contact', Is_Enabled_for_Incentives__c = true, Is_Vendor_Updated__c = true, Vendor_Update_Datetime__c = System.now());
        insert testContact;        
        
        //Select Profile
        Profile prof = [SELECT Id FROM Profile WHERE Name LIKE '%PRM Portal%' LIMIT 1];
        //Create test User        
        testUser = new User(ContactId = testContact.id, IsActive = true, Email = email, LanguageLocaleKey = 'en_US', 
            LastName = 'UT', Alias = 'UT', CommunityNickname = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_'), 
            TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', 
            ProfileId = prof.id, UserName = email, Badge_Number__c = String.valueOf(Datetime.now()));
        insert testUser;
        System.debug('##1');        
        
        /*
        //enable contact for incentives
        testContact.Is_Enabled_for_Incentives__c = true;
        testContact.Is_Vendor_Updated__c = true;       
        testContact.Vendor_Update_Datetime__c = System.now();
        update testContact;
        System.debug('##2');  
        */
        
        Test.startTest();
            
        //Check for BOOMI failure and revert back the changes
        testContact.Is_Enabled_for_Incentives__c = false;
        update testContact;
        System.debug('##4');
        
        //Create a BOOMI integration user
        //Profile profile = [select id from profile where name like '%Sales Rep%' order by name limit 1];
        UserRole testUserRole = [select id, name from userrole where name like '%WW_Exec%' limit 1];
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true][0];
        //Create test User
        User testUser1;
        System.runAs(adminusr) {
            testUser1 = new User(Username='boomi_integuser' +'@dell.comtest',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    ProfileId = '00eA0000000hNqF', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    UserRoleId = testUserRole.Id);
            insert testUser1;
        }
        
        testAcc.OwnerId = testUser1.id;
        update testAcc;
		
        System.debug('##5');
        System.runAs(testUser1){
            
            testContact.last_Operation_Performed__c = 'Vendor Sync failed';
			update testContact;
            Test.stopTest();
            Contact res4 = [SELECT Is_Vendor_Update_Required__c,Is_Enabled_for_Incentives__c,Is_Vendor_Updated__c,Operation_for_Boomi__c,Last_Operation_Performed__c,Is_Incentives_Updated__c
                       FROM Contact WHERE id=:testContact.id];
            
            System.assertEquals(res4.Is_Enabled_for_Incentives__c, true);
        }
    }   
     
    public static void createTestData(){
        //Create Country
        //Insert Country
        testCountry  = new Country__c(Code__c = 'XY', Region__c = 'NA',Inc_Vendor_Name__c='Partner Direct Rewards Center',Inc_Vendor_End_Point__c='Test End point');
        insert testCountry;
        
        //Create Account
        testAcc = new Account(
                      Name = 'Test Account',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active', 
                      Partner_Relationship__c = 'Registered',
                      Account_Country_Code__c = 'XY',
                      Is_Enabled_for_Incentives__c = true,                     
                      type='Partner'
                      );
        
        insert testAcc; 
        testAcc.IsPartner = true;
        update testAcc;
        //Create Contact
        string email = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com';
        testContact = new Contact(AccountId = testAcc.id, Email = email, Lastname = 'Contact');
        insert testContact;        
        
        //Select Profile
        Profile prof = [SELECT Id FROM Profile WHERE Name LIKE '%PRM Portal%' LIMIT 1];
        //Create test User        
        testUser = new User(ContactId = testContact.id, IsActive = true, Email = email, LanguageLocaleKey = 'en_US', 
            LastName = 'UT', Alias = 'UT', CommunityNickname = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_'), 
            TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', 
            ProfileId = prof.id, UserName = email, Badge_Number__c = String.valueOf(Datetime.now()));
        insert testUser;
    }
}
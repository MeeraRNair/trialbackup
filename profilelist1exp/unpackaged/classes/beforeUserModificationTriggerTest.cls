/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 * Bikram  14-Jan-2013      R14.2 SSO - Removed field Is Country Enabled for Incentives 
 * MenMee  13-Jan-2015      R16.12 - Improve UserValidator code coverage
 */
@isTest(seealldata=true)
private class beforeUserModificationTriggerTest {

    // Test on populating partner domain text field
    // When insert/udate a user that's not associated to a contact
    static testMethod void InsertUpdateUser_NotAssociated_Contact() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User user = new User(IsActive = true, Email = 'unit_test@dell.com.fdev', LanguageLocaleKey = 'en_US', Enable_Partner_Admin__c = false,
            LastName = 'UT', Alias = 'UT', CommunityNickname = 'UTUser', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', 
            ProfileId = p.Id, UserName = 'unit_test@dell.com.fdev', Badge_Number__c = 'abcxyz123',
            System_Admin_or_Delegated_User_Admin__c = true);
        insert user;
        
        User inserted = [SELECT AccountId, ContactId, Partner_Domain_Name__c FROM User WHERE Id = :user.Id];
        system.assertEquals(null, inserted.AccountId);
        system.assertEquals(null, inserted.ContactId);
        system.assertEquals(null, inserted.Partner_Domain_Name__c);
        
        inserted.LastName = 'UpdatedUT';
        update inserted;
        inserted = [SELECT AccountId, ContactId, Partner_Domain_Name__c FROM User WHERE Id = :user.Id];
        system.assertEquals(null, inserted.AccountId);
        system.assertEquals(null, inserted.ContactId);
        system.assertEquals(null, inserted.Partner_Domain_Name__c);
        
        System.runAs(inserted){
            inserted.Email = 'unit_test@dell.com';
            update inserted;
            inserted = [SELECT AccountId, ContactId, Partner_Domain_Name__c FROM User WHERE Id = :user.Id];
            system.assertEquals(null, inserted.AccountId);
            system.assertEquals(null, inserted.ContactId);
            system.assertEquals(null, inserted.Partner_Domain_Name__c);
        }
    }
    
    // Test on populating partner domain text field
    // When insert/update a user which it's contact is associated with a non partner account
    static testMethod void InsertUpdateUser_Contact_Associated_NotPartnerAccount(){
                
            Account acc = new Account(Name = 'CreatePartnerAccount', Account_Country_Code__c = 'FR');
            insert acc;

            Contact con = new Contact(AccountId = acc.Id, Email = 'unit_test@dellteam.com', Lastname = 'UT');
            insert con;

            Profile p = [SELECT Id FROM Profile WHERE UserType = 'CSPLitePortal' LIMIT 1];
        
            //Test.startTest();
            User user = new User(ContactId = con.Id, IsActive = true, Email = 'unit_test@dellteam.com', LanguageLocaleKey = 'en_US', Enable_Partner_Admin__c = false,
            LastName = 'UT', Alias = 'UT', CommunityNickname = 'UTUser', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', 
            ProfileId = p.Id, UserName = 'unit_test@dellteam.com.fdev', Badge_Number__c = 'abcxyz123', 
            System_Admin_or_Delegated_User_Admin__c = true);
            insert user;        
           
            User inserted = [SELECT AccountId, ContactId, Partner_Domain_Name__c FROM User WHERE Id = :user.Id];
            system.assertEquals(acc.Id, inserted.AccountId);
            system.assertEquals(con.Id, inserted.ContactId);
            system.assertEquals(null, inserted.Partner_Domain_Name__c);
            
            System.runAs(inserted ){ 
                    
            inserted.LastName = 'UpdatedUT';
            update inserted;
            inserted = [SELECT AccountId, ContactId, Partner_Domain_Name__c FROM User WHERE Id = :user.Id];
            system.assertEquals(acc.Id, inserted.AccountId);
            system.assertEquals(con.Id, inserted.ContactId);
            system.assertEquals(null, inserted.Partner_Domain_Name__c);
            
            inserted.Email = 'unit_test@dell.com';
            update inserted;
            inserted = [SELECT AccountId, ContactId, Partner_Domain_Name__c FROM User WHERE Id = :user.Id];
            system.assertEquals(acc.Id, inserted.AccountId);
            system.assertEquals(con.Id, inserted.ContactId);
            system.assertEquals(null, inserted.Partner_Domain_Name__c);
            
        }
        
        //Test.stopTest();
    }
    
    // Test on populating partner domain text field
    // When insert/update a user which it's contact is associated with a partner account
    static testMethod void InsertUpdateUser_Contact_Associated_PartnerAccount(){
        Account acc = new Account(Name = 'CreatePartnerAccount', Account_Country_Code__c = 'FR');
        insert acc;
        acc.IsPartner = true;
        update acc;

        Contact con = new Contact(AccountId = acc.Id, Email = 'unit_test@dellteam.com', Lastname = 'UT');
        insert con;

        Profile p = [SELECT Id FROM Profile WHERE UserType = 'CSPLitePortal' LIMIT 1];
                
        User user = new User(ContactId = con.Id, IsActive = true, Email = 'unit_test@dellteam.com', LanguageLocaleKey = 'en_US', Enable_Partner_Admin__c = false,
            LastName = 'UT', Alias = 'UT', CommunityNickname = 'UTUser', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', 
            ProfileId = p.Id, UserName = 'unit_test@dell.com.fdev', Badge_Number__c = 'abcxyz123',
            System_Admin_or_Delegated_User_Admin__c = true);
        insert user;
        
        User inserted = [SELECT AccountId, ContactId, Partner_Domain_Name__c FROM User WHERE Id = :user.Id];
        system.assertEquals(acc.Id, inserted.AccountId);
        system.assertEquals(con.Id, inserted.ContactId);
        system.assertEquals('dellteam.com', inserted.Partner_Domain_Name__c);
        
        System.runAs(inserted){
            inserted.LastName = 'UpdatedUT';
            update inserted;
            inserted = [SELECT AccountId, ContactId, Partner_Domain_Name__c FROM User WHERE Id = :user.Id];
            system.assertEquals(acc.Id, inserted.AccountId);
            system.assertEquals(con.Id, inserted.ContactId);
            system.assertEquals('dellteam.com', inserted.Partner_Domain_Name__c);
            
            inserted.Email = 'unit_test@dell.com';
            update inserted;
            inserted = [SELECT AccountId, ContactId, Partner_Domain_Name__c FROM User WHERE Id = :user.Id];
            system.assertEquals(acc.Id, inserted.AccountId);
            system.assertEquals(con.Id, inserted.ContactId);
            system.assertEquals('dell.com', inserted.Partner_Domain_Name__c);
        }
    }
    
    //Code Start: R14.2 CMAP - User Language Translation [Bianca Huit 08-Dec-2012]
    static testMethod void hasOnePartner() {
        CMAP_Helper.skipinsert = true;
        CMAP_TestDataGenerator testData = new CMAP_TestDataGenerator();
        testData.getAccount(true);
        testData.getContact(true);
        test.startTest();
        testData.getPartnerUser(true);
        testData.getCampaign(true);
        testData.getLead(true);
        
        
        System.runAs(testData.PartnerUser){
          testData.PartnerUser.LanguageLocaleKey='en_US';
           update testData.PartnerUser;
        }
        test.stopTest();
        system.assertEquals(testData.PartnerUser.LanguageLocaleKey, 'en_US' );                                    
    }
    //Code End: R14.2 CMAP - User Language Translation [Bianca Huit 08-Dec-2012]
    
    public static Account testAcc;
    public static Country__c testCountry;
    public static Contact testContact;
    public static User testUser;
    //Test cases for User BOOMI Synch
    static testMethod void BOOMISynchTest(){
        createTestData();
        //enable contact for incentives
        Test.startTest();
        GlobalVariables.BYPASS_PARTNER_PROFILE_INTEGRATION = true;
        testContact.Is_Enabled_for_Incentives__c = true;
        testContact.Vendor_Update_Datetime__c = System.now();
        update testContact;
        
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true][0];
        
        System.runAs(adminusr) {
        
            //update non vendor synch fields and asserts that it is not marked for BOOMI operation
            testUser.LastName = 'New Name';
            update testUser;
        
        
        
            User usr = [SELECT id,Is_Vendor_Update_Required__c,Last_Operation_Performed__c FROM USER WHERE id=:testUser.id];
            System.assertEquals(usr.Is_Vendor_Update_Required__c, false);
            System.assertEquals(usr.Last_Operation_Performed__c, null);
            
            //update LanguageLocaleKey and verify this is ready for BOOMI operation
            testUser.LanguageLocaleKey = 'el';
            update testUser;
            
        }
        
        User usr1 = [SELECT id,Is_Vendor_Update_Required__c,Last_Operation_Performed__c,Is_Vendor_Updated__c,Operation_for_Boomi__c FROM USER WHERE id=:testUser.id];
        Test.stopTest();
        System.assertEquals(usr1.Is_Vendor_Update_Required__c, true);
        System.assertEquals(usr1.Last_Operation_Performed__c, 'SFDC Updated');
        System.assertEquals(usr1.Is_Vendor_Updated__c, false);
        System.assertEquals(usr1.Operation_for_Boomi__c, 'UPDATE_USER');
        
    } 
    
    public static void createTestData(){
        //Create Country
        //Insert Country
        testCountry  = new Country__c(Code__c = '@@', Region__c = 'APJ',Inc_Vendor_Name__c='Partner Advantage',Inc_Vendor_End_Point__c='{TBD}' );
        insert testCountry ; 
        
        //Create Account
        testAcc = new Account(
                      Name = 'Test Account',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active', 
                      Partner_Relationship__c = 'Registered',
                      Account_Country_Code__c = '@@',
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
    static testMethod void CMAPLMChangesTestnonOEM() {
        CMAP_Helper.skipinsert = true;
        Country__c testCountry1 = new Country__c (name = 'TESCOUNTRY', Code__c = 'T6', Region__c = 'APJ',
                                                Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Not Applicable/On Hold',
                                                Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',Partner_Relationship__c = 'Premier,Registered',Partner_Relationship_for_OEM__c = 'Premier,Registered');
        
  
        
        
        insert testCountry1;
        Sales_Channel_Group__c testSalesChanGrp = new Sales_Channel_Group__c(Name = 'Test  Sales channel', Regional_Parent_Name__c = 'APJ');
        insert testSalesChanGrp;              
        Account testAcc1 = new Account(name = 'testAccount'+System.currentTimeMillis(), Is_Rebate_Partner__c = true,Sales_Channel__c=testSalesChanGrp.Id,
                                    Account_Country_Code__c = testCountry1.Code__c, Account_Country__c = testCountry1.Name,Partner_Relationship__c='Registered');
        insert testAcc1;
        testAcc1.RecordTypeId = System.Label.RecType_Partner_Account;
        testAcc1.IsPartner = true;
        testAcc1.Type = 'Partner';
        update testAcc1;
        Test.startTest();
        Contact testContact1 = new Contact(Status__c='Active', AccountId=testAcc1.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact',  Partner_My_Account_GUID__c='validuser');
        insert testContact1; 
    
    //Profile profile = [select id from profile where UserType = 'PowerPartner' limit 1]; // Fenny commented
    // Fenny added -- To prevent this user following group '#SFDC – Frequently Asked Questions (FAQ)' which will cause INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY at EntitySubscriptionUtils.followGroup
    Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
        try{
            User testUser1 = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    ContactId = testContact1.Id,
                                    isActive=true,
                                    Enable_Partner_Lead_Management__c = true,
                                    Enable_Partner_Deal_Registration__c = true);
        insert testUser1;
        Test.stopTest();
                             
        }catch(Exception e){
            System.assert(e.getMessage().contains('You cannot enable lead management since this record does not meet the conditions (Country: Lead management Enabled ='+testCountry1.Lead_Management_Enabled__c+' and Partner Relationship = '+testCountry1.Partner_Relationship__c+') to enable Lead Management.'));
        }
        
    }
    
    //R16.12
    //static testMethod void CMAPLMChangesTestOEM() {
    static testMethod void CMAPLMChangesTestOEMError() {
        CMAP_Helper.skipinsert = true;
        Country__c testCountry1 = new Country__c (name = 'TESCOUNTRY', Code__c = 'T6', Region__c = 'APJ',
                                                Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Not Applicable/On Hold',
                                                Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',Partner_Relationship__c = 'Premier,Registered',Partner_Relationship_for_OEM__c = 'Premier');  //R16.12,Registered');
        
  
        
        
        insert testCountry1;
        Sales_Channel_Group__c testSalesChanGrp = new Sales_Channel_Group__c(Name = 'Test  OEM Sales channel', Regional_Parent_Name__c = 'APJ');
        insert testSalesChanGrp;              
        Account testAcc1 = new Account(name = 'testAccount'+System.currentTimeMillis(), Is_Rebate_Partner__c = true,Sales_Channel__c=testSalesChanGrp.Id,
                                    Account_Country_Code__c = testCountry1.Code__c, Account_Country__c = testCountry1.Name,Partner_Relationship__c='Registered');
        insert testAcc1;
        testAcc1.RecordTypeId = System.Label.RecType_Partner_Account;
        testAcc1.IsPartner = true;
        testAcc1.Type = 'Partner';
        update testAcc1;
        //R16.12 Test.startTest();
        Contact testContact1 = new Contact(Status__c='Active', AccountId=testAcc1.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact',  Partner_My_Account_GUID__c='validuser');
        insert testContact1; 
    
    //Profile profile = [select id from profile where UserType = 'PowerPartner' limit 1]; // Fenny commented
    // Fenny added -- To prevent this user following group '#SFDC – Frequently Asked Questions (FAQ)' which will cause INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY at EntitySubscriptionUtils.followGroup
    Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
        try{
            User testUser1 = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    ContactId = testContact1.Id,
                                    isActive=true,
                                    Enable_Partner_Lead_Management__c = false,
                                    Enable_Partner_Deal_Registration__c = true);
        insert testUser1;
        
        //R16.12
        //Test.stopTest();
        System.runAs(testUser1) {
            testUser1.Enable_Partner_Lead_Management__c  = true;
            Test.startTest();
            update testUser1;
            Test.stopTest();
        }
        //R16.12-end

      
        }catch(Exception e){
            System.assert(e.getMessage().contains('You cannot enable lead management since this record does not meet the conditions (Country: Lead management Enabled for OEM ='+testCountry1.Lead_Management_Enabled_for_OEM__c+' and Partner Relationship for OEM = '+testCountry1.Partner_Relationship_for_OEM__c+') to enable Lead Management.'));
        }
        
    }
}
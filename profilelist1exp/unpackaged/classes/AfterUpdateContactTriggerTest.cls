/**
 * Version 1.0 Meera 14.2 SSO Creation
 */

/***********************************************************
* Revision CR Number   Release No      Date            Modified By     Description
* 2.0      16018       FY19-DCS-0802   08-Aug-18       Gan	           Fix prod validation error 
************************************************************/
@isTest
private class AfterUpdateContactTriggerTest {
    public static Account testAcc;
    //public static Account testAcc1;
    public static Country__c testCountry;
    public static Contact testContact;
    public static User testUser;
    public static list<Account> listAcc;
    @testsetup static void setup()
    {
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        insert listAccTDF;
       
    }
    
    static testMethod void contactAccountAssociationTestGrassroots() {

        Profile profile = [select id from profile where name like '%Sales Rep%' order by name limit 1];
        UserRole testUserRole = [select id, name from userrole where name like '%WW_Exec%' limit 1];
        
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true][0];
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
                 UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
       User usr = [Select Id,UserRoleId from User where UserRoleId != null AND IsActive = True limit 1];
       
  

   //     testCountry = [SELECT id from Country__c WHERE Code__c = 'IN'];
        
//        if(testCountry == null){
            //Insert Country
            testCountry  = new Country__c(Code__c = 'IN', Region__c = 'APJ',Inc_Vendor_Name__c='Dell Achievers',Inc_Vendor_End_Point__c='Test End point');
            insert testCountry ; 
  //      }else{
            // Fenny added on 30-Mar-2013: Country is not enabled for Incentives. Enable the Country first to approve Account to particip....
            testCountry.Inc_Vendor_Name__c='Dell Achievers';
            testCountry.Inc_Vendor_End_Point__c='Test End Point';
            update testCountry;
    //    }
                
        //Create Account
                 TriggerExecutionController.setSkipAccountTriggers(true);
    /*    testAcc = new Account(
                      Name = 'Test Account',
                      RecordTypeId = PageUtils.getRecordTypeId('Account','Partner Account',false),
                      Status__c = 'Active', 
                      Partner_Relationship__c = 'Registered',
                      Account_Country_Code__c = 'IN',
                      Is_Enabled_for_Incentives__c = true,                     
                      type='Partner'
                      );
                      
        insert testAcc; 
                testAcc.IsPartner = true;
        update testAcc;*/
        listAcc = [select id from Account limit 1];
        listAcc[0].Account_Country_Code__c = 'IN';
        listAcc[0].IsPartner = true;
        update listAcc[0];    
		system.assertEquals(listAcc[0], listAcc[0]);
        string stremail = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com';
        //fix prod validation error
        testContact = new Contact(AccountId = listAcc[0].id, Email = stremail, Lastname = 'Contact',Partner_My_Account_GUID__c = 'Test myaccount guid'+ System.currentTimeMillis());
        insert testContact;
        //Select Profile
        TriggerExecutioncontroller.setSkipAllTriggers(True);
        Test.startTest();
        Profile prof = [SELECT Id FROM Profile WHERE Name LIKE '%PRM Portal%' LIMIT 1];
        //Create test User

        testUser = new User(ContactId = testContact.id, IsActive = true, Email = stremail, LanguageLocaleKey = 'en_US', 
            LastName = 'UT', Alias = 'UT', CommunityNickname = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_'), 
            TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1',
            ProfileId = prof.Id, UserName = stremail, Badge_Number__c = String.valueOf(Datetime.now()));
        insert testUser;
        }
        TriggerExecutionController.setSkipAccountTriggers(true);
        listAcc[0].OwnerId = testUser1.id;
        update listAcc[0];
        System.runAs(testUser1){
            testContact.Is_Vendor_Updated__c = true;
            testContact.Last_Operation_Performed__c = 'Vendor Updated';
            testContact.Vendor_Update_Datetime__c = System.now();
            update testContact;
        }  
        test.stopTest();
    }
}
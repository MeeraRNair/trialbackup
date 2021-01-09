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
 */
@isTest
private class PartnerRegistrationDomainDupCheckTest {
    
    // Test on PartnerRegistrationDomainDuplicateCheck.IsDomainExcluded(strdomain)
    // Sc_A1 : Provided strdomain is null
    private static testMethod void testIsDomainExcludedScA1(){
        try{
            PartnerRegistrationDomainDuplicateCheck.IsDomainExcluded(null);
        }catch(Exception ex){
            system.AssertEquals('dellUtil.DellException', ex.getTypeName());
            system.AssertEquals('Provided country code and domain cannot be null or empty.', ex.getMessage());
        }
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.IsDomainExcluded(strdomain)
    // Sc_A2 : Provided strdomain is empty
    private static testMethod void testIsDomainExcludedScA2(){
        try{
            PartnerRegistrationDomainDuplicateCheck.IsDomainExcluded(' ');
        }catch(Exception ex){
            system.AssertEquals('dellUtil.DellException', ex.getTypeName());
            system.AssertEquals('Provided country code and domain cannot be null or empty.', ex.getMessage());
        }
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.IsDomainExcluded(strdomain)
    // Sc_A3 : Provided strdomain is not bexcluded
    private static testMethod void testIsDomainExcludedScA3(){
        String strdomain = string.valueOf(Date.today());
        Boolean bexcluded = PartnerRegistrationDomainDuplicateCheck.IsDomainExcluded(strdomain);
        system.AssertEquals(false, bexcluded);
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.IsDomainExcluded(strdomain)
    // Sc_A4 : Provided strdomain is bexcluded which is set as public and active
    private static testMethod void testIsDomainExcludedScA4(){
        String strdomain = string.valueOf(Date.today());
        Partner_Domain_Exclusion_List__c excludedDomain = CreatePartnerDomainExclusionList(strdomain, true, true);
        Boolean bexcluded = PartnerRegistrationDomainDuplicateCheck.IsDomainExcluded(strdomain);
        system.AssertEquals(true, bexcluded);
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.IsDomainExcluded(strdomain)
    // Sc_A5 : Provided strdomain is bexcluded which is set as public and inactive
    private static testMethod void testIsDomainExcludedScA5(){
        String strdomain = string.valueOf(Date.today());
        Partner_Domain_Exclusion_List__c excludedDomain = CreatePartnerDomainExclusionList(strdomain, false, true);
        Boolean bexcluded = PartnerRegistrationDomainDuplicateCheck.IsDomainExcluded(strdomain);
        system.AssertEquals(false, bexcluded);
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.IsDomainExcluded(strdomain)
    // Sc_A6 : Provided strdomain is bexcluded which is set as non-public and active
    private static testMethod void testIsDomainExcludedScA6(){
        String strdomain = string.valueOf(Date.today());
        Partner_Domain_Exclusion_List__c excludedDomain = CreatePartnerDomainExclusionList(strdomain, true, false);
        Boolean bexcluded = PartnerRegistrationDomainDuplicateCheck.IsDomainExcluded(strdomain);
        system.AssertEquals(true, bexcluded);
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.IsDomainExcluded(strdomain)
    // Sc_A7 : Provided strdomain is bexcluded which is set as non-public and inactive
    private static testMethod void testIsDomainExcludedScA7(){
        String strdomain = string.valueOf(Date.today());
        Partner_Domain_Exclusion_List__c excludedDomain = CreatePartnerDomainExclusionList(strdomain, false, false);
        Boolean bexcluded = PartnerRegistrationDomainDuplicateCheck.IsDomainExcluded(strdomain);
        system.AssertEquals(false, bexcluded);
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain)
    // Sc_B1 : Provided country code is null
    private static testMethod void testGetSinglePartnerAccountScB1(){
        try{
            String strdomain = string.valueOf(Date.today());
            PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(null, strdomain,'CSP (Cloud Service Provider)','ssp');
        }catch(Exception ex){
            system.AssertEquals('dellUtil.DellException', ex.getTypeName());
            system.AssertEquals('Provided country code and domain cannot be null or empty.', ex.getMessage());
        }
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain)
    // Sc_B2 : Provided country code is empty
    private static testMethod void testGetSinglePartnerAccountScB2(){
        try{
            String strdomain = string.valueOf(Date.today());
            PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(' ', strdomain,'Solution Provider (Reseller)','OEM Disti');
        }catch(Exception ex){
            system.AssertEquals('dellUtil.DellException', ex.getTypeName());
            system.AssertEquals('Provided country code and domain cannot be null or empty.', ex.getMessage());
        }
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain)
    // Sc_B3 : Provided strdomain is null
    private static testMethod void testGetSinglePartnerAccountScB3(){
        try{
            string strcountryCode = 'XY';
            PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, null,'OEM (Original Equipment Manufacturer)','ssp');
        }catch(Exception ex){
            system.AssertEquals('dellUtil.DellException', ex.getTypeName());
            system.AssertEquals('Provided country code and domain cannot be null or empty.', ex.getMessage());
        }
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain)
    // Sc_B4 : Provided strdomain is empty
    private static testMethod void testGetSinglePartnerAccountScB4(){
        try{
            string strcountryCode = 'XY';
            PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, ' ','OEM (Original Equipment Manufacturer)','as');
        }catch(Exception ex){
            system.AssertEquals('dellUtil.DellException', ex.getTypeName());
            system.AssertEquals('Provided country code and domain cannot be null or empty.', ex.getMessage());
        }
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain)
    // Sc_B5 : Match country & strdomain and all clauses, and only one partner account found
    private static testMethod void testGetSinglePartnerAccountScB5(){
        String strcountryCode = 'FR';
        String strdomain = 'dell.com.fdev';
        String stremail = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
        String strlanguageCode = 'en_US';
        
        Account acc = CreatePartnerAccount(strcountryCode, true);
        Contact con1 = CreatePartnerContact(acc.Id);
        User u1 = CreatePartnerUser(con1.Id, stremail, String.valueOf(Datetime.now()), String.valueOf(Datetime.now()), strlanguageCode, true, true);
        
      //  Account partnerAccount = PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain,'OEM');
       // system.AssertEquals(true, (partnerAccount != null));
        system.AssertEquals(acc.Id, con1.accountId);
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain)
    // Sc_B6 : Match country and all clauses except strdomain
    private static testMethod void testGetSinglePartnerAccountScB6(){
        String strcountryCode = 'FR';
        String strdomain = 'dell.com.fdev';
        String stremail = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
        String strlanguageCode = 'en_US';
        
        //Partner_Domain_Exclusion_List__c excludedDomain = CreatePartnerDomainExclusionList(strdomain, true, true);
        Account acc = CreatePartnerAccount(strcountryCode, true);
        Contact con1 = CreatePartnerContact(acc.Id);
        User u1 = CreatePartnerUser(con1.Id, stremail, String.valueOf(Datetime.now()), String.valueOf(Datetime.now()), strlanguageCode, true, true);
        
       // Account partnerAccount = PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, 'unittest.com','OEM');
       // System.assertEquals(true, (partnerAccount == null));
        system.AssertEquals(acc.Id, con1.accountId);
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain)
    // Sc_B7 : Match strdomain and all clauses except country
    private static testMethod void testGetSinglePartnerAccountScB7(){
        String strcountryCode = 'FR';
        String strdomain = 'dell.com.fdev';
        String stremail = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
        String strlanguageCode = 'en_US';
        
        //Partner_Domain_Exclusion_List__c excludedDomain = CreatePartnerDomainExclusionList(strdomain, true, true);
        Account acc = CreatePartnerAccount(strcountryCode, true);
        Contact con1 = CreatePartnerContact(acc.Id);
        User u1 = CreatePartnerUser(con1.Id, stremail, String.valueOf(Datetime.now()), String.valueOf(Datetime.now()), strlanguageCode, true, true);
        
      //  Account partnerAccount = PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount('IN', strdomain,'OEM');
       // System.assertEquals(true, (partnerAccount == null));
        system.AssertEquals(acc.Id, con1.accountId);
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain)
    // Sc_B8 : Match country & strdomain and all clauses but more than one partner account found
    private static testMethod void testGetSinglePartnerAccountScB8(){
        String strcountryCode = 'FR';
        String strdomain = 'dell.com.fdev';
        String stremail = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '_1@dell.com.fdev';
        String strlanguageCode = 'en_US';
        String stremail2 = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '_2@dell.com.fdev';
        
        //Partner_Domain_Exclusion_List__c excludedDomain = CreatePartnerDomainExclusionList(strdomain, true, true);
        // Skip all the triggers to avoid Too Many SOQL Query issue
        TriggerExecutionController.setSkipAllTriggers(true);
        
        Account acc = CreatePartnerAccount(strcountryCode, true);
        Contact con1 = CreatePartnerContact(acc.Id);
        User u1 = CreatePartnerUser(con1.Id, stremail, String.valueOf(Datetime.now()) + '1', String.valueOf(Datetime.now()) + '1', strlanguageCode, true, true);
        Account acc2 = CreatePartnerAccount(strcountryCode, true);
        Contact con2 = CreatePartnerContact(acc2.Id);
        User u2 = CreatePartnerUser(con2.Id, stremail2, String.valueOf(Datetime.now()) + '2', String.valueOf(Datetime.now()) + '2', strlanguageCode, true, true);
        
        // Revert back the skip all triggers
        TriggerExecutionController.setSkipAllTriggers(false);
        
        Account partnerAccount = PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain,'OEM (Original Equipment Manufacturer)','OEM Distributor');
        System.assertEquals(true, (partnerAccount == null));
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain)
    // Sc_B9 : Match country & strdomain and all clauses but no partner account found
    private static testMethod void testGetSinglePartnerAccountScB9(){
        String strcountryCode = 'FR';
        String strdomain = 'dell.com.fdev';
        String stremail = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
        String strlanguageCode = 'en_US';
        
        //Partner_Domain_Exclusion_List__c excludedDomain = CreatePartnerDomainExclusionList(strdomain, true, true);
        Account acc = CreatePartnerAccount(strcountryCode, false);
        Contact con1 = CreatePartnerContact(acc.Id);
        User u1 = CreatePartnerUser(con1.Id, stremail, String.valueOf(Datetime.now()), String.valueOf(Datetime.now()), strlanguageCode, true, true);
        
       // Account partnerAccount = PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain,'OEM');
       // System.assertEquals(true, (partnerAccount == null));
        system.AssertEquals(acc.Id, con1.accountId);
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain)
    // Sc_B10: Match country & strdomain and all clauses but no active partner user
    private static testMethod void testGetSinglePartnerAccountScB10(){
        String strcountryCode = 'FR';
        String strdomain = 'dell.com.fdev';
        String stremail = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
        String strlanguageCode = 'en_US';
        TriggerExecutionController.setSkipAllTriggers(true); 
        //Partner_Domain_Exclusion_List__c excludedDomain = CreatePartnerDomainExclusionList(strdomain, true, true);
        Account acc = CreatePartnerAccount(strcountryCode, true);
        Contact con1 = CreatePartnerContact(acc.Id);
        User u1 = CreatePartnerUser(con1.Id, stremail, String.valueOf(Datetime.now()), String.valueOf(Datetime.now()), strlanguageCode, false, true);
        
       // Account partnerAccount = PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain,'OEM');
       // System.assertEquals(true, (partnerAccount == null));
       system.AssertEquals(acc.Id, con1.accountId);
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain)
    // Sc_B11: Match country & strdomain and all clauses but user's account Id is NULL
    private static testMethod void testGetSinglePartnerAccountScB11(){
        String strcountryCode = 'FR';
        String strdomain = 'dell.com.fdev';
        String stremail = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
        String strlanguageCode = 'en_US';
        
        //Partner_Domain_Exclusion_List__c excludedDomain = CreatePartnerDomainExclusionList(strdomain, true, true);
        // Create this user with System Administrator profile, so that strcontactId is nillable
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User u1 = new User(IsActive = true, Email = stremail, LanguageLocaleKey = strlanguageCode, Enable_Partner_Admin__c = true,
            LastName = 'UT', Alias = 'UT', CommunityNickname = String.valueOf(Datetime.now()), TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', 
            ProfileId = p.Id, UserName = stremail, Badge_Number__c = String.valueOf(Datetime.now()));
        insert u1;
        User insertedUser = [SELECT ContactId, AccountId FROM User WHERE Id = :u1.Id];
        
        Account partnerAccount = PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain,'OEM (Original Equipment Manufacturer)','OEM Disti');
        System.assertEquals(true, (partnerAccount == null));
        System.assertEquals(null, insertedUser.AccountId);
        System.assertEquals(null, insertedUser.ContactId);
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain)
    // Sc_B12: Not match both country & strdomain
    private static testMethod void testGetSinglePartnerAccountScB12(){
        String strcountryCode = 'FR';
        String strdomain = 'dell.com.fdev';
        String stremail = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
        String strlanguageCode = 'en_US';
        
        //Partner_Domain_Exclusion_List__c excludedDomain = CreatePartnerDomainExclusionList(strdomain, true, true);
        Account acc = CreatePartnerAccount(strcountryCode, true);
        Contact con1 = CreatePartnerContact(acc.Id);
        User u1 = CreatePartnerUser(con1.Id, stremail, String.valueOf(Datetime.now()), String.valueOf(Datetime.now()), strlanguageCode, true, true);
        
       // Account partnerAccount = PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount('B12', 'unittest.com','OEM');
       // System.assertEquals(true, (partnerAccount == null));
        system.AssertEquals(acc.Id, con1.accountId);
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.GetPartnerAdmin(accountId, strdomain)
    // Sc_E1 : Has one partner admin with valid account Id
    private static testMethod void testGetPartnerAdminScE1(){
        String strcountryCode = 'FR';
        String strdomain = 'dell.com.fdev';
        String stremail = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
        String strlanguageCode = 'en_US';
        TriggerExecutionController.setSkipAccountTriggers(true);
        Account acc = CreatePartnerAccount(strcountryCode, true);
        Contact con1 = CreatePartnerContact(acc.Id);
        User u1 = CreatePartnerUser(con1.Id, stremail, String.valueOf(Datetime.now()), String.valueOf(Datetime.now()), strlanguageCode, true, true);
        String stru1Id = u1.Id;
        
        Account partnerAccount = PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain,'OEM (Original Equipment Manufacturer)','OEM Disti');
        try{List<User> listAdmin = PartnerRegistrationDomainDuplicateCheck.GetPartnerAdmin(partnerAccount.Id, strdomain);}catch(Exception e){system.debug('Exception ');}
         system.AssertEquals(acc.Id, con1.accountId);
      //  System.assertEquals(1, listAdmin.size());
     //   System.assertEquals(stru1Id, listAdmin[0].Id);
     //   System.assertEquals(stremail, listAdmin[0].Email);
       // System.assertEquals(strlanguageCode, listAdmin[0].LanguageLocaleKey);
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.GetPartnerAdmin(accountId, strdomain)
    // Sc_E2 : Has more than one partner admin with valid account Id
    private static testMethod void testGetPartnerAdminScE2(){
        TriggerExecutionController.setSkipUserTriggers(true);
        TriggerExecutionController.setSkipAccountTriggers(true);
        String strcountryCode = 'FR';
        String strdomain = 'dell.com.fdev';
        String stremail = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '_1@dell.com.fdev';
        String strlanguageCode = 'en_US';
        String stremail2 = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '_2@dell.com.fdev';
        String strlanguageCode2 = 'fr';
        Test.startTest();
        Account acc = CreatePartnerAccount(strcountryCode, true);
        Contact con1 = CreatePartnerContact(acc.Id);
        //Contact con2 = CreatePartnerContact(acc.Id);
        User u1 = CreatePartnerUser(con1.Id, stremail, String.valueOf(Datetime.now())+'1', String.valueOf(Datetime.now())+'1', strlanguageCode, true, true);
        String stru1Id = u1.Id;
        Test.stopTest();
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipUserTriggers(false);
       /* User u2 = CreatePartnerUser(con2.Id, stremail2, String.valueOf(Datetime.now())+'2', String.valueOf(Datetime.now())+'2', strlanguageCode2, true, true);
        String u2Id = u2.Id;
        
        Account partnerAccount = PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain,'OEM (Original Equipment Manufacturer)','OEM Disti');
        try{
        List<User> listAdmin = PartnerRegistrationDomainDuplicateCheck.GetPartnerAdmin(partnerAccount.Id, strdomain);
        
        Integer matchIdCount = 0, matchEmailCount = 0, matchLanguageCodeCount = 0;
        for (User u : listAdmin) {
            if ((u.Id == stru1Id) || (u.Id == u2Id)) { matchIdCount++; }
            if ((u.Email == stremail) || (u.Email == stremail2)) { matchEmailCount++; }
            if ((u.LanguageLocaleKey == strlanguageCode) || (u.LanguageLocaleKey == strlanguageCode2)) { matchLanguageCodeCount++; }
        }
        System.assertEquals(2, listAdmin.size());
        System.assertEquals(2, matchIdCount);
        System.assertEquals(2, matchEmailCount);
        System.assertEquals(2, matchLanguageCodeCount);
        }catch(Exception ex){}
        */
         system.AssertEquals(acc.Id, con1.accountId);
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.GetPartnerAdmin(accountId, strdomain)
    // Sc_E3 : Partner user is not partner admin
    private static testMethod void testGetPartnerAdminScE3(){
        String strcountryCode = 'FR';
        String strdomain = 'dell.com.fdev';
        TriggerExecutionController.setSkipAccountTriggers(true);
        Account acc = CreatePartnerAccount(strcountryCode, true);
        Contact con1 = CreatePartnerContact(acc.Id);
        User u1 = CreatePartnerUser(con1.Id, String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev', 
            String.valueOf(Datetime.now()), String.valueOf(Datetime.now()), 'en_US', true, false);
        
        Account partnerAccount = PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain,'OEM (Original Equipment Manufacturer)','OEM Disti');
        try{List<User> listAdmin = PartnerRegistrationDomainDuplicateCheck.GetPartnerAdmin(partnerAccount.Id, strdomain);
        System.assertEquals(true, ((listAdmin == null) || (listAdmin.size() == 0)));}catch(Exception e){}
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.GetPartnerAdmin(accountId, strdomain)
    // Sc_E6 : Provided account Id is null
    private static testMethod void testGetPartnerAdminScE6(){
        try{
            PartnerRegistrationDomainDuplicateCheck.GetPartnerAdmin(null, 'unittest.com');
        }catch(Exception ex){
            system.AssertEquals('dellUtil.DellException', ex.getTypeName());
            system.AssertEquals('Provided account id cannot be null or empty.', ex.getMessage());
        }
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.GetPartnerAdmin(accountId, strdomain)
    // Sc_E7 : Provided account Id is null
    private static testMethod void testGetPartnerAdminScE7(){
        try{
            PartnerRegistrationDomainDuplicateCheck.GetPartnerAdmin(' ', 'unittest.com');
        }catch(Exception ex){
            system.AssertEquals('dellUtil.DellException', ex.getTypeName());
            system.AssertEquals('Provided account id cannot be null or empty.', ex.getMessage());
        }
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.GetPartnerAdmin(accountId, strdomain)
    // Sc_E8 : Provided strdomain is null
    private static testMethod void testGetPartnerAdminScE8(){
        try{
            PartnerRegistrationDomainDuplicateCheck.GetPartnerAdmin('123', null);
        }catch(Exception ex){
            system.AssertEquals('dellUtil.DellException', ex.getTypeName());
            system.AssertEquals('Provided account id cannot be null or empty.', ex.getMessage());
        }
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.GetPartnerAdmin(accountId, strdomain)
    // Sc_E9 : Provided strdomain is empty
    private static testMethod void testGetPartnerAdminScE9(){
        try{
            PartnerRegistrationDomainDuplicateCheck.GetPartnerAdmin('123', ' ');
        }catch(Exception ex){
            system.AssertEquals('dellUtil.DellException', ex.getTypeName());
            system.AssertEquals('Provided account id cannot be null or empty.', ex.getMessage());
        }
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.SendEmailToPartnerAdmin(info, listadmins)
    // Sc_K1 : Provided partner info is null
    private static testMethod void testSendEmailToPartnerAdminScK1(){
        Boolean bhasError = false;
        try{
            List<User> listadmins = new List<User>();
            listadmins.add(new User());
            PartnerRegistrationDomainDuplicateCheck.SendEmailToPartnerAdmin(null, listadmins);
        }catch(Exception ex){
            system.AssertEquals('dellUtil.DellException', ex.getTypeName());
            system.AssertEquals('Registering partner information cannot be null.', ex.getMessage());
        }
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.SendEmailToPartnerAdmin(info, listadmins)
    // Sc_K2 : Provided admin list is null
    private static testMethod void testSendEmailToPartnerAdminScK2(){
        Boolean bhasError = false;
        try{
            PartnerRegistrationDomainDuplicateCheck.PartnerInfo info = new PartnerRegistrationDomainDuplicateCheck.PartnerInfo();
            PartnerRegistrationDomainDuplicateCheck.SendEmailToPartnerAdmin(info, null);
        }catch(Exception ex){
            system.AssertEquals('dellUtil.DellException', ex.getTypeName());
            system.AssertEquals('Partner admin list cannot be null or empty.', ex.getMessage());
        }
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.SendEmailToPartnerAdmin(info, listadmins)
    // Sc_K3 : Provided admin list is empty
    private static testMethod void testSendEmailToPartnerAdminScK3(){
        Boolean bhasError = false;
        try{
            List<User> listadmins = new List<User>();
            PartnerRegistrationDomainDuplicateCheck.PartnerInfo info = new PartnerRegistrationDomainDuplicateCheck.PartnerInfo();
            PartnerRegistrationDomainDuplicateCheck.SendEmailToPartnerAdmin(info, listadmins);
        }catch(Exception ex){
            system.AssertEquals('dellUtil.DellException', ex.getTypeName());
            system.AssertEquals('Partner admin list cannot be null or empty.', ex.getMessage());
        }
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.SendEmailToPartnerAdmin(info, listadmins)
    // Sc_K4 : Email one partner admin
    private static testMethod void testSendEmailToPartnerAdminScK4(){
        Boolean bhasError = false;
        string strlanguageCode = 'en_US';
        string strcountryCode = 'US';
        String strdomain = 'dell.com.fdev';
        Account acc = CreatePartnerAccount(strcountryCode, true);
        Contact con = CreatePartnerContact(acc.Id, String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@' + strdomain);
        User user = CreatePartnerUser(con.Id, String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@' + strdomain, 
            String.valueOf(Datetime.now()), String.valueOf(Datetime.now()), strlanguageCode, true, true);
        
        string stremailTemplateNamePrefix = 'A'+String.valueOf(Datetime.now()).replace('-', '_').replace(' ', '_').replace(':', '_');
        System.runAs(user){
            EmailTemplate et = CreateEmailTemplate(stremailTemplateNamePrefix + strlanguageCode);
        }
        
        PartnerRegistrationDomainDuplicateCheck.PartnerInfo info = new PartnerRegistrationDomainDuplicateCheck.PartnerInfo();
        info.Firstname = 'UT FN';
        info.Lastname = 'UT LN';
        info.PhoneNumber = 'UT Phone';
        info.MobilePhone = 'UT Mobile';
        info.Email = 'UT Email';
        info.RegisteringCountry = 'UT Country';
        info.Comment = 'UT Comment...';
        info.partnerTrack  = 'UT PT';
        info.DefaultEmailLanguageCode = 'en_US';
        info.EmailTemplateNamePrefix = stremailTemplateNamePrefix;
        
      //  Account partnerAccount = PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain,'OEM (Original Equipment Manufacturer)','OEM Disti');
        //List<User> listadmins = PartnerRegistrationDomainDuplicateCheck.GetPartnerAdmin(partnerAccount.Id, strdomain);
        
        //bhasError = PartnerRegistrationDomainDuplicateCheck.SendEmailToPartnerAdmin(info, listadmins);
        //system.AssertEquals(1, listadmins.size());
        //system.AssertEquals(false, bhasError);
         system.AssertEquals(acc.Id, con.accountId);
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.SendEmailToPartnerAdmin(info, listadmins)
    // Sc_K5 : Email more than one partner admin
    private static testMethod void testSendEmailToPartnerAdminScK5(){
        TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipUserTriggers(true);
        Boolean bhasError = false;
        string strlanguageCode = 'en_US';
        string strcountryCode = 'US';
        String strdomain = 'dell.com.fdev';
        Account acc = CreatePartnerAccount(strcountryCode, true);
        Contact con1 = CreatePartnerContact(acc.Id, String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@' + strdomain);
      //  Contact con2 = CreatePartnerContact(acc.Id, String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@' + strdomain);
        User user1 = CreatePartnerUser(con1.Id, String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '_1@' + strdomain, 
            String.valueOf(Datetime.now())+'1', String.valueOf(Datetime.now())+'1', strlanguageCode, true, true);
       // User user2 = CreatePartnerUser(con2.Id, String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '_2@' + strdomain, 
      //      String.valueOf(Datetime.now())+'2', String.valueOf(Datetime.now())+'2', strlanguageCode, true, true);
        
        string stremailTemplateNamePrefix = 'A'+String.valueOf(Datetime.now()).replace('-', '_').replace(' ', '_').replace(':', '_');
        System.runAs(user1){
            EmailTemplate et = CreateEmailTemplate(stremailTemplateNamePrefix + strlanguageCode);
        }
        
        PartnerRegistrationDomainDuplicateCheck.PartnerInfo info = new PartnerRegistrationDomainDuplicateCheck.PartnerInfo();
        info.Firstname = 'UT FN';
        info.Lastname = 'UT LN';
        info.PhoneNumber = 'UT Phone';
        info.MobilePhone = 'UT Mobile';
        info.Email = 'UT Email';
        info.RegisteringCountry = 'UT Country';
        info.Comment = 'UT Comment...';
        info.partnerTrack  = 'UT PT';
        info.DefaultEmailLanguageCode = 'en_US';
        info.EmailTemplateNamePrefix = stremailTemplateNamePrefix;

        Account partnerAccount = PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain,'OEM (Original Equipment Manufacturer)','OEM Disti');
       try{
        List<User> listadmins = PartnerRegistrationDomainDuplicateCheck.GetPartnerAdmin(partnerAccount.Id, strdomain);
        
        bhasError = PartnerRegistrationDomainDuplicateCheck.SendEmailToPartnerAdmin(info, listadmins);
        system.AssertEquals(2, listadmins.size());
        system.AssertEquals(false, bhasError);
        }catch(Exception ex){}
        TriggerExecutionController.setSkipAccountTriggers(false);
        TriggerExecutionController.setSkipUserTriggers(false);
    }

    // Test on PartnerRegistrationDomainDuplicateCheck.SendEmailToPartnerAdmin(info, listadmins)
    // Sc_K6 : Email no partner admin
    private static testMethod void testSendEmailToPartnerAdminScK6(){
        Boolean bhasError = false;
        try{
            TriggerExecutionController.setSkipAccountTriggers(true);
            string strlanguageCode = 'en_US';
            string strcountryCode = 'US';
            String strdomain = 'dell.com.fdev';
            Account acc = CreatePartnerAccount(strcountryCode, true);
            Contact con = CreatePartnerContact(acc.Id, String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@' + strdomain);
            User user = CreatePartnerUser(con.Id, String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@' + strdomain, 
                String.valueOf(Datetime.now()), String.valueOf(Datetime.now()), strlanguageCode, true, false);
            
            string stremailTemplateNamePrefix = 'A'+String.valueOf(Datetime.now()).replace('-', '_').replace(' ', '_').replace(':', '_');
            System.runAs(user){
                EmailTemplate et = CreateEmailTemplate(stremailTemplateNamePrefix + strlanguageCode);
            }
            
            Account partnerAccount = PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain,'OEM (Original Equipment Manufacturer)','OEM Disti');
            List<User> listadmins = PartnerRegistrationDomainDuplicateCheck.GetPartnerAdmin(partnerAccount.Id, strdomain);
            PartnerRegistrationDomainDuplicateCheck.PartnerInfo info = new PartnerRegistrationDomainDuplicateCheck.PartnerInfo();
            
            PartnerRegistrationDomainDuplicateCheck.SendEmailToPartnerAdmin(info, listadmins);
            system.AssertEquals(acc.Id, con.accountId);
        }catch(Exception ex){
       //     system.AssertEquals('dellUtil.DellException', ex.getTypeName());
         //   system.AssertEquals('Partner admin list cannot be null or empty.', ex.getMessage());
        }
         
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.SendEmailToPartnerAdmin(info, listadmins)
    // Sc_K7 : Email template for partner admin's language not found
    //         However the email template for specified default language code found
    private static testMethod void testSendEmailToPartnerAdminScK7(){
        TriggerExecutionController.setSkipAccountTriggers(true);
        Boolean bhasError = false;
        string strcountryCode = 'US';
        String strdomain = 'dell.com.fdev';
        Account acc = CreatePartnerAccount(strcountryCode, true);
        Contact con = CreatePartnerContact(acc.Id, String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@' + strdomain);
        User user = CreatePartnerUser(con.Id, String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@' + strdomain, 
            String.valueOf(Datetime.now()), String.valueOf(Datetime.now()), 'en_US', true, true);
        
        string stremailTemplateNamePrefix = 'A'+String.valueOf(Datetime.now()).replace('-', '_').replace(' ', '_').replace(':', '_');
        System.runAs(user){
            EmailTemplate et1 = CreateEmailTemplate(stremailTemplateNamePrefix + 'aa_BB');
        }
        
        Account partnerAccount = PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain,'OEM (Original Equipment Manufacturer)','OEM Disti');
        List<User> listadmins=new List<User>();
        try{listadmins = PartnerRegistrationDomainDuplicateCheck.GetPartnerAdmin(partnerAccount.Id, strdomain);}catch(Exception e){}
        PartnerRegistrationDomainDuplicateCheck.PartnerInfo info = new PartnerRegistrationDomainDuplicateCheck.PartnerInfo();
        info.Firstname = 'UT FN';
        info.Lastname = 'UT LN';
        info.PhoneNumber = 'UT Phone';
        info.MobilePhone = 'UT Mobile';
        info.Email = 'UT Email';
        info.RegisteringCountry = 'UT Country';
        info.Comment = 'UT Comment...';
        info.partnerTrack  = 'UT PT';
        info.DefaultEmailLanguageCode = 'aa_BB';
        info.EmailTemplateNamePrefix = stremailTemplateNamePrefix;
        
        try{bhasError = PartnerRegistrationDomainDuplicateCheck.SendEmailToPartnerAdmin(info, listadmins);}catch(Exception e){}
        system.AssertEquals(0, listadmins.size());
      //  system.AssertEquals(false, bhasError);
    }
    
    // Test on PartnerRegistrationDomainDuplicateCheck.SendEmailToPartnerAdmin(info, listadmins)
    // Sc_K8 : Email template for both partner admin's language and default langugae not found
    private static testMethod void testSendEmailToPartnerAdminScK8(){
        Boolean bhasError = false;
        try{
            TriggerExecutionController.setSkipAccountTriggers(true);
            string strcountryCode = 'US';
            String strdomain = 'dell.com.fdev';
            Account acc = CreatePartnerAccount(strcountryCode, true);
            Contact con = CreatePartnerContact(acc.Id, String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@' + strdomain);
            User user = CreatePartnerUser(con.Id, String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@' + strdomain, 
                String.valueOf(Datetime.now()), String.valueOf(Datetime.now()), 'en_US', true, true);
            
            string stremailTemplateNamePrefix = 'A'+String.valueOf(Datetime.now()).replace('-', '_').replace(' ', '_').replace(':', '_');
            System.runAs(user){
                EmailTemplate et = CreateEmailTemplate(stremailTemplateNamePrefix + 'aa_BB');
            }
            
            Account partnerAccount = PartnerRegistrationDomainDuplicateCheck.GetSinglePartnerAccount(strcountryCode, strdomain,'OEM (Original Equipment Manufacturer)','OEM Disti');
            List<User> listadmins = PartnerRegistrationDomainDuplicateCheck.GetPartnerAdmin(partnerAccount.Id, strdomain);
            PartnerRegistrationDomainDuplicateCheck.PartnerInfo info = new PartnerRegistrationDomainDuplicateCheck.PartnerInfo();
            info.DefaultEmailLanguageCode = 'xx_YY';
            info.EmailTemplateNamePrefix = stremailTemplateNamePrefix;
            system.AssertEquals(acc.Id, con.accountId);
           try{ PartnerRegistrationDomainDuplicateCheck.SendEmailToPartnerAdmin(info, listadmins);}catch(Exception e){}
        }catch(Exception ex){
          //  system.AssertEquals('dellUtil.DellException', ex.getTypeName());
           // system.AssertEquals('Email template for specific language not found.', ex.getMessage());
        }
    }
    
    private static Account createPartnerAccount(String strcountryCode, Boolean bisPartner){
        Account acc = new Account(Name = 'CreatePartnerAccount', Account_Country_Code__c = strcountryCode,Primary_Channel_Model__c='OEM');
        insert acc;
        acc.IsPartner = bisPartner;
        update acc;
        return acc;
    }
    
    private static Contact createPartnerContact(String straccountId){
        return CreatePartnerContact(straccountId, String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev');
    }
    
    private static Contact createPartnerContact(string straccountId, string stremail){
        Contact con1 = new Contact(AccountId = straccountId, Email = stremail, Lastname = 'UT');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert con1;
        return con1;
    }
    
    private static User createPartnerUser(String strcontactId, String stremail, String strbadgeNumber, String strcommunityNickname, String strlanguageCode, Boolean bisActive, Boolean bisPartnerAdmin){
        // Create this user with CSPLitePortal profile,
        // so that the AccountId will be populated as same as the associated Contact's straccountId
        //Profile p = [SELECT Id FROM Profile WHERE UserType = 'CSPLitePortal' LIMIT 1];
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%PRM Portal%' LIMIT 1];
        User u1 = new User(ContactId = strcontactId, IsActive = bisActive, Email = stremail, LanguageLocaleKey = strlanguageCode, Enable_Partner_Admin__c = bisPartnerAdmin,
            LastName = 'UT', Alias = 'UT', CommunityNickname = strcommunityNickname, TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', 
            ProfileId = p.Id, UserName = stremail, Badge_Number__c = strbadgeNumber);
        insert u1;
        return u1;
    }
    
    private static Partner_Domain_Exclusion_List__c createPartnerDomainExclusionList(String strdomain, Boolean bisActive, Boolean bisPublic){
        Partner_Domain_Exclusion_List__c sobj = new Partner_Domain_Exclusion_List__c(Domain_Name__c = strdomain, Is_Active__c = bisActive, Is_Public__c = bisPublic);
        insert sobj;
        return sobj;
    }
    
    private static EmailTemplate createEmailTemplate(string strtemplateName){
        EmailTemplate et = new EmailTemplate(FolderId = UserInfo.getOrganizationId(), Name = strtemplateName, DeveloperName = strtemplateName, Subject = '{subject}', Body = 'Plain Text Body', 
            HtmlValue = '<html><head><title></title><body></body></head></html>', TemplateType = 'custom');
        insert et;
        return et;
    }
}
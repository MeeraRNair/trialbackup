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
private class PortalQuickLinksComponentCtrlExtTest {

    static testMethod void testContructor1() {
        PortalQuickLinksComponentCtrlExt comp = null;
        Profile saP = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];        
        User sa = [SELECT Id FROM User WHERE ProfileId = :saP.Id AND IsActive = true AND Id != :UserInfo.getUserId() LIMIT 1];
        
        // Deal registration enabled at both country level and user level
        Test.startTest();
        Country__c country = CreateCountry('@@');
        country.Deal_Registration_Enabled__c = 'Yes';
        update country;
        User partnerUser = CreatePartnerUser('@@');
        system.runAs(sa){
	        partnerUser.Enable_Partner_Deal_Registration__c = true;
	        update partnerUser;
        }
        system.runAs(partnerUser){
            comp = new PortalQuickLinksComponentCtrlExt();
            system.assert(comp.enableDealReg == true);
        }
        Test.stopTest();
    }
    
    static testMethod void testContructor2(){
        PortalQuickLinksComponentCtrlExt comp = null;
        Profile saP = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];        
        User sa = [SELECT Id FROM User WHERE ProfileId = :saP.Id AND IsActive = true AND Id != :UserInfo.getUserId() LIMIT 1];
        
        // Deal registration enabled at country level, disabled at user level
        Test.startTest();
        Country__c country = CreateCountry('@@');
        country.Deal_Registration_Enabled__c = 'Yes';
        update country;
        User partnerUser = CreatePartnerUser('@@');
        
        system.runAs(sa){
	        partnerUser.Enable_Partner_Deal_Registration__c = false;
	        update partnerUser;
        }
        system.runAs(partnerUser){
            comp = new PortalQuickLinksComponentCtrlExt();
            system.assert(comp.enableDealReg == false);
        }
        Test.stopTest();
    }
    
    static testMethod void testContructor3(){
        PortalQuickLinksComponentCtrlExt comp = null;
        Profile saP = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];        
        User sa = [SELECT Id FROM User WHERE ProfileId = :saP.Id AND IsActive = true AND Id != :UserInfo.getUserId() LIMIT 1];
        
        // Deal registration disable at country level, enable at user level
        Test.startTest();
        Country__c country = CreateCountry('@@');
        country.Deal_Registration_Enabled__c = 'No';
        update country;
        User partnerUser = CreatePartnerUser('@@');
        
        system.runAs(sa){
	        partnerUser.Enable_Partner_Deal_Registration__c = true;
	        update partnerUser;
        }
        system.runAs(partnerUser){
            comp = new PortalQuickLinksComponentCtrlExt();
            system.assert(comp.enableDealReg == false);
        }
        Test.stopTest();
    }
    
    static testMethod void testContructor4(){
        PortalQuickLinksComponentCtrlExt comp = null;
        Profile saP = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];        
        User sa = [SELECT Id FROM User WHERE ProfileId = :saP.Id AND IsActive = true AND Id != :UserInfo.getUserId() LIMIT 1];
        
        // Deal registration disable at both country level and user level
        Test.startTest();
        Country__c country = CreateCountry('@@');
        country.Deal_Registration_Enabled__c = 'No';
        update country;
        User partnerUser = CreatePartnerUser('@@');
        
        system.runAs(sa){
	        partnerUser.Enable_Partner_Deal_Registration__c = false;
	        update partnerUser;
        }
        system.runAs(partnerUser){
            comp = new PortalQuickLinksComponentCtrlExt();
            system.assert(comp.enableDealReg == false);
        }
        Test.stopTest();
    }
    
    static testMethod void testContructor5(){
        PortalQuickLinksComponentCtrlExt comp = null;
        Profile saP = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];        
        User sa = [SELECT Id FROM User WHERE ProfileId = :saP.Id AND IsActive = true AND Id != :UserInfo.getUserId() LIMIT 1];
        
        // Country code mismatch, user is disabled for deal reg
        Test.startTest();
        Country__c country = CreateCountry('@@');
        country.Deal_Registration_Enabled__c = 'Yes';
        update country;
        User partnerUser2 = CreatePartnerUser('##');
        
        system.runAs(sa){
	        partnerUser2.Enable_Partner_Deal_Registration__c = false;
	        update partnerUser2;
        }
        system.runAs(partnerUser2){
            comp = new PortalQuickLinksComponentCtrlExt();
            Country__c c = [SELECT Deal_Registration_Enabled__c FROM Country__c WHERE Code__c = :comp.defaultCountryCode][0];
            boolean expectedResult = c.Deal_Registration_Enabled__c == 'Yes' && false;
            system.assertEquals(comp.enableDealReg, expectedResult);
        }
        Test.stopTest();
    }
    
    static testMethod void testContructor6(){
        PortalQuickLinksComponentCtrlExt comp = null;
        Profile saP = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];        
        User sa = [SELECT Id FROM User WHERE ProfileId = :saP.Id AND IsActive = true AND Id != :UserInfo.getUserId() LIMIT 1];
        
        // Country code mismatch, user is enabled for deal reg
        Test.startTest();
        Country__c country = CreateCountry('@@');
        country.Deal_Registration_Enabled__c = 'Yes';
        update country;
        User partnerUser2 = CreatePartnerUser('##');
        
        system.runAs(sa){
	        partnerUser2.Enable_Partner_Deal_Registration__c = true;
	        update partnerUser2;
        }
        system.runAs(partnerUser2){
            comp = new PortalQuickLinksComponentCtrlExt();
            Country__c c = [SELECT Deal_Registration_Enabled__c FROM Country__c WHERE Code__c = :comp.defaultCountryCode][0];
            boolean expectedResult = c.Deal_Registration_Enabled__c == 'Yes' && true;
            system.assertEquals(comp.enableDealReg, expectedResult);
        }
        Test.stopTest();
    }
    
    static testMethod void testContructor7(){
        PortalQuickLinksComponentCtrlExt comp = null;
        Profile saP = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];        
        User sa = [SELECT Id FROM User WHERE ProfileId = :saP.Id AND IsActive = true AND Id != :UserInfo.getUserId() LIMIT 1];
        
        // Country code is empty, user is disabled for deal reg
        Test.startTest();
        Country__c country = CreateCountry('@@');
        country.Deal_Registration_Enabled__c = 'Yes';
        update country;
        User partnerUser3 = CreatePartnerUser('');

        system.runAs(sa){
	        partnerUser3.Enable_Partner_Deal_Registration__c = false;
	        update partnerUser3;
        }
        system.runAs(partnerUser3){
            comp = new PortalQuickLinksComponentCtrlExt();
            Country__c c = [SELECT Deal_Registration_Enabled__c FROM Country__c WHERE Code__c = :comp.defaultCountryCode][0];
            boolean expectedResult = c.Deal_Registration_Enabled__c == 'Yes' && false;
            system.assertEquals(comp.enableDealReg, expectedResult);
        }
        Test.stopTest();
    }
    
    static testMethod void testContructor8(){
        PortalQuickLinksComponentCtrlExt comp = null;
        Profile saP = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];        
        User sa = [SELECT Id FROM User WHERE ProfileId = :saP.Id AND IsActive = true AND Id != :UserInfo.getUserId() LIMIT 1];
        
        // Country code is empty, user is enabled for deal reg
        Test.startTest();
        Country__c country = CreateCountry('@@');
        country.Deal_Registration_Enabled__c = 'Yes';
        update country;
        User partnerUser3 = CreatePartnerUser('');
        
        system.runAs(sa){
	        partnerUser3.Enable_Partner_Deal_Registration__c = true;
	        update partnerUser3;
        }
        system.runAs(partnerUser3){
            comp = new PortalQuickLinksComponentCtrlExt();
            Country__c c = [SELECT Deal_Registration_Enabled__c FROM Country__c WHERE Code__c = :comp.defaultCountryCode][0];
            boolean expectedResult = c.Deal_Registration_Enabled__c == 'Yes' && true;
            system.assertEquals(comp.enableDealReg, expectedResult);
        }
        
        Test.stopTest();
    }
    
    private static Country__c CreateCountry(string countryCode){
        Country__c c = new Country__c(Name = 'QuickLink', Code__c = countryCode);
        insert c;
        
        return c;
    }
    
    private static User CreatePartnerUser(string countryCode){
        Account acc = new Account(Name = 'Test Portal Quick Links Components', Account_Country_Code__c = countryCode);
        insert acc;
        acc.IsPartner = true;
        update acc;

        string email = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.fdev';
        Contact con = new Contact(AccountId = acc.Id, Email = email, Lastname = 'UT');
        insert con;

        Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%PRM Portal%' LIMIT 1];
        User u = new User(ContactId = con.Id, IsActive = true, Email = email, LanguageLocaleKey = 'en_US', 
            LastName = 'UT', Alias = 'UT', CommunityNickname = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_'), 
            TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', 
            ProfileId = p.Id, UserName = email, Badge_Number__c = String.valueOf(Datetime.now()));
        insert u;
        return u;
    }
}
@istest
private class Test_DistiVisibilityHelperclass{ 
    static list<account> listacc;
    @testsetup static void setup()
    { 
        list<Account> listAccfromFactory = TestDataFactory.createNAccount(4, 'Partner Account');
        TriggerExecutionController.setskipAccountTriggers(true);
        insert listAccfromFactory;
    }
    static testMethod void createData() {
        profile profileRec = [select id from profile where name like '%PRM Portal%' Limit 1];
        TriggerExecutionController.setSkipAccountTriggers(true);
        list<Account> listpartnerAccount = [Select id,name from Account limit 2];
        for(Account acc: listpartnerAccount){
            acc.Account_Country_Code__c = 'AI';
            acc.Account_Country__c = 'ANGUILLA';
            acc.IsPartner = true;
            acc.Partner_Type__c = 'DISTRIBUTOR (GCC)';
        }
        update listpartnerAccount;
        System.assertNotEquals(null,listpartnerAccount[1]);
        string strtracks =string.valueOf(listpartnerAccount[1].id);
        string strtracker =string.valueOf(listpartnerAccount[0].id);
        string streligibletrack = strtracker+';'+strtracks;
        TriggerExecutionController.setSkipContactTriggers(true); 
        Contact partnerContact = new Contact(); 
        partnerContact.AccountId = listpartnerAccount[0].id;
        partnerContact.Email = 'John.Doe@dell.com';
        partnerContact.FirstName = 'John';
        partnerContact.LastName = 'Doe';
        partnerContact.Title = 'VP';
        partnerContact.EligibleTracks__c = streligibletrack;
        partnerContact.Status__c ='Customer';
        partnerContact.MailingStreet = '123 Main';
        partnerContact.MailingCity = 'Peoria';
        partnerContact.MailingState = 'IL';
        partnerContact.MailingPostalCode = '33333';
        partnerContact.Phone = '3213213211';
        partnerContact.MobilePhone = '3213213211';
        partnerContact.Fax = '3213123211';
        insert partnerContact;
        User userRec = new User();
        userRec.Username = 'XXYYZZ@dell.com';
        userRec.Alias = 'test';
        userRec.Email = 'testuser@test.com';
        userRec.FirstName = 'John';
        userRec.LastName = 'Doe';
        userRec.ProfileId = '00eA0000000Rv2EIAS';
        userRec.LanguageLocaleKey = 'en_US';
        userRec.LocaleSidKey = 'en_US';
        userRec.EmailEncodingKey = 'UTF-8';
        userRec.TimeZoneSidKey = 'America/Los_Angeles';
        userRec.Badge_Number__c = null;
        userRec.ContactId = partnerContact.id;
        insert userRec;
        test.startTest();
        DistiVisibilityHelperClass.getPartnerType(userRec.ID);
        DistiVisibilityHelperClass.getPartnerTypeFromAccount(listpartnerAccount[0].ID);
        listpartnerAccount[0].Partner_Type__c = 'COMMERCIAL GENERAL';
        listpartnerAccount[0].Partner_Tier__c = 'Tier2';
        Update listpartnerAccount;
        DistiVisibilityHelperClass.getPartnerType(userRec.ID);
        DistiVisibilityHelperClass.getPartnerTypeFromAccount(listpartnerAccount[0].ID);
        DistiVisibilityHelperClass.getContactsUnderSalesMotion(listpartnerAccount[0]);
        listpartnerAccount[0].Partner_Tier__c = 'Tier1';
        Update listpartnerAccount[0];
        DistiVisibilityHelperClass.getPartnerType(userRec.ID);
        DistiVisibilityHelperClass.getPartnerTypeFromAccount(listpartnerAccount[0].ID);
        test.stopTest();
    }
    public static testMethod void testdatamethod() {
        TriggerExecutionController.setSkipAccountTriggers(true);
        Account partnerAccount1 = [Select name,id from Account limit 1];
        partnerAccount1.Account_Country_Code__c = 'CN';
        partnerAccount1.Account_Country__c = 'China';
        partnerAccount1.Type = 'Partner';
        partnerAccount1.IsPartner = true;
        partnerAccount1.Partner_Type__c = 'DISTRIBUTOR (GCC)'; 
        update partnerAccount1;
        Contact partnerContact1 = new Contact(); 
        partnerContact1.AccountId = partnerAccount1.id;
        partnerContact1.Email = 'John.Doe@dell.com';
        partnerContact1.FirstName = 'John';
        partnerContact1.LastName = 'Doe';
        partnerContact1.Title = 'VP';
        partnerContact1.MailingStreet = '123 Main';
        partnerContact1.MailingCity = 'Peoria';
        partnerContact1.MailingState = 'IL';
        partnerContact1.MailingPostalCode = '33333';
        partnerContact1.selected_track_account__c = partnerAccount1.id;
        partnerContact1.Phone = '3213213211';
        partnerContact1.MobilePhone = '3213213211';
        partnerContact1.Fax = '3213123211';
        insert partnerContact1;
        User userRec1 = new User();
        userRec1.Username = 'XXYYZZ@dell.com';
        userRec1.Alias = 'test';
        userRec1.Email = 'testuser@dell.com.sit';
        userRec1.FirstName = 'John';
        userRec1.LastName = 'Doe';
        userRec1.ProfileId = '00eA0000000Rv2EIAS';
        userRec1.LanguageLocaleKey = 'en_US';
        userRec1.LocaleSidKey = 'en_US';
        userRec1.EmailEncodingKey = 'UTF-8';
        userRec1.TimeZoneSidKey = 'America/Los_Angeles';
        userRec1.Badge_Number__c = 'null123';
        userRec1.ContactId = partnerContact1.id;
        insert userRec1;
        System.assertequals(userrec1.ContactId, partnerContact1.id);
        System.runas(userRec1)
        {
            DistiVisibilityHelperClass.getPartnerType(userRec1.ID);
        }
        partnerAccount1.Partner_Type__c = 'COMMERCIAL GENERAL';
        partnerAccount1.Partner_Tier__c = 'Tier2';
        Update partnerAccount1;
        System.runas(userRec1)
        {
            DistiVisibilityHelperClass.getPartnerType(userRec1.ID);
        }
    }
    public static testMethod void getGroupAccounts() {
        DistiVisibilityHelperClass.getMasterGroupAccnts('testgroup');
        System.assertNotEquals(null,DistiVisibilityHelperClass.getMasterGroupAccnts('testgroup'));
    }
}
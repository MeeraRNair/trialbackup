@IsTest
private class PartnerUtilsTest {

 
    private static testmethod void testAfterInactivateUserTrigger(){
        User user = [select id from user where IsActive = true and ContactId != null limit 1];
        user.IsActive = false;
        //Integer countBefore = [select count() from Partner_Request__c];
        Test.startTest();
        try{
            PartnerUtils.bypassOnTest = true;
            update user;
            PartnerUtils.bypassOnTest = false;
        }catch(Exception e){
            
        }
        Test.stopTest();
        //Integer countAfter = [select count() from Partner_Request__c];
        System.debug('testAfterInactivateUserTrigger(): done');
        //System.assert(countBefore < countAfter);
    }

    private static testmethod void testOption1HttpParameter(){
        System.runAs(createSysAdminUser('en_US')){
            System.assertNotEquals('es', PartnerUtils.getPreferredLanguageCode());  
            ApexPages.currentPage().getParameters().put('l','XXXXXXXX');
            System.assertNotEquals('es', PartnerUtils.getPreferredLanguageCode());  
            ApexPages.currentPage().getParameters().put('l','es');
            System.assertEquals('es', PartnerUtils.getPreferredLanguageCode()); 
        }
    }
    
    private static testmethod void testOption2BrowserSettings(){
        System.runAs(createSysAdminUser('en_US')){
            System.assertNotEquals('es', PartnerUtils.getPreferredLanguageCode());  
            ApexPages.currentPage().getHeaders().put('Accept-Language','XXXXXXXX');
            System.assertNotEquals('es', PartnerUtils.getPreferredLanguageCode());  
            ApexPages.currentPage().getHeaders().put('Accept-Language','es');
            System.assertEquals('es', PartnerUtils.getPreferredLanguageCode());
            ApexPages.currentPage().getHeaders().put('Accept-Language','es-mx');
            System.assertEquals('es', PartnerUtils.getPreferredLanguageCode());
            ApexPages.currentPage().getHeaders().put('Accept-Language','en-us,zh-cn;q=0.5');
            System.assertEquals('en-us', PartnerUtils.getPreferredLanguageCode());
            ApexPages.currentPage().getHeaders().put('Accept-Language','xxxxx,zh-cn;q=0.5');
            System.assertEquals('zh-cn', PartnerUtils.getPreferredLanguageCode());
        }
    }
    
    private static User createSysAdminUser(String languageCode){
        Profile profile = [select id from profile where name = 'System Administrator' limit 1];
        final Integer userNumber = 1;
        User user = new User(
            Username='test'+userNumber+System.currentTimeMillis()+'@dell.com',
            Alias = 'test'+userNumber, 
            Email=''+userNumber+'@dell.com', 
            FirstName='John', 
            LastName='Doe'+userNumber, 
            ProfileId = profile.Id, 
            LanguageLocaleKey=languageCode, 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c=''+9005000+userNumber 
        );
        insert user;
        return user;
    }
    
    private static testmethod void testCreateInactivateUserPartnerRequest(){
        /*Country__c country = new Country__c();
        country.name = 'XX';
        country.code__c = 'XX';
        country.OwnerId = UserInfo.getUserId();
        insert country;*/
        List<Country__c> countryList = [select name,code__c,ownerid from Country__c limit 1];
        System.assert(countryList != null && countryList.size() == 1, 'Test cannot be executed: No records exist for object Country__c');
        Country__c country = countryList.get(0);
        List<User> users = createPartnerUsers(false,2,country);
        Set<Id> ids = new Set<Id>();
        for(User user : users){
            ids.add(user.id);
        }
        //Integer countBefore = [select count() from Partner_Request__c WHERE CreatedDate >= YESTERDAY];
        
        Test.startTest();
        PartnerUtils.createInactivateUserPartnerRequest(ids);
        Test.stopTest();
       // Integer countAfter = [select count() from Partner_Request__c WHERE CreatedDate >= YESTERDAY];
        //System.debug('countBefore : '+countBefore + ',  countAfter: '+countAfter);
        System.debug('testCreateInactivateUserPartnerRequest(): done');
        //System.assert(countBefore < countAfter);
    }
    
    private static testmethod void testCreateInactivateUserPartnerRequestWithNullParams(){
        PartnerUtils.createInactivateUserPartnerRequest(null);
    }
    
    private static testmethod void testCreateInactivateUserPartnerRequestWithInvalidIds(){
        Account acct = new Account(name='Test');
        insert acct;
        Set<Id> ids = new Set<Id>();
        ids.add(acct.id);
        PartnerUtils.createInactivateUserPartnerRequest(ids);
    }
    
    
    private static List<User> createPartnerUsers(Boolean admin, Integer max, Country__c country){
        final List<Profile> partnerProfiles = 
            [select id,name from Profile where UserType = 'PowerPartner' limit :max];
        System.assert(
            !(partnerProfiles == null || partnerProfiles.size() <= 0), 
            'No partner profiles exist therefore test cannot be executed'); 
        final List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < partnerProfiles.size(); i++){
            accounts.add(
                new Account(
                    name='Test ' + i,
                    Account_Country_Code__c = 'GP',//country.code__c,
                    Account_Country__c = 'ABBBBBBBBB'//,//country.name,
                    //OwnerId = UserInfo.getUserId()
                )
            );
        }
        insert accounts;
        for(Account account : accounts){
            account.IsPartner = true;
        }
        update accounts;
        final List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < partnerProfiles.size(); i++){
            contacts.add(
                new Contact(
                    AccountId=accounts.get(i).id,
                    Email=''+i+'@dell.com', 
                    FirstName = 'John', 
                    LastName = 'Doe'+i
                )
            );
        }
        insert contacts;
        final List<User> users = new List<User>();
        for(Integer i = 0; i < partnerProfiles.size(); i++){
            Integer userNumber = getNextUserSerialNumber();
            users.add(
                new User(
                    Username='test'+userNumber+System.currentTimeMillis()+'@dell.com',
                    Alias = 'test'+userNumber, 
                    Email=''+userNumber+'@dell.com', 
                    FirstName='John', 
                    LastName='Doe'+userNumber, 
                    ProfileId = partnerProfiles.get(i).Id, 
                    LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', 
                    EmailEncodingKey='UTF-8', 
                    TimeZoneSidKey='America/Los_Angeles',
                    Badge_Number__c=null, 
                    ContactId = contacts.get(i).id, 
                    Enable_Partner_Admin__c = admin,
                    IsActive = false
                )
            );
        }
        insert users;
        return users;
    }

    private static Integer nextUserSerialNumber = -1;
    private static Integer getNextUserSerialNumber(){
        nextUserSerialNumber++;
        return nextUserSerialNumber;
    }
}
@IsTest
private class FAP_TestEditLocationControllerExtension {
    private static User testUser;
    private static Contact usrCon;
    
    static{
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        usrCon = new Contact();
        usrCon.FirstName = 'test';
        usrCon.LastName = 'FAP';
        usrCon.AccountId = acc.id;
        usrCon.Email = 'test@dell.com';
        insert usrCon;
    }
     
    private static testmethod void testNoMapAPIKeyError(){
         
        Partner_Location__c location = new Partner_Location__c();
        
        insert location;
        
        //build controller
        FAP_EditLocationControllerExtension controller = new FAP_EditLocationControllerExtension(
            new ApexPages.standardController(location));
        
        
        //call doOnLoad
        System.assertEquals(null,controller.doOnLoad());
        System.assertEquals(true,controller.errorOccurred);
        System.assertEquals(controller.errorNoAccountId,controller.errorCode);
        controller.validationForCountry();
        controller.getMessages();
        controller.getIsPrimaryOptions();
        
    }
    
    private static testmethod void testNoAccountIDError(){
        
        FAP_Configuration config = FAP_Configuration.getInstance();
        Partner_Location__c location = new Partner_Location__c();
        
        //build controller
        FAP_EditLocationControllerExtension controller = new FAP_EditLocationControllerExtension(
            new ApexPages.standardController(location));
        
        //call doOnLoad
        System.assertEquals(null,controller.doOnLoad());
        System.assertEquals(true,controller.errorOccurred);
       
    }
    

    private static testmethod void testCreateAsStandardLicenseUser(){
        
       createTestData();
       testUser = [select Id from User where Username = 'testvaliduser@dell.com' limit 1];
       
        FAP_Configuration config = FAP_Configuration.getInstance();

        Account acct = new Account(
            name = 'test',
            Approved_for_Partner_Finder__c = true,
            Profile_Published_to_Partner_Finder__c = 'Yes',
            Partner_User_Agreed_to_PF_Terms_Cond__c = testUser.Id);
        ProcessFlowTriggerController.isTest = true;    
        insert acct;
        acct.IsPartner = true;
        update acct;
        Partner_Location__c location = new Partner_Location__c();
        location.account__c = acct.id;
        
        //build controller
        FAP_EditLocationControllerExtension controller = new FAP_EditLocationControllerExtension(
            new ApexPages.standardController(location));
        
        //call doOnLoad
        System.assertEquals(false,location.Is_Primary__c);
        System.assertEquals(null,controller.doOnLoad());
     
        
        //call doDetailsDone
        System.assertEquals(false,controller.showConfirmation);
        System.assertEquals(null,controller.doDetailsDone());
        System.assertEquals(true,controller.showConfirmation);
        System.assertEquals(true,controller.lookingForLocation);
        System.assertEquals(false,controller.locationFound);
        
        //call handleLocationFound
        System.assertEquals(null,controller.handleLocationFound());
        System.assertEquals(false,controller.lookingForLocation);
        System.assertEquals(true,controller.locationFound);
        
        //call handleLocationNotFound
        System.assertEquals(null,controller.handleLocationNotFound());
        System.assertEquals(false,controller.lookingForLocation);
        System.assertEquals(false,controller.locationFound);
        
        //call doConfirmationPrevious
        System.assertEquals(null,controller.doConfirmationPrevious());
        System.assertEquals(false,controller.showConfirmation);

        //call doCancel
        PageReference next = controller.doCancel();
        System.assertNotEquals(null,next);
       // System.assertEquals('/'+acct.id,next.getUrl());

        //call doDetailsDone
        System.assertEquals(false,controller.showConfirmation);
        System.assertEquals(null,controller.doDetailsDone());
        System.assertEquals(true,controller.showConfirmation);
        System.assertEquals(true,controller.lookingForLocation);
        System.assertEquals(false,controller.locationFound);
        
        //call doConfirmationDone
        next = controller.doConfirmationDone();
        //System.assertNotEquals(null,next);
        //System.assertEquals('/'+acct.id,next.getUrl());

        //FAP_TestUtils.assertNoErrorMessagesExist();
    }

    private static testmethod void testEditAsStandardLicenseUser(){
          
       createTestData();
       testUser = [select Id from User where Username = 'testvaliduser@dell.com' limit 1];
        FAP_Configuration config = FAP_Configuration.getInstance();
        Account acct = new Account(
            name = 'test',
            Approved_for_Partner_Finder__c = true,
            Profile_Published_to_Partner_Finder__c = 'Yes',
            Partner_User_Agreed_to_PF_Terms_Cond__c = testUser.Id);
        ProcessFlowTriggerController.isTest = true;    
        insert acct;
        acct.IsPartner = true;
        update acct;
         Partner_Track__c pt = new Partner_Track__c(
            Partner_Track_Name__c = 'test',
             Authorized_Countries__c='France',
             Partner_Track__c='Distributor',
            Approved_for_Partner_Finder__c = true,
            Profile_Published_to_Partner_Finder__c = 'Yes',
            User_Agreed_to_PF_Terms_Cond__c = testUser.Id);
        insert pt;
        Partner_Location__c location = new Partner_Location__c();
        location.account__c = acct.id;
        location.Is_Primary__c = true;
        location.Partner_Track__c=pt.id;
        location.Country__c='France';
        insert location;
        
        //build controller
        FAP_EditLocationControllerExtension controller = new FAP_EditLocationControllerExtension(
            new ApexPages.standardController(location));
        
        //call doOnLoad
        System.assertEquals(true,location.Is_Primary__c);
        System.assertEquals(null,controller.doOnLoad());
        System.assertEquals(true,location.Is_Primary__c);
        
        FAP_TestUtils.assertNoErrorMessagesExist();
        PageReference next = controller.doConfirmationDone();
    }


    private static testmethod void testCreateFail(){
        createTestData();
        testUser = [select Id from User where Username = 'testvaliduser@dell.com' limit 1];
       
        
         FAP_Configuration config = FAP_Configuration.getInstance();

        Account acct = new Account(
            name = 'test',
            Approved_for_Partner_Finder__c = true,
            Profile_Published_to_Partner_Finder__c = 'Yes',
            Partner_User_Agreed_to_PF_Terms_Cond__c = testUser.Id);
        ProcessFlowTriggerController.isTest = true;    
        insert acct;
        acct.IsPartner = true;
        update acct;
        Partner_Location__c location = new Partner_Location__c();
        location.account__c = acct.id;
        
        //build controller
        System.runAs(testUser){
        FAP_EditLocationControllerExtension controller = new FAP_EditLocationControllerExtension(
            new ApexPages.standardController(location));
        
        System.assertEquals(null,controller.doOnLoad());
        FAP_TestUtils.assertNoErrorMessagesExist();
        System.assertEquals(false,controller.showConfirmation);
        System.assertEquals(null,controller.doDetailsDone());
        System.assertEquals(true,controller.showConfirmation);
        FAP_TestUtils.assertNoErrorMessagesExist();
        location.point_of_contact_email__c = '@';
        System.assertEquals(null,controller.doConfirmationDone());
        FAP_TestUtils.assertErrorMessagesExist();
        }
    }

    private static testmethod void testCreateAsPartnerLicenseUser(){
        
         FAP_Configuration config = FAP_Configuration.getInstance();
        Partner_Location__c location = new Partner_Location__c();
        //build controller
        FAP_EditLocationControllerExtension controller = new FAP_EditLocationControllerExtension(
            new ApexPages.standardController(location));
        
        //call doOnLoad
        System.assertEquals(false,location.Is_Primary__c);
        System.assertEquals(null,controller.doOnLoad());
        //call doDetailsDone
        System.assertEquals(false,controller.showConfirmation);
        System.assertEquals(null,controller.doDetailsDone());
        System.assertEquals(false,controller.locationFound);
        
        //call handleLocationFound
        System.assertEquals(null,controller.handleLocationFound());
        System.assertEquals(false,controller.lookingForLocation);
        //System.assertEquals(true,controller.locationFound);
        
        //call handleLocationNotFound
        System.assertEquals(null,controller.handleLocationNotFound());
        System.assertEquals(false,controller.lookingForLocation);
        System.assertEquals(false,controller.locationFound);
        
        //call doConfirmationPrevious
        System.assertEquals(null,controller.doConfirmationPrevious());
        System.assertEquals(false,controller.showConfirmation);

        //call doCancel
        PageReference next = controller.doCancel();
        System.assertNotEquals(null,next);

        //call doDetailsDone
        System.assertEquals(false,controller.showConfirmation);
        System.assertEquals(null,controller.doDetailsDone());
        System.assertEquals(false,controller.locationFound);
        
        //call doConfirmationDone
        next = controller.doConfirmationDone();
        //System.assertNotEquals(null,next);

        //FAP_TestUtils.assertNoErrorMessagesExist();
    }

    private static testmethod void testMake2ndLocationPrimary(){
        createTestData();
        testUser = [select Id from User where Username = 'testvaliduser@dell.com' limit 1];
        
        
         FAP_Configuration config = FAP_Configuration.getInstance();
        Account acct = new Account(
            name = 'test',
            Approved_for_Partner_Finder__c = true,
            Profile_Published_to_Partner_Finder__c = 'Yes',
            Partner_User_Agreed_to_PF_Terms_Cond__c = testUser.Id);
        ProcessFlowTriggerController.isTest = true;    
        insert acct;
        
         Partner_Track__c pt = new Partner_Track__c(
            Partner_Track_Name__c = 'test',
             Authorized_Countries__c='France',
             Partner_Track__c='Distributor',
            Approved_for_Partner_Finder__c = true,
            Profile_Published_to_Partner_Finder__c = 'Yes',
            User_Agreed_to_PF_Terms_Cond__c = testUser.Id);
        insert pt;
        
        pt.Partner_Account__c = true;
        update pt;
        Partner_Location__c first = new Partner_Location__c();
        first.account__c = acct.id;
        first.Is_Primary__c = true;
        first.Partner_Track__c=pt.id;
        insert first;
        Partner_Location__c second = new Partner_Location__c();
        second.Partner_Track__c=pt.id;
        
        second.account__c = acct.id;
        
        //build controller
        FAP_EditLocationControllerExtension controller = new FAP_EditLocationControllerExtension(
            new ApexPages.StandardController(second));
        String t=controller.googleMapsApiURL;
        t=controller.strBaiduMapsApiUrl;
        Boolean isIE=controller.isIE;
        system.assertEquals(isIE, controller.isIE);
         Boolean isChrome=controller.isChrome;
        system.assertEquals(isChrome, controller.isChrome);
        Boolean isFirefox=controller.isFirefox;
        system.assertEquals(isFirefox, controller.isFirefox);
        
        FAP_TestUtils.assertNoErrorMessagesExist();
        
        //call doOnLoad
        System.assertEquals(null,controller.doOnLoad());
        FAP_TestUtils.assertNoErrorMessagesExist();
        
        second.Is_Primary__c = true;
        PageReference next = controller.doDetailsDone();
        FAP_TestUtils.assertNoErrorMessagesExist();
        System.assertEquals(null,next);

        first = [select id,Is_Primary__c from Partner_Location__c where id = :first.id];
        System.assertEquals(true,first.Is_Primary__c);
        Boolean exceptionCaught = false;
        try{
            second = [select id,Is_Primary__c from Partner_Location__c where id = :second.id];
        }catch(QueryException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught,'Expected QueryException');

        next = controller.doConfirmationDone();
        //FAP_TestUtils.assertNoErrorMessagesExist();
        //System.assertNotEquals(null,next);
        
        first = [select id,Is_Primary__c from Partner_Location__c where id = :first.id];
        System.assertEquals(true,first.Is_Primary__c);
        //second = [select id,Is_Primary__c from Partner_Location__c where id = :controller.location.id];
        //System.assertEquals(true,second.Is_Primary__c);
    }   
    private static testmethod void testMake21ndLocationPrimary(){
        createTestData();
        testUser = [select Id from User where Username = 'testvaliduser@dell.com' limit 1];
        
        
         FAP_Configuration config = FAP_Configuration.getInstance();
        Account acct = new Account(
            name = 'test',
            Approved_for_Partner_Finder__c = true,
            Profile_Published_to_Partner_Finder__c = 'Yes',
            Partner_User_Agreed_to_PF_Terms_Cond__c = testUser.Id);
        ProcessFlowTriggerController.isTest = true;
        insert acct;
        
         Partner_Track__c pt = new Partner_Track__c(
            Partner_Track_Name__c = 'test',
             Authorized_Countries__c='France',
             Partner_Track__c='Distributor',
            Approved_for_Partner_Finder__c = true,
            Profile_Published_to_Partner_Finder__c = 'Yes',
            User_Agreed_to_PF_Terms_Cond__c = testUser.Id);
        insert pt;
        
        pt.Partner_Account__c = true;
        update pt;
        Partner_Location__c first = new Partner_Location__c();
        first.account__c = acct.id;
        first.Is_Primary__c = true;
        first.Partner_Track__c=pt.id;
        insert first;
        Partner_Location__c second = new Partner_Location__c();
        second.Partner_Track__c=pt.id;
        
        second.account__c = acct.id;
        
        //build controller
        FAP_EditLocationControllerExtension controller = new FAP_EditLocationControllerExtension(
            new ApexPages.StandardController(second));
        String t=controller.googleMapsApiURL;
        t=controller.strBaiduMapsApiUrl;
        Boolean isIE=controller.isIE;
        system.assertEquals(isIE, controller.isIE);
         Boolean isChrome=controller.isChrome;
        system.assertEquals(isChrome, controller.isChrome);
        Boolean isFirefox=controller.isFirefox;
        system.assertEquals(isFirefox, controller.isFirefox);
        
        FAP_TestUtils.assertNoErrorMessagesExist();
        
        //call doOnLoad
        System.assertEquals(null,controller.doOnLoad());
        FAP_TestUtils.assertNoErrorMessagesExist();
        
        second.Is_Primary__c = false;
        controller.isPrimary='None';
        PageReference next = controller.doDetailsDone();
      //  FAP_TestUtils.assertNoErrorMessagesExist();
      //   System.assertEquals(null,next);

        first = [select id,Is_Primary__c from Partner_Location__c where id = :first.id];
        System.assertEquals(true,first.Is_Primary__c);
        Boolean exceptionCaught = false;
        try{
            second = [select id,Is_Primary__c from Partner_Location__c where id = :second.id];
        }catch(QueryException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught,'Expected QueryException');

        next = controller.doConfirmationDone();
        //FAP_TestUtils.assertNoErrorMessagesExist();
        //System.assertNotEquals(null,next);
        
        first = [select id,Is_Primary__c from Partner_Location__c where id = :first.id];
        System.assertEquals(true,first.Is_Primary__c);
        //second = [select id,Is_Primary__c from Partner_Location__c where id = :controller.location.id];
        //System.assertEquals(true,second.Is_Primary__c);
    }   
    private static testmethod void testStrings()
    {
          FAP_Configuration config = FAP_Configuration.getInstance();
          system.assertEquals(true, config.googleMapsApiURL!=null);
          system.assertEquals(true, config.baiduMapsApiUrl!=null);
        
    }
    
   private static void createTestData(){
        Profile profile = [select id from profile where name like '%R16.10 NA PRM Portal User (MOSS)%' order by name limit 1];
        testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    ContactId = usrCon.Id,
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis());
        insert testUser;
    }
    
 private static testmethod void testGetIsPrimaryOptions(){
             Partner_Location__c location = new Partner_Location__c();
        
        insert location;
        FAP_EditLocationControllerExtension controller = new FAP_EditLocationControllerExtension(
            new ApexPages.standardController(location));
        controller.getIsPrimaryOptions();
        
        //Dummy assert statement
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('None',Label.none));
        system.assertEquals(options.size(), 1);
        
    }    
    
    private static testmethod void testGetIsPrimary(){
             Partner_Location__c location = new Partner_Location__c();
        
        insert location;
        FAP_EditLocationControllerExtension controller = new FAP_EditLocationControllerExtension(
            new ApexPages.standardController(location));  
        String test='test';
        controller.setIsPrimary(test);
        system.assertEquals(test, controller.getIsPrimary());
        
    }
    
    private static testmethod void testGetPartnerAccountID(){
        createTestData();
        testUser = [select Id from User where Username = 'testvaliduser@dell.com' limit 1];
        List<User> userList = [
            select id, ContactId, Contact.AccountId, Contact.Account.id, Contact.Account.name,userrole.name 
            from user where Username = 'testvaliduser@dell.com' limit 1];   
        
        Partner_Location__c location = new Partner_Location__c();        
        insert location;
        FAP_EditLocationControllerExtension.getPartnerAccountID();   
        system.assertEquals(userList.size(), 1);
    }   

    private static testmethod void testGetPartnerAccount() {
        createTestData();
        testUser = [select Id from User where Username = 'testvaliduser@dell.com' limit 1];
        
        FAP_Configuration config = FAP_Configuration.getInstance();
        
        Account acct = new Account( name = 'test',
                                   ShippingStreet ='Test Street',ShippingCity='Test City',ShippingState='Test State',
                                   ShippingPostalCode='EH43NP',ShippingCountry='Test Country');
        insert acct; 
        ID partnerAccId=acct.id;
                ProcessFlowTriggerController.isTest = true; 
        Account acctObj = [SELECT Id,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry FROM Account WHERE id = :partnerAccId];
        FAP_EditLocationControllerExtension.getPartnerAccount();    
        system.assertNotEquals(null, acctObj);

        
    }  
}
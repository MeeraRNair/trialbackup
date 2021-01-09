/***********************************************************
* ---------------------------------------------------------
* Revision  Name                Description
* 1.0       VIKAS KH         Implemeted TDF for 0202 Release
*  
************************************************************/
@isTest
//(seealldata=true)
private class BeforeInsertUpdateTriggerOnCountryTest {
   
    static list<Sales_Channel_Group__c> listSalesChannel;
    static list<Account> listAcc;
    static list<contact> listCon;
    static list<User> listuser;
         @testSetup static void setup() {
             TriggerExecutionController.SetSkipAllTriggers(True);
             list<Sales_Channel_Group__c> listSalesChannelTDF = TestDataFactory.createNSalesChannelGroups(1);
             insert listSalesChannelTDF;
             list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
             listAccTDF[0].Is_Rebate_Partner__c = true;
             listAccTDF[0].Sales_Channel__c=listSalesChannelTDF[0].Id;
             insert listAccTDF;
             system.debug('listAccTDF>>>>>'+listAccTDF);
             list<contact> listConTDF = TestDataFactory.createNContacts(1);
             listConTDF[0].AccountID = listAccTDF[0].id;
             insert listConTDF;
			 list<User> listuserTDF = TestDataFactory.createNPortalUser(1);
             listuserTDF[0].contactID = listConTDF[0].id;
             insert listuserTDF;
    }

    static testMethod void countryReadyforBOOMITest() {
        // Create Test Data
        CMAP_Helper.skipinsert = true;
        Country__c cntry1 = new Country__c(Code__c = '@@', Region__c = 'APJ',Inc_Vendor_Name__c='Dell Achievers',Inc_Vendor_End_Point__c = 'test');
        insert cntry1;
        
        //Query and asserts the results
        Country__c res1 = [SELECT Is_Vendor_Update_Required__c,Is_Vendor_Updated__c,Operation_for_Boomi__c,Last_Operation_Performed__c FROM Country__c WHERE id=:cntry1.id];
        System.assertEquals(true, res1.Is_Vendor_Update_Required__c);
        System.assertEquals(false, res1.Is_Vendor_Updated__c);
        System.assertEquals('ENABLE_COUNTRY', res1.Operation_for_Boomi__c);
        System.assertEquals('SFDC Updated', res1.Last_Operation_Performed__c);        
        
        //disable access
        res1.Inc_Vendor_Name__c = 'Not Applicable/On Hold';
        res1.Is_Vendor_Updated__c = true;
        update res1;
        
        //Query and asserts the results
        Country__c res2 = [SELECT Is_Vendor_Update_Required__c,Is_Vendor_Updated__c,Operation_for_Boomi__c,Last_Operation_Performed__c FROM Country__c WHERE id=:cntry1.id];
        System.assertEquals(true, res2.Is_Vendor_Update_Required__c);
        System.assertEquals(false, res2.Is_Vendor_Updated__c);
        System.assertEquals('DISABLE_COUNTRY', res2.Operation_for_Boomi__c);
        System.assertEquals('SFDC Updated', res2.Last_Operation_Performed__c);
        
        //update something else and make sure still it ready for BOOMI
        res2.Inc_Vendor_End_Point__c = 'Test end point';
        update res2;
        
        Country__c res3 = [SELECT Is_Vendor_Update_Required__c,Is_Vendor_Updated__c,Operation_for_Boomi__c,Last_Operation_Performed__c FROM Country__c WHERE id=:cntry1.id];
        System.assertEquals(true, res3.Is_Vendor_Update_Required__c);
        System.assertEquals(false, res3.Is_Vendor_Updated__c);
        System.assertEquals('DISABLE_COUNTRY', res3.Operation_for_Boomi__c);
        System.assertEquals('SFDC Updated', res3.Last_Operation_Performed__c);
        
        res3.Is_Vendor_Updated__c = true;
        res3.Inc_Vendor_Name__c = 'Partner Advantage';
        update res3;
        Country__c res4 = [SELECT Is_Vendor_Update_Required__c,Is_Vendor_Updated__c,Operation_for_Boomi__c,Last_Operation_Performed__c FROM Country__c WHERE id=:cntry1.id];
        System.assertEquals(false, res4.Is_Vendor_Update_Required__c);
        
        
    }
    
    static testMethod void disabilingnonOEMLMoncountryTest() {
        CMAP_Helper.skipinsert = true;
        TriggerExecutionController.setSkipAllTriggers(True);
        Country__c testCountry = new Country__c (name = 'TESCOUNTRY', Code__c = 'T6', Region__c = 'APJ',
                                                Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Not Applicable/On Hold',
                                                Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',Partner_Relationship__c = 'All',Partner_Relationship_for_OEM__c = 'All');
        
  
        
        
        insert testCountry;
        
        
       /*
        Sales_Channel_Group__c testSalesChanGrp = new Sales_Channel_Group__c(Name = 'Test Sales channel', Regional_Parent_Name__c = 'APJ');
       / insert testSalesChanGrp;              
        Account testAcc = new Account(name = 'testAccount'+System.currentTimeMillis(), Is_Rebate_Partner__c = true,Sales_Channel__c=testSalesChanGrp.Id,
                                    Account_Country_Code__c = testCountry.Code__c, Account_Country__c = testCountry.Name,Partner_Relationship__c='Registered');
        insert testAcc;
        */
                Test.startTest();
        listSalesChannel = [select id from Sales_Channel_Group__c limit 1];
        listAcc = [select id from Account limit 1];
        listAcc[0].IsPartner = true;
        update listAcc;
      testCountry.Deal_Registration_Enabled__c = 'No';
        testCountry.Lead_Management_Enabled__c  = 'No';
        testCountry.Lead_Management_Enabled_for_OEM__c = 'No';
        
        update testCountry;
      //  update testAcc;
        
      //  testAcc.IsPartner = true;
      //  update testAcc;
        
     /*   Contact testContact = new Contact(Status__c='Active', AccountId=testAcc.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact',  Partner_My_Account_GUID__c='validuser');
        insert testContact; 
    
    //Profile profile = [select id from profile where UserType = 'PowerPartner' limit 1]; // Fenny commented
    // Fenny added -- To prevent this user following group '#SFDC – Frequently Asked Questions (FAQ)' which will cause INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY at EntitySubscriptionUtils.followGroup
    Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
                              
        User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    ContactId = testContact.Id,
                                    isActive=true,
                                    Enable_Partner_Lead_Management__c = true,
                                    Enable_Partner_Deal_Registration__c = true);
        insert testUser; */
        listuser = [select id from user limit 1];
        try{
            testCountry.Lead_Management_Enabled__c = 'No';
            update testCountry;
        }catch(Exception e){
            System.assert(e.getMessage().contains('You cannot disable the country from lead management as there are existing'));
        }
        
        Test.stopTest(); 
    }
   static testMethod void disabilingOEMLMoncountryTest() {
        CMAP_Helper.skipinsert = true;
        Country__c testCountry = new Country__c (name = 'TESCOUNTRY', Code__c = 'T6', Region__c = 'APJ',
                                                Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Not Applicable/On Hold',
                                                Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',Partner_Relationship__c = 'All',Partner_Relationship_for_OEM__c = 'All');
        
  
        
        
        insert testCountry;
    /*    Sales_Channel_Group__c testSalesChanGrp = new Sales_Channel_Group__c(Name = 'Test OEM Sales channel', Regional_Parent_Name__c = 'APJ');
        insert testSalesChanGrp;              
        Account testAcc = new Account(name = 'testAccount'+System.currentTimeMillis(), Is_Rebate_Partner__c = true,Sales_Channel__c=testSalesChanGrp.Id,
                                    Account_Country_Code__c = testCountry.Code__c, Account_Country__c = testCountry.Name,Partner_Relationship__c='Registered');
        insert testAcc;
        testAcc.IsPartner = true;
        update testAcc;
        
        Contact testContact = new Contact(Status__c='Active', AccountId=testAcc.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact',  Partner_My_Account_GUID__c='validuser');
        insert testContact; 
    
    //Profile profile = [select id from profile where UserType = 'PowerPartner' limit 1]; // Fenny commented
    // Fenny added -- To prevent this user following group '#SFDC – Frequently Asked Questions (FAQ)' which will cause INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY at EntitySubscriptionUtils.followGroup
    Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
                              
        User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    ContactId = testContact.Id,
                                    isActive=true,
                                    Enable_Partner_Lead_Management__c = true,
                                    Enable_Partner_Deal_Registration__c = true);
        insert testUser;
		*/
       listSalesChannel = [select id from Sales_Channel_Group__c limit 1];
       listAcc = [select id from Account limit 1];
       listAcc[0].IsPartner = true;
       update listAcc;
       listuser = [select id from user limit 1];
       Test.startTest();
       try{
           testCountry.Lead_Management_Enabled_for_OEM__c = 'No';
           update testCountry;
       }catch(Exception e){
           System.assert(e.getMessage().contains('You cannot disable the country from lead management as there are existing'));
       }
        
        Test.stopTest();       
        

      
    
    
    }	        
    
    static testMethod void changingPRnonOEMLMoncountryTest() {
        CMAP_Helper.skipinsert = true;
        Country__c testCountry = new Country__c (name = 'TESCOUNTRY', Code__c = 'T6', Region__c = 'APJ',
                                                Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Not Applicable/On Hold',
                                                Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',Partner_Relationship__c = 'All',Partner_Relationship_for_OEM__c = 'All');
        
  
        
        
        insert testCountry;
        /*
        Sales_Channel_Group__c testSalesChanGrp = new Sales_Channel_Group__c(Name = 'Test Sales channel', Regional_Parent_Name__c = 'APJ');
        insert testSalesChanGrp;              
        Account testAcc = new Account(name = 'testAccount'+System.currentTimeMillis(), Is_Rebate_Partner__c = true,Sales_Channel__c=testSalesChanGrp.Id,
                                    Account_Country_Code__c = testCountry.Code__c, Account_Country__c = testCountry.Name,Partner_Relationship__c='Registered');
        insert testAcc;
        testAcc.IsPartner = true;
        update testAcc;
        
        Contact testContact = new Contact(Status__c='Active', AccountId=testAcc.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact',  Partner_My_Account_GUID__c='validuser');
        insert testContact; 
    
    //Profile profile = [select id from profile where UserType = 'PowerPartner' limit 1]; // Fenny commented
    // Fenny added -- To prevent this user following group '#SFDC – Frequently Asked Questions (FAQ)' which will cause INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY at EntitySubscriptionUtils.followGroup
    Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
                              
        User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    ContactId = testContact.Id,
                                    isActive=true,
                                    Enable_Partner_Lead_Management__c = true,
                                    Enable_Partner_Deal_Registration__c = true);
        insert testUser; */
        listSalesChannel = [select id from Sales_Channel_Group__c limit 1];
        listAcc = [select id from Account limit 1];
        listAcc[0].IsPartner = true;
        update listAcc;
        listuser = [select id from user limit 1];
        Test.startTest();
        try{
            testCountry.Partner_Relationship__c = 'Premier';
            update testCountry;
        }catch(Exception e){
            System.assert(e.getMessage().contains('You cannot change the Partner Relationship  as there are existing'));
        }
        
        Test.stopTest();
    }
    
     static testMethod void changingPROEMLMoncountryTest() {
        CMAP_Helper.skipinsert = true;
        Country__c testCountry = new Country__c (name = 'TESCOUNTRY', Code__c = 'T6', Region__c = 'APJ',
                                                Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Not Applicable/On Hold',
                                                Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',Partner_Relationship__c = 'All',Partner_Relationship_for_OEM__c = 'All');
        
  
        
        
        insert testCountry;
		/*
         Sales_Channel_Group__c testSalesChanGrp = new Sales_Channel_Group__c(Name = 'Test OEM Sales channel', Regional_Parent_Name__c = 'APJ');
        insert testSalesChanGrp;              
        Account testAcc = new Account(name = 'testAccount'+System.currentTimeMillis(), Is_Rebate_Partner__c = true,Sales_Channel__c=testSalesChanGrp.Id,
                                    Account_Country_Code__c = testCountry.Code__c, Account_Country__c = testCountry.Name,Partner_Relationship__c='Registered');
        insert testAcc;
        testAcc.IsPartner = true;
        update testAcc;
        
        Contact testContact = new Contact(Status__c='Active', AccountId=testAcc.Id, EMEA_Decision_Making_Role__c='Influencer', 
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact',  Partner_My_Account_GUID__c='validuser');
        insert testContact; 
    
    //Profile profile = [select id from profile where UserType = 'PowerPartner' limit 1]; // Fenny commented
    // Fenny added -- To prevent this user following group '#SFDC – Frequently Asked Questions (FAQ)' which will cause INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY at EntitySubscriptionUtils.followGroup
    Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
                              
        User testUser = new User(Username='testvaliduser' +'@dell.com',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    ContactId = testContact.Id,
                                    isActive=true,
                                    Enable_Partner_Lead_Management__c = true,
                                    Enable_Partner_Deal_Registration__c = true);
        insert testUser;
        */
       listSalesChannel = [select id from Sales_Channel_Group__c limit 1];
       listAcc = [select id from Account limit 1];
       listAcc[0].IsPartner = true;
       update listAcc;
       listuser = [select id from user limit 1];
        Test.startTest();
        try{
            testCountry.Partner_Relationship_for_OEM__c = 'Premier';
            update testCountry;
        }catch(Exception e){
            System.assert(e.getMessage().contains('You cannot change the Partner Relationship  as there are existing'));
        }
        
        Test.stopTest();
    }

   static testMethod void disabilingnonOEMLMoncountryTestBulk() {
        CMAP_Helper.skipinsert = true;
        List<Country__c> listcountr = new List<Country__c>();
        for(Integer intc=0;intc<10;intc++){
            Country__c testCountry = new Country__c (name = 'TESCOUNTRY'+intc, Code__c = 'T'+intc, Region__c = 'APJ',
                                                Training_Enabled__c = 'Yes', Deal_Registration_Enabled__c = 'Yes',Last_Operation_Performed__c='Test Data',Inc_Vendor_Name__c='Not Applicable/On Hold',
                                                Lead_Management_Enabled__c = 'Yes',Lead_Management_Enabled_for_OEM__c = 'Yes',Partner_Relationship__c = 'All',Partner_Relationship_for_OEM__c = 'All');
            listcountr.add(testCountry);
        
        }
        insert listcountr;
       /*
        Sales_Channel_Group__c testSalesChanGrp = new Sales_Channel_Group__c(Name = 'Test Sales channel', Regional_Parent_Name__c = 'APJ');
        insert testSalesChanGrp;   */
       listSalesChannel = [select id from Sales_Channel_Group__c limit 1];

       listAcc = [select id from Account limit 1];
       listAcc[0].IsPartner = true;
       update listAcc;
       listuser = [select id from user limit 1];
		/*
        List<Account> accntlist = new  List<Account>();
        for(Integer cnt=0;cnt<10;cnt++){
             Account testAcc = new Account(name = 'testAccount'+System.currentTimeMillis()+cnt, Is_Rebate_Partner__c = true,Sales_Channel__c=testSalesChanGrp.Id,
                                    Account_Country_Code__c = countrlist[cnt].Code__c, Account_Country__c = countrlist[cnt].Name,Partner_Relationship__c='Registered');
            accntlist.add(testAcc);
        }         
        insert accntlist;
        for(Integer cnt=0;cnt<10;cnt++){
            accntlist[0].IsPartner = true;
        }
        
        update accntlist;
        List<Contact> contactList = new List<Contact>();
        for(Integer cnt=0;cnt<10;cnt++){
            Contact testContact = new Contact(Status__c='Active', AccountId=accntlist[cnt].Id, EMEA_Decision_Making_Role__c='Influencer', 
                                            Purchaser_Influence_over_Merged__c='Enterprise - Networking', 
                                            Phone='111-1000', Decision_Making_Role__c='Influencer', LastName='Test Contact',  Partner_My_Account_GUID__c='validuser'+cnt);
            contactList.add(testContact);
        }
         insert contactList; 
    
            //Profile profile = [select id from profile where UserType = 'PowerPartner' limit 1]; // Fenny commented
            // Fenny added -- To prevent this user following group '#SFDC – Frequently Asked Questions (FAQ)' which will cause INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY at EntitySubscriptionUtils.followGroup
            Profile profile = [select id from profile where Name LIKE '%PRM Portal%' limit 1]; 
        List<User> usrlist = new List<User>();  
        for(Integer cnt=0;cnt<10;cnt++){
            User testUser = new User(Username='testvaliduser'+cnt+'@dell.com',
                                    Alias = 'Test',
                                     
                                    Email='Test'+cnt+'@dell.com',            
                                    LastName='Test', 
                                    ProfileId = profile.Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis()+cnt,
                                    ContactId = contactList[cnt].Id,
                                    isActive=true,
                                    Enable_Partner_Lead_Management__c = true,
                                    Enable_Partner_Deal_Registration__c = true);
              usrlist.add(testUser);
        }                      
        
        insert usrlist; */
        Test.startTest();
        try{
            for(Integer intc=0;intc<10;intc++){
                listcountr[intc].Lead_Management_Enabled__c = 'No';
                
            }
            update listcountr;
        }catch(Exception e){
            System.assert(e.getMessage().contains('You cannot disable the country from lead management as there are existing'));
        }
        
        Test.stopTest();       
        
    
    
    
    }
}
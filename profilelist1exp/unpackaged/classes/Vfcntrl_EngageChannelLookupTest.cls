/*****************************************************************************************************************
* Name          : Vfcntrl_EngageChannelLookupTest
* Description   : Test Class for Vfcntrl_EngageChannelLookup
* -----------------------------------------------------------
* Revision     Name              Date           CR         Release No            Description
* 1.0         Yeswanth          29.06.2016 
* 2.0         Srikanth          06.07.2016
* 3.0         Jatin             04-08-2018     16018        Fy-19-DCS-0802        Commented NET exam logic statements as part of NET003 story
*             Venugopalachary k 26-Sep-2018                                       Implement Test Data Factory                      		     
******************************************************************************************************************/
@isTest
public class Vfcntrl_EngageChannelLookupTest {
    static list<Account> listAcc;
    static list<opportunity> listOpp=new list<opportunity>();
    @testSetup static void setup() {
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        insert owdSetting;
        List<Account> listAccfromFactory=TestDataFactory.createNAccount(3, 'Partner Account');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listAccfromFactory;
        List<Opportunity> listOppFromFactory=TestDataFactory.createNOpportunities(1, 'Channel Opportunity');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listOppFromFactory;
    }   
    Static testmethod void testPartnerAccountSelection(){
        triggerexecutioncontroller.setSkipAllTriggers(True);
        Partner_Request__c partnerReq = createPartnerRequest();
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Purchase_Path__c='Distribution';
        insert testPartnerTrackObj;
        listAcc=[select id from account Limit 2];
        for(Account acc : listAcc){
            acc.Name='partnerAccount'; 
            acc.Partner_Type__c = 'Test';
            acc.Status__c = 'Active';
            acc.DMU__c = false;
            acc.Partner_Track__c=testPartnerTrackObj.id;        
            acc.Partner_Registration__c = partnerReq.Id;
        }
        listAcc[1].RecordtypeID=getRecordTypeIdbyName('End-User Account','Account');
        update listAcc;
        system.assertNotEquals(listAcc[0], null);
        Contact newContSearch = new Contact(FirstName = 'My Search33',
                                            LastName = 'Contact33',
                                            AccountId =listAcc[1].Id,
                                            Status__c  =  'Marketing Suspect',
                                            Email = 'MyLastName@dell.com',
                                            Fax = '12345673',
                                            MobilePhone = '09876543',
                                            Last_Operation_Performed__c = 'testing',
                                            Phone = '12345003');
        insert newContSearch;
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        UserRole userRoleRec = [Select PortalAccountId, Name, Id From UserRole where name like '%WW_Exec' Limit 1];
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com.sit',
                                    Alias = 'MTU9', 
                                    Email='MyLastName@dell.com',         
                                    FirstName='MyTestUser9', 
                                    LastName='MyTestUser9',  
                                    ProfileId = partnerProfiles.get(0).Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test1236', 
                                    isActive = true,
                                    UserRole = userRoleRec,
                                    Enable_Partner_Admin__c = true,
                                    Enable_Partner_Deal_Registration__c = true,
                                    ContactId = newContSearch.Id);
        insert partnerUser;
        listOpp=[select id from Opportunity];
        listOpp[0].AccountId=listAcc[1].id;
        listOpp[0].Distributor_Reseller_Name__c = listAcc[1].Id;
        listOpp[0].Primary_Product_Delivery_Address_Country__C = 'INDIA';
        listOpp[0].Primary_Product_Delivery_Address_Region__c = 'APJ';
        listOpp[0].Distributor_Name__c = 'Distribution';
        listOpp[0].Distributor_ID__c = 'Test Disti User';
        update listOpp;
        PageReference pageRef = Page.EngageChannelLookup;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(listOpp[0]);
        ApexPages.currentPage().getParameters().put('Id',listOpp[0].id);
        Vfcntrl_EngageChannelLookup engageChannelpage = new Vfcntrl_EngageChannelLookup(sc);          
        engageChannelpage.getaccountCountries();
        engageChannelpage.accountCountry ='UNITED STATES';
        engageChannelpage.accName = 'Name';
        engageChannelpage.searchString = 'partner';
        engageChannelpage.fetchResults();
        engageChannelpage.accName = 'Affinity';
        engageChannelpage.searchString = '9876543210';
        engageChannelpage.fetchResults();
        engageChannelpage.accName = 'Email';
        engageChannelpage.searchString = 'MyLastName';
        engageChannelpage.fetchResults();
        System.currentPagereference().getParameters().put('selectedAccId', listAcc[0].Id);
        engageChannelpage.fetchPartnerContacts();
        engageChannelpage.searchString = '';
        engageChannelpage.fetchResults();
        engageChannelpage.searchString = 'Te';
        engageChannelpage.fetchResults();
        engageChannelpage.accName = 'Affinity';
        engageChannelpage.searchString = 'Test';
        engageChannelpage.fetchResults();
        engageChannelpage.accName = 'Email';
        engageChannelpage.searchString = '.com';
        engageChannelpage.fetchResults();
        engageChannelpage.redirectToDealEditPage();  
        System.currentPagereference().getParameters().put('selectedAccId', listAcc[0].Id);
        engageChannelpage.fetchPartnerContacts();
        Engagechannelpage.cancelFunction();
        System.currentPagereference().getParameters().put('selectedContUserId', newContSearch.Id);
        engageChannelpage.redirectToDealEditPage();
    }
    static Partner_Request__c createPartnerRequest(){
        Account testAccount = new Account(
            name='Test 1',
            Account_Country_Code__c = 'AI',
            Account_Country__c = 'ANGUILIA',            
            Account_ID__c =''+System.currentTimeMillis()
        );
        insert testAccount;
        Country__c testCountry = new Country__c(
            Name = 'TestCountry',
            Code__c = 'TY',
            User_Currency_Iso_Code__c = 'INR',
            Region__c = 'APJ');
        insert testCountry;
        //Create User
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];        
        User userRecord = new User(
            Username='testUser'+System.currentTimeMillis()+'@test.com',
            Alias = 'test', 
            Email='test@dell.com', 
            FirstName='Tfirst', 
            LastName='TLast',
            ProfileId = userProfile.Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='TEST12345'
        );
        insert userRecord;
        Partner_Request__c request = new Partner_Request__c();
        request.Account__c = testAccount.id;
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
                                                             'Partner_Request__c', true);
        request.email__c = 'test@dell.com';
        request.Export_Compliance_Agreed__c = true;
        request.Partner_Terms_Conditions__c = true;
        request.Other_Customers__c = 'test1';
        request.Preferred_Dell_Distribution_Partner__c = 'Test prefer';
        request.Feature_Request_Deal_Registration__c = true;
        request.Org_Country__c = testCountry.id;
        request.Website__c = 'website';     
        request.Org_Address_1__c =  'Address 1';
        request.Org_Address_2__c = 'Address 2';
        request.Org_Address_3__c =  'Address 3';
        request.Org_City__c = 'city';
        request.Org_State__c = 'state';
        request.Org_Postal_Code__c = 'postalcode';      
        request.Address_Line_1__c = 'Address 1';
        request.Address_Line_2__c = 'Address 2';
        request.Address_Line_3__c = 'Address 3';
        request.City__c = 'city';
        request.State__c = 'state';
        request.Postal_Code__c = 'postalcode';
        request.Last_Name__c = 'Test Last Name';
        request.Country__c = testCountry.id;
        request.OwnerId = userRecord.Id;
        insert request;
        return request;
    }
    Static testmethod void partnerAccountSelection(){
        triggerexecutioncontroller.setSkipAllTriggers(True);
        Partner_Request__c partnerReq = createPartnerRequest();
        listAcc=[select id from account limit 2];
        for(Account acc : listAcc){
            acc.Name='partnerAccount'; 
            acc.Partner_Type__c = 'Test';
            acc.Status__c = 'Active';
            acc.DMU__c = false;
            acc.Partner_Registration__c = partnerReq.Id;
        }
        listAcc[1].RecordtypeID=getRecordTypeIdbyName('End-User Account','Account');
        update listAcc;
        Contact newContSearch = new Contact(FirstName = 'My Search33',
                                            LastName = 'Contact33',
                                            AccountId =listAcc[1].Id,
                                            Status__c  =  'Marketing Suspect',
                                            Email = 'MyLastName@dell.com',
                                            Fax = '12345673',
                                            MobilePhone = '09876543',
                                            Last_Operation_Performed__c = 'testing',
                                            Phone = '12345003');
        insert newContSearch;
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        UserRole userRoleRec = [Select PortalAccountId, Name, Id From UserRole where name like '%WW_Exec' Limit 1];
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                    Alias = 'MTU9', 
                                    Email='MyLastName@dell.com',         
                                    FirstName='MyTestUser9', 
                                    LastName='MyTestUser9',  
                                    ProfileId = partnerProfiles.get(0).Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test1234', 
                                    isActive = false,
                                    UserRole = userRoleRec,
                                    Enable_Partner_Admin__c = true,
                                    Enable_Partner_Deal_Registration__c = true,
                                    ContactId = newContSearch.Id);
        insert partnerUser;
        listOpp=[select id from Opportunity];
        listOpp[0].AccountId=listAcc[1].id;
        listOpp[0].Distributor_Reseller_Name__c = listAcc[1].Id;
        listOpp[0].Primary_Product_Delivery_Address_Country__C = 'INDIA';
        listOpp[0].Primary_Product_Delivery_Address_Region__c = 'APJ';
        listOpp[0].Distributor_Name__c = 'Distribution';
        listOpp[0].Distributor_ID__c = 'Test Disti User';
        update listOpp;
        system.assertNotEquals(listOpp[0].id, null);
        PageReference pageRef = Page.EngageChannelLookup;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(listOpp[0]);
        ApexPages.currentPage().getParameters().put('Id',listOpp[0].id);
        Vfcntrl_EngageChannelLookup engageChannelpage = new Vfcntrl_EngageChannelLookup(sc);          
        engageChannelpage.getaccountCountries();
        System.currentPagereference().getParameters().put('selectedAccId', listAcc[0].Id);
        engageChannelpage.fetchPartnerContacts();
        System.currentPagereference().getParameters().put('selectedContUserId', newContSearch.Id);
        engageChannelpage.redirectToDealEditPage();
    }
    Static testmethod void testPartnerAccountSelectionNew(){
        triggerexecutioncontroller.setSkipAllTriggers(True);
        Partner_Request__c partnerReq = createPartnerRequest();
        listAcc=[select id from account];
        for(Account acc : listAcc){
            acc.Name='partnerAccount'; 
            acc.Partner_Type__c = 'Test';
            acc.Status__c = 'Active';
            acc.DMU__c = false;
            acc.Partner_Registration__c = partnerReq.Id;
        }
        listAcc[1].RecordtypeID=getRecordTypeIdbyName('End-User Account','Account');
        listAcc[2].RecordtypeID=getRecordTypeIdbyName('End-User Account','Account');
        update listAcc;
        Contact newContSearch = new Contact(FirstName = 'My Search33',
                                            LastName = 'Contact33',
                                            //AccountId =searchResultAccount.Id,
                                            AccountId =listAcc[2].Id,
                                            Status__c  =  'Marketing Suspect',
                                            Email = 'MyLastName@dell.com',
                                            Fax = '12345673',
                                            MobilePhone = '09876543',
                                            Last_Operation_Performed__c = 'testing',
                                            Phone = '12345003');
        insert newContSearch;
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com',
                                    Alias = 'MTU9', 
                                    Email='MyLastName@dell.com',         
                                    FirstName='MyTestUser9', 
                                    LastName='MyTestUser9',  
                                    ProfileId = partnerProfiles.get(0).Id, 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test1237', 
                                    isActive = true,
                                    Enable_Partner_Admin__c = true,
                                    Enable_Partner_Deal_Registration__c = true,
                                    ContactId = newContSearch.Id);
        insert partnerUser;
        listOpp=[select id from Opportunity];
        listOpp[0].AccountId=listAcc[1].id;
        listOpp[0].Distributor_Reseller_Name__c = listAcc[1].Id;
        listOpp[0].Primary_Product_Delivery_Address_Country__C = 'INDIA';
        listOpp[0].Primary_Product_Delivery_Address_Region__c = 'APJ';
        listOpp[0].Distributor_Name__c = 'Distribution';
        listOpp[0].Distributor_ID__c = 'Test Disti User';
        update listOpp;
        system.assertNotEquals(listOpp[0].id, null);
        PageReference pageRef = Page.EngageChannelLookup;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(listOpp[0]);
        ApexPages.currentPage().getParameters().put('Id',listOpp[0].id);
        Vfcntrl_EngageChannelLookup engageChannelpage = new Vfcntrl_EngageChannelLookup(sc);          
        engageChannelpage.getaccountCountries();
        engageChannelpage.accountCountry ='UNITED STATES';
        engageChannelpage.accName = 'Name';
        engageChannelpage.searchString = 'partner';
        engageChannelpage.fetchResults();
        engageChannelpage.accName = 'Affinity';
        engageChannelpage.searchString = '9876543210';
        engageChannelpage.fetchResults();
        engageChannelpage.accName = 'Email';
        engageChannelpage.searchString = 'MyLastName';
        engageChannelpage.fetchResults();
        System.currentPagereference().getParameters().put('selectedAccId', listAcc[0].Id);
        engageChannelpage.fetchPartnerContacts();
        engageChannelpage.searchString = '';
        engageChannelpage.fetchResults();
        engageChannelpage.searchString = 'Te';
        engageChannelpage.fetchResults();
        engageChannelpage.accName = 'Affinity';
        engageChannelpage.searchString = 'Test';
        engageChannelpage.fetchResults();
        engageChannelpage.accName = 'Email';
        engageChannelpage.searchString = '.com';
        engageChannelpage.fetchResults();
        engageChannelpage.redirectToDealEditPage();  
        System.currentPagereference().getParameters().put('selectedAccId', listAcc[0].Id);
        engageChannelpage.fetchPartnerContacts();
        engageChannelpage.cancelFunction();
        System.currentPagereference().getParameters().put('selectedContUserId', newContSearch.Id);
        engageChannelpage.redirectToDealEditPage();
        Vfcntrl_EngageChannelLookup.wrapContacts csd=new Vfcntrl_EngageChannelLookup.wrapContacts();
        csd.contactName='TestAcc';
        csd.contactAccName='TestAcc';
        csd.contactPhone='TestAcc';
        csd.contactMobilePhone='TestAcc';
        csd.contactEmail='TestAcc';
        csd.contactTitle='TestAcc';
    }
    public static Id getRecordTypeIdbyName(String strRecordTypeName,String strobjectName){
        return  Schema.getGlobalDescribe().get(strobjectName).getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
    }
}
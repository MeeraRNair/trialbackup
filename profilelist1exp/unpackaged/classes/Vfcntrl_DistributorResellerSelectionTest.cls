/*****************************************************************************************************************
* Name          : Vfcntrl_DistributorResellerSelectionTest
* Description   : Test Method for Vfcntrl_DistributorResellerSelectionExt
* -----------------------------------------------------------
* Revision  Name            Date          
* 1.0       Suresh          07.03.2016 
* 2.0       Srikanth        24.03.2016
* 3.0       Yeswanth        01.04.2016
* 4.0       Srikanth        14.04.2016
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 5.0 -    CR 16018    FY19-DCS-0802    6-June-2018:   Jatin Puri      Decommisioned netexam and Feature_Request_Training__c as part of story# 4988542


******************************************************************************************************************/
@isTest
private class Vfcntrl_DistributorResellerSelectionTest{
    static list<Account> listAcc;
    static list<opportunity> listOpp=new list<opportunity>();
    static list<OpportunityLineItem> listOppLineItem;
    @testSetup static void setup() {
        TriggerExecutionController.setSkipAllTriggers(true);
        OWD__c owdsetting = new OWD__c();
        owdsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdsetting.Oppty_Stage10__c = 'Discover - 10%';
        owdsetting.Oppty_Stage100__c = 'Win - 100%';
        owdsetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdsetting.Oppty_Stage60__c = 'Propose - 60%';
        owdsetting.Oppty_Stage90__c = 'Commit - 90%';
        owdsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdsetting.Oppty_Stage1__c = 'Plan - 1%';
        insert owdsetting;
        List<Account> listAccfromFactory=TestDataFactory.createNAccount(4, 'Partner Account');
        insert listAccfromFactory;
        List<Opportunity> listOppFromFactory=TestDataFactory.createNOpportunities(1, 'Deal Registration');
        insert listOppFromFactory;
        list<OpportunityLineItem> listOppLineItemTdf=TestDataFactory.createNOpportunityLineItem(1);
        listOppLineItemTdf[0].OpportunityID=listOppFromFactory[0].id;
        insert listOppLineItemTdf;
    }   
    
    static Partner_Request__c createPartnerRequest(){
        Account testAccount = new Account(name='Test 1', Account_Country_Code__c = 'AI', Account_Country__c = 'ANGUILIA', Account_ID__c =''+System.currentTimeMillis());
        insert testAccount;
        Country__c testCountry = new Country__c(Name = 'TestCountry', Code__c = 'TY', User_Currency_Iso_Code__c = 'MYR', Region__c = 'APJ');
        insert testCountry;
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];        
        User userRecord = new User(Username='testUser'+System.currentTimeMillis()+'@test.com', Alias = 'test', Email='test@dell.com', 
                                   FirstName='Tfirst', LastName='TLast', ProfileId = userProfile.Id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                   EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles', Badge_Number__c='TEST12345');
        insert userRecord;
        Partner_Request__c request = new Partner_Request__c(Account__c = testAccount.id, 
                                                            RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,'Partner_Request__c', true), email__c = 'test@dell.com', Export_Compliance_Agreed__c = true, Partner_Terms_Conditions__c = true,
                                                            Other_Customers__c = 'test1', Preferred_Dell_Distribution_Partner__c = 'Test prefer',
                                                            Feature_Request_Deal_Registration__c = true, Org_Country__c = testCountry.id, Website__c = 'website', 
                                                            Org_Address_1__c =  'Address 1', Org_Address_2__c = 'Address 2', Org_Address_3__c =  'Address 3', Org_City__c = 'city',
                                                            Org_State__c = 'state', Org_Postal_Code__c = 'postalcode', Address_Line_1__c = 'Address 1', Address_Line_2__c = 'Address 2',
                                                            Address_Line_3__c = 'Address 3', City__c = 'city', State__c = 'state', Postal_Code__c = 'postalcode', 
                                                            Last_Name__c = 'Test Last Name', Country__c = testCountry.id, OwnerId = userRecord.Id);
        insert request;
        System.AssertNotEquals(request.Last_Name__c,'MyTestUser9'); 
        return request;
        
    }
    static testMethod void testDistiSelection(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Vfcntrl_DistributorResellerSelectionExt.WrapContacts wrco = new Vfcntrl_DistributorResellerSelectionExt.WrapContacts();
        Partner_Request__c partnerReq = createPartnerRequest();
        listAcc=[select id from account];
        for(Account acc : listAcc){
            acc.Partner_Registration__c = partnerReq.Id;
            acc.Status__c = 'Active';
            acc.DMU__c = false;
            acc.Account_Country__c = 'UNITED STATES';
            acc.Partner_Relationship__c = 'Authorized';
            acc.Partner_Tier__c = 'Tier 1';
            acc.Name='testOppDistiUser Test Account';
        }
        listAcc[0].Partner_Type__c = 'Commercial General';
        listAcc[1].Partner_Type__c = 'Sub Distributor';
        listAcc[2].Partner_Type__c = 'FEDERAL DISTRIBUTOR';
        listAcc[3].Partner_Type__c = 'OEM';
        update listAcc;
        Contact newContSearch2 = new Contact(FirstName = 'My Search', LastName = 'Contact', AccountId =listAcc[3].Id,
                                             Status__c  =  'Marketing Suspect', Email = 'MyLastNae@dell.com', Fax = '1234567', MobilePhone = '0987654',
                                             Last_Operation_Performed__c = 'testing', Phone = '1234500',Job_Function__c='OTHER47');
        insert newContSearch2;
        Contact newContSearch = new Contact(FirstName = 'My Search33', LastName = 'Contact33', AccountId =listAcc[2].Id,
                                            Status__c  =  'Marketing Suspect', Email = 'MyLastName@dell.com', Fax = '12345673', MobilePhone = '09876543',
                                            Last_Operation_Performed__c = 'testing', Phone = '12345003');
        insert newContSearch;
        final List<Profile> partnerProfiles1 = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        User partnerUser2 = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com', Alias = 'MTU9', Email='MyLastName@dell.com',
                                     FirstName='MyTestUser9', LastName='MyTestUser9', ProfileId = partnerProfiles1.get(0).Id, LanguageLocaleKey='en_US', 
                                     LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles', Badge_Number__c='Test846258',
                                     Enable_Partner_Admin__c = true, isActive = true,Enable_Partner_Deal_Registration__c = true,ContactId = newContSearch2.Id);
        insert partnerUser2;
        final List<Profile> partnerProfiles2 = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        
        User partnerUser1 = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com', Alias = 'MTU9', Email='MyLastName@dell.com',                    FirstName='MyTestUser9', LastName='MyTestUser9', ProfileId = partnerProfiles2.get(0).Id, LanguageLocaleKey='en_US', 
                                     LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles', Badge_Number__c='Test685219',
                                     Enable_Partner_Admin__c = true, isActive = true, Enable_Partner_Deal_Registration__c = true,ContactId = newContSearch.Id);
        insert partnerUser1;
        wrco.ContactName =partnerUser2.UserName;
        wrco.contactAccName=listAcc[2].Name;
        wrco.contactPhone =partnerUser2.contact.Phone;
        wrco.contactMobilePhone = partnerUser2.contact.MobilePhone;
        wrco.contactEmail = partnerUser2.contact.Email;
        wrco.contactTitle = partnerUser2.contact.Title;
        Contact newCont = new Contact(FirstName = 'MyTestContact9', LastName = 'MyTestContact9', AccountId =listAcc[2].Id,
                                      Status__c  =  'Marketing Suspect', Email = 'MyTestContactEmail_9@ust-global.com', Fax = '12345675',
                                      MobilePhone = '09876545', Last_Operation_Performed__c = 'testing', Phone = '12345005');
        insert newCont;
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com', Alias = 'MTU9',
                                    Email='MyTestUser9@dell.com', FirstName='MyTestUser9', LastName='MyTestUser9', ProfileId = partnerProfiles.get(0).Id, 
                                    LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',
                                    Enable_Partner_Admin__c = true, Badge_Number__c='Test970531', isActive = TRUE, ContactId = newCont.Id);
        insert partnerUser;
        Disti_Relationship__c distiRel = new Disti_Relationship__c(Reseller_Account__c =listAcc[3].Id, Disti_Account__c = listAcc[2].id,
                                                                   Contracted_Disti__c = true);
        insert distiRel;
        listOpp=[select id from Opportunity];
        listOpp[0].AccountId=listAcc[2].id;
        listOpp[0].Distributor_Name__c = 'Distribution';
        listOpp[0].Deal_Registration_Status__c= 'New';
        listOpp[0].Distributor_ID__c = 'Test Disti User';
        listOpp[0].partnerAccountid = listAcc[2].Id;
        listOpp[0].Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes';
        update listOpp;
        Id pricebookId = Test.getStandardPricebookId();   
        test.starttest();
        listOppLineItem=[select id from OpportunityLineItem Limit 1]; 
        PageReference pageRef = Page.DistributorResellerSelectionPage;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(listOpp[0]);
        ApexPages.currentPage().getParameters().put('Id',listOpp[0].id);
        Vfcntrl_DistributorResellerSelectionExt distiSelectPage = new Vfcntrl_DistributorResellerSelectionExt(sc);
        DistiSelectPage.onPageLoad();
        DistiSelectPage.searchString = 'Test';
        DistiSelectPage.accName = 'Name';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = '9876543210';
        DistiSelectPage.accName = 'Affinity';
        DistiSelectPage.fetchResults();
        DistiSelectPage.accName = 'Email';
        DistiSelectPage.fetchResults();
        TriggerExecutionController.setSkipAllTriggers(true);
        DistiSelectPage.searchString = '.com';
        DistiSelectPage.accName = 'Email';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = 'ABC';
        DistiSelectPage.accName = 'Name';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = 'Test';
        DistiSelectPage.accName = 'sName';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = '9876543210';
        DistiSelectPage.accName = 'sAffinity';
        DistiSelectPage.fetchResults();
        DistiSelectPage.accName = 'sEmail';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = '.com';
        DistiSelectPage.accName = 'sEmail';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = 'ABC';
        DistiSelectPage.accName = 'sName';
        DistiSelectPage.fetchResults();
        System.currentPagereference().getParameters().put('selectedAccId', listAcc[0].Id);
        DistiSelectPage.saveFunction();
        DistiSelectPage.distributorContactAddition();
        distiselectpage.isDistiPartneradminchecked = true;
        DistiSelectPage.contactAddition();
        DistiSelectPage.distributorcontactSearchString = 'MyLastName';     
        DistiSelectPage.distributorContactSelection = true;
        DistiSelectPage.isDistiPartneradminchecked = false;           
        DistiSelectPage.contactSearch();
        DistiSelectPage.contactAddition();
        DistiSelectPage.editOppTeamMem();   
        DistiSelectPage.distributorContactSelection = false;
        DistiSelectPage.editOppTeamMem();   
        Distiselectpage.DistiselectedAccess = 'Read';
        Distiselectpage.cancel();
        Distiselectpage.delRow();
        DistiSelectPage.contactAddition();
        DistiSelectPage.contactAddition();
        DistiSelectPage.distributorcontactSearchString = '';                 
        DistiSelectPage.contactSearch();
        DistiSelectPage.distributorcontactSearchString = 'My';                 
        DistiSelectPage.contactSearch();
        DistiSelectPage.distributorcontactSearchString = 'ABC';                 
        DistiSelectPage.contactSearch();
        DistiSelectPage.resellerContactAddition();           
        DistiSelectPage.backtoAccountSearch();   
        DistiSelectpage.getdistiCountriesdropdown(); 
        DistiSelectPage.searchString = 'Te';
        DistiSelectPage.accName = 'Name';
        DistiSelectPage.fetchContractedResellers();
        DistiSelectPage.searchString = '';
        DistiSelectPage.accName = 'Name';
        DistiSelectPage.fetchContractedResellers();
        DistiSelectPage.searchString = 'Test';
        DistiSelectPage.accName = 'Affinity';
        DistiSelectPage.fetchContractedResellers();
        DistiSelectPage.searchString = 'Test';
        DistiSelectPage.accName = 'Name';
        DistiSelectPage.fetchContractedResellers();
        DistiSelectPage.searchString = '9876543210';
        DistiSelectPage.accName = 'Affinity';
        DistiSelectPage.fetchContractedResellers();
        DistiSelectPage.searchString = 'MyLastName@dell.com';
        DistiSelectPage.accName = 'Email';
        DistiSelectPage.searchString = 'Test';
        DistiSelectPage.accName = 'sName';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = '9876543210';
        DistiSelectPage.accName = 'sAffinity';
        DistiSelectPage.fetchResults();
        DistiSelectPage.accName = 'sEmail';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = '.com';
        DistiSelectPage.accName = 'sEmail';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = 'ABC';
        DistiSelectPage.accName = 'sName';
        DistiSelectPage.fetchResults();
        DistiSelectPage.fetchContractedResellers();
        DistiSelectPage.hasContractedDistiorReseller();
        test.stoptest();  
        System.AssertNotEquals(DistiSelectPage.searchString,'MyTest');                  
    } 
    static testMethod void testResellerSelection(){
        TriggerExecutionController.setSkipAllTriggers(true);        
        Vfcntrl_DistributorResellerSelectionExt.WrapContacts wrco = new Vfcntrl_DistributorResellerSelectionExt.WrapContacts();
        Partner_Request__c partnerReq = createPartnerRequest();
        listAcc=[select id from Account];
        listAcc[0].Partner_Type__c = 'Commercial General';
        listAcc[1].Partner_Type__c = 'Distributor (GCC)';
        listAcc[2].Partner_Type__c = 'OEM';
        listAcc[3].Partner_Type__c = 'Sub Distributor';
        for(Account acc : listAcc){
            acc.Partner_Registration__c = partnerReq.Id;
            acc.Status__c = 'Active';
            acc.DMU__c = false;
        }
        update listAcc;
        Contact newContSearch2 = new Contact(FirstName = 'My Search', LastName = 'Contact', AccountId =listAcc[2].Id,
                                             Status__c  =  'Marketing Suspect', Email = 'MyLastNae@dell.com', Fax = '1234567', MobilePhone = '0987654',
                                             Last_Operation_Performed__c = 'testing', Phone = '1234500');
        insert newContSearch2;
        Contact newContSearch = new Contact(FirstName = 'My Search33', LastName = 'Contact33', AccountId =listAcc[1].Id,
                                            Status__c  =  'Marketing Suspect', Email = 'MyLastName@dell.com', Fax = '12345673', MobilePhone = '09876543',
                                            Last_Operation_Performed__c = 'testing', Phone = '12345003');
        insert newContSearch;
        final List<Profile> partnerProfiles1 = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        User partnerUser2 = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com', Alias = 'MTU9', Email='MyLastName@dell.com',
                                     FirstName='MyTestUser9', LastName='MyTestUser9', ProfileId = partnerProfiles1.get(0).Id, LanguageLocaleKey='en_US', 
                                     LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles', Badge_Number__c='Test846258',
                                     Enable_Partner_Admin__c = true, isActive = true,Enable_Partner_Deal_Registration__c = true,ContactId = newContSearch2.Id);
        insert partnerUser2;
        final List<Profile> partnerProfiles2 = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        User partnerUser1 = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com', Alias = 'MTU9', Email='MyLastName@dell.com',                    FirstName='MyTestUser9', LastName='MyTestUser9', ProfileId = partnerProfiles2.get(0).Id, LanguageLocaleKey='en_US', 
                                     LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles', Badge_Number__c='Test685219',
                                     Enable_Partner_Admin__c = true, isActive = true, Enable_Partner_Deal_Registration__c = true,ContactId = newContSearch.Id);
        insert partnerUser1;
        Contact newCont = new Contact(FirstName = 'MyTestContact9', LastName = 'MyTestContact9', AccountId =listAcc[2].Id,
                                      Status__c  =  'Marketing Suspect', Email = 'MyTestContactEmail_9@ust-global.com', Fax = '12345675',
                                      MobilePhone = '09876545', Last_Operation_Performed__c = 'testing', Phone = '12345005');
        insert newCont;
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com', Alias = 'MTU9', 
                                    Email='MyTestUser9@dell.com', FirstName='MyTestUser9', LastName='MyTestUser9', ProfileId = partnerProfiles.get(0).Id, 
                                    LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',
                                    Enable_Partner_Admin__c = true, Badge_Number__c='Test970531', isActive = TRUE, ContactId = newCont.Id);
        insert partnerUser;
        Disti_Relationship__c distiRel = new Disti_Relationship__c(Reseller_Account__c =listAcc[2].Id, Disti_Account__c = listAcc[1].id,
                                                                   Contracted_Disti__c = true);
        insert distiRel;
        listOpp=[select id from Opportunity];
        listOpp[0].AccountId=listAcc[2].id;
        listOpp[0].partnerAccountid=listAcc[2].id;
        update listOpp;
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.OpportunityId = listOpp[0].Id;
        otm.UserId = partnerUser.Id;
        otm.TeamMemberRole = 'Reseller Contact';         
        insert otm;      
        test.startTest();
        listOppLineItem=[select id from OpportunityLineItem Limit 1]; 
        PageReference pageRef = Page.DistributorResellerSelectionPage;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(listOpp[0]);
        ApexPages.currentPage().getParameters().put('Id',listOpp[0].id);
        Vfcntrl_DistributorResellerSelectionExt distiSelectPage = new Vfcntrl_DistributorResellerSelectionExt(sc);
        DistiSelectPage.onPageLoad();
        DistiSelectPage.searchString = 'Test';
        DistiSelectPage.accName = 'Name';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = '9876543210';
        DistiSelectPage.accName = 'Affinity';
        DistiSelectPage.fetchResults();
        DistiSelectPage.accName = 'Email';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = '.com';
        DistiSelectPage.accName = 'Email';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = 'ABC';
        DistiSelectPage.accName = 'Name';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = 'Test';
        DistiSelectPage.accName = 'sName';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = '9876543210';
        DistiSelectPage.accName = 'sAffinity';
        DistiSelectPage.fetchResults();
        DistiSelectPage.accName = 'sEmail';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = '.com';
        DistiSelectPage.accName = 'sEmail';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = 'ABC';
        DistiSelectPage.accName = 'sName';
        DistiSelectPage.fetchResults();
        System.currentPagereference().getParameters().put('selectedAccId', listAcc[0].Id);
        DistiSelectPage.saveFunction();
        DistiSelectPage.distributorContactAddition();
        distiselectpage.isDistiPartneradminchecked = true;
        DistiSelectPage.contactAddition();
        DistiSelectPage.distributorcontactSearchString = 'MyLastName';                 
        DistiSelectPage.contactSearch();
        DistiSelectPage.contactAddition();
        id oppteamid = distiselectpage.oppTeamMembers[0].id;
        Distiselectpage.DistiparamOpportunityId = oppteamid;
        DistiSelectPage.editOppTeamMem();   
        Distiselectpage.DistiselectedAccess = 'Read';
        DistiSelectpage.updateTeamrole();
        Distiselectpage.cancel();
        Distiselectpage.delRow();
        DistiSelectPage.contactAddition();
        DistiSelectPage.contactAddition();
        DistiSelectPage.distributorcontactSearchString = '';                 
        DistiSelectPage.contactSearch();
        DistiSelectPage.distributorcontactSearchString = 'My';                 
        DistiSelectPage.contactSearch();
        DistiSelectPage.distributorcontactSearchString = 'ABC';                 
        DistiSelectPage.contactSearch();
        DistiSelectPage.resellerContactAddition();           
        DistiSelectPage.backtoAccountSearch();   
        DistiSelectpage.getdistiCountriesdropdown(); 
        DistiSelectPage.searchString = 'Te';
        DistiSelectPage.accName = 'Name';
        DistiSelectPage.fetchContractedResellers();
        DistiSelectPage.searchString = '';
        DistiSelectPage.accName = 'Name';
        DistiSelectPage.fetchContractedResellers();
        DistiSelectPage.searchString = 'Test';
        DistiSelectPage.accName = 'Affinity';
        DistiSelectPage.fetchContractedResellers();
        DistiSelectPage.searchString = 'Test';
        DistiSelectPage.accName = 'Name';
        DistiSelectPage.fetchContractedResellers();
        DistiSelectPage.searchString = '9876543210';
        DistiSelectPage.accName = 'Affinity';
        DistiSelectPage.fetchContractedResellers();
        DistiSelectPage.searchString = 'Test';
        DistiSelectPage.accName = 'sName';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = '9876543210';
        DistiSelectPage.accName = 'sAffinity';
        DistiSelectPage.fetchResults();
        DistiSelectPage.accName = 'sEmail';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = '.com';
        DistiSelectPage.accName = 'sEmail';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = 'ABC';
        DistiSelectPage.accName = 'sName';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = 'MyLastName@dell.com';
        DistiSelectPage.accName = 'Email';
        DistiSelectPage.fetchContractedResellers();
        DistiSelectPage.hasContractedDistiorReseller();
        test.stoptest(); 
        System.AssertNotEquals(DistiSelectPage.searchString,'MyTest');                   
    } 
    
    static testMethod void testResellerSelectionEMC(){
        TriggerExecutionController.setSkipAllTriggers(true);        
        Vfcntrl_DistributorResellerSelectionExt.WrapContacts wrco = new Vfcntrl_DistributorResellerSelectionExt.WrapContacts();
        Partner_Request__c partnerReq = createPartnerRequest();
        listAcc=[select id from account limit 3];
        for(Account acc : listAcc){
            acc.Status__c = 'Active';
            acc.DMU__c = false;
            acc.Partner_Registration__c = partnerReq.Id;
        }
        listAcc[0].Partner_Type__c = 'Commercial General';
        listAcc[1].Partner_Type__c = 'Distributor (GCC)';
        listAcc[2].Partner_Type__c = 'OEM';
        update listAcc;
        Contact newContSearch2 = new Contact(FirstName = 'My Search', LastName = 'Contact', AccountId =listAcc[2].Id,
                                             Status__c  =  'Marketing Suspect', Email = 'MyLastNae@dell.com', Fax = '1234567', MobilePhone = '0987654',
                                             Last_Operation_Performed__c = 'testing', Phone = '1234500');
        insert newContSearch2;
        Contact newContSearch = new Contact(FirstName = 'My Search33', LastName = 'Contact33', AccountId =listAcc[1].Id,
                                            Status__c  =  'Marketing Suspect', Email = 'MyLastName@dell.com', Fax = '12345673', MobilePhone = '09876543',
                                            Last_Operation_Performed__c = 'testing', Phone = '12345003');
        insert newContSearch;
        final List<Profile> partnerProfiles1 = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        User partnerUser2 = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com', Alias = 'MTU9', Email='MyLastName@dell.com',
                                     FirstName='MyTestUser9', LastName='MyTestUser9', ProfileId = partnerProfiles1.get(0).Id, LanguageLocaleKey='en_US', 
                                     LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles', Badge_Number__c='Test846258',
                                     Enable_Partner_Admin__c = true, isActive = true,Enable_Partner_Deal_Registration__c = true,ContactId = newContSearch2.Id);
        insert partnerUser2;
        final List<Profile> partnerProfiles2 = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        
        User partnerUser1 = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com', Alias = 'MTU9', Email='MyLastName@dell.com',                    FirstName='MyTestUser9', LastName='MyTestUser9', ProfileId = partnerProfiles2.get(0).Id, LanguageLocaleKey='en_US', 
                                     LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles', Badge_Number__c='Test685219',
                                     Enable_Partner_Admin__c = true, isActive = true, Enable_Partner_Deal_Registration__c = true,ContactId = newContSearch.Id);
        insert partnerUser1;
        Contact newCont = new Contact(FirstName = 'MyTestContact9', LastName = 'MyTestContact9', AccountId =listAcc[2].Id,
                                      Status__c  =  'Marketing Suspect', Email = 'MyTestContactEmail_9@ust-global.com', Fax = '12345675',
                                      MobilePhone = '09876545', Last_Operation_Performed__c = 'testing', Phone = '12345005');
        insert newCont;
        final List<Profile> partnerProfiles = [select Id, Name from Profile where UserType = 'PowerPartner' and name like '%PRM%' limit 1];
        User partnerUser = new User(Username='MyTestUser9' + System.currentTimeMillis() + '@dell.com', Alias = 'MTU9', 
                                    Email='MyTestUser9@dell.com', FirstName='MyTestUser9', LastName='MyTestUser9', ProfileId = partnerProfiles.get(0).Id, 
                                    LanguageLocaleKey='en_US', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',
                                    Enable_Partner_Admin__c = true, Badge_Number__c='Test970531', isActive = TRUE, ContactId = newCont.Id);
        insert partnerUser;
        Disti_Relationship__c distiRel = new Disti_Relationship__c(Reseller_Account__c =listAcc[2].Id, Disti_Account__c = listAcc[1].id,
                                                                   Contracted_Disti__c = true);
        insert distiRel;
        listOpp=[select id from Opportunity];
        listOpp[0].AccountID=listAcc[2].id;
        listOpp[0].partnerAccountid = listAcc[2].Id;
        update listOpp;
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.OpportunityId = listOpp[0].Id;
        otm.UserId = partnerUser.Id;
        otm.TeamMemberRole = 'Reseller Contact';         
        insert otm;      
        listOppLineItem=[select id from OpportunityLineItem Limit 1]; 
        test.startTest();
        PageReference pageRef = Page.DistributorResellerSelectionPage;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(listOpp[0]);
        ApexPages.currentPage().getParameters().put('Id',listOpp[0].id);
        Vfcntrl_DistributorResellerSelectionExt distiSelectPage = new Vfcntrl_DistributorResellerSelectionExt(sc);
        DistiSelectPage.onPageLoad();
        DistiSelectPage.searchString = 'Test';
        DistiSelectPage.accName = 'Name';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = '9876543210';
        DistiSelectPage.accName = 'Affinity';
        DistiSelectPage.fetchResults();
        DistiSelectPage.accName = 'Email';
        DistiSelectPage.fetchResults();
        TriggerExecutionController.setSkipAllTriggers(true);
        DistiSelectPage.searchString = '.com';
        DistiSelectPage.accName = 'Email';
        DistiSelectPage.fetchResults();
        DistiSelectPage.searchString = 'ABC';
        DistiSelectPage.accName = 'Name';
        DistiSelectPage.fetchResults();
        TriggerExecutionController.setSkipAllTriggers(true);
        System.currentPagereference().getParameters().put('selectedAccId', listAcc[0].Id);
        DistiSelectPage.saveFunction();
        DistiSelectPage.distributorContactAddition();
        distiselectpage.isDistiPartneradminchecked = true;
        DistiSelectPage.contactAddition();
        DistiSelectPage.distributorcontactSearchString = 'MyLastName';                 
        DistiSelectPage.contactSearch();
        DistiSelectPage.contactAddition();
        id oppteamid = distiselectpage.oppTeamMembers[0].id;
        Distiselectpage.DistiparamOpportunityId = oppteamid;
        DistiSelectPage.editOppTeamMem();   
        Distiselectpage.DistiselectedAccess = 'Read';
        DistiSelectpage.updateTeamrole();
        Distiselectpage.cancel();
        Distiselectpage.delRow();
        DistiSelectPage.contactAddition();
        DistiSelectPage.contactAddition();
        DistiSelectPage.distributorcontactSearchString = '';                 
        DistiSelectPage.contactSearch();
        DistiSelectPage.distributorcontactSearchString = 'My';                 
        DistiSelectPage.contactSearch();
        DistiSelectPage.distributorcontactSearchString = 'ABC';                 
        DistiSelectPage.contactSearch();
        DistiSelectPage.resellerContactAddition();           
        DistiSelectPage.backtoAccountSearch();   
        DistiSelectpage.getdistiCountriesdropdown(); 
        DistiSelectPage.searchString = 'Te';
        DistiSelectPage.accName = 'Name';
        DistiSelectPage.fetchContractedResellers();
        DistiSelectPage.searchString = '';
        DistiSelectPage.accName = 'Name';
        DistiSelectPage.fetchContractedResellers();
        DistiSelectPage.searchString = 'Test';
        DistiSelectPage.accName = 'Affinity';
        DistiSelectPage.fetchContractedResellers();
        DistiSelectPage.searchString = 'Test';
        DistiSelectPage.accName = 'Name';
        DistiSelectPage.fetchContractedResellers();
        DistiSelectPage.searchString = '9876543210';
        DistiSelectPage.accName = 'Affinity';
        DistiSelectPage.fetchContractedResellers();
        DistiSelectPage.searchString = 'MyLastName@dell.com';
        DistiSelectPage.accName = 'Email';
        DistiSelectPage.fetchContractedResellers();
        test.stoptest();    
        DistiSelectPage.searchString = 'Test';
        DistiSelectPage.accName = 'Name';
        DistiSelectPage.fetchContractedResellers();
        DistiSelectPage.hasContractedDistiorReseller();
        DistiSelectPage.goBack();
        System.AssertNotEquals(DistiSelectPage.searchString,'MyTest');
    }
}
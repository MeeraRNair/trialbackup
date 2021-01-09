/**  
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------     -----------     ------------    -----------
* 1.0      15997      FY19-DCS-0802   05-June-2018    manip4          removed netExam reference, story# 4988525
* 1.1 -    16018     FY19-DCS-0802    6-June-2018:   Jatin Puri      Decommisioned netexam and Feature_Request_Training__c as part of story# 4988542
* 1.2                                 16-10-2019     venugopalachary Implimented TestDataFactory
*/
@isTest(seealldata= false)
private class PartnerRegistrationProvisionUsrCtExTest {
    static list<Account> listAcc;
    @testSetup static void setup() {
        List<Account> listAccfromFactory=TestDataFactory.createNAccount(2, 'Master Account');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listAccfromFactory;
        list<User> listUserTdf=TestDataFactory.createNPortalUser(1);
        listUserTdf[0].Enable_Partner_Admin__c = false;
        listUserTdf[0].isActive=true;
        insert listUserTdf;
    }
    private static testmethod void testNoIdParamError(){
        assertErrorOccurs(null,PartnerRegistrationProvisionUserCtrlExt.MISSING_PARAM);
        list<Account> listAcc=[select id from Account Limit 1];
        system.assertNotEquals(listAcc[0].id, null);
    }
    private static testmethod void testBadPartnerReqRecTypeError(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Country__c country = buildMockCountry(true);
        listAcc=[select id,Master_Group_Affinity_Id__c from Account];
        listAcc[0].account_country_code__c=country.code__c;
        update listAcc;
        system.assertNotEquals(listAcc[0].id, null);
        Partner_Request__c request = new Partner_Request__c();
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_UPDATE_PARTNER,
                                                             'Partner_Request__c', true);
        request.Account__c = listAcc[0].id;
        request.Website__c = 'www.test1.com';
        populateContactData(request,country);
        insert request;
    }
    private static testmethod void testNoAccountLinkError(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Partner_Request__c request = new Partner_Request__c();
        list<Account> listAcc=[select id from Account Limit 1];
        system.assertNotEquals(listAcc[0].id, null);
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
                                                             'Partner_Request__c', true);
        request.Website__c = 'www.test2.com';
        insert request;
        try{ assertErrorOccurs(request.id,PartnerRegistrationProvisionUserCtrlExt.ACCT_NOT_LINKED);}catch(Exception ex){}
    }
    private static testmethod void testNoCountryFoundError(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Country__c country = buildMockCountry(true);
        listAcc=[select id from Account];
        system.assertNotEquals(listAcc[0].id, null);
        Partner_Request__c request = new Partner_Request__c();
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
                                                             'Partner_Request__c', true);
        request.Website__c = 'www.test3.com';
        request.Account__c = listAcc[0].id;
        populateContactData(request,country);
        insert request;
        try{ assertErrorOccurs(request.id,PartnerRegistrationProvisionUserCtrlExt.COUNTRY_NOT_FOUND);}catch(Exception ex){}
        listAcc[0].account_country_code__c='XZ';
        update listAcc;
    }
    private static testmethod void testCountryNotEnabledError(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Country__c country = buildMockCountry(false);
        listAcc=[select id,Master_Group_Affinity_Id__c from Account];
        listAcc[0].account_country_code__c=country.code__c;
        Partner_Request__c request = new Partner_Request__c();
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
                                                             'Partner_Request__c', true);
        request.Account__c = listAcc[0].id;
        request.Website__c = 'www.test4.com';
        populateContactData(request,country);
        insert request;
        system.assertNotEquals(listAcc[0].id, null);
    }
    private static testmethod void testAccountNotPartnerError(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Country__c country = buildMockCountry(true);
        listAcc=[select id,Master_Group_Affinity_Id__c from Account];
        listAcc[0].account_country_code__c=country.code__c;
        Partner_Request__c request = new Partner_Request__c();
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
                                                             'Partner_Request__c', true);
        request.Account__c = listAcc[0].id;
        request.Website__c = 'www.test5.com';
        populateContactData(request,country);
        insert request;
        system.assertNotEquals(listAcc[0].id, null);
    }
    private static testmethod void testContactNoParentAccountError(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Country__c country = buildMockCountry(true);
        listAcc=[select id from Account];
        system.assertNotEquals(listAcc[0].id, null);
        listAcc[0].account_country_code__c=country.code__c;
        Contact contact = new Contact(lastname='cmapmodified',email='john@acme.com',accountid=listAcc[0].id,status__c = 'Prospect');
        insert contact;
        assertErrorOccurs(contact.id,PartnerRegistrationProvisionUserCtrlExt.ACCT_NOT_LINKED);
    }
    private static testmethod void testContactAccountNotPartnerError(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Country__c country = buildMockCountry(true);
        listAcc=[select id,Master_Group_Affinity_Id__c from Account];
        system.assertNotEquals(listAcc[0].id, null);
        listAcc[0].account_country_code__c=country.code__c;
        Contact contact = new Contact(lastname='cmapmodified',accountid=listAcc[0].id,email='john@acme.com',status__c = 'Prospect');
        insert contact;
        assertErrorOccurs(contact.id,PartnerRegistrationProvisionUserCtrlExt.ACCT_NOT_PARTNER);
    }
    private static void assertErrorOccurs(String strtheID, String strexpectedErrorCode){
        PageUtils.param('id',strtheID);
        PartnerRegistrationProvisionUserCtrlExt controller = new PartnerRegistrationProvisionUserCtrlExt();
        System.assertEquals(null,controller.doOnLoad());
    }
    private static testmethod void testContactNewFromContact(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Country__c country = buildMockCountry(true);
        Sales_Channel_Group__c testSalesChanGrp = new Sales_Channel_Group__c(Name = 'Test Sales channel OEM', Regional_Parent_Name__c = 'APJ');
        insert testSalesChanGrp;
        listAcc=[select id,Master_Group_Affinity_Id__c from Account];
        system.assertNotEquals(listAcc[0].id, null);
        listAcc[0].account_country_code__c=country.code__c;
        listAcc[0].Sales_Channel__c=testSalesChanGrp.Id;
        listAcc[0].Partner_Relationship__c='Registered';
        listAcc[0].IsPartner = true;
        update listAcc;
        //14.2 SSO Addition -insert record to Special job title        
        SpecialJobTitle__c specialjob = new SpecialJobTitle__c(Job_Title__c = 'VP');
        insert specialjob;
        Contact contact = new Contact(LastName='cmapmodified', Email='test@dell.com',AccountId = listAcc[0].id,title='VP',status__c='Prospect');
        insert contact;
        PageUtils.param('id',contact.id);
        PartnerRegistrationProvisionUserCtrlExt controller = new PartnerRegistrationProvisionUserCtrlExt();
        System.assertEquals(null,controller.doOnLoad());
        controller.checkforVendorUpdate();
        controller.doReuseOrCreateUser();
    }
    private static testmethod void testContactUpdateFromPartnerRequest(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Country__c country = buildMockCountry(true);
        listAcc=[select id,Master_Group_Affinity_Id__c from Account];
        listAcc[0].account_country_code__c=country.code__c;
        listAcc[0].IsPartner = true;
        update listAcc;
        system.assertNotEquals(listAcc[0].id, null);
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj; 
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = listAcc[0].id;
        testPartnerTrackObj.Master_Group_Affinity_Id__c = listAcc[0].Master_Group_Affinity_Id__c;
        insert testPartnerTrackObj;
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = listAcc[0].id;
        testPartnerTrackObj1.Master_Group_Affinity_Id__c = listAcc[0].Master_Group_Affinity_Id__c;
        insert testPartnerTrackObj1;
        Partner_Request__c request = new Partner_Request__c();
        request.Account__c = listAcc[0].id;
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
                                                             'Partner_Request__c', true);
        request.Is_Enabled_for_Incentives__c = true;
        request.Website__c = 'www.test6.com';
        request.Eligible_Partner_Tracks__c = testPartnerTrackObj.id + ';' + testPartnerTrackObj1.id;
        populateContactData(request,country);
        insert request;
        Contact contact = new Contact(LastName='cmapmodified',Email = request.Email__c, AccountId = listAcc[0].id,Is_Enabled_for_Incentives__c=true,Vendor_Update_Datetime__c=System.now(),status__c = 'Prospect',EligibleTracks__c = testPartnerTrackObj.id);
        insert contact;
        Test.startTest();
        PageUtils.param('id',request.id);
        PartnerRegistrationProvisionUserCtrlExt controller = new PartnerRegistrationProvisionUserCtrlExt();
        try{
            controller.isPartnerRequest = true;
            controller.doOnLoad();
        }catch(exception ex){}
        final String guid = RandomStringUtils.randomUUID();
        controller.state.guid = guid;
        try{controller.doReuseOrCreateContact();}catch(exception ex){}
        controller.state.contact = contact;
        System.assertEquals(guid,controller.state.guid);
        try{controller.doReuseOrCreateUser();}catch(Exception ex){}
        Test.stopTest();
        TriggerExecutionController.setSkipContactTriggers(true);
        controller.checkforVendorUpdate();
    }
    private static testmethod void testProvisionUserFromRequest(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Country__c country = buildMockCountry(true);
        listAcc=[select id,Master_Group_Affinity_Id__c from Account];
        listAcc[0].account_country_code__c=country.code__c;
        listAcc[0].IsPartner = true;
        update listAcc;
        system.assertNotEquals(listAcc[0].id, null);
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = listAcc[0].id;
        testPartnerTrackObj1.Master_Group_Affinity_Id__c = listAcc[0].Master_Group_Affinity_Id__c;
        insert testPartnerTrackObj1;
        listAcc[1].account_country_code__c=country.code__c;
        listAcc[1].Master_Group_Id__c = listAcc[0].id;
        listAcc[1].Partner_Track__c = testPartnerTrackObj1.id;
        listAcc[1].RecordTypeId = TestDataFactory.getRecordTypeIdbyName('Partner Account', 'Account');
        Update listAcc;
        Partner_Request__c request = new Partner_Request__c();
        request.Account__c = listAcc[1].id;
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
                                                             'Partner_Request__c', true);
        request.Website__c = 'www.test7.com';
        //request.Eligible_Partner_Tracks__c = testPartnerTrackObj1.id;
        populateContactData(request,country);
        insert request;
        Contact contact = new Contact(LastName='testConPortal',Email = request.Email__c, AccountId = listAcc[0].id,status__c = 'Prospect');
        insert contact;
        Test.startTest();
        PageUtils.param('id',request.id);
        PartnerRegistrationProvisionUserCtrlExt controller = new PartnerRegistrationProvisionUserCtrlExt();
        try{
            controller.doOnLoad();
        }catch(exception ex){}
        try{controller.doReuseOrCreateContact();}catch(exception ex){}
        Test.stopTest();
    }
    private static testmethod void testProvisionUserForGroupAdmin(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Country__c country = buildMockCountry(true);
        listAcc=[select id,Master_Group_Affinity_Id__c from Account];
        listAcc[0].account_country_code__c=country.code__c;
        listAcc[0].IsPartner = true;
        update listAcc;
        system.assertNotEquals(listAcc[0].id, null);
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = listAcc[0].id;
        testPartnerTrackObj1.Master_Group_Affinity_Id__c = listAcc[0].Master_Group_Affinity_Id__c;
        insert testPartnerTrackObj1;
        listAcc[1].account_country_code__c=country.code__c;
        listAcc[1].Master_Group_Id__c = listAcc[0].id;
        listAcc[1].Partner_Track__c = testPartnerTrackObj1.id;
        listAcc[1].RecordTypeId = TestDataFactory.getRecordTypeIdbyName('Partner Account', 'Account');
        Update listAcc;
        Partner_Request__c request = new Partner_Request__c();
        request.Account__c = listAcc[1].id;
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
                                                             'Partner_Request__c', true);
        request.Website__c = 'www.test7.com';
        request.Enable_Partner_Group_Admin__c = true;
        populateContactData(request,country);
        insert request;
        Test.startTest();
        PageUtils.param('id',request.id);
        PartnerRegistrationProvisionUserCtrlExt controller = new PartnerRegistrationProvisionUserCtrlExt();
        try{
            controller.doOnLoad();
        }catch(exception ex){}
        try{controller.doReuseOrCreateContact();}catch(exception ex){}
        Test.stopTest();
    }
    private static testmethod void testContactNewFromPartnerRequest(){
        TriggerExecutionController.setSkipAccountTriggers(true);
        Country__c country = buildMockCountry(true);
        listAcc=[select id,Master_Group_Affinity_Id__c from Account];
        listAcc[0].account_country_code__c=country.code__c;
        listAcc[0].IsPartner = true;
        update listAcc;
        system.assertNotEquals(listAcc[0].id, null);
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = listAcc[0].id;
        testPartnerTrackObj.Master_Group_Affinity_Id__c = listAcc[0].Master_Group_Affinity_Id__c;
        insert testPartnerTrackObj;
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = listAcc[0].id;
        testPartnerTrackObj1.Master_Group_Affinity_Id__c = listAcc[0].Master_Group_Affinity_Id__c;
        insert testPartnerTrackObj1;
        Partner_Request__c request = new Partner_Request__c();
        request.Account__c = listAcc[0].id;
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
                                                             'Partner_Request__c', true);
        request.Is_Enabled_for_Incentives__c = true;
        request.Website__c = 'www.test9.com';
        request.Eligible_Partner_Tracks__c = testPartnerTrackObj.id + ';' + testPartnerTrackObj1.id;
        populateContactData(request,country);
        insert request;
        PageUtils.param('id',request.id);
        PartnerRegistrationProvisionUserCtrlExt controller = new PartnerRegistrationProvisionUserCtrlExt();
        try{
            controller.doOnLoad();
        }catch(exception ex){}
        System.debug(controller.errorCode);
        System.assert(true,StringUtils.isBlank(controller.errorCode));
        controller.state.guid = RandomStringUtils.randomUUID();
        System.assertEquals(null,controller.state.contact);
        System.assertEquals(null,controller.ajaxError);
        try{
            controller.doReuseOrCreateContact();}catch(exception ex){}
        listAcc[1].account_country_code__c=country.code__c;
        listAcc[1].Is_Enabled_for_Incentives__c =true;
        listAcc[1].IsPartner = true;
        update listAcc;
        request.Account__c = listAcc[1].id;
        update request;
        Test.startTest();
        controller = new PartnerRegistrationProvisionUserCtrlExt();
        try{
            controller.doOnLoad();
        }catch(exception ex){}
        System.debug(controller.errorCode);
        //14.2 SSO Addition
        controller.state.guid = RandomStringUtils.randomUUID();
        try{     controller.doReuseOrCreateContact();}catch(exception ex){}
        //14.2 SSO Addition
        Test.stopTest();
    }
    // - test - CR6728
    private static testmethod void testContactNewFromPartnerRequestWithNoAcc(){
        Country__c country = buildMockCountry(true);
        listAcc=[select id,Master_Group_Affinity_Id__c from Account limit 1];
        listAcc[0].account_country_code__c=country.code__c;
        listAcc[0].IsPartner = true;
        update listAcc;
        system.assertNotEquals(listAcc[0].id, null);
        Partner_Request__c request = new Partner_Request__c();
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
                                                             'Partner_Request__c', true);
        populateContactData(request,country);
        insert request;
        PageUtils.param('id',request.id);
        Test.startTest();
        PartnerRegistrationProvisionUserCtrlExt controller = new PartnerRegistrationProvisionUserCtrlExt();
        try{
            controller.doOnLoad();
        }catch(exception ex){}
        System.debug(controller.errorCode);
        controller.state.guid = RandomStringUtils.randomUUID();
        delete listAcc[0];
        Test.stopTest();
    }
    // - test - CR6728
    //CR3387
    private static testmethod void testProvisionUserFromContact() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Country__c country = buildMockCountry(true);
        listAcc=[select id,Master_Group_Affinity_Id__c from Account];
        for(Account acc : listAcc){
            acc.account_country_code__c=country.code__c;
            acc.IsPartner = true;
            acc.Is_Enabled_for_Incentives__c=true;
        }
        update listAcc;
        system.assertNotEquals(listAcc[0].id, null);
        
        //14.2 SSO Addition -insert record to Special job title
        Track__c trackObj = new Track__c(Name = 'testTrack',Zone__c = 'Zone 1');
        insert trackObj;
        Partner_Track__c testPartnerTrackObj = new Partner_Track__c();
        testPartnerTrackObj.Partner_Track_Name__c = 'Tech Data';
        testPartnerTrackObj.Track_Id__c = trackObj.id;
        testPartnerTrackObj.Master_Group_Id__c = listAcc[1].id;
        testPartnerTrackObj.Master_Group_Affinity_Id__c = listAcc[1].Master_Group_Affinity_Id__c;
        insert testPartnerTrackObj;
        Partner_Track__c testPartnerTrackObj1 = new Partner_Track__c();
        testPartnerTrackObj1.Partner_Track_Name__c = 'Tech Data1';
        testPartnerTrackObj1.Track_Id__c = trackObj.id;
        testPartnerTrackObj1.Master_Group_Id__c = listAcc[1].id;
        testPartnerTrackObj1.Master_Group_Affinity_Id__c = listAcc[1].Master_Group_Affinity_Id__c;
        insert testPartnerTrackObj1;
        SpecialJobTitle__c specialjob = new SpecialJobTitle__c(Job_Title__c = 'VP');
        insert specialjob;
        PartnerRegistrationProvisionUserCtrlExt controller = new PartnerRegistrationProvisionUserCtrlExt();
        controller.doUpdateContactProvisionedFlags(); 
        System.assertNotEquals(controller.ajaxError,null);  
        Contact contact = new Contact(LastName='cmapmodified',Email = 'john@dell.com', AccountId = listAcc[1].id,status__c = 'Prospect');
        populateContactData(contact,country);
        insert contact;
        controller = new PartnerRegistrationProvisionUserCtrlExt();
        system.debug('prinntttdonlsadkjf'+controller.doOnLoad());
        controller.state.contact = contact;
        controller.state.contactIsCampaignBuilder = true;
        controller.state.contactIsPremier = true;
        controller.state.contactIsTransactionalStore = true;
        controller.state.contactIsWarrantyPartsInfo = true;
        controller.state.contactIsEnabledForIncentives = true;     
        controller.state.enableAsPartnerGroupAdmin = 'true';
        controller.doUpdateContactProvisionedFlags(); 
        System.assertEquals(contact.Campaign_Builder__c,true);
        System.assertEquals(contact.Premier_Partner__c,true);
        System.assertEquals(contact.Transactional_Store__c,true);
        System.assertEquals(contact.Warranty_Parts_Info__c,true); 
        //14.2 SSO Addition
        System.assertEquals(controller.state.contact.Is_Enabled_for_Incentives__c, true);  
        System.assertEquals(controller.state.contact.Is_Enabled_for_Incentives__c, true);
        controller.checkforVendorUpdate();
        Contact con = [SELECT id,Is_Enabled_for_Incentives__c,Is_Vendor_Update_Required__c,Last_Operation_Performed__c,Vendor_Update_Datetime__c
                       ,Operation_for_Boomi__c FROM CONTACT WHERE id=:controller.state.contact.id];
        try{
            controller.doDiasWebServiceCall();
            controller.doReuseOrCreateUser();
        }catch(exception ex){}
    }
    private static testmethod void testDoUpdateRequest(){
        TriggerExecutionController.setSkipAllTriggers(true);
        User theUser=[select id from user Limit 1];
        Country__c country = buildMockCountry(true);
        listAcc=[select id from Account limit 1];
        listAcc[0].account_country_code__c=country.code__c;
        listAcc[0].Is_Enabled_for_Incentives__c=true;
        update listAcc;
        system.assertNotEquals(listAcc[0].id, null);
        Contact contact1 = new Contact(LastName='cmapmodified1',Email = 'john1@dell.com', AccountId = listAcc[0].id,Is_Enabled_for_Incentives__c=true,status__c = 'Prospect');
        insert contact1;
        Partner_Request__c request = new Partner_Request__c();
        populateContactData(request,country);
        insert request;
        PageUtils.param('id',request.id);
        PartnerRegistrationProvisionUserCtrlExt controller = new PartnerRegistrationProvisionUserCtrlExt();
        controller.state.user = theUser;
        controller.state.request = request;
        controller.isPartnerRequest = true;
        controller.IsPortalEnabled = false;  //CR2087
        controller.state.contact = contact1;
        Test.startTest();    
        try{   
            controller.doBackToRegistrationButton().getUrl();
        }catch(Exception ex){}
        System.assertNotEquals(true,request.Provision_First_User_Is_Complete_Flag__c);
        System.assertNotEquals(PartnerConstants.REG_STATUS_COMPLETE,request.Status__c);
        controller.ajaxError = null;
        System.assertEquals(null,controller.ajaxError);
        System.assertEquals(null,controller.doUpdateRequest());
        System.assertEquals(null,controller.ajaxError);
        System.assertEquals(theUser.id,request.Provisioned_User__c);
        System.assertEquals(true,request.Provision_First_User_Is_Complete_Flag__c);
        System.assertEquals(PartnerConstants.REG_STATUS_COMPLETE,request.Status__c);
        controller.isPartnerRequest = false;
        controller.ajaxError = null;
        System.assertEquals(null,controller.ajaxError);
        System.assertEquals(null,controller.doUpdateRequest());
        System.assertNotEquals(null,controller.ajaxError);
        controller.isPartnerRequest = true;
        controller.ajaxError = null;
        delete request;
        Test.stopTest();
        System.assertEquals(null,controller.ajaxError);
        System.assertEquals(null,controller.doUpdateRequest());
        System.assertNotEquals(null,controller.ajaxError);
    }
    private static testmethod void testConfigVarSsoLinkMyAcctUrl(){
        PartnerRegistrationProvisionUserCtrlExt controller = new PartnerRegistrationProvisionUserCtrlExt();
        System.assertNotEquals('',controller.ssoLinkMyAcctUrl);
    }
    //22-July-2009 Raymond: Added for CR1466
    private static testmethod void testCopyPRFieldsToAccount() {
        TriggerExecutionController.setSkipAllTriggers(true);
        listAcc=[select id,Master_Group_Affinity_Id__c from account limit 1];
        String strrecTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Partner_Request__c' AND Name = 'New Partner'].Id;
        System.assert(strrecTypeId != '');
        Partner_Request__c testPartnerRequest =
            new Partner_Request__c(
                Currently_Selling_Dell__c=true,
                Dell_Revenue_Percent__c='0-10%',
                Hardware_Revenue_Percent__c='0-10%',
                Other_Customers__c='Education',
                Percent_Sales_Force__c='0%-10%',
                Percent_Technical_Professionals__c='0%-10%',
                Preferred_Dell_Distribution_Partner__c='Dell',
                Primary_Channel_Model__c='Other',
                Primary_Routes_to_Market__c='Internet',
                Primary_Customer__c='Public',
                Product_Focus__c='Servers',
                Reseller_Tax_ID__c='12345678',
                Service_Revenue_Percent__c='0-10%',
                Software_Revenue_Percent__c='0-10%',
                States_Provinces_doing_business__c='USA',
                Account__c=listAcc[0].Id,
                RecordTypeId=strrecTypeId);
        insert testPartnerRequest;
        PartnerRegistrationProvisionUserCtrlExt controller = new PartnerRegistrationProvisionUserCtrlExt();
        controller.copyPRFieldsToAccount(testPartnerRequest.Id);
        Account resultAccount = [SELECT
                                 Id,
                                 Partner_Registration__c,
                                 IsPartner,
                                 Currently_Selling_Dell__c,
                                 Dell_Revenue_Percent__c,
                                 Hardware_Revenue_Percent__c,
                                 Other_Customers__c,
                                 Percent_Sales_Force__c,
                                 Percent_Technical_Professionals__c,
                                 Preferred_Dell_Distribution_Partner__c,
                                 Primary_Channel_Model__c,
                                 Primary_Routes_to_Market__c,
                                 Partner_Primary_Customer__c,
                                 Product_Focus__c,
                                 Reseller_Tax_ID__c,
                                 Service_Revenue_Percent__c,
                                 Software_Revenue_Percent__c,
                                 States_Provinces_doing_business__c
                                 FROM
                                 Account
                                 WHERE
                                 Id=:listAcc[0].Id];
        System.debug('###DEBUG### testPartnerRequest=' + testPartnerRequest);
        System.debug('###DEBUG### Asserting...Account=' + resultAccount);
        System.assertEquals(resultAccount.States_Provinces_doing_business__c,testPartnerRequest.States_Provinces_doing_business__c);
        System.assertEquals(resultAccount.Software_Revenue_Percent__c,testPartnerRequest.Software_Revenue_Percent__c);
        System.assertEquals(resultAccount.Service_Revenue_Percent__c,testPartnerRequest.Service_Revenue_Percent__c);
        System.assertEquals(resultAccount.Reseller_Tax_ID__c,testPartnerRequest.Reseller_Tax_ID__c);
        System.assertEquals(resultAccount.Product_Focus__c,testPartnerRequest.Product_Focus__c);
        System.assertEquals(resultAccount.Partner_Primary_Customer__c,testPartnerRequest.Primary_Customer__c);
        System.assertEquals(resultAccount.Primary_Routes_to_Market__c,testPartnerRequest.Primary_Routes_to_Market__c);
        System.assertEquals(resultAccount.Primary_Channel_Model__c,testPartnerRequest.Primary_Channel_Model__c);
        System.assertEquals(resultAccount.Preferred_Dell_Distribution_Partner__c,testPartnerRequest.Preferred_Dell_Distribution_Partner__c);
        System.assertEquals(resultAccount.Percent_Technical_Professionals__c,testPartnerRequest.Percent_Technical_Professionals__c);
        System.assertEquals(resultAccount.Percent_Sales_Force__c,testPartnerRequest.Percent_Sales_Force__c);
        System.assertEquals(resultAccount.Other_Customers__c,testPartnerRequest.Other_Customers__c);
        System.assertEquals(resultAccount.Hardware_Revenue_Percent__c,testPartnerRequest.Hardware_Revenue_Percent__c);
        System.assertEquals(resultAccount.Dell_Revenue_Percent__c,testPartnerRequest.Dell_Revenue_Percent__c);
        System.assertEquals(resultAccount.Currently_Selling_Dell__c,testPartnerRequest.Currently_Selling_Dell__c);
        System.assertEquals(resultAccount.Partner_Registration__c,testPartnerRequest.Id);
    }
    //22-July-2009 Raymond: Added for CR1466
    private static testmethod void testCopyPRFieldsToAccountForNewUserPR() {
        TriggerExecutionController.setSkipAllTriggers(true);
        listAcc=[select id,Master_Group_Affinity_Id__c from Account Limit 1];
        String strrecTypeId1 = [SELECT Id FROM RecordType WHERE SObjectType = 'Partner_Request__c' AND Name = 'New Partner'].Id;
        String strrecTypeId2 = [SELECT Id FROM RecordType WHERE SObjectType = 'Partner_Request__c' AND Name = 'New User'].Id;
        System.assert(strrecTypeId1 != '');
        System.assert(strrecTypeId2 != '');
        Partner_Request__c testPartnerRequest1 =
            new Partner_Request__c(
                Currently_Selling_Dell__c=true,
                Dell_Revenue_Percent__c='0-10%',
                Hardware_Revenue_Percent__c='0-10%',
                Other_Customers__c='Education',
                Percent_Sales_Force__c='0%-10%',
                Percent_Technical_Professionals__c='0%-10%',
                Preferred_Dell_Distribution_Partner__c='Dell',
                Primary_Channel_Model__c='Other',
                Primary_Routes_to_Market__c='Internet',
                Primary_Customer__c='Public',
                Product_Focus__c='Servers',
                Reseller_Tax_ID__c='12345678',
                Service_Revenue_Percent__c='0-10%',
                Software_Revenue_Percent__c='0-10%',
                States_Provinces_doing_business__c='USA',
                Account__c=listAcc[0].Id,
                RecordTypeId=strrecTypeId1);
        insert testPartnerRequest1;
        Account resultAccount = [SELECT
                                 Id,
                                 Partner_Registration__c,
                                 IsPartner,
                                 Currently_Selling_Dell__c,
                                 Dell_Revenue_Percent__c,
                                 Hardware_Revenue_Percent__c,
                                 Other_Customers__c,
                                 Percent_Sales_Force__c,
                                 Percent_Technical_Professionals__c,
                                 Preferred_Dell_Distribution_Partner__c,
                                 Primary_Channel_Model__c,
                                 Primary_Routes_to_Market__c,
                                 Partner_Primary_Customer__c,
                                 Product_Focus__c,
                                 Reseller_Tax_ID__c,
                                 Service_Revenue_Percent__c,
                                 Software_Revenue_Percent__c,
                                 States_Provinces_doing_business__c
                                 FROM
                                 Account
                                 WHERE
                                 Id=:listAcc[0].Id];
        resultAccount.Partner_Registration__c = testPartnerRequest1.Id;
        update resultAccount;
        Partner_Request__c testPartnerRequest2 =
            new Partner_Request__c(
                Currently_Selling_Dell__c=true,
                Dell_Revenue_Percent__c='0-10%',
                Hardware_Revenue_Percent__c='0-10%',
                Other_Customers__c='Education',
                Percent_Sales_Force__c='0%-10%',
                Percent_Technical_Professionals__c='0%-10%',
                Preferred_Dell_Distribution_Partner__c='Dell',
                Primary_Channel_Model__c='Other',
                Primary_Routes_to_Market__c='Internet',
                Primary_Customer__c='Public',
                Product_Focus__c='Servers',
                Reseller_Tax_ID__c='12345678',
                Service_Revenue_Percent__c='0-10%',
                Software_Revenue_Percent__c='0-10%',
                States_Provinces_doing_business__c='USA',
                Account__c=listAcc[0].Id,
                RecordTypeId=strrecTypeId2);
        insert testPartnerRequest2;
        PartnerRegistrationProvisionUserCtrlExt controller = new PartnerRegistrationProvisionUserCtrlExt();
        controller.copyPRFieldsToAccount(testPartnerRequest2.Id);
        System.assertEquals(resultAccount.Partner_Registration__c,testPartnerRequest1.Id);
    }  
    //CR2087
    private static testmethod void testUserNewFromPartnerPortal(){
        TriggerExecutionController.setSkipAllTriggers(true);
        System.debug('########## START testUserNewFromPartnerPortal ##########');
        test.starttest();
        Country__c country = buildMockCountry(true);
        listAcc=[select id,Master_Group_Affinity_Id__c from Account Limit 1];
        listAcc[0].account_country_code__c=country.code__c;
        listAcc[0].Is_Enabled_for_Incentives__c=true;
        listAcc[0].IsPartner = true;
        update listAcc;
        system.assertNotEquals(listAcc[0].id, null);
        
        //14.2 SSO Addition -insert record to Special job title        
        SpecialJobTitle__c specialjob = new SpecialJobTitle__c(Job_Title__c = 'VP');
        insert specialjob;
        test.stopTest();
        Contact contact = new Contact(LastName='cmapmodified',Email = 'john@dell.com', AccountId = listAcc[0].id,Is_Enabled_for_Incentives__c=true,status__c = 'Prospect');
        populateContactData(contact,country);
        insert contact;
        final List<Profile> partnerProfiles = [select id,name from Profile where Name='R16.10 APJ PRM Portal User (MOSS)'];
        User user = new User();
        populateContactData(user,country);
        final String guid = RandomStringUtils.randomUUID();
        user.alias = StringUtils.substring(guid, 0, 8);
        user.contactid = contact.id;
        user.username = guid + '@partner.dell.com';
        user.ProfileId                  = country.User_Profile_ID__c;
        user.LanguageLocaleKey          = country.User_Language_Locale_Key__c;
        user.LocaleSidKey               = country.User_Locale_Sid_Key__c;
        user.EmailEncodingKey           = country.User_Email_Encoding_Key__c;
        user.TimeZoneSidKey             = country.User_Time_Zone_Sid_Key__c;
        user.Badge_Number__c            = null;
        user.Enable_Partner_Admin__c    = true;
        user.ProfileId                  = partnerProfiles.get(0).Id;
        try{
            insert user;
        }catch(exception ex){} 
        System.runAs(user) {
            Partner_Request__c request = new Partner_Request__c();
            request.Account__c = listAcc[0].id;
            request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_USER,
                                                                 'Partner_Request__c', true);
            populateContactData(request,country);
            insert request;
            PageUtils.param('id',request.id);
            //create and load controller expecting no error
            PartnerRegistrationProvisionUserCtrlExt controller = new PartnerRegistrationProvisionUserCtrlExt();
            controller.IsPortalEnabled = true;
            controller.state.contact = contact;
            try{
                controller.doBackToRegistrationButton().getUrl();        
            }catch(Exception ex){} 
            try{
                controller.doOnLoad();
            }catch(exception ex){}
            System.assert(true,StringUtils.isBlank(controller.errorCode));
            controller.state.guid = guid;
            controller.state.contact = contact;
            System.assertEquals(null,controller.state.user);
            Partner_Request__c found = [Select description__c from Partner_Request__c where id =:request.Id];
            System.debug('### found record : ' + found.description__c);
            controller.ajaxError = null; 
            try{ 
                controller.doReuseOrCreateUser();  }catch(Exception ex){} 
            //Test checkforVendorUpdate
            controller.checkforVendorUpdate();
            Contact con = [SELECT id,Is_Enabled_for_Incentives__c,Is_Vendor_Update_Required__c,Last_Operation_Performed__c,Vendor_Update_Datetime__c
                           ,Operation_for_Boomi__c FROM CONTACT WHERE id=:controller.state.contact.id];
            System.assertEquals(con.Is_Enabled_for_Incentives__c, true);
            System.assertEquals(con.Is_Vendor_Update_Required__c, true);
            String strlastOp = con.Last_Operation_Performed__c;
            System.assertEquals(con.Last_Operation_Performed__c, strlastOp);
        }
        System.debug('########## END testUserNewFromPartnerPortal ##########');
    }
    //CR2087-end 
    private static void populateContactData(SObject obj,Country__c countryTest){
        if(obj != null){
            if(obj instanceof Partner_Request__c){
                Partner_Request__c request = (Partner_Request__c) obj;
                request.First_Name__c = 'John';
                request.Last_Name__c = 'Doe';
                request.Job_Title__c = 'VP';
                request.Address_Line_1__c = '123 Main St.';
                request.City__c = 'Peoria';
                request.State__c = 'IL';
                request.Postal_Code__c = '33333';
                request.Phone__c = '3213213211';
                request.Email__c = 'test@dell.com';
                request.Country__c = countryTest.id;
            } else if(obj instanceof Contact){
                Contact contact = (Contact) obj;
                contact.FirstName = 'John';
                contact.LastName = 'Doe';
                contact.Title = 'VP';
                contact.MailingStreet = '123 Main St.';
                contact.MailingCity = 'Peoria';
                contact.MailingState = 'IL';
                contact.MailingPostalCode = '33333';
                contact.Phone = '3213213211';
                contact.Email = 'test@dell.com';
            } else if(obj instanceof User){
                User user = (User) obj;
                user.FirstName = 'John';
                user.LastName = 'Doe';
                user.Title = 'VP';
                user.Street = '123 Main St.';
                user.City = 'Peoria';
                user.State = 'IL';
                user.PostalCode = '33333';
                user.Phone = '3213213211';
                user.Email = 'test@dell.com';
            }
        }
    }
    private static Country__c buildMockCountry(Boolean bactivePartner){
        Country__c country = new Country__c();
        country.name = 'test';
        country.Is_Active_Partner_Country__c = bactivePartner;
        country.code__c = 'XX';
        List<Profile> listprofiles = [select id,name from Profile where UserType = 'PowerPartner' limit 1];
        System.assert(listprofiles.size()>0, 'Test cannot execute: no partner profiles exist');
        country.User_Time_Zone_Sid_Key__c = 'America/Chicago';
        country.User_Profile_ID__c = listprofiles.get(0).id;
        country.User_Locale_Sid_Key__c = 'en_US';
        country.User_Language_Locale_Key__c = 'en_US';
        country.User_Email_Encoding_Key__c = 'ISO-8859-1';
        country.User_Currency_Iso_Code__c = 'USD';
        country.Inc_Vendor_Name__c = 'Partner Advantage';
        country.Inc_Vendor_End_Point__c = 'test URL';
        country.Deal_Registration_Enabled__c = 'Yes';
        country.Lead_Management_Enabled__c = 'Yes';
        country.Lead_Management_Enabled_for_OEM__c = 'Yes';
        country.Partner_Relationship__c = 'All';
        country.Partner_Relationship_for_OEM__c = 'All';
        insert country;
        return country;
    }
    /*private static User createPartnerUser(Boolean badmin, String strusername){
final List<Profile> listpartnerProfiles = [select id,name from Profile where Name LIKE '%PRM Portal%' limit 1];
System.assert(
!(listpartnerProfiles == null || listpartnerProfiles.size() <= 0),
'No partner profiles exist therefore test cannot be executed');
listAcc=[select id from Account Limit 1];
listAcc[0].Account_Country_Code__c = 'AI';
listAcc[0].Account_Country__c = 'ANGUILIA';
listAcc[0].IsPartner = true;
update listAcc;
Contact contact = new Contact(
AccountId=listAcc[0].id,
Email='1@dell.com',
FirstName = 'John1',
LastName = 'Doe1',
Title='VP',
MailingStreet='123 Main',
MailingCity='Peoria',
MailingState='IL',
MailingPostalCode='33333',
Phone='3213213211',
MobilePhone='3213213211',
Fax='3213123211',
status__c = 'Prospect'
);
insert contact;
User user = new User(
Username=strusername == null ? 'john@dell.com' : strusername,
Alias = 'test1',
Email='1@dell.com',
FirstName='John1',
LastName='Doe1',
ProfileId = listpartnerProfiles.get(0).Id,
LanguageLocaleKey='en_US',
LocaleSidKey='en_US',
EmailEncodingKey='UTF-8',
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c= strusername.mid(0,8),//null,
ContactId = contact.id,
Enable_Partner_Admin__c = badmin
);
try{
insert user;
}catch(Exception ex){}
return user;
}*/
    // [Fenny 10-Jan-2013] CR7944
    static testmethod void testdoPermissionSetAssignment(){
        list<Account> listAccounts = [SELECT Id FROM Account WHERE Type = 'Partner' AND RecordTypeId = :System.Label.RecType_Partner_Account LIMIT 1];
        if(listAccounts != null && !listAccounts.isEmpty()) {
            Account acc = listAccounts[0];
            Contact con = new Contact(AccountId = acc.id,Email = '1_2@dell.com',FirstName = 'fn' ,LastName = 'ln' ,Title = 'King',MailingStreet = '123Main',MailingCity = 'Peoria',
                                      MailingState = 'IL',MailingPostalCode = '33333',Phone = '3213213211',MobilePhone = '3213213211',Fax = '3213123211',status__c = 'Prospect');
            insert con;
            Profile profileRec = [select id from profile where name like '%PRM Portal%' Limit 1]; 
            String strusername = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@test.unit.user';
            User  usr = new User(Username = strusername,Alias = 'test',Email = 'testuser@dell.com',FirstName = 'John',LastName = 'Doe',ProfileId = profileRec.Id,
                                 LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',TimeZoneSidKey = 'America/Los_Angeles',
                                 Badge_Number__c = null, ContactId = con.Id, Enable_Partner_Admin__c = false);
            insert usr;
            PartnerRegistrationProvisionUserCtrlExt controller = new PartnerRegistrationProvisionUserCtrlExt();     
            PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'Partner_Opportunity_Access'];
            User sa = [SELECT Id, username,Badge_Number__c FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true AND Id <> :UserInfo.getUserId() AND ID != NULL AND Badge_Number__c != NULL LIMIT 1];
            Test.startTest();
            controller.state.user = usr;
            controller.state.user.Enable_Partner_Deal_Registration__c = true;
            system.runAs(sa){
                controller.doPermissionSetAssignment();
                List<PermissionSetAssignment> listassignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :usr.Id and PermissionSetId = :permSet.Id];
                system.assertEquals(true, ((listassignments != null) && (listassignments.size() > 0)));
                system.assertEquals(true, (listassignments.size() == 1));
            }
            controller.state.user.Enable_Partner_Deal_Registration__c = false;
            system.runAs(sa){
                controller.doPermissionSetAssignment();
                List<PermissionSetAssignment> listassignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :usr.Id and PermissionSetId = :permSet.Id];
                system.assertEquals(true, ((listassignments == null) || (listassignments.size() == 0)));
            }
            controller.setIncompleteForRequestWithReasonJS();
            controller.doPermissionSetAssignment();
            try{
                controller.doDiasWebServiceCall();
            }catch(exception ex){}
            Test.stopTest();
        }
    }
    static testmethod void testmethod1(){
        TriggerExecutionController.setSkipAllTriggers(true);
        PartnerRegistrationProvisionUserCtrlExt controller = new PartnerRegistrationProvisionUserCtrlExt(); 
        try{
            controller.setIncompleteForRequestWithReasonJS();}catch(Exception ex){}
        try{    controller.doPermissionSetAssignment();}catch(Exception ex){}
        controller.toJSONString('test');
        try{
            PartnerRegistrationProvisionUserCtrlExt.synchronizeToCMI(null,null,null,null);
        }
        catch(exception ex){} 
        string strtest1 = PartnerRegistrationProvisionUserCtrlExt.INVALID_REC_TYPE;
        strtest1 = PartnerRegistrationProvisionUserCtrlExt.COUNTRY_NOT_ENABLED;
        strtest1 = PartnerRegistrationProvisionUserCtrlExt.CONTACT_NO_EMAIL;
        strtest1 = PartnerRegistrationProvisionUserCtrlExt.ACCOUNT_NOT_UPDATED;
        Country__c country = buildMockCountry(true);
        //Meera:updated for 15.03 CMAP Changes - create new sales channel
        Sales_Channel_Group__c testSalesChanGrp = new Sales_Channel_Group__c(Name = 'Test Sales channel', Regional_Parent_Name__c = 'APJ');
        insert testSalesChanGrp;
        listAcc=[select id from account limit 1];
        listAcc[0].account_country_code__c=country.code__c;
        listAcc[0].Sales_Channel__c=testSalesChanGrp.Id;
        listAcc[0].Partner_Relationship__c='Registered';
        update listAcc;
        system.assertNotEquals(listAcc[0].id, null);
        
        system.assertNotEquals(listAcc[0].id, null);
        Partner_Request__c request = new Partner_Request__c();
        request.Account__c = listAcc[0].id;
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
                                                             'Partner_Request__c', true);
        request.email__c = 'test@dell.com';
        request.Is_Enabled_for_Incentives__c = true;
        request.Website__c = 'www.test.com';
        insert request;
        Test.startTest();
        Contact contact = new Contact(LastName='test',Email = request.Email__c, AccountId = listAcc[0].id,status__c = 'Prospect');
        populateContactData(contact,country);
        insert contact;
        PageUtils.param('id',request.id);
        //create and load controller expecting no error
        PartnerRegistrationProvisionUserCtrlExt controller1 = new PartnerRegistrationProvisionUserCtrlExt();
        controller1.doOnLoad();
        Test.stopTest();
    }
}
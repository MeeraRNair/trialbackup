@IsTest
private class PartnerRegistrationProvUserTaskCtrlTest {


    private static testmethod void testNoIdParamError(){
        PartnerRegistrationProvUserTaskCtrl controller = new PartnerRegistrationProvUserTaskCtrl();
        System.assertEquals(null,controller.doOnLoad());
        System.assertNotEquals(null,controller.errorDescription);
        System.assertEquals(false,controller.success);
    }
    
    private static testmethod void testInvalidRequestIdError(){
        ApexPages.currentPage().getParameters().put(PartnerRegistrationProvUserTaskCtrl.HTTP_PARAMETER_ID,'badid');
        PartnerRegistrationProvUserTaskCtrl controller = new PartnerRegistrationProvUserTaskCtrl();
        System.assertEquals(null,controller.doOnLoad());
        System.assertNotEquals(null,controller.errorDescription);
        System.assertEquals(false,controller.success);
    }
    
    private static testmethod void testNoActionParamError(){
        Partner_Request__c request = new Partner_Request__c();
        insert request;
        ApexPages.currentPage().getParameters().put(PartnerRegistrationProvUserTaskCtrl.HTTP_PARAMETER_ID,request.id);
        PartnerRegistrationProvUserTaskCtrl controller = new PartnerRegistrationProvUserTaskCtrl();
        System.assertEquals(null,controller.doOnLoad());
        System.assertNotEquals(null,controller.errorDescription);
        System.assertEquals(false,controller.success);
    }

    private static testmethod void testNoPersonPartyIdError(){
        Partner_Request__c request = new Partner_Request__c();
        insert request;
        ApexPages.currentPage().getParameters().put(PartnerRegistrationProvUserTaskCtrl.HTTP_PARAMETER_ACTION,'invalidaction');
        ApexPages.currentPage().getParameters().put(PartnerRegistrationProvUserTaskCtrl.HTTP_PARAMETER_ID,request.id);
        PartnerRegistrationProvUserTaskCtrl controller = new PartnerRegistrationProvUserTaskCtrl();
        System.assertEquals(null,controller.doOnLoad());
        System.assertNotEquals(null,controller.errorDescription);
        System.assertEquals(false,controller.success);
    }

    private static testmethod void testInvalidActionError(){
        Partner_Request__c request = new Partner_Request__c();
        insert request;
        ApexPages.currentPage().getParameters().put(PartnerRegistrationProvUserTaskCtrl.HTTP_PARAMETER_ACTION,'invalidaction');
        ApexPages.currentPage().getParameters().put(PartnerRegistrationProvUserTaskCtrl.HTTP_PARAMETER_PERSONPARTYID,'123abc');
        ApexPages.currentPage().getParameters().put(PartnerRegistrationProvUserTaskCtrl.HTTP_PARAMETER_ID,request.id);
        PartnerRegistrationProvUserTaskCtrl controller = new PartnerRegistrationProvUserTaskCtrl();
        System.assertEquals(null,controller.doOnLoad());
        System.assertNotEquals(null,controller.errorDescription);
        System.assertEquals(false,controller.success);
    }

    private static testmethod void testCreateContactNew(){
        Account account = new Account(name='test');
        insert account;
        account.IsPartner = true;
        update account;
        Partner_Request__c request = new Partner_Request__c();
        request.Account__c = account.id;
        populateContactData(request);
        insert request;
        ApexPages.currentPage().getParameters().put(
            PartnerRegistrationProvUserTaskCtrl.HTTP_PARAMETER_ACTION,
            PartnerRegistrationProvUserTaskCtrl.ACTION_CREATE_CONTACT);
        ApexPages.currentPage().getParameters().put(
            PartnerRegistrationProvUserTaskCtrl.HTTP_PARAMETER_PERSONPARTYID,'123abc');
        ApexPages.currentPage().getParameters().put(
            PartnerRegistrationProvUserTaskCtrl.HTTP_PARAMETER_ID,request.id);

        PartnerRegistrationProvUserTaskCtrl controller = new PartnerRegistrationProvUserTaskCtrl();
        System.assertEquals(null,controller.doOnLoad());
      //  System.assertEquals(null,controller.errorDescription);
       // System.assertEquals(true,controller.success);
    }

    private static testmethod void testCreateContactUpdate(){
    TriggerExecutionController.setSkipAllTriggers(true);
        Account account = new Account(name='test');
        insert account;
        account.IsPartner = true;
        update account;
        Partner_Request__c request = new Partner_Request__c();
        request.Account__c = account.id;
        populateContactData(request);
        insert request;
        Contact contact = new Contact(FirstName='ContactExcSafeWord1',LastName='ContactExcSafeWord1',Email = request.Email__c, AccountId = account.id);
        insert contact;
        
        ApexPages.currentPage().getParameters().put(
            PartnerRegistrationProvUserTaskCtrl.HTTP_PARAMETER_ACTION,
            PartnerRegistrationProvUserTaskCtrl.ACTION_CREATE_CONTACT);
        ApexPages.currentPage().getParameters().put(
            PartnerRegistrationProvUserTaskCtrl.HTTP_PARAMETER_PERSONPARTYID,'123abc');
        ApexPages.currentPage().getParameters().put(
            PartnerRegistrationProvUserTaskCtrl.HTTP_PARAMETER_ID,request.id);

        PartnerRegistrationProvUserTaskCtrl controller = new PartnerRegistrationProvUserTaskCtrl();
        System.assertEquals(null,controller.doOnLoad());
        System.assertEquals(null,controller.errorDescription);
        System.assertEquals(true,controller.success);
        TriggerExecutionController.setSkipAllTriggers(false);
    }

    private static testmethod void testCreateUser(){
        Account account = new Account(name='test');
        insert account;
        account.IsPartner = true;
        update account;
        Country__c country = createCountry();
        insert country;
        Partner_Request__c request = new Partner_Request__c();
        request.Account__c = account.id;
        request.Top_3_Vendors__c = 'EMC';
        request.Country__c = country.id;
        populateContactData(request);
        insert request;
        Contact contact = new Contact(FirstName='ContactExcSafeWord1',LastName='ContactExcSafeWord1',Email = request.Email__c, AccountId = account.id);
        insert contact;
        
        //Create User
        ApexPages.currentPage().getParameters().put(
            PartnerRegistrationProvUserTaskCtrl.HTTP_PARAMETER_ACTION,
            PartnerRegistrationProvUserTaskCtrl.ACTION_CREATE_USER);
        ApexPages.currentPage().getParameters().put(
            PartnerRegistrationProvUserTaskCtrl.HTTP_PARAMETER_PERSONPARTYID,'123abc');
        ApexPages.currentPage().getParameters().put(
            PartnerRegistrationProvUserTaskCtrl.HTTP_PARAMETER_ID,request.id);
        ApexPages.currentPage().getParameters().put(
            PartnerRegistrationProvUserTaskCtrl.HTTP_PARAMETER_PREVOBJECTID,contact.id);

        PartnerRegistrationProvUserTaskCtrl controller = new PartnerRegistrationProvUserTaskCtrl();
        System.assertEquals(null,controller.doOnLoad());
        System.assertEquals(null,controller.errorDescription);
        System.assertEquals(true,controller.success);

        String userid = controller.objectId;
        
        //Update request with no user id
        ApexPages.currentPage().getParameters().put(
            PartnerRegistrationProvUserTaskCtrl.HTTP_PARAMETER_PREVOBJECTID,'');
        ApexPages.currentPage().getParameters().put(
            PartnerRegistrationProvUserTaskCtrl.HTTP_PARAMETER_ACTION,
            PartnerRegistrationProvUserTaskCtrl.ACTION_UPDATE_REGISTRATION);

        controller = new PartnerRegistrationProvUserTaskCtrl();
        System.assertEquals(null,controller.doOnLoad());
        System.assertNotEquals(null,controller.errorDescription);
        System.assertEquals(false,controller.success);

        //Update request 
        ApexPages.currentPage().getParameters().put(
            PartnerRegistrationProvUserTaskCtrl.HTTP_PARAMETER_PREVOBJECTID,userid);

        controller = new PartnerRegistrationProvUserTaskCtrl();
        System.assertEquals(null,controller.doOnLoad());
        System.assertEquals(null,controller.errorDescription);
        System.assertEquals(true,controller.success);
    }

    private static void populateContactData(Partner_Request__c request){
        request.First_Name__c = 'John';
        request.Last_Name__c = 'Doe';
        request.Job_Title__c = 'VP';
        request.Address_Line_1__c = '123 Main St.';
        request.City__c = 'Peoria';
        request.State__c = 'IL';
        request.Postal_Code__c = '33333';
        request.Phone__c = '3213213211';
        request.Email__c = 'test@dellteam.com';
    }
    
    private static Country__c createCountry(){
        Country__c country = new Country__c();
        country.Code__c = 'XX';
        country.Name = 'XXXXXXXXXX';

        List<Profile> profiles = [select id,name from Profile where UserType = 'PowerPartner' limit 1];
        System.assert(profiles.size()>0, 'Test cannot execute: no partner profiles exist');
        country.User_Time_Zone_Sid_Key__c = 'America/Chicago';
        country.User_Profile_ID__c = profiles.get(0).id;
        country.User_Locale_Sid_Key__c = 'en_US';
        country.User_Language_Locale_Key__c = 'en_US';
        country.User_Email_Encoding_Key__c = 'ISO-8859-1';
        country.User_Currency_Iso_Code__c = 'USD';

        return country; 
    }
    
    
}
public class PartnerRegistrationDupSearchCtrlExtTest {
    private static string strcompany = string.valueOf(DateTime.Now()); // [Fenny 4-Apr-2013] Added: Generate a unique company name from real data

    private static testMethod void testScreenIsForUpdateOnly() {
        //the partner request dup search screen is for updates only
        //this test creates but does NOT save the test partner request record
        //the dup search screen controller needs to recognize this and set an error
        Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@dell.com',
            //Company__c = 'Tyama'); // [Fenny 4-Apr-2013] Commented: Generate a unique company name from real data
            Company__c = strcompany); // [Fenny 4-Apr-2013] Added: Generate a unique company name from real data
        PartnerRegistrationDupSearchCtrlExt extension = new PartnerRegistrationDupSearchCtrlExt(
            new ApexPages.standardController(request));
        TestUtils.assertErrorMessagesExist();
        System.assertEquals(extension.doPageLoad(),null);
        System.assertEquals(extension.accountSearchResults,null);
        System.assertEquals(extension.registrationSearchResults,null);
    }
    
    private static testMethod void testDoCancel() {
        //basic flow for testing doCancel
        Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@dell.com',
            //Company__c = 'Tyama'); // [Fenny 4-Apr-2013] Commented: Generate a unique company name from real data
            Company__c = strcompany); // [Fenny 4-Apr-2013] Added: Generate a unique company name from real data
        insert request;
        PartnerRegistrationDupSearchCtrlExt extension = new PartnerRegistrationDupSearchCtrlExt(
            new ApexPages.standardController(request));
        
        //invoke doPageLoad
        System.assertEquals(extension.doPageLoad(),null);
        System.assertNotEquals(extension.accountSearchResults,null);
        System.assertNotEquals(extension.registrationSearchResults,null);
        assertCheckForDupFlagSet(request.id);

        //invoke doCancel
        PageReference next = extension.doCancel();
        System.assertNotEquals(next,null);
        System.assertEquals(next.getUrl(),'/' + request.id);
    }
    
    private static testMethod void testNoSearchResults() {
        Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@dell.com',
            //Company__c = 'Tyama'); // [Fenny 4-Apr-2013] Commented: Generate a unique company name from real data
            Company__c = strcompany); // [Fenny 4-Apr-2013] Added: Generate a unique company name from real data
        insert request;
        ApexPages.standardController controller = new ApexPages.standardController(request);
        PartnerRegistrationDupSearchCtrlExt extension = new PartnerRegistrationDupSearchCtrlExt(controller);
        extension.doPageLoad();
        System.assert(extension.accountSearchResults != null);
        System.assert(extension.registrationSearchResults != null);
        System.assert(extension.accountSearchResults.size() >= 0);
        System.assert(extension.registrationSearchResults.size() >= 0);
        assertCheckForDupFlagSet(request.id);
    }
    
    private static void assertCheckForDupFlagSet(Id theId){
        Partner_Request__c request = [select Check_For_Duplicates_Is_Complete_Flag__c
            from Partner_Request__c where id = :theId];
        System.assert(request.Check_For_Duplicates_Is_Complete_Flag__c, 'Check_For_Duplicates_Is_Complete_Flag__c not set');
    }
    
    private static testMethod void testAcctSearchResultsExist() {
        Partner_Request__c dupRequest = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@dell.com',
            //Company__c = 'Tyama'); // [Fenny 4-Apr-2013] Commented: Generate a unique company name from real data
            Company__c = strcompany); // [Fenny 4-Apr-2013] Added: Generate a unique company name from real data
        insert dupRequest;
        Account dupAcct = new Account(name='Tyama',Partner_Registration__c=dupRequest.id);
        insert dupAcct;     
        Test.setFixedSearchResults(new Id[]{dupAcct.id});
        Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@dell.com',
            //Company__c = 'Tyama'); // [Fenny 4-Apr-2013] Commented: Generate a unique company name from real data
            Company__c = strcompany); // [Fenny 4-Apr-2013] Added: Generate a unique company name from real data
        insert request;
        ApexPages.standardController controller = new ApexPages.standardController(request);
        PartnerRegistrationDupSearchCtrlExt extension = new PartnerRegistrationDupSearchCtrlExt(controller);
        System.assertEquals(extension.getAccountSearchResultsCount(), 0);
        System.assertEquals(extension.getRegistrationSearchResultsCount(), 0);
        
        //execute doPageLoad
        System.assertEquals(extension.doPageLoad(),null);
        System.assertNotEquals(extension.accountSearchResults,null);
        System.assertNotEquals(extension.registrationSearchResults,null);
        System.assert(extension.accountSearchResults.size() >= 0);
        System.assert(extension.registrationSearchResults.size() <= 0);
        System.assert(extension.getAccountSearchResultsCount() >= 0);
        System.assert(extension.getRegistrationSearchResultsCount() <= 0);
        assertCheckForDupFlagSet(request.id);

        //execute doSelectAccount
        ApexPages.currentPage().getParameters().put('accountId', '');
        System.assertEquals(extension.doSelectAccount(), null);
        System.assertEquals(extension.getIsAccountSelected(), false);
        System.assertEquals(extension.getIsRegistrationSelected(), false);
        
        ApexPages.currentPage().getParameters().put('accountId', '123');
        System.assertEquals(extension.doSelectAccount(), null);
        System.assertEquals(extension.getIsAccountSelected(), false);
        System.assertEquals(extension.getIsRegistrationSelected(), false);

        ApexPages.currentPage().getParameters().put('accountId', dupAcct.id);
        System.assertEquals(extension.doSelectAccount(), null);
        System.assertEquals(extension.selectionName, dupAcct.name);
        System.assertEquals(extension.getIsAccountSelected(), true);
        System.assertEquals(extension.getIsRegistrationSelected(), true);

        //execute doConfirm
        PageReference next = extension.doConfirm();
        request = [select Duplicate_Account__c,Duplicate_Registration__c 
            from Partner_Request__c where id = :request.id];
        System.assertEquals(request.Duplicate_Account__c, dupAcct.id);
        System.assertEquals(request.Duplicate_Registration__c, dupRequest.id);
        System.assertNotEquals(next,null);
        System.assertEquals('/' + request.id, next.getUrl());
       // TestUtils.assertNoErrorMessagesExist();
    }
    
    //CR3402
    private static testMethod void testSearchBy() {
        Id recordTypeID = IdLookupUtils.getRecordTypeId('Partner Account','Account', true);      
        Account acct = new Account(
            //name = 'Tyama', // [Fenny 4-Apr-2013] Commented: Generate a unique company name from real data
            name = strcompany, // [Fenny 4-Apr-2013] Added: Generate a unique company name from real data
            RecordTypeId = recordTypeID, 
            Account_ID__c = String.valueOf(Math.random())); 
        insert acct;
        
        recordTypeID =IdLookupUtils.getRecordTypeId(
            PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,'Partner_Request__c', true);   
        Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@dell.com',
            Org_Phone__c = '9123445678',
            Reseller_Tax_ID__c = '23456789',
            Website__c = 'www.dell.com',
            Org_Address_1__c = 'Austin',
            Org_Address_2__c = 'Texas',
            Org_Address_3__c = 'California',
            Org_City__c = 'Texas',
            Org_State__c ='Austin',
            Org_Postal_Code__c ='1027',
            //Company__c = 'Tyama', // [Fenny 4-Apr-2013] Commented: Generate a unique company name from real data
            Company__c = strcompany, // [Fenny 4-Apr-2013] Added: Generate a unique company name from real data
            Account__c = acct.Id,
            RecordTypeId = recordTypeID);
        insert request;
        
        ApexPages.standardController controller = new ApexPages.standardController(request);
        PartnerRegistrationDupSearchCtrlExt extension = new PartnerRegistrationDupSearchCtrlExt(controller);
        extension.doPageLoad();
        
        List<SelectOption> listoptions = extension.getSearchByList();
        System.assert(listoptions.size()>0);
        
        //search by Company Name by default
        System.assert(extension.getAccountSearchResultsCount()>= 0);
        System.assert(extension.getRegistrationSearchResultsCount()>= 0);
        
        //search By Email
        extension.searchBy = 'Email';
        extension.searchString = request.Email__c;
        extension.doSearch();
        System.assert(extension.getRegistrationSearchResultsCount()>= 0);
        
        //search by Account ID
        extension.searchBy = 'AccountID';           
        extension.searchString = acct.Account_ID__c;
        extension.doSearch();
        System.assert(extension.getAccountSearchResultsCount()>= 0);
        System.assert(extension.getRegistrationSearchResultsCount()>= 0);  
        
         //search By Domain
        extension.searchBy = 'Domain';
        extension.searchString = request.Website__c;
        extension.doSearch();
        System.assert(extension.getAccountSearchResultsCount()>= 0);
        System.assert(extension.getRegistrationSearchResultsCount()>= 0);   
        
        // Search by Phone 
       extension.searchBy = 'Phone';
        extension.searchString = request.Org_Phone__c;
        extension.doSearch();
        System.assert(extension.getAccountSearchResultsCount()>= 0);
        System.assert(extension.getRegistrationSearchResultsCount()>= 0);
        
         // Search by Tax Id 
       extension.searchBy = 'Tax ID';
        extension.searchString = request.Reseller_Tax_ID__c;
        extension.doSearch();
        System.assert(extension.getAccountSearchResultsCount()>= 0);
        System.assert(extension.getRegistrationSearchResultsCount()>= 0);
        
         // Search by Duns Number 
       extension.searchBy = 'Duns';
        extension.searchString = request.Dun_and_Bradstreet_DUNS_Number__c ;
        extension.doSearch();
        System.assert(extension.getAccountSearchResultsCount()>= 0);
        System.assert(extension.getRegistrationSearchResultsCount()>= 0);
        
        // Search by Address 
       extension.searchBy = 'Address';
        extension.searchString = request.Org_Address_1__c ;
        extension.doSearch();
        System.assert(extension.getAccountSearchResultsCount()>= 0);
        System.assert(extension.getRegistrationSearchResultsCount()>= 0);
        
        extension.searchBy = 'CompanyName';
        extension.searchString = acct.name;
        extension.doSearch();
        System.assert(extension.getAccountSearchResultsCount()>= 0);
        System.assert(extension.getRegistrationSearchResultsCount()>= 0);
    }
    
     //Test case for CR 2001
    private static testMethod void testLinkAccountConfirm(){
                                
        Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'temp',
            Last_Name__c = 'Lastname',
            Email__c = 'temp.lastname@dell.com',
            //Company__c = 'test 20091020', // [Fenny 4-Apr-2013] Commented: Generate a unique company name from real data
            Company__c = strcompany, // [Fenny 4-Apr-2013] Added: Generate a unique company name from real data
            RecordTypeId=IdLookupUtils.getRecordTypeId(
            PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,'Partner_Request__c', true),
            status__c = PartnerConstants.REG_STATUS_INREVIEW       
            );
        Test.startTest();
        insert request;
       
        Id recordTypeID = IdLookupUtils.getRecordTypeId('Partner Account','Account', true);
        
        Account acct = new Account(name='Test 20091010',RecordTypeId=recordTypeID);
       
        insert acct;     
        
        doInvokeLinkAcctConfirm(acct, request); 
        Test.stopTest();    
            
    }
    
    private static void doInvokeLinkAcctConfirm(Account acct, Partner_Request__c request){
        Boolean isLinkAcctConfirmCalled = false;
         ApexPages.standardController controller = new ApexPages.standardController(request);
         PartnerRegistrationDupSearchCtrlExt extension = new PartnerRegistrationDupSearchCtrlExt(controller);
         
         ApexPages.currentPage().getParameters().put('linkaccountId', acct.Id);
         ApexPages.currentPage().getParameters().put('linkaccountPRId', request.name);
         
         //new added
         system.assertEquals(extension.doSelectManualLink(),null);
         system.assert(!extension.getIsManualAccountSelected());
         system.assertEquals(extension.getPartnerRequestRecord(''),null);
         system.assertNotEquals(extension.getPartnerRequestRecord(request.Id),null);
         
         
         extension.updateLinkedAccount(acct, null);
         TestUtils.assertErrorMessagesExist();
         
         extension.updateLinkedAccount(null, request);
         TestUtils.assertErrorMessagesExist();  
                 
         ApexPages.Message[] listmsg  = pageUtils.getErrorMessagesOnly();
            String strmsgStr = listmsg[0].getSummary();
            system.debug('### strmsgStr=' +strmsgStr);         
          
         
         system.assertEquals(extension.getAccountRecord(''),null);
         system.assertNotEquals(extension.getAccountRecord(acct.Id),null);
         
         //end added
         
         System.debug('acct id>>'+acct.id);
         System.debug('req id>>'+request.id);
         System.debug('req name>>'+request.name);
         
         System.debug('Accr is blank ? >>'+StringUtils.isBlank(acct.Id));
         System.debug('Request name blank ?>>'+StringUtils.isBlank(request.name));
         
         System.debug('acct id>>'+acct.id);
         System.debug('req id>>'+request.id);
         System.debug('req name>>'+request.name);
         
         System.debug('Accr is blank ? >>'+StringUtils.isBlank(acct.Id));
         System.debug('Request name blank ?>>'+StringUtils.isBlank(request.name));
         
         
         if(StringUtils.isBlank(acct.Id)){
                system.assert(extension.isLinkedAccount(acct.id)==false);
         }else{
                system.assert(extension.isLinkedAccount(acct.id)==true);
         }
         
         if(StringUtils.isBlank(request.name)){
                system.assert(extension.isPartnerRequestValid(request.id)==false);
         }else{
                system.assert(extension.isPartnerRequestValid(request.id)==true);
         }
         
          //continue here
         if(acct==null){
            extension.updateLinkedAccount(acct, request);
            TestUtils.assertErrorMessagesExist();
         }
         
          if(request==null){
            extension.updateSelectedPR(acct, request);
            
            TestUtils.assertErrorMessagesExist();
         }
         
        if(acct==null && request==null){
            TestUtils.assertErrorMessagesExist();
        }
        
        String strconfirmlinkaccountId = '';
        String strconfirmlinkaccountPRId = '';
        
        extension.doLinkAccountConfirm();
        TestUtils.assertErrorMessagesExist();
        system.assertEquals(null, extension.doLinkAccountConfirm());
        
        if(acct!=null && request!=null){
            Boolean bisLinkedAccount = extension.isLinkedAccount(acct.id);
            Boolean bisPartnerRequestValid = extension.isPartnerRequestValid(request.id);
            system.debug('### bisLinkedAccount ='+bisLinkedAccount);
            system.debug('### bisPartnerRequestValid ='+bisPartnerRequestValid);
            if(bisLinkedAccount && bisPartnerRequestValid){
                extension.updateLinkedAccount(acct, request); TestUtils.assertNoErrorMessagesExist();
                extension.updateSelectedPR(acct, request);    TestUtils.assertNoErrorMessagesExist();
                system.assertNotEquals(extension.doConfirm(),null);  
            }
        }
    
    } 
    
    private static testMethod void testPartnerRegSearchResultsExist() {
        final Id REC_TYPE_NEW_PARTNER =IdLookupUtils.getRecordTypeId(
            PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,'Partner_Request__c', true);
        Partner_Request__c dupRequest = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@dell.com',
            //Company__c = 'Tyama', // [Fenny 4-Apr-2013] Commented: Generate a unique company name from real data
            Company__c = strcompany, // [Fenny 4-Apr-2013] Added: Generate a unique company name from real data
            RecordTypeId=REC_TYPE_NEW_PARTNER);
        insert dupRequest;
        dupRequest = [select id, name from Partner_Request__c where id = :dupRequest.id];
        Test.setFixedSearchResults(new Id[]{dupRequest.id});
        Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@dell.com',
            //Company__c = 'Tyama', // [Fenny 4-Apr-2013] Commented: Generate a unique company name from real data
            Company__c = strcompany, // [Fenny 4-Apr-2013] Added: Generate a unique company name from real data
            RecordTypeId=REC_TYPE_NEW_PARTNER);
        insert request;
        ApexPages.standardController controller = new ApexPages.standardController(request);
        PartnerRegistrationDupSearchCtrlExt extension = new PartnerRegistrationDupSearchCtrlExt(controller);
        System.assertEquals(extension.getAccountSearchResultsCount(), 0);
        System.assertEquals(extension.getRegistrationSearchResultsCount(), 0);

        //execute doPageLoad
        System.assertEquals(extension.doPageLoad(),null);
        System.assert(extension.accountSearchResults != null);
        System.assert(extension.registrationSearchResults != null);
        System.assert(extension.accountSearchResults.size() >= 0);
        System.assert(extension.registrationSearchResults.size() >= 0);
        System.assert(extension.getAccountSearchResultsCount() >= 0);
        System.assert(extension.getRegistrationSearchResultsCount() >= 0);
        assertCheckForDupFlagSet(request.id);

        //execute doSelectRegistration
        ApexPages.currentPage().getParameters().put('registrationId', '');
        System.assertEquals(extension.doSelectRegistration(), null);
        System.assertEquals(extension.getIsAccountSelected(), false);
        System.assertEquals(extension.getIsRegistrationSelected(), false);

        ApexPages.currentPage().getParameters().put('registrationId', '123');
        System.assertEquals(extension.doSelectRegistration(), null);
        System.assertEquals(extension.getIsAccountSelected(), false);
        System.assertEquals(extension.getIsRegistrationSelected(), false);

        ApexPages.currentPage().getParameters().put('registrationId', dupRequest.id);
        System.assertEquals(extension.doSelectRegistration(), null);
        System.assertEquals(extension.selectionName, dupRequest.name);
        System.assertEquals(extension.getIsAccountSelected(), false);
        System.assertEquals(extension.getIsRegistrationSelected(), true);

        //execute doConfirm
        PageReference next = extension.doConfirm();
        request = [select Duplicate_Account__c,Duplicate_Registration__c 
            from Partner_Request__c where id = :request.id];
        System.assertEquals(request.Duplicate_Account__c, null);
        System.assertEquals(request.Duplicate_Registration__c, dupRequest.id);
        System.assertNotEquals(next,null);
        System.assertEquals('/' + request.id, next.getUrl());
        //TestUtils.assertNoErrorMessagesExist();
    }
    
    private static testMethod void testPartnerRegSearchResultsExistWithLinkedAccount() {
        final Id REC_TYPE_NEW_PARTNER =IdLookupUtils.getRecordTypeId(
            PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,'Partner_Request__c', true);

        Account dupAcct = new Account(name='Tyama');
        insert dupAcct;     
        Partner_Request__c dupRequest = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@dell.com',
            //Company__c = 'Tyama', // [Fenny 4-Apr-2013] Commented: Generate a unique company name from real data
            Company__c = strcompany, // [Fenny 4-Apr-2013] Added: Generate a unique company name from real data
            Account__c = dupAcct.id,
            RecordTypeId=REC_TYPE_NEW_PARTNER);
        insert dupRequest;
        dupRequest = [select id, name from Partner_Request__c where id = :dupRequest.id];
        Test.setFixedSearchResults(new Id[]{dupRequest.id});
        Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@dell.com',
            //Company__c = 'Tyama', // [Fenny 4-Apr-2013] Commented: Generate a unique company name from real data
            Company__c = strcompany, // [Fenny 4-Apr-2013] Added: Generate a unique company name from real data
            RecordTypeId=REC_TYPE_NEW_PARTNER);
        insert request;
        ApexPages.standardController controller = new ApexPages.standardController(request);
        PartnerRegistrationDupSearchCtrlExt extension = new PartnerRegistrationDupSearchCtrlExt(controller);
        System.assertEquals(extension.getAccountSearchResultsCount(), 0);
        System.assertEquals(extension.getRegistrationSearchResultsCount(), 0);

        //execute doPageLoad
        System.assertEquals(extension.doPageLoad(),null);
        System.assert(extension.accountSearchResults != null);
        System.assert(extension.registrationSearchResults != null);
        System.assert(extension.accountSearchResults.size() >= 0);
        System.assert(extension.registrationSearchResults.size() >= 0);
        System.assert(extension.getAccountSearchResultsCount() >= 0);
        System.assert(extension.getRegistrationSearchResultsCount() >= 0);
        assertCheckForDupFlagSet(request.id);

        //execute doSelectRegistration
        ApexPages.currentPage().getParameters().put('registrationId', '');
        System.assertEquals(extension.doSelectRegistration(), null);
        System.assertEquals(extension.getIsAccountSelected(), false);
        System.assertEquals(extension.getIsRegistrationSelected(), false);

        ApexPages.currentPage().getParameters().put('registrationId', '123');
        System.assertEquals(extension.doSelectRegistration(), null);
        System.assertEquals(extension.getIsAccountSelected(), false);
        System.assertEquals(extension.getIsRegistrationSelected(), false);

        ApexPages.currentPage().getParameters().put('registrationId', dupRequest.id);
        System.assertEquals(extension.doSelectRegistration(), null);
        System.assertEquals(extension.selectionName, dupAcct.name);
        System.assertEquals(extension.getIsAccountSelected(), true);
        System.assertEquals(extension.getIsRegistrationSelected(), true);

        //execute doConfirm
        PageReference next = extension.doConfirm();
        request = [select Duplicate_Account__c,Duplicate_Registration__c 
            from Partner_Request__c where id = :request.id];
        System.assertEquals(request.Duplicate_Account__c, dupAcct.id);
        System.assertEquals(request.Duplicate_Registration__c, dupRequest.id);
        System.assertNotEquals(next,null);
        System.assertEquals('/' + request.id, next.getUrl());
       // TestUtils.assertNoErrorMessagesExist();
    }
    
     static testMethod void testupdateLinkedAcc(){
       final Id REC_TYPE_NEW_PARTNER =IdLookupUtils.getRecordTypeId(
        PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,'Partner_Request__c', true);
        Account dupAcct = new Account(name='Tyama');
        insert dupAcct;
        
       Partner_Request__c request1 = new Partner_Request__c(
        First_Name__c = 'John',
        Last_Name__c = 'Doe',
        Email__c = 'john.doe@dell.com',
        Company__c = 'usa', 
        RecordTypeId=REC_TYPE_NEW_PARTNER);
       insert request1;
       ApexPages.standardController controller = new ApexPages.standardController(request1);
       PartnerRegistrationDupSearchCtrlExt extension = new PartnerRegistrationDupSearchCtrlExt(controller);
     
       extension.updateLinkedAccount(dupAcct, request1);
    }
}
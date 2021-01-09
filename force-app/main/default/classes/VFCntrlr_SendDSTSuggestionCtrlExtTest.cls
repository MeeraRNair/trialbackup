/* Commented lines are for DIT5 enviornment*/

/* 
History:
Version Release         CR #        Date            Modified By     Description     
1.0     0102                        04-Dec-2019     Vikas KH        Implemented TDF
*/

@isTest
private class VFCntrlr_SendDSTSuggestionCtrlExtTest {
    Static list<Account> listAcc;
    static Country__c testCountry;
    static Partner_Request__c request;
    static Lead suggestionLead;
    static Lead updateSuggestionLead;
    static Lead suggestionLead1;
    static Lead updateSuggestionLead1;
    static Lead suggestionLead2;
    static Lead updateSuggestionLead2;
    static Lead suggestionLead3;
    static Lead updateSuggestionLead3;
    static Lead suggestionLead4;
    static Lead updateSuggestionLead4;
    static User userRecord;
    static Sales_Channel_Group__c testSalesChannelRecord;
    static boolean btestDataCreated=false;
    @testsetup static void setup() {
        list<Account> listAccTDF = TestDataFactory.createNAccount(1, 'Partner Account');
        listAccTDF[0].Account_Country_Code__c = 'AI';
        listAccTDF[0].Account_Country__c = 'ANGUILIA';            
        listAccTDF[0].Account_ID__c =''+System.currentTimeMillis();
        insert listAccTDF;   
    }    
    public static testMethod void testVFCntrlrSendDSTSuggestionCtrlExtsendSuggestion() {
        if(btestDataCreated==false){createLead();
                                    PageReference pageRef = Page.SendDSTSuggestion;
                                    Test.setCurrentPage(pageRef);
                                    ApexPages.currentPage().getParameters().put('id', suggestionLead.id);
                                    Test.startTest();
                                    ApexPages.StandardController con = new ApexPages.StandardController(suggestionLead);
                                    VFCntrlr_SendDSTSuggestionCtrlExt controller = new VFCntrlr_SendDSTSuggestionCtrlExt(con);
                                    controller.bisTestExecution = true;
                                    //controller.isTestExecution = true;
                                    AccountSuggestion.SuggestionResponse response = new AccountSuggestion.SuggestionResponse();
                                    response.strOracleError = '';
                                    response.strErrorDescription = '';
                                    response.bIsAccountDuplicate=true;
                                    controller.result = response;       
                                    System.assertEquals(controller.sendSuggestion(true), null);
                                    System.assertEquals(ApexPages.hasMessages(),true);
                                    response = new AccountSuggestion.SuggestionResponse();
                                    response.strOracleError = '';
                                    response.strErrorDescription = '';
                                    response.strID  = '1008';
                                    response.bIsAccountDuplicate=true;
                                    controller.result = response;       
                                    System.assertEquals(controller.sendSuggestion(true), null);
                                    response = new AccountSuggestion.SuggestionResponse();
                                    response.strOracleError = 'validationError';
                                    response.strErrorDescription = 'Validation error occured';
                                    response.strID = '0';
                                    response.bIsAccountDuplicate=true;
                                    controller.result = response;       
                                    System.assertEquals(controller.sendSuggestion(true), null);
                                    //System.assertEquals(controller.strstatus,'VALIDATION_ERROR');
                                    //System.assertEquals(controller.status,'VALIDATION_ERROR');
                                    response = new AccountSuggestion.SuggestionResponse();      
                                    response.strID = '0';
                                    response.bIsAccountDuplicate=true;
                                    controller.result = response;       
                                    System.assertEquals(controller.sendSuggestion(true), null);
                                    //System.assertEquals(controller.strstatus,'VALIDATION_ERROR');
                                    //System.assertEquals(controller.status,'VALIDATION_ERROR');
                                    response = new AccountSuggestion.SuggestionResponse();
                                    response.strOracleError = '';
                                    response.strErrorDescription = '';
                                    response.strID = '12345';
                                    response.bIsAccountDuplicate=true;
                                    controller.result = response;       
                                    System.assertEquals(controller.sendSuggestion(true), null);
                                    //System.assertEquals(controller.strstatus,'PROCESS_COMPLETE');
                                    //System.assertEquals(controller.status,'PROCESS_COMPLETE');
                                    response = new AccountSuggestion.SuggestionResponse();
                                    response.strID = '';
                                    controller.result = response;       
                                    System.assertEquals(controller.sendSuggestion(true), null);
                                    System.assertEquals(ApexPages.hasMessages(),true);
                                    controller.strsuggestionType='test';
                                    controller.strsuggestionType='test';
                                    controller.result.strID='123123';
                                    controller.sendSuggestion(true);
                                    Test.stopTest();
                                   } 
    }
    public static testMethod void testVFCntrlrSendDSTSuggestionCtrlExtsendSuggestionisTestExecutionfalse() {
        if(btestDataCreated==false){createLead1();
                                    PageReference pageRef = Page.SendDSTSuggestion;
                                    Test.setCurrentPage(pageRef);
                                    ApexPages.currentPage().getParameters().put('id', suggestionLead1.id);
                                    Test.startTest();
                                    ApexPages.StandardController con = new ApexPages.StandardController(suggestionLead1);
                                    VFCntrlr_SendDSTSuggestionCtrlExt controller = new VFCntrlr_SendDSTSuggestionCtrlExt(con);
                                    AccountSuggestion.SuggestionResponse response = new AccountSuggestion.SuggestionResponse();
                                    response.strOracleError = '';
                                    response.strErrorDescription = '';
                                    response.bIsAccountDuplicate=true;
                                    controller.result = response;
                                    Test.stopTest();            
                                    System.assertEquals(controller.sendSuggestion(true), null);
                                    System.assertEquals(ApexPages.hasMessages(),true);
                                   }
    }
    public static testMethod void testVFCntrlrSendDSTSuggestionCtrlExtsendSuggestionstatusNotDraft() {
        if(btestDataCreated==false){createLead();
                                    PageReference pageRef = Page.SendDSTSuggestion;
                                    Test.setCurrentPage(pageRef);
                                    suggestionLead.Status = 'open';     
                                    suggestionLead .Partner_Class__c= 'Direct Partner Purchase';
                                    suggestionLead .Partner_Status__c = 'Authorized Reseller';
                                    update suggestionLead;
                                    ApexPages.currentPage().getParameters().put('id', suggestionLead.id);
                                    Test.startTest();
                                    ApexPages.StandardController con = new ApexPages.StandardController(suggestionLead);
                                    VFCntrlr_SendDSTSuggestionCtrlExt controller = new VFCntrlr_SendDSTSuggestionCtrlExt(con);
                                    AccountSuggestion.SuggestionResponse response = new AccountSuggestion.SuggestionResponse();
                                    response.strOracleError = '';
                                    response.strID = '1008';
                                    response.strErrorDescription = '';
                                    response.bIsAccountDuplicate=true;
                                    controller.result = response;
                                    Test.stopTest();
                                    System.assertEquals(controller.sendSuggestion(true), null);
                                    System.assertEquals(ApexPages.hasMessages(),true);
                                   }
    }
    public static testMethod void testVFCntrlrSendDSTSuggestionCtrlExtsendFirstandSecondSuggestion() {
        if(btestDataCreated==false){createLead3();
                                    PageReference pageRef = Page.SendDSTSuggestion;
                                    Test.setCurrentPage(pageRef);
                                    ApexPages.currentPage().getParameters().put('id', suggestionLead3.id);
                                    Test.startTest();
                                    ApexPages.StandardController con = new ApexPages.StandardController(suggestionLead3);
                                    VFCntrlr_SendDSTSuggestionCtrlExt controller = new VFCntrlr_SendDSTSuggestionCtrlExt(con);
                                    controller.bisTestExecution = true;
                                    //controller.isTestExecution = true;
                                    AccountSuggestion.SuggestionResponse response = new AccountSuggestion.SuggestionResponse();
                                    response.strOracleError = '';
                                    response.strErrorDescription = '';
                                    response.bIsAccountDuplicate=true;
                                    controller.result = response;
                                    Test.stopTest();            
                                    System.assertEquals(controller.sendFirstSuggestion(), null);
                                    System.assertEquals(controller.sendSecondSuggestion(), null);
                                    System.assertEquals(ApexPages.hasMessages(),true);
                                   }
    }
    public static testMethod void testVFCntrlrSendDSTSuggestionCtrlExtgoToEdit() {
        System.debug('#MN:START of testVFCntrlrSendDSTSuggestionCtrlExtgoToEdit()');
        if(btestDataCreated==false){createLead2();
                                    PageReference pageRef = Page.SendDSTSuggestion;
                                    Test.setCurrentPage(pageRef);
                                    ApexPages.currentPage().getParameters().put('id', suggestionLead2.id);
                                    Test.startTest();
                                    ApexPages.StandardController con = new ApexPages.StandardController(suggestionLead2);
                                    VFCntrlr_SendDSTSuggestionCtrlExt controller = new VFCntrlr_SendDSTSuggestionCtrlExt(con);
                                    controller.bisTestExecution = true;
                                    //controller.isTestExecution = true;
                                    String strpageReference = controller.goToEdit().getUrl();
                                    Test.stopTest();    
                                    String struRLTobeTested = '/'+suggestionLead2.Id+'/e?retURL='+suggestionLead2.Id;    
                                    System.assertEquals(struRLTobeTested, strpageReference);
                                   }
    }
    public static testMethod void testVFCntrlrSendDSTSuggestionCtrlExtcancelSuggestion() {
        if(btestDataCreated==false){createLead4();
                                    PageReference pageRef = Page.SendDSTSuggestion;
                                    Test.setCurrentPage(pageRef);
                                    ApexPages.currentPage().getParameters().put('id', suggestionLead4.id);
                                    Test.startTest();
                                    ApexPages.StandardController con = new ApexPages.StandardController(suggestionLead4);
                                    VFCntrlr_SendDSTSuggestionCtrlExt controller = new VFCntrlr_SendDSTSuggestionCtrlExt(con);
                                    //      controller.bisTestExecution = true;    
                                    //     controller.strduplicationMessage = 'test';  
                                    controller.bisTestExecution = true;    
                                    controller.strduplicationMessage = 'test';  
                                    String strpageReference = controller.cancelSuggestion().getUrl();
                                    Test.stopTest();    
                                    system.debug('##pageRef: '+strpageReference);
                                    String struRLTobeTested = '/'+suggestionLead4.Id;   
                                    System.assert(struRLTobeTested.contains(strpageReference));
                                    System.assertEquals('Account Suggestion Rejected',[Select Status FROM Lead WHERE Id= :suggestionLead4.Id limit 1].status);       
                                   }
    }
    public static testMethod void testVFCntrlrSendDSTSuggestionCtrlExtupdateSuggestion() {
        if(btestDataCreated==false){createLead();
                                    PageReference pageRef = Page.SendDSTSuggestion;
                                    Test.setCurrentPage(pageRef);
                                    ApexPages.currentPage().getParameters().put('id', updateSuggestionLead.id);
                                    Test.startTest();
                                    ApexPages.StandardController con = new ApexPages.StandardController(updateSuggestionLead);
                                    VFCntrlr_SendDSTSuggestionCtrlExt controller = new VFCntrlr_SendDSTSuggestionCtrlExt(con);
                                    controller.bisTestExecution = true;
                                    //controller.isTestExecution = true;
                                    AccountSuggestion.SuggestionResponse response = new AccountSuggestion.SuggestionResponse();
                                    response.strOracleError = '';
                                    response.strErrorDescription = '';
                                    response.bIsAccountDuplicate=true;
                                    controller.result = response;
                                    response.strID = '375836';     
                                    System.assertEquals(controller.sendSuggestion(true), null);
                                    //System.assertEquals(controller.strstatus,'PROCESS_COMPLETE');
                                    //System.assertEquals(controller.status,'PROCESS_COMPLETE');
                                   }
    }
    public static testMethod void testVFCntrlrSendDSTSuggestionCtrlExtshowError() {
        if(btestDataCreated==false){createLead();
                                    PageReference pageRef = Page.SendDSTSuggestion;
                                    Test.setCurrentPage(pageRef);
                                    Test.startTest();
                                    ApexPages.StandardController con = new ApexPages.StandardController(new Lead());
                                    VFCntrlr_SendDSTSuggestionCtrlExt controller = new VFCntrlr_SendDSTSuggestionCtrlExt(con);      
                                    System.assert(ApexPages.hasMessages());         
                                   }
    }
    private static void createLead(){
        listAcc = [select id,Account_Country_Code__c,Account_Country__c,Account_ID__c from Account];
        testCountry = new Country__c(
            Name = 'TestCountry',
            Code__c = 'TY',
            User_Currency_Iso_Code__c = 'INR',
            Region__c = 'APJ');
        insert testCountry;
        Profile userProfile = [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];        
        userRecord = new User(
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
        request = new Partner_Request__c();
        request.Account__c = listAcc[0].id;
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
                                                             'Partner_Request__c', true);
        request.email__c = 'test@dell.com';
        request.Export_Compliance_Agreed__c = true;
        request.Partner_Terms_Conditions__c = true;
        request.Other_Customers__c = 'test1';
        request.Feature_Request_Training__c = true;
        request.Preferred_Dell_Distribution_Partner__c = 'Test prefer';
        request.Feature_Request_Deal_Registration__c = true;
        request.Company__c = 'Test Company';
        request.Org_Country__c = testCountry.id;
        request.Website__c = 'website';     
        request.Org_Address_1__c =  'Address 1';
        request.Org_Address_2__c = 'Address 2';
        request.Org_Address_3__c =  'Address 3';
        request.Org_City__c = 'city';
        request.phone__c = '1211-122-123';
        request.fax__c = '1211-122-112';
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
        testSalesChannelRecord = new Sales_Channel_Group__c
            (Name='Test - SC Record 1');//  Group_ID__c='12345611'
        insert TestSalesChannelRecord;
        suggestionLead = new Lead(
            Status = 'Draft',
            CFI_Project_Numbers__c = 'testPN',
            Questions_Comments__c = 'Sample Questions And Comments',
            Date_Founded__c = DateTime.now(),
            DMU_Flag__c = true,
            FIN_GEO__c = 'Test',
            Fiscal_Year_End__c = DateTime.now(),
            Company = 'Test Company',
            Phone = '1111',
            Function_Category_Code__c = 'Air Force Air Station',
            Program_Type__c = 'Test',
            Location_Number__c = 4,
            Marketing_Class_Code__c = 'Defense Army',
            National_ID__c = '344',
            NDA_Expiry_Date__c = DateTime.now(),
            NDA_Flag__c = false,
            Other_Company_Name__c = 'Other Company',
            Website = 'Mywebsite',
            Physical_City__c = 'City',
            Physical_Company_Name__c = 'Name',
            Organization_Country__c = testCountry.id,       
            Physical_Country__c = testCountry.id,
            Physical_County__c = 'Test',
            Physical_Fax__c = ' ',
            Physical_Phone__c = ' ',
            Physical_PostalCode__c = '3455',
            Physical_State__c = 'City',
            Physical_Address_1__c = 'Add',
            Physical_Address_2__c = 'Add2',
            Physical_suburb__c = 'Suburb',
            Postal_City__c = 'city',
            Postal_Company_Name__c = 'Company',
            Postal_Country__c = testCountry.id,     
            Postal_County__c = 'County',
            Postal_Fax__c = ' ',
            Postal_Phone__c = ' ',
            Postal_PostalCode__c = '45554',
            Postal_State__c = 'State',
            Postal_Address_1__c = 'Add1',
            Postal_Address_2__c = 'Add2',
            Postal_suburb__c = 'Suburb',
            Premier_Page_URL__c = 'URL',
            Suggestion_Reason__c = 'Reseller',
            Retail_Flag__c = true,
            Sales_Model_Code__c = 'Relationship',
            Std_Quote_Numbers__c = 'Test',
            Sub_Market_Code__c = 'Army',
            Partner_Request__c = request.id,        
            Account_Category__c = 'Partner',
            Partner_Type__c = 'ISG',
            Partner_Class__c = 'Tier 1',LeadSource = 'Partner',       
            Territory_Assignment__c = testSalesChannelRecord.id,
            LastName = 'Test',
            Partner_Status__c = 'Registered',RecordTypeId = IdLookupUtils.getRecordTypeId('Update Account Suggestion', 'Lead', TRUE));  
        insert suggestionLead;      
        updateSuggestionLead = suggestionLead.clone(false,true);
        updateSuggestionLead.RecordTypeId = IdLookupUtils.getRecordTypeId('Update Account Suggestion', 'Lead', TRUE);
        insert updateSuggestionLead;
        btestDataCreated = true;
    }
    private static void createLead1(){
        listAcc = [select id,Account_Country_Code__c,Account_Country__c,Account_ID__c from Account];
        testCountry = new Country__c(
            Name = 'TestCountry',
            Code__c = 'TY',
            User_Currency_Iso_Code__c = 'INR',
            Region__c = 'APJ');
        insert testCountry;
        Profile userProfile = [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];        
        userRecord = new User(
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
        request = new Partner_Request__c();
        request.Account__c = listAcc[0].id;
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
                                                             'Partner_Request__c', true);
        request.email__c = 'test@dell.com';
        request.Export_Compliance_Agreed__c = true;
        request.Partner_Terms_Conditions__c = true;
        request.Other_Customers__c = 'test1';
        request.Feature_Request_Training__c = true;
        request.Preferred_Dell_Distribution_Partner__c = 'Test prefer';
        request.Feature_Request_Deal_Registration__c = true;
        request.Company__c = 'Test Company';
        request.Org_Country__c = testCountry.id;
        request.Website__c = 'website';     
        request.Org_Address_1__c =  'Address 1';
        request.Org_Address_2__c = 'Address 2';
        request.Org_Address_3__c =  'Address 3';
        request.Org_City__c = 'city';
        request.phone__c = '1211-122-123';
        request.fax__c = '1211-122-112';
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
        testSalesChannelRecord = new Sales_Channel_Group__c
            (Name='Test - SC Record 1'); //Group_ID__c='1234567'
        insert TestSalesChannelRecord;
        suggestionLead1 = new Lead(
            Status = 'Draft',
            CFI_Project_Numbers__c = 'testPN',
            Questions_Comments__c = 'Sample Questions And Comments',
            Date_Founded__c = DateTime.now(),
            DMU_Flag__c = true,
            FIN_GEO__c = 'Test',
            Fiscal_Year_End__c = DateTime.now(),
            Company = 'Test Company',
            Phone = '1111',
            Function_Category_Code__c = 'Air Force Air Station',
            Program_Type__c = 'Test',
            Location_Number__c = 4,
            Marketing_Class_Code__c = 'Defense Army',
            National_ID__c = '344',
            NDA_Expiry_Date__c = DateTime.now(),
            NDA_Flag__c = false,
            Other_Company_Name__c = 'Other Company',
            Website = 'Mywebsite',
            Physical_City__c = 'City',
            Physical_Company_Name__c = 'Name',
            Organization_Country__c = testCountry.id,       
            Physical_Country__c = testCountry.id,
            Physical_County__c = 'Test',
            Physical_Fax__c = ' ',
            Physical_Phone__c = ' ',
            Physical_PostalCode__c = '3455',
            Physical_State__c = 'City',
            Physical_Address_1__c = 'Add',
            Physical_Address_2__c = 'Add2',
            Physical_suburb__c = 'Suburb',
            Postal_City__c = 'city',
            Postal_Company_Name__c = 'Company',
            Postal_Country__c = testCountry.id,     
            Postal_County__c = 'County',
            Postal_Fax__c = '8121-448600',
            Postal_Phone__c = ' ',
            Postal_PostalCode__c = '45554',
            Postal_State__c = 'State',
            Postal_Address_1__c = 'Add1',
            Postal_Address_2__c = 'Add2',
            Postal_suburb__c = 'Suburb',
            Premier_Page_URL__c = 'URL',
            Suggestion_Reason__c = 'Reseller',
            Retail_Flag__c = true,
            Sales_Model_Code__c = 'Relationship',
            Std_Quote_Numbers__c = 'Test',
            Sub_Market_Code__c = 'Army',
            Partner_Request__c = request.id,        
            Account_Category__c = 'Partner',
            Partner_Type__c = 'ISG',
            Partner_Class__c = 'Tier 1',LeadSource = 'Partner',        
            Territory_Assignment__c = testSalesChannelRecord.id,
            LastName = 'Test',
            RecordTypeId = IdLookupUtils.getRecordTypeId('Update Account Suggestion', 'Lead', TRUE),
            Partner_Status__c = 'Registered');  
        insert suggestionLead1;      
        updateSuggestionLead1 = suggestionLead1.clone(false,true);
        updateSuggestionLead1.RecordTypeId = IdLookupUtils.getRecordTypeId('Update Account Suggestion', 'Lead', TRUE);
        insert updateSuggestionLead1;
        btestDataCreated = true;
    }   
    private static void createLead2(){
        listAcc = [select id,Account_Country_Code__c,Account_Country__c,Account_ID__c from Account];
        testCountry = new Country__c(
            Name = 'TestCountry',
            Code__c = 'TY',
            User_Currency_Iso_Code__c = 'INR',
            Region__c = 'APJ');
        insert testCountry;
        Profile userProfile = [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];        
        userRecord = new User(
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
        request = new Partner_Request__c();
        request.Account__c = listAcc[0].id;
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
                                                             'Partner_Request__c', true);
        request.email__c = 'test@dell.com';
        request.Export_Compliance_Agreed__c = true;
        request.Partner_Terms_Conditions__c = true;
        request.Other_Customers__c = 'test1';
        request.Feature_Request_Training__c = true;
        request.Preferred_Dell_Distribution_Partner__c = 'Test prefer';
        request.Feature_Request_Deal_Registration__c = true;
        request.Company__c = 'Test Company';
        request.Org_Country__c = testCountry.id;
        request.Website__c = 'website';     
        request.Org_Address_1__c =  'Address 1';
        request.Org_Address_2__c = 'Address 2';
        request.Org_Address_3__c =  'Address 3';
        request.Org_City__c = 'city';
        request.phone__c = '1211-122-123';
        request.fax__c = '1211-122-112';
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
        testSalesChannelRecord = new Sales_Channel_Group__c
            (Name='Test - SC Record 1'); //Group_ID__c='1234568'
        insert TestSalesChannelRecord;
        suggestionLead2 = new Lead(
            Status = 'Draft',
            CFI_Project_Numbers__c = 'testPN',
            Questions_Comments__c = 'Sample Questions And Comments',
            Date_Founded__c = DateTime.now(),
            DMU_Flag__c = true,
            FIN_GEO__c = 'Test',
            Fiscal_Year_End__c = DateTime.now(),
            Company = 'Test Company',
            Phone = '1111',
            Function_Category_Code__c = 'Air Force Air Station',
            Program_Type__c = 'Test',
            Location_Number__c = 4,
            Marketing_Class_Code__c = 'Defense Army',
            National_ID__c = '344',
            NDA_Expiry_Date__c = DateTime.now(),
            NDA_Flag__c = false,
            Other_Company_Name__c = 'Other Company',
            Website = 'Mywebsite',
            Physical_City__c = 'City',
            Physical_Company_Name__c = 'Name',
            Organization_Country__c = testCountry.id,       
            Physical_Country__c = testCountry.id,
            Physical_County__c = 'Test',
            Physical_Fax__c = ' ',
            Physical_Phone__c = '8121-448600',
            Physical_PostalCode__c = '3455',
            Physical_State__c = 'City',
            Physical_Address_1__c = 'Add',
            Physical_Address_2__c = 'Add2',
            Physical_suburb__c = 'Suburb',
            Postal_City__c = 'city',
            Postal_Company_Name__c = 'Company',
            Postal_Country__c = testCountry.id,     
            Postal_County__c = 'County',
            Postal_Fax__c = ' ',
            Postal_Phone__c = ' ',
            Postal_PostalCode__c = '45554',
            Postal_State__c = 'State',
            Postal_Address_1__c = 'Add1',
            Postal_Address_2__c = 'Add2',
            Postal_suburb__c = 'Suburb',
            Premier_Page_URL__c = 'URL',
            Suggestion_Reason__c = 'Reseller',
            Retail_Flag__c = true,
            Sales_Model_Code__c = 'Relationship',
            Std_Quote_Numbers__c = 'Test',
            Sub_Market_Code__c = 'Army',
            Partner_Request__c = request.id,        
            Account_Category__c = 'Partner',
            Partner_Type__c = 'ISG',
            Partner_Class__c = 'Tier 1',LeadSource = 'Partner',        
            Territory_Assignment__c = testSalesChannelRecord.id,
            LastName = 'Test',
            Partner_Status__c = 'Registered',RecordTypeId = IdLookupUtils.getRecordTypeId('Update Account Suggestion', 'Lead', TRUE));  
        insert suggestionLead2;      
        updateSuggestionLead2 = suggestionLead2.clone(false,true);
        updateSuggestionLead2.RecordTypeId = IdLookupUtils.getRecordTypeId('Update Account Suggestion', 'Lead', TRUE);
        insert updateSuggestionLead2;
        btestDataCreated = true;
    }
    private static void createLead3(){
        listAcc = [select id,Account_Country_Code__c,Account_Country__c,Account_ID__c from Account];
        testCountry = new Country__c(
            Name = 'TestCountry',
            Code__c = 'TY',
            User_Currency_Iso_Code__c = 'INR',
            Region__c = 'APJ');
        insert testCountry;
        Profile userProfile = [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];        
        userRecord = new User(
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
        request = new Partner_Request__c();
        request.Account__c = listAcc[0].id;
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
                                                             'Partner_Request__c', true);
        request.email__c = 'test@dell.com';
        request.Export_Compliance_Agreed__c = true;
        request.Partner_Terms_Conditions__c = true;
        request.Other_Customers__c = 'test1';
        request.Feature_Request_Training__c = true;
        request.Preferred_Dell_Distribution_Partner__c = 'Test prefer';
        request.Feature_Request_Deal_Registration__c = true;
        request.Company__c = 'Test Company';
        request.Org_Country__c = testCountry.id;
        request.Website__c = 'website';     
        request.Org_Address_1__c =  'Address 1';
        request.Org_Address_2__c = 'Address 2';
        request.Org_Address_3__c =  'Address 3';
        request.Org_City__c = 'city';
        request.phone__c = '1211-122-123';
        request.fax__c = '1211-122-112';
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
        testSalesChannelRecord = new Sales_Channel_Group__c
            (Name='Test - SC Record 1');// 
        //Group_ID__c='1234569');
        insert TestSalesChannelRecord;
        suggestionLead3 = new Lead(
            Status = 'Draft',
            CFI_Project_Numbers__c = 'testPN',
            Questions_Comments__c = 'Sample Questions And Comments',
            Date_Founded__c = DateTime.now(),
            DMU_Flag__c = true,
            FIN_GEO__c = 'Test',
            Fiscal_Year_End__c = DateTime.now(),
            Company = 'Test Company',
            Phone = '1111',
            Function_Category_Code__c = 'Air Force Air Station',
            Program_Type__c = 'Test',
            Location_Number__c = 4,
            Marketing_Class_Code__c = 'Defense Army',
            National_ID__c = '344',
            NDA_Expiry_Date__c = DateTime.now(),
            NDA_Flag__c = false,
            Other_Company_Name__c = 'Other Company',
            Website = 'Mywebsite',
            Physical_City__c = 'City',
            Physical_Company_Name__c = 'Name',
            Organization_Country__c = testCountry.id,       
            Physical_Country__c = testCountry.id,
            Physical_County__c = 'Test',
            Physical_Fax__c = '8121-448600',
            Physical_Phone__c = ' ',
            Physical_PostalCode__c = '3455',
            Physical_State__c = 'City',
            Physical_Address_1__c = 'Add',
            Physical_Address_2__c = 'Add2',
            Physical_suburb__c = 'Suburb',
            Postal_City__c = 'city',
            Postal_Company_Name__c = 'Company',
            Postal_Country__c = testCountry.id,     
            Postal_County__c = 'County',
            Postal_Fax__c = ' ',
            Postal_Phone__c = ' ',
            Postal_PostalCode__c = '45554',
            Postal_State__c = 'State',
            Postal_Address_1__c = 'Add1',
            Postal_Address_2__c = 'Add2',
            Postal_suburb__c = 'Suburb',
            Premier_Page_URL__c = 'URL',
            Suggestion_Reason__c = 'Reseller',
            Retail_Flag__c = true,
            Sales_Model_Code__c = 'Relationship',
            Std_Quote_Numbers__c = 'Test',
            Sub_Market_Code__c = 'Army',
            Partner_Request__c = request.id,        
            Account_Category__c = 'Partner',
            Partner_Type__c = 'ISG',
            Partner_Class__c = 'Tier 1',        
            Territory_Assignment__c = testSalesChannelRecord.id,
            LastName = 'Test',LeadSource = 'Partner',
            Partner_Status__c = 'Registered',RecordTypeId = IdLookupUtils.getRecordTypeId('Update Account Suggestion', 'Lead', TRUE));  
        insert suggestionLead3;      
        updateSuggestionLead3 = suggestionLead3.clone(false,true);
        updateSuggestionLead3.RecordTypeId = IdLookupUtils.getRecordTypeId('Update Account Suggestion', 'Lead', TRUE);
        insert updateSuggestionLead3;
        btestDataCreated = true;
        
    }
    private static void createLead4(){
        listAcc = [select id,Account_Country_Code__c,Account_Country__c,Account_ID__c from Account];
        testCountry = new Country__c(
            Name = 'TestCountry',
            Code__c = 'TY',
            User_Currency_Iso_Code__c = 'INR',
            Region__c = 'APJ');
        insert testCountry;
        Profile userProfile = [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];        
        userRecord = new User(
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
        request = new Partner_Request__c();
        request.Account__c = listAcc[0].id;
        request.RecordTypeId = IdLookupUtils.getRecordTypeId(PartnerConstants.REQUEST_RECORD_TYPE_NEW_PARTNER,
                                                             'Partner_Request__c', true);
        request.email__c = 'test@dell.com';
        request.Export_Compliance_Agreed__c = true;
        request.Partner_Terms_Conditions__c = true;
        request.Other_Customers__c = 'test1';
        request.Feature_Request_Training__c = true;
        request.Preferred_Dell_Distribution_Partner__c = 'Test prefer';
        request.Feature_Request_Deal_Registration__c = true;
        request.Company__c = 'Test Company';
        request.Org_Country__c = testCountry.id;
        request.Website__c = 'website';     
        request.Org_Address_1__c =  'Address 1';
        request.Org_Address_2__c = 'Address 2';
        request.Org_Address_3__c =  'Address 3';
        request.Org_City__c = 'city';
        request.phone__c = '1211-122-123';
        request.fax__c = '1211-122-112';
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
        testSalesChannelRecord = new Sales_Channel_Group__c
            (Name='Test - SC Record 1'); 
        insert TestSalesChannelRecord;
        suggestionLead4 = new Lead(
            Status = 'Draft',
            CFI_Project_Numbers__c = 'testPN',
            Questions_Comments__c = 'Sample Questions And Comments',
            Date_Founded__c = DateTime.now(),
            DMU_Flag__c = true,
            FIN_GEO__c = 'Test',
            Fiscal_Year_End__c = DateTime.now(),
            Company = 'Test Company',
            Phone = '1111',
            Function_Category_Code__c = 'Air Force Air Station',
            Program_Type__c = 'Test',
            Location_Number__c = 4,
            Marketing_Class_Code__c = 'Defense Army',
            National_ID__c = '344',
            NDA_Expiry_Date__c = DateTime.now(),
            NDA_Flag__c = false,
            Other_Company_Name__c = 'Other Company',
            Website = 'Mywebsite',
            Physical_City__c = 'City',
            Physical_Company_Name__c = 'Name',
            Organization_Country__c = testCountry.id,       
            Physical_Country__c = testCountry.id,
            Physical_County__c = 'Test',
            Physical_Fax__c = ' ',
            Physical_Phone__c = ' ',
            Physical_PostalCode__c = '3455',
            Physical_State__c = 'City',
            Physical_Address_1__c = 'Add',
            Physical_Address_2__c = 'Add2',
            Physical_suburb__c = 'Suburb',
            Postal_City__c = 'city',
            Postal_Company_Name__c = 'Company',
            Postal_Country__c = testCountry.id,     
            Postal_County__c = 'County',
            Postal_Fax__c = ' ',
            Postal_Phone__c = '8121-448600', 
            Postal_PostalCode__c = '45554',
            Postal_State__c = 'State',
            Postal_Address_1__c = 'Add1',
            Postal_Address_2__c = 'Add2',
            Postal_suburb__c = 'Suburb',
            Premier_Page_URL__c = 'URL',
            Suggestion_Reason__c = 'Reseller',
            Retail_Flag__c = true,
            Sales_Model_Code__c = 'Relationship',
            Std_Quote_Numbers__c = 'Test',
            Sub_Market_Code__c = 'Army',
            Partner_Request__c = request.id,        
            Account_Category__c = 'Partner',
            Partner_Type__c = 'ISG',
            Partner_Class__c = 'Tier 1',        
            Territory_Assignment__c = testSalesChannelRecord.id,
            LastName = 'Test',LeadSource = 'Partner',
            Partner_Status__c = 'Registered',RecordTypeId = IdLookupUtils.getRecordTypeId('Update Account Suggestion', 'Lead', TRUE));  
        insert suggestionLead4;      
        updateSuggestionLead4 = suggestionLead4.clone(false,true);
        updateSuggestionLead4.RecordTypeId = IdLookupUtils.getRecordTypeId('Update Account Suggestion', 'Lead', TRUE);
        insert updateSuggestionLead4;
        btestDataCreated = true;
    }
}
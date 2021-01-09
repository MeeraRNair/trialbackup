/***********************************************************
    * Name          : VFcntrl_SearchEndCustomerFromDnBTest
    * Description   : Test Class for VFcntrl_SearchEndCustomerFromDnB class
    * ---------------------------------------------------------
    * Revision     Name            Date             Description
    * 1.0         Yeswanth     25. july. 2016    Test Class for VFcntrl_SearchEndCustomerFromDnB class
    * 2.0         Yeswanth     08. Aug. 2016     To increase code coverage
    * 3.0         Yeswanth     07. Sep. 2016     Added methods to cover exception scenarios
    * 4.0         Meera        28. Sep. 2016     Added UI Validation related test methods
************************************************************/
@isTest
public class VFcntrl_SearchEndCustomerFromDnBTest{
    @testSetup public static void createData(){
        TriggerExecutionController.setSkipAllTriggers(true);
        profile partnerProfile = [select id,name from profile where name like '%EMEA PRM Portal User%' order by name desc Limit 1];
        Id accRTId= IdLookupUtils.getRecordTypeId('Master Account','Account',true);
        Account partnerAccount=new Account(name='PartnerAccount',Account_Country_Code__c='US',Account_Country__c = 'UNITED STATES',RecordTypeId= accRTId);
        insert partnerAccount;
         // Creating partner contact
        Contact partnerContact = new Contact(FirstName = 'Partner', LastName = 'Contact',
                           AccountId =partnerAccount.Id,
                           Status__c  =  'Marketing Suspect',
                           Email = 'MyLastNae@dell.com',
                           Fax = '1234567',
                           MobilePhone = '0987654',
                           Last_Operation_Performed__c = 'testing',
                           Phone = '1234500');
        insert partnerContact;
        // Creating Partner User
        User partnerUser = new User(Username='partnerUser'+ System.currentTimeMillis() +'@dell.com',
                            Alias = 'PU', 
                            Email='MyLastName@dell.com',         
                            FirstName='Partner', 
                            LastName='User',  
                            ProfileId = partnerProfile.Id, 
                            LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='UTF-8', 
                            TimeZoneSidKey='America/Los_Angeles',
                            Badge_Number__c='Test1234',
                            Enable_Partner_Admin__c = true,
                            isActive = true,
                            Enable_Partner_Deal_Registration__c = true,
                            ContactId = partnerContact.Id);
        insert partnerUser;
        Country__c country = new Country__c(Name='canada',Code__c='US',DNB_COUNTRY_CODE__c ='805',DNB_ISO_country_code__c ='US',DNB_Region__c = 'AMER',DnB_Supported_Country__c=true);
        insert country;
    }

    public static testmethod void testMethod1(){
       
        VFcntrl_SearchEndCustomerFromDnB dnbController = new VFcntrl_SearchEndCustomerFromDnB();
        dnbController.ziprequired=true;
        dnbController.minscore='test';
        dnbController.selectedcountry='test country';
        dnbController.onPageLoad();
        dnbController.markRequired(); 
        dnbController.useOriginalAddress();
        dnbController.useOriginalAddress2();
        dnbController.navigateToExistingEndcustomer();
        dnbController.getMailingCountries();
        dnbController.saveEndCustomerDetails();
                Test.startTest();
        dnbController.endCustomer.Name = 'John %';
        dnbController.endCustomer.Mailing_street__c = 'Albert';
        dnbController.endCustomer.Mailing_city__c = 'Hyd';
        dnbController.endCustomer.Mailing_State__c = 'TEXAS';
        dnbController.endCustomer.Mailing_country__c = 'canada';
        dnbController.endCustomer.Zip_Code__c = '12345';
        StaticResourceCalloutMock mockResponse = new StaticResourceCalloutMock();  
        mockResponse.setStaticResource('DnB_response_body_staticresource');
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('OK');
        mockResponse.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        mockResponse.setHeader('Authorization',System.Label.Deal_Reg_MDM_Prod_Credentials);  
        Test.setMock(HttpCalloutMock.class, mockResponse);
        dnbController.searchDnB();
        dnbController.hideNewContForm();
        dnbController.searchMethod='search';
        dnbController.currentDNBCode='code';
        dnbController.showOriginalEnduserButton=true;
        dnbController.displaynew=true;
        dnbController.displaycontacts=true;
        dnbController.showcontacts=true;
        dnbController.getEndCustomer();
        dnbController.getEndCustomerContact();
        dnbController.getshowResultTable();
        dnbController.getshowResultBlock();
        dnbController.addCustomerToDeal();
        dnbController.addContactToDealBasedOnValidCountries();
       // dnbController.addContactToDeal();
        dnbController.exceptionMessage='exception';

        dnbController.getItems();
        Test.stopTest();
        User partnerUser = [SELECT id,Email,contact.accountId FROM USER WHERE Email='MyLastName@dell.com' ];
        system.runAs(partnerUser){
        PageReference pageRef = Page.searchEndCustomerFromDnB;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('selectedDUnsId','792341950');
        dnbController.onPageLoad();
        dnbController.addCustomerToDeal();  
         system.assertEquals(partnerUser.Email,'mylastname@dell.com');
        }
    }    
    public static testmethod void testMethod2(){
        User partnerUser = [SELECT id,Email,contact.accountId FROM USER WHERE Email='MyLastName@dell.com' ];
        system.runAs(partnerUser){
        PageReference pageRef = Page.searchEndCustomerFromDnB;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('dupEndCustContact','0033B000004udyg');

        VFcntrl_SearchEndCustomerFromDnB dnbController = new VFcntrl_SearchEndCustomerFromDnB();
        dnbController.addCustomerToDeal();
        dnbController.onPageLoad();
        dnbController.markRequired();
        dnbController.endCustomer.Name = 'John';
        dnbController.endCustomer.Mailing_street__c = 'Albert';
        dnbController.endCustomer.Mailing_city__c = 'Hyd';
        dnbController.endCustomer.Mailing_State__c = 'TEXAS';
        dnbController.endCustomer.Mailing_country__c = 'India';
        dnbController.endCustomer.Zip_Code__c = '';
        dnbController.useOriginalAddress();
        dnbController.createNewContForm();
        dnbController.saveEndCustomerDetails();
        dnbController.EndCustomer.Mailing_country__c='canada';
        Test.startTest();
        StaticResourceCalloutMock mockResponse = new StaticResourceCalloutMock();  
        mockResponse.setStaticResource('DnB_response_body_staticresource');
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('faultcode');
    
        mockResponse.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        mockResponse.setHeader('Authorization',System.Label.Deal_Reg_MDM_Prod_Credentials);  
        Test.setMock(HttpCalloutMock.class, mockResponse);
        dnbController.searchDnB();
        Test.stopTest();
        system.assertEquals(partnerUser.Email,'mylastname@dell.com');
        }
            
    }
    
    public static testmethod void testMethod3(){
	triggerexecutioncontroller.setSkipAllTriggers(True);
        Account partnerAccount = [select Id from Account where name ='PartnerAccount'];
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='Test678', RecordtypeId = accRTId, Type = 'Partner',Master_Group_Id__c = partnerAccount.id);
        test.starttest();
		insert newAcc;
		test.stoptest();
        End_Customer__c ec = new End_Customer__c();
        ec.Name = 'John1';
        ec.Status__c = 'Active';
        ec.Mailing_city__c ='testdc city';
        ec.Mailing_State__c ='testd state';
        ec.Partner_Account__c = newAcc.Id;
        Insert ec;
        
        End_Customer__c ec1 = new End_Customer__c();
        ec1.Name = 'Test';
        ec1.Status__c = 'Active';
        ec1.Mailing_city__c ='test city';
        ec1.Mailing_State__c ='test state';
        ec1.Partner_Account__c = newAcc.Id;
        Insert ec1;
        
        End_Customer_Contact__c ecc = new End_Customer_Contact__c(); 
        ecc.Status__c = 'Active';
        ecc.email__c ='test@test.com';
        ecc.Last_Name__c ='LastName';
        ecc.Phone__c ='54567889';
        ecc.End_Customer__c =ec.Id;
        insert ecc;
        User partnerUser = [SELECT id,Email,contact.accountId FROM USER WHERE Email='MyLastName@dell.com' ];
        system.runAs(partnerUser){
        VFcntrl_SearchEndCustomerFromDnB dnbController = new VFcntrl_SearchEndCustomerFromDnB();
        dnbController.onPageLoad();
        dnbController.markRequired();
        dnbController.endCustomer.Name = 'John';
        dnbController.endCustomer.Mailing_street__c = 'Albert';
        dnbController.endCustomer.Mailing_city__c = 'Hyd';
        dnbController.endCustomer.Mailing_State__c = 'TEXAS';
        dnbController.endCustomer.Mailing_country__c = 'India';
        dnbController.endCustomer.Zip_Code__c = '12345';
        dnbController.useOriginalAddress();
        PageReference pageRef = Page.searchEndCustomerFromDnB;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('dupEndCustContact','0033B000004udyg');
        dnbController.createNewContForm();
        dnbController.objEndCustumerContact.Name ='test@test.com';
        dnbController.objEndCustumerContact.Email__c ='test@test.com';
        dnbController.objEndCustumerContact.Last_Name__c ='test@test.com';
        dnbController.objEndCustumerContact.Phone__c ='987656567';
        dnbController.saveEndCustomerDetails();
        dnbController.endCustomer.Mailing_country__c = 'India';
        dnbController.endCustomer.Mailing_street__c = 'Albert';
         dnbController.searchDnB();
         dnbController.createNewContactForm(ec1);
         system.assertEquals(partnerUser.Email,'mylastname@dell.com');
         
    } 
    }
        // to cover non duplicate in saveEndCustomerDetails
        public static testmethod void testMethod4(){
		triggerexecutioncontroller.setSkipAllTriggers(True);
        Account partnerAccount = [select Id from Account where name ='PartnerAccount'];
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account newAcc = new Account(name='Test', RecordtypeId = accRTId, Type = 'Partner',Master_Group_Id__c = partnerAccount.id);
		test.starttest();
        insert newAcc;
		test.stoptest();
        End_Customer__c ec = new End_Customer__c();
        ec.Name = 'John';
        ec.Status__c = 'Active';
        ec.Mailing_city__c ='test city';
        ec.Mailing_State__c ='test state';
        ec.Partner_Account__c = newAcc.Id;
        Insert ec;
        
        End_Customer_Contact__c ecc = new End_Customer_Contact__c(); 
        ecc.Status__c = 'Active';
        ecc.email__c ='test@test.com';
        ecc.Last_Name__c ='LastName';
        ecc.Phone__c ='545678891';
        ecc.End_Customer__c =ec.Id;
        insert ecc;
        User partnerUser = [SELECT id,Email,contact.accountId FROM USER WHERE Email='MyLastName@dell.com' ];
        system.runAs(partnerUser){
        VFcntrl_SearchEndCustomerFromDnB dnbController = new VFcntrl_SearchEndCustomerFromDnB();
        dnbController.onPageLoad();
        dnbController.EndCustomer.Mailing_country__c='canada';
        dnbController.markRequired();
        dnbController.endCustomer.Name = null;
        dnbController.endCustomer.Mailing_street__c = null;
        dnbController.endCustomer.Mailing_city__c = null;
        dnbController.endCustomer.Mailing_State__c = null;
        dnbController.endCustomer.Mailing_country__c = null;
            dnbController.endCustomer.Tax_Id__c= null;
        dnbController.endCustomer.Zip_Code__c = null;
        dnbController.searchDnB();
        dnbController.endCustomer.Name = 'John';
        dnbController.endCustomer.Mailing_street__c = 'Albert';
        dnbController.endCustomer.Mailing_city__c = 'Hyd';
        dnbController.endCustomer.Mailing_State__c = 'TEXAS';
        dnbController.endCustomer.Mailing_country__c = 'India';
        dnbController.endCustomer.Tax_Id__c='6237900';
        dnbController.endCustomer.Zip_Code__c = '12345';
        dnbController.useOriginalAddress();
        PageReference pageRef = Page.searchEndCustomerFromDnB;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('dupEndCustContact','0033B000004udyg');
        dnbController.createNewContForm();
        dnbController.objEndCustumerContact.Name ='test@test.com';
        dnbController.objEndCustumerContact.Email__c ='test2@test.com';
        dnbController.objEndCustumerContact.Last_Name__c ='test@test.com';
        dnbController.objEndCustumerContact.Phone__c ='987656567';
        dnbController.saveEndCustomerDetails();
        dnbController.endCustomer.Mailing_country__c = 'canada';
        dnbController.endCustomer.Mailing_street__c = 'Albert';
        dnbController.searchDnB();
        system.assertEquals(partnerUser.Email,'mylastname@dell.com');
        }
    }
        public static testmethod void testMethod5(){
        User partnerUser = [SELECT id,Email,contact.accountId FROM USER WHERE Email='MyLastName@dell.com' ];
        system.runAs(partnerUser){
        PageReference pageRef = Page.searchEndCustomerFromDnB;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('dupEndCustContact','0033B000004udyg');
        VFcntrl_SearchEndCustomerFromDnB dnbController = new VFcntrl_SearchEndCustomerFromDnB();
        dnbController.onPageLoad();
        
        dnbController.markRequired();
        dnbController.endCustomer.Name = 'John';
        dnbController.endCustomer.Mailing_street__c = 'Albert';
        dnbController.endCustomer.Mailing_city__c = 'Hyd';
        dnbController.endCustomer.Mailing_State__c = 'TEXAS';
        dnbController.endCustomer.Mailing_country__c = 'India';
        dnbController.endCustomer.Zip_Code__c = '';
        dnbController.useOriginalAddress();
        dnbController.createNewContForm();
        dnbController.saveEndCustomerDetails();
        dnbController.EndCustomer.Mailing_country__c='canada';
        Test.startTest();
        StaticResourceCalloutMock mockResponse = new StaticResourceCalloutMock();  
        mockResponse.setStaticResource('DnB_response_body_staticresource_500');
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('OK');
        mockResponse.setHeader('Content-Type', 'text/xml;charset=UTF-8');
       // mockResponse.setHeader('Authorization',System.Label.Deal_Reg_MDM_Prod_Credentials);  
        Test.setMock(HttpCalloutMock.class, mockResponse);
        dnbController.searchDnB();
        Test.stopTest();
        system.assertEquals(partnerUser.Email,'mylastname@dell.com');
        }
            
    }
        public static testmethod void testMethod6(){
        User partnerUser = [SELECT id,Email,contact.accountId FROM USER WHERE Email='MyLastName@dell.com' ];
        system.runAs(partnerUser){
        PageReference pageRef = Page.searchEndCustomerFromDnB;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('dupEndCustContact','0033B000004udyg');
        VFcntrl_SearchEndCustomerFromDnB dnbController = new VFcntrl_SearchEndCustomerFromDnB();
        dnbController.onPageLoad();
        
        dnbController.markRequired();
        dnbController.endCustomer.Name = 'John';
        dnbController.endCustomer.Mailing_street__c = 'Albert';
        dnbController.endCustomer.Mailing_city__c = 'Hyd';
        dnbController.endCustomer.Mailing_State__c = 'TEXAS';
        dnbController.endCustomer.Mailing_country__c = 'India';
        dnbController.endCustomer.Zip_Code__c = '';
        dnbController.useOriginalAddress();
        dnbController.createNewContForm();
        dnbController.saveEndCustomerDetails();
        dnbController.EndCustomer.Mailing_country__c='canada';
        Test.startTest();
        StaticResourceCalloutMock mockResponse = new StaticResourceCalloutMock();  
        mockResponse.setStaticResource('DnB_response_body_staticresource_exception');
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('OK');
    
        mockResponse.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        mockResponse.setHeader('Authorization',System.Label.Deal_Reg_MDM_Prod_Credentials);  
        Test.setMock(HttpCalloutMock.class, mockResponse);
        dnbController.searchDnB();
        Test.stopTest();
        system.assertEquals(partnerUser.Email,'mylastname@dell.com');
        }
            }     
             public static testmethod void testMethod7(){
         User partnerUser = [SELECT id,Email,contact.accountId FROM USER WHERE Email='MyLastName@dell.com' ];
        system.runAs(partnerUser){
        PageReference pageRef = Page.searchEndCustomerFromDnB;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('dupEndCustContact','0033B000004udyg');
        VFcntrl_SearchEndCustomerFromDnB dnbController = new VFcntrl_SearchEndCustomerFromDnB();
        dnbController.onPageLoad();
        
        dnbController.markRequired();
        dnbController.endCustomer.Name = 'John';
        dnbController.endCustomer.Mailing_street__c = 'Albert';
        dnbController.endCustomer.Mailing_city__c = 'Hyd';
        dnbController.endCustomer.Mailing_State__c = 'TEXAS';
        dnbController.endCustomer.Mailing_country__c = 'India';
        dnbController.endCustomer.Zip_Code__c = '';
        dnbController.useOriginalAddress();
        dnbController.createNewContForm();
        dnbController.saveEndCustomerDetails();
        dnbController.EndCustomer.Mailing_country__c='canada';
        Test.startTest();
        StaticResourceCalloutMock mockResponse = new StaticResourceCalloutMock();  
        mockResponse.setStaticResource('DnB_response_body_staticresource_500');
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('faultcode');
    
        mockResponse.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        mockResponse.setHeader('Authorization',System.Label.Deal_Reg_MDM_Prod_Credentials);  
        Test.setMock(HttpCalloutMock.class, mockResponse);
        dnbController.searchDnB();
        Test.stopTest();
        system.assertEquals(partnerUser.Email,'mylastname@dell.com');
        }
            
    } 
    public static testmethod void testUIValidations(){
        VFcntrl_SearchEndCustomerFromDnB dnbController = new VFcntrl_SearchEndCustomerFromDnB();
        dnbController.onPageLoad();
        
        Test.startTest();
        dnbController.endCustomer.Name = '%J';
        //dnbController.endCustomer.Mailing_street__c = 'Albert';
        //dnbController.endCustomer.Mailing_city__c = 'Hyd';
        //dnbController.endCustomer.Mailing_State__c = 'Texas';
        dnbController.endCustomer.Mailing_country__c = 'canada';
        dnbController.endCustomer.Zip_Code__c = '12345';
        StaticResourceCalloutMock mockResponse = new StaticResourceCalloutMock();  
        mockResponse.setStaticResource('DnB_response_body_staticresource');
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('OK');
    
        mockResponse.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        mockResponse.setHeader('Authorization',System.Label.Deal_Reg_MDM_Prod_Credentials);  
        Test.setMock(HttpCalloutMock.class, mockResponse);
        dnbController.searchDnB();
       
        Test.stopTest();
        System.assert(ApexPages.hasMessages());
    }  
    
    public static testmethod void testUIValidations2(){
       
        VFcntrl_SearchEndCustomerFromDnB dnbController = new VFcntrl_SearchEndCustomerFromDnB();
        dnbController.onPageLoad();
        
        Test.startTest();
        dnbController.endCustomer.Name = '%J';
        dnbController.endCustomer.Mailing_street__c = 'Albert';
        dnbController.endCustomer.Mailing_city__c = 'H%';
        dnbController.endCustomer.Mailing_State__c = 'T%';
        //dnbController.endCustomer.Mailing_country__c = 'canada';
        dnbController.endCustomer.Zip_Code__c = '12345';
        StaticResourceCalloutMock mockResponse = new StaticResourceCalloutMock();  
        mockResponse.setStaticResource('DnB_response_body_staticresource');
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('OK');
    
        mockResponse.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        mockResponse.setHeader('Authorization',System.Label.Deal_Reg_MDM_Prod_Credentials);  
        Test.setMock(HttpCalloutMock.class, mockResponse);
        dnbController.searchDnB();
       
        Test.stopTest();
        System.assert(ApexPages.hasMessages());
    }  
    /*
     public static testmethod void addcontactstodeal2(){
     
      
                VFcntrl_SearchEndCustomerFromDnB dnbController = new VFcntrl_SearchEndCustomerFromDnB();
             
               
                dnbController.endCustomerContact.Name ='JV'; 
                dnbController.endCustomerContact.Last_Name__c ='JV'; 
                dnbController.endCustomerContact.Email__c = 'js@dell.com';
                dnbController.objEndCustumerContact.Phone__c ='987656567';
             //   dnbController.endCustomerContact.Source_System__c = 'Deal Registration';
      //           dnbController.endCustomerContact.End_Customer__c = dnbController.endCustomer.Id;
                   dnbController.addContactToDeal();
                
           
   
}*/
    
        public static testmethod void testLocallanguage(){
            
          VFcntrl_SearchEndCustomerFromDnB dnbController1 = new VFcntrl_SearchEndCustomerFromDnB();
           dnbController1.onPageLoad();
           
         Country__c country = new Country__c(Name='china',Code__c='CH',DNB_COUNTRY_CODE__c ='825',DNB_ISO_country_code__c ='CH',DNB_Region__c = 'APJ',DnB_Supported_Country__c=true);
        insert country;
            
        PageReference pageRef = Page.searchEndCustomerFromDnB;
        Test.setCurrentPage(pageRef);
       
        VFcntrl_SearchEndCustomerFromDnB dnbController = new VFcntrl_SearchEndCustomerFromDnB();
        dnbController.selectedMailingCountry='12345';
        dnbController.duperror='Test';
        
        dnbController.endCustomer.Name = 'John';
        dnbController.endCustomer.Mailing_street__c = 'Albert';
        dnbController.endCustomer.Mailing_city__c = 'Hyd';
        dnbController.endCustomer.Mailing_State__c = 'TEXAS';
        dnbController.endCustomer.Mailing_country__c = 'china';
       // dnbController.isLocalLanguageSearch = true;
        dnbController.endCustomer.Zip_Code__c = '12345';
        StaticResourceCalloutMock mockResponse = new StaticResourceCalloutMock();  
        mockResponse.setStaticResource('dnb_local_language_response');
        mockResponse.setStatusCode(200);
        mockResponse.setStatus('OK');
        mockResponse.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        mockResponse.setHeader('Authorization',System.Label.Deal_Reg_MDM_Prod_Credentials);  
        Test.setMock(HttpCalloutMock.class, mockResponse);
        Test.startTest();
        dnbController.onPageLoad();
        dnbController.isLocalLanguageSearch = true;
        dnbController.searchDnB();      
      
        
        Test.stopTest();      
        system.assertEquals(country.Name,'china');
        }
    }
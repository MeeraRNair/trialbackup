/*
 * Author   : Jagadeesh
 * Purpose  : Test class for Case Ordersupport Recordtype 
 *
 * Revision CR Number   Release No  Date            Modified By    Description
 * -------- ---------   ----------  -----------  ------------      -----------
 * 1.0    CR 14665   10.01     25-June-2017                        New VF page for case Order Support Record Type
 * 2.0    CR 17671             26-June-2019         Meenu Sinha    Increased coverage 
 * 3.0                         15-Nov-2019          Emily          Adding test method for CSH Case
 */

@istest
public class Vfcntrl_OrderSupportvfpage_Test {

    public static testmethod void ordersupportvfpage(){
        TriggerExecutionController.setSkipAllTriggers(true);        
        Account portalAccount = createAccount();
        Contact portalCont1 = createContact(portalAccount.id,'navjot.sidhu@gmail.com');
        Case cs = createCase(portalAccount.id,portalCont1.id);


        Test.StartTest();
        Pagereference orderSupportVfpage = page.OrderSupportvfpage;
        Test.setCurrentPage(orderSupportVfpage);
        Apexpages.currentPage().getparameters().put('id', cs.Id);   
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);

        Vfcntrl_OrderSupportVfPage vfctrlordersuport = new Vfcntrl_OrderSupportVfPage(sc);
        vfctrlordersuport.attach1 = new Attachment(Name = 'Unit Test Attachment1', body = Blob.valueOf('Unit Test Attachment Body1'));     
        vfctrlordersuport.attach2 = new Attachment(Name = 'Unit Test Attachment2', body = Blob.valueOf('Unit Test Attachment Body2'));
        vfctrlordersuport.attach3 = new Attachment(Name = 'Unit Test Attachment3', body = Blob.valueOf('Unit Test Attachment Body3'));     
        vfctrlordersuport.attach4 = new Attachment(Name = 'Unit Test Attachment4', body = Blob.valueOf('Unit Test Attachment Body4'));
        vfctrlordersuport.attach5 = new Attachment(Name = 'Unit Test Attachment5', body = Blob.valueOf('Unit Test Attachment Body5'));
        //vfctrlordersuport.validateFormData();
        vfctrlordersuport.ClearSubtypeOptions();
        vfctrlordersuport.saveCase();
        //vfctrlordersuport.OnBehalfCase=true;
        //vfctrlordersuport.AccountId=portalAccount.id;
        //vfctrlordersuport.OnBehalfCaseAction();
        //vfctrlordersuport.saveAndNew();        
        Test.StopTest();

        cs.Order_Reference_Number_Type__c = null;     cs.Order_Number1__c = null;    
        cs.Sub_Type_Order_Support__c = null;      cs.ContactId = null;    cs.AccountId = null;
        Database.SaveResult result = Database.update(cs, false);
     
        system.assertNotEquals(null, result);
        
        Pagereference orderSupportVfpage1 = page.OrderSupportvfpage;
        Test.setCurrentPage(orderSupportVfpage1);
        Apexpages.currentPage().getparameters().put('id', cs.Id);   
        ApexPages.StandardController sc1 = new ApexPages.StandardController(cs);

        Vfcntrl_OrderSupportVfPage vfctrlordersuport1 = new Vfcntrl_OrderSupportVfPage(sc1);
        //vfctrlordersuport1.validateFormData();
        vfctrlordersuport1.userType = userinfo.getusertype();
        vfctrlordersuport1.saveCase();
    }
    
    public static testmethod void dealRegvfpage(){
        TriggerExecutionController.setSkipAllTriggers(true);        
        Account portalAccount = createAccount();
        
        Contact portalCont1 = createContact(portalAccount.id,'navjot.sidhu@gmail.com');
        
        system.assertNotEquals(null, portalCont1);
        
        Case cs = createDealRegCase(portalAccount.id,portalCont1.id);

        Test.StartTest();
        Pagereference dealRegVFPage = page.DealRegVFPage;
        Test.setCurrentPage(dealRegVFPage);
        Apexpages.currentPage().getparameters().put('id', cs.Id);   
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);

        Vfcntrl_OrderSupportVfPage vfctrlordersuport = new Vfcntrl_OrderSupportVfPage(sc);
        vfctrlordersuport.attach1 = new Attachment(Name = 'Unit Test Attachment1', body = Blob.valueOf('Unit Test Attachment Body1'));     
        vfctrlordersuport.attach2 = new Attachment(Name = 'Unit Test Attachment2', body = Blob.valueOf('Unit Test Attachment Body2'));
        vfctrlordersuport.attach3 = new Attachment(Name = 'Unit Test Attachment3', body = Blob.valueOf('Unit Test Attachment Body3'));     
        vfctrlordersuport.attach4 = new Attachment(Name = 'Unit Test Attachment4', body = Blob.valueOf('Unit Test Attachment Body4'));
        vfctrlordersuport.attach5 = new Attachment(Name = 'Unit Test Attachment5', body = Blob.valueOf('Unit Test Attachment Body5'));
        
        //vfctrlordersuport.validateFormData();
        vfctrlordersuport.ClearSubtypeOptions();
        vfctrlordersuport.saveCase();
        //vfctrlordersuport.saveAndNew();        
        Test.StopTest();
/*
        cs.Sub_Type_Internal_User__c = null; cs.Sub_Type_Partner_User__c = null;
        cs.Origin = null; cs.ContactId = null; cs.AccountId = null;
        Database.SaveResult result = Database.update(cs, false);
     
        Pagereference DealReg_VFPage1 = page.DealRegVFPage;
        Test.setCurrentPage(DealReg_VFPage1);
        Apexpages.currentPage().getparameters().put('id', cs.Id);   
        ApexPages.StandardController sc1 = new ApexPages.StandardController(cs);

        Vfcntrl_OrderSupportVfPage vfctrlordersuport1 = new Vfcntrl_OrderSupportVfPage(sc1);
        //vfctrlordersuport1.validateFormData();
        vfctrlordersuport1.saveCase();*/
    }
    
    public static testmethod void onBoardingvfpage(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Id dealRegRTId = StaticFactory.getRecordTypeIdByName('Case', 'RPQ');        
        Account portalAccount = createAccount();
        Contact portalCont1 = createContact(portalAccount.id,'navjot.sidhu@gmail.com');
        Case cs = createOnBoardingCase(portalAccount.id,portalCont1.id);

        system.assertNotEquals(null, portalCont1);

        Test.StartTest();
        Pagereference dealRegVFPage = page.OnBoardingVFPage;
        Test.setCurrentPage(dealRegVFPage);
        Apexpages.currentPage().getparameters().put('id', cs.Id); 
        Apexpages.currentPage().getparameters().put('clone', '1');  
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);

        Vfcntrl_OrderSupportVfPage vfctrlordersuport = new Vfcntrl_OrderSupportVfPage(sc);
        vfctrlordersuport.attach1 = new Attachment(Name = 'Unit Test Attachment1', body = Blob.valueOf('Unit Test Attachment Body1'));     
        vfctrlordersuport.attach2 = new Attachment(Name = 'Unit Test Attachment2', body = Blob.valueOf('Unit Test Attachment Body2'));
        vfctrlordersuport.attach3 = new Attachment(Name = 'Unit Test Attachment3', body = Blob.valueOf('Unit Test Attachment Body3'));     
        vfctrlordersuport.attach4 = new Attachment(Name = 'Unit Test Attachment4', body = Blob.valueOf('Unit Test Attachment Body4'));
        vfctrlordersuport.attach5 = new Attachment(Name = 'Unit Test Attachment5', body = Blob.valueOf('Unit Test Attachment Body5'));
        
        vfctrlordersuport.Countryregion();
        vfctrlordersuport.ClearSubtypeOptions();
        vfctrlordersuport.saveCase();
        vfctrlordersuport.caseRedirect();
        
        cs.Case_Reason_Order_Support__c='Address change';
        update cs;
        
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(cs);
        vfctrlordersuport = new Vfcntrl_OrderSupportVfPage(sc1);
        vfctrlordersuport.saveAndNew(); 
        vfctrlordersuport.caseRedirect();   
        Case cs1 = createPresalesCase(portalAccount.id,portalCont1.id);
        Pagereference dealRegVFPage1 = page.OnBoardingVFPage; 
        Test.setCurrentPage(dealRegVFPage1);
        Apexpages.currentPage().getparameters().put('id', cs1.Id); 
        Apexpages.currentPage().getparameters().put('clone', '1');  
        ApexPages.StandardController sc2 = new ApexPages.StandardController(cs1);
    Vfcntrl_OrderSupportVfPage vfctrlordersuport1 = new Vfcntrl_OrderSupportVfPage(sc2);
        vfctrlordersuport1.caseRedirect();
        
        Test.StopTest();

    }
    
    public static testmethod void distiSubTypes(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Id dealRegRTId = StaticFactory.getRecordTypeIdByName('Case', 'RPQ');        
        Account portalAccount = createAccount();
        Contact portalCont1 = createContact(portalAccount.id,'navjot.sidhu@gmail.com');
        Case cs = createOnBoardingCase(portalAccount.id,portalCont1.id);

        system.assertNotEquals(null, portalCont1);

        Test.StartTest();
        Pagereference dealRegVFPage = page.OnBoardingVFPage;
        Test.setCurrentPage(dealRegVFPage);
        Apexpages.currentPage().getparameters().put('id', cs.Id); 
        Apexpages.currentPage().getparameters().put('clone', '1');  
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);

        Vfcntrl_OrderSupportVfPage vfctrlordersuport = new Vfcntrl_OrderSupportVfPage(sc);
        vfctrlordersuport.attach1 = new Attachment(Name = 'Unit Test Attachment1', body = Blob.valueOf('Unit Test Attachment Body1'));     
        vfctrlordersuport.attach2 = new Attachment(Name = 'Unit Test Attachment2', body = Blob.valueOf('Unit Test Attachment Body2'));
        vfctrlordersuport.attach3 = new Attachment(Name = 'Unit Test Attachment3', body = Blob.valueOf('Unit Test Attachment Body3'));     
        vfctrlordersuport.attach4 = new Attachment(Name = 'Unit Test Attachment4', body = Blob.valueOf('Unit Test Attachment Body4'));
        vfctrlordersuport.attach5 = new Attachment(Name = 'Unit Test Attachment5', body = Blob.valueOf('Unit Test Attachment Body5'));
        
        vfctrlordersuport.accountRegion = 'APJ';
        vfctrlordersuport.distiSubTypes();
        vfctrlordersuport.Countryregion();
        vfctrlordersuport.ClearSubtypeOptions();
        vfctrlordersuport.saveCase();
        vfctrlordersuport.caseRedirect();
        
        cs.Case_Reason_Order_Support__c='Address change';
        update cs;
        
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(cs);
        vfctrlordersuport = new Vfcntrl_OrderSupportVfPage(sc1);
        vfctrlordersuport.accountRegion = 'Latam';
        vfctrlordersuport.distiSubTypes();
        vfctrlordersuport.saveAndNew(); 
        vfctrlordersuport.caseRedirect();   
        Case cs1 = createPresalesCase(portalAccount.id,portalCont1.id);
        
        Pagereference dealRegVFPage1 = page.OnBoardingVFPage; 
        Test.setCurrentPage(dealRegVFPage1);
        Apexpages.currentPage().getparameters().put('id', cs1.Id); 
        Apexpages.currentPage().getparameters().put('clone', '1');  
        ApexPages.StandardController sc2 = new ApexPages.StandardController(cs1);
        Vfcntrl_OrderSupportVfPage vfctrlordersuport1 = new Vfcntrl_OrderSupportVfPage(sc2);
        vfctrlordersuport.accountRegion = 'NA';
        vfctrlordersuport.distiSubTypes();
        cs1.Sub_Type_Order_Support__c = 'SPL Tech query';
        vfctrlordersuport1.distiCaseReasons();
        vfctrlordersuport1.caseRedirect();
        
        Test.StopTest();

    }

    //3.0
    public static testmethod void channelServicesHelpdeskVFPage(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Account portalAccount = createAccount();
        Contact portalCont1 = createContact(portalAccount.id,'navjot.sidhu@gmail.com');
        Case cs = createCSHCase(portalAccount.id,portalCont1.id);

        system.assertNotEquals(null, portalCont1);

        Test.StartTest();
        Pagereference channelServicesHelpdeskVFPage = page.ChannelServicesHelpdeskVFPage;
        Test.setCurrentPage(channelServicesHelpdeskVFPage);
        Apexpages.currentPage().getparameters().put('id', cs.Id); 
        Apexpages.currentPage().getparameters().put('clone', '1');  
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);

        Vfcntrl_OrderSupportVfPage vfctrlordersuport = new Vfcntrl_OrderSupportVfPage(sc);
        vfctrlordersuport.attach1 = new Attachment(Name = 'Unit Test Attachment1', body = Blob.valueOf('Unit Test Attachment Body1'));     
        vfctrlordersuport.attach2 = new Attachment(Name = 'Unit Test Attachment2', body = Blob.valueOf('Unit Test Attachment Body2'));
        vfctrlordersuport.attach3 = new Attachment(Name = 'Unit Test Attachment3', body = Blob.valueOf('Unit Test Attachment Body3'));     
        vfctrlordersuport.attach4 = new Attachment(Name = 'Unit Test Attachment4', body = Blob.valueOf('Unit Test Attachment Body4'));
        vfctrlordersuport.attach5 = new Attachment(Name = 'Unit Test Attachment5', body = Blob.valueOf('Unit Test Attachment Body5'));
        
        vfctrlordersuport.Countryregion();
        vfctrlordersuport.ClearSubtypeOptions();
        vfctrlordersuport.saveCase();
        vfctrlordersuport.caseRedirect();
        
        cs.Case_Reason_Order_Support__c='Renewal Quote Request';
        update cs;
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(cs);
        vfctrlordersuport = new Vfcntrl_OrderSupportVfPage(sc1);
        vfctrlordersuport.saveAndNew(); 
        vfctrlordersuport.caseRedirect();   
        Case cs1 = createCSHCase(portalAccount.id,portalCont1.id);
        Pagereference channelServicesHelpdeskVFPage1 = page.ChannelServicesHelpdeskVFPage; 
        Test.setCurrentPage(channelServicesHelpdeskVFPage1);
        Apexpages.currentPage().getparameters().put('id', cs1.Id); 
        Apexpages.currentPage().getparameters().put('clone', '1');  
        ApexPages.StandardController sc2 = new ApexPages.StandardController(cs1);
        Vfcntrl_OrderSupportVfPage vfctrlordersuport1 = new Vfcntrl_OrderSupportVfPage(sc2);
        vfctrlordersuport1.caseRedirect();
        
        Test.StopTest();
    }
    
    //Test Data Insertions
    static Account createAccount(){
        Country__c objCountry = new Country__c(Region__c='EMEA',Code__c='BS',Name='Test');
        insert objCountry;
        Id accMasterRecId = IdLookupUtils.getRecordTypeId('Master Account', 'Account', true);
        Account accMasterRec = new Account(name = 'Test PAccv', Account_Country__c='BAHAMAS',account_country_code__c = 'BS', RecordTypeId = accMasterRecId, 
        Type = 'Master', Partner_Type__c = 'DISTRIBUTOR (GCC)', Dell_Certification_Areas__c = 'Storage;Server');
        insert accMasterRec;
        return accMasterRec;
        
       /* Id accRTId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
        Account testAccount= new Account(name = 'Test PAccv', Account_Country__c='BAHAMAS',account_country_code__c = 'BS', RecordTypeId = accRTId, 
        Type = 'Partner', Partner_Type__c = 'DISTRIBUTOR (GCC)', Dell_Certification_Areas__c = 'Storage;Server');
        insert testAccount;
        return testAccount;
        */
    }
    
    
    
    static Contact createContact(Id accountId,String email){
        
        System_Behavior_Bypasser__c obj = new System_Behavior_Bypasser__c();
        obj.Bypass_Contact_VRs__c = true;
        insert obj;
        
        Contact newCont = new Contact(FirstName = 'conv', Phone = '9876543987', AccountId = accountId, Email = 'abc@dell.comfdev', Lastname = 'UT', 
        Decision_Making_Role__c = 'Influencer', Job_Function__c = 'Finance', Job_Function_Role__c = 'Finance Manager', Primary_Contact__c = false,
        MobilePhone = '991122789', Eloqua_ID__c = '1234');
        insert newCont;
        return newCont;
    }
    
    static Case createCase(Id accountId,Id contactId){
        Id orderSuppRTId = StaticFactory.getRecordTypeIdByName('Case', 'order support');
          Case newCase = new case(Accountid = accountId, Contactid = contactId, Status = 'Open', Priority = 'High', Alternate_Phone__c ='1234',
                 Sub_Type_Order_Support__c ='credit Request', Subject  ='Test Case Subject', Description ='Test Case Subject', 
                 Order_Reference_Number_Type__c = 'Order Number', Order_Number1__c = '123',Request_Escalation__c = true, 
                 recordTypeId = orderSuppRTId);  
          insert newCase;
          return newCase;
    }
    static Case createDealRegCase(Id accountId,Id contactId){
          Id dealRegRTId = StaticFactory.getRecordTypeIdByName('Case', 'Deal Registration');
          Case newCase = new case(Accountid = accountId, Contactid = contactId, Status = 'Open', Priority = 'High', Alternate_Phone__c ='1234',
                 Subject  ='Test Case Subject', Description ='Test Case Subject', Sub_Type_Internal_User__c = 'Test', Origin = 'test',
                 recordTypeId = dealRegRTId);    
          insert newCase;
          return newCase;
    }
    static Case createOnBoardingCase(Id accountId,Id contactId){
          Id dealRegRTId = StaticFactory.getRecordTypeIdByName('Case', 'On Boarding');
          Case newCase = new case(Accountid = accountId, Contactid = contactId, Status = 'Open', Priority = 'High', Alternate_Phone__c ='1234',
                 Subject  ='Test Case Subject', Description ='Test Case Subject', Sub_Type_Internal_User__c = 'Test', Origin = 'test',
                 recordTypeId = dealRegRTId,Case_Reason_Order_Support__c='Tax ID change');    
          insert newCase;
          return newCase;
    }
    Static Case createPresalesCase(Id accountId, Id contactId)
    {
        Id presalesRTId = StaticFactory.getRecordTypeIdByName('Case', 'Converged');
         Case newCase = new case(Accountid = accountId, Contactid = contactId, Status = 'Open', Priority = 'High', Alternate_Phone__c ='1234',
                 Subject  ='Test Case Subject', Description ='Test Case Subject', Sub_Type_Internal_User__c = 'Test', Origin = 'test',
                 recordTypeId = presalesRTId,Case_Reason_Order_Support__c='Tax ID change');    
          insert newCase;
          return newCase;
        
    }
    Static Case createCSHCase(Id idAccountId, Id idContactId)
    {
        Id idCSHRT = StaticFactory.getRecordTypeIdByName('Case', 'Channel Services Helpdesk');
        Case newCase = new case(Accountid = idAccountId, Contactid = idContactId, Status = 'Open', Priority = 'High', 
                 Subject  ='Test Case Subject', Description ='Test Case Subject', Origin = 'System', CaseRTMigrate__Contact_Name_User__c='005A0000003Ksio',
                 recordTypeId = idCSHRT, Sub_Type_Order_Support__c='Renewal Sales', Case_Reason_Order_Support__c='Other', Partner_Motion__c='Channel');    
        insert newCase;
        return newCase;
        
    }
    

}
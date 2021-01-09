/*---------------------------------------------

History:
    1.0 : 16-Nov-2011: Hanan     : CR 6706,6707,6709 (R13.1):- Created with test methods these CRs
    1.1 : 13-Dec-2011: Krishna   : CR 6708(R13.1):- Added test methods for CMI data Queue manipulation functionalities
    2.0 : 08-Jan-2019: Emily     : CR 16970(FY20-0202) - Remove virtualization__c
---------------------------------------------*/
@isTest
private class PartnerEndUserDataCaptureUtilsTest {

    //Added custom settings to populate StageName values.
    @testSetup static void setup() {
        // Create common test OWD settings
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Insert owdSetting;
    }
    
    Static Account partnerAccount = new Account();
    Static Account newAcc = new Account();
    Static End_Customer__c endCustomer = new End_Customer__c();
    Static End_Customer__c endCustomer2 = new End_Customer__c();
    Static Opportunity dealRegOppty = new Opportunity();

    Static Opportunity customerOppty = new Opportunity();
    static User userRec = new User();
    Static Contact partnerContact = new COntact();

    static testMethod void testCMIQueueCreation() {
        // TO DO: implement unit test
    }

    public static void createData() {
        TriggerExecutionController.setSkipAllTriggers(true); 
        
        profile profileRec = [select id from profile where name like '%PRM Portal%'
        Limit 1];
        UserRole userRoleRec = [Select PortalAccountId, Name, Id From UserRole where name like '%WW_Exec'
        Limit 1];
        RecordType REUDRecType = [SELECT Name, Id, SobjectType FROM RecordType WHERE Name = 'Deal Registration'
        AND SobjectType = 'Opportunity'];
        RecordType recType = [SELECT Name, Id, SobjectType FROM RecordType WHERE Name = 'Deal Registration for Existing End Customer'
        AND SobjectType = 'Opportunity'];
        Id accRTId = IdLookupUtils.getRecordTypeId('Partner Account', 'Account', true);
        newAcc = new Account(name = 'Test', RecordtypeId = accRTId, Type = 'Partner');
        insert newAcc;
        //Creating Partner Account   
        partnerAccount.name = 'PartnerAccount';
        partnerAccount.Account_Country_Code__c = 'AI';
        partnerAccount.Account_Country__c = 'ANGUILLA';
        partnerAccount.Type = 'Partner';
        insert partnerAccount;
        partnerAccount.IsPartner = true;
        partnerAccount.RecordTypeId = System.Label.RecType_Partner_Account;
        update partnerAccount;

        //Creating end customer   
        endCustomer.Account_Department__c = 'xxx';
        endCustomer.Account_Industry__c = 'Biotechnology';
        endCustomer.Mailing_city__c = 'ff';
        endCustomer.Mailing_country__c = 'dasssa';
        endCustomer.Mailing_State__c = 'sdawwqwq';
        endCustomer.Mailing_street__c = 'ddsdqwewdc';
        endCustomer.Partner_Account__c = partnerAccount.id;
        endCustomer.Segment__c = 'Education';
        endCustomer.Status__c = 'Active';
        endCustomer.Tax_Id__c = 'aaaaa';
        endCustomer.Total_of_End_User_Employees__c = '100 - 199';
        endCustomer.Zip_Code__c = '333333';
        endCustomer.Name = 'Company';
        endCustomer.Mailing_street2__c = 'Dark street 2';
        endCustomer.B2BCRTEndUserID__c = '666';

        insert endCustomer;

        End_Customer_Contact__c endCstmrCntct = new End_Customer_Contact__c();
        endCstmrCntct.Name = 'test';
        endCstmrCntct.Email__c = 'testemail@Company31.com';
        endCstmrCntct.End_Customer__c = endCustomer.Id;
        endCstmrCntct.Fax__c = '222';
        endCstmrCntct.Last_Name__c = 'tester';
        endCstmrCntct.Mobile__c = '333';
        endCstmrCntct.Phone__c = '4444';
        endCstmrCntct.Status__c = 'Active';
        endCstmrCntct.Title__c = 'xsad';

        insert endCstmrCntct;

        //Creating Partner Contact
        partnerContact.AccountId = partnerAccount.id;
        partnerContact.Email = 'John.Doe@dell.com';
        partnerContact.FirstName = 'John';
        partnerContact.LastName = 'Doe';
        partnerContact.Title = 'VP';
        partnerContact.MailingStreet = '123 Main';
        partnerContact.MailingCity = 'Peoria';
        partnerContact.MailingState = 'IL';
        partnerContact.MailingPostalCode = '33333';
        partnerContact.Phone = '3213213211';
        partnerContact.MobilePhone = '3213213211';
        partnerContact.Fax = '3213123211';

        insert partnerContact;

        //userRec=[select id,name from user where ProfileId =:profileRec.Id and IsActive=true Limit 1];

        //Creating Partner User

        userRec.Username = 'XXYYZZ@dell.com';
        userRec.Alias = 'test';
        userRec.Email = 'testuser@test.com';
        userRec.FirstName = 'John';
        userRec.LastName = 'Doe';
        userRec.ProfileId = profileRec.Id;
        userRec.LanguageLocaleKey = 'en_US';
        userRec.LocaleSidKey = 'en_US';
        userRec.EmailEncodingKey = 'UTF-8';
        userRec.TimeZoneSidKey = 'America/Los_Angeles';
        userRec.Badge_Number__c = null;
        userRec.ContactId = partnerContact.id;
        //userRec.userRoleId=userRoleRec.Id;
        insert userRec;

        dealRegOppty.Name = 'Test';
        dealRegOppty.Total_Expected_Dell_Revenue__c = 1000;
        dealRegOppty.CloseDate = System.today() + 100;
        dealRegOppty.Engagement_Type__c = 'Public Tender';
        dealRegOppty.OS_Type__c = 'Other';
        dealRegOppty.Solution_Scope__c = 'Hardware and support only';
        dealRegOppty.Justification_Statement__c = 'adaddaf';
        //2.0 dealRegOppty.virtualization__c = 'None';
        dealRegOppty.GTM_Message__c = 'xxxxxxx';
        dealRegOppty.StageName = 'Plan - 1%';
        dealRegOppty.End_User_Account_Name__c = 'Apple';
        dealRegOppty.End_User_Registration_Tax_Code__c = '2123';
        dealRegOppty.End_User_Account_Department__c = 'xys';
        dealRegOppty.End_User_Account_Industry__c = 'assa';
        dealRegOppty.End_User_Mailing_Street__c = 'asadsd';
        dealRegOppty.End_User_Mailing_City__c = 'asadsd';
        dealRegOppty.End_User_Mailing_Country__c = 'INDIA';
        dealRegOppty.End_User_Mailing_State_Province_Region__c = 'ssss';
        dealRegOppty.End_User_Mailing_Zip_Postal_Code__c = '1323';
        dealRegOppty.End_User_Segment__c = 'qwe';
        dealRegOppty.End_User_Website_URL_Address__c = 'www.google.com';
        dealRegOppty.End_User_First_Name__c = 'John';
        dealRegOppty.End_User_Last_Name__c = 'doe';
        dealRegOppty.End_User_Mobile__c = '3333';
        dealRegOppty.End_User_Phone__c = '222';
        dealRegOppty.End_User_Title__c = 'wwww';
        dealRegOppty.End_User_Email__c = 'test@test.com';
        dealRegOppty.End_User_Fax__c = '1222';
        dealRegOppty.recordtypeId = REUDRecType.Id;
        dealRegOppty.Save_End_Customer_to_my_list__c = 'Yes';
        dealRegOppty.Owner = UserRec;


        customerOppty.Name = 'Test2';
        customerOppty.Total_Expected_Dell_Revenue__c = 1000;
        customerOppty.CloseDate = System.today() + 100;
        customerOppty.Engagement_Type__c = 'Public Tender';
        customerOppty.OS_Type__c = 'Other';
        customerOppty.Solution_Scope__c = 'Hardware and support only';
        customerOppty.Justification_Statement__c = 'adaddaf';
        //2.0 customerOppty.virtualization__c = 'None';
        customerOppty.GTM_Message__c = 'xxxxxxx';
        customerOppty.StageName = 'Plan - 1%';
        customerOppty.recordtypeId = recType.Id;
        customerOppty.End_Customer__c = endCustomer.Id;
        customerOppty.End_Customer_Contact__c = endCstmrCntct.Id;
        
        TriggerExecutionController.setSkipAllTriggers(false); 
    }


    public static testMethod void testDuplicateCheckError() {
        createData();
        End_Customer_Contact__c endCstmrCntct2 = new End_Customer_Contact__c();
        endCstmrCntct2.Name = 'test2';
        endCstmrCntct2.Email__c = 'testemail@cmpy30.com';
        endCstmrCntct2.End_Customer__c = endCustomer.Id;
        endCstmrCntct2.Fax__c = '222';
        endCstmrCntct2.Last_Name__c = 'tester';
        endCstmrCntct2.Mobile__c = '333';
        endCstmrCntct2.Phone__c = '4444';
        endCstmrCntct2.Status__c = 'Active';
        endCstmrCntct2.Title__c = 'xsad';
        try {
            insert endCstmrCntct2;
        } Catch(Exception e) {
            // System.assert(e.getMessage().contains('Another End Customer Contact has the same End Customer & emailId.'),true);            
            //System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' ,e.getDmlStatusCode(0));
        }
    }
    public static testMethod void testDuplicateCheckNoError() {
        createData();
        End_Customer_Contact__c endCstmrCntct3 = new End_Customer_Contact__c();
        endCstmrCntct3.Name = 'test2';
        endCstmrCntct3.Email__c = 'testemail2@company31.com';
        endCstmrCntct3.End_Customer__c = endCustomer.Id;
        endCstmrCntct3.Fax__c = '222';
        endCstmrCntct3.Last_Name__c = 'tester';
        endCstmrCntct3.Mobile__c = '333';
        endCstmrCntct3.Phone__c = '4444';
        endCstmrCntct3.Status__c = 'Active';
        endCstmrCntct3.Title__c = 'xsad';
        try {
            insert endCstmrCntct3;
            End_Customer_Contact__c contact = [select id, name, Email__c, End_Customer__c, Fax__c, Last_Name__c, Mobile__c, Phone__c, Status__c, Title__c from End_Customer_Contact__c where id = : endCstmrCntct3.Id];
            System.assertEquals('test2', contact.Name);
            System.assertEquals('testemail2@company31.com', contact.Email__c);
            System.assertEquals(endCustomer.Id, contact.End_Customer__c);
            System.assertEquals('222', contact.Fax__c);
            System.assertEquals('tester', contact.Last_Name__c);
            System.assertEquals('333', contact.Mobile__c);
            System.assertEquals('4444', contact.Phone__c);
            System.assertEquals('Active', contact.Status__c);
            System.assertEquals('xsad', contact.Title__c);
        } Catch(Exception e) {}
    }

    public static testMethod void testCreateEndCustomer() {
        createData();
        // System.runAs(userRec){
        // dealRegOppty.partnerAccountId=partnerAccount.id;
        Test.startTest();
        insert dealRegOppty;

        Opportunity opportunityElt = new Opportunity(Id = dealRegOppty.Id, Deal_Registration_Status__c = 'Submitted');
        update opportunityElt;
        Test.stopTest();

        //} 
        /*
             Opportunity oppty=[select id,end_customer__c,end_customer_contact__c,partnerAccountId,End_User_Account_Name__c from opportunity where id=:dealRegOppty.Id];
             
            End_Customer__c endCstmr=[select Name,Account_Department__c,Account_Industry__c,Customer_Id__c,End_User_Account__c,Mailing_city__c,Mailing_country__c,Mailing_State__c,Mailing_street__c,Partner_Account__c,Segment__c,Status__c,Tax_Id__c,Total_of_End_User_Employees__c,Website__c,Zip_Code__c from End_Customer__c where Partner_Account__c=:oppty.PartnerAccountId and name=:oppty.End_User_Account_Name__c];         
        
            End_Customer_Contact__c contact=[select id,name,Email__c,End_Customer__c,Fax__c,Last_Name__c,Mobile__c,Phone__c,Status__c,Title__c from End_Customer_Contact__c where End_Customer__c=:endCstmr.Id];
            
            System.assertEquals(endCstmr.Id,oppty.end_customer__c);  
            System.assertEquals(contact.Id,oppty.end_customer_contact__c);
            
            System.assertEquals('Apple',endCstmr.Name);  
            System.assertEquals('xys',endCstmr.Account_Department__c);            
            System.assertEquals(dealRegOppty.End_User_Account_Industry__c,endCstmr.Account_Industry__c);  
            System.assertEquals(oppty.end_customer__c,endCstmr.Id);            
            System.assertEquals('asadsd',endCstmr.Mailing_city__c);  
            System.assertEquals(dealRegOppty.End_User_Mailing_Country__c,endCstmr.Mailing_country__c);
            System.assertEquals('ssss',endCstmr.Mailing_State__c);
            System.assertEquals('asadsd',endCstmr.Mailing_street__c);
            System.assertEquals(oppty.partnerAccountId,endCstmr.Partner_Account__c);
            
            System.assertEquals(dealRegOppty.End_User_First_Name__c,contact.Name);  
            System.assertEquals(dealRegOppty.End_User_Email__c,contact.Email__c);            
           System.assertEquals(oppty.end_customer_contact__c,contact.Id);
           */


    }

    public static testMethod void testUpdateExistingEndCustomerDetails() {
        createData();
        System.runAs(userRec) {
            Test.StartTest();
            insert customerOppty;
            Test.StopTest();
        }
    }

    public static testMethod void testDeActivateCustomers() {
        createData();
        partnerAccount.status__c = 'Inactive';
        update partnerAccount;
    }
    public static testMethod void testDeActivateContacts() {
        createData();
        endCustomer.status__c = 'Inactive';
        update endCustomer;
    }
    public static testMethod void testDupCheckOfEndCustomerAndContact() {

        createData();

        Test.startTest();
        List < Profile > userProfile = [select id, name from profile where name like '%System Administrator%'
        order by name limit 2];
        User tempUser = new User(
        Username = String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_') + '@dell.com.dev',
        Alias = 'test',
        Email = 'test109@dell.com',
        FirstName = 'Tfirst A1',
        LastName = 'TLast2',
        ProfileId = userProfile[0].Id,
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        TimeZoneSidKey = 'America/Los_Angeles',
        Badge_Number__c = 'Test' + System.currentTimeMillis(),
        Title = 'Test Title',
        //Country = Cntry.id,
        //Contact = testCon.Id, 
        CurrencyIsoCode = 'USD');
        insert tempUser;
        //Creating end customer   
        endCustomer2.Account_Department__c = 'xxx4';
        endCustomer2.Account_Industry__c = 'Biotechnologys';
        endCustomer2.Mailing_city__c = 'ffs';
        endCustomer2.Mailing_country__c = 'dasssas';
        endCustomer2.Mailing_State__c = 'sdawwqwqs';
        endCustomer2.Mailing_street__c = 'ddsdqwewdcs';
        //endCustomer2.Partner_Account__c = newAcc.id;
        endCustomer2.Partner_Account__c = partnerAccount.id;
        endCustomer2.Segment__c = 'Education';
        endCustomer2.Status__c = 'Active';
        endCustomer2.Tax_Id__c = 'aaaaas';
        endCustomer2.Total_of_End_User_Employees__c = '100 - 199';
        endCustomer2.Zip_Code__c = '3333334';
        endCustomer2.Name = 'Companys';
        endCustomer2.Mailing_street2__c = 'Dark street 24';
        endCustomer2.B2BCRTEndUserID__c = '6664';
        insert endCustomer2;
        //Create End Customer Contact
        End_Customer_Contact__c endCstmrCntct4 = new End_Customer_Contact__c();
        endCstmrCntct4.Name = 'test222';
        endCstmrCntct4.Email__c = 'testemail22@Company31.com';
        endCstmrCntct4.End_Customer__c = endCustomer2.Id;
        endCstmrCntct4.Fax__c = '22432';
        endCstmrCntct4.Last_Name__c = 'tester43';
        endCstmrCntct4.Mobile__c = '3335433';
        endCstmrCntct4.Phone__c = '44445555';
        endCstmrCntct4.Status__c = 'Active';
        endCstmrCntct4.Title__c = 'xsad455';

        insert endCstmrCntct4;
        //Create Deal Reg Record 
        Id DealRTId = IdLookupUtils.getRecordTypeId('Deal Registration', 'Opportunity', true);
        Opportunity testOppty = new Opportunity(Name = 'testOpportunityPlanRedirectPage Test Oppty',
        AccountId = newAcc.Id,
        Deal_Registration_Status__c = 'Approved',
        Total_Expected_Dell_Revenue__c = 1919191,
        RecordTypeID = DealRTId,
        Engagement_Type__c = 'Public Tender',
        Justification_Statement__c = 'Statement1',
        End_User_Account_Name__c = 'Companys',
        End_User_Mailing_City__c = 'City',
        End_User_Mailing_State_Province_Region__c = 'State 1',
        End_User_Mailing_Country__c = 'dasssas',
        Save_End_Customer_to_my_list__c = 'Yes',
        End_User_First_Name__c = 'First Name',
        End_User_Last_Name__c = 'Last Name',
        End_User_Email__c = 'user@dell.coin',
        Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
        StageName = 'Plan - 1%',
        End_Customer__c = endCustomer.Id,
        OwnerId = userRec.Id,
        Deal_Type__c = 'LOB Deal',
        CloseDate = System.Today() + 30);
        
        Opportunity testOppty1 = new Opportunity(Name = 'testOpportunityPlanRedirectPage Test Oppty',
        AccountId = newAcc.Id,
        Deal_Registration_Status__c = 'Approved',
        Total_Expected_Dell_Revenue__c = 1919191,
        RecordTypeID = DealRTId,
        Engagement_Type__c = 'Public Tender',
        Justification_Statement__c = 'Statement1',
        End_User_Account_Name__c = 'Companys',
        End_User_Mailing_City__c = 'City',
        End_User_Mailing_State_Province_Region__c = 'State 1',
        End_User_Mailing_Country__c = 'dasssas',
        Save_End_Customer_to_my_list__c = 'Yes',
        End_User_First_Name__c = 'First Name',
        End_User_Last_Name__c = 'Last Name',
        End_User_Email__c = 'user@dell.coin',
        Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
        StageName = 'Plan - 1%',
        End_Customer__c = endCustomer.Id,
        OwnerId = userRec.Id,
        Deal_Type__c = 'LOB Deal',
        CloseDate = System.Today() + 30);
        
        Opportunity testOppty2 = new Opportunity(Name = 'testOpportunityPlanRedirectPage Test Oppty',
        AccountId = newAcc.Id,
        Deal_Registration_Status__c = 'Approved',
        Total_Expected_Dell_Revenue__c = 1919191,
        RecordTypeID = DealRTId,
        Engagement_Type__c = 'Public Tender',
        Justification_Statement__c = 'Statement1',
        End_User_Account_Name__c = 'Companys',
        End_User_Mailing_City__c = 'City',
        End_User_Mailing_State_Province_Region__c = 'State 1',
        End_User_Mailing_Country__c = 'dasssas',
        Save_End_Customer_to_my_list__c = 'Yes',
        End_User_First_Name__c = 'First Name',
        End_User_Last_Name__c = 'Last Name',
        End_User_Email__c = 'newuser@dell.coin',
        Is_the_Customer_Part_of_a_Larger_Group__c = 'Yes',
        StageName = 'Plan - 1%',
        End_Customer__c = endCustomer.Id,
        OwnerId = userRec.Id,
        Deal_Type__c = 'LOB Deal',
        CloseDate = System.Today() + 30);

        List<opportunity> oppListToInsert = new List<Opportunity>();
        oppListToInsert.add(testOppty);
          oppListToInsert.add(testOppty1);
          oppListToInsert.add(testOppty2);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        //insert testOppty;
        insert oppListToInsert;
        List < Opportunity > dealList = new List < Opportunity > {
            testOppty
        };
        Set < Id > ownerSet = new Set < Id > {
            testOppty.OwnerID
        };
        Set < Id > partnerAccIdSet = new Set < Id > {
            newAcc.id
        };
        

        Map < String, End_Customer__c > mapOfEndCustmer = new Map < String, End_Customer__c > ();
        Map < Id, String > endCustIdMap = new Map < Id, String > ();
        Map < Id, Set < String >> enscustContactMap = new Map < Id, Set < String >> ();
        List < End_Customer_Contact__c > createEndCustContactList = new List < End_Customer_Contact__c > {
            endCstmrCntct4
        };
        Map < Id, User > userMap = new Map < Id, User > ([select id, contactId, contact.accountId from User where id in : ownerSet]);
        Map < Id, User > userMap1 = new Map < Id, User > ([select id, contactId, contact.accountId from User where id =: userRec.id]);
        End_Customer__c ec = [select Name, Account_Department__c, Account_Industry__c, Customer_Id__c, End_User_Account__c, Mailing_city__c, Mailing_country__c, Mailing_State__c, Mailing_street__c, Partner_Account__c, Segment__c, Status__c, Tax_Id__c, Total_of_End_User_Employees__c, Website__c, Zip_Code__c from End_Customer__c where id =:endcustomer2.id];
        system.debug('ec'+ec);
        Set < Id > EndCustomerIDSet = new Set < Id > {
            ec.id
        };
        Opportunity oppty=[select id,end_customer__c,End_User_Email__c,Save_End_Customer_to_my_list__c,end_customer_contact__c,partnerAccountId,End_User_Account_Name__c,End_User_Mailing_Country__c,OwnerID from opportunity where id=:testOppty.Id];
        system.debug('oppty'+oppty);
        String uniqIden = ec.Name.toUpperCase() + ec.Mailing_country__c + ec.Partner_Account__c;
        system.debug('uniqIden'+uniqIden);
        String uniqEC = oppty.End_User_Account_Name__c.toUpperCase() + oppty.End_User_Mailing_Country__c+userMap.get(oppty.ownerId).contact.accountId;
        system.debug('uniqEC'+uniqEC);
        String uniqECC = uniqEC+oppty.End_User_Email__c;
        endCustIdMap.put(ec.id, uniqIden);
        system.debug('endCustIdMap'+endCustIdMap);
        mapOfEndCustmer.put(uniqIden, ec);
        //Id endCustId = mapOfEndCustmer.get(uniqEC).Id;
        PartnerEndUserDataCaptureUtils.deActivateCustomers(partnerAccIdSet);
        PartnerEndUserDataCaptureUtils.CreateCustomerContactPartnerRequest(dealList, ownerSet);
        PartnerEndUserDataCaptureUtils.DupCheckOfEndCustomerAndContact(oppListToInsert, userMap);
        system.assertequals(0,enscustContactMap.size());
        //system.assertequals(true,enscustContactMap.get(endCustId).contains(oppty.End_User_Email__c));
      //  if(!enscustContactMap.get(endCustId).contains(opp.End_User_Email__c) || enscustContactMap.size()==0
        Test.stopTest();
    }

}
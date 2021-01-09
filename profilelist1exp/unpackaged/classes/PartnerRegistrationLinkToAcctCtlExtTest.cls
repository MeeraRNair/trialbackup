@IsTest
private class PartnerRegistrationLinkToAcctCtlExtTest {
  
    private static testMethod void testScreenIsForUpdateOnly() {
        Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@acme.com',
            Company__c = 'Tyama');
        PartnerRegistrationLinkToAcctCtrlrExt extension = new PartnerRegistrationLinkToAcctCtrlrExt(
            new ApexPages.standardController(request));
        TestUtils.assertErrorMessagesExist();
        System.assertEquals(extension.doPageLoad(),null);
        System.assertNotEquals(extension.getAccountSearchResults(),null);
        System.assert(extension.getAccountSearchResults().isEmpty());
        TestUtils.assertErrorMessagesExist();
    }
    
    private static testMethod void testRegistrationIsNotSaved() {
        Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@acme.com');
        PartnerRegistrationLinkToAcctCtrlrExt extension = new PartnerRegistrationLinkToAcctCtrlrExt(
            new ApexPages.standardController(request));
        System.assertEquals(extension.doPageLoad(),null);

        insert request;
        extension = new PartnerRegistrationLinkToAcctCtrlrExt(
            new ApexPages.standardController(request));
        System.assertEquals(extension.doPageLoad(),null);
    } 
    
    private static testMethod void testNormalFlow() {
        Lead lead = new Lead(lastName='test',Company='test',Phone='1234567899');
        insert lead;
        Account acct2Link = new Account(name='Tyama');
        insert acct2Link;       
        Test.setFixedSearchResults(new Id[]{acct2Link.id});
        Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@acme.com',
            Company__c = 'Tyama',
            Lead__c = lead.id);
        insert request;  
        lead.Partner_Request__c = request.id;
        update lead;
        PartnerRegistrationLinkToAcctCtrlrExt extension = new PartnerRegistrationLinkToAcctCtrlrExt(
            new ApexPages.standardController(request));
        System.assertEquals(extension.getAccountSearchResultsCount(),0);
        System.assertEquals(extension.doPageLoad(),null);
        TestUtils.assertNoErrorMessagesExist();
        System.assertEquals(extension.getIsAccountSelected(),false);
        System.assertNotEquals(extension.getAccountSearchResults(),null);
        System.assertNotEquals(extension.getAccountSearchResultsCount(),0);
        System.assert(!extension.getAccountSearchResults().isEmpty());
        
        System.assertEquals(extension.doConfirmAccount(),null);
        TestUtils.assertNoErrorMessagesExist();
 
        ApexPages.currentPage().getParameters().put('accountId', '');
        System.assertEquals(extension.doSelectAccount(),null);
        ApexPages.currentPage().getParameters().put('accountId', '123');
        System.assertEquals(extension.doSelectAccount(),null);
        ApexPages.currentPage().getParameters().put('accountId', acct2Link.id);
        System.assertEquals(extension.doSelectAccount(),null);
        TestUtils.assertNoErrorMessagesExist();
        System.assertEquals(extension.getIsAccountSelected(),true);
        System.assertNotEquals(extension.selectedAccount,null);
        
        PageReference next = extension.doCancel();
        System.assertNotEquals(next,null);
        System.assertEquals(next.getUrl(),'/' + request.id);

        next = extension.doConfirmAccount();
        TestUtils.assertNoErrorMessagesExist();
        System.assertNotEquals(next,null);
        System.assertEquals(next.getUrl(),'/' + request.id);
        
    }
    
    
    private static testMethod void testSelectAccountAlreadyPartner() {
        Lead lead = new Lead(lastName='test',Company='test',phone='1234567891');
        insert lead;
        Account acct2Link = new Account(name='Tyama');
        insert acct2Link;  
        acct2Link.IsPartner = true;
        update acct2Link;     
        Test.setFixedSearchResults(new Id[]{acct2Link.id});
        Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@acme.com',
            Company__c = 'Tyama',
            Lead__c = lead.id);
        insert request;
        PartnerRegistrationLinkToAcctCtrlrExt extension = new PartnerRegistrationLinkToAcctCtrlrExt(
            new ApexPages.standardController(request));
        TestUtils.assertNoErrorMessagesExist();

        ApexPages.currentPage().getParameters().put('accountId', acct2Link.id);
        System.assertEquals(extension.doSelectAccount(),null);
        TestUtils.assertErrorMessagesExist();
    }
    
    
    
    private static testMethod void testNewCustomer() {
        RecordType recType=[SELECT Name,Id,SobjectType FROM RecordType WHERE Name ='New Customer' AND SobjectType='Partner_Request__c'];
        
        Account acct2Link = new Account(name='Tyama');
        insert acct2Link;
        
        Account partnerAccount=new Account();
        partnerAccount.name='PartnerAccount';
        partnerAccount.Account_Country_Code__c='AI';
        partnerAccount.Account_Country__c = 'ANGUILIA';              
        insert partnerAccount;
        partnerAccount.IsPartner = true;
        partnerAccount.RecordTypeId = System.Label.RecType_Partner_Account;                
        update partnerAccount;
        
        //Creating end customer
        End_Customer__c endCustomer=new End_Customer__c();                   
        endCustomer.Account_Department__c='xxx';
        endCustomer.Account_Industry__c='Biotechnology';             
        endCustomer.Mailing_city__c='ff';
        endCustomer.Mailing_country__c='dasssa';
        endCustomer.Mailing_State__c='sdawwqwq';
        endCustomer.Mailing_street__c='ddsdqwewdc';
        endCustomer.Partner_Account__c=partnerAccount.id;
        endCustomer.Segment__c='Education';
        endCustomer.Status__c='Active';
        endCustomer.Tax_Id__c='aaaaa';
        endCustomer.Total_of_End_User_Employees__c='100 - 199';           
        endCustomer.Zip_Code__c='333333';
        endCustomer.Name='Company';           
        insert endCustomer;
        
        End_Customer_Contact__c endCstmrCntct=new End_Customer_Contact__c();
        endCstmrCntct.Name='test';
        endCstmrCntct.Email__c='testemail@Company31.com';
        endCstmrCntct.End_Customer__c=endCustomer.Id;
        endCstmrCntct.Fax__c='222';
        endCstmrCntct.Last_Name__c='tester';
        endCstmrCntct.Mobile__c='333';
        endCstmrCntct.Phone__c='4444';
        endCstmrCntct.Status__c='Active';
        endCstmrCntct.Title__c='xsad';        
        insert endCstmrCntct;
            
        Test.setFixedSearchResults(new Id[]{acct2Link.id});
        
        Partner_Request__c request = new Partner_Request__c(
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Email__c = 'john.doe@acme.com',
            Company__c = 'Tyama',
            recordtypeId=recType.Id,
            end_customer__c=endCustomer.Id,
            Account__c=partnerAccount.id
            );
        insert request;
        
        
            
        //Partner_Request__c request=[select id,end_customer__c,First_Name__c,Last_Name__c,Email__c,Company__c,recordtypeId from Partner_Request__c where end_customer__c=:endCustomer.Id];
         
         
         PartnerRegistrationLinkToAcctCtrlrExt extension = new PartnerRegistrationLinkToAcctCtrlrExt(
            new ApexPages.standardController(request));
                  
        //TestUtils.assertNoErrorMessagesExist();
        PageReference pageRef3 = Page.PartnerRegistrationLinkToAcct;
        Test.setCurrentPage(pageRef3);
        ApexPages.currentPage().getParameters().put('accountId2', acct2Link.id);
        extension.getConfirmEUAcc();
        extension.getConfirmAccount();
        System.assertEquals(extension.doSelectAccount(),null);
        Pagereference pageRef=new Pagereference('/' + request.id);
        
        //System.debug('###Actual extension.doConfirmEndUserAccount()'+extension.doConfirmEndUserAccount());
        //System.debug('###Expected pageRef'+pageRef);
        //extension.setsearchString('Tyama');
        extension.doSearch();
        Pagereference result = extension.doConfirmEndUserAccount();
        System.debug('### result : ' + result);
        System.debug('### request: ' + request);
        //System.assertNotEquals(result,null);

        End_Customer__c endCstmr=[select id,EU_Affinity_ID__c , End_User_Account__c from End_Customer__c where id=:endCustomer.Id]; 
        System.debug('### Partner Acc : ' + partnerAccount.Id);
        System.debug('### Acc : ' + acct2Link.Id);
        System.debug('### Partner Acc Account_ID__c  : ' + partnerAccount.Account_ID__c );
        System.debug('### end cust EU_Affinity_ID__c   : ' + endCstmr.EU_Affinity_ID__c );
        System.debug('### reg end user: ' + request .End_Customer__c);
        
        End_Customer__c endCstmr2=[select id,EU_Affinity_ID__c , End_User_Account__c from End_Customer__c where id=:request .End_Customer__c]; 
        System.debug('### reg end user2 End_User_Account__c : ' + endCstmr2.End_User_Account__c);
        System.assertEquals(endCstmr.End_User_Account__c,endCstmr2.End_User_Account__c);
        
        //TestUtils.assertErrorMessagesExist();
    }
}
/* 
REVISION HISTORY
================
Version     Author      Date            Release#    CR#              Description
-------     ------      ----            --------    ---             -----------   
N/A         N/A         N/A             N/A         N/A             N/A
2.0         Venkat      10-Oct-2018     FY19-0102   16670           Added testMethod to cover ExistingDealRegistrationCls
3.0         Emily       08-Jan-2019     FY20-0202   16970           Comment primary_owner__c
*/
@isTest
private class OSCafterinsertTest
{   
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
    
    public static testmethod void testOSC_Sales()
    {
        Id accRTId= IdLookupUtils.getRecordTypeId('End-User Account','Account',true);
        Account accountObj;
        accountObj = new Account(name='Test', RecordtypeId = accRTId, Account_ID__c = '9876543');
        
        TriggerExecutionController.setSkipAllTriggers(true); 
        insert accountObj;
        TriggerExecutionController.setSkipAllTriggers(false); 
        
        User usr;
        Profile p = [SELECT id from Profile where name LIKE '%GBL EMEA Sales Mgr%' limit 1 ];
        usr = new User(
            Username='testsSale@dll.com',
            Alias = 'test1', 
            Email='testS3445@dell.com', 
            FirstName='John', 
            LastName='Doe', 
            ProfileId = p.Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='SUser1', 
            isActive = TRUE
        );
        
        TriggerExecutionController.setSkipAllTriggers(true); 
        insert usr; 
        TriggerExecutionController.setSkipAllTriggers(false); 
        
        //Id oppRTId= IdLookupUtils.getRecordTypeId('Standard opportunity','opportunity',true);
        
        Customer_Number__c CustNum;
        CustNum = New Customer_Number__c (Name = '1111',BU_ID__c ='1111',Customer_Number_BU_Integ__c='11111111');
        insert CustNum;
        Opportunity o = new Opportunity();
        //o.RecordtypeId = oppRTId;
        o.name = 'TestOpp';
        o.AccountId = accountObj.Id;
        o.Type = 'Design';
        o.Domain__c = 'Networking';
        o.Solution_Type__c = 'Campus';
        o.Solution_Name__c = 'Wireless Switches';
        //o.CurrencyIsoCode = 'USD - U.S Dollar';
        o.StageName = 'Plan - 1%';
        o.CloseDate = System.today();
        o.Deal_Type__c = 'Greenfield';
        o.Deal_Registration_Status__c = 'New';
        o.Deal_Expiration_Date__c = System.today() + 10; 
        o.Opportunity_Customer_Number__c = CustNum.id;
        o.Deal_Expiration_Date__c = null;
        o.Deal_Registration_Status__c = 'Approved';        
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setskipOpportunityLineItemTriggers(true);                
        insert o;        
        
        OpportunityTeamMember opt = new OpportunityTeamMember();
        opt.userid = usr.id;
        opt.OpportunityId = o.id;
        insert opt;
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setskipOpportunityLineItemTriggers(false);
        
        list<string> solutionList = new list<string>();
        Solution__c solObj = new Solution__c();
        solObj.Opportunity__c = o.id;
        solObj.OSC_Regional_ID__c = '773456638.5';
        insert solObj;
        solutionList.add(solObj.OSC_Regional_ID__c);
        
        System.runas(usr){
            System.debug('@@USer: '+usr);
            ApexPages.StandardController sc = new ApexPages.StandardController(solObj);
            SolutionRefreshCtrlExtn srce = new SolutionRefreshCtrlExtn(sc);
            srce.id = '123545';
            srce.status = 'abcd';
            srce.description = 'xyz';
            srce.type = 'wxy';
            srce.messages = 'fgh';
            srce.displaysuccessmsg = true;
            SolutionRefreshCtrlExtn.RefreshResponse Refres = new  SolutionRefreshCtrlExtn.RefreshResponse('abc','xyz');
            
            
            Pagereference pr = new Pagereference('/apex/existingdealregistration');
            Test.setcurrentpagereference(pr);
            Apexpages.currentpage().getparameters().put('oscid','EU:675645342312.1');
            ExistingDealRegistrationCls edr = new ExistingDealRegistrationCls();         
            string s = new ExistingDealRegistrationCls.AdminController().getUser();
            ExistingDealRegistrationCls.UserController uc = new ExistingDealRegistrationCls.UserController();
            //edr.AdminController();
            edr.getTagged();
            edr.searchTagged = 'Owned';
            edr.oppid = o.id;
            edr.DealId = '999999';
            
            edr.showHideErr = True;
            edr.err = 'No matching records found. Please ensure that the Deal ID is valid';
            //3.0 edr.searchOpp.Primary_Owner__c = usr.id;
            edr.getLstOpp();
            edr.searchTagged = 'Owned';
            edr.searchOpp = o;
            edr.getLstOpp();
            edr.searchTagged = 'Tagged';
            edr.searchOpp = o;
            
            edr.getLstOpp();
            edr.total_size = 100;
            edr.getStages();
            edr.getDealRegStatuses();        
            edr.associate();    
            edr.beginning();
            edr.previous();
            edr.next();
            edr.getdisableprevious();
            edr.getdisablenext();
            edr.getTotal_size();
            edr.getpagenumber();
            edr.getTotalpages();
            edr.end();
            edr.SearchAction();
            edr.ResetAction();
            edr.IsProfile = true;
        }
        
    }
    
    public static testmethod void testOSC_Sales7()
    {
        Id accRTId= IdLookupUtils.getRecordTypeId('End-User Account','Account',true);
        Account accountObj;
        accountObj = new Account(name='Test', RecordtypeId = accRTId, Account_ID__c = '9876543');
        insert accountObj;
        
        User usr;
        Profile p = [SELECT id from Profile where name LIKE '%GBL EMEA Sales Mgr%' limit 1 ];
        usr = new User(
            Username='testsSale@dll.com',
            Alias = 'test1', 
            Email='testS3445@dell.com', 
            FirstName='John', 
            LastName='Doe', 
            ProfileId = p.Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='SUser1', 
            isActive = TRUE
        );
        insert usr; 
        
        //Id oppRTId= IdLookupUtils.getRecordTypeId('Standard opportunity','opportunity',true);
        
        Customer_Number__c CustNum;
        CustNum = New Customer_Number__c (Name = '1111',BU_ID__c ='1111',Customer_Number_BU_Integ__c='11111111');
        insert CustNum;
        Opportunity o = new Opportunity();
        //o.RecordtypeId = oppRTId;
        o.name = 'TestOpp';
        o.AccountId = accountObj.Id;
        o.Type = 'Design';
        o.Domain__c = 'Networking';
        o.Solution_Type__c = 'Campus';
        o.Solution_Name__c = 'Wireless Switches';
        //o.CurrencyIsoCode = 'USD - U.S Dollar';
        o.StageName = 'Plan - 1%';
        o.CloseDate = System.today();
        o.Deal_Type__c = 'Greenfield';
        o.Deal_Registration_Status__c = 'New';
        o.Deal_Expiration_Date__c = System.today() + 10; 
        o.Opportunity_Customer_Number__c = CustNum.id;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setskipOpportunityLineItemTriggers(true);        
        insert o;
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setskipOpportunityLineItemTriggers(false);
        
        list<string> solutionList = new list<string>();
        Solution__c solObj = new Solution__c();
        solObj.Opportunity__c = o.id;
        solObj.OSC_Regional_ID__c = 'AMER:773456638.5';
        insert solObj;
        solutionList.add(solObj.OSC_Regional_ID__c);
        
        System.runas(usr){
            System.debug('@@USer: '+usr);
            ApexPages.StandardController sc = new ApexPages.StandardController(solObj);
            SolutionRefreshCtrlExtn srce = new SolutionRefreshCtrlExtn(sc);
            
            Pagereference pr = new Pagereference('/apex/SolutionRefresh');
            Test.setcurrentpagereference(pr);
            Apexpages.currentpage().getparameters().put('id',solObj.OSC_Regional_ID__c);
        }
        
    }
    
    public static testmethod void testOSC_Sales1()
    {
        // TriggerExecutionController.setSkipAccountTriggers(true);
        TriggerExecutionController.setSkipAllTriggers(true);
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account accountObj;
        accountObj = new Account(name='Test', RecordtypeId = accRTId);
        insert accountObj;
        
        Contact c;
        c = new Contact(AccountId = accountObj.id, lastname = 'lastname', Phone = '1234');
        Database.insert(c);
        
        
        //subbu changes 
        final List<Profile> partnerProfiles = 
            [select id,name from Profile where UserType = 'PowerPartner' and name like '%LA PRM%' limit 1];
        User usr= new User(
            Username='test' + System.currentTimeMillis() + '@test.com',
            Alias = 'test1', 
            Email='test@test.com', 
            FirstName='John', 
            LastName='Doe', 
            ProfileId = partnerProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c=null, 
            ContactId = c.id,
            isActive = TRUE
        );
        insert usr;
        
        System.runas(usr){
            Account acc = new Account(Name='testAccount'); 
            insert acc;
            Contact testCont = new Contact();
            testCont.FirstName='test EU contact ';
            testCont.LastName='Test2';
            testCont.Email='testEUContact@dell.com';
            testCont.MailingStreet='test Street';
            testCont.Status__c='Prospect';
            testCont.MailingCity='test City';
            testCont.MailingState='test State';
            testCont.MailingCountry='test Country';
            testCont.AccountId=acc.Id;
            insert testCont;
            
            //Id oppRTId= IdLookupUtils.getRecordTypeId('Standard opportunity','opportunity',true);
            Opportunity o = new Opportunity();
            //o.RecordtypeId = oppRTId;
            o.name = 'TestOppSales1';
            o.AccountId = accountObj.Id;
            o.End_User_Account_Name__c = 'tcvs';
            o.Type = '';
            o.Domain__c = 'Networking';
            o.Solution_Type__c = 'Campus';
            o.Solution_Name__c = 'Wireless Switches';
            //o.CurrencyIsoCode = 'USD - U.S Dollar';
            o.StageName = 'Plan - 1%';
            o.CloseDate = System.today()+1; 
            o.Quest_Software_Contact__c= testCont.id;
            o.Deal_Registration_Status__c = 'Approved';
            o.Deal_Expiration_Date__c = null;
            
            Test.startTest();
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            TriggerExecutionController.setskipOpportunityLineItemTriggers(true);
            insert o;
            TriggerExecutionController.setSkipOpportunityTriggers(false);
            TriggerExecutionController.setskipOpportunityLineItemTriggers(false);       
            
            //   Opportunity op = [select id,name from opportunity where id=:o.id limit 1];
            //   system.debug('----------RRRR'+op.id);
            
            
            
            System.debug('@@USer: '+usr);
            
            Pagereference pr = new Pagereference('/apex/existingdealregistration');
            Test.setcurrentpagereference(pr);
            Apexpages.currentpage().getparameters().put('oscid','EU:675645342312.1');
            ExistingDealRegistrationCls edr = new ExistingDealRegistrationCls();
            
            edr.DealId =o.id;
            edr.searchOppName = 'TestOppSales1';
            edr.searchStage = 'Plan - 1%';
            edr.searchDealRegStatus = 'New';
            edr.searchEndUserAccName = 'tcvs';
            edr.searchOpp.Decision_Date__c = System.today();
            edr.SearchAction();
            edr.getLstOpp();
            edr.total_size = 100;
            edr.getStages();
            edr.getDealRegStatuses();  
            edr.oppid = o.id;
            system.debug('^^^'+o.id);      
            edr.associate();    
            edr.beginning();
            edr.previous();
            edr.next();
            edr.getdisableprevious();
            edr.getdisablenext();
            edr.getTotal_size();
            edr.getpagenumber();
            edr.getTotalpages();
            edr.end();
            
            edr.ResetAction();
            edr.IsProfile = true;
        }
        Test.stopTest();
        //    TriggerExecutionController.setSkipAccountTriggers(false);
    } 
    
    public static testmethod void testOSC_Sales2()
    {
        /*//Test.startTest();
Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
Account accountObj;
accountObj = new Account(name='Test', RecordtypeId = accRTId);
insert accountObj;

//Id oppRTId= IdLookupUtils.getRecordTypeId('Standard opportunity','opportunity',true);

Profile p = [select id from profile
where usertype = :'PowerPartner'
limit 1]; 

Contact c;
c = new Contact(AccountId = accountObj.id, lastname = 'lastname', Phone = '1234');
Database.insert(c);

User usr;

usr = new User(
Username='testsSale@dll.com',
Alias = 'test1', 
Email='testS3445@dell.com', 
FirstName='John', 
LastName='Doe', 
ProfileId = p.Id,
contactId = c.id, 
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='SUser1',
isActive = TRUE
);
insert usr; 
*/ 
        
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        
        Account accountObj = new Account(name='Test', RecordtypeId = accRTId);
        insert accountObj;
        
        Contact c = new Contact(AccountId = accountObj.id, lastname = 'lastname', Phone = '1234');
        insert c;
        
        User user = new User();
        user.ProfileID = [Select Id From Profile Where UserType = 'PowerPartner' and name like '%LA PRM%' limit 1].id;
        user.EmailEncodingKey = 'UTF-8';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = 'test'+System.currentTimeMillis()+'@appirio.com';   
        user.CommunityNickname = 'testUser123';
        user.Alias = 't1';
        user.Email = 'no@email.com';
        user.IsActive = true;
        user.ContactId = c.Id;
        user.Badge_Number__c = '2e4m5j5';
        user.isActive = TRUE;
        insert user;
        System.runas(user){    
            
            Opportunity o = new Opportunity();
            //o.RecordtypeId = oppRTId;
            o.name = 'TestOpp';
            o.AccountId = accountObj.Id;
            o.End_User_Account_Name__c = 'tcvs';
            o.Type = 'Design';
            o.Domain__c = 'Networking';
            o.Solution_Type__c = 'Campus';
            o.Solution_Name__c = 'Wireless Switches';
            //o.CurrencyIsoCode = 'USD - U.S Dollar';
            o.StageName = 'Plan - 1%';
            o.CloseDate = System.today()+1;
            o.Deal_Type__c = 'Greenfield';
            o.Deal_Registration_Status__c = 'New';
            o.Deal_Expiration_Date__c = System.today() + 10;
            o.Opportunity_Customer_Number__c = CustNum.id;
            o.OSC_Solution_ID__c = 'EURO:123.3';     
            
            
            Test.startTest();
            TriggerExecutionController.setSkipOpportunityTriggers(true);
            TriggerExecutionController.setskipOpportunityLineItemTriggers(true);
            insert o;
            TriggerExecutionController.setSkipOpportunityTriggers(false);
            //  TriggerExecutionController.setskipOpportunityLineItemTriggers(false);
            
            List<Solution__c> solutionList = [SELECT id,OSC_Solution_ID__c from Solution__C WHERE  OSC_Regional_ID__c =: o.OSC_Solution_ID__c];
            System.debug('____________________________________________________'+solutionList.size());
            
            
            System.debug('@@USer: '+user);
            
            Pagereference pr = new Pagereference('/apex/existingdealregistration');
            Test.setcurrentpagereference(pr);
            Apexpages.currentpage().getparameters().put('oscid','EU:675645342312.1');
            ExistingDealRegistrationCls edr = new ExistingDealRegistrationCls();
            edr.oppid = o.id;
            //edr.DealId = '235';
            edr.showHideErr = True;
            edr.err = 'No matching records found. Please ensure that the Deal ID is valid';
            edr.getLstOpp();
            edr.total_size = 100;
            edr.getStages();
            edr.getDealRegStatuses();        
            edr.associate();    
            edr.beginning();
            edr.previous();
            edr.next();
            edr.getdisableprevious();
            edr.getdisablenext();
            edr.getTotal_size();
            edr.getpagenumber();
            edr.getTotalpages();
            edr.end();
            edr.SearchAction();
            edr.ResetAction();
            edr.IsProfile = true;
        }
        Test.stopTest();
    }
    
    public static testmethod void testOSC_Sales3()
    {
        try{
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        system.debug('accRTId' + accRTId);
        Account accountObj;
        accountObj = new Account(name='Test', RecordtypeId = accRTId, Account_ID__c = '9876543');
        insert accountObj;
        system.debug('accountObj' + accountObj);
        
        Contact c;
        c = new Contact(AccountId = accountObj.id, lastname = 'lastname', Phone = '1234');
        Database.insert(c);
        system.debug('c' + c);
        
        User usr;
        Profile p = [select id from profile
                     where usertype = :'PowerPartner'
                     limit 1]; 
        system.debug('p' + p);
        usr = new User(
            Username='testsSale@dll.com',
            Alias = 'test1', 
            Email='testS3445@dell.com', 
            FirstName='John', 
            LastName='Doe', 
            ProfileId = p.Id,
            contactId = c.id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='SUser1',
            isActive = TRUE
        );
        insert usr; 
        system.debug('usr' + usr);
        string oscid;
        
        //Id oppRTId= IdLookupUtils.getRecordTypeId('Standard opportunity','opportunity',true);
        Customer_Number__c CustNum;
        CustNum = New Customer_Number__c (Name = '1111',BU_ID__c ='1111',Customer_Number_BU_Integ__c='11111111');
        insert CustNum;
        Opportunity o = new Opportunity();
        //o.RecordtypeId = oppRTId;
        o.name = 'TestOpp';
        o.AccountId = accountObj.Id;
        //o.End_User_Account_Name__c = 'tcvs';
        o.Type = 'Design';
        o.Domain__c = 'Networking';
        o.Solution_Type__c = 'Campus';
        o.Solution_Name__c = 'Wireless Switches';
        //o.CurrencyIsoCode = 'USD - U.S Dollar';
        o.StageName = 'Plan - 1%';
        o.CloseDate = System.today();  
        o.osc_solution_id__c = 'AMER:17031990.1';
        o.Deal_Type__c = '';
        o.Deal_Registration_Status__c = '';
        o.Deal_Expiration_Date__c = System.today() + 10; 
        o.Opportunity_Customer_Number__c = CustNum.id;
        
        system.Test.startTest();
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setskipOpportunityLineItemTriggers(true);
        insert o;
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setskipOpportunityLineItemTriggers(false);
        
        Solution__c s= new Solution__c ();
        s.Opportunity__c = o.id;
        s.OSC_Regional_ID__c = o.osc_solution_id__c;
        insert s;
        system.debug('oppty' + o);
        List<Solution__c> solRecords = [select OSC_Regional_ID__c from Solution__c where OSC_Regional_ID__c =: o.OSC_Solution_Id__c];
        system.debug('$$$$$$$$$$$$$$ solRecords' + solRecords );
        list<string> oscidlist = new list<string>();
        map<id,opportunity> oppmap = new map<id,opportunity>();
        map<id,list<string>> opidlist = new map<id,list<string>>();
        list<id> oppid = new list<id>();
        oppid.add(o.id);
        
        if(solRecords.size() > 0){
            delete solRecords;
        }
        
        system.debug('%%%%%%%%%%%%%');
        oscidlist.add(o.osc_solution_id__c);
        system.debug('oscidlist' + oscidlist);
        oppmap.put(o.id,o);
        system.debug('oppmap' + oppmap);
        opidlist.put(o.id,oscidlist);
        system.debug('opidlist' + opidlist);
        
        System.runas(usr){
            
            OSCWebServiceCallout.isRefreshBtnClicked = false;
            OSCWebserviceCallout.sendNotification(oppid,'Association');
            system.Test.stopTest();
            
            
            
        }
    }catch(exception e){}
        
    }
    
    public static testmethod void testOSC_Sales4()
    {   
        TriggerExecutionController.setSkipAllTriggers(true);
        //if(GlobalVariables.SKIP_OPP_LINEITEM_TRIGGERS){
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        system.debug('accRTId' + accRTId);
        Account accountObj;
        accountObj = new Account(name='Test', RecordtypeId = accRTId, Account_ID__c = '9876543');
        insert accountObj;
        system.debug('accountObj' + accountObj);
        
        Profile p = [select id from profile
                     where usertype = :'PowerPartner'
                     limit 1]; 
        system.debug('p' + p);
        
        Contact c;
        c = new Contact(AccountId = accountObj.id, lastname = 'lastname', Phone = '1234');
        Database.insert(c);
        system.debug('c' + c);
        
        User usr;
        
        usr = new User(
            Username='testsSale@dll.com',
            Alias = 'test1', 
            Email='testS3445@dell.com', 
            FirstName='John', 
            LastName='Doe', 
            ProfileId = p.Id,
            contactId = c.id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='SUser1',
            isActive = TRUE
        );
        insert usr; 
        system.debug('usr' + usr);
        string oscid;
        
        
        
        
        //Id oppRTId= IdLookupUtils.getRecordTypeId('Standard opportunity','opportunity',true);
        Customer_Number__c CustNum;
        CustNum = New Customer_Number__c (Name = '1111',BU_ID__c ='1111',Customer_Number_BU_Integ__c='11111111');
        insert CustNum;
        
        Opportunity o = new Opportunity();
        //o.RecordtypeId = oppRTId;
        o.name = 'TestOpp';
        o.AccountId = accountObj.Id;
        //o.End_User_Account_Name__c = 'tcvs';
        o.Type = 'Design';
        o.Domain__c = 'Networking';
        o.Solution_Type__c = 'Campus';
        o.Solution_Name__c = 'Wireless Switches';
        //o.CurrencyIsoCode = 'USD - U.S Dollar';
        o.StageName = 'Plan - 1%';
        o.CloseDate = System.today();  
        o.osc_solution_id__c = 'EMEA:17981990.1';
        o.Deal_Type__c = '';
        o.Deal_Registration_Status__c = '';
        o.Deal_Expiration_Date__c = System.today() + 10; 
        o.Opportunity_Customer_Number__c = CustNum.id;
        
        //////TriggerExecutionController.setSkipOpportunityTriggers(true);
        //////TriggerExecutionController.setskipOpportunityLineItemTriggers(true);
        insert o;
        
        
        /*Solution__c solObj = new Solution__c();
solObj.Opportunity__c = o.id;
solObj.OSC_Regional_ID__c = 'AMER:2754716.1';
insert solObj;*/
        
        system.debug('oppty' + o);
        List<Solution__c> solutionList = [SELECT id,OSC_Solution_ID__c from Solution__C WHERE  OSC_Regional_ID__c =: o.OSC_Solution_ID__c];
        System.debug('____________________________________________________'+solutionList.size());
        
        //system.debug('---------------solution obj' + solObj);
        
        //Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
        Id pricebookId = Test.getStandardPricebookId();
        list<opportunitylineitem> olilist = new list<opportunitylineitem>();
        
        Product2 prod = new Product2(
            Name = 'Absolute Software',
            Product_ID__c = '8966',
            ProductCode = 'AS -1',
            isActive = true
        );
        insert prod;
        system.debug('---------------------- prod ' + prod);
        
        /*Product2 prod2 = new Product2(
Name = '3M',
ProductCode = '3M -1',
isActive = true
);
insert prod2;
system.debug('----------------------- prod2' + prod2);*/
        
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            useStandardPrice=false,
            IsActive = true
        );
        insert pbEntry;
        
        /*PricebookEntry pbEntry2 = new PricebookEntry(
Pricebook2Id = pricebookId,
Product2Id = prod2.Id,
UnitPrice = 50.00,
IsActive = true
);
insert pbEntry2;*/
        
        Enable_Codes_Settings__c emcObj = new Enable_Codes_Settings__c();
        emcObj.Name = 'EMC Codes';
        emcObj.Enable__c = false;
        insert emcObj;
        
        Opportunitylineitem oli = new opportunitylineitem();
        oli.Mrgn__c = 2;
        oli.Discount_off__c = 7;
        oli.UnitPrice = 100;
        oli.Quantity = 5;
        oli.Product_Type__c = 'TestType';
        oli.Opportunityid = o.id;
        oli.Description = 'Line Description';
        oli.PricebookEntryId = pbEntry.Id;
        oli.Service_Support_US__c = 'ProSupport IT - Mission Critical';
        //oli.PricebookEntry.Product2.name = prod.id;
        
        Test.startTest();
        insert oli;
        //////TriggerExecutionController.setSkipOpportunityTriggers(false);
        //////TriggerExecutionController.setskipOpportunityLineItemTriggers(false);
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        
        /*Opportunitylineitem oli2 = new opportunitylineitem();
oli2.Mrgn__c = 2;
oli2.UnitPrice = 100;
oli2.Quantity = 5;
oli2.Opportunityid = o.id;
oli2.PricebookEntryId = pbEntry2.Id;
//oli.PricebookEntry.Product2.name = prod2.id;
insert oli2;*/
        
        system.debug('------------------------oli ' + oli);
        //system.debug('------------------------oli 2' + oli2);
        
        olilist.add(oli);
        //olilist.add(oli2);
        
        system.debug('------------------------- olilist' + olilist);
        system.runas(usr){
            //List<Solution__c> solRecords = [select OSC_Regional_ID__c from Solution__c where OSC_Regional_ID__c =: o.OSC_Solution_Id__c];
            //system.debug('$$$$$$$$$$$$$$ solRecords' + solRecords );
            list<string> oscidlist = new list<string>();
            map<id,opportunity> oppmap = new map<id,opportunity>();
            map<id,list<string>> opidlist = new map<id,list<string>>();
            map<id,list<opportunitylineitem>> olimap = new map<id,list<opportunitylineitem>>();
            
            if(solutionList.size() > 0){
                system.debug('%%%%%%%%%%%%%');
                oscidlist.add(o.osc_solution_id__c);
                system.debug('oscidlist' + oscidlist);
                oppmap.put(o.id,o);
                system.debug('oppmap' + oppmap);
                opidlist.put(o.id,oscidlist);
                system.debug('opidlist' + opidlist);
                olimap.put(oli.opportunity.id,olilist);
                system.debug('----------------- olimap ' + olimap);
                
            }
            String OSCActionIdentifier = 'Association';
            Test.stopTest();
            OSCWebServiceCallout.isRefreshBtnClicked = false;
            system.debug('----------------- opidlist : opidlist : ' + opidlist);
            try{
                OSCWebserviceCallout.processRequest(oppmap,opidlist,OSCActionIdentifier,olimap,false);
            }catch(Exception e){}        
            
            
        }
        TriggerExecutionController.setSkipAccountTriggers(false);
    }
    
    public static testmethod void testOSC_Sales5()
    {
        try{
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        system.debug('accRTId' + accRTId);
        Account accountObj;
        accountObj = new Account(name='Test', RecordtypeId = accRTId, Account_ID__c = '9876543');
        insert accountObj;
        system.debug('accountObj' + accountObj);
        
        Contact c;
        c = new Contact(AccountId = accountObj.id, lastname = 'lastname', Phone = '1234');
        Database.insert(c);
        system.debug('c' + c);
        
        final List<Profile> partnerProfiles = 
            [select id,name from Profile where UserType = 'PowerPartner' and name like '%LA PRM%' limit 1];
        User usr= new User(
            Username='test' + System.currentTimeMillis() + '@test.com',
            Alias = 'test1', 
            Email='test@test.com', 
            FirstName='John', 
            LastName='Doe', 
            ProfileId = partnerProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c=null, 
            ContactId = c.id,
            isActive = TRUE
        );
        insert usr;
        system.debug('usr' + usr);
        string oscid;
        
        //Id oppRTId= IdLookupUtils.getRecordTypeId('Standard opportunity','opportunity',true);
        Customer_Number__c CustNum;
        CustNum = New Customer_Number__c (Name = '1111',BU_ID__c ='1111',Customer_Number_BU_Integ__c='11111111');
        insert CustNum;
        Opportunity opp = new Opportunity();
        //o.RecordtypeId = oppRTId;
        opp.name = 'TestOpp';
        opp.AccountId = accountObj.Id;
        //o.End_User_Account_Name__c = 'tcvs';
        opp.Type = 'Design';
        opp.Domain__c = 'Networking';
        opp.Solution_Type__c = 'Campus';
        opp.Solution_Name__c = 'Wireless Switches';
        //o.CurrencyIsoCode = 'USD - U.S Dollar';
        opp.StageName = 'Plan - 1%';
        opp.CloseDate = System.today()+1;  
        opp.Deal_Type__c = '';
        opp.Deal_Registration_Status__c = '';
        opp.Deal_Expiration_Date__c = System.today() + 10; 
        opp.Opportunity_Customer_Number__c = CustNum.id;
        Test.startTest();
       // try{
            insert opp;
       
       // catch(Exception e){}
        Solution__c solObj = new Solution__c();
        solObj.Opportunity__c = opp.id;
        solObj.OSC_Regional_ID__c = 'AMER:2454716.1';
        insert solObj;
        
        list<id> oppid = new list<id>();
        oppid.add(opp.id);
        
        
        System.runas(usr){
            
            
            OSCWebserviceCallout.Messages_Z oc = new OSCWebserviceCallout.Messages_Z();
            oc.source = 'a';
            oc.applicationsource = 'b';
            OSCWebserviceCallout.Error ose = new OSCWebserviceCallout.Error();
            ose.Region = 'd';
            ose.DealId = '123';
            ose.issuccess = 'f';  
            OSCWebServiceCallout.isRefreshBtnClicked = false;
            OSCWebserviceCallout.sendNotification(oppid,'Association');
            Test.stopTest();
        }
        }catch(Exception e){}
    }
    public static testmethod void testOSC_Sales6()
    {
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        system.debug('accRTId' + accRTId);
        TriggerExecutionController.setSkipAccountTriggers(true);
        Account accountObj;
        
        accountObj = new Account(name='Test', RecordtypeId = accRTId, Account_ID__c = '9876543');
        insert accountObj;
        TriggerExecutionController.setSkipAccountTriggers(false);
        system.debug('accountObj' + accountObj);
        
        Contact c;
        c = new Contact(AccountId = accountObj.id, lastname = 'lastname', Phone = '1234');
        Database.insert(c);
        system.debug('c' + c);
        
        final List<Profile> partnerProfiles = 
            [select id,name from Profile where UserType = 'PowerPartner' and name like '%LA PRM%' limit 1];
        User usr= new User(
            Username='test' + System.currentTimeMillis() + '@test.com',
            Alias = 'test1', 
            Email='test@test.com', 
            FirstName='John', 
            LastName='Doe', 
            ProfileId = partnerProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c=null, 
            ContactId = c.id,
            isActive = TRUE
        );
        insert usr;
        
        
        //Id oppRTId= IdLookupUtils.getRecordTypeId('Standard opportunity','opportunity',true);
        Customer_Number__c CustNum;
        CustNum = New Customer_Number__c (Name = '1111',BU_ID__c ='1111',Customer_Number_BU_Integ__c='11111111');
        insert CustNum;
        Opportunity o = new Opportunity();
        //o.RecordtypeId = oppRTId;
        o.name = 'TestOpp';
        o.AccountId = accountObj.Id;
        //o.End_User_Account_Name__c = 'tcvs';
        o.Type = 'Design';
        o.Domain__c = 'Networking';
        o.Solution_Type__c = 'Campus';
        o.Solution_Name__c = 'Wireless Switches';
        //o.CurrencyIsoCode = 'USD - U.S Dollar';
        o.StageName = 'Plan - 1%';
        o.CloseDate = System.today();  
        o.Deal_Type__c = '';
        o.Deal_Registration_Status__c = '';
        o.Deal_Expiration_Date__c = System.today() + 10; 
        o.Opportunity_Customer_Number__c = CustNum.id;
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setskipOpportunityLineItemTriggers(true);
        insert o;
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setskipOpportunityLineItemTriggers(false);
        
        Solution__c solObj = new Solution__c();
        solObj.Opportunity__c = o.id;
        solObj.OSC_Regional_ID__c = 'AMER:2454716.1';
        insert solObj;
        
        system.Test.startTest();
        o.Deal_Expiration_Date__c = System.today() + 20;
        try{
            update o;
        }
        catch(Exception e){}
        //  OpportunityUtilities.RealtimeSolutionsupdate(lop,oldMap);
        system.Test.stopTest();
    }
    
    public static Account acc= new Account();
    public static Opportunity opp= new Opportunity();
    //public static User internalUser= new User();
    //public static User partnerUser= new User();
    public static Customer_Number__c CustNum= new Customer_Number__c();
    
    public static void createData(){
        Id accRTId= IdLookupUtils.getRecordTypeId('End-User Account','Account',true);
        acc= new Account(name='Test', RecordtypeId = accRTId, Account_ID__c = '9876543');
        insert acc;
        
        
        CustNum = New Customer_Number__c (Name = '1111',BU_ID__c ='1111',Customer_Number_BU_Integ__c='11111111');
        insert CustNum;
        
        Opportunity o = new Opportunity(
            name = 'TestOpp',
            AccountId = acc.id,
            Type = 'Design',
            Domain__c = 'Networking',
            Solution_Type__c = 'Campus',
            Solution_Name__c = 'Wireless Switches',
            StageName = 'Plan - 1%',
            CloseDate = System.today(),
            Deal_Type__c = 'Greenfield',
            Deal_Registration_Status__c = 'New',
            Deal_Expiration_Date__c = System.today() + 10,
            Opportunity_Customer_Number__c = CustNum.id
        );
    }
    
    public static testMethod void internalAssociation(){
        TriggerExecutionController.setSkipAllTriggers(true);
        createData();
        Profile p = [SELECT id from Profile where name LIKE '%GBL EMEA Sales Mgr%' limit 1 ];
        
        User internalUser = new User(
            Username='testsSale@dll.com',
            Alias = 'test1', 
            Email='testS3445@dell.com', 
            FirstName='John', 
            LastName='Doe', 
            ProfileId = p.Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='intUser', 
            isActive = TRUE
        );
        insert internalUser; 
        
        Opportunity intOpp = new Opportunity(
            name = 'TestOpp',
            AccountId = acc.id,
            Type = 'Design',
            Domain__c = 'Networking',
            Solution_Type__c = 'Campus',
            Solution_Name__c = 'Wireless Switches',
            StageName = 'Plan - 1%',
            CloseDate = System.today(),
            Deal_Type__c = 'Greenfield',
            Deal_Registration_Status__c = 'New',
            Deal_Expiration_Date__c = System.today() + 10,
            Opportunity_Customer_Number__c = CustNum.id,
            OSC_Solution_ID__c = 'EURO:123.3'
        );
        
        
        //////TriggerExecutionController.setSkipOpportunityTriggers(true);
        //////TriggerExecutionController.setskipOpportunityLineItemTriggers(true);
        Database.insert(intOpp);// when insering opp, the details should be passed to OSC
        
        system.debug('---------------------- intOpp' + intOpp);
        
        List<Solution__c> solutionList = [SELECT id,OSC_Solution_ID__c from Solution__C WHERE  OSC_Regional_ID__c =: intOpp.OSC_Solution_ID__c];
        System.debug('____________________________________________________'+solutionList.size());
        //addind products to opp
        //Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
        Product2 newPrdct = new Product2(Name = 'Test Product',Product_ID__c = '8976',Product_Line_Desc__c = 'test Product',IsActive = TRUE); 
        insert newPrdct;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe= new PricebookEntry (Product2ID=newPrdct.id,
                                                Pricebook2ID=pricebookId,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        insert pbe; 
        Enable_Codes_Settings__c emcObj = new Enable_Codes_Settings__c();
        emcObj.Name = 'EMC Codes';
        emcObj.Enable__c = false;
        insert emcObj;
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =intOpp.Id,
                                                                    pricebookEntryId=pbe.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Product_Type__c = 'TestType',
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                   ); 
        Test.startTest();
        insert testLineItem; //this will send the product details to OSC
        system.debug('----------------- testLineItem' + testLineItem);
        //////TriggerExecutionController.setSkipOpportunityTriggers(false);
        //////TriggerExecutionController.setskipOpportunityLineItemTriggers(false);
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        
        //associating another solution to this opp
        System.runas(internalUser){
            
            Pagereference pr = new Pagereference('/apex/InternalSalesExistingdealregistration');
            Test.setcurrentpagereference(pr);
            Apexpages.currentpage().getparameters().put('oscid','EU:675645342312.1');
            InternalSalesExistingDealRegistrationCls edr = new InternalSalesExistingDealRegistrationCls(); 
            List<Opportunity> ls = new List<Opportunity>();
            List<List<opportunity>> lst = new List<List<opportunity>>();
            ls.add(intOpp);
            lst.add(ls);
            edr.pgIndex = 0;
            edr.pageNumber= 2;
            edr.pageSize = 5;
            edr.oppid = ls[0].id;  
            system.debug('------------------ checking for oppty');     
            edr.lstOppMainList = lst;
            edr.lstopp = ls;
            edr.searchOppName = 'TestOpp';
            edr.searchStage = 'Plan - 1%';
            //edr.searchDealRegStatus = 'New';
            edr.searchEndUserAccName = acc.name;
            edr.searchOpp.Decision_Date__c = System.today();
            
            edr.associate();
        }
        Test.stopTest();
        TriggerExecutionController.setSkipAccountTriggers(false);
    }
    
    public static testMethod void partnerAssociation(){
        TriggerExecutionController.setSkipAllTriggers(true);
        createData();
        
        /*Contact cont = new Contact(AccountId = acc.id, lastname = 'lastname', Phone = '1234');
insert cont;
// UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
// Profile p = [SELECT Id FROM Profile WHERE Name LIKE '%Partner Community User Custom%' AND usertype = :'PowerPartner'Limit 1];
Profile p = [SELECT id from Profile where name LIKE '%PRM Portal%' AND usertype = :'PowerPartner'limit 1 ];
User partnerUser = new User(
Username='testspartner@dll.com',
Alias = 'test1', 
Email='testpartner5@dell.com', 
FirstName='TestP1', 
LastName='TestL', 
ProfileId = p.Id,
//UserRoleId=PortalRole.Id,
contactId = cont.id,
LanguageLocaleKey='en_US', 
LocaleSidKey='en_US', 
EmailEncodingKey='UTF-8', 
TimeZoneSidKey='America/Los_Angeles',
Badge_Number__c='partnerUser', 
isActive = TRUE
);
insert partnerUser;*/
        //subbu changes 
        final List<Profile> partnerProfiles = 
            [select id,name from Profile where UserType = 'PowerPartner' and name like '%LA PRM%' limit 1];
        Contact contact = new Contact(
            AccountId=acc.id,
            Email='test@test.com', 
            FirstName = 'John', 
            LastName = 'Doe'
        );
        insert contact;
        User partnerUser= new User(
            Username='test' + System.currentTimeMillis() + '@test.com',
            Alias = 'test1', 
            Email='test@test.com', 
            FirstName='John', 
            LastName='Doe', 
            ProfileId = partnerProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c=null, 
            ContactId = contact.id,
            isActive = TRUE
        );
        insert partnerUser;
        
        Opportunity intOpp = new Opportunity(
            name = 'TestOpp',
            AccountId = acc.id,
            Type = 'Design',
            Domain__c = 'Networking',
            Solution_Type__c = 'Campus',
            Solution_Name__c = 'Wireless Switches',
            StageName = 'Plan - 1%',
            CloseDate = System.today(),
            Deal_Type__c = 'Greenfield',
            Deal_Registration_Status__c = 'New',
            Deal_Expiration_Date__c = System.today() + 10,
            Opportunity_Customer_Number__c = CustNum.id,
            OSC_Solution_ID__c = 'EURO:123.3'
        );
        
        //////TriggerExecutionController.setSkipOpportunityTriggers(true);
        //////TriggerExecutionController.setskipOpportunityLineItemTriggers(true);
        insert intOpp;// when insering opp, the details should be passed to OSC
        
        
        //List<Solution__c> solutionList = [SELECT id,OSC_Solution_ID__c from Solution__C WHERE  OSC_Regional_ID__c =: intOpp.OSC_Solution_ID__c];
        //System.debug('____________________________________________________'+solutionList.size());
        
        Solution__c solObj = new Solution__c();
        solObj.Opportunity__c = intOpp.id;
        solObj.OSC_Regional_ID__c = '773456638.5';
        
        insert solObj;
        
        //addind products to opp
        //Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
        Product2 newPrdct = new Product2(Name = 'Test Product',Product_ID__c = '8876',Product_Line_Desc__c = 'test Product',IsActive = TRUE); 
        insert newPrdct;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe= new PricebookEntry (Product2ID=newPrdct.id,
                                                Pricebook2ID=pricebookId,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        insert pbe;
        Enable_Codes_Settings__c emcObj = new Enable_Codes_Settings__c();
        emcObj.Name = 'EMC Codes';
        emcObj.Enable__c = false;
        insert emcObj;
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =intOpp.Id,
                                                                    pricebookEntryId=pbe.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Product_Type__c = 'TestType',
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                   );
        
        Test.startTest();           
        insert testLineItem;//this will send the product details to OSC
        //////TriggerExecutionController.setSkipOpportunityTriggers(false);
        //////TriggerExecutionController.setskipOpportunityLineItemTriggers(false);
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        Test.stopTest();
        //update testLineItem;
        
        //associating another solution to this opp
        System.runas(partnerUser){
            Pagereference pr = new Pagereference('/apex/existingdealregistration');
            Test.setcurrentpagereference(pr);
            Apexpages.currentpage().getparameters().put('oscid','EURO:123.6');
            ExistingDealRegistrationCls edr = new ExistingDealRegistrationCls();  
            edr.oppid = intOpp.id;
            edr.showHideErr = True;
            edr.err = 'No matching records found. Please ensure that the Deal ID is valid';
            edr.getLstOpp();
            edr.total_size = 100;
            edr.getStages();
            edr.getDealRegStatuses();        
            edr.associate();    
            edr.beginning();
            edr.previous();
            edr.next();
            edr.getdisableprevious();
            edr.getdisablenext();
            edr.getTotal_size();
            edr.getpagenumber();
            edr.getTotalpages();
            edr.end();
            edr.SearchAction();
            edr.ResetAction();
            edr.IsProfile = true;
            edr.OSCActionIdentifier = 'Association';
        }
        
        TriggerExecutionController.setSkipAccountTriggers(false);
    }
    
    public static testmethod void SolutionRefresh()
    {
        Id accRTId= IdLookupUtils.getRecordTypeId('End-User Account','Account',true);
        Account accountObj;
        accountObj = new Account(name='Test', RecordtypeId = accRTId, Account_ID__c = '9876543');
        insert accountObj;
        
        User usr;
        Profile p = [SELECT id from Profile where name LIKE '%GBL EMEA Sales Mgr%' limit 1 ];
        usr = new User(
            Username='testsSale@dll.com',
            Alias = 'test1', 
            Email='testS3445@dell.com', 
            FirstName='John', 
            LastName='Doe', 
            ProfileId = p.Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='SUser1', 
            isActive = TRUE
        );
        insert usr; 
        
        //Id oppRTId= IdLookupUtils.getRecordTypeId('Standard opportunity','opportunity',true);
        list<id> oppid = new list<id>();
        Customer_Number__c CustNum1;
        CustNum1 = New Customer_Number__c (Name = '1111',BU_ID__c ='1111',Customer_Number_BU_Integ__c='11111111');
        insert CustNum1;
        Opportunity o = new Opportunity();
        //o.RecordtypeId = oppRTId;
        o.name = 'TestOpp';
        o.AccountId = accountObj.Id;
        //o.End_User_Account_Name__c = 'tcvs';
        o.Type = 'Design';
        o.Domain__c = 'Networking';
        o.Solution_Type__c = 'Campus';
        o.Solution_Name__c = 'Wireless Switches';
        //o.CurrencyIsoCode = 'USD - U.S Dollar';
        o.StageName = 'Plan - 1%';
        o.CloseDate = System.today();  
        o.Deal_Type__c = '';
        o.Deal_Registration_Status__c = '';
        o.Deal_Expiration_Date__c = System.today() + 10; 
        o.Opportunity_Customer_Number__c = CustNum1.id;
        o.osc_solution_id__c = 'EMEA:17091990.1';
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setskipOpportunityLineItemTriggers(true);
        insert o;
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setskipOpportunityLineItemTriggers(false);
        
        OSCWebserviceCallout.Messages_Z msgs = new OSCWebserviceCallout.Messages_Z();
        msgs.id = '123456';
        msgs.Description = 'description';
        msgs.ApplicationSource = 'sfdc';
        msgs.Source = 'abc1';
        msgs.Type = 'xyz1';
        
        list<OSCWebserviceCallout.Messages_Z> lstmsg = new list<OSCWebserviceCallout.Messages_Z>();
        lstmsg.add(msgs);
        
        OSCWebserviceCallout.Error Err = new OSCWebserviceCallout.Error();
        Err.Region = 'Asia'; 
        Err.DealId = '123789';
        Err.IsSuccess = 'True';
        Err.Messages = lstmsg;
        Err.InvalidSolutionIdList = null;
        
        list<OSCWebserviceCallout.Error> lsterr = new list<OSCWebserviceCallout.Error>();
        lsterr.add(Err);
        
        list<string> solutionList = new list<string>();
        Solution__c solObj = new Solution__c();
        solObj.Opportunity__c = o.id;
        solObj.OSC_Regional_ID__c = 'AMER:773456638.5';
        
        insert solObj;
        solutionList.add(solObj.OSC_Regional_ID__c);
        
        Pagereference pr = new Pagereference('/'+solObj.id);
        Test.setcurrentpagereference(pr); 
        Apexpages.currentpage().getparameters().put('id',solObj.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(solObj); 
        SolutionRefreshCtrlExtn srce1 = new SolutionRefreshCtrlExtn(sc);
        OSCWebServiceCallout.isRefreshBtnClicked = true;
        srce1.integrationResults = lsterr;
        srce1.MessageResults = lstmsg;
        system.debug('-----IR--'+srce1.integrationResults);
        
        
    }
    
    public static testmethod void RealtimeSolnupdate()
    {
        
        Id accRTId= IdLookupUtils.getRecordTypeId('End-User Account','Account',true);
        Account accountObj;
        accountObj = new Account(name='Test', RecordtypeId = accRTId, Account_ID__c = '9876543');
        insert accountObj;
        
        User usr;
        Profile p = [SELECT id from Profile where name LIKE '%GBL EMEA Sales Mgr%' limit 1 ];
        usr = new User(
            Username='testsSale@dll.com',
            Alias = 'test1', 
            Email='testS3445@dell.com', 
            FirstName='John', 
            LastName='Doe', 
            ProfileId = p.Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='SUser1', 
            isActive = TRUE
        );
        insert usr; 
        
        //Id oppRTId= IdLookupUtils.getRecordTypeId('Standard opportunity','opportunity',true);
        list<id> oppid = new list<id>();
        list<id> oppidlist = new list<id>();
        Customer_Number__c CustNum1;
        CustNum1 = New Customer_Number__c (Name = '1111',BU_ID__c ='1111',Customer_Number_BU_Integ__c='11111111');
        insert CustNum1;
        
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        
        Opportunity o = new Opportunity();
        //o.RecordtypeId = oppRTId;
        o.name = 'TestOpp';
        o.AccountId = accountObj.Id;
        //o.End_User_Account_Name__c = 'tcvs';
        o.Type = 'Design';
        o.Domain__c = 'Networking';
        o.Solution_Type__c = 'Campus';
        o.Solution_Name__c = 'Wireless Switches';
        //o.CurrencyIsoCode = 'USD - U.S Dollar';
        o.StageName = 'Plan - 1%';
        o.CloseDate = System.today();  
        o.Deal_Type__c = 'Agent';
        o.Deal_Registration_Status__c = 'New';
        o.Deal_Expiration_Date__c = System.today() + 10; 
        o.Opportunity_Customer_Number__c = CustNum1.id;
        o.osc_solution_id__c = 'EMEA:17091990.1';
        
        system.Test.startTest();        
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(true);        
        insert o;  
        
        
        Map<Id, Opportunity> opmap = new map<Id, Opportunity>([select Id,Opportunity_Customer_Number__c, Opportunity_Customer_Number__r.Name, Deal_Type__c,Deal_Expiration_Date__c,stagename, Deal_Registration_Status__c,Unassigned_End_User__c from Opportunity where Id = : o.id]);
        
        system.debug('----------------- o ' + o);
        
        o.Deal_Registration_Status__c = 'Submitted'; 
        o.StageName = 'Discover - 10%';   
        o.Deal_Type__c = 'Greenfield';
        Database.upsert(o);
        TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipOpportunityLineItemTriggers(false);
        
        system.debug('@@@@@@@@@@@@@@@@@@@@@@@@Oppty' + o);
        oppid.add(o.id);
        system.debug('--------------oppid' + oppid);
        
        list<opportunity> oplist = new list<opportunity>();
        oplist.add(o);
        
        system.debug('---------------- oplist' + oplist);
        system.debug('---------------- opmap ' + opmap);
        System.runas(usr){
            OpportunityUtilities.RealtimeSolutionsupdate(oplist,opmap);
            OSCWebserviceCallout.sendNotification(oppidlist,'DealSync');
            system.Test.stopTest();
            
        }
        
    }
    
    public static testMethod void internalAssociationdeletingproduct(){
        TriggerExecutionController.setSkipAllTriggers(true);
        createData();
        Profile p = [SELECT id from Profile where name LIKE '%GBL EMEA Sales Mgr%' limit 1 ];
        
        User internalUser = new User(
            Username='testsSale@dll.com',
            Alias = 'test1', 
            Email='testS3445@dell.com', 
            FirstName='John', 
            LastName='Doe', 
            ProfileId = p.Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c='intUser', 
            isActive = TRUE
        );
        insert internalUser; 
        
        Opportunity intOpp = new Opportunity(
            name = 'TestOpp',
            AccountId = acc.id,
            Type = 'Design',
            Domain__c = 'Networking',
            Solution_Type__c = 'Campus',
            Solution_Name__c = 'Wireless Switches',
            StageName = 'Plan - 1%',
            CloseDate = System.today(),
            Deal_Type__c = 'Greenfield',
            Deal_Registration_Status__c = 'New',
            Deal_Expiration_Date__c = System.today() + 10,
            Opportunity_Customer_Number__c = CustNum.id,
            OSC_Solution_ID__c = 'EURO:123.3'
        );
        
        
        //////TriggerExecutionController.setSkipOpportunityTriggers(true);
        //////TriggerExecutionController.setskipOpportunityLineItemTriggers(true);
        Database.insert(intOpp);// when insering opp, the details should be passed to OSC
        system.debug('---------------------- intOpp' + intOpp);
        
        List<Solution__c> solutionList = [SELECT id,OSC_Solution_ID__c from Solution__C WHERE  OSC_Regional_ID__c =: intOpp.OSC_Solution_ID__c];
        System.debug('____________________________________________________'+solutionList.size());
        //addind products to opp
        //Pricebook2 pbk1 = [select Id from Pricebook2 where isStandard=true and IsActive = TRUE];
        
        
        Product2 newPrdct = new Product2(Name = 'Test Product',Product_ID__c = '8979',Product_Line_Desc__c = 'test Product',IsActive = TRUE); 
        insert newPrdct;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe= new PricebookEntry (Product2ID=newPrdct.id,
                                                Pricebook2ID=pricebookId,
                                                isActive=true,
                                                useStandardPrice=false,
                                                UnitPrice = 50);
        insert pbe; 
        
        OpportunityLineItem  testLineItem = new OpportunityLineItem(Opportunityid =intOpp.Id,
                                                                    pricebookEntryId=pbe.id,
                                                                    Mrgn__c =6,
                                                                    Discount_off__c = 7,
                                                                    UnitPrice = 100,
                                                                    Quantity =2,
                                                                    Product_Type__c = 'TestType',
                                                                    Description = 'Line Description',
                                                                    Service_Support_US__c = 'ProSupport IT - Mission Critical'
                                                                   ); 
        Test.startTest();
        insert testLineItem; //this will send the product details to OSC
        system.debug('----------------- testLineItem' + testLineItem);
        
        //////TriggerExecutionController.setskipOpportunityLineItemTriggers(false); 
        //////TriggerExecutionController.setSkipOpportunityTriggers(false);
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipAccountTriggers(true);
        //delete testLineItem;
        
        //associating another solution to this opp
        System.runas(internalUser){
            
            Pagereference pr = new Pagereference('/apex/InternalSalesExistingdealregistration');
            Test.setcurrentpagereference(pr);
            Apexpages.currentpage().getparameters().put('oscid','EU:675645342312.1');
            InternalSalesExistingDealRegistrationCls edr = new InternalSalesExistingDealRegistrationCls(); 
            List<Opportunity> ls = new List<Opportunity>();
            List<List<opportunity>> lst = new List<List<opportunity>>();
            ls.add(intOpp);
            lst.add(ls);
            edr.pgIndex = 0;
            edr.pageNumber= 2;
            edr.pageSize = 5;
            edr.oppid = ls[0].id;  
            system.debug('------------------ checking for oppty');     
            edr.lstOppMainList = lst;
            edr.lstopp = ls;
            edr.searchOppName = 'TestOpp';
            edr.searchStage = 'Plan - 1%';
            //edr.searchDealRegStatus = 'New';
            edr.searchEndUserAccName = acc.name;
            edr.searchOpp.Decision_Date__c = System.today();
            edr.associate();
            
        }
        Test.stopTest();
        TriggerExecutionController.setSkipAccountTriggers(false);
    }
   
    //V2.0
    public static testmethod void lstOppTest()
    {
        TriggerExecutionController.setSkipAllTriggers(true);
        //createData();
        Id accRTId= IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        Account accountObj;
        accountObj = new Account(name='Test', RecordtypeId = accRTId);
        insert accountObj;
        
        Contact c;
        c = new Contact(AccountId = accountObj.id, lastname = 'lastname', Phone = '1234');
        Database.insert(c);
        
       final List<Profile> partnerProfiles = 
            [select id,name from Profile where UserType = 'PowerPartner' and name like '%LA PRM%' limit 1];
        User internalUser= new User(
            Username='test' + System.currentTimeMillis() + '@test.com',
            Alias = 'test1', 
            Email='test@test.com', 
            FirstName='John', 
            LastName='Doe', 
            ProfileId = partnerProfiles.get(0).Id, 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            EmailEncodingKey='UTF-8', 
            TimeZoneSidKey='America/Los_Angeles',
            Badge_Number__c=null, 
            ContactId = c.id,
            isActive = TRUE
        );
        insert internalUser;
        
        Customer_Number__c custNum;
        custNum = New Customer_Number__c (Name = '1111',BU_ID__c ='7876',Customer_Number_BU_Integ__c='11117876');
        insert custNum;
        
        Opportunity intOpp = new Opportunity(
            name = 'TestOpp',
            AccountId = accountObj.id,
            Type = 'Design',
            Domain__c = 'Networking',
            Solution_Type__c = 'Campus',
            Solution_Name__c = 'Wireless Switches',
            StageName = 'Plan - 1%',
            CloseDate = System.today()+30,
            Deal_Type__c = 'Greenfield',
            Deal_Registration_Status__c = 'New',
            Deal_Expiration_Date__c = System.today() + 10,
            Decision_Date__c = System.today()+2,
            Opportunity_Customer_Number__c = custNum.id,
            OSC_Solution_ID__c = 'EURO:123.3',
            //3.0 Primary_Owner__c = internalUser.id,
            OwnerId = internalUser.id,
            End_User_Account_Name__c = 'Desc -'
        );
        
        system.runAs(internalUser)
        {
            Database.insert(intOpp);// when insering opp, the details should be passed to OSC
            system.debug('---------------------- intOpp' + intOpp);
            ExistingDealRegistrationCls obj = new ExistingDealRegistrationCls();
            obj.searchPrimaryOwner = '';
            obj.searchOppIds = '';
            obj.searchOpp = intOpp;
            obj.searchTagged = 'Owned';
            //obj.DealId = '999999';
            obj.searchOppName = 'Test';
            obj.searchEndUserAccName = 'Desc -';
            obj.searchStage = 'All';
            obj.getLstOpp();
        }
        
        System.assertNotEquals(null, intOpp.id, 'Opportunity Id is not null');
    }
    
}
/*
* Author   : 
* Purpose  : 
*
* Revision CR Number   Release No      Date            Modified By     Description
* -------- ---------   ----------      -----------     ------------    -----------
* 1.0
* 2.0      12749       FY17-DCS-0403   21-Mar-2016     Gan             Added testmehtod to test when task information is incomplete
* 2.1                                  22-Mar-2016     Gan             Fix existing failed test method
* 2.2      12758       FY17-DCS-0403   23-Mar-2016     Azwanti         Added coverage on validation done for Convert Lead with Status Not Equal â€œOpenâ€, â€œAcceptedâ€, â€œContactedâ€ or â€œMarketing Qualified Leadâ€.
* 2.3                                  25-Mar-2016     Gan             Fix System.RunAs that fail to trigger a flow (process bulder update a field)
* 2.4                                  13-May-2016     SuiYee          Fix testLeadConversionCreateTaskWIncompleteTaskInfo - BadgeNumber
* 3.0                  FY17-DCS-0602   18-May-2016     Gan             Fix the test failure during the 0502 deployment.
* 4.0                  FY17-DCS-0702   03-Jun-2016     Gan             Increase the test coverage for LeadConvertPageCtrl    
* 5.0      13216       FY17-DCS-0801   23-Jun-2016     Azwanti         added test method for LM2_15-Existing opportunity - Search & Select opportunity
* 5.1      13232       FY17-DCS-0801   24-Jun-2016     SuiYee          LM2_15-Existing opportunity - Lead conversion page lay out changes
* 6.0      13282       FY17-DCS-0801   28-Jun-2016     Gan             Fix test methods that fail after introduce link to existing oppty and test method for link existing oppty
* 6.1      13309       FY17-DCS-0801   06-Jul-2016     Gan             Add test method for Small Deal
* 6.2                  FY17-DCS-0801   13-Jul-2016     Gan             Increase code coverage
* 7.0      13640       FY17-DCS-0103   01-Nov-2016     SuiYee          Adding Department field to Lead 2.0 and mapping with contact field
* 7.1      13693       FY17-DCS-0103   01-Nov-2016     Sajith          Introduced Sales Follow Up days calculation logic during lead conversion
* 8.0      13806       FY18-DCS-0202   23-Dec-2016     Gan             To enable Creation of SubAccount
* 8.1      13878       FY18-DCS-0202   06-Jan-2017     Azwanti         Added test data when Company contain single character
* 9.0      13927       FY18-DCS-0302   14-Feb-2017     Azwanti         LM2_17- Upload translated error messages for Lead 2.0
* 9.1      13991       FY18-DCS-0302   07-Feb-2016     Sajith          LM2_Optimization in lead conversion process - Contact validations
* 10.0     14566       FY18-DCS-0802   11-Jul-2017     Sajith          Existing Partner opportunity - New Grid for Partner Account
* 11.0     15435       FY19-DCS-0401   14-Feb-2018     Azwanti         Affinity Interlock: Making Legal English or Legal Local Address mandatory for China and Japan countries
* 12.0     15957       FY19-DCE-0802   28-Jun-2018     Fenny           Code cleanup: removed debug statement, shorten some variable name
* 13.0     18366       FY20-DCS-0202   12-Dec-2019     Siva            Increase the test coverage for LeadConvertPageCtrl           
*/
@isTest
private class TestLeadConvertPage {

/****
    //insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018- START
    @testSetup static void setup() {
        OWD__c oWDsetting = new OWD__c();
        oWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        oWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        oWDsetting.Oppty_Stage100__c = 'Win - 100%';
        oWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        oWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        oWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        oWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        oWDsetting.Oppty_Stage1__c = 'Plan - 1%';
        
        insert oWDsetting;
    }   
    //insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018 - END
 ****/   
    @testSetup 
    static void setUpConversionTestData() {
        TriggerExecutionController.setSkipAllTriggers(true);
        
         OWD__c oWDsetting = new OWD__c();
        oWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        oWDsetting.Oppty_Stage10__c = 'Discover - 10%';
        oWDsetting.Oppty_Stage100__c = 'Win - 100%';
        oWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
        oWDsetting.Oppty_Stage60__c = 'Propose - 60%';
        oWDsetting.Oppty_Stage90__c = 'Commit - 90%';
        oWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        oWDsetting.Oppty_Stage1__c = 'Plan - 1%';
        
        insert oWDsetting;
        
        CMAP_Queue_Settings__c eClerxQueue = new CMAP_Queue_Settings__c(Name = 'Channel_eClerx', Queue_Id__c = '00GA0000002y6hl', Queue_Name__c = 'Channel_eClerx');
        Database.insert(eClerxQueue);
        
        //Account Record INSERTION    
        Account newAccount = new Account(Name = 'Dell Internal_01');
        insert newAccount;
        
        //User Record INSERTION
        Profile userProfile= [select id,name from profile where name like '%GBL Sales Rep%' order by name limit 1 ];
        User user = new User( Username='TestLeadConversion' +System.currentTimeMillis() + '@test.com',
                             Alias = 'TstLd'+056,
                             Email='test'+ 012 +'@dell.com',
                             FirstName='Tfirst'+0,
                             LastName='TestLeadConversion'+100,
                             ProfileId = userProfile.Id,
                             LanguageLocaleKey='en_US',
                             LocaleSidKey='en_US',
                             EmailEncodingKey='UTF-8',
                             TimeZoneSidKey='America/Los_Angeles',
                             Badge_Number__c='TstLeadCon123456789' );
        insert user;
        
        //Test Data for CONTACT
       ContactTestData.iNumberOfContacts = 1;
        ContactTestData.createContact();
        list<Contact> lstContacts = ContactTestData.lstContacts;
        lstContacts[0].LastName = 'TestLeadConversion-Contact 1';
        lstContacts[0].Accountid = newAccount.id;
        update lstContacts;
        
        //TEST data for Opportunity
        Id oppRecordTypeId= IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity',true);
        Opportunity opp=new Opportunity (name='TestLeadConversion-Opp 1', Total_Expected_Dell_Revenue__c=5000,CloseDate=System.Today(),Description='Test Desc',StageName='Plan - 1%', Forecast_Category_Override__c = 'Omitted',RecordtypeId = oppRecordTypeId);
        insert opp;
        
        //TestData for SALES CHANNEL
        Sales_Channel_Group__c testSalesChannelRecord = new Sales_Channel_Group__c
            (Name='TestLeadConversion-SC Record 1',
             Group_ID__c=''+System.currentTimeMillis()
            );
        insert testSalesChannelRecord;
        
        //TestData for COUNTRY
        country__c country = new Country__c (Name = 'TestLeadConversion-Contry 1',code__c='US',region__c = 'EMEA',Is_Active_in_Affinity__c = true);
        insert country;
        
        country__c chinaCntry = new country__c(Name='CHINA', Code__c='CH',region__c='APJ',Is_Active_in_Affinity__c=true);
        insert chinaCntry;
        
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        lstLeads[0].LastName='TestLeadConversion';
        lstLeads[0].ownerid = user.id;
        lstLeads[0].Country = 'CHINA';
        lstLeads[0].Country_CN__c = 'CHINA';
        //lstLeads[0].Country_Code__c = 'CHINA';
        
        update lstLeads;
     
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    
    private static testMethod void myLeadConversionWithExistingAccount() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();
        Account newAccount=[SELECT Id,Name FROM Account WHERE Name='Dell Internal_01' LIMIT 1];
        User user=[SELECT Id,Username FROM User WHERE LastName='TestLeadConversion100' LIMIT 1];
        Lead newLead=[SELECT Id,LastName,ownerid,Company FROM Lead Where LastName='TestLeadConversion' LIMIT 1];
        Contact objContact=[SELECT Id, Accountid FROM Contact WHERE LastName = 'TestLeadConversion-Contact 1' LIMIT 1];
        country__c country =[SELECT Id,Name FROM country__c WHERE Name='TestLeadConversion-Contry 1' LIMIT 1];
        Opportunity objOpportunity=[SELECT Id,Name FROM Opportunity WHERE Name='TestLeadConversion-Opp 1' LIMIT 1 ];
        Sales_Channel_Group__c testSalesChannelRecord=[SELECT Id FROM Sales_Channel_Group__c WHERE Name='TestLeadConversion-SC Record 1' LIMIT 1];
        newLead.Sales_Follow_up_days__c = null;
        newLead.First_time_assigned_to_Sales__c=system.now();
        newLead.Contact__c = objContact.id;
        newLead.Account__c =objContact.AccountId;
                
        //Test conversion validation with invalid lead status
        //newLead.Status='Marketing Ready Lead';
        update newLead;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(newLead);
        LeadConvertPageCtrl leadController = new LeadConvertPageCtrl(stdController);
        
        leadcontroller.leadToConvert = newLead;
                
        leadController.getMyComponentController();
        leadController.getmyTaskComponentController();
        leadController.getThis();
        
        // Initialize PageControllerBase
        PageControllerBase pgBase = new PageControllerBase();
        pgBase.getMyComponentController();
        pgBase.getmyDescriptionComponentController();
        pgBase.getmyTaskComponentController();
        pgBase.getThis();
        pgBase.getmyReminderComponentController();
        
        // Initialize ComponentControllerBase
        ComponentControllerBase compBase = new ComponentControllerBase();
        compBase.pageController = pgBase;
        compBase.pageControllerDescription = pgBase;
        compBase.pageControllerReminder = pgBase;
        compBase.pageControllerTask = pgBase;
        
        // Test myCompCtrler is null.
        leadController.convertLead();
        
        leadController.setComponentController(new leadConvertCoreComponentController());
        leadController.setTaskComponentController(new leadConvertTaskInfoComponentController());
        System.assert(leadController.myTaskCompCtrler != null);
        
        // Test Account Name: Please select an Account.
        leadController.myCompCtrler.selectedAccount = 'NONE';
        leadController.convertLead();
        
        leadController.myCompCtrler.selectedAccount = newAccount.Id;
        leadController.convertLead();
        
        leadController.myCompCtrler.selectedContact = objContact.id;
        leadController.myCompCtrler.validateContact();
        
        // Test Opportunity Name: You must enter a value.
        
        leadController.myCompCtrler.oppty = 'New';
        leadController.convertLead();
        
        //leadController.myCompCtrler.opportunityName='New TestLeadConversion';
        leadController.myCompCtrler.oppty = 'Existing';
        leadController.convertLead();
        
        ApexPages.currentPage().getParameters( ).put('selectedOppid', objOpportunity.id);
        ApexPages.currentPage().getParameters( ).put('selectedOppName', objOpportunity.Name);
        ApexPages.currentPage().getParameters( ).put('selectedOppDaysCreated','1');
        leadController.myCompCtrler.populateOppty();   
        // Test Converted Status: Please select a Lead Status.
        leadController.myCompCtrler.leadConvert = newLead;
        leadController.myCompCtrler.selectedAccount = 'New';
        leadController.convertLead();  
        leadController.myCompCtrler.selectedContact = 'New';
        leadController.myCompCtrler.oppty = 'New';
        leadController.myCompCtrler.opportunityName='New TestLeadConversion';
        leadController.myCompCtrler.leadConvert.Status = 'NONE';
        
        leadController.convertLead();    
        leadController.myCompCtrler.leadConvert.Status = 'Converted to New Opportunity';
        //leadController.myCompCtrler.LeadStatusOption = 'Converted to Opportunity';

        leadController.myCompCtrler.leadConvert.ownerid = user.id;
        
        leadController.myCompCtrler.selectedAccount ='NEW';
        leadController.convertLead();  
        
        newLead.physical_country__c=country.id;
        newLead.Status = 'Working';
        //update newLead;
        //leadController.convertLead();
        
        newLead.Territory_Assignment__c = testSalesChannelRecord.id;
        update newLead;
        leadController.myCompCtrler.LeadStatusOption = 'Converted to New Opportunity';

        // Test If Subject is not set then show an error / If a due date is not set then show an error 
        leadController.myCompCtrler.selectedAccount = newAccount.Id;
        leadController.myTaskCompCtrler.taskID.Subject = 'TEST TASK';
        leadController.myTaskCompCtrler.taskID.Priority = 'High';
        leadController.myTaskCompCtrler.taskID.Status = 'Not Started';
        leadController.myTaskCompCtrler.taskID.ActivityDate = System.today();
        leadController.myCompCtrler.sendOwnerEmail = true;
        Contact contactID = leadController.myCompCtrler.contactID;
        leadController.myCompCtrler.contactID.ownerID = user.id;
        //List<SelectOption> leadStatuses = leadController.myCompCtrler.LeadStatusOption;
        leadController.myCompCtrler.oppty = 'New';
        leadController.myCompCtrler.opportunityName='';
        Opportunity opportunityID = leadController.myCompCtrler.opportunityID;
        String reminderTime = leadController.myTaskCompCtrler.remCon.reminderTime;
        List<SelectOption> timeOptions = leadController.myTaskCompCtrler.remCon.ReminderTimeOption;
        leadController.myTaskCompCtrler.sendNotificationEmail = true;
        leadController.myCompCtrler.sendOwnerEmail = true;
        leadController.convertLead();
        List<SelectOption> priorityOptions = leadController.myTaskCompCtrler.TaskPriorityOption;
        List<SelectOption> statusOptions = leadController.myTaskCompCtrler.TaskStatusOption;
        
        leadController.printErrors(new List<Database.Error>());
        leadController.printError('Test');
        leadController.validateLead();
        leadController.selectedAccountId =newAccount.id;
        //leadController.continueProcess();
        leadController.goBack();
        
        string reminderDate = leadController.myTaskCompCtrler.remCon.disabledActivityDate;
        
        leadController.myCompCtrler.selectedAccount = 'NEW';
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];   
        System.runAs ( thisUser ) {
            // Test the reminder time as a French user to test the 24 hour clock
            Profile profileObj = [select id from profile where name='Standard User'];

            User userObj = new User(alias = 'standt', email='stdUser' +System.currentTimeMillis() + '@DellTeam.com',
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='fr',
                          localesidkey='fr', profileid = profileObj.Id,
                          timezonesidkey='America/Los_Angeles',Badge_Number__c = 'STDU' + System.currentTimeMillis(), 
                          Username='stdUser'+System.currentTimeMillis() + '@test.com');
        
            System.runAs(userObj) {
                timeOptions = leadController.myTaskCompCtrler.remCon.ReminderTimeOption;
            }
        }
         leadController.myCompCtrler.selectedAccount = 'NONE';
        //leadController.myDescriptionComponentController.sendNotificationEmail = false;
        leadController.myTaskCompCtrler.sendNotificationEmail = false;
        
        // Test the situation where there is a due date but no subject
        leadController.myTaskCompCtrler.taskID.ActivityDate = system.today();
        leadController.myTaskCompCtrler.taskID.Subject = '';
        leadController.myCompCtrler.leadConvert.Status = 'NONE';
         
        // Convert the lead
        leadController.convertLead();
        
        //Test accountLookup method     
        leadController.myCompCtrler.accountLookedUp();
        leadController.convertLead();
        
        leadController.myTaskCompCtrler.DueDateChanged();
        
        leadController.myCompCtrler.leadConvert.Status = 'Converted to New Opportunity';//Sajith
        leadController.myCompCtrler.selectedAccount = newAccount.Id;//Sajith
        
        //leadController.continueProcess();
        
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
    }
    
    private static testMethod void testInvalidContact(){
        
        TriggerExecutionController.setSkipAllTriggers(true);
        test.startTest();
        Account newAccount=[SELECT Id,Name FROM Account WHERE Name='Dell Internal_01' LIMIT 1];
        User user=[SELECT Id,Username FROM User WHERE LastName='TestLeadConversion100' LIMIT 1];
        country__c country =[SELECT Id,Name FROM country__c WHERE Name='TestLeadConversion-Contry 1' LIMIT 1];
                
        //                     Badge_Number__c='123451' 
        
        LeadTestData.iNumberOfLeads = 1;
        leadTestData.bCreate = false;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        Lead newLead = lstLeads[0];
        newLead.Phone='6739abc';
        insert newLead;
        
        
        system.debug('suiuyee '+ newLead.phone);
        ApexPages.StandardController stdController = new ApexPages.StandardController(newLead);
        LeadConvertPageCtrl leadController = new LeadConvertPageCtrl(stdController);
        leadController.validateLead();
        test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);

    }
    
    //2.0
    private static testMethod void testLeadConversionCreateTaskWIncompleteTaskInfo(){
        
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();

        Account newAccount=[SELECT Id,Name FROM Account WHERE Name='Dell Internal_01' LIMIT 1];
        //User user=[SELECT Id,Username FROM User WHERE LastName='TestLeadConversion100' LIMIT 1];
        Profile userProfile= [select id,name from profile where name like '%GBL Sales Rep%' order by name limit 1 ];
        User user = new User( Username='test' +System.currentTimeMillis() + '@test.com',
                             Alias = 'test'+056, 
                             Email='test'+ 012 +'@dell.com', 
                             FirstName='Tfirst'+0, 
                             LastName='TLast'+09,
                             ProfileId = userProfile.Id, 
                             LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', 
                             EmailEncodingKey='UTF-8', 
                             TimeZoneSidKey='America/Los_Angeles',
                             //3.0
                             Badge_Number__c='1010' + String.valueOf(Math.round(Math.random()*1000000000)) + '0202');
        insert user;
        
        Lead newLead=[SELECT Id,LastName,ownerid,Company,Account__c,Contact__c,Country_Code__c FROM Lead Where LastName='TestLeadConversion' LIMIT 1];
        Contact objContact=[SELECT Id, Accountid FROM Contact WHERE LastName = 'TestLeadConversion-Contact 1' LIMIT 1];
        country__c country =[SELECT Id,Name,code__c FROM country__c WHERE Name='TestLeadConversion-Contry 1' LIMIT 1];
        Sales_Channel_Group__c testSalesChannelRecord=[SELECT Id FROM Sales_Channel_Group__c WHERE Name='TestLeadConversion-SC Record 1' LIMIT 1];
        
        
         newlead.ownerid = user.id;      
        newLead.Contact__c = objContact.id;
        newLead.Account__c = objContact.AccountId;
         newLead.Sales_Follow_up_days__c = null;
        newLead.First_time_assigned_to_Sales__c=system.now();
        update newLead;
        
        // Start Testing
                
        ApexPages.StandardController stdController = new ApexPages.StandardController(newLead);
        LeadConvertPageCtrl leadController = new LeadConvertPageCtrl(stdController);
        
        leadcontroller.leadToConvert = newLead;
        //System.debug('before assigning contact'+lstContacts[0]);
        
        leadController.getMyComponentController();
        //leadController.getmyDescriptionComponentController();
        leadController.getmyTaskComponentController();
        leadController.getThis();
        
        // Initialize PageControllerBase
        PageControllerBase pgBase = new PageControllerBase();
        pgBase.getMyComponentController();
        pgBase.getmyDescriptionComponentController();
        pgBase.getmyTaskComponentController();
        pgBase.getThis();
        pgBase.getmyReminderComponentController();
        
        // Initialize ComponentControllerBase
        ComponentControllerBase compBase = new ComponentControllerBase();
        compBase.pageController = pgBase;
        compBase.pageControllerDescription = pgBase;
        compBase.pageControllerReminder = pgBase;
        compBase.pageControllerTask = pgBase;
        
        leadController.setComponentController(new leadConvertCoreComponentController());
        //leadController.setDescriptionComponentController(new leadConvertTaskDescComponentController());
        leadController.setTaskComponentController(new leadConvertTaskInfoComponentController());
        System.assert(leadController.myTaskCompCtrler != null);
        
        leadController.myCompCtrler.leadConvert = newLead;
        leadController.myCompCtrler.selectedAccount = newAccount.Id;
        leadController.myCompCtrler.selectedContact = objContact.Id;      
        //6.0
        leadController.myCompCtrler.oppty = 'Default';
        //leadController.myCompCtrler.leadConvert.Status = 'Marketing Qualified Lead';
        leadController.myCompCtrler.leadConvert.ownerid = user.id;
        
        leadController.myTaskCompCtrler.taskID.Subject = 'TEST TASK';
        leadController.myTaskCompCtrler.taskID.Priority = 'High';
        leadController.myTaskCompCtrler.taskID.Status = 'Not Started';
        leadController.myTaskCompCtrler.taskID.ActivityDate = null;
        leadController.myCompCtrler.sendOwnerEmail = false;
        
        leadController.convertLead();
        /*
        //3.0
        system.runAs(user) {   
            leadController.myTaskCompCtrler.taskID.ActivityDate =  System.today();
            leadController.myTaskCompCtrler.remCon.taskID.ActivityDate = System.today();
            leadController.myTaskCompCtrler.remCon.reminderTime = '8:00 AM';
            leadController.myTaskCompCtrler.remCon.taskID.IsReminderSet = true;
            leadController.myTaskCompCtrler.sendNotificationEmail = true;
            leadController.convertLead();
        }
        */
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
        
    }
    
    
    //2.2
    
    private static testMethod void testConvertLeadWithAccountAndNewOppty() {
        TriggerExecutionController.setSkipAllTriggers(true);
        test.startTest();
        Account newAccount=[SELECT Id,Name FROM Account WHERE Name='Dell Internal_01' LIMIT 1];
        User user=[SELECT Id,Username FROM User WHERE LastName='TestLeadConversion100' LIMIT 1];
        Lead newLead=[SELECT Id,LastName,ownerid,Account__c,Contact__c,Company FROM Lead Where LastName='TestLeadConversion' LIMIT 1];
        Contact objContact=[SELECT Id, Accountid FROM Contact WHERE LastName = 'TestLeadConversion-Contact 1' LIMIT 1];
        country__c country =[SELECT Id,Name FROM country__c WHERE Name='TestLeadConversion-Contry 1' LIMIT 1];
        Opportunity opp=[SELECT Id,Name FROM Opportunity WHERE Name='TestLeadConversion-Opp 1' LIMIT 1 ];
        Sales_Channel_Group__c testSalesChannelRecord=[SELECT Id FROM Sales_Channel_Group__c WHERE Name='TestLeadConversion-SC Record 1' LIMIT 1];
        
       
        ApexPages.StandardController stdController = new ApexPages.StandardController(newLead);
        LeadConvertPageCtrl leadController = new LeadConvertPageCtrl(stdController);
        
        leadcontroller.leadToConvert = newLead;
        
        leadController.getMyComponentController(); 
        leadController.getThis();
        
        // Initialize PageControllerBase
        PageControllerBase pgBase = new PageControllerBase();
        pgBase.getMyComponentController();
        pgBase.getThis();
        
        // Initialize ComponentControllerBase
        ComponentControllerBase compBase = new ComponentControllerBase();
        compBase.pageController = pgBase;
        compBase.pageControllerDescription = pgBase;
        compBase.pageControllerReminder = pgBase;
        compBase.pageControllerTask = pgBase;        
        
        leadController.convertLead();        
        leadController.setComponentController(new leadConvertCoreComponentController());        
        leadController.myCompCtrler.selectedAccount = newAccount.Id;
        
        // Test Account with no open Opportunity
        leadController.myCompCtrler.Oppty = 'New';       
        
        ApexPages.currentPage().getParameters( ).put('selectedOppid',opp.id);
        ApexPages.currentPage().getParameters( ).put('selectedOppName',opp.Name);
        ApexPages.currentPage().getParameters( ).put('selectedOppDaysCreated','1');
        leadController.myCompCtrler.opptyActionChanged();
        leadController.convertLead();
        TriggerExecutionController.setSkipAllTriggers(false);
        
        Test.stopTest();
    }
    
    //6.0
    private static testMethod void testLeadConversionLinkedExistingOppty(){
       TriggerExecutionController.setSkipAllTriggers(true);
       
       Test.startTest();
 
        Account newAccount = [select id,name,RecordTypeId,type from Account where Name = 'Dell Internal_01' LIMIT 1];
        Id accRecordTypeId = IdLookupUtils.getRecordTypeId('Partner Account','Account',true);
        newAccount.RecordTypeId = accRecordTypeId;
        newAccount.type = 'Partner';
        update newAccount;
        
        Id oppRecordTypeId= IdLookupUtils.getRecordTypeId('Standard Opportunity','Opportunity',true);
        Id oppDealRegRecTypeId = IdLookupUtils.getRecordTypeId('Deal Registration','Opportunity',true);
        List<Opportunity> listTestOppty = new List<Opportunity>();
        
        for(integer i=0; i < 21; i++){
            Opportunity newOppty = new Opportunity(Name = 'test opp SR'+i, Deal_Created_Date_Time__c = system.today().adddays(1), Deal_Registration_Status__c='Approved', AccountId = newAccount.Id, Total_Expected_Dell_Revenue__c=5000,StageName = 'Plan - 1%', Forecast_Category_Override__c = 'Omitted',Description='Test Desc',CloseDate = System.Now().Date().addDays(180), RecordTypeId=oppRecordTypeId);
            listTestOppty.add(newOppty);
        }
        insert listTestOppty;
        
        Profile userProfile= [select id,name from profile where name like '%GBL Sales Rep%' order by name limit 1 ];
        User user = new User( Username='test1' +System.currentTimeMillis() + '@test.com',
                             Alias = 'test'+056, 
                             Email='test'+ 012 +'@dell.com', 
                             FirstName='Tfirst'+0, 
                             LastName='TLast'+09,
                             ProfileId = userProfile.Id,
                             Title = 'Channel_Test_user',
                             LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_AU', 
                             EmailEncodingKey='UTF-8', 
                             TimeZoneSidKey='America/Los_Angeles',
                             //3.0
                             Badge_Number__c='1010' + String.valueOf(Math.round(Math.random()*1000000000)) + '0202');
        insert user;
 
 
 
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> listLeads = LeadTestData.lstLeads;
        
        
        ContactTestData.iNumberOfContacts = 1;
        ContactTestData.createContact();
        list<Contact> listContacts = ContactTestData.lstContacts;              
        listContacts[0].Accountid = newAccount.id;
        update listContacts;
        
        Lead newLead = listLeads[0];
        newlead.ownerid = user.id;      
        update newLead;             
        
        country__c country =[SELECT Id,Name,code__c,region__c,Is_Active_in_Affinity__c FROM country__c WHERE Name='TestLeadConversion-Contry 1' LIMIT 1];

               
        Sales_Channel_Group__c testSalesChannelRecord = new Sales_Channel_Group__c
            (Name='Test - SC Record 11', 
             Group_ID__c=''+System.currentTimeMillis()
            );
        insert testSalesChannelRecord;
        
        system.runas(user){
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(newLead);
        LeadConvertPageCtrl leadController = new LeadConvertPageCtrl(stdController);
        
        leadcontroller.leadToConvert = newLead;
        System.debug('before assigning contact'+listContacts[0]);
        
        leadController.getMyComponentController();
        //leadController.getmyDescriptionComponentController();
        leadController.getmyTaskComponentController();
        leadController.getThis();
        
        // Initialize PageControllerBase
        PageControllerBase pgBase = new PageControllerBase();
        pgBase.getMyComponentController();
        pgBase.getmyDescriptionComponentController();
        pgBase.getmyTaskComponentController();
        pgBase.getThis();
        pgBase.getmyReminderComponentController();
        
        // Initialize ComponentControllerBase
        ComponentControllerBase compBase = new ComponentControllerBase();
        compBase.pageController = pgBase;
        compBase.pageControllerDescription = pgBase;
        compBase.pageControllerReminder = pgBase;
        compBase.pageControllerTask = pgBase;
        
        leadController.setComponentController(new leadConvertCoreComponentController());
        //leadController.setDescriptionComponentController(new leadConvertTaskDescComponentController());
        leadController.setTaskComponentController(new leadConvertTaskInfoComponentController());
        System.assert(leadController.myTaskCompCtrler != null);
        
        leadController.myCompCtrler.leadConvert = newLead;
        leadController.myCompCtrler.selectedAccount = newAccount.Id;
        leadController.myCompCtrler.selectedContact = listContacts[0].Id;    
        
        leadController.myCompCtrler.oppty = 'Default';
        leadController.myCompCtrler.opptyActionChanged();
        leadController.myCompCtrler.oppty = 'Existing';  
        leadController.myCompCtrler.opptyActionChanged();
        
        //test coverage for error 
        leadController.convertLead();
        system.assert(leadController.myCompCtrler.listExistingOpp.size() == 20);
        system.assertEquals(leadController.myCompCtrler.listExistingPartnerOpp.size(),0);
        
        ApexPages.currentPage().getParameters( ).put('selectedOppid',listTestOppty[0].id);
        ApexPages.currentPage().getParameters( ).put('selectedOppName',listTestOppty[0].Name);
        ApexPages.currentPage().getParameters( ).put('selectedOppDaysCreated','1');
        leadController.myCompCtrler.populateOppty();
        leadController.myCompCtrler.next();
        leadController.myCompCtrler.previous();
        leadController.myCompCtrler.getbHasPreviousAndNext();
        //leadController.myCompCtrler.getpHasPreviousAndNext();
        //leadController.myCompCtrler.nextPartnerOpp();
        //leadController.myCompCtrler.previousPartnerOpp();

        //leadController.myCompCtrler.leadConvert.Status = 'Sales Qualified Lead';
        leadController.myCompCtrler.leadConvert.ownerid = user.id;
        
        leadController.myTaskCompCtrler.taskID.Subject = 'TEST TASK';
        leadController.myTaskCompCtrler.taskID.Priority = 'High';
        leadController.myTaskCompCtrler.taskID.Status = 'Not Started';
        leadController.myTaskCompCtrler.taskID.ActivityDate = System.today();
        leadController.myCompCtrler.sendOwnerEmail = true;
        
        leadController.myTaskCompCtrler.sendNotificationEmail = false;
        //leadController.convertLead();
        leadController.myCompCtrler.resetContactInfo();
        leadcontroller.myCompCtrler.printError('Test Error');
        
        }
        Test.stopTest();
        TriggerExecutionController.setSkipAllTriggers(false);
    }   
    
    private static testMethod void testInvalidBadgeError() {
        
        TriggerExecutionController.setSkipAllTriggers(true);
          
        Test.startTest();      
        Account newAccount = [select id,name from Account where Name = 'Dell Internal_01' LIMIT 1];
        user user = [select id,username,name,profileId,Badge_Number__c from user where LastName='TestLeadConversion100' LIMIT 1];
        country__c country =[SELECT Id,Name,region__c,Is_Active_in_Affinity__c  FROM country__c WHERE Name='TestLeadConversion-Contry 1' LIMIT 1];

        
        LeadTestData.iNumberOfLeads = 1;
        leadTestData.bCreate = true;
        LeadTestData.createDirectLead2();
        list<Lead> listLeads = LeadTestData.lstLeads;
        listLeads[0].OwnerId = user.id;
        update listLeads;
        
        ContactTestData.iNumberOfContacts = 1;
        ContactTestData.createContact();
        list<Contact> listContacts = ContactTestData.lstContacts;              
        listContacts[0].Accountid = newAccount.id;
        update listContacts;
        TriggerExecutionController.setSkipAllTriggers(false);
        
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(listLeads[0]);
        LeadConvertPageCtrl leadController = new LeadConvertPageCtrl(stdController);
        
        leadcontroller.leadToConvert = listLeads[0];
        
        leadController.getMyComponentController();
        leadController.getmyTaskComponentController();
        leadController.getThis();
        
        // Initialize PageControllerBase
        PageControllerBase pgBase = new PageControllerBase();
        pgBase.getMyComponentController();
        pgBase.getmyDescriptionComponentController();
        pgBase.getmyTaskComponentController();
        pgBase.getThis();
        pgBase.getmyReminderComponentController();
        
        // Initialize ComponentControllerBase
        ComponentControllerBase compBase = new ComponentControllerBase();
        compBase.pageController = pgBase;
        compBase.pageControllerDescription = pgBase;
        compBase.pageControllerReminder = pgBase;
        compBase.pageControllerTask = pgBase;
        
        leadController.setComponentController(new leadConvertCoreComponentController());
        leadController.setTaskComponentController(new leadConvertTaskInfoComponentController());
        System.assert(leadController.myTaskCompCtrler != null);
        
        leadController.myCompCtrler.leadConvert = listLeads[0];
        leadController.myCompCtrler.selectedAccount = newAccount.Id;
        leadController.myCompCtrler.selectedContact = listContacts[0].Id;      
        //6.0
        leadController.myCompCtrler.oppty = 'Default';
        //leadController.myCompCtrler.leadConvert.Status = 'Marketing Qualified Lead';
        leadController.myCompCtrler.leadConvert.ownerid = user.id;
        
        leadController.myTaskCompCtrler.taskID.Subject = 'TEST TASK';
        leadController.myTaskCompCtrler.taskID.Priority = 'High';
        leadController.myTaskCompCtrler.taskID.Status = 'Not Started';
        leadController.myTaskCompCtrler.taskID.ActivityDate = null;
        leadController.myCompCtrler.sendOwnerEmail = false;
        
        leadController.convertLead();
        
        Test.stopTest();
        
    }
    
    private static testMethod void testOwnerProfileError() {
        
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();

        Account newAccount = [select id,name from Account where Name = 'Dell Internal_01' LIMIT 1];
        country__c country =[SELECT Id,Name,region__c,Is_Active_in_Affinity__c  FROM country__c WHERE Name='TestLeadConversion-Contry 1' LIMIT 1];
        
        Profile userProfile= [select id,name from profile where name like '%Marketing%' order by name limit 1 ];
        User user = new User( Username='testrandom' +System.currentTimeMillis() + '@test.com',
                             Alias = 'testrd'+06, 
                             Email='testrandom'+ 012 +'@dell.com', 
                             FirstName='Tfirst'+0, 
                             LastName='TLast'+09,
                             ProfileId = userProfile.Id, 
                             LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', 
                             EmailEncodingKey='UTF-8', 
                             TimeZoneSidKey='America/Los_Angeles',
                             HR_Location_Country_Desc__c='CHINA',
                             Badge_Number__c='1010' + String.valueOf(Math.round(Math.random()*1000000000)) + '0202' );
        insert user;
        
        LeadTestData.iNumberOfLeads = 1;
        leadTestData.bCreate = true;
        LeadTestData.createDirectLead2();
        list<Lead> listLeads = LeadTestData.lstLeads;
        listLeads[0].OwnerId = user.id;
        
        ContactTestData.iNumberOfContacts = 1;
        ContactTestData.createContact();
        list<Contact> listContacts = ContactTestData.lstContacts;              
        listContacts[0].Accountid = newAccount.id;
        update listContacts;
        TriggerExecutionController.setSkipAllTriggers(false);
        
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(listLeads[0]);
        LeadConvertPageCtrl leadController = new LeadConvertPageCtrl(stdController);
        
        leadcontroller.leadToConvert = listLeads[0];
        
        leadController.getMyComponentController();
        leadController.getmyTaskComponentController();
        leadController.getThis();
        
        // Initialize PageControllerBase
        PageControllerBase pgBase = new PageControllerBase();
        pgBase.getMyComponentController();
        pgBase.getmyDescriptionComponentController();
        pgBase.getmyTaskComponentController();
        pgBase.getThis();
        pgBase.getmyReminderComponentController();
        
        // Initialize ComponentControllerBase
        ComponentControllerBase compBase = new ComponentControllerBase();
        compBase.pageController = pgBase;
        compBase.pageControllerDescription = pgBase;
        compBase.pageControllerReminder = pgBase;
        compBase.pageControllerTask = pgBase;
        
        leadController.setComponentController(new leadConvertCoreComponentController());
        leadController.setTaskComponentController(new leadConvertTaskInfoComponentController());
        System.assert(leadController.myTaskCompCtrler != null);
        
        leadController.myCompCtrler.leadConvert = listLeads[0];
        leadController.myCompCtrler.selectedAccount = newAccount.Id;
        leadController.myCompCtrler.selectedContact = listContacts[0].Id;      
        //6.0
        leadController.myCompCtrler.oppty = 'Default';
        //leadController.myCompCtrler.leadConvert.Status = 'Marketing Qualified Lead';
        leadController.myCompCtrler.leadConvert.ownerid = user.id;
        
        leadController.myTaskCompCtrler.taskID.Subject = 'TEST TASK';
        leadController.myTaskCompCtrler.taskID.Priority = 'High';
        leadController.myTaskCompCtrler.taskID.Status = 'Not Started';
        leadController.myTaskCompCtrler.taskID.ActivityDate = null;
        leadController.myCompCtrler.sendOwnerEmail = false;
        
        leadController.convertLead();
        
        Test.stopTest();
    }
    //6.2
    private static testMethod void testAccSuggestionResponseError(){
        Test.startTest();
        string strError;
        string strResponse;
        AccountSuggestionResponse response;
        LeadTestData.iNumberOfLeads = 1;
        leadTestData.bCreate = true;
        LeadTestData.createDirectLead2();
        list<Lead> listLeads = LeadTestData.lstLeads;
        

        
        ApexPages.StandardController stdController = new ApexPages.StandardController(listLeads[0]);
        LeadConvertPageCtrl leadController = new LeadConvertPageCtrl(stdController);
        
        strResponse = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"> <s:Body> <CreateAccountResponse xmlns="CIL"> <CreateAccountResult i:type="b:TxRemarks" xmlns:b="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common" xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:a="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common.Response"> <a:CommonSearchResponse> <a:CommonSearchResponseBObj i:type="c:AccountBasicSearchResponseBObj" xmlns:c="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Account.Response"> <c:AE>Allen, Bertram Leon Jr.</c:AE> <c:AccountGroupExt> <c:AccountGroupExtBObj> <c:GroupDescription>AMER US FED VAR Channel</c:GroupDescription> </c:AccountGroupExtBObj> </c:AccountGroupExt> <c:AccountId>2725316733</c:AccountId> <c:AccountName>test email</c:AccountName> <c:AccountStatus>REVIEW</c:AccountStatus> <c:AccountType>ACCOUNT</c:AccountType> <c:Country>US</c:Country> <c:DMU>Y</c:DMU> <c:ISR>Silveira, Mateus do Nascimento</c:ISR> <c:IsOutOfBusiness>N</c:IsOutOfBusiness> </a:CommonSearchResponseBObj> </a:CommonSearchResponse> <b:MDMError><b:Message>You cannot create suggestion that belong to a different region</b:Message></b:MDMError><b:Requester>Authenticated User</b:Requester> <b:TxStatusCode>SUCCESS</b:TxStatusCode> </CreateAccountResult> </CreateAccountResponse> </s:Body> </s:Envelope>';
        response = AccountSuggestionResponse.parseResponseString(strResponse);
        
        strError = leadController.checkAndReturnResponseError(response);        
        //'Account cannot be created since the record owner, country or territory are in different regions. Please choose a combination on the same region.'
        System.assert(strError.contains(System.Label.LM2_Wrong_Combination)); //v9.0
        
        strResponse = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"> <s:Body> <CreateAccountResponse xmlns="CIL"> <CreateAccountResult i:type="b:TxRemarks" xmlns:b="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common" xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:a="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common.Response"> <a:CommonSearchResponse> <a:CommonSearchResponseBObj i:type="c:AccountBasicSearchResponseBObj" xmlns:c="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Account.Response"> <c:AE>Allen, Bertram Leon Jr.</c:AE> <c:AccountGroupExt> <c:AccountGroupExtBObj> <c:GroupDescription>AMER US FED VAR Channel</c:GroupDescription> </c:AccountGroupExtBObj> </c:AccountGroupExt> <c:AccountId>2725316733</c:AccountId> <c:AccountName>test email</c:AccountName> <c:AccountStatus>REVIEW</c:AccountStatus> <c:AccountType>ACCOUNT</c:AccountType> <c:Country>US</c:Country> <c:DMU>Y</c:DMU> <c:ISR>Silveira, Mateus do Nascimento</c:ISR> <c:IsOutOfBusiness>N</c:IsOutOfBusiness> </a:CommonSearchResponseBObj> </a:CommonSearchResponse> <b:MDMError><b:Message>Legacy Id is already associated with different account</b:Message></b:MDMError><b:Requester>Authenticated User</b:Requester> <b:TxStatusCode>SUCCESS</b:TxStatusCode> </CreateAccountResult> </CreateAccountResponse> </s:Body> </s:Envelope>';
        response = AccountSuggestionResponse.parseResponseString(strResponse);
        
        strError = leadController.checkAndReturnResponseError(response);   
        //'Kindly recreate new lead and convert again. You may clone this lead and proceed your lead conversion.'
        System.assert(strError.contains(System.Label.LM2_Recreate_Lead));// v9.0
        
        strResponse = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"> <s:Body> <CreateAccountResponse xmlns="CIL"> <CreateAccountResult i:type="b:TxRemarks" xmlns:b="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common" xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:a="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common.Response"> <a:CommonSearchResponse> <a:CommonSearchResponseBObj i:type="c:AccountBasicSearchResponseBObj" xmlns:c="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Account.Response"> <c:AE>Allen, Bertram Leon Jr.</c:AE> <c:AccountGroupExt> <c:AccountGroupExtBObj> <c:GroupDescription>AMER US FED VAR Channel</c:GroupDescription> </c:AccountGroupExtBObj> </c:AccountGroupExt> <c:AccountId>2725316733</c:AccountId> <c:AccountName>test email</c:AccountName> <c:AccountStatus>REVIEW</c:AccountStatus> <c:AccountType>ACCOUNT</c:AccountType> <c:Country>US</c:Country> <c:DMU>Y</c:DMU> <c:ISR>Silveira, Mateus do Nascimento</c:ISR> <c:IsOutOfBusiness>N</c:IsOutOfBusiness> </a:CommonSearchResponseBObj> </a:CommonSearchResponse> <b:MDMError><b:Message>Suggestion submitter RRID/BadgeNumber is Invalid</b:Message></b:MDMError><b:Requester>Authenticated User</b:Requester> <b:TxStatusCode>SUCCESS</b:TxStatusCode> </CreateAccountResult> </CreateAccountResponse> </s:Body> </s:Envelope>';
        response = AccountSuggestionResponse.parseResponseString(strResponse);
        
        strError = leadController.checkAndReturnResponseError(response); 
        //System.assertEquals(strError, 'The record owner you designated in a prior step is not available in Affinity or properly setup in SFDC, the badge number is invalid. Please, choose a different user or raise a trouble ticket to ensure that user has a correct badge number in the profile');
        System.assert(strError.contains(System.Label.LM2_Owner_Error)); //v9.0
        
        strResponse = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"> <s:Body> <CreateAccountResponse xmlns="CIL"> <CreateAccountResult i:type="b:TxRemarks" xmlns:b="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common" xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:a="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Common.Response"> <a:CommonSearchResponse> <a:CommonSearchResponseBObj i:type="c:AccountBasicSearchResponseBObj" xmlns:c="http://schemas.datacontract.org/2004/07/DELL.HT.BusinessModel.Account.Response"> <c:AE>Allen, Bertram Leon Jr.</c:AE> <c:AccountGroupExt> <c:AccountGroupExtBObj> <c:GroupDescription>AMER US FED VAR Channel</c:GroupDescription> </c:AccountGroupExtBObj> </c:AccountGroupExt> <c:AccountId>2725316733</c:AccountId> <c:AccountName>test email</c:AccountName> <c:AccountStatus>REVIEW</c:AccountStatus> <c:AccountType>ACCOUNT</c:AccountType> <c:Country>US</c:Country> <c:DMU>Y</c:DMU> <c:ISR>Silveira, Mateus do Nascimento</c:ISR> <c:IsOutOfBusiness>N</c:IsOutOfBusiness> </a:CommonSearchResponseBObj> </a:CommonSearchResponse> <b:MDMError><b:Message>Other sample test error</b:Message></b:MDMError><b:Requester>Authenticated User</b:Requester> <b:TxStatusCode>SUCCESS</b:TxStatusCode> </CreateAccountResult> </CreateAccountResponse> </s:Body> </s:Envelope>';
        response = AccountSuggestionResponse.parseResponseString(strResponse);
        
        strError = leadController.checkAndReturnResponseError(response);        
        System.assertEquals(strError, 'Other sample test error');
        
        
        Test.stopTest();
    }
    
    //6.2
    private static testMethod void myLeadConversionWithNewAccount() {
        
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();
        Profile userProfile= [select id,name from profile where name like '%GBL Sales Rep%' order by name limit 1 ];
        User user = new User( Username='test' +System.currentTimeMillis() + '@test.com',
                                Alias = 'test'+056, 
                                Email='test'+ 012 +'@dell.com', 
                                FirstName='Tfirst'+0, 
                                LastName='TLast'+09,
                                Title = 'Channel_Test_User',
                                ProfileId = userProfile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c=String.valueOf(Math.round(Math.random()*1000000000)) + '00' + system.now().millisecond());

        insert user;
        Account newAccount = [select id,name from Account where Name = 'Dell Internal_01' LIMIT 1];
        
        country__c country =[SELECT Id,Name,region__c,Is_Active_in_Affinity__c  FROM country__c WHERE Name='TestLeadConversion-Contry 1' LIMIT 1];

        
        Sales_Channel_Group__c testSalesChannelRecord = new Sales_Channel_Group__c
            (Name='Test - SC Record 11', 
             Group_ID__c=''+System.currentTimeMillis()
            );
        insert testSalesChannelRecord;
        
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        
        
        ContactTestData.iNumberOfContacts = 1;
        ContactTestData.createContact();
        list<Contact> lstContacts = ContactTestData.lstContacts;
        
        
        lstContacts[0].Accountid = newAccount.id;
        update lstContacts;
        
        Lead newLead = lstLeads[0];
        newlead.ownerid = user.id;      
        newlead.company = '测试公司';
        newLead.Street='地址栏1';
        newLead.City='地址栏2';
        newLead.State='地址栏3';
        newLead.PostalCode='六千';
        newLead.Country='test1';
        newLead.Territory_Assignment__c = testSalesChannelRecord.id;
        update newLead;

        // Start Testing

        ApexPages.StandardController stdController = new ApexPages.StandardController(newLead);
        LeadConvertPageCtrl leadController = new LeadConvertPageCtrl(stdController);
        
        leadcontroller.leadToConvert = newLead;
        
        leadController.getMyComponentController();
        //leadController.getmyDescriptionComponentController();
        leadController.getmyTaskComponentController();
        leadController.getThis();
        
        // Initialize PageControllerBase
        PageControllerBase pgBase = new PageControllerBase();
        pgBase.getMyComponentController();
        pgBase.getmyDescriptionComponentController();
        pgBase.getmyTaskComponentController();
        pgBase.getThis();
        pgBase.getmyReminderComponentController();
        
        // Initialize ComponentControllerBase
        ComponentControllerBase compBase = new ComponentControllerBase();
        compBase.pageController = pgBase;
        compBase.pageControllerDescription = pgBase;
        compBase.pageControllerReminder = pgBase;
        compBase.pageControllerTask = pgBase;
        
        // Test myCompCtrler is null.
        leadController.convertLead();
        
        leadController.setComponentController(new leadConvertCoreComponentController());
        leadController.setTaskComponentController(new leadConvertTaskInfoComponentController());
        System.assert(leadController.myTaskCompCtrler != null);
        
        // Test Account Name: Please select an Account.
        leadController.myCompCtrler.selectedAccount = 'NONE';
        leadController.convertLead();
        
        leadController.myCompCtrler.selectedAccount ='NEW';
        leadController.myCompCtrler.selectedContact ='NEW';
        leadController.populateMDMFields(newAccount);
        
        leadController.convertLead();
        
        // Test Opportunity Name: You must enter a value.
        //6.0
        leadController.myCompCtrler.oppty = 'New';
        leadController.convertLead();
        //6.0
        leadController.myCompCtrler.oppty = 'Default';
        
        // Test Converted Status: Please select a Lead Status.
        leadController.myCompCtrler.leadConvert = newLead;
        
        leadController.myCompCtrler.selectedAccount ='NEW';
        leadController.myCompCtrler.selectedContact ='NEW';
        //6.2 set to new oppty to cover some missing part
        leadController.myCompCtrler.oppty = 'New';
        leadController.myCompCtrler.opportunityName = 'Test Oppty';
        leadController.myCompCtrler.sendOwnerEmail = false;
        
        leadController.myCompCtrler.leadConvert.Physical_Country__c=country.Id;
        leadController.myCompCtrler.leadConvert.Country=country.Name;
        leadController.convertLead();
        
        leadController.myCompCtrler.leadConvert.ownerid = user.id;
        leadController.convertLead();  
        
        leadController.myCompCtrler.leadConvert.Country=country.Name;
        leadController.convertLead(); 
        
        leadController.myCompCtrler.leadConvert.Territory_Assignment__c = testSalesChannelRecord.id;
        leadController.convertLead();
        
        //for test coverage if selectedAccountId is no nothing
        leadController.myCompCtrler.leadConvert.Company = 'Test Company';
        leadController.convertLead();
        
        //Expected a Street Double Byte Error, So changing the Street name to English
        leadController.myCompCtrler.leadConvert.Street='Test Street';
        leadController.convertLead();
        
        //Expected a City Double Byte Error, So changing the City name to English
        leadController.myCompCtrler.leadConvert.City='Test City';
        leadController.convertLead();
       
        //Expected a state Double Byte Error, So changing the state name to English
        leadController.myCompCtrler.leadConvert.State='Test State';
        leadController.convertLead();
        
        //Expected a Postal Code Double Byte Error, So changing the City name to Numbers
        leadController.myCompCtrler.leadConvert.PostalCode='6000';
        leadController.convertLead();      
    }

     private static testMethod void myLeadConversionWithDoubleByte() {
        
        TriggerExecutionController.setSkipAllTriggers(true);
        country__c country =[SELECT Id,Name,region__c,Is_Active_in_Affinity__c FROM country__c WHERE Name='CHINA' LIMIT 1];
        
        Sales_Channel_Group__c testSalesChannelRecord = new Sales_Channel_Group__c
            (Name='Test - SC Record 11', 
             Group_ID__c=''+System.currentTimeMillis()
            );
        insert testSalesChannelRecord;
        // Start Testing
        Test.startTest();
        Profile userProfile= [select id,name from profile where name like '%GBL Sales Rep%' order by name limit 1 ];
        User user = new User( Username='test' +System.currentTimeMillis() + '@test.com',
                             Alias = 'test'+056, 
                             Email='test'+ 012 +'@dell.com', 
                             FirstName='Tfirst'+0, 
                             LastName='TLast'+09,
                             Title = 'Channel_Test_User',
                             ProfileId = userProfile.Id, 
                             LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', 
                             EmailEncodingKey='UTF-8', 
                             TimeZoneSidKey='America/Los_Angeles',
                             HR_Location_Country_Desc__c='CHINA',
                             Badge_Number__c='leadCon' + system.now().millisecond());
        
        insert user;
        User admin=[select id,Name,isActive from User where Profile.name='System Administrator' and isActive=true limit 1];
        
        Account newAccount = [select id,name from Account where Name = 'Dell Internal_01' LIMIT 1];
        
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        
        
        ContactTestData.iNumberOfContacts = 1;
        ContactTestData.createContact();
        list<Contact> lstContacts = ContactTestData.lstContacts;
        
        
        lstContacts[0].Accountid = newAccount.id;
        update lstContacts;
                
        Lead newLead = lstLeads[0];
        newlead.ownerid = user.id;
        newLead.company ='这是一个新的测试帐户';      
        //newLead.company ='This is a new account - 12345';
        newLead.Street='測試';
        newLead.City='測試';
        newLead.PostalCode='測試';
        newLead.Country= country.Id;
        newLead.Physical_Country__c = Country.Id;
        newLead.Street_CN__c='測試';
        newLead.City_CN__c='測試';
        newLead.State_Province_CN__c='測試';
        newLead.Zip_Postal_Code_CN__c='測試';
        newLead.Sales_Follow_up_days__c=null;
        newLead.Territory_Assignment__c = testSalesChannelRecord.id;
        
        update newLead;        
        
        System.runAs(user) {
            ApexPages.StandardController stdController = new ApexPages.StandardController(newLead);
            LeadConvertPageCtrl leadController = new LeadConvertPageCtrl(stdController);
            
            leadcontroller.leadToConvert = newLead;
            
            leadController.getMyComponentController();
            leadController.getmyTaskComponentController();
            leadController.getThis();
            
            // Initialize PageControllerBase
            PageControllerBase pgBase = new PageControllerBase();
            pgBase.getMyComponentController();
            pgBase.getmyDescriptionComponentController();
            pgBase.getmyTaskComponentController();
            pgBase.getThis();
            pgBase.getmyReminderComponentController();
            
            // Initialize ComponentControllerBase
            ComponentControllerBase compBase = new ComponentControllerBase();
            compBase.pageController = pgBase;
            compBase.pageControllerDescription = pgBase;
            compBase.pageControllerReminder = pgBase;
            compBase.pageControllerTask = pgBase;
            
            
            leadController.setComponentController(new leadConvertCoreComponentController());
            leadController.setTaskComponentController(new leadConvertTaskInfoComponentController());
            System.assert(leadController.myTaskCompCtrler != null);
            
            // Test Account Name: Please select an Account.
            leadController.myCompCtrler.selectedAccount = 'NONE';
            
            leadController.myCompCtrler.selectedAccount ='NEW';
            leadController.myCompCtrler.selectedContact ='NEW';
            
            leadController.myCompCtrler.leadConvert = newLead;
            
            leadController.myCompCtrler.selectedAccount ='NEW';
            leadController.myCompCtrler.selectedContact ='NEW';
            //6.2 set to new oppty to cover some missing part
            leadController.myCompCtrler.oppty = 'New';
            leadController.myCompCtrler.opportunityName = 'Test Oppty';
            leadController.myCompCtrler.sendOwnerEmail = false;
            leadController.myCompCtrler.leadConvert.Physical_Country__c=country.Id;
            leadController.myCompCtrler.leadConvert.Country=country.Name;
            leadController.myCompCtrler.leadConvert.ownerid = user.id;

            leadController.convertLead();
            
            leadController.myCompCtrler.leadConvert.Country_CN__c = country.Name;
            leadController.convertLead();
                        
            //Expected a Company Double Byte Error, So changing the company name to English
            leadController.myCompCtrler.leadConvert.company ='This is a new account - 12345';
            leadController.convertLead();
            
            //Expected a Street Double Byte Error, So changing the Street name to English
            leadController.myCompCtrler.leadConvert.Street_CN__c='Test China Street';
            leadController.convertLead();

            //Expected a City Double Byte Error, So changing the City name to English
            leadController.myCompCtrler.leadConvert.City_CN__c ='Test China City';
            leadController.convertLead();
            
            //Expected a State Double Byte Error, So changing the State name to English
            leadController.myCompCtrler.leadConvert.State_Province_CN__c='Test China State';
            leadController.convertLead();
            
            //Expected a Postal Code Double Byte Error, So changing the City name to Numbers
            leadController.myCompCtrler.leadConvert.Zip_Postal_Code_CN__c='6000';
            leadController.convertLead();
            
            
            leadController.populateMDMFields(newAccount);
        }
        Test.stopTest();     
    }
    
    //11.0
    private static testMethod void leadConversionWithNewJapanAccount() {
        TriggerExecutionController.setSkipAllTriggers(true);
        Test.startTest();
        Profile userProfile= [select id,name from profile where name like '%GBL Sales Rep%' order by name limit 1 ];
        User user = new User( Username='test' +System.currentTimeMillis() + '@test.com',
                                Alias = 'test'+056, 
                                Email='test'+ 012 +'@dell.com', 
                                FirstName='Tfirst'+0, 
                                LastName='TLast'+09,
                                Title = 'Sales_Test_User',
                                ProfileId = userProfile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c=String.valueOf(Math.round(Math.random()*1000000000)) + '00' + system.now().millisecond());

        insert user;
        Account newAccount = [select id,name from Account where Name = 'Dell Internal_01' LIMIT 1];
        
        country__c cntry = new country__c(Name='JAPAN', Code__c='JP',region__c='APJ',Is_Active_in_Affinity__c=true);
        insert cntry;
        country__c country =[SELECT Id,Name,region__c,Is_Active_in_Affinity__c  FROM country__c WHERE Id=:cntry.Id LIMIT 1];

        
        Sales_Channel_Group__c testSalesChannelRecord = new Sales_Channel_Group__c
            (Name='Test - SC Record 11', 
             Group_ID__c=''+System.currentTimeMillis()
            );
        insert testSalesChannelRecord;
        
        LeadTestData.iNumberOfLeads = 1;
        LeadTestData.createDirectLead2();
        list<Lead> lstLeads = LeadTestData.lstLeads;
        
        ContactTestData.iNumberOfContacts = 1;
        ContactTestData.createContact();
        list<Contact> lstContacts = ContactTestData.lstContacts;
        
        lstContacts[0].Accountid = newAccount.id;
        update lstContacts;
        
        Lead newLead = lstLeads[0];
        newlead.ownerid = user.id;      
        newlead.company = 'Kozue';
        newLead.Street='3 Chome−7−1−２';
        newLead.City='Nishishinjuku';
        newLead.State='Tokyo';
        newLead.PostalCode='160-0023';
        newLead.Country='JAPAN';
        newLead.Territory_Assignment__c = testSalesChannelRecord.id;
        update newLead;

        // Start Testing

        ApexPages.StandardController stdController = new ApexPages.StandardController(newLead);
        LeadConvertPageCtrl leadController = new LeadConvertPageCtrl(stdController);
        
        leadcontroller.leadToConvert = newLead;
        
        leadController.getMyComponentController();
        leadController.getmyTaskComponentController();
        leadController.getThis();
        
        // Initialize PageControllerBase
        PageControllerBase pgBase = new PageControllerBase();
        pgBase.getMyComponentController();
        pgBase.getmyDescriptionComponentController();
        pgBase.getmyTaskComponentController();
        pgBase.getThis();
        pgBase.getmyReminderComponentController();
        
        // Initialize ComponentControllerBase
        ComponentControllerBase compBase = new ComponentControllerBase();
        compBase.pageController = pgBase;
        compBase.pageControllerDescription = pgBase;
        compBase.pageControllerReminder = pgBase;
        compBase.pageControllerTask = pgBase;
        
        // Test myCompCtrler is null.
        leadController.convertLead();
        
        leadController.setComponentController(new leadConvertCoreComponentController());
        leadController.setTaskComponentController(new leadConvertTaskInfoComponentController());
        System.assert(leadController.myTaskCompCtrler != null);
        
        // Test Account Name: Please select an Account.
        leadController.myCompCtrler.selectedAccount = 'NONE';
        leadController.convertLead();
        
        leadController.myCompCtrler.selectedAccount ='NEW';
        leadController.myCompCtrler.selectedContact ='NEW';
        leadController.populateMDMFields(newAccount);
        
        leadController.convertLead();
        
        // Test Opportunity Name: You must enter a value.
        //6.0
        leadController.myCompCtrler.oppty = 'New';
        leadController.convertLead();
        //6.0
        leadController.myCompCtrler.oppty = 'Default';
        
        // Test Converted Status: Please select a Lead Status.
        leadController.myCompCtrler.leadConvert = newLead;
        
        leadController.myCompCtrler.selectedAccount ='NEW';
        leadController.myCompCtrler.selectedContact ='NEW';
        //6.2 set to new oppty to cover some missing part
        leadController.myCompCtrler.oppty = 'New';
        leadController.myCompCtrler.opportunityName = 'Test Oppty';
        leadController.myCompCtrler.sendOwnerEmail = false;
        
        leadController.myCompCtrler.leadConvert.Physical_Country__c=country.Id;
        leadController.myCompCtrler.leadConvert.Country_CN__c=country.Name;
        leadController.convertLead();
        
        leadController.myCompCtrler.leadConvert.ownerid = user.id;
        leadController.convertLead();  
        
        leadController.myCompCtrler.leadConvert.Territory_Assignment__c = testSalesChannelRecord.id;
        leadController.convertLead();
        
        //for test coverage if selectedAccountId is no nothing
        leadController.myCompCtrler.leadConvert.Company = 'Kozue';
        leadController.convertLead();
                
        //Populate blank english and local address
        leadController.myCompCtrler.leadConvert.Country = null;
        leadController.myCompCtrler.leadConvert.Legal_Local_Country__c = null;
        leadController.convertLead();
        leadController.myCompCtrler.leadConvert.Legal_Local_Country__c = 'JAPAN';
        leadController.myCompCtrler.leadConvert.Legal_Local_Address_1__c =null ;        
        leadController.convertLead();
        leadController.myCompCtrler.leadConvert.Country = 'JAPAN';
        leadController.myCompCtrler.leadConvert.Street = null;
        leadController.myCompCtrler.leadConvert.Legal_Local_City__c = null;
        leadController.myCompCtrler.leadConvert.City = null;
        leadController.convertLead();
        leadController.myCompCtrler.leadConvert.Legal_Local_Postal_Code__c = null;
        leadController.myCompCtrler.leadConvert.PostalCode = null;
        leadController.convertLead();
        
        cntry.Is_Active_in_Affinity__c = false;
        update cntry;
        leadController.myCompCtrler.leadConvert.Country = 'JAPAN';
        leadController.convertLead();
                        
        Test.stopTest(); 
    } 

  

//13.0 starts
    private static testmethod void convertToDatetime(){
                
   
      /*******
        Profile userProfile= [select id,name from profile where name like '%GBL Sales Rep%' order by name limit 1 ];
        User user = new User( Username='test' +System.currentTimeMillis() + '@test.com',
                             Alias = 'test'+056, 
                             Email='test'+ 012 +'@dell.com', 
                             FirstName='Tfirst'+0, 
                             LastName='TLast'+09,
                             Title = 'Channel_Test_User',
                             ProfileId = userProfile.Id, 
                             LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', 
                             EmailEncodingKey='UTF-8', 
                             TimeZoneSidKey='America/Los_Angeles',
                             HR_Location_Country_Desc__c='CHINA',
                             Badge_Number__c='leadCon' + system.now().millisecond());
        
        insert user;
    ****/
        User user = [SELECT Id,Name,Badge_Number__c FROM User WHERE Badge_Number__c = 'TstLeadCon123456789' LIMIT 1];
        Account newAccount=[SELECT Id,Name FROM Account WHERE Name='Dell Internal_01' LIMIT 1];
        Lead newLead=[SELECT Id,LastName,ownerid,Company,Country FROM Lead Where LastName='TestLeadConversion' LIMIT 1];
        Contact objContact=[SELECT Id, Accountid FROM Contact WHERE LastName = 'TestLeadConversion-Contact 1' LIMIT 1];
        country__c county =[SELECT Id,Name,region__c,Is_Active_in_Affinity__c FROM country__c WHERE Name='CHINA' LIMIT 1];
        Opportunity objOpportunity=[SELECT Id,Name FROM Opportunity WHERE Name='TestLeadConversion-Opp 1' LIMIT 1 ];
      /*****
           system.debug('county#####'+county.Name); 
           system.debug('newLead.Country#####'+newLead.Country);
           system.debug('newLead#####'+newLead);
       list<Country__c> stdCountry=[Select Id,Name from Country__c Where Name =:newLead.Country LIMIT 1];
       system.debug('Country#####'+stdCountry.size());
      ****/ 
        Decimal followup;
        newLead.Contact__c = objContact.id;
        newLead.Account__c = newAccount.id; 
        
        //update newLead;
       newAccount.Account_ID__c = '12345';
       update newAccount;
       //objContact.OwnerId = user.id;
       //update objContact;
        
        Date d = system.today();
        string t = '9:50 am';
        System.runAs(user){
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(newLead);
        LeadConvertPageCtrl leadController = new LeadConvertPageCtrl(stdController);
        //leadController.setComponentController(new leadConvertCoreComponentController());
        leadController.setTaskComponentController(new leadConvertTaskInfoComponentController());
        leadcontroller.leadToConvert = newLead;
        leadController.validateLead();
        leadController.convertLead();
        leadController.goBack();
        leadController.convertToDatetime(d,t);
        
        user.LocaleSidKey = 'en_KY';
        update user;
        string t1 = '9:50';
        leadController.convertToDatetime(d,t1);
        
        string leadid = newLead.id;
        string opptyid = objOpportunity.id;
        leadController.updateLeadWithLinkedOppty(leadid,opptyid);
        TriggerExecutionController.setSkipAllTriggers(true);
        leadController.strPrevStatus = 'New1';
        newLead.Status = 'Reason';
        newLead.Sales_Follow_up_days__c = followup;
        newLead.First_time_assigned_to_Sales__c = system.now();
        newLead.OwnerId = user.id;
        update newLead;
        system.debug('Siva@@@@@'+newLead.Owner.Name);
        leadController.updateLeadWithSalesFollowUpDays(newLead);
        
        //leadController.myCompCtrler.selectedAccount = newAccount.Id;
        //leadController.continueProcess();

        
        }
    Test.stopTest(); 
    TriggerExecutionController.setSkipAllTriggers(false);   
    }
 //13.0 stops   
}
/* ---------------------------------------------------------
* Revision  Name        Date            Release     Description
* 1.0                                               Creation
* 2.0       Meghana     20.12.2013      15.03       OMGO CR 8973 - Remove use of field Verifiable_Outcome__c in Test Methods
* 3.0       Fenny       19-Aug-2015     CSM1102     CR11834 - Insert Services Solutioning Team Member when BOOMI update Support Owner from BLANK to a value 
* 4.0       Fenny       20-Oct-2015     CSM1102     CR 12076 - Redesign the SFDC - MyDeal integration via Boomi to make it real time
************************************************************/

@isTest

private class afterInsertUpdateSupportRequestTest {

	//insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018- START
	@testSetup static void setup() {
		OWD__c OWDsetting = new OWD__c();
		OWDsetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
		OWDsetting.Oppty_Stage10__c = 'Discover - 10%';
		OWDsetting.Oppty_Stage100__c = 'Win - 100%';
		OWDsetting.Oppty_Stage30__c = 'Qualify - 30%';
		OWDsetting.Oppty_Stage60__c = 'Propose - 60%';
		OWDsetting.Oppty_Stage90__c = 'Commit - 90%';
		OWDsetting.Oppty_Stage99__c = 'Order Submitted - 99%';
		OWDsetting.Oppty_Stage1__c = 'Plan - 1%';
		
		insert OWDsetting;
	}	
	//insert Custom Setting for test classes -Afiq FY180203 8 Feb 2018 - END

    // 4.0 - Start
    static testMethod void integrateMyDealTest(){
        TriggerExecutionController.setSkipAllTriggers(true);
        Account acc = new Account(Name='testAccount'); 
        insert acc;
        Blob blobFile=Blob.valueOf('Unit Test Attachment Body');
        Contact con = new Contact(FirstName='test',LastName='Test2',Email='test@dell.com',MailingStreet='test',MailingCity='test',MailingState='test',
                        MailingCountry='test',AccountId=acc.Id,Phone='12345');
        insert con;
        
        Opportunity oppty = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity', RecordTypeId = '012300000004zf2AAA', CurrencyIsoCode = 'USD', Type = 'Renewal',
                                                    CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution',
                                                    StageName = 'Plan - 1%',Quest_Software_Contact__c= con.id);
        insert oppty;
        TriggerExecutionController.setSkipAllTriggers(false);
        
        Test.startTest();
        String CSS_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Custom Service Support', 'Support_Request__c', true);
        Support_Request__c cssSR = new Support_Request__c(RecordTypeId = CSS_RECORDTYPEID, Receive_Notification__c = 'Yes', Opportunity__c = oppty.Id,
                                            Requestor_Comments__c = 'testComment', Specialist_Role__c = 'testRole',Engagement_Time_Frame__c=Date.today(),
                                            Support_Owner__c = UserInfo.getUserId(), Solution_Architect__c = 'Yes', Customer_Contact_InformationName__c = con.Id,
                                            Support_Owner_Team_Role__c = 'Services Intake Manager',Status__c='New',Project_Type__c='CWS',Project_Duration_months__c =1,
                                            Suggested_Delivery_Method__c='Custom',Decision_Date__c=Date.today(),Primary_Work_Delivery_Language__c='Spanish');
        ProcessFlowTriggerController.isTest = true;
        insert cssSR;
        

        //5.0 Start
        ContentVersion testContentInsert =new ContentVersion(); 
        testContentInsert.Title = 'TestFile';
        testContentInsert.VersionData =blobFile;      
        testContentInsert.PathOnClient ='/';     
        testContentInsert.origin = 'H'; 
        insert testContentInsert;     

        ContentVersion testContent = [SELECT id,contentdocumentid FROM ContentVersion where id =:testContentInsert.id];

        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=oppty.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId=testContent.contentdocumentid;
        insert contentlink;

        // This update is to cover code of OpportunityUtilities.pushCustomServiceSupportRequestToMyDeal
        Opportunity oldOpp = [SELECT Id, Contract_Term__c FROM Opportunity WHERE Id = :oppty.Id];
        Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>();
        oldOppMap.put(oldOpp.Id, oldOpp);
        
        oppty.Contract_Term__c = 123;
        Map<Id, Opportunity> newOppMap = new Map<Id, Opportunity>();
        newOppMap.put(oppty.Id, oppty);
        
        OpportunityUtilities.pushCustomServiceSupportRequestToMyDeal(oldOppMap, newOppMap);
        Test.stopTest();
        
        // 4.0 - Because the integration callout is a @future method, so not able to do assert test the result here
    }
    // 4.0 - End
    
    // 3.0 - Start
    static testMethod void insertServicesSolutioningTeamWhenBOOMIInsertSR(){
        CSSR_Pursuit_Support__c pursuitSupp = new CSSR_Pursuit_Support__c(Name = 'Finance', Resource_Type_Name__c = 'Resource Name', Pursuit_Team_Mailbox__c = 'test@test.com');
        insert pursuitSupp;
        
        TriggerExecutionController.setSkipAllTriggers(true);
        User boomi = new User(Username='Test1'+System.currentTimeMillis() +'@dell.com', 
                                Alias = 'Test1', Email='testSalesUser1'+'@dell.com', LastName='Test1', ProfileId = '00eA0000000hNqFIAU', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test1'+System.currentTimeMillis());
        insert boomi;
        
        Account acc = new Account(Name='testAccount');     
        
        Opportunity oppty = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity', RecordTypeId = '012300000004zf2AAA', CurrencyIsoCode = 'USD', Type = 'Renewal',
                                                    CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution',
                                                    StageName = 'Plan - 1%');
        
        // RT = Request Custom Service Support
        // Has Support Owner when insert Support Request
        // User is boomi user
        Support_Request__c cssSR = new Support_Request__c(RecordTypeId = '012700000005e26AAA', Receive_Notification__c = 'Yes',
                                            Requestor_Comments__c = 'testComment', Specialist_Name__c = UserInfo.getUserId(), Specialist_Role__c = 'testRole',
                                            Support_Owner__c = UserInfo.getUserId(), Services_Finance_Support__c = 'Yes', Pricing_Cycle_Status__c = 'Preliminary/indicative pricing', 
                                            HW_SW_or_other_Financing_Dell_owned__c = 'Yes', Customer_Pricing_Due_Date__c = system.today(), Support_Owner_Team_Role__c = 'Services Intake Manager');
        
        
        system.runAs(boomi){
            insert acc; 
            insert oppty;
            Contact testCont = new Contact();
            testCont.FirstName='test';
            testCont.LastName='Test2';
            testCont.Email='test@dell.com';
            testCont.MailingStreet='test';
            testCont.MailingCity='test';
            testCont.MailingState='test';
            testCont.MailingCountry='test';
            testCont.phone = '11211211';
            testCont.MobilePhone = '1211121';
            testCont.Eloqua_ID__c = '1';
            testCont.AccountId=acc.id;
            insert testCont;
            TriggerExecutionController.setSkipAllTriggers(false);
            
            cssSR.Opportunity__c = oppty.Id;
            insert cssSR;
        }
        Integer recordCount = [SELECT Count() FROM Services_Solutioning_Team__c WHERE Support_Request_ID__c = :cssSR.Id AND Solution_Team_Role__c = 'Services Intake Manager' AND Solution_Team_Member__c = :UserInfo.getUserId()];
        system.assert(recordCount > 0);
        
        Test.startTest();
        
        // RT = Request Specialist Support
        // Has Support Owner when insert Support Request
        // User is boomi user
        Support_Request__c specialistSR2 = new Support_Request__c(RecordTypeId = '012A0000000ViNJIA0', Opportunity__c = oppty.Id, Receive_Notification__c = 'Yes',
                                            Requestor_Comments__c = 'testComment', Specialist_Name__c = UserInfo.getUserId(), Specialist_Role__c = 'testRole',
                                            Support_Owner__c = UserInfo.getUserId(), Support_Owner_Team_Role__c = 'Services Intake Manager');
        system.runAs(boomi){
            insert specialistSR2;
        }
        recordCount = [SELECT Count() FROM Services_Solutioning_Team__c WHERE Support_Request_ID__c = :specialistSR2.Id AND Solution_Team_Role__c = 'Services Intake Manager' AND Solution_Team_Member__c = :UserInfo.getUserId()];
        system.assert(recordCount == 0);

        Test.stopTest();
    } // 3.0 - End

    // 3.0 - Start
    static testMethod void insertServicesSolutioningTeamWhenBOOMIUpdateSupportOwner(){
        CSSR_Pursuit_Support__c pursuitSupp = new CSSR_Pursuit_Support__c(Name = 'Finance', Resource_Type_Name__c = 'Resource Name', Pursuit_Team_Mailbox__c = 'test@test.com');
        insert pursuitSupp;
        
        TriggerExecutionController.setSkipAllTriggers(true);
        User boomi = new User(Username='Test1'+System.currentTimeMillis() +'@dell.com', 
                                Alias = 'Test1', Email='testSalesUser1'+'@dell.com', LastName='Test1', ProfileId = '00eA0000000hNqFIAU', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test1'+System.currentTimeMillis());
        insert boomi;
        
        Account acc = new Account(Name='testAccount');     
        
        Opportunity oppty = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity', RecordTypeId = '012300000004zf2AAA', CurrencyIsoCode = 'USD', Type = 'Renewal',
                                                    CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution',
                                                    StageName = 'Plan - 1%');
        
        // RT = Request Custom Service Support
        // Has Support Owner when insert Support Request, but Support Owner Team Role != Services Intake Manager
        // User is boomi user       
        Support_Request__c cssSR = new Support_Request__c(RecordTypeId = '012700000005e26AAA', Opportunity__c = oppty.Id, Receive_Notification__c = 'Yes',
                                            Requestor_Comments__c = 'testComment', Specialist_Name__c = UserInfo.getUserId(), Specialist_Role__c = 'testRole', Services_Finance_Support__c = 'Yes', Pricing_Cycle_Status__c = 'Preliminary/indicative pricing', 
                                            HW_SW_or_other_Financing_Dell_owned__c = 'Yes', Customer_Pricing_Due_Date__c = system.today(),
                                            Support_Owner__c = UserInfo.getUserId(), Support_Owner_Team_Role__c = 'Alliance Account Executive');
        system.runAs(boomi){
            insert acc; 
            insert oppty;
            TriggerExecutionController.setSkipAllTriggers(false);

            cssSR.Opportunity__c = oppty.Id;
            insert cssSR;
        }
        Integer recordCount = [SELECT Count() FROM Services_Solutioning_Team__c WHERE Support_Request_ID__c = :cssSR.Id AND Solution_Team_Role__c = 'Services Intake Manager' AND Solution_Team_Member__c = :UserInfo.getUserId()];
        system.assert(recordCount == 0);
        
        // RT = Request Custom Service Support
        // No Support Owner when insert Support Request, but later update to have Support Owner. After that, update once again the Support Request record
        // User is boomi user
        Support_Request__c cssSR2 = new Support_Request__c(RecordTypeId = '012700000005e26AAA', Opportunity__c = oppty.Id, Receive_Notification__c = 'Yes',
                                            Requestor_Comments__c = 'testComment', Specialist_Name__c = UserInfo.getUserId(), Specialist_Role__c = 'testRole', Services_Finance_Support__c = 'Yes', Pricing_Cycle_Status__c = 'Preliminary/indicative pricing', 
                                            HW_SW_or_other_Financing_Dell_owned__c = 'Yes', Customer_Pricing_Due_Date__c = system.today());
        system.runAs(boomi){
            insert cssSR2;
        }
        recordCount = [SELECT Count() FROM Services_Solutioning_Team__c WHERE Support_Request_ID__c = :cssSR2.Id AND Solution_Team_Role__c = 'Services Intake Manager' AND Solution_Team_Member__c = :UserInfo.getUserId()];
        system.assert(recordCount == 0);
        
        Test.startTest();
        
        cssSR2.Support_Owner__c = UserInfo.getUserId();
        cssSR2.Support_Owner_Team_Role__c = 'Services Intake Manager';
        system.runAs(boomi){
            update cssSR2;
        }
        Integer recordCount2 = [SELECT Count() FROM Services_Solutioning_Team__c WHERE Support_Request_ID__c = :cssSR2.Id AND Solution_Team_Role__c = 'Services Intake Manager' AND Solution_Team_Member__c = :UserInfo.getUserId()];
        system.assert(recordCount2 > 0);
        
        cssSR2.Comments__c = 'Testing on inserting services solutioning team';
        system.runAs(boomi){
            update cssSR2;
        }
        recordCount = [SELECT Count() FROM Services_Solutioning_Team__c WHERE Support_Request_ID__c = :cssSR2.Id AND Solution_Team_Role__c = 'Services Intake Manager' AND Solution_Team_Member__c = :UserInfo.getUserId()];
        system.assert(recordCount == recordCount2);

        // RT = Request Custom Service Support
        // No Support Owner when insert Support Request, later update to have Support Owner
        // BUT, the Servies Solutioning TEam record already exists
        // User is boomi user
        Support_Request__c cssSR4 = new Support_Request__c(RecordTypeId = '012700000005e26AAA', Opportunity__c = oppty.Id, Receive_Notification__c = 'Yes',
                                            Requestor_Comments__c = 'testComment', Specialist_Name__c = UserInfo.getUserId(), Specialist_Role__c = 'testRole', Services_Finance_Support__c = 'Yes', Pricing_Cycle_Status__c = 'Preliminary/indicative pricing', 
                                            HW_SW_or_other_Financing_Dell_owned__c = 'Yes', Customer_Pricing_Due_Date__c = system.today());
        system.runAs(boomi){
            insert cssSR4;
        }

        Services_Solutioning_Team__c team = new Services_Solutioning_Team__c(Solution_Team_Member__c = UserInfo.getUserId(), Solution_Team_Role__c = 'Services Intake Manager', 
                                                                                Support_Request_ID__c = cssSR4.Id);
        insert team;
        
        cssSR4.Support_Owner__c = UserInfo.getUserId();
        cssSR4.Support_Owner_Team_Role__c = 'Services Intake Manager';
        system.runAs(boomi){
            update cssSR4;
        }
        List<Services_Solutioning_Team__c> teams = [SELECT Id FROM Services_Solutioning_Team__c WHERE Support_Request_ID__c = :cssSR4.Id AND Solution_Team_Role__c = 'Services Intake Manager' AND Solution_Team_Member__c = :UserInfo.getUserId()];
        system.assert(teams.size() == 1);
        system.assert(team.Id == teams[0].Id);
        
        Test.stopTest();
    } // 3.0 - End

    // 3.0 - Start
    static testMethod void insertServicesSolutioningTeamWhenNonBOOMIInsertSR(){
        CSSR_Pursuit_Support__c pursuitSupp = new CSSR_Pursuit_Support__c(Name = 'Finance', Resource_Type_Name__c = 'Resource Name', Pursuit_Team_Mailbox__c = 'test@test.com');
        insert pursuitSupp;
        
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        TriggerExecutionController.setSkipAllTriggers(true);
        User boomi = new User(Username='Test1'+System.currentTimeMillis() +'@dell.com', 
                                Alias = 'Test1', Email='testSalesUser1'+'@dell.com', LastName='Test1', ProfileId = '00eA0000000hNqFIAU', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', EmailEncodingKey='UTF-8', TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test1'+System.currentTimeMillis());
        insert boomi;
        
        Account acc = new Account(Name='testAccount'); 
        insert acc;
        Contact testCont = new Contact();
            testCont.FirstName='test';
            testCont.LastName='Test2';
            testCont.Email='test@dell.com';
            testCont.MailingStreet='test';
            testCont.MailingCity='test';
            testCont.MailingState='test';
            testCont.MailingCountry='test';
            testCont.phone = '11211211';
            testCont.MobilePhone = '1211121';
            testCont.Eloqua_ID__c = '1';
            testCont.AccountId=acc.id;
            insert testCont;
              
        
        Opportunity oppty = new Opportunity(AccountId = acc.Id, Name = 'testOpportunity', RecordTypeId = '012300000004zf2AAA', CurrencyIsoCode = 'USD', Type = 'Renewal',
                                                    CloseDate = system.Today(), Domain__c = 'Non Domain', Solution_Type__c = 'Cloud Integration', Solution_Name__c = 'Boomi Solution',
                                                    StageName = 'Plan - 1%',Quest_Software_Contact__c= testCont.id);
         
        insert oppty;
        
        TriggerExecutionController.setSkipAllTriggers(false);
        Test.startTest();
        
        // RT = Request Custom Service Support
        // Has Support Owner when insert Support Request
        // Not boomi user
        Support_Request__c cssSR3 = new Support_Request__c(RecordTypeId = '012700000005e26AAA', Opportunity__c = oppty.Id, Receive_Notification__c = 'Yes',
                                            Requestor_Comments__c = 'testComment', Specialist_Name__c = boomi.Id, Specialist_Role__c = 'testRole',
                                            Support_Owner__c = UserInfo.getUserId(), Services_Finance_Support__c = 'Yes', Pricing_Cycle_Status__c = 'Preliminary/indicative pricing', 
                                            HW_SW_or_other_Financing_Dell_owned__c = 'Yes', Customer_Pricing_Due_Date__c = system.today(), Support_Owner_Team_Role__c = 'Services Intake Manager');
        system.runAs(currentUser){
            insert cssSR3;
        }
        Integer recordCount = [SELECT Count() FROM Services_Solutioning_Team__c WHERE Support_Request_ID__c = :cssSR3.Id AND Solution_Team_Role__c = 'Services Intake Manager' AND Solution_Team_Member__c = :UserInfo.getUserId()];
        system.assert(recordCount == 0);
        
        // RT = Request Specialist Support
        // Has Support Owner when insert Support Request
        // Not boomi user 
        Support_Request__c specialistSR = new Support_Request__c(RecordTypeId = '012A0000000ViNJIA0', Opportunity__c = oppty.Id, Receive_Notification__c = 'Yes',
                                            Requestor_Comments__c = 'testComment', Specialist_Name__c = boomi.Id, Specialist_Role__c = 'testRole',
                                            Support_Owner__c = UserInfo.getUserId(), Support_Owner_Team_Role__c = 'Services Intake Manager');
        system.runAs(currentUser){
            insert specialistSR;
        }
        recordCount = [SELECT Count() FROM Services_Solutioning_Team__c WHERE Support_Request_ID__c = :specialistSR.Id AND Solution_Team_Role__c = 'Services Intake Manager' AND Solution_Team_Member__c = :UserInfo.getUserId()];
        system.assert(recordCount == 0);
        
        Test.stopTest();
    } // 3.0 - End
    
    static testMethod void afterInsertUpdateSupportRequestTest() {
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%GBL Sales Rep' ORDER BY Name DESC LIMIT 1];
        List<User> testUser = new List<User>();
        Support_Request__c testSR = new Support_Request__c();
        
        testUser.add(new User(Username='testSalesUser1'+System.currentTimeMillis()+'@dell.com',
                                Alias = 'Test1', 
                                Email='testSalesUser1'+'@dell.com',            
                                LastName='Test1',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test1'+System.currentTimeMillis()));
                                    
        testUser.add(new User(Username='testSalesUser2'+System.currentTimeMillis()+'@dell.com',
                                Alias = 'Test2', 
                                Email='testSalesUser2'+'@dell.com',            
                                LastName='Test2',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test2'+System.currentTimeMillis()));
                                
        testUser.add(new User(Username='testSalesUser3'+System.currentTimeMillis()+'@dell.com',
                                Alias = 'Test3', 
                                Email='testSalesUser3'+'@dell.com',            
                                LastName='Test3',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test3'+System.currentTimeMillis()));                       
        
        TriggerExecutionController.setSkipAllTriggers(true);
        insert testUser;
        
        System.runAs(testUser[0]){
            Account testAccount = new Account(Name='testAccount', Type = 'End User', OwnerId = testUser[0].Id);     
            insert testAccount; 
            Contact testCont = new Contact();
            testCont.FirstName='test';
            testCont.LastName='Test2';
            testCont.Email='test@dell.com';
            testCont.MailingStreet='test';
            testCont.MailingCity='test';
            testCont.MailingState='test';
            testCont.MailingCountry='test';
            testCont.phone = '11211211';
            testCont.MobilePhone = '1211121';
            testCont.Eloqua_ID__c = '1';
            testCont.AccountId=testAccount.id;
            insert testCont;

            
            Opportunity testOpp = new Opportunity(AccountId = testAccount.Id,
                                                    Name = 'testOpportunity',
                                                    RecordTypeId = '012300000004zf2AAA',
                                                    CurrencyIsoCode = 'USD',
                                                    Type = 'Renewal',
                                                    CloseDate = system.Today(),
                                                    Domain__c = 'Non Domain',
                                                    Solution_Type__c = 'Cloud Integration',
                                                    Solution_Name__c = 'Boomi Solution',
                                                    StageName = 'Plan - 1%',
                                                    Quest_Software_Contact__c= testCont.id
                                                    //,Verifiable_Outcome__c = 'Territory/Account/Opportunity Plan developed & reviewed by RSM'
                                                    ) ;                                    
            insert testOpp;
            TriggerExecutionController.setSkipAllTriggers(false);
            
            testSR = new Support_Request__c(
                                            RecordTypeId = '012A0000000ViNJIA0',
                                            Opportunity__c = testOpp.Id,
                                            Receive_Notification__c = 'Yes',
                                            Requestor_Comments__c = 'testComment',
                                            Specialist_Name__c = testUser[1].Id,
                                            Specialist_Role__c = 'testRole');
            Test.startTest();
            insert testSR;
            testSR.Status__c='Engagement complete';
            update testSR;
            Test.stopTest();
            /*
            System.assertEquals(true,primaryContact1);
            */
        }
        
        /*System.runAs(testUser[1]){
            testSR.Specialist_Name__c = testUser[2].Id;
            update testSR;
        }*/
    }
}
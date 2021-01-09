/* ---------------------------------------------------------
* Revision  Name            Date        Release         Description
* 1.0                                                   Creation
* 2.0       Meghana         20.12.2013  15.03           OMGO CR 8973 - Remove use of field Verifiable_Outcome__c in Test Methods
* 3.0       Krishnamoorthi  05.06.2015  16.07(MAJ-S-03) CR 11561: GSD User Story (162173) - To Pre-Populate the Contact (Customer Contact Information (Name)) 
                                                        fields in Support Request
* 4.0       Krishnamoorthi  12.08.2015  R16.07 - CR 11809:  Added code to assign 'Support  Owner' to 'Solution Architect Assigned By' if logged in user has "Boomi Integration API Only" profile  
* 5.0       Krishnamoorthi  17.09.2015  R16.10 - CR 11963: Story 195421:[Pre-Sales] Excluding Boomi Integration User from Mandatory fields check while updating via API                                                      
* 6.0       Men Mee         06.01.2016  R16.12 - CR12402: Resolve for :Non-selective query against large object type" error
************************************************************/

@isTest

private class beforeInsertUpdateSupportRequestTest {
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
    
    /*static testMethod void IM_SOM() {
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%GBL Sales Rep - Non SSO%' ORDER BY Name DESC LIMIT 1];
        List<User> testUser = new List<User>();
        List<Sales_Motion_User_Role__c> testSMUR = new List<Sales_Motion_User_Role__c>();
        Support_Request__c testSR = new Support_Request__c();
        
        testUser.add(new User(Username='testSalesUser1' +'@dell.com',
                                Alias = 'Test1', 
                                Email='testSalesUser1'+'@dell.com',            
                                LastName='Test1',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test1'+System.currentTimeMillis()));
                                    
        testUser.add(new User(Username='testSalesUser2' +'@dell.com',
                                Alias = 'Test2', 
                                Email='testSalesUser2'+'@dell.com',            
                                LastName='Test2',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test2'+System.currentTimeMillis())); 
                                
        insert testUser;
        
        System.runAs(testUser[0]){
            Account testAccount = new Account(Name='testAccount', Type = 'End User', OwnerId = testUser[0].Id);     
            insert testAccount; 
            
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
                                                    Verifiable_Outcome__c = 'Territory/Account/Opportunity Plan developed & reviewed by RSM');                                      
            insert testOpp;
            
            testSMUR.add( new Sales_Motion_User_Role__c(Username__c = testUser[0].Id,
                                                            Role__c = 'SOC Intake Manager'));
                                                        
            testSMUR.add( new Sales_Motion_User_Role__c(Username__c = testUser[0].Id,
                                                        Role__c = 'SOC SOM'));
                                                        
            insert testSMUR;
                                            
            testSR = new Support_Request__c(RecordTypeId = '012K00000004XNRIA2',
                                            Opportunity__c = testOpp.Id,
                                            Receive_Notification__c = 'Yes',
                                            Assigned_ISA_DSA_from_SDC__c = testUser[1].Id,
                                            Customer_Due_Date_for_Proposal__c = system.Today(),
                                            Consolidated_Invoice_Required__c = 'Yes',
                                            Additional_Notes_Comments__c = 'testAdditionalNotesComments',
                                            Status__c = 'New');         

            insert testSR;

            testSR.Status__c = 'Returned';
            testSR.Intake_Manager_SOC__c = testSMUR[0].Id;
            testSR.IM_Comments__c = 'testIMComments1';
            testSR.Return_Decline_Reason__c = 'Missing Data';
            GlobalVariables.SM_SOC_ISINSERT = false;
            
            Test.startTest();
            update testSR;
            Test.stopTest();
            System.assertEquals('testIMComments1', testSR.IM_Comments__c);
        }
    }
    
    static testMethod void SOM() {
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%GBL Sales Rep - Non SSO%' ORDER BY Name DESC LIMIT 1];
        List<User> testUser = new List<User>();
        List<Sales_Motion_User_Role__c> testSMUR = new List<Sales_Motion_User_Role__c>();
        List<Sales_Motion_User_Role__c> testSMUR2 = new List<Sales_Motion_User_Role__c>();
        Support_Request__c testSR = new Support_Request__c();
        
        testUser.add(new User(Username='testSalesUser1' +'@dell.com',
                                Alias = 'Test1', 
                                Email='testSalesUser1'+'@dell.com',            
                                LastName='Test1',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test1'+System.currentTimeMillis()));
                                    
        testUser.add(new User(Username='testSalesUser2' +'@dell.com',
                                Alias = 'Test2', 
                                Email='testSalesUser2'+'@dell.com',            
                                LastName='Test2',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test2'+System.currentTimeMillis()));
                                
        insert testUser;
        
        System.runAs(testUser[0]){
            Account testAccount = new Account(Name='testAccount', Type = 'End User', OwnerId = testUser[0].Id);     
            insert testAccount; 
            
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
                                                    Verifiable_Outcome__c = 'Territory/Account/Opportunity Plan developed & reviewed by RSM');                                      
            insert testOpp;
                                            
            testSR = new Support_Request__c(RecordTypeId = '012K00000004XNRIA2',
                                            Opportunity__c = testOpp.Id,
                                            Receive_Notification__c = 'Yes',
                                            Assigned_ISA_DSA_from_SDC__c = testUser[1].Id,
                                            Customer_Due_Date_for_Proposal__c = system.Today(),
                                            Consolidated_Invoice_Required__c = 'Yes',
                                            Additional_Notes_Comments__c = 'testAdditionalNotesComments',
                                            Status__c = 'New');         

            insert testSR;
            
            testSMUR.add( new Sales_Motion_User_Role__c(Username__c = testUser[0].Id,
                                                        Role__c = 'SOC SOM'));
            insert testSMUR;
            
            testSR.Status__c = 'Returned';
            //testSR2.Intake_Manager_SOC__c = testSMUR[0].Id;
            //testSR2.IM_Comments__c = 'testIMComments2';
            testSR.SOM__c = testSMUR[0].Id;
            testSR.SOM_Comments__c = 'testSOMComments2';
            testSR.Return_Decline_Reason__c = 'Missing Data';
            GlobalVariables.SM_SOC_ISINSERT = false;
            Test.startTest();
            update testSR;
            Test.stopTest();
            System.assertEquals('testSOMComments2', testSR.SOM_Comments__c);
        }
    }
    
    static testMethod void IM() {
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%GBL Sales Rep - Non SSO%' ORDER BY Name DESC LIMIT 1];
        List<User> testUser = new List<User>();
        List<Sales_Motion_User_Role__c> testSMUR = new List<Sales_Motion_User_Role__c>();
        Support_Request__c testSR = new Support_Request__c();
        
        testUser.add(new User(Username='testSalesUser1' +'@dell.com',
                                Alias = 'Test1', 
                                Email='testSalesUser1'+'@dell.com',            
                                LastName='Test1',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test1'+System.currentTimeMillis()));
                                    
        testUser.add(new User(Username='testSalesUser2' +'@dell.com',
                                Alias = 'Test2', 
                                Email='testSalesUser2'+'@dell.com',            
                                LastName='Test2',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test2'+System.currentTimeMillis()));
                                
        insert testUser;
        
        System.runAs(testUser[0]){
            Account testAccount = new Account(Name='testAccount', Type = 'End User', OwnerId = testUser[0].Id);     
            insert testAccount; 
            
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
                                                    Verifiable_Outcome__c = 'Territory/Account/Opportunity Plan developed & reviewed by RSM');                                      
            insert testOpp;
                                            
            testSR = new Support_Request__c(RecordTypeId = '012K00000004XNRIA2',
                                            Opportunity__c = testOpp.Id,
                                            Receive_Notification__c = 'Yes',
                                            Assigned_ISA_DSA_from_SDC__c = testUser[1].Id,
                                            Customer_Due_Date_for_Proposal__c = system.Today(),
                                            Consolidated_Invoice_Required__c = 'Yes',
                                            Additional_Notes_Comments__c = 'testAdditionalNotesComments',
                                            Status__c = 'New');         

            insert testSR;
            
            testSMUR.add( new Sales_Motion_User_Role__c(Username__c = testUser[0].Id,
                                                        Role__c = 'SOC Intake Manager'));
            insert testSMUR;
            
            testSR.Status__c = 'Returned';
            testSR.Intake_Manager_SOC__c = testSMUR[0].Id;
            testSR.IM_Comments__c = 'testIMComments2';
            //testSR.SOM__c = testSMUR2[0].Id;
            //testSR.SOM_Comments__c = 'testSOMComments2';
            testSR.Return_Decline_Reason__c = 'Missing Data';
            GlobalVariables.SM_SOC_ISINSERT = false;
            Test.startTest();
            update testSR;
            Test.stopTest();
            System.assertEquals('Returned', testSR.Status__c);
        }
    }
    
    static testMethod void Sales() {
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%GBL Sales Rep - Non SSO%' ORDER BY Name DESC LIMIT 1];
        List<User> testUser = new List<User>();
        List<Sales_Motion_User_Role__c> testSMUR = new List<Sales_Motion_User_Role__c>();
        Support_Request__c testSR = new Support_Request__c();
        
        testUser.add(new User(Username='testSalesUser1' +'@dell.com',
                                Alias = 'Test1', 
                                Email='testSalesUser1'+'@dell.com',            
                                LastName='Test1',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test1'+System.currentTimeMillis()));
                                    
        testUser.add(new User(Username='testSalesUser2' +'@dell.com',
                                Alias = 'Test2', 
                                Email='testSalesUser2'+'@dell.com',            
                                LastName='Test2',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test2'+System.currentTimeMillis()));
                                
        insert testUser;
        
        System.runAs(testUser[0]){
        
            
            Account testAccount = new Account(Name='testAccount', Type = 'End User', OwnerId = testUser[0].Id);     
            insert testAccount; 
            
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
                                                    Verifiable_Outcome__c = 'Territory/Account/Opportunity Plan developed & reviewed by RSM');                                      
            insert testOpp;
                                            
            testSR = new Support_Request__c(RecordTypeId = '012K00000004XNRIA2',
                                            Opportunity__c = testOpp.Id,
                                            Receive_Notification__c = 'Yes',
                                            Assigned_ISA_DSA_from_SDC__c = testUser[1].Id,
                                            Customer_Due_Date_for_Proposal__c = system.Today(),
                                            Consolidated_Invoice_Required__c = 'Yes',
                                            Additional_Notes_Comments__c = 'testAdditionalNotesComments',
                                            Status__c = 'New');         

            insert testSR;
            
            testSR.Additional_Notes_Comments__c = 'testAdditionalNotesComments2';
            testSR.Consolidated_Invoice_Required__c = 'Yes';
            GlobalVariables.SM_SOC_ISINSERT = false;
            Test.startTest();
            update testSR;
            Test.stopTest();
            System.assertEquals('testAdditionalNotesComments2', testSR.Additional_Notes_Comments__c);
        }
    }*/
    
    static testMethod void failedInsertSales() {
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%GBL Sales Rep%' ORDER BY Name DESC LIMIT 1];
        List<User> testUser = new List<User>();
        List<Sales_Motion_User_Role__c> testSMUR = new List<Sales_Motion_User_Role__c>();
        Support_Request__c testSR = new Support_Request__c();
        
        testUser.add(new User(Username='testSalesUser113235454'+'@dell.com',
                                Alias = 'Test1', 
                                Email='testSalesUser1'+'@dell.com',            
                                LastName='Test1',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test1'+System.currentTimeMillis()));
                                    
        testUser.add(new User(Username='testSalesUser213235454'+'@dell.com',
                                Alias = 'Test2', 
                                Email='testSalesUser2'+'@dell.com',            
                                LastName='Test2',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test2'+System.currentTimeMillis()));
                                
        insert testUser;
                
        System.runAs(testUser[0]){
            TriggerExecutionController.setSkipAllTriggers(true);
        Account testAccount = new Account(Name='testAccount', Type = 'End User', OwnerId = testUser[0].Id);     
            insert testAccount; 
        Contact con = new Contact(FirstName='test',LastName='Test2',Email='test@dell.com',MailingStreet='test',MailingCity='test',MailingState='test',
                        MailingCountry='test',AccountId=testAccount.Id,Phone='12345',Decision_Making_Role__c='Business User');
            insert con;
                        
            Opportunity testOpp = new Opportunity(AccountId = testAccount.Id,
                                                    Name = 'testOpportunity',
                                                    RecordTypeId = '012300000004zf2AAA',
                                                    CurrencyIsoCode = 'USD',
                                                    Type = 'Renewal',
                                                    CloseDate = system.Today(),
                                                    Domain__c = 'Non Domain',
                                                    Quest_Software_Contact__c= con.id,
                                                    Solution_Type__c = 'Cloud Integration',
                                                    Solution_Name__c = 'Boomi Solution',
                                                    StageName = 'Plan - 1%'
                                                    //,Verifiable_Outcome__c = 'Territory/Account/Opportunity Plan developed & reviewed by RSM'
                                                    );                                      
            insert testOpp;
            
            testSMUR.add( new Sales_Motion_User_Role__c(Username__c = testUser[1].Id,
                                                        Role__c = 'SOC Intake Manager'));
                                                        
            testSMUR.add( new Sales_Motion_User_Role__c(Username__c = testUser[1].Id,
                                                        Role__c = 'SOC SOM'));
            insert testSMUR;
                                            
            testSR = new Support_Request__c(RecordTypeId = '012A0000000ViNOIA0',
                                            Opportunity__c = testOpp.Id,
                                            Receive_Notification__c = 'Yes',
                                            Assigned_ISA_DSA_from_SDC__c = testUser[1].Id,
                                            Customer_Due_Date_for_Proposal__c = system.Today(),
                                            Consolidated_Invoice_Required__c = 'Yes',
                                            Additional_Notes_Comments__c = 'testAdditionalNotesComments',
                                            Status__c = 'New',
                                            Category__c= 'Internal to CSE',
                                            Intake_Manager_SOC__c = testSMUR[0].Id,
                                            IM_Comments__c = 'abc',
                                            SOM__c = testSMUR[1].Id,
                                            SOM_Comments__c = '123',
                                            Return_Decline_Reason__c = 'Missing Data');         

            try{
                insert testSR;
                Support_Request__c sr = [Select id, Category__c from Support_Request__c where Id =:testSR.Id];
                sr.Category__c= 'Custom Integration';
                testSR.Status__c= 'Planning';
                Update testSR;
            }
            catch(Exception e){
                System.debug(e);
            }
        }
    }
    
    static testMethod void failedUpdateSales() {
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%GBL Sales Rep%' ORDER BY Name DESC LIMIT 1];
        List<User> testUser = new List<User>();
        List<Sales_Motion_User_Role__c> testSMUR = new List<Sales_Motion_User_Role__c>();
        Support_Request__c testSR = new Support_Request__c();
        
        testUser.add(new User(Username='testSalesUser113235454'+'@dell.com',
                                Alias = 'Test1', 
                                Email='testSalesUser1'+'@dell.com',            
                                LastName='Test1',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test1'+System.currentTimeMillis()));
                                    
        testUser.add(new User(Username='testSalesUser213235454'+'@dell.com',
                                Alias = 'Test2', 
                                Email='testSalesUser213235454'+'@dell.com',            
                                LastName='Test2',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test2'+System.currentTimeMillis()));
                                
        insert testUser;
        
        System.runAs(testUser[0]){
            TriggerExecutionController.setSkipAllTriggers(true);
            Account testAccount = new Account(Name='testAccount', Type = 'End User', OwnerId = testUser[0].Id);     
            insert testAccount; 
            
           Contact con = new Contact(FirstName='test',LastName='Test2',Email='test@dell.com',MailingStreet='test',MailingCity='test',MailingState='test',
                        MailingCountry='test',AccountId=testAccount.Id,Phone='12345',Decision_Making_Role__c='Business User');
            insert con;
        
            
            Opportunity testOpp = new Opportunity(AccountId = testAccount.Id,
                                                    Name = 'testOpportunity',
                                                    RecordTypeId = '012300000004zf2AAA',
                                                    CurrencyIsoCode = 'USD',
                                                    Type = 'Renewal',
                                                    CloseDate = system.Today(),
                                                    Domain__c = 'Non Domain',
                                                    Quest_Software_Contact__c= con.id,
                                                    Solution_Type__c = 'Cloud Integration',
                                                    Solution_Name__c = 'Boomi Solution',
                                                    StageName = 'Plan - 1%'
                                                    //Verifiable_Outcome__c = 'Territory/Account/Opportunity Plan developed & reviewed by RSM'
                                                    );                                      
            insert testOpp;
            
            testSMUR.add( new Sales_Motion_User_Role__c(Username__c = testUser[1].Id,
                                                        Role__c = 'SOC Intake Manager'));
                                                        
            testSMUR.add( new Sales_Motion_User_Role__c(Username__c = testUser[1].Id,
                                                        Role__c = 'SOC SOM'));
            insert testSMUR;
                                            
            testSR = new Support_Request__c(RecordTypeId = '012A0000000ViNOIA0',
                                            Opportunity__c = testOpp.Id,
                                            Receive_Notification__c = 'Yes',
                                            Assigned_ISA_DSA_from_SDC__c = testUser[1].Id,
                                            Customer_Due_Date_for_Proposal__c = system.Today(),
                                            Consolidated_Invoice_Required__c = 'Yes',
                                            Additional_Notes_Comments__c = 'testAdditionalNotesComments',
                                            Status__c = 'New');         

            insert testSR;
            
            testSR.Intake_Manager_SOC__c = testSMUR[0].Id;
            testSR.IM_Comments__c = '123';
            testSR.Status__c = 'In Review';
            testSR.Return_Decline_Reason__c = 'Missing Data';
            testSR.SOM__c = testSMUR[1].Id;
            testSR.SOM_Comments__c = '123';
            GlobalVariables.SM_SOC_ISINSERT = false;
            Test.startTest();
            try{
                update testSR;
            }
            catch(Exception e){
                System.debug(e);
            }
            Test.stopTest();
        }
    }
    
    static testMethod void failedIM_SOM() {
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%GBL Sales Rep%' ORDER BY Name DESC LIMIT 1];
        List<User> testUser = new List<User>();
        List<Sales_Motion_User_Role__c> testSMUR = new List<Sales_Motion_User_Role__c>();
        Support_Request__c testSR = new Support_Request__c();
        
        testUser.add(new User(Username='testSalesUser113235454' +'@dell.com',
                                Alias = 'Test1', 
                                Email='testSalesUser1'+'@dell.com',            
                                LastName='Test1',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test1'+System.currentTimeMillis()));
                                    
        testUser.add(new User(Username='testSalesUser213235454' +'@dell.com',
                                Alias = 'Test2', 
                                Email='testSalesUser2'+'@dell.com',            
                                LastName='Test2',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test2'+System.currentTimeMillis())); 
                                
        testUser.add(new User(Username='testSalesUser313235454' +'@dell.com',
                                Alias = 'Test3', 
                                Email='testSalesUser3'+'@dell.com',            
                                LastName='Test3',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test3'+System.currentTimeMillis())); 
                                
        insert testUser;
                
        System.runAs(testUser[0]){
            TriggerExecutionController.setSkipAllTriggers(true);
            Account testAccount = new Account(Name='testAccount', Type = 'End User', OwnerId = testUser[0].Id);     
            insert testAccount; 
            
            Contact con = new Contact(FirstName='test',LastName='Test2',Email='test@dell.com',MailingStreet='test',MailingCity='test',MailingState='test',
                        MailingCountry='test',AccountId=testAccount.Id,Phone='12345',Decision_Making_Role__c='Business User');
        insert con;
            Opportunity testOpp = new Opportunity(AccountId = testAccount.Id,
                                                    Name = 'testOpportunity',
                                                    RecordTypeId = '012300000004zf2AAA',
                                                    CurrencyIsoCode = 'USD',
                                                    Type = 'Renewal',
                                                    CloseDate = system.Today(),
                                                    Domain__c = 'Non Domain',
                                                    Quest_Software_Contact__c= con.id,
                                                    Solution_Type__c = 'Cloud Integration',
                                                    Solution_Name__c = 'Boomi Solution',
                                                    StageName = 'Plan - 1%'
                                                    //Verifiable_Outcome__c = 'Territory/Account/Opportunity Plan developed & reviewed by RSM'
                                                    );                                      
            insert testOpp;
            
            testSMUR.add( new Sales_Motion_User_Role__c(Username__c = testUser[0].Id,
                                                            Role__c = 'SOC Intake Manager'));
                                                        
            testSMUR.add( new Sales_Motion_User_Role__c(Username__c = testUser[0].Id,
                                                        Role__c = 'SOC SOM'));
                                                        
            insert testSMUR;
                                            
            testSR = new Support_Request__c(RecordTypeId = '012A0000000ViNOIA0',
                                            Opportunity__c = testOpp.Id,
                                            Receive_Notification__c = 'Yes',
                                            Assigned_ISA_DSA_from_SDC__c = testUser[1].Id,
                                            Customer_Due_Date_for_Proposal__c = system.Today(),
                                            Consolidated_Invoice_Required__c = 'Yes',
                                            Additional_Notes_Comments__c = 'testAdditionalNotesComments',
                                            Status__c = 'New');         

            insert testSR;

            testSR.Customer_Number__c = '123';
            testSR.Customer_Contract_Code_If_Applicable__c = '123';
            testSR.Customer_Due_Date_for_Proposal__c = system.Today()+1;
            testSR.Consolidated_Invoice_Required__c = 'No';
            testSR.Additional_Notes_Comments__c = '123';
            testSR.Assigned_ISA_DSA_from_SDC__c = testUser[2].Id;
            testSR.Assigned_Solution_Architect__c = testUser[2].Id;
            testSR.DDVS_Solution_Advisor_ID__c = '123';
            testSR.Receive_Notification__c = 'No';
            testSR.Status__c = 'In Review';
            testSR.Intake_Manager_SOC__c = testSMUR[0].Id;
            testSR.SOM__c = testSMUR[1].Id;
            testSR.IM_Comments__c = '';
            testSR.SOM_Comments__c = '';
            testSR.Return_Decline_Reason__c  = '';
            GlobalVariables.SM_SOC_ISINSERT = false;
            
            Test.startTest();
            try{
                update testSR;
            }
            catch(Exception e){
                System.debug(e);
            }
            Test.stopTest();
        }
    }
    
    static testMethod void failedIM_SOM2() {
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%GBL Sales Rep%' ORDER BY Name DESC LIMIT 1];
        List<User> testUser = new List<User>();
        List<Sales_Motion_User_Role__c> testSMUR = new List<Sales_Motion_User_Role__c>();
        Support_Request__c testSR = new Support_Request__c();
        
        testUser.add(new User(Username='testSalesUser113235454' +'@dell.com',
                                Alias = 'Test1', 
                                Email='testSalesUser1'+'@dell.com',            
                                LastName='Test1',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test1'+System.currentTimeMillis()));
                                    
        testUser.add(new User(Username='testSalesUser213235454' +'@dell.com',
                                Alias = 'Test2', 
                                Email='testSalesUser2'+'@dell.com',            
                                LastName='Test2',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test2'+System.currentTimeMillis())); 
                                
        testUser.add(new User(Username='testSalesUser313235454' +'@dell.com',
                                Alias = 'Test3', 
                                Email='testSalesUser3'+'@dell.com',            
                                LastName='Test3',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test3'+System.currentTimeMillis())); 
                                
        insert testUser;
        
        
        System.runAs(testUser[0]){
            TriggerExecutionController.setSkipAllTriggers(true);
            Account testAccount = new Account(Name='testAccount', Type = 'End User', OwnerId = testUser[0].Id);     
            insert testAccount; 
           Contact con = new Contact(FirstName='test',LastName='Test2',Email='test@dell.com',MailingStreet='test',MailingCity='test',MailingState='test',
                        MailingCountry='test',AccountId=testAccount.Id,Phone='12345',Decision_Making_Role__c='Business User');
            insert con;
            
            Opportunity testOpp = new Opportunity(AccountId = testAccount.Id,
                                                    Name = 'testOpportunity',
                                                    RecordTypeId = '012300000004zf2AAA',
                                                    CurrencyIsoCode = 'USD',
                                                    Type = 'Renewal',
                                                    CloseDate = system.Today(),
                                                    Domain__c = 'Non Domain',
                                                    Quest_Software_Contact__c= con.id,
                                                    Solution_Type__c = 'Cloud Integration',
                                                    Solution_Name__c = 'Boomi Solution',
                                                    StageName = 'Plan - 1%'
                                                    //Verifiable_Outcome__c = 'Territory/Account/Opportunity Plan developed & reviewed by RSM'
                                                    );                                      
            insert testOpp;
            
            testSMUR.add( new Sales_Motion_User_Role__c(Username__c = testUser[0].Id,
                                                            Role__c = 'SOC Intake Manager'));
                                                        
            testSMUR.add( new Sales_Motion_User_Role__c(Username__c = testUser[0].Id,
                                                        Role__c = 'SOC SOM'));
                                                        
            insert testSMUR;
                                            
            testSR = new Support_Request__c(RecordTypeId = '012A0000000ViNOIA0',
                                            Opportunity__c = testOpp.Id,
                                            Receive_Notification__c = 'Yes',
                                            Assigned_ISA_DSA_from_SDC__c = testUser[1].Id,
                                            Customer_Due_Date_for_Proposal__c = system.Today(),
                                            Consolidated_Invoice_Required__c = 'Yes',
                                            Additional_Notes_Comments__c = 'testAdditionalNotesComments',
                                            Status__c = 'New');         

            insert testSR;

            testSR.Customer_Number__c = '123';
            testSR.Customer_Contract_Code_If_Applicable__c = '123';
            testSR.Customer_Due_Date_for_Proposal__c = system.Today()+1;
            testSR.Consolidated_Invoice_Required__c = 'No';
            testSR.Additional_Notes_Comments__c = '123';
            testSR.Assigned_ISA_DSA_from_SDC__c = testUser[2].Id;
            testSR.Assigned_Solution_Architect__c = testUser[2].Id;
            testSR.DDVS_Solution_Advisor_ID__c = '123';
            testSR.Receive_Notification__c = 'No';
            testSR.Status__c = 'New';
            testSR.Intake_Manager_SOC__c = testSMUR[0].Id;
            testSR.SOM__c = testSMUR[1].Id;
            testSR.IM_Comments__c = '';
            testSR.SOM_Comments__c = '';
            testSR.Return_Decline_Reason__c  = '';
            GlobalVariables.SM_SOC_ISINSERT = false;
            
            Test.startTest();
            try{
                update testSR;
            }
            catch(Exception e){
                System.debug(e);
            }
            Test.stopTest();
        }
    }
    
    static testMethod void failedIM_SOM3() {
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%GBL Sales Rep%' ORDER BY Name DESC LIMIT 1];
        List<User> testUser = new List<User>();
        List<Sales_Motion_User_Role__c> testSMUR = new List<Sales_Motion_User_Role__c>();
        Support_Request__c testSR = new Support_Request__c();
        
        testUser.add(new User(Username='testSalesUser113235454' +'@dell.com',
                                Alias = 'Test1', 
                                Email='testSalesUser1'+'@dell.com',            
                                LastName='Test1',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test1'+System.currentTimeMillis()));
                                    
        testUser.add(new User(Username='testSalesUser213235454' +'@dell.com',
                                Alias = 'Test2', 
                                Email='testSalesUser2'+'@dell.com',            
                                LastName='Test2',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test2'+System.currentTimeMillis())); 
                                
        testUser.add(new User(Username='testSalesUser313235454' +'@dell.com',
                                Alias = 'Test3', 
                                Email='testSalesUser3'+'@dell.com',            
                                LastName='Test3',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test3'+System.currentTimeMillis())); 
                                
        insert testUser;
       
        
        System.runAs(testUser[0]){
            TriggerExecutionController.setSkipAllTriggers(true);
            Account testAccount = new Account(Name='testAccount', Type = 'End User', OwnerId = testUser[0].Id);     
            insert testAccount; 
          
            Contact con = new Contact(FirstName='test',LastName='Test2',Email='test@dell.com',MailingStreet='test',MailingCity='test',MailingState='test',
                        MailingCountry='test',AccountId=testAccount.Id,Phone='12345',Decision_Making_Role__c='Business User');
            insert con;
            
            Opportunity testOpp = new Opportunity(AccountId = testAccount.Id,
                                                    Name = 'testOpportunity',
                                                    RecordTypeId = '012300000004zf2AAA',
                                                    CurrencyIsoCode = 'USD',
                                                    Type = 'Renewal',
                                                    CloseDate = system.Today(),
                                                    Domain__c = 'Non Domain',
                                                    Quest_Software_Contact__c= con.id,
                                                    Solution_Type__c = 'Cloud Integration',
                                                    Solution_Name__c = 'Boomi Solution',
                                                    StageName = 'Plan - 1%'
                                                    //Verifiable_Outcome__c = 'Territory/Account/Opportunity Plan developed & reviewed by RSM'
                                                    );                                      
            insert testOpp;
            
            testSMUR.add( new Sales_Motion_User_Role__c(Username__c = testUser[0].Id,
                                                            Role__c = 'SOC Intake Manager'));
                                                        
            testSMUR.add( new Sales_Motion_User_Role__c(Username__c = testUser[0].Id,
                                                        Role__c = 'SOC SOM'));
                                                        
            insert testSMUR;
                                            
            testSR = new Support_Request__c(RecordTypeId = '012A0000000ViNOIA0',
                                            Opportunity__c = testOpp.Id,
                                            Receive_Notification__c = 'Yes',
                                            Assigned_ISA_DSA_from_SDC__c = testUser[1].Id,
                                            Customer_Due_Date_for_Proposal__c = system.Today(),
                                            Consolidated_Invoice_Required__c = 'Yes',
                                            Additional_Notes_Comments__c = 'testAdditionalNotesComments',
                                            Status__c = 'New');         

            insert testSR;

            testSR.Customer_Number__c = '123';
            testSR.Customer_Contract_Code_If_Applicable__c = '123';
            testSR.Customer_Due_Date_for_Proposal__c = system.Today()+1;
            testSR.Consolidated_Invoice_Required__c = 'No';
            testSR.Additional_Notes_Comments__c = '123';
            testSR.Assigned_ISA_DSA_from_SDC__c = testUser[2].Id;
            testSR.Assigned_Solution_Architect__c = testUser[2].Id;
            testSR.DDVS_Solution_Advisor_ID__c = '123';
            testSR.Receive_Notification__c = 'No';
            testSR.Status__c = 'Planning';
            testSR.IM_Comments__c = '';
            testSR.SOM_Comments__c = '';
            testSR.Return_Decline_Reason__c  = '';
            GlobalVariables.SM_SOC_ISINSERT = false;
            
            Test.startTest();
            try{
                update testSR;
            }
            catch(Exception e){
                System.debug(e);
            }
            Test.stopTest();
        }
    }
    
    static testMethod void failedIM() {
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%GBL Sales Rep%' ORDER BY Name DESC LIMIT 1];
        List<User> testUser = new List<User>();
        List<Sales_Motion_User_Role__c> testSMUR = new List<Sales_Motion_User_Role__c>();
        Support_Request__c testSR = new Support_Request__c();
        
        testUser.add(new User(Username='testSalesUser113235454' +'@dell.com',
                                Alias = 'Test1', 
                                Email='testSalesUser1'+'@dell.com',            
                                LastName='Test1',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test1'+System.currentTimeMillis()));
                                    
        testUser.add(new User(Username='testSalesUser213235454' +'@dell.com',
                                Alias = 'Test2', 
                                Email='testSalesUser2'+'@dell.com',            
                                LastName='Test2',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test2'+System.currentTimeMillis())); 
                                
        testUser.add(new User(Username='testSalesUser313235454' +'@dell.com',
                                Alias = 'Test3', 
                                Email='testSalesUser3'+'@dell.com',            
                                LastName='Test3',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test3'+System.currentTimeMillis())); 
                                
        insert testUser;
     
        
        System.runAs(testUser[0]){
            TriggerExecutionController.setSkipAllTriggers(true);
            Account testAccount = new Account(Name='testAccount', Type = 'End User', OwnerId = testUser[0].Id);     
            insert testAccount; 
            Contact con = new Contact(FirstName='test',LastName='Test2',Email='test@dell.com',MailingStreet='test',MailingCity='test',MailingState='test',
                        MailingCountry='test',AccountId=testAccount.Id,Phone='12345',Decision_Making_Role__c='Business User');
            insert con;
            
            Opportunity testOpp = new Opportunity(AccountId = testAccount.Id,
                                                    Name = 'testOpportunity',
                                                    RecordTypeId = '012300000004zf2AAA',
                                                    CurrencyIsoCode = 'USD',
                                                    Type = 'Renewal',
                                                    CloseDate = system.Today(),
                                                    Domain__c = 'Non Domain',
                                                    Quest_Software_Contact__c= con.id,
                                                    Solution_Type__c = 'Cloud Integration',
                                                    Solution_Name__c = 'Boomi Solution',
                                                    StageName = 'Plan - 1%'
                                                    //Verifiable_Outcome__c = 'Territory/Account/Opportunity Plan developed & reviewed by RSM'
                                                    );                                      
            insert testOpp;
            
            testSMUR.add( new Sales_Motion_User_Role__c(Username__c = testUser[0].Id,
                                                            Role__c = 'SOC Intake Manager'));
                                                        
                                                        
            insert testSMUR;
                                            
            testSR = new Support_Request__c(RecordTypeId = '012A0000000ViNOIA0',
                                            Opportunity__c = testOpp.Id,
                                            Receive_Notification__c = 'Yes',
                                            Assigned_ISA_DSA_from_SDC__c = testUser[1].Id,
                                            Customer_Due_Date_for_Proposal__c = system.Today(),
                                            Consolidated_Invoice_Required__c = 'Yes',
                                            Additional_Notes_Comments__c = 'testAdditionalNotesComments',
                                            Status__c = 'New');         

            insert testSR;

            testSR.Status__c = 'Returned';
            testSR.IM_Comments__c = '';
            testSR.SOM_Comments__c = '123';
            testSR.Return_Decline_Reason__c  = '';
            GlobalVariables.SM_SOC_ISINSERT = false;
            
            Test.startTest();
            try{
                update testSR;
            }
            catch(Exception e){
                System.debug(e);
            }
            Test.stopTest();
        }
    }
    
    static testMethod void failedIM2() {
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%GBL Sales Rep%' ORDER BY Name DESC LIMIT 1];
        List<User> testUser = new List<User>();
        List<Sales_Motion_User_Role__c> testSMUR = new List<Sales_Motion_User_Role__c>();
        Support_Request__c testSR = new Support_Request__c();
        
        testUser.add(new User(Username='testSalesUser113235454' +'@dell.com',
                                Alias = 'Test1', 
                                Email='testSalesUser1'+'@dell.com',            
                                LastName='Test1',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test1'+System.currentTimeMillis()));
                                    
        testUser.add(new User(Username='testSalesUser213235454' +'@dell.com',
                                Alias = 'Test2', 
                                Email='testSalesUser2'+'@dell.com',            
                                LastName='Test2',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test2'+System.currentTimeMillis())); 
                                
        testUser.add(new User(Username='testSalesUser313235454' +'@dell.com',
                                Alias = 'Test3', 
                                Email='testSalesUser3'+'@dell.com',            
                                LastName='Test3',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test3'+System.currentTimeMillis())); 
                                
        insert testUser;
        
        
        System.runAs(testUser[0]){
            TriggerExecutionController.setSkipAllTriggers(true);
            Account testAccount = new Account(Name='testAccount', Type = 'End User', OwnerId = testUser[0].Id);     
            insert testAccount; 
            Contact con = new Contact(FirstName='test',LastName='Test2',Email='test@dell.com',MailingStreet='test',MailingCity='test',MailingState='test',
                        MailingCountry='test',AccountId=testAccount.Id,Phone='12345',Decision_Making_Role__c='Business User');
            insert con;
            
            Opportunity testOpp = new Opportunity(AccountId = testAccount.Id,
                                                    Name = 'testOpportunity',
                                                    RecordTypeId = '012300000004zf2AAA',
                                                    CurrencyIsoCode = 'USD',
                                                    Type = 'Renewal',
                                                    CloseDate = system.Today(),
                                                    Domain__c = 'Non Domain',
                                                    Quest_Software_Contact__c= con.id,
                                                    Solution_Type__c = 'Cloud Integration',
                                                    Solution_Name__c = 'Boomi Solution',
                                                    StageName = 'Plan - 1%'
                                                    //Verifiable_Outcome__c = 'Territory/Account/Opportunity Plan developed & reviewed by RSM'
                                                    );                                      
            insert testOpp;
            
            testSMUR.add( new Sales_Motion_User_Role__c(Username__c = testUser[0].Id,
                                                            Role__c = 'SOC Intake Manager'));
                                                        
                                                        
            insert testSMUR;
                                            
            testSR = new Support_Request__c(RecordTypeId = '012A0000000ViNOIA0',
                                            Opportunity__c = testOpp.Id,
                                            Receive_Notification__c = 'Yes',
                                            Assigned_ISA_DSA_from_SDC__c = testUser[1].Id,
                                            Customer_Due_Date_for_Proposal__c = system.Today(),
                                            Consolidated_Invoice_Required__c = 'Yes',
                                            Additional_Notes_Comments__c = 'testAdditionalNotesComments',
                                            Status__c = 'New');         

            insert testSR;

            testSR.Status__c = 'Planning';
            testSR.IM_Comments__c = '';
            testSR.SOM_Comments__c = '123';
            testSR.Return_Decline_Reason__c  = '';
            GlobalVariables.SM_SOC_ISINSERT = false;
            
            Test.startTest();
            try{
                update testSR;
            }
            catch(Exception e){
                System.debug(e);
            }
            Test.stopTest();
        }
    }
    
    static testMethod void failedSOM() {
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%GBL Sales Rep%' ORDER BY Name DESC LIMIT 1];
        List<User> testUser = new List<User>();
        List<Sales_Motion_User_Role__c> testSMUR = new List<Sales_Motion_User_Role__c>();
        Support_Request__c testSR = new Support_Request__c();
        
        testUser.add(new User(Username='testSalesUser113235454' +'@dell.com',
                                Alias = 'Test1', 
                                Email='testSalesUser1'+'@dell.com',            
                                LastName='Test1',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test1'+System.currentTimeMillis()));
                                    
        testUser.add(new User(Username='testSalesUser213235454' +'@dell.com',
                                Alias = 'Test2', 
                                Email='testSalesUser2'+'@dell.com',            
                                LastName='Test2',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test2'+System.currentTimeMillis())); 
                                
        testUser.add(new User(Username='testSalesUser313235454' +'@dell.com',
                                Alias = 'Test3', 
                                Email='testSalesUser3'+'@dell.com',            
                                LastName='Test3',
                                ProfileId = profile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='Test3'+System.currentTimeMillis())); 
                                
        insert testUser;
       
        
        System.runAs(testUser[0]){
            TriggerExecutionController.setSkipAllTriggers(true);
            Account testAccount = new Account(Name='testAccount', Type = 'End User', OwnerId = testUser[0].Id);     
            insert testAccount; 
            
            Contact con = new Contact(FirstName='test',LastName='Test2',Email='test@dell.com',MailingStreet='test',MailingCity='test',MailingState='test',
                        MailingCountry='test',AccountId=testAccount.Id,Phone='12345',Decision_Making_Role__c='Business User');
            insert con;
            
            Opportunity testOpp = new Opportunity(AccountId = testAccount.Id,
                                                    Name = 'testOpportunity',
                                                    RecordTypeId = '012300000004zf2AAA',
                                                    CurrencyIsoCode = 'USD',
                                                    Type = 'Renewal',
                                                    CloseDate = system.Today(),
                                                    Domain__c = 'Non Domain',
                                                    Quest_Software_Contact__c= con.id,
                                                    Solution_Type__c = 'Cloud Integration',
                                                    Solution_Name__c = 'Boomi Solution',
                                                    StageName = 'Plan - 1%'
                                                    //Verifiable_Outcome__c = 'Territory/Account/Opportunity Plan developed & reviewed by RSM'
                                                    );                                      
            insert testOpp;
            
            testSMUR.add( new Sales_Motion_User_Role__c(Username__c = testUser[0].Id,
                                                            Role__c = 'SOC SOM'));
                                                            
            testSMUR.add( new Sales_Motion_User_Role__c(Username__c = testUser[1].Id,
                                                            Role__c = 'SOC Intake Manager'));
                                                        
                                                        
            insert testSMUR;
                                            
            testSR = new Support_Request__c(RecordTypeId = '012A0000000ViNOIA0',
                                            Opportunity__c = testOpp.Id,
                                            Receive_Notification__c = 'Yes',
                                            Assigned_ISA_DSA_from_SDC__c = testUser[1].Id,
                                            Customer_Due_Date_for_Proposal__c = system.Today(),
                                            Consolidated_Invoice_Required__c = 'Yes',
                                            Additional_Notes_Comments__c = 'testAdditionalNotesComments',
                                            Status__c = 'New');         

            insert testSR;

            testSR.Status__c = 'Unqualified Opp';
            testSR.Intake_Manager_SOC__c = testSMUR[1].Id;
            testSR.IM_Comments__c = '123';
            testSR.SOM_Comments__c = '';
            testSR.Return_Decline_Reason__c  = '';
            GlobalVariables.SM_SOC_ISINSERT = false;
            
            Test.startTest();
            try{
                update testSR;
            }
            catch(Exception e){
                System.debug(e);
            }
            Test.stopTest();
        }
    }
    
    /*
    v3.0 CR 11561: GSD User Story (162173) - To Pre-Populate the 7 Contact (Customer Contact Information (Name)) fields in 
    "Request Custom Service Support" Record type Support Request creation
    */
    static testMethod void populateContactFieldsInSR() {
        
        Account testAccount = new Account(Name='testAccount');     
        insert testAccount; 
        
        Opportunity testOpp = new opportunity();
        testOpp.name = 'test opportunity';
        testOpp.StageName = 'Discover - 10%';
        testOpp.CloseDate = System.Today();
        insert testOpp;  
        
        Contact testContactObjt= new Contact(AccountID = testAccount.ID, Email = 'Email_115@dellTeam.Com', FirstName = 'TestContact', LastName = '1', Title='VP',MailingStreet='123 Main', MailingCity='Peoria', MailingState='IL', MailingCountry='US', MailingPostalCode='33333',Phone='3213213211',MobilePhone='3213213211',Fax='3213123211',Status__c = 'Marketing Suspect');      
        insert testContactObjt;             

        //Get  Request Custom Service Support Record type id
        Id  RCSS_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Custom Service Support', 'Support_Request__c', true);    

        Support_Request__c SR = new Support_Request__c(RecordTypeId = RCSS_RECORDTYPEID, Opportunity__c = testOpp.Id, Solution_Architect__c = 'Yes',
                                    Engagement_Time_Frame__c = System.Today() + 10, Project_Type__c = 'CWS', Project_Duration_months__c = 2, 
                                    Decision_Date__c = System.Today() + 10, Primary_Work_Delivery_Language__c = 'English',
                                    Custom_Service_Support__c = 'Custom Service Solution', Comments__c = 'Test Comments', Deliverable_Due_Date__c = System.Today() + 15, Customer_Contact_InformationName__c = testContactObjt.Id, Suggested_Delivery_Method__c = 'FastTrack');
        Test.startTest();
        insert SR;

        //Query the fields in Support Request object
        Support_Request__c SR2 = [SELECT Id, Customer_Contact_Information_Name__c, Customer_Contact_Information_Phone__c, Customer_Contact_Information_Email__c, Primary_Work_Delivery_Address_1__c, Primary_Work_Delivery_City__c, Primary_Work_Delivery_State_Province__c,
        Primary_Work_Delivery_Country__c, Suggested_Delivery_Method__c FROM Support_Request__c WHERE Id =: SR.Id];    
        
        //Query the fields in Contact object
        Contact con2 = [SELECT Id, Name, Phone, Email, MailingStreet, MailingCity, MailingState, MailingCountry FROM Contact 
                    WHERE Id =: testContactObjt.Id];    
        
        //Assert the Contact fields are populated in Support Request object
        System.assertEquals(con2.Name,SR2.Customer_Contact_Information_Name__c);
        System.assertEquals(con2.Phone,SR2.Customer_Contact_Information_Phone__c);
        System.assertEquals(con2.Email,SR2.Customer_Contact_Information_Email__c);
        System.assertEquals(con2.MailingStreet,SR2.Primary_Work_Delivery_Address_1__c);
        System.assertEquals(con2.MailingCity,SR2.Primary_Work_Delivery_City__c);
        System.assertEquals(con2.MailingState,SR2.Primary_Work_Delivery_State_Province__c);
        System.assertEquals(con2.MailingCountry,SR2.Primary_Work_Delivery_Country__c);   
        
        Test.stopTest();
    }
    
    /*
    v4.0 CR 11809: GSD User Story (162173) - Assign 'Support  Owner' to 'Solution Architect Assigned By' if logged in user has "Boomi Integration API Only" profile
    */
    static testMethod void populateSolutionArchitectAssignedBy() {
        
        List<User> testUserList = new List<User>();
            
        //Create Test Data  
        Profile userProfile= [select id,name from profile where name like '%Sales Rep%' order by name limit 1 ];
        for (integer i=0; i<2;i++){
            User user = new User( Username='test' +i+ System.currentTimeMillis() + '@test.com',
                                Alias = 'test'+i, 
                                Email='test'+ i +'@dell.com', 
                                FirstName='Tfirst'+i, 
                                LastName='TLast'+i,
                                ProfileId = userProfile.Id, 
                                LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', 
                                EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey='America/Los_Angeles',
                                Badge_Number__c='TEST'+i+System.currentTimeMillis());
                
            testUserList.add(user);   
        }
            
        UserRole testUserRole = [select id, name from userrole where name like '%WW_Exec%' limit 1];
        User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true][0];
        //Create test Boomi User
        User testBoomiUser;
        System.runAs(adminusr){
           
            testBoomiUser = new User(Username='boomi_integuser' +'@dell.comtest',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    ProfileId = '00eA0000000hNqF', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    UserRoleId = testUserRole.Id);
            insert testBoomiUser;
            insert testUserList;
        }
        
        //Login as Boomi user
        System.runAs(testBoomiUser) {
        TriggerExecutionController.setSkipAllTriggers(true);
        Account testAccount = new Account(Name='testAccount');     
        insert testAccount; 
        
        AccountTeamMember atm=new AccountTeamMember(userId=testUserList[0].Id,
                                                     TeamMemberRole='Services Intake Manager',
                                                     accountId = testAccount.id); 
        insert atm;                                          
        
        Opportunity testOpp = new opportunity();
        testOpp.name = 'test opportunity';
        testOpp.StageName = 'Discover - 10%';
        testOpp.CloseDate = System.Today();
        insert testOpp;  
        
        Contact testContactObjt= new Contact(AccountID = testAccount.ID, Email = 'Email_115@dellTeam.Com', FirstName = 'TestContact', LastName = '1', Title='VP',MailingStreet='123 Main', MailingCity='Peoria', MailingState='IL', MailingCountry='US', MailingPostalCode='33333',Phone='3213213211',MobilePhone='3213213211',Fax='3213123211',Status__c = 'Marketing Suspect');      
        insert testContactObjt;             
        //Get  Request Custom Service Support Record type id
        Id  RCSS_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Custom Service Support', 'Support_Request__c', true);    

        Support_Request__c SR = new Support_Request__c(RecordTypeId = RCSS_RECORDTYPEID, Opportunity__c = testOpp.Id, Solution_Architect__c = 'Yes',
                                    Engagement_Time_Frame__c = System.Today() + 10, Project_Type__c = 'CWS', Project_Duration_months__c = 2, 
                                    Decision_Date__c = System.Today() + 10, Primary_Work_Delivery_Language__c = 'English',
                                    Custom_Service_Support__c = 'Custom Service Solution', Comments__c = 'Test Comments', Deliverable_Due_Date__c = System.Today() + 15, Customer_Contact_InformationName__c = testContactObjt.Id, Suggested_Delivery_Method__c = 'FastTrack',
                                    Support_Owner__c = testUserList[0].Id, Solution_Architect_Status__c = 'Resource Requested', 
                                    Support_Owner_Team_Role__c = 'Services Intake Manager');
        Test.startTest();
        insert SR;      
        Support_Request__c SR2 = [SELECT Id, Solution_Architect_Name__c, Support_Owner__c FROM Support_Request__c WHERE Id =: SR.Id];

        //Update Solution Architect Name
        SR2.Solution_Architect_Name__c = testUserList[1].Id;
        update SR2;
        
        Support_Request__c SR3 = [SELECT Id, Support_Owner__c, Solution_Architect_Assigned_By__c FROM Support_Request__c WHERE Id =: SR2.Id];       
        //Assert the Solution_Architect_Assigned_By__c
        System.assertEquals(testUserList[0].Id,SR3.Solution_Architect_Assigned_By__c);
        }
                
        Test.stopTest();
    }
    
    /* v5.0 - CR 11963: Story 195421:[Pre-Sales] Excluding Boomi Integration User from Mandatory fields check while updating Support Request via API                                                     
    */
    static testMethod void excludeBoomiUserFromMandatoryCheck() {
        
        UserRole testUserRole = [select id, name from userrole where name like '%WW_Exec%' limit 1];
        //6.0
        //User adminusr = [SELECT Id, username FROM User WHERE Profile.Name = 'System Administrator' AND IsActive=true][0];
                
        //Create test Boomi User
        User testBoomiUser;
        TriggerExecutionController.setSkipAllTriggers(true);
        //System.runAs(adminusr) {
            testBoomiUser = new User(Username='boomi_integuser' +'@dell.comtest',
                                    Alias = 'Test', 
                                    Email='Test'+'@dell.com',            
                                    LastName='Test',
                                    ProfileId = '00eA0000000hNqF', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    EmailEncodingKey='UTF-8', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    Badge_Number__c='Test'+System.currentTimeMillis(),
                                    UserRoleId = testUserRole.Id);
            insert testBoomiUser;
        //}
        
        //Login as Boomi user
        System.runAs(testBoomiUser) {
        Account testAccount = new Account(Name='testAccount');     
        insert testAccount; 

        Opportunity testOpp = new opportunity();
        testOpp.name = 'test opportunity';
        testOpp.StageName = 'Discover - 10%';
        testOpp.CloseDate = System.Today();
        insert testOpp;  
        
        TriggerExecutionController.setSkipAllTriggers(false);
        TriggerExecutionController.setSkipOpportunityTriggers(true);
        TriggerExecutionController.setSkipAllTriggers(true);
        //Get  Request Custom Service Support Record type id
        Id  RCSS_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Custom Service Support', 'Support_Request__c', true);    

        //Insert Support Request without any mandatory fields and Solution_Architect__c = No
        Support_Request__c SR = new Support_Request__c(RecordTypeId = RCSS_RECORDTYPEID, Opportunity__c = testOpp.Id, Solution_Architect__c = 'No');
        
        Test.startTest();
        insert SR;      
        Support_Request__c SR2 = [SELECT Id, Solution_Architect_Name__c, Support_Owner__c FROM Support_Request__c WHERE Id =: SR.Id];

        //Assign Solution Architect = Yes and update SR without entering any mandatory fields
        SR2.Solution_Architect__c = 'Yes';
        update SR2;
        
        Support_Request__c SR3 = [SELECT Id, Customer_Contact_InformationName__c, Engagement_Time_Frame__c, Project_Type__c, Project_Duration_months__c, Decision_Date__c FROM Support_Request__c WHERE Id =: SR2.Id];       
        
        //Assert some of the mandatory fields are blank in the updated SR
        System.assertEquals(null,SR3.Customer_Contact_InformationName__c);
        System.assertEquals(null,SR3.Engagement_Time_Frame__c);
        System.assertEquals(null,SR3.Project_Type__c);
        System.assertEquals(null,SR3.Project_Duration_months__c);
        System.assertEquals(null,SR3.Decision_Date__c);
        }
                
        Test.stopTest();
    
    } 
    static testMethod void skip_Support_Request_Trigger() {
        
        Opportunity testOpp = new opportunity();
        testOpp.name = 'test opportunity';
        testOpp.StageName = 'Discover - 10%';
        testOpp.CloseDate = System.Today();
        insert testOpp;  
        
        //Get  Request Custom Service Support Record type id
        Id  RCSS_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Custom Service Support', 'Support_Request__c', true);    
        
        //Insert Support Request without any mandatory fields and Solution_Architect__c = No
        Support_Request__c SR = new Support_Request__c(RecordTypeId = RCSS_RECORDTYPEID, Opportunity__c = testOpp.Id, Solution_Architect__c = 'No');
        TriggerExecutionControl__c tc =new  TriggerExecutionControl__c(SkipTriggers__c =true, Name ='Support_Request__c');
        insert tc;
        Test.startTest();
        insert SR;
        Test.stopTest();
        
    }
    static testMethod void RequestGlobalBusinessOpsPMTrigger() {
        
        Opportunity testOpp = new opportunity();
        testOpp.name = 'test opportunity';
        testOpp.StageName = 'Discover - 10%';
        testOpp.CloseDate = System.Today();
        insert testOpp;  
        
        //Get  Request Custom Service Support Record type id
        Id  GBOPM_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Global Business Ops PM Support', 'Support_Request__c', true);    
        String PPT_SE_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Pre-Sales Product Technologist Support - SE', 'Support_Request__c', true); 
        //Insert Support Request without any mandatory fields and Solution_Architect__c = No
        Support_Request__c SR1 = new Support_Request__c(RecordTypeId = GBOPM_RECORDTYPEID, Opportunity__c = testOpp.Id, Solution_Architect__c = 'No',Support_Status__c = 'Resource requested');
        Support_Request__c SR2 = new Support_Request__c(RecordTypeId = PPT_SE_RECORDTYPEID, Opportunity__c = testOpp.Id, Solution_Architect__c = 'No',Support_Status__c = 'Resource requested');
        List<Support_Request__c> srList = new List<Support_Request__c>();
        srList.add(SR1);
        srList.add(SR2);
        insert srList;
        Test.startTest();
        SR2.Intake_Manager__c = userinfo.getUserId();
        SR2.Assigned_System_Engineer_1__c =userinfo.getUserId();
        SR2.Assigned_System_Engineer_2__c =userinfo.getUserId();
        update srList;
        Test.stopTest(); 
        
    }   
    static testMethod void CstmSolnEnggSprtRTTrigger() {
        
        Opportunity testOpp = new opportunity();
        testOpp.name = 'test opportunity';
        testOpp.StageName = 'Discover - 10%';
        testOpp.CloseDate = System.Today();
        insert testOpp;  
        
        List<Sales_Motion_User_Role__c> somList = new List<Sales_Motion_User_Role__c >();
        Sales_Motion_User_Role__c somBC = new Sales_Motion_User_Role__c (Username__c = UserInfo.getUserId(), Role__c = 'Business Consultant');
        somList.add(somBC);
        Sales_Motion_User_Role__c somPM = new Sales_Motion_User_Role__c (Username__c = UserInfo.getUserId(), Role__c = 'Project Manager');
        somList.add(somPM);
        Sales_Motion_User_Role__c somEG = new Sales_Motion_User_Role__c (Username__c = UserInfo.getUserId(), Role__c = 'Engineer');
        somList.add(somEG);
        //somList.add(new Sales_Motion_User_Role__c (Username__c = UserInfo.getUserId(), Role__c = 'SOC Intake Manager'));
        insert somList;
       
        //Get  Request Custom Service Support Record type id
        String CstmSolnEnggSprtRT=IdLookupUtils.getRecordTypeId('Request PG Custom Solutions Engineering Support', 'Support_Request__c', true);
        //Insert Support Request without any mandatory fields and Solution_Architect__c = No
        Support_Request__c SR1 = new Support_Request__c(RecordTypeId = CstmSolnEnggSprtRT, Opportunity__c = testOpp.Id, Solution_Architect__c = 'No');

        Support_Request__c SR2 = new Support_Request__c(RecordTypeId = CstmSolnEnggSprtRT, Opportunity__c = testOpp.Id, Solution_Architect__c = 'No');
        List<Support_Request__c> srList = new List<Support_Request__c>();
        srList.add(SR1);
        srList.add(SR2);
        insert srList;
      
        Test.startTest();
        SR1.Status__c = 'In Sustaining';
        SR1.Project_Manager__c = somPM.Id;
        SR1.Business_Consultant__c= somBC.Id;
        SR1.Engineer_1__c = somEG.Id;
        SR1.Engineer_2__c = somEG.Id;
        SR1.Engineer_3__c = somEG.Id;
        SR1.Engineer_4__c = somEG.Id;
        SR1.Exit_Report_Submitted__c = 'Yes';
        
        SR2.Status__c = 'Incomplete';

        GlobalVariables.SM_SOC_ISINSERT = false;
        update srList;
        Test.stopTest();
        
    } 
    
    static testMethod void CSS_RECORDTYPEID_Trigger() {
        
        Opportunity testOpp = new opportunity();
        testOpp.name = 'test opportunity';
        testOpp.StageName = 'Discover - 10%';
        testOpp.CloseDate = System.Today();
        insert testOpp;  
        Account testAccount = new Account(Name='testAccount', Type = 'End User', OwnerId = userInfo.getUserId());     
        insert testAccount; 
        Contact con = new Contact(FirstName='test',LastName='Test2',Email='test@dell.com',MailingStreet='test',MailingCity='test',MailingState='test',
                                  MailingCountry='test',AccountId=testAccount.Id,Phone='12345',Decision_Making_Role__c='Business User');
        insert con; 
        
        Sales_Motion_User_Role__c som = new Sales_Motion_User_Role__c (Username__c = UserInfo.getUserId(), Role__c = 'SOC Intake Manager');
        insert som;
        
        //Get  Request Custom Service Support Record type id
        String CSS_RECORDTYPEID = IdLookupUtils.getRecordTypeId('Request Custom Service Support', 'Support_Request__c', true); 
        //Insert Support Request without any mandatory fields and Solution_Architect__c = No 
        Support_Request__c SR1 = new Support_Request__c(RecordTypeId = CSS_RECORDTYPEID, Opportunity__c = testOpp.Id, Services_Finance_Support__c = 'Yes', Services_Finance_Support_Status__c = null,Pricing_Cycle_Status__c = 'Preliminary/indicative pricing',HW_SW_or_other_Financing_Dell_owned__c = 'Yes',Customer_Pricing_Due_Date__c = system.Date.today()+1,Engagement_Time_Frame__c=system.Date.today()+1,Customer_Contact_InformationName__c=con.id);
        Support_Request__c SR2 = new Support_Request__c(RecordTypeId = CSS_RECORDTYPEID, Opportunity__c = testOpp.Id, Services_Proposal_Support__c = 'Yes', Services_Proposal_Support_Status__c = null,Pricing_Cycle_Status__c = 'Preliminary/indicative pricing',HW_SW_or_other_Financing_Dell_owned__c = 'Yes',Customer_Pricing_Due_Date__c = system.Date.today()+1,Engagement_Time_Frame__c=system.Date.today()+1,Customer_Contact_InformationName__c=con.id);
        Support_Request__c SR3 = new Support_Request__c(RecordTypeId = CSS_RECORDTYPEID, Opportunity__c = testOpp.Id, Deal_Governance_Review_Support__c = 'Yes', Deal_Governance_Review_Support_Status__c = null,Pricing_Cycle_Status__c = 'Preliminary/indicative pricing',HW_SW_or_other_Financing_Dell_owned__c = 'Yes',Customer_Pricing_Due_Date__c = system.Date.today()+1,Engagement_Time_Frame__c=system.Date.today()+1,Customer_Contact_InformationName__c=con.id);
        Support_Request__c SR4 = new Support_Request__c(RecordTypeId = CSS_RECORDTYPEID, Opportunity__c = testOpp.Id, Services_Legal_Support__c = 'Yes', Services_Legal_Support_Status__c = null,Pricing_Cycle_Status__c = 'Preliminary/indicative pricing',HW_SW_or_other_Financing_Dell_owned__c = 'Yes',Customer_Pricing_Due_Date__c = system.Date.today()+1,Engagement_Time_Frame__c = system.Date.today()+1,Customer_Contact_InformationName__c=con.id);
        Support_Request__c SR5 = new Support_Request__c(RecordTypeId = CSS_RECORDTYPEID, Opportunity__c = testOpp.Id, Solution_Architect__c = 'Yes', Solution_Architect_Status__c = null,Pricing_Cycle_Status__c = 'Preliminary/indicative pricing',HW_SW_or_other_Financing_Dell_owned__c = 'Yes',Customer_Pricing_Due_Date__c = system.Date.today()+1,Engagement_Time_Frame__c=system.Date.today()+1,Customer_Contact_InformationName__c=con.id);
        List<Support_Request__c> srList = new List<Support_Request__c>();
        srList.add(SR1);
        //srList.add(SR2);
        //srList.add(SR3);
        //srList.add(SR4);
        //srList.add(SR5);
        CSSR_Pursuit_Support__c cssr1 = new CSSR_Pursuit_Support__c(Pursuit_Team_Mailbox__c='proposals_global_services_proposal_support@dell.com.dit2', Resource_Type_Name__c='Services Proposal Support', Name='Proposal');
        CSSR_Pursuit_Support__c cssr2 = new CSSR_Pursuit_Support__c(Pursuit_Team_Mailbox__c='global_dgr_support@dell.com.dit2', Resource_Type_Name__c='Deal Governance Review Support', Name='DGR');
        CSSR_Pursuit_Support__c cssr3 = new CSSR_Pursuit_Support__c(Pursuit_Team_Mailbox__c='services_global_pricing_support@dell.com.dit2', Resource_Type_Name__c='Services Finance Support', Name='Finance');
        CSSR_Pursuit_Support__c cssr4 = new CSSR_Pursuit_Support__c(Pursuit_Team_Mailbox__c='legal_us_services_contract_support@dell.com.dit2', Resource_Type_Name__c='Services Legal Support', Name='Legal');
        List<CSSR_Pursuit_Support__c> cssrList = new List<CSSR_Pursuit_Support__c>();
        cssrList.add(cssr1);
        cssrList.add(cssr2);
        cssrList.add(cssr3);
        cssrList.add(cssr4);
        insert cssrList;
        
        Test.startTest();
        insert srList;
        SR1.Status__c = 'In Sustaining';
        //SR2.Status__c = 'Incomplete';
        update srList;
        Test.stopTest();
        
    }
}
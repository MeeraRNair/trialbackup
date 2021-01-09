/*****************************************************************************
*CreatedBy : Shubham Bhatt
* 
* Story: 6295277
* 
* Purpose: To cover the test scenarios which needs to be done in before insertion of Renewal Opportunity
*
*Date : 13thAug2019
*******************************************************************************/
@isTest
Public Class RenewalOpportunityTriggerHandlerBI_Test {
    
    @testSetup public static void setup() { 
        
        //create custom setting
        EMC_General_Settings__c objGS = New EMC_General_Settings__c(Create_Quote_Encrypt_Key__c = 'dg67ewh1ImzndDwy1ISgMQ==',
                                                                    Direct_Distribution_Channels__c = 'Direct' ,
                                                                    Hybris_URL__c = 'https://myquotes-qav.emc.com/createQuote/createQuoteFromSFDC');
        
        //insert objGS; 
        
        OWD__c owdSetting = New OWD__c();
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        
        insert owdSetting;      
        
        list<RenewalsLabels__c> listRenLabels = New list<RenewalsLabels__c>();
        
        listRenLabels.add(New RenewalsLabels__c(Name = 'sourceSystem_EMC_Core', labelValue__c = 'EMC Core'));
        listRenLabels.add(New RenewalsLabels__c(Name = 'sourceSystem_Renewals_EBIA', labelValue__c = 'Renewals EBIA'));
        listRenLabels.add(New RenewalsLabels__c(Name = 'teamMemberRole', labelValue__c = 'Service Global Renewals Sales Rep'));
        listRenLabels.add(New RenewalsLabels__c(Name = 'type_EMC_Renewals_Direct', labelValue__c = 'EMC Renewals Direct'));
        listRenLabels.add(New RenewalsLabels__c(Name = 'type_EMC_Renewals_In_Direct', labelValue__c = 'EMC Renewals In-Direct'));
        
        insert listRenLabels;
        
    }
    
    Public Static testMethod void setOpportunityOwnerTest1(){
        
        createRenewalBIRec();
        User usr = userSetup();
        insert usr;
        
        System.runAs(usr){
            
            Opportunity testOpportunity = opptySetupWithRole('Account Executive');
            
            Test.startTest();
            insert testOpportunity;
            
            System.assertEquals(testOpportunity.ownerid,testOpportunity.account.ownerid);                                
            test.StopTest();
        }
    }
    Public Static testMethod void setOpportunityOwnerTest2(){
        
        createRenewalBIRec();
        User usr = userSetup();
        insert usr;
        
        System.runAs(usr){
            
            Opportunity testOpportunity = opptySetupWithRole('Service Global Renewals Sales Rep');
            
            
            Test.startTest();
            insert testOpportunity;
            
            System.assertEquals(testOpportunity.ownerid,testOpportunity.account.ownerid);                                
            test.StopTest();
        }
    }
    Public Static testMethod void setOpportunityOwnerTest3(){
        
        createRenewalBIRec();
        User usr = userSetup();
        insert usr;
        
        System.runAs(usr){
            
            Opportunity testOpportunity = opptySetupWithoutRole();
            
            Test.startTest();
            insert testOpportunity;
            
            System.assertEquals(testOpportunity.ownerid,testOpportunity.account.ownerid);                                 
            test.StopTest();
        }
    }
    Public Static testMethod void bulkOptyLoadOwner(){
        
        createRenewalBIRec();
        User usr = userSetup();
        insert usr;
        list<opportunity> listOpty = new list<opportunity>();
        System.runAs(usr){
            
            
            
            
            String strpid = setupPricebook();
            
            Account testAcc = accountSetup();             
            insert testAcc;
            
            Opportunity testOpportunity = New Opportunity();
            testOpportunity.RecordTypeid = RenewalOpportunity_Utils.aposRecordTypeId;
            
            testOpportunity.name='test APOS2';
            testOpportunity.Accountid=testAcc.id; 
            testOpportunity.CloseDate=system.today()  + 5;
            testopportunity.pricebook2Id = strpid;             
            testOpportunity.CurrencyIsoCode='USD';                
            testopportunity.probability = 1.0;
            testOpportunity.StageName='Plan - 1%';                                   
            testOpportunity.LeadSource = 'Contract Renewal';
            testOpportunity.Source_System__c = 'EMC Core';
            testOpportunity.Type = 'EMC Renewals-Direct';
            testOpportunity.EMC_Opportunity_Amount__c = 500;  
            
            Opportunity testOpportunity1 = New Opportunity();
            testOpportunity1.RecordTypeid = RenewalOpportunity_Utils.aposRecordTypeId;
            
            testOpportunity1.name='test APOS2';
            testOpportunity1.Accountid=testAcc.id; 
            testOpportunity1.CloseDate=system.today()  + 5;
            testOpportunity1.pricebook2Id = strpid;             
            testOpportunity1.CurrencyIsoCode='USD';                
            testOpportunity1.probability = 1.0;
            testOpportunity1.StageName='Plan - 1%';                                    
            testOpportunity1.LeadSource = 'Contract Renewal';
            testOpportunity1.Source_System__c = 'EMC Core';
            testOpportunity1.Type = 'EMC Renewals-Direct';
            testOpportunity1.EMC_Opportunity_Amount__c = 500;  
            
            listOpty.add(testOpportunity);
            listOpty.add(testOpportunity1);
            
            
            Test.startTest();
            
            insert listOpty;
            system.debug('---listOpty---'+listOpty);
            System.assertEquals(testOpportunity.ownerid,testOpportunity.account.ownerid);                                 
            test.StopTest();
        }
    }
    Public Static user userSetup() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User usr = New User(LastName = 'Integration User',
                            FirstName ='Renewals EBIA',
                            Alias = 'jliv',
                            Email = 'jason.liveston@dell.com',
                            Username = 'jason.liveston@dell.com',
                            ProfileId = profileId.id,
                            Badge_Number__c='12348769',
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US',
                            renewal_user__c = true
                           );
        Return usr;
        
    }
    Public Static account accountSetup() {
        Account testAcc = New Account();
        testAcc.name = 'Some test Account2';        
        testAcc.status__c = 'Active';
        testAcc.Account_Country_Code__c='US';              
        Return testAcc;
    }
    Public Static accountTeamMember accountTeamMemberSetup(String strTeamMemRole) {
        Account testAcc = accountSetup();             
        insert testAcc;
        accountTeamMember testAccteam = New accountTeamMember();
        
        testAccteam.accountid = testAcc.id;        
        testAccteam.userid = userinfo.getUserId();
        testAccteam.teammemberrole = strTeamMemRole;              
        Return testAccteam;
    }
    
    Public Static opportunity opptySetupWithRole(String strTeamMemberRoleName) {
        String strpid = setupPricebook();
        
        accountTeamMember accTeam = accountTeamMemberSetup(strTeamMemberRoleName);
        insert accTeam;
        
        
        Opportunity testOpportunity = New Opportunity();
        testOpportunity.RecordTypeid = RenewalOpportunity_Utils.aposRecordTypeId;
        
        testOpportunity.name='test APOS2';
        testOpportunity.Accountid=accTeam.accountid; 
        testOpportunity.CloseDate=system.today()  + 5;
        testopportunity.pricebook2Id = strpid;             
        testOpportunity.CurrencyIsoCode='USD';                
        testopportunity.probability = 1.0;
        testOpportunity.StageName='Plan - 1%';                                   
        testOpportunity.LeadSource = 'Contract Renewal';
        testOpportunity.Source_System__c = 'EMC Core';
        testOpportunity.Type = 'EMC Renewals-Direct';
        testOpportunity.EMC_Opportunity_Amount__c = 500;  
        
        
        Return testOpportunity;
    }
    
    Public Static opportunity opptySetupWithoutRole() {
        String strpid = setupPricebook();
        
        Account testAcc = accountSetup();             
        insert testAcc;
        
        Opportunity testOpportunity = New Opportunity();
        testOpportunity.RecordTypeid = RenewalOpportunity_Utils.aposRecordTypeId;
        
        testOpportunity.name='test APOS2';
        testOpportunity.Accountid=testAcc.id; 
        testOpportunity.CloseDate=system.today()  + 5;
        testopportunity.pricebook2Id = strpid;             
        testOpportunity.CurrencyIsoCode='USD';                
        testopportunity.probability = 1.0;
        testOpportunity.StageName='Plan - 1%';                                   
        testOpportunity.LeadSource = 'Contract Renewal';
        testOpportunity.Source_System__c = 'EMC Core';
        testOpportunity.Type = 'EMC Renewals-Direct';
        testOpportunity.EMC_Opportunity_Amount__c = 500;  
        
        
        Return testOpportunity;
    }
    
    Public Static String setupPricebook(){
        Pricebook2 standardPricebook = New Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = True
        );
        update standardPricebook;
        Pricebook2 s = [select id, name, IsActive from Pricebook2 where IsStandard = True LIMIT 1];
        String strpid = s.Id;
        Return strpid;
    }
    
    Public Static void createRenewalBIRec(){
        String strMockMetaData = '';
        
        Map<String, List<Boolean>> mapEvents = New Map<String, List<Boolean>> {
            'BeforeInsert' => new List<Boolean>{false, false, true, false, false}
        };
            
            For (String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Opportunity", "Class_Name__c": "RenewalOpportunityTriggerHandlerBI"},';
            }
        
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        
    }
    
    
}
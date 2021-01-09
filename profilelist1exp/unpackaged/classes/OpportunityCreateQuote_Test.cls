/***********************************************************
* Name          : OpportunityCreateQuote_Test
* ---------------------------------------------------------
* Revision       Release                   Name           Date                  Description   
* 1.0            FY20-0202                 Abhishek       14 Jan 2019           Test class for OpportunityCreateQuoteCtrl
* 2.0            FY20-0802                 Dan Q          25 Jun 2019           fix parameters for Indirect Oppty
* 3.0            0202                       Srinivas       08-Dec-2019           Impelemented TDF
***************************************************************/
@isTest
private class OpportunityCreateQuote_Test {
    static list<Account> listAcc;
    static list<Opportunity> listOpp;
    @testSetup static void setup() {
        //create custom setting
        EMC_General_Settings__c objGS = new EMC_General_Settings__c(Create_Quote_Encrypt_Key__c = 'dg67ewh1ImzndDwy1ISgMQ==',
                                                                    Direct_Distribution_Channels__c = 'Direct' ,
                                                                    Hybris_URL__c = 'https://myquotes-qav.emc.com/createQuote/createQuoteFromSFDC');
        insert objGS; 
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        insert owdSetting;      
        list<Account> listAccTDF = TestDataFactory.createNAccount(2, 'Partner Account');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listAccTDF;
        list<opportunity> listoppTDF = TestDataFactory.createNopportunities(1, 'Standard Opportunity');
        TriggerExecutionController.setSkipAllTriggers(true);
        insert listoppTDF;
    }
    //Method to show the validation errors
    private static testMethod void throwValidationTest() {
        //skip all triggers on creation of account and opportunity
        TriggerExecutionController.setSkipAllTriggers(true);
        listAcc = [select id from Account limit 1];
        //create account
        // Account objAccount = new Account(Name = 'Test Account');
        // insert objAccount;
       /* Opportunity objOpp = new Opportunity(   Name = 'Test Opp1', accountid = objAccount.Id, type = 'Support Request Only', 
                                             Domain__c ='Business Solutions', StageName ='Plan - 1%', CurrencyIsoCode ='SEK',
                                             CloseDate = date.today(), Services_Location_s__c = 'APJ-All countries',
                                             MyQuotes_Quote_Number__c = '123',
                                             RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId()
                                            );
        insert objOpp; */
        listOpp = [select id,Name,AccountID,type,Domain__c,StageName,CurrencyIsoCode,CloseDate,Services_Location_s__c,MyQuotes_Quote_Number__c from Opportunity limit 1];
        listopp[0].accountid = listAcc[0].id;
        listopp[0].type = 'Support Request Only';
        listopp[0].Domain__c ='Business Solutions';
        listOpp[0].CurrencyIsoCode ='SEK';
        listOpp[0].CloseDate = date.today();
        listOpp[0].Services_Location_s__c = 'APJ-All countries';
        listOpp[0].MyQuotes_Quote_Number__c = '123';
        update listOpp;
        TriggerExecutionController.setSkipAllTriggers(false);
        PageReference pageRef = Page.OpportunityCreateQuote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',listopp[0].id);
        ApexPages.StandardController sc = new ApexPages.StandardController(listopp[0]);
        OpportunityCreateQuoteCtrl objOCQ = new OpportunityCreateQuoteCtrl(sc);
        objOCQ.validate();
        List<Apexpages.Message> listMsgs = ApexPages.getMessages();
        system.assertEquals(4, listMsgs.size());
    }
    //Method to pass the validation errors
    private static testMethod void skipValidationTest() {
        //skip all triggers on creation of account and opportunity
        TriggerExecutionController.setSkipAllTriggers(true);
        //create account
        // Account objAccount = new Account(Name = 'Test Account', EMC_ID__c = '1111111111');
        // insert objAccount;
        Partner_Track__c prtTrack = new Partner_Track__c (PPA_UCID__c = '2222222222');
        insert prtTrack;
        // Account partnerAccount = new Account(Name = 'Test Account', EMC_ID__c = '2222222222', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account').getRecordTypeId(), Partner_Track__c = prtTrack.id ); 
        // insert partnerAccount;
        listAcc = [select id,EMC_ID__c from Account limit 2];
        listAcc[0].EMC_ID__c = '1111111111';
        listAcc[1].EMC_ID__c = '2222222222';
        listAcc[1].Partner_Track__c = prtTrack.id;
        update listAcc;
        /*
        Opportunity objOpp = new Opportunity(   Name = 'Test Opp1', accountid = objAccount.Id, type = 'Deal/Bid - Indirect', 
                                             Domain__c ='Business Solutions', StageName ='Plan - 1%', CurrencyIsoCode ='SEK',
                                             CloseDate = date.today(), Services_Location_s__c = 'APJ-All countries',
                                             EMC_Opportunity_Number__c = 'Test ON', EMC_Sales_Channel__c = 'Test SC',
                                             EMC_Sales_Force__c = 'Test SF', EMC_ID_Opp__c = 'AccountTest' ,
                                             Distributor_Direct_Reseller_Account__c = partnerAccount.id, Indirect_Partner_Account__c = partnerAccount.id);
        insert objOpp;
        */
        listOpp = [select id,Name,AccountID,type,Domain__c,StageName,CurrencyIsoCode,CloseDate,Services_Location_s__c,Indirect_Partner_Account__c, Distributor_Direct_Reseller_Account__c,EMC_Sales_Channel__c, EMC_Opportunity_Number__c,MyQuotes_Quote_Number__c from Opportunity limit 1];
        listopp[0].accountid = listAcc[0].id;
        listopp[0].type = 'Deal/Bid - Indirect';
        listopp[0].Domain__c ='Business Solutions';
        listOpp[0].CloseDate = date.today();
        listOpp[0].EMC_Sales_Force__c='Test SF';
        listOpp[0].Services_Location_s__c = 'APJ-All countries';
        listOpp[0].MyQuotes_Quote_Number__c = '123';
        listOpp[0].EMC_Opportunity_Number__c = 'Test ON';
        listOpp[0].EMC_Sales_Channel__c = 'Test SC';
        listOpp[0].EMC_ID_Opp__c = 'AccountTest';
        listOpp[0].Distributor_Direct_Reseller_Account__c = listAcc[1].id;
        listOpp[0].Indirect_Partner_Account__c = listAcc[1].id;
        TriggerExecutionController.setSkipopportunityTriggers(true);
        update listOpp;
        TriggerExecutionController.setSkipAllTriggers(false);
        PageReference pageRef = Page.OpportunityCreateQuote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',listOpp[0].id);
        ApexPages.StandardController sc = new ApexPages.StandardController(listOpp[0]);
        OpportunityCreateQuoteCtrl objOCQ = new OpportunityCreateQuoteCtrl(sc);
        objOCQ.validate();
        List<Apexpages.Message> listMsgs = ApexPages.getMessages();
        system.assertEquals(1, listMsgs.size());
        objOCQ.redirectToOppty();
        TriggerExecutionController.setSkipopportunityTriggers(false);
        
    }
    
}
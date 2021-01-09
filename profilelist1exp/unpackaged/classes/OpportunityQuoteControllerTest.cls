/**
History:
Version Date            Modified By     Description     
--------------------------------------------------------------------------------------
1.0      04-DEC-2019   Vikas           Implemented TDF
*/

@isTest
private class OpportunityQuoteControllerTest {
    Static list<Opportunity> listOpp; 
    static list<Account> listAcc;
    @testSetup  static void setup() {
        // Create common test data OWD customsetting
        String strMockMetaData = '';
        Map<String, List<Boolean>> mapEvents = new Map<String, List<Boolean>> {
            'AfterUpdate' => new List<Boolean>{false, true, false, false, false}
        };
            for(String strEvent : mapEvents.keySet()) {
                strMockMetaData += '{"DeveloperName": "TestHandler' + strEvent + '", '
                    + '"NamespacePrefix": "",'
                    + '"Event__c": "' + strEvent + '", '
                    + '"sObject__c": "Opportunity", "Class_Name__c": "OpportunityTriggerHandlerAU"},'; 
            }
        strMockMetaData = '[' + strMockMetaData.substringBeforeLast(',') + ']';
        MetadataTriggerManager.listMockMetaData = (List<Trigger_Handler__mdt>)JSON.deserializeStrict(strMockMetaData, List<Trigger_Handler__mdt>.class);
        TriggerExecutionControl__c tec = new TriggerExecutionControl__c();
        tec.Name = 'Opportunity';
        tec.RecursiveCount__c = 2;
        insert tec;
        OWD__c owdSetting = new OWD__c();
        owdSetting.Oppty_Stage1__c = 'Plan - 1%';
        owdSetting.Oppty_Stage10__c = 'Discover - 10%';
        owdSetting.Oppty_Stage30__c = 'Qualify - 30%';
        owdSetting.Oppty_Stage60__c = 'Propose - 60%';
        owdSetting.Oppty_Stage90__c = 'Commit - 90%';
        owdSetting.Oppty_Stage99__c = 'Order Submitted - 99%';
        owdSetting.Oppty_Stage100__c = 'Win - 100%';
        owdSetting.Oppty_Stage0__c = 'Lost, Cancelled - 0%';
        Database.insert(owdSetting);
        Needed_Quote_GS__c objNQGS = new Needed_Quote_GS__c();
        objNQGS.add_quote_desc__c = 'You must enter a valid Quote#, Quantity, Configuration Services and Customer Requested Date on the Product in order to save the Opportunity at the desired Probability.    ';
        objNQGS.add_quote_desc2__c = 'Otherwise all other changes will be saved and the Stage / Probability will not be updated.';
        objNQGS.add_quote_err_msg__c = 'You must enter a valid Quote#, Quantity, Configuration Services and Customer Requested Date in order to save Opportunity Product.';
        objNQGS.add_quote_no_lot_prod_err_msg__c = 'There are not any products that currently meet LOT/Ocean/Needed-Quote criteria.';
        objNQGS.add_quote_title__c = 'Add Quote numbers to Products';
        objNQGS.alt_msg_desc__c = 'Please add quote numbers for all products.';
        objNQGS.alt_msg_title_lt__c = 'Opportunity';
        objNQGS.alt_msg_title_rt__c = 'stage could not be updated.';
        objNQGS.actionlist_nq_label__c = 'Add Quote numbers to Products';
        objNQGS.actionlist_nq_tooltip__c = 'All products must include quote information.';
        objNQGS.trigger_alt_msg__c = 'Please provide a valid Quote#, Quantity, Configuration Services and Customer Requested Date on the Products before changing the stage';
        Database.insert(objNQGS);
        string strProfileId = [SELECT id from profile WHERE Name = 'R16.10 GBL Sales Mgr' LIMIT 1][0].Id;
        User u1 = new User(Alias = 'gblsales', Email='gblsalesmgr@dell.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = strProfileId, TimeZoneSidKey='America/Los_Angeles', UserName='gblsales@dell.com', Badge_Number__c = getUniqueString());
        insert u1;
        List<Create_Quote_Profiles__c> listCQP = new List<Create_Quote_Profiles__c>();
        listCQP.add(new Create_Quote_Profiles__c(Name = 'System Administrator', ProfileName__c = 'System Administrator', isUSP__c = true, isDSP__c = true));
        listCQP.add(new Create_Quote_Profiles__c(Name = 'R16.10 GBL Sales Mgr', ProfileName__c = 'R16.10 GBL Sales Mgr', isUSP__c = true, isDSP__c = true));
        insert listCQP;
        TriggerExecutionController.setSkipAllTriggers(true);
        list<Account> listAcc = TestDataFactory.createNAccount(1, 'Partner Account');
        listAcc[0].name='Test Account';
        listAcc[0].Account_Country_Code__c = 'US';
        listAcc[0].Account_Country__c = 'United States';
        insert listAcc;   
        list<Opportunity> listOppTDF = TestDataFactory.createNOpportunities(2, 'Standard Opportunity');  
        insert listOppTDF;   
        List<Opportunity> listOpp = [SELECT Id, Name, StageName, RecordType.Name, Order_Compliance_Product__c, 
                                     How_many_shipments__c, CloseDate, 
                                     Needed_Quote_Notification_Pop_Up__c, LOT_Large_Opportunity__c, 
                                     Probability, Deal_ID__c,Indirect_Partner_Account__c FROM Opportunity LIMIT 2];
        listOpp[0].AccountID = listAcc[0].id;
        listOpp[0].Indirect_Partner_Account__c = listAcc[0].id;
        listOpp[0].Type = 'Deal/Bid - Indirect';
        listOpp[0].Solution_Type__c = 'Campus';
        listOpp[0].Solution_Name__c = 'Wireless Switches';
        listOpp[0].StageName='Plan - 1%';
        listOpp[0].Partner_Opportunity_Stage__c = 'Plan - 1%';
        listOpp[0].EMC_Opportunity_Number__c = '09872862';
        listOpp[0].Primary_Competitor__c='Unknown';
        listOpp[0].Competitor_Lost_To__c='Unknown';
        listOpp[0].OwnerId = u1.Id;
        listOpp[1].AccountID = listAcc[0].id;
        listOpp[1].Indirect_Partner_Account__c = listAcc[0].id;
        listOpp[1].Type = 'Deal/Bid - Indirect';
        listOpp[1].Solution_Type__c = 'Campus';
        listOpp[1].Solution_Name__c = 'Wireless Switches';
        listOpp[1].StageName='Discover - 10%';
        listOpp[1].Partner_Opportunity_Stage__c = 'Discover - 10%';
        listOpp[1].EMC_Opportunity_Number__c = '09872863';
        listOpp[1].Primary_Competitor__c='Unknown';
        listOpp[1].Competitor_Lost_To__c='Unknown';
        listOpp[1].OwnerId = u1.Id; 
        update listOpp;
        list<OpportunityLineItem> listOppLineItem=TestDataFactory.createNOpportunityLineItem(2);
        listOppLineItem[0].Opportunityid=listOpp[0].id;
        listOppLineItem[0].Ocean_Indicator__c = true;
        listOppLineItem[1].Opportunityid=listOpp[0].id;
        listOppLineItem[1].Ocean_Indicator__c = true;
        insert listOppLineItem;
    }
    static testmethod void validateInitmethodTest() {
        //LOTOpportunityTriggerHandlerBU.bIsInLexUI = true; //remove comment in DIT5
        List<Opportunity> listOpp = [SELECT Id, Name, StageName, RecordType.Name, Order_Compliance_Product__c, How_many_shipments__c, CloseDate, Needed_Quote_Notification_Pop_Up__c, LOT_Large_Opportunity__c, Probability, Deal_ID__c,Account.Account_Country_Code__c FROM Opportunity LIMIT 2];
        System.assertEquals(listOpp.size(), 2);    
        if(listOpp.size() > 0) {
            Test.startTest();
            OpportunityQuoteController.initmethod(listOpp[0].Id);
            Test.stopTest();
        } 
    }
    @isTest
    static void validateUpdateOpportunityItemsTest() {
        List<Opportunity> listOpp = [SELECT Id, Name, StageName, RecordType.Name, Order_Compliance_Product__c, How_many_shipments__c, CloseDate, Needed_Quote_Notification_Pop_Up__c, LOT_Large_Opportunity__c, Probability, Deal_ID__c, Account.Account_Country_Code__c FROM Opportunity LIMIT 2];
        List<OpportunityLineItem> listOLI = [SELECT Id, OpportunityId, PricebookEntryId,Total_Price_in_USD__c, Ocean_Indicator__c,Opportunity.Account_Country_Code__c, Opportunity.Account_Country__c, Quantity, ListPrice, PricebookEntry.UnitPrice, TotalPrice, Quote__c, 
                                             PricebookEntry.Name, PricebookEntry.Product2Id, Product2.Order_Compliant_Product__c,LOT_Indicator__c,Configuration_Services__c, Customer_Requested_Date__c, Request_Type__c, Supportability_Status__c, Support_by_Date__c,Supported_Quantity__c,
                                             Alternate_Item__c, Supportability_Comments__c FROM OpportunityLineItem WHERE OpportunityId =: listOpp[0].Id limit 2];
        System.assertEquals(listOpp.size(), 2);
        if(listOpp.size() > 0) {
            if(listOLI.size() > 0) {
                for(OpportunityLineItem objOLI : listOLI) {
                    if(objOLI.Quote__c == '' || objOLI.Quote__c == null) {
                        objOLI.Quote__c = getUniqueString();
                    }
                }
                Test.startTest();
                TriggerExecutionController.setSkipOpportunityTriggers(true);
                OpportunityQuoteController.updateOpportunityItems(listOLI);
                TriggerExecutionController.setSkipOpportunityTriggers(false);
                Test.stopTest();
            }
        }
    }
    @isTest
    static void validateOpportunityQuoteTest() {
        Test.startTest(); 
        OpportunityQuoteController.getAllPicklistValues('Opportunity', 'StageName');
        OpportunityQuoteController.getNeededQuoteGS();
        List<Opportunity> listOpp = [SELECT Id, Name, StageName, RecordType.Name, Order_Compliance_Product__c, How_many_shipments__c, CloseDate, Needed_Quote_Notification_Pop_Up__c, LOT_Large_Opportunity__c, Probability, Deal_ID__c, Account.Account_Country_Code__c FROM Opportunity LIMIT 2];
        System.assertEquals(listOpp.size(), 2);
        if(listOpp.size() > 0) {
            OpportunityQuoteController.getOpportunityQuoteStatus(listOpp[0].Id);
        }
        Test.stopTest();
    }
    private static string getUniqueString(){
        return String.valueOf(Datetime.now()).replace(' ', '_').replace(':', '_').replace('-', '_');
    }
}